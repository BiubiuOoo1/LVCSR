function [ output_args ] = LVCSR_main( filename,mfcc,wavele,lpcc )
%    LVCSR_main ������������������
%     filename ������Ƶ�ļ�·��
%     mfcc.num mfcc��Ӧ����
%     mfcc.MelNum mfcc��Mel�˲�������
%     wavele.DNnum С��ȥ��С���߶Ȳ���
%     wavele.DNname С��ȥ��С����
%     wavele.num С��Ƶ��ͼ����Ƴ߶Ȳ���
%     wavele.name С��Ƶ�׻���Ӧ��С����
%     lpcc lpcc ��Ӧ����
waveData = myrecursiveFileList(filename);%��ȡ��������
waveNum = length(waveData);%ͳ����������
[savefilepath,~,~]=fileparts(waveData(1).path);%����һ��·���������ļ�·�����������ļ����������ļ���׺��
[junk,~]=fileparts(savefilepath);
[junk]=fileparts(junk);
MotherFileName=[junk,'\','������ȡ'];%����������ȡĸ�ļ���
mkdir(MotherFileName);
for i=1:waveNum
    [savefilepath,~,~]=fileparts(waveData(i).path);%����һ��·���������ļ�·�����������ļ����������ļ���׺��
    [~,allfile]=fileparts(savefilepath);
    SonFileName=[MotherFileName,'\',allfile];%������ȡÿ��������ļ���
    mkdir(SonFileName);
    mkdir([SonFileName,'\','MFCC']);
    mkdir([SonFileName,'\','MySpectrogram']);
    mkdir([SonFileName,'\','CELP']);
    speech = myAudioRead(waveData(i).path);
    [~, ~, soundSegment, zeroOneVec, frameVar] = epdByWaveletZXF(speech, epdPrmSet2Wavelet(speech.fs), 0);%�˵���
    for j = 1:length(soundSegment)
      speech_clear = speech.signal(soundSegment(j).beginSample:soundSegment(j).endSample);%�˵���������ȡ
      speech_clear = DeNoiseByZXF( speech_clear,wavele.DNnum,wavele.DNnum,0 );
      speech_clear=speech_clear-mean(speech_clear);%ȥֱ��
      speech_clear=speech_clear/max(abs(speech_clear));%��һ��
      wave_mfcc(:,j)=frame2mfcc_s(speech_clear,speech.fs,mfcc.MelNum,mfcc.num);%MFCC
    end
end
end

