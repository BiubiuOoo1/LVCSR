function [ output_args ] = LVCSR_main( filename,mfcc,wavele,lpcc )
%    LVCSR_main 语音特征特征主函数
%     filename 输入音频文件路径
%     mfcc.num mfcc对应点数
%     mfcc.MelNum mfcc的Mel滤波器阶数
%     wavele.DNnum 小波去噪小波尺度层数
%     wavele.DNname 小波去噪小波名
%     wavele.num 小波频谱图像绘制尺度层数
%     wavele.name 小波频谱绘制应用小波名
%     lpcc lpcc 对应阶数
waveData = myrecursiveFileList(filename);%提取鸟类声音
waveNum = length(waveData);%统计鸟声个数
[savefilepath,~,~]=fileparts(waveData(1).path);%输入一个路径，返回文件路径名，返回文件名，返回文件后缀名
[junk,~]=fileparts(savefilepath);
[junk]=fileparts(junk);
MotherFileName=[junk,'\','特征提取'];%建立特征提取母文件夹
mkdir(MotherFileName);
for i=1:waveNum
    [savefilepath,~,~]=fileparts(waveData(i).path);%输入一个路径，返回文件路径名，返回文件名，返回文件后缀名
    [~,allfile]=fileparts(savefilepath);
    SonFileName=[MotherFileName,'\',allfile];%特征提取每种鸟的子文件夹
    mkdir(SonFileName);
    mkdir([SonFileName,'\','MFCC']);
    mkdir([SonFileName,'\','MySpectrogram']);
    mkdir([SonFileName,'\','CELP']);
    speech = myAudioRead(waveData(i).path);
    [~, ~, soundSegment, zeroOneVec, frameVar] = epdByWaveletZXF(speech, epdPrmSet2Wavelet(speech.fs), 0);%端点检测
    for j = 1:length(soundSegment)
      speech_clear = speech.signal(soundSegment(j).beginSample:soundSegment(j).endSample);%端点检测声音提取
      speech_clear = DeNoiseByZXF( speech_clear,wavele.DNnum,wavele.DNnum,0 );
      speech_clear=speech_clear-mean(speech_clear);%去直流
      speech_clear=speech_clear/max(abs(speech_clear));%归一化
      wave_mfcc(:,j)=frame2mfcc_s(speech_clear,speech.fs,mfcc.MelNum,mfcc.num);%MFCC
    end
end
end

