clc;clear;close all;
% ������ȡ
handles.filename='D:\matlab\envi\newFeatures\newFeatures\birdcall\���к�wav';%��ȡ�����ļ�
operOrder=[0 0 0 0 1];folder = {'MFCC';'MFCC_D';'MFCC_s';'MFCC_s_D';...
    'WMFCC';'MySpectrogram';'LPCC'}; 
waveData=myrecursiveFileList(handles.filename);%��ȡ��������
waveNum=length(waveData);
filterNum=13;   %mel�˲�������
mfccNum=13;     %MFCC����
WavletNum=25;   %С������
LPCCNum=10;     %LPCC����
for i=1:waveNum
%    randn('state',0);%������׼��̬�ֲ� ��state���Ƕ������������״̬���г�ʼ�������Ҷ����״̬��ʼֵ��
%    �������һ��ʱ�仹Ҫʹ������������ʱ�򣬻��ܱ��ֵ�ǰ�����ȡֵ��
	fprintf('%d/%d ===> %s\n', i, waveNum, waveData(i).path);%��ӡ��������
    speech=myAudioRead(waveData(i).path);%��ȡ�����ļ�����Ϣ
%     =======================˫�����䵥����=======================
%     if size(speech.signal,2)~=1
%         if sum(abs(speech.signal(:,1)))>sum(abs(speech.signal(:,2)))
%             speech.signal=speech.signal(:,1);
%         else
%             speech.signal=speech.signal(:,2);
%         end 
%     end
%     speech.fs
%     ======================˫�����䵥��������======================
  %======endpoint detection========
     [epInSampleIndex, epInFrameIndex, soundSegment, zeroOneVec, volume, hod, vh] = ...
    epdByVolHod(speech, epdPrmSet(speech.fs), 0);%�Ľ���ĺ���
%==========valueable voice segments========
  speech_clear=[];%�½�һ�������洢���˵������������������
  for j=1:length(soundSegment)
      speech_clear=[speech_clear;...
      speech.signal(soundSegment(j).beginSample:soundSegment(j).endSample)];%�˵���������ȡ
  end
  speech_clear=speech_clear-mean(speech_clear);%ȥֱ��
  speech_clear=speech_clear/max(abs(speech_clear));%��һ��
    [savefilepath,allfileName,junk]=fileparts(waveData(i).path);%����һ��·���������ļ�·�����������ļ����������ļ���׺��
    [junk,allfile]=fileparts(savefilepath);
    savefileName=[allfile,'_',allfileName];%�ļ�Ŀ¼�����ļ���
    if i==1
        for z=1:length(folder)
            new_folder = [savefilepath,'\',char(folder(z,:))]; 
            if ~exist(new_folder)
                mkdir(new_folder);
            end
        end
    end     
    frameSize=25e-3*speech.fs;%�и�����               25ms
    overlap=0;
    frameMat=buffer2(speech_clear,frameSize);
    frameNum=size(frameMat,2);
%     =======================================================================
    if operOrder(1)==1
        for z=1:frameNum
            wave_mfcc(:,z)=frame2mfcc(frameMat(:,z),speech.fs,filterNum,mfccNum);%MFCC
        end
% ========================���MFCC============================        
%          wave_mfcc_D1=[wave_mfcc(:,1:end-1);diff(wave_mfcc,1,2)];
%          wave_mfcc_D2=[wave_mfcc_D1(:,1:end-1);diff(wave_mfcc,2,2)];
% ============================================================
         myfile=[savefilepath,'\','MFCC','\',savefileName,'_MFCC','.csv'];     
         csvwrite(myfile,wave_mfcc');
%          myfile=[savefilepath,'\','MFCC_D','\',savefileName,'_MFCC_D','.csv'];     
%          csvwrite(myfile,wave_mfcc_D1');
         clear wave_mfcc ��
         clear wave_mfcc_D1;
    end
    if operOrder(2)==1
        for z=1:frameNum
            wave_mfcc_s(:,z)=frame2mfcc_s(frameMat(:,z),speech.fs,filterNum,mfccNum);%MFCC
        end
% ========================���MFCC============================        
%          wave_mfcc_s_D1=[wave_mfcc_s(:,1:end-1);diff(wave_mfcc_s,1,2)];
%          wave_mfcc_s_D2=[wave_mfcc_s_D1(:,1:end-1);diff(wave_mfcc_s,2,2)];
% ============================================================
         myfile=[savefilepath,'\','MFCC_s','\',savefileName,'_MFCC_s','.csv'];     
         csvwrite(myfile,wave_mfcc_s');
%          myfile=[savefilepath,'\','MFCC_s_D','\',savefileName,'_MFCC_s_D','.csv'];     
%          csvwrite(myfile,wave_mfcc_s_D1');
         clear wave_mfcc_s ;
         %clear wave_mfcc_s_D1;
    end
    if operOrder(3)==1
        for z=1:frameNum
            wave_Wmfcc(:,z)=frame2Wmfcc(frameMat(:,z),speech.fs,WavletNum,mfccNum);%С���任MFCC
        end
        myfile=[savefilepath,'\','WMFCC','\',savefileName,'_WMFCC','.csv'];
        csvwrite(myfile,wave_Wmfcc');
        clear wave_Wmfcc;
%        MFCCfile=[savefilepath,'\',savefileName,'_WMFCC'];
%        save(MFCCfile,'wave_Wmfcc');
%        clear wave_Wmfcc;
    end
%     =============================����ͼ====================================
    if operOrder(4)==1
        my_spectrogram=spectrogramByzxf( speech_clear, speech.fs, frameSize, overlap );%��ȡ����ͼ
        my_spectrogramfile=[savefilepath,'\','MySpectrogram','\',savefileName,'_spectrogram','.jpg'];
        saveas(my_spectrogram,my_spectrogramfile);
        close all hidden;clear my_spectrogram;
    end
    if operOrder(5)==1
        for z=1:frameNum
%             wave_lpcc(:,z)=frame2LPCCbyZXF(frameMat(:,z),LPCCNum,1);%LPCC
            wave_lpcc(:,z)=frame2Wmfcc2cwtBYZXF(frameMat(:,z),speech.fs,WavletNum,mfccNum);%С���任MFCC
        end
         myfile=[savefilepath,'\','LPCC','\',savefileName,'_LPCC','.csv'];     
         csvwrite(myfile,wave_lpcc');
%          myfile=[savefilepath,'\','MFCC_D','\',savefileName,'_MFCC_D','.csv'];     
%          csvwrite(myfile,wave_mfcc_D1');
         clear wave_lpcc ��
    end
end