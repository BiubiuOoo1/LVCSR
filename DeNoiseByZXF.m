function [ sigden ] = DeNoiseByZXF( sig,wname,N,plotOpt )
%DeNoiseByZXF 利用小波阈值来进行语音去噪
%   x 输入的一维语音信号
%   wname 采用的小波类型 需要注意的是采用SWT方式时使用正交或者双正交的小波类型
%   N 小波分解层数
if nargin<1, selfdemo; return; end
if nargin<2, wname='db5'; end
if nargin<3, N=8; end
if nargin<4, plotOpt=1; end
% coeff=20;
% coeff2=0.5;
sorh='h';
if size(sig,1)>1,sig=sig'; end
[coefs,longs]=wavedec(sig,N,wname);% 原始信号小波分级
thrParams=utthrset_cmd(coefs,longs);%自动计算每个小波层去噪时的间隔
% X=wrepcoef(C,longs);% 对小波系数进行分级重构,从上至下频率降低Dn~D1
% =============================
first = cumsum(longs)+1;
first = first(end-2:-1:1);
tmp   = longs(end-1:-1:2);
longsast  = first+tmp-1;
for k = 1:N
    thr_par = thrParams{k};
    if ~isempty(thr_par)
        cfs = coefs(first(k):longsast(k));%找出每一层小波系数对应的点数
        nbCFS = longs(end-k);
        NB_int = size(thr_par,1);
        x = [thr_par(:,1) ; thr_par(NB_int,2)];
        alongsf = (nbCFS-1)/(x(end)-x(1));
        bet = 1 - alongsf*x(1);
        x = round(alongsf*x+bet);%将每一层对应的间断点值映射在点数上
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
            %假设信号是服从正态分布的
%             sigma=median(abs(cfs2))./0.6745;%利用Donoho 提出的鲁邦性中值估计，估计不同级数重构信号的噪声标准差
%             sigmaY2=sum(power(cfs2-mean(cfs2),2))./length(cfs2);%利用最大似然估计法得到信号总体方差
%             sigmacfs=power(max(sigmaY2-power(sigma,2),0),0.5);%信号与噪声信号在小波系数中协方差为零
%             thr=power(sigma,2)./sigmacfs;% 贝叶斯阈值
%             cfs3=sign(cfs2).*(cfs2-thr/(1+coeff).*power(coeff2,power(power(cfs2,2)-power(thr,2),0.5)));%coeff是可调系数,coeff2属于0到1
%             cfs4=sign(cfs2).*exp(10.*(abs(cfs2)-thr)).*abs(thr);
%             cfs(j_ind)=cfs3.*(abs(cfs2)>thr)+cfs4.*(abs(cfs2)<=thr);
            cfs(j_ind) = wthresh(cfs(j_ind),sorh,thr(j));
        end
        coefs(first(k):longsast(k)) = cfs;
    end
end
cfs_beg = wrepcoef(coefs,longs);%重构小波系数
sigden = waverec(coefs,longs,wname);
if plotOpt
    figure(1);
    subplot(N+1,1,1);
    plot(sig,'r');
    axis tight
    title('原始波形和滤波后多层小波细节');
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
    xlabel('时空');
    figure(2);
    res = sig - sigden;
    subplot(3,1,1);
    plot(sig,'r');
    hold on
    plot(sigden,'b');
    axis tight
    title('原始信号和去噪信号');
    subplot(3,1,2);
    plot(sigden,'b');
    axis tight
    title('去噪信号');
    subplot(3,1,3);
    plot(res,'k');
    axis tight
    title('去除的噪声信号');
end

% n=find(~sigmaX);
% T(n)=max(max(X));
%小波阈值函数实现
end
function selfdemo
load nelec.mat;
sig = nelec;
wname = 'sym4';
level = 6;
DeNoiseByZXF( sig,wname,level );
end
