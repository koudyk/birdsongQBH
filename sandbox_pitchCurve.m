%clc,clear,close all,clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
addpath(genpath('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH'))
cd('F:\0.birdsongQBH\audio')
list_seg=dir('SEG_short_*.mat');
list_spec=dir('spc*');
Nspec=length(list_seg);
%Nspec =4 ;
Ncol=2;
Nrow=ceil(Nspec/Ncol);
figure
for nspec=Nspec
    clf
    
    %subplot(Nrow,Ncol,nspec)
    spec= list_spec(nspec).name (6:end);
    disp(['------ species ' num2str(nspec) ' - ' spec]);
    load(list_seg(nspec).name);
    temp=strsplit(list_seg(nspec).name,'_');
    fs=str2double(temp{end}(1:end-4));
    p.sr=fs;
    
    
    
    [ryb,fig]= yb_yinbirdVsYin(seg,fs);
    pause
    
end
    


