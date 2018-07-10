
clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

list_spec = dir('pitchCurves_excerpts_cents_spc*_NXC-Nexcerpt.mat');
Nspec=10;

maxGap_sec = .01;
minLength_sec = .01;

for nspec=1:Nspec
    load(list_spec(nspec).name)
    pitchCurve_excerpts = pitchCurves; clear pitchCurves pitchCurves_segs
    
    wsize_samples = floor(wsize_sec*fs);
    hop_samples = floor(wsize_samples * hop_pwin); 
    
    NXC=length(pitchCurve_excerpts); % number of xeno-canto recordings
    for nXC=1:NXC % Xeno-Canto file
        fprintf('\n spec %d, XC ID %d / %d',nspec,nXC,NXC)
        
        Nexcerpt=length(pitchCurve_excerpts{nXC});
        for nexcerpt=1:Nexcerpt % pitch curve of clean excerpt in the XC file
            pitchCurve = pitchCurve_excerpts{nXC}{nexcerpt};
            
%             % FREQUENCY NORMALIZATION
%             
%             % TEMPORAL NORMALIZATION
%             notNan = find(~isnan(pitchCurve));
%             dur_pc = notNan(end) - notNan(1);
%             dur_
                      
            pitchCurves_segs{nXC}{nexcerpt} = segmentPitchCurve( pitchCurve,...
                maxGap_sec,minLength_sec,hop_samples,fs );
        end
    end
    speciesFile=sprintf('pitchCurves_segments_cents_spc%02d_NXC-Nexcerpt',nspec);
    save(speciesFile,'pitchCurves','nspec','xcID','wsize_sec','ssize_sec',...
        'hop_pwin','fs','fmin_hz','fmax_hz','tooShort','-v7.3')
end