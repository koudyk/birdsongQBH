clc,clear,close all,clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
addpath(genpath('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH'))
cd('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH')

list_a=dir('short*.wav'); % short audio files 

na=2;
[a,fs]=audioread(list_a(na).name);
r = yb_segmentSyllables(a,fs);