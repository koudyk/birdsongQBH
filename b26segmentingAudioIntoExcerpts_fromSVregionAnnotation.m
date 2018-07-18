

clc,clear,%close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

cd(exhard)
list_anno=dir('spc*.txt');
Nanno=length(list_anno);


for nspec=1:10
    disp(sprintf('-------------- spc %d --------------',nspec))
    clear xcID audio_segs audio_excerpts
    list_anno=dir(sprintf('spc%02d*.txt',nspec));
    for nanno=1:length(list_anno)
        disp(nanno)
        [x,fs]=audioread([list_anno(nanno).name(1:end-4) '.wav']);
        x=mean(x,2);
        
        % normalize volume
        x_centered = x - mean(x);
        power = norm(x_centered) / length(x_centered);
        x_normalized = x_centered / power;
        
        audio_excerpts{nanno}=segmentAudio(x,list_anno(nanno).name,0,fs);
        xcID(nanno)=str2double(list_anno(nanno).name(9:end-4));
    end
     file=sprintf('audio_cleanExcerpts_spc%02d',nspec);
     save(file,'audio_excerpts','xcID','-v7.3')
    
    
end