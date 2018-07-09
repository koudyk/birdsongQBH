clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

list_spec = dir('pitchCurves_concatenatedSegments*');
Nspec = 10;
hop = 82;
fs = 44100;
fsize_sec = 1; 
hop_pframe = .1;


for nspec=6%:Nspec
    load(list_spec(nspec).name)
    
    NXC=length(pitchCurves_concat); % number of xeno-canto recordings
    for nXC=1%:NXC % Xeno-Canto file
        fprintf('\n spec %d, XC ID %d / %d\n',nspec,nXC,NXC)
        
        Nexcerpt=length(pitchCurves_concat{nXC});
        for nexcerpt=1%:Nexcerpt % pitch curve of clean excerpt in the XC file
            
            Nsegment=length(pitchCurves_concat{nXC}{nexcerpt});
            for nsegment = 1%:Nsegment
                
                pitchCurve = pitchCurves_concat{nXC}{nexcerpt};
                
                fv = ft_vibrato(pitchCurve,0,hop,fs,fsize_sec,hop_pframe);
                
            end
        end
    end
%     speciesFile=sprintf('pitchCurves_segments_cents_spc%02d_NXC-Nexcerpt',nspec);
%     save(speciesFile,'pitchCurves','nspec','xcID','wsize_sec','ssize_sec',...
%         'hop_pwin','fs','fmin_hz','fmax_hz','tooShort','-v7.3')
end