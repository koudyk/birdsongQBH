clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('PITCHCURVES_test_stimuliAndQueries.mat')

nspec=1;
nrec=1;

f0=f0_s{nspec,nrec};