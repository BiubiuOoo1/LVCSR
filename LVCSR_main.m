function [ output_args ] = LVCSR_main( filename,mfcc,wavele,lpcc )
%    LVCSR_main ������������������
%     filename ������Ƶ�ļ�·��
%     mfcc.num mfcc��Ӧ����
%     mfcc.MelNum mfcc��Mel�˲�������
%     wavele.DNnum С��ȥ��С���߶Ȳ���
%     wavele.DNname С��ȥ��С����
%     wavele.num С��Ƶ��ͼ����Ƴ߶Ȳ���
%     wavele.num С��Ƶ�׻���Ӧ��С����
%     lpcc.num lpcc��Ӧ����
%     lpcc.name lpcc��Ӧ����
if nargin<1, selfdemo; return; end
if nargin<2, mfcc.num=13; mfcc.MelNum=20; end
if nargin<3, wavele.DNnum=8; wavele.DNname='sym5'; wavele.num=256; wavele.name='cmor3-3'; end
if nargin<4, lpcc.num=12; lpcc.name=1; end
waveData = myrecursiveFileList(filename);%��ȡ��������
waveNum = length(waveData);%ͳ����������
[savefilepath,~,~]=fileparts(waveData(1).path);%����һ��·���������ļ�·�����������ļ����������ļ���׺��
[junk,~]=fileparts(savefilepath);
[junk]=fileparts(junk);
MotherFileName=[junk,'\','������ȡ'];%����������ȡĸ�ļ���
mkdir(MotherFileName);
for i=1:waveNum
    [savefilepath,allfileName,~]=fileparts(waveData(i).path);%����һ��·���������ļ�·�����������ļ����������ļ���׺��
    [~,allfile]=fileparts(savefilepath);
    SonFileName=[MotherFileName,'\',allfile];%������ȡÿ��������ļ���
    mkdir(SonFileName);
    mkdir([SonFileName,'\','MFCC']);
    mkdir([SonFileName,'\','MySpectrogram']);
    mkdir([SonFileName,'\','LPCC']);
    speech = myAudioRead(waveData(i).path);
    [~, ~, soundSegment, zeroOneVec, frameVar] = ...
        epdByWaveletZXF(speech, epdPrmSet2Wavelet(speech.fs), 0);%�˵���
    for j = 1:length(soundSegment)
      speech_clear = ...
          speech.signal(soundSegment(j).beginSample:soundSegment(j).endSample);%�˵���������ȡ
      speech_clear = ...
          DeNoiseByZXF( speech_clear,wavele.DNname,wavele.DNnum,0 );%���źŽ���ȥ��
      speech_clear = speech_clear-mean(speech_clear);%ȥֱ��
      speech_clear = speech_clear/max(abs(speech_clear));%��һ��
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
LVCSR_main( 'D:\GIT\LVCSR\��������1',mfcc,wavele,lpcc );
end

