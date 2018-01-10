function [ PowerDb, frameTime ] = WTspectrogramByzxf(frame , fs, wavename, waveNum, plotOpt)
%WTspectrogramByzxf： 将语音信号的频谱图通过小波变换的方式绘制
%   frame 输入的信号帧
%   fs 输入的信号采样率
%   wavename 小波类型
if nargin<1, selfdemo; return; end
if nargin<2, fs=16000; end
if nargin<3, wavename='cmor3-3'; end
if nargin<4, waveNum=256; end
if nargin<5, plotOpt=1; end
frameSize=length(frame);
%================尺度构建的小波时频分析=============
totalscal=waveNum; %尺度序列的长度，即scal的长度
wcf=centfrq(wavename); %小波的中心频率
cparam=2*wcf*totalscal; %为得到合适的尺度所求出的参数
a=1:totalscal;
scal=cparam./a; %得到各个尺度，以使转换得到频率序列为等差序列
Freq=scal2frq(scal,wavename,1/fs);
coefs=cwt(frame,scal,wavename);
% ================不进行尺度构建===================
% [coefs,Freq] = cwt(frame,fs,'amor');
% ================================================
% PowerDb=abs(coefs);
PowerDb=20*log(abs(coefs)+0.000000005);
frameTime=0:1/fs:(frameSize-1)/fs;
if plotOpt
    set(gcf,'Position',[20 100 600 500]);
    my_spectrogram=mesh(frameTime,Freq,PowerDb);%如果需要使用surf函数可以配合shading interp;语句消除阴影
    view(0,90);
    colormap(jet);
    axis xy;title('频谱图-小波');
    ylabel('频率/Hz');xlabel('时间/s');
end
end
% ====== Self demo
function selfdemo
waveFile='what_movies_have_you_seen_recently.wav';
[y, fs]=audioread(waveFile);
startIndex=12000;
frameSize=512;
frame=y(startIndex:startIndex+frameSize-1);wavename='cmor3-3';
WTspectrogramByzxf(frame , fs, wavename);
end

