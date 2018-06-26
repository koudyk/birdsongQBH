clc,clear,close all,clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
addpath(genpath('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH'))
cd('F:\0.birdsongQBH\audio')
list_seg=dir('SEG_singlePhrase*.mat');
list_spec=dir('spc*');
Nspec=length(list_seg);
%%

for nspec=1:Nspec
    clf
    spec= list_spec(nspec).name (7:end);
    disp(['------ species ' num2str(nspec) ' - ' spec]);
    load(list_seg(nspec).name);
    temp=strsplit(list_seg(nspec).name,'_');
    fs=str2double(temp{end}(1:end-4));
    p.sr=fs;
    [r, fig] = yb_yinbird(seg,fs);
   
    %out=segmentPitchCurve(seg,fs);
    pause
    
    
    
    
    
    
end