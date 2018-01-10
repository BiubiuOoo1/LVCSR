function [ output_args ] = LVCSR_main( filename,mfcc,wavele,lpcc )
%    LVCSR_main 语音特征特征主函数
%     filename 输入音频文件路径
%     mfcc.num mfcc对应点数
%     mfcc.MelNum mfcc的Mel滤波器阶数
%     wavele.DNnum 小波去噪小波尺度层数
%     wavele.DNname 小波去噪小波名
%     wavele.num 小波频谱图像绘制尺度层数
%     wavele.num 小波频谱绘制应用小波名
%     lpcc.num lpcc对应阶数
%     lpcc.name lpcc对应方法
if nargin<1, selfdemo; return; end
if nargin<2, mfcc.num=13; mfcc.MelNum=20; end
if nargin<3, wavele.DNnum=8; wavele.DNname='sym5'; wavele.num=256; wavele.name='cmor3-3'; end
if nargin<4, lpcc.num=12; lpcc.name=1; end
waveData = myrecursiveFileList(filename);%提取鸟类声音
waveNum = length(waveData);%统计鸟声个数
[savefilepath,~,~]=fileparts(waveData(1).path);%输入一个路径，返回文件路径名，返回文件名，返回文件后缀名
[junk,~]=fileparts(savefilepath);
[junk]=fileparts(junk);
MotherFileName=[junk,'\','特征提取'];%建立特征提取母文件夹
mkdir(MotherFileName);
for i=1:waveNum
    [savefilepath,allfileName,~]=fileparts(waveData(i).path);%输入一个路径，返回文件路径名，返回文件名，返回文件后缀名
    [~,allfile]=fileparts(savefilepath);
    SonFileName=[MotherFileName,'\',allfile];%特征提取每种鸟的子文件夹
    mkdir(SonFileName);
    mkdir([SonFileName,'\','MFCC']);
    mkdir([SonFileName,'\','MySpectrogram']);
    mkdir([SonFileName,'\','LPCC']);
    speech = myAudioRead(waveData(i).path);
    [~, ~, soundSegment, zeroOneVec, frameVar] = ...
        epdByWaveletZXF(speech, epdPrmSet2Wavelet(speech.fs), 0);%端点检测
    for j = 1:length(soundSegment)
      speech_clear = ...
          speech.signal(soundSegment(j).beginSample:soundSegment(j).endSample);%端点检测声音提取
      speech_clear = ...
          DeNoiseByZXF( speech_clear,wavele.DNname,wavele.DNnum,0 );%对信号进行去噪
      speech_clear = speech_clear-mean(speech_clear);%去直流
      speech_clear = speech_clear/max(abs(speech_clear));%归一化
      wave_mfcc(:,j) = ...
          frame2mfcc(speech_clear,speech.fs,mfcc.MelNum,mfcc.num);%MFCC
      wave_lpcc(:,j) = frame2LPCCbyZXF( speech_clear,lpcc.num,lpcc.name,0 );
      my_spectrogram = WTspectrogramByzxf(speech_clear , speech.fs, wavele.name, wavele.num, 0);
      save([SonFileName,'\','MySpectrogram','\',allfileName,'_',num2str(j)],'my_spectrogram');
      clear my_spectrogram;
    end
    save([SonFileName,'\','MFCC','\',allfileName,'_MFCC'],'wave_mfcc');
    clear wave_mfcc;
    save([SonFileName,'\','LPCC','\',allfileName,'LPCC'],'wave_lpcc');
    clear wave_lpcc;   
end
end
function selfdemo
mfcc.num=13;
mfcc.MelNum=20;
wavele.DNnum=8;
wavele.DNname='sym3';
wavele.num=256;
wavele.name='cmor3-3';
lpcc.num=12;
lpcc.name=1;
LVCSR_main( 'D:\GIT\LVCSR\鸟类声音1',mfcc,wavele,lpcc );
end

