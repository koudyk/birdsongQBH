%% 15.6.2018 using the downloadXC.m function to download the audio
% and audio metadata for the BirdsongQBH project

clc,clear,%close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

names={...
    'northern cardinal',...
    'black-capped chickadee',...
    'mourning dove',...
    'white-throated sparrow',...
    'red-eyed vireo'...
    'sora'...
    'common yellowthroat'...
    'prairie warbler'...
    };
names=sort(names);

type='song';
quality='B'; % greater than B (i.e., A)
dwnldDir=exhard;
wgetDir='C:\Users\User\Downloads';
maxNum=50;

[ recDet, recMeta ] = downloadXC( wgetDir, dwnldDir,names,type,quality,maxNum );


cd(dwnldDir)
save(['b8_output_audioData_' datestr(now,'yyyy-mm-dd')],'recDet','recMeta')