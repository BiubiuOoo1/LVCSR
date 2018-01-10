function [ PowerDb, frameTime ] = WTspectrogramByzxf(frame , fs, wavename, waveNum, plotOpt)
%WTspectrogramByzxf�� �������źŵ�Ƶ��ͼͨ��С���任�ķ�ʽ����
%   frame ������ź�֡
%   fs ������źŲ�����
%   wavename С������
if nargin<1, selfdemo; return; end
if nargin<2, fs=16000; end
if nargin<3, wavename='cmor3-3'; end
if nargin<4, waveNum=256; end
if nargin<5, plotOpt=1; end
frameSize=length(frame);
%================�߶ȹ�����С��ʱƵ����=============
totalscal=waveNum; %�߶����еĳ��ȣ���scal�ĳ���
wcf=centfrq(wavename); %С��������Ƶ��
cparam=2*wcf*totalscal; %Ϊ�õ����ʵĳ߶�������Ĳ���
a=1:totalscal;
scal=cparam./a; %�õ������߶ȣ���ʹת���õ�Ƶ������Ϊ�Ȳ�����
Freq=scal2frq(scal,wavename,1/fs);
coefs=cwt(frame,scal,wavename);
% ================�����г߶ȹ���===================
% [coefs,Freq] = cwt(frame,fs,'amor');
% ================================================
% PowerDb=abs(coefs);
PowerDb=20*log(abs(coefs)+0.000000005);
frameTime=0:1/fs:(frameSize-1)/fs;
if plotOpt
    set(gcf,'Position',[20 100 600 500]);
    my_spectrogram=mesh(frameTime,Freq,PowerDb);%�����Ҫʹ��surf�����������shading interp;���������Ӱ
    view(0,90);
    colormap(jet);
    axis xy;title('Ƶ��ͼ-С��');
    ylabel('Ƶ��/Hz');xlabel('ʱ��/s');
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

