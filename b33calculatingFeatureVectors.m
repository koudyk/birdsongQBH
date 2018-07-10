clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

list_concat = dir('pitchCurves_concatenatedSegments_cents_spc*_NXC-Nexcerpt.mat');
list_segs = dir('pitchCurves_segments_cents_spc*_NXC-Nexcerpt.mat');
Nspec=10;
for nspec=1%:Nspec
    load(list_concat(nspec).name)
    load(list_segs(nspec).name)
    clear featureVectors
    NXC=length(pitchCurves_concat); % number of xeno-canto recordings
    for nXC=1%:NXC % Xeno-Canto file
        %fprintf('\n spec %d, XC ID %d / %d',nspec,nXC,NXC)
        
        Nexcerpt=length(pitchCurves_concat{nXC});
        for nexcerpt=1%:Nexcerpt % pitch curve of clean excerpt in the XC file
            pc_concat = pitchCurves_concat{nXC}{nexcerpt};
            pc_segs = pitchCurves_segs{nXC}{nexcerpt};
            [featureVectors(:,nXC) labels] = ft_allFeatures(pc_concat,pc_segs)
        end
    end
    speciesFile=sprintf('featureVectors_spc%02d_NXC-Nexcerpt',nspec);
    save(speciesFile,'featureVectors','nspec','xcID','wsize_sec','ssize_sec',...
       'hop_pwin','fs','fmin_hz','fmax_hz','tooShort','-v7.3')
end