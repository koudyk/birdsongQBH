clc,clear,%close all,clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
addpath(genpath('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH'))
cd('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH')

list_a=dir('short*.wav'); % short audio files 
for na=3%
[a,fs]=audioread(list_a(na).name);
p.minf0=0;
figure
[~,~,fig]=yb_yinbird(list_a(na).name,fs,2,p,.068,400,8000,.01,.5);


% [P,F,T]=yb_spectrogram(audio);
% minf0_hop = yb_minf0(audio);
% [F0,T2] = yb_yinbird(audio);
% 
% % visualize
% figure,yb_spectrogram_fig(P,F,T); % spectrogram
% hold on, plot(T,minf0_hop)
% hold on, plot(T,F0,'linewidth',2)
end
