
clc;clear;close all; clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

cd(exhard)
list_spec=dir('spc_*'); % list of species folders

for nspec=1:length(list_spec)
    folder_spec=fullfile(exhard,list_spec(nspec).name);
    cd(folder_spec)
    list_audio=dir('*.wav'); % list of audio 
    list_anno=dir('p*.txt'); % list of annotations 
    
    for naud=1:length(list_audio)
        id=list_audio(naud).name(1:end-4);
        anno=['p' id '.txt'];
        
        if exist(anno)==2 % if the annotation exists in the path
            if isempty(strfind([list_anno.name],anno)) % and if it's not in the right folder
                source=which(anno);
                movefile(source,folder_spec)     
            end
        end
    end
    
    
end
