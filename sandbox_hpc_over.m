clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)


% PITCH CURVE PARAMETERS

par.fs=44100;
par.wsize_sec = .02; 
par.hop_pwin = .1; % (proportion of the window size)
par.aperThresh = .2; 
par.ssize_sec = .068; % size of the segments in which to calculate the minimum frequency for YIN
par.fmin_hz = 30;
par.fmax_hz = 10000;

% FEATURE PARAMETERS
par.vsize_sec = .35; % window size for calculating vibrato
par.vminf_hz = 3;
par.vmaxf_hz = 15;

saveOn = 1;

list_excerptSpc=dir('excerpts_audioExcerpts_species*'); % audio waveform excerpts
list_queryPtp=dir('queries_audio*queries_ptp*');
[rank] = over_compareFVs(list_excerptSpc,list_queryPtp,par,saveOn);

% [FV_e , info_e] = over_excerptsFV(list_excerpts,par,saveOn);
% fileName = 'overAll_excerpts_featureVectors_allSpc';
% save(fileName,'FV_e','info_e','-v7.3')
% 

% [FV_q , info_q] = over_queriesFV(list_queries,par,saveOn);
% fileName = 'overAll_queries_featureVectors_allPtp';
% save(fileName,'FV_q','info_q','-v7.3')