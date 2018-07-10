% concatenating pitch curve segments (i.e., getting rid of NaNs)

clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

list_spec = dir('pitchCurves_excerpts_cents_spc*_NXC-Nexcerpt.mat');
Nspec=10;

for nspec=1:Nspec
    load(list_spec(nspec).name)
    clear pitchCurves_concat
    NXC=length(pitchCurves); % number of xeno-canto recordings
    for nXC=1:NXC % Xeno-Canto file
        fprintf('\n spec %d, XC ID %d / %d',nspec,nXC,NXC)
        
        Nexcerpt=length(pitchCurves{nXC});
        for nexcerpt=1:Nexcerpt % pitch curve of clean excerpt in the XC file
            excerpt = pitchCurves{nXC}{nexcerpt};
            excerpt(isnan(excerpt))=[];
            pitchCurves_concat{nXC}{nexcerpt}=excerpt;
        end
    end
    speciesFile=sprintf('pitchCurves_concatenatedSegments_cents_spc%02d_NXC-Nexcerpt',nspec);
    save(speciesFile,'pitchCurves_concat','nspec','xcID','wsize_sec','ssize_sec',...
        'hop_pwin','fs','fmin_hz','fmax_hz','tooShort','-v7.3')
end