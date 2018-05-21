clc;clear;close all
cd('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH')
list=dir('f0*.wav');

fs=8000;
for n=1:length(list)
    a(n).name=list(n).name(9:end-3);
    [a(n).a fs]=audioread(list(n).name);
end



wlen=(fs/50);
hop=wlen/2;

for nc=1:length(list)
    aa=a(nc).a;
    
    for w=1:(length(aa)-2*wlen)/hop;
        % select window
        wbeg=floor(w-1)*hop+1;
        win1=aa(wbeg:wbeg+wlen);
        %win2=aa(wbeg+wlen:wbeg+2*wlen);
        % autocorrelation
        [x(w) lags(w)]=xcorr(win1,win2);
        
        
    end
end
    


