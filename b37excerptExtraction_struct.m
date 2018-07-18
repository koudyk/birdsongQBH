

clc,clear,%close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

cd(fullfile(exhard,'excerptAnnotations'))
list_anno_total=dir('spc*.txt');
Nanno=length(list_anno_total);
minLen = 882;

for nspec=10
    disp(sprintf('-------------- spc %d --------------',nspec))
    clear excerpts
    list_anno=dir(sprintf('spc%02d*.txt',nspec));
    
    NxcID = length(list_anno);
    ne=0;
    for nxcID=1:NxcID
        disp(nxcID)
        [x,fs]=audioread([list_anno(nxcID).name(1:end-4) '.wav']);
        x=mean(x,2);
        
        % normalize volume
        x_centered = x - mean(x);
        power = norm(x_centered) / length(x_centered);
        x_normalized = x_centered / power;

        [segs, locs] = extractAudioExcerpts(x,list_anno(nxcID).name,0,fs);
        Nexcerpt = length(segs);
        for nexcerpt = 1:Nexcerpt
            excerpt=segs{nexcerpt};
            if length(excerpt) > minLen
                ne=ne+1;
                excerpts(ne).species = nspec;
                excerpts(ne).xcID = str2double(list_anno(nxcID).name(9:end-4));
                excerpts(ne).xcIDNum = nxcID;
                excerpts(ne).excerptNum = nexcerpt;
                excerpts(ne).begEnd_frames = locs(nexcerpt,:);
                excerpts(ne).audio = segs{nexcerpt};
            end
      
        end
    end
     file=sprintf('excerpts_audioExcerpts_species%02d',nspec);
     save(file,'excerpts','fs','-v7.3')
end