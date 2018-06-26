clc;clear;%close all; clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
exhard_x2='F:\0.birdsongQBH\x2_audio';
addpath(genpath(exhard))
addpath(genpath(exhard_x2))
addpath(genpath(laptop))

cd(exhard_x2)
list_spec=dir('spc*');
Nspec=length(list_spec);
ncol = 2; % number of columns in figure
quality = 1;
figure
for nspec=1%:Nspec
    folder=list_spec(nspec).name;
    cd(fullfile(exhard_x2,folder))
    list_audioSeg=dir('sp*');
    spec=folder(5:end);
    
    for naudio=1%:length(list_audioSeg)
        file = list_audioSeg(naudio).name;
        load(file); a=seg;
        temp = strsplit(file,'_');
        fs = str2double( temp{3}(1:end-4) );
        id = str2double( temp{1}(3:end) );
        
        %subplot(ceil(Nspec/ncol),ncol,nspec)
        [~,~,fig]=yb_yinbird(a,fs,quality);
        title(spec)
        
                
    end
    
    
    
end
