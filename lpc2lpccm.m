function lpcc=lpc2lpccm(ar,n_lpc,n_lpcc)
lpcc=zeros(n_lpcc,1);
lpcc(1)=ar(1);
for n=2:n_lpc
    lpcc(n)=ar(n);
    for k=1:n-1
        lpcc(n)=lpcc(n)+ar(k)*lpcc(n-k)*(n-k)/n;
    end
end

for n=n_lpc+1:n_lpcc
    lpcc(n)=0;
    for k=1:n_lpc
        lpcc(n)=lpcc(n)+ar(k)*lpcc(n-k)*(n-k)/n;
    end
end
lpcc=-lpcc;
    