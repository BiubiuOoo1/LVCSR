function lpcc = frame2LPCCbyZXF( frame,LPCCNum,lpcname,plotOpt )
%	����������ȡһ֡������LPCC(����Ԥ�⵹��)
%   frameΪ����������һ֡����
%   LPCCNumΪ����LPCC����
%   lpcnameѡ��ͬ�㷨
%   plotOpt�Ƿ��ӡͼ��
%	For example:
%		waveFile='what_movies_have_you_seen_recently.wav';
%		[y, fs, nbits]=wavReadInt(waveFile);
% %		startIndex=12000;
%		frameSize=512;
%		frame=y;
%		frame2Wmfcc(frame, fs, 25, 13, 1);

%	Zhao 20170927
if nargin<1, selfdemo; return; end
if nargin<2, LPCCNum=12; end
if nargin<3, lpcname=1; end
if nargin<4, plotOpt=1; end

if size(frame,1)<2, frame=frame'; end
switch lpcname
    case 1
        ar=lpc_coefficientm(frame,LPCCNum);%����ط���lpc
        ar=-ar';
    case 2
        ar=arcov(frame,LPCCNum);%Э�����lpc
        ar=ar(2:end);
    case 3
        [~,ar]=latticem(frame,length(frame)-LPCCNum,LPCCNum);%���ͷ���lpc 
        ar=ar(:,LPCCNum);
end
lpcc=lpc2lpccm([1,ar],LPCCNum,LPCCNum+1);
lpcc=lpcc(2:end);
if plotOpt
    nfft=512;m=1:nfft/2+1;Y=fft(frame,nfft);W2=nfft/2;
    Y1=lpcar2ff([1,ar],W2-1); 
    subplot(211);plot(frame,'k');
    title('һ֡�����źŵĲ���');ylabel('��ֵ');xlabel('(a)');
    subplot(212);
    plot(m,20*log10(abs(Y(m))),'k','LineWidth',1.5);
    line(m,20*log10(abs(Y1)),'color',[.6 .6 .6],'linewidth',2)
    %axis([0 W2+1 -50 25]);
    ylabel('��ֵ/db');
    legend('FFTƵ��','LPC��'); xlabel(['����' 10 '(b)'])
    title('FFTƵ�׺�LPC�׵ıȽ�');
end
function selfdemo
waveFile='what_movies_have_you_seen_recently.wav';
[y, fs]=audioread(waveFile);
startIndex=12000;
frameSize=512;
frame=y(startIndex:startIndex+frameSize-1);
feval(mfilename, frame, 12, 2, 1);

