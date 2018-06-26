% script for impleme

clc,clear,close all,clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
addpath(genpath('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH'))
cd('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH')

list_a=dir('short*.wav'); % short audio files 
wsizes=[.005 .01 .025];

nplot=0;
figure
quality=0;
ssize_minf0=.1;
minf_hz=200;
maxf_hz=8000;
hop_pwsize=.5;

for nwsize=1:length(wsizes)
    for na=1:length(list_a)
        
        wsize=wsizes(nwsize);
        [~,fs]=audioread(list_a(na).name);
        p.minf0=0;
        
        nplot=nplot+1;
        subplot(length(list_a),length(wsizes),nplot),
        [r,fig]=yb_yinbird(list_a(na).name,fs,p,ssize_minf0,minf_hz,maxf_hz,wsize,hop_pwsize);
        title(['wsize=' num2str(wsize)])
        if nwsize==1, title({list_a(na).name(7:end-4),['wsize=' num2str(wsize)]}), end
        
    end
end
