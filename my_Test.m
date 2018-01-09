clc;clear;close all;
% 特征提取
handles.filename='D:\matlab\envi\newFeatures\newFeatures\birdcall\拉市海wav';%读取鸟类文件
operOrder=[0 0 0 0 1];folder = {'MFCC';'MFCC_D';'MFCC_s';'MFCC_s_D';...
    'WMFCC';'MySpectrogram';'LPCC'}; 
waveData=myrecursiveFileList(handles.filename);%提取鸟类声音
waveNum=length(waveData);
filterNum=13;   %mel滤波器阶数
mfccNum=13;     %MFCC阶数
WavletNum=25;   %小波阶数
LPCCNum=10;     %LPCC阶数
for i=1:waveNum
%    randn('state',0);%产生标准正态分布 ‘state’是对随机发生器的状态进行初始化，并且定义该状态初始值。
%    比如你过一段时间还要使用这个随机数的时候，还能保持当前的随机取值。
	fprintf('%d/%d ===> %s\n', i, waveNum, waveData(i).path);%打印鸟名名字
    speech=myAudioRead(waveData(i).path);%获取鸟类文件的信息
%     =======================双声道变单声道=======================
%     if size(speech.signal,2)~=1
%         if sum(abs(speech.signal(:,1)))>sum(abs(speech.signal(:,2)))
%             speech.signal=speech.signal(:,1);
%         else
%             speech.signal=speech.signal(:,2);
%         end 
%     end
%     speech.fs
%     ======================双声道变单声道结束======================
  %======endpoint detection========
     [epInSampleIndex, epInFrameIndex, soundSegment, zeroOneVec, volume, hod, vh] = ...
    epdByVolHod(speech, epdPrmSet(speech.fs), 0);%改进后的函数
%==========valueable voice segments========
  speech_clear=[];%新建一段声音存储，端点检测出的声音存在这里
  for j=1:length(soundSegment)
      speech_clear=[speech_clear;...
      speech.signal(soundSegment(j).beginSample:soundSegment(j).endSample)];%端点检测声音提取
  end
  speech_clear=speech_clear-mean(speech_clear);%去直流
  speech_clear=speech_clear/max(abs(speech_clear));%归一化
    [savefilepath,allfileName,junk]=fileparts(waveData(i).path);%输入一个路径，返回文件路径名，返回文件名，返回文件后缀名
    [junk,allfile]=fileparts(savefilepath);
    savefileName=[allfile,'_',allfileName];%文件目录名，文件名
    if i==1
        for z=1:length(folder)
            new_folder = [savefilepath,'\',char(folder(z,:))]; 
            if ~exist(new_folder)
                mkdir(new_folder);
            end
        end
    end     
    frameSize=25e-3*speech.fs;%切割音框               25ms
    overlap=0;
    frameMat=buffer2(speech_clear,frameSize);
    frameNum=size(frameMat,2);
%     =======================================================================
    if operOrder(1)==1
        for z=1:frameNum
            wave_mfcc(:,z)=frame2mfcc(frameMat(:,z),speech.fs,filterNum,mfccNum);%MFCC
        end
% ========================差分MFCC============================        
%          wave_mfcc_D1=[wave_mfcc(:,1:end-1);diff(wave_mfcc,1,2)];
%          wave_mfcc_D2=[wave_mfcc_D1(:,1:end-1);diff(wave_mfcc,2,2)];
% ============================================================
         myfile=[savefilepath,'\','MFCC','\',savefileName,'_MFCC','.csv'];     
         csvwrite(myfile,wave_mfcc');
%          myfile=[savefilepath,'\','MFCC_D','\',savefileName,'_MFCC_D','.csv'];     
%          csvwrite(myfile,wave_mfcc_D1');
         clear wave_mfcc ；
         clear wave_mfcc_D1;
    end
    if operOrder(2)==1
        for z=1:frameNum
            wave_mfcc_s(:,z)=frame2mfcc_s(frameMat(:,z),speech.fs,filterNum,mfccNum);%MFCC
        end
% ========================差分MFCC============================        
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
            wave_Wmfcc(:,z)=frame2Wmfcc(frameMat(:,z),speech.fs,WavletNum,mfccNum);%小波变换MFCC
        end
        myfile=[savefilepath,'\','WMFCC','\',savefileName,'_WMFCC','.csv'];
        csvwrite(myfile,wave_Wmfcc');
        clear wave_Wmfcc;
%        MFCCfile=[savefilepath,'\',savefileName,'_WMFCC'];
%        save(MFCCfile,'wave_Wmfcc');
%        clear wave_Wmfcc;
    end
%     =============================声谱图====================================
    if operOrder(4)==1
        my_spectrogram=spectrogramByzxf( speech_clear, speech.fs, frameSize, overlap );%获取声谱图
        my_spectrogramfile=[savefilepath,'\','MySpectrogram','\',savefileName,'_spectrogram','.jpg'];
        saveas(my_spectrogram,my_spectrogramfile);
        close all hidden;clear my_spectrogram;
    end
    if operOrder(5)==1
        for z=1:frameNum
%             wave_lpcc(:,z)=frame2LPCCbyZXF(frameMat(:,z),LPCCNum,1);%LPCC
            wave_lpcc(:,z)=frame2Wmfcc2cwtBYZXF(frameMat(:,z),speech.fs,WavletNum,mfccNum);%小波变换MFCC
        end
         myfile=[savefilepath,'\','LPCC','\',savefileName,'_LPCC','.csv'];     
         csvwrite(myfile,wave_lpcc');
%          myfile=[savefilepath,'\','MFCC_D','\',savefileName,'_MFCC_D','.csv'];     
%          csvwrite(myfile,wave_mfcc_D1');
         clear wave_lpcc ；
    end
end