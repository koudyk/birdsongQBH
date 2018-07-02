% clc;clear;close all
% 
% list=dir('spc4*');
% na=3;
% [a,fs]=audioread(list(na).name);
% a=mean(a,2);
% p.sr=fs;

%%
clc,clear,close all,clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
addpath(genpath('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH'))
cd('F:\0.birdsongQBH\x2_audio\spc_black-capped_chickadee')
list=dir('sp*.mat');
randomAudio=randperm(length(list));

for n=1%:length(list)
    na=randomAudio(n);
    %na=130;
    %na=11;
    na=62;
    disp(['-------------------loading ' num2str(na)])
    load(list(na).name); 
    a=seg; clear seg
    %[a fs]=audioread('10169.wav');
    temp=strsplit(list(na).name,'_');
    fs=str2num(temp{3}(1:end-4));
    p.sr=fs;
    
    disp(['showing ' num2str(na)])
    clf
    [r, fig]=yb_yinbird(a,fs,p);
    %r=yin_k(a,p);
    f0_yin=r.f0;
    f0_yin=2.^f0_yin .*440;
    hold on, plot(r.timescale,f0_yin,'k')
    
    f0_shifted=[0 f0_yin(1:end-1)];
    change=(abs(f0_yin-f0_shifted));
    change=(log2(change));%zscore(change)+ abs(min(zscore(change)));
    %change=change*.01;
    change(isnan(change))=0;
    %change=change/max(change);
    
    %change=zscore(change)+ abs(min(zscore(change)));
    %figure,plot(change)
    
    
    
    
    ap0=(r.ap0);
    ap0=ap0/range(ap0);
    pwr=(r.pwr);
    pwr=pwr/range(pwr);
    %pwr=1-pwr;
    %pwr=max(pwr)-pwr;
    
    Aap0=1;
    Apwr=1;
    Achange=.0001;
    
    x = (Aap0 * ap0) .* ...
        (Apwr * (1-pwr));% +...
        %(Achange * change);
    %x=x/range(x);
    
    best=f0_yin;
    best(find(x    >       .4         ))=nan;
    hold on, plot(r.timescale,best,'k','linewidth',5)
    
    
    figure,plot(x)
    hold on, plot(ap0)
    hold on, plot(1-pwr)
    %hold on, plot(change)
    hold on, plot(best>0,'*')
    legend('mix','aperiodicity','1-power','change','pitch curve')
    
    %figure
    %histogram(change)
    
    
    %change=zscore(change);
    %change=change+abs(min(change));
    %figure
    %plot(change), hold on
    %findpeaks(change(change>nanmean(change)));
    
    
    %figure,findchangepts(sort(change),'statistic','linear')
    ap0=(r.ap0);
    p0=max(ap0)-ap0;
    
    %pwr=
    
    
    
    
    %hold on, plot(x+5000)
    
    title(na)
    %pause(2)
end


%%
% thresh_ap=.2;
% best=r.f0;
% best(find(r.f0>thresh_ap))=nan;
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% f0=r.f0;
% %f0(isnan(f0))=0;
% %f0=zscore(f0);
% 
% pwr=r.pwr;
% %pwr(isnan(pwr))=0;
% pwr=sqrt(pwr);
% %pwr=zscore(pwr);
% 
% ap0=r.ap0;
% %ap0(isnan(ap0))=0;
% ap0=sqrt(ap0);
% %ap0=zscore(ap0);
% 
% f0_shifted=[0 f0(1:end-1)];
% change=(abs(f0-f0_shifted));
% 
% best=f0;
% best(find(r.ap0>.2))=nan;
% 
% figure
% subplot(3,1,1)
% plot(r.f0), hold on
% plot(r.best)
% 
% subplot(3,1,2)
% plot(r.f0),hold on
% plot(best)
% 
% subplot(3,1,3)
% plot(r.best,'linewidth',3)
% hold on, 
% plot(best)




