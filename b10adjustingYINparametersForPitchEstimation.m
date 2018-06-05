clc;clear;close all,clear sound



% SELECT SPECIES
rdir='F:\0.birdsongQBH\audio'; cd(rdir)
specFiles=dir('spc*');
nspec=randi(length(specFiles),1);
nspec=7;
load('b8_output_audioData.mat','recMeta')

% SELECT AUDIO
cd([rdir '\' specFiles(nspec).name])
list=dir('*.wav');
na=randi(length(list),1);
% na=80;
file=list(na).name;
[a, fs]=audioread(list(na).name);
a=mean(a,2);

% PARAMETERS
p.wsize=round(fs*.01); % window size for pitch estimation
p.hop=round(p.wsize*.1); % hop factor for pitch estimation
fref=440; % reference frequency used by YIN to scale f0 into octaves above & below A4

% PITCH ESTIMATION
out=yinK(file,p);
f0=2.^out.f0*fref/1000;
best=2.^out.best*fref/1000;
good=2.^out.good*fref/1000;


sound(a,fs)


%%
% VISUALIZE
figure
subplot(2,1,1),spectrogram(a,p.wsize,p.hop,p.wsize,fs,'yaxis'),colorbar('off')
title(['win=' num2str(p.wsize/fs) ' sec, hop=' num2str(p.hop/fs) 'sec'])
grid on
subplot(2,1,2),plot(good,'.-'),hold on, plot(best,'.-'),xlim([0 length(best)])
grid on



%% EXTRAS
%%
% figure
% spectrogram(a,p.wsize,p.hop,p.wsize,fs,'yaxis'),colorbar('off')
% title(['win=' num2str(p.wsize/fs) ' sec, hop=' num2str(p.hop/fs) 'sec'])
% hold on, plot(best,'.-'),xlim([0 length(best)])
% grid on


%% POST PROCESSING

% w=1; wsec=w*p.hop/fs; % window size for post-processing removal of aperiodic sound
% h=1; hsec=h*p.hop/fs; % hop size for post-processing noise of aperiodic sound
% Tpow=.0001; % power threshold

% clc,clear sound
% temp=zeros(1,length(out.f0));
% c=0;
% figs=0;
% for nwin=1:length(out.f0)/h-ceil(w/h)
%     win=out.pwr(c*h+1:c*h+w);
%     if figs==1; clf,plot(win),hold on, plot(1,Tpow,'*'),ylim([0 max(out.pwr)]),title(num2str(nwin)),end
%     if max(win)>Tpow
%         temp(c*h+1:c*h+w)=ones;
%     end    
%     c=c+1;
%     if figs==1; pause(.01), end
%         
% end
% f0=out.f0.*temp;
% %f0=out.f0 .* (out.pwr>Tpow); % mask out locations in the pitch curve where there is low periodicity
% f0(f0==0)=NaN;






