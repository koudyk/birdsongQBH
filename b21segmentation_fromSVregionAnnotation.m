% % 18.6.2018 testing segmentAudio
% 
clc;clear;close all; clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard_x2='F:\0.birdsongQBH\x2_audio'; %external harddrive
addpath(genpath(exhard_x2))
addpath(genpath(laptop))


cd(exhard_x2)
list_spec=dir('spc*'); % list of species folders

for nspec=1:length(list_spec)
    cd(fullfile(exhard_x2,list_spec(nspec).name))
    list_anno=dir('p*.txt'); % list of annotations 
    
    for nanno=1:length(list_anno)
        [audio, fs]=audioread([list_anno(nanno).name(2:end-4) '.wav']);
        segs{nspec,nanno}=segmentAudio(audio,list_anno(nanno).name,1,fs);
        
% METADATA
        Lseg(nanno) = length(cell2mat(segs{nspec,nanno}));
        Nseg(nanno) = length(segs{nspec,nanno});      
    end
    meta(nspec).spec=list_spec(nspec).name(5:end);
    meta(nspec).nPhrase=sum(Nseg);
    meta(nspec).time_sec=sum(Lseg/fs);

end

%% VISUALIZE
% clc,close all
% nanno=1;
% 
% Ncol=2;
% 
% for nspec=1:8
%     Nseg=length(segs{nspec,nanno});
%     figure
%     for nseg=1:Nseg
%         a=segs{nspec,nanno}{nseg};
%         subplot(ceil(Nseg/Ncol),Ncol,nseg)
%         [~,~,fig]=yb_yinbird(a,fs);
%         if nseg==1, title(list_spec(nspec).name(5:end-4)),end
%     end
% end
    