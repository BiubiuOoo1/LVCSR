function [ sigden ] = DeNoiseByZXF( sig,wname,N,plotOpt )
%DeNoiseByZXF ����С����ֵ����������ȥ��
%   x �����һά�����ź�
%   wname ���õ�С������ ��Ҫע����ǲ���SWT��ʽʱʹ����������˫������С������
%   N С���ֽ����
if nargin<1, selfdemo; return; end
if nargin<2, wname='db5'; end
if nargin<3, N=8; end
if nargin<4, plotOpt=1; end
% coeff=20;
% coeff2=0.5;
sorh='h';
if size(sig,1)>1,sig=sig'; end
[coefs,longs]=wavedec(sig,N,wname);% ԭʼ�ź�С���ּ�
thrParams=utthrset_cmd(coefs,longs);%�Զ�����ÿ��С����ȥ��ʱ�ļ��
% X=wrepcoef(C,longs);% ��С��ϵ�����зּ��ع�,��������Ƶ�ʽ���Dn~D1
% =============================
first = cumsum(longs)+1;
first = first(end-2:-1:1);
tmp   = longs(end-1:-1:2);
longsast  = first+tmp-1;
for k = 1:N
    thr_par = thrParams{k};
    if ~isempty(thr_par)
        cfs = coefs(first(k):longsast(k));%�ҳ�ÿһ��С��ϵ����Ӧ�ĵ���
        nbCFS = longs(end-k);
        NB_int = size(thr_par,1);
        x = [thr_par(:,1) ; thr_par(NB_int,2)];
        alongsf = (nbCFS-1)/(x(end)-x(1));
        bet = 1 - alongsf*x(1);
        x = round(alongsf*x+bet);%��ÿһ���Ӧ�ļ�ϵ�ֵӳ���ڵ�����
        x(x<1) = 1;
        x(x>nbCFS) = nbCFS;
        thr = thr_par(:,3);
        for j = 1:NB_int
            if j == 1
                d_beg = 0;
            else
                d_beg = 1;
            end
            j_beg = x(j)+ d_beg;
            j_end = x(j+1);
            j_ind = (j_beg:j_end);
            cfs2=cfs(j_ind);
            %�����ź��Ƿ�����̬�ֲ���
%             sigma=median(abs(cfs2))./0.6745;%����Donoho �����³������ֵ���ƣ����Ʋ�ͬ�����ع��źŵ�������׼��
%             sigmaY2=sum(power(cfs2-mean(cfs2),2))./length(cfs2);%���������Ȼ���Ʒ��õ��ź����巽��
%             sigmacfs=power(max(sigmaY2-power(sigma,2),0),0.5);%�ź��������ź���С��ϵ����Э����Ϊ��
%             thr=power(sigma,2)./sigmacfs;% ��Ҷ˹��ֵ
%             cfs3=sign(cfs2).*(cfs2-thr/(1+coeff).*power(coeff2,power(power(cfs2,2)-power(thr,2),0.5)));%coeff�ǿɵ�ϵ��,coeff2����0��1
%             cfs4=sign(cfs2).*exp(10.*(abs(cfs2)-thr)).*abs(thr);
%             cfs(j_ind)=cfs3.*(abs(cfs2)>thr)+cfs4.*(abs(cfs2)<=thr);
            cfs(j_ind) = wthresh(cfs(j_ind),sorh,thr(j));
        end
        coefs(first(k):longsast(k)) = cfs;
    end
end
cfs_beg = wrepcoef(coefs,longs);%�ع�С��ϵ��
sigden = waverec(coefs,longs,wname);
if plotOpt
    figure(1);
    subplot(N+1,1,1);
    plot(sig,'r');
    axis tight
    title('ԭʼ���κ��˲�����С��ϸ��');
    ylabel('S','Rotation',0);
    for k = 1:N
    subplot(N+1,1,k+1); plot(cfs_beg(k,:),'Color',[0.5 0.8 0.5]);
    ylabel(['D' int2str(k)],'Rotation',0);
    axis tight
    hold on
    maxi = max(abs(cfs_beg(k,:)));
    hold on
    par = thrParams{k};
    plotPar = {'Color','m','LineStyle','-.'};
    for j = 1:size(par,1)-1
        plot([par(j,2),par(j,2)],[-maxi maxi],plotPar{:});
    end
    for j = 1:size(par,1)
        plot([par(j,1),par(j,2)],[par(j,3) par(j,3)],plotPar{:});
        plot([par(j,1),par(j,2)],-[par(j,3) par(j,3)],plotPar{:});
    end
    ylim([-maxi*1.05 maxi*1.05]);
    end
    subplot(N+1,1,N+1);
    xlabel('ʱ��');
    figure(2);
    res = sig - sigden;
    subplot(3,1,1);
    plot(sig,'r');
    hold on
    plot(sigden,'b');
    axis tight
    title('ԭʼ�źź�ȥ���ź�');
    subplot(3,1,2);
    plot(sigden,'b');
    axis tight
    title('ȥ���ź�');
    subplot(3,1,3);
    plot(res,'k');
    axis tight
    title('ȥ���������ź�');
end

% n=find(~sigmaX);
% T(n)=max(max(X));
%С����ֵ����ʵ��
end
function selfdemo
load nelec.mat;
sig = nelec;
wname = 'sym4';
level = 6;
DeNoiseByZXF( sig,wname,level );
end
