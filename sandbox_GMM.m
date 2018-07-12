clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('featureVectors_allSpecies_Nfeatures_by_Nxc.mat');

k=7;
GMModel=fitgmdist(features_allspec',k,'RegularizationValue',0.1);