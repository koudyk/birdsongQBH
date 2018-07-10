%clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

list_spec = dir('pitchCurves_spc*_NXC-Nexcerpt.mat');
fref=440;
centsPerOctave = 1200;
Nspec = 10;

for nspec=1:Nspec
    load(list_spec(nspec).name)
    
    NXC = length(pitchCurves);
    for nXC = 1:NXC
        fprintf('\n spec %d, XC ID %d / %d',nspec,nXC,NXC)
        
        Nexcerpt=length(pitchCurves{nXC});
        for nexcerpt=1%:Nexcerpt % pitch curve of clean excerpt in the XC file
            pitchCurve_hz = pitchCurves{nspec}{nexcerpt};
            %pitchCurve_octaves = (log2(pitchCurve_hz/fref));
            pitchCurve_cents = (log2(pitchCurve_hz/fref))*centsPerOctave;
        end
    end
    
    speciesFile=sprintf('pitchCurves_cents_spc%02d_NXC-Nexcerpt',nspec);
    save(speciesFile,'pitchCurves','nspec','xcID','wsize_sec','ssize_sec',...
        'hop_pwin','fs','fmin_hz','fmax_hz','tooShort','-v7.3')
end
% figure
% subplot(3,1,1),plot(pitchCurve_hz)
% subplot(3,1,2),plot(pitchCurve_octaves)
% subplot(3,1,3),plot(pitchCurve_cents)