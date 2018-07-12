clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('QUERIES_test_NspecByNrec.mat')
load('STIMULI_test_NspecByNrec.mat')


Nspec=10;
Nrec=10;
centsPerOct=1200;
fs=44100;

for nspec=1:Nspec
    fprintf('---------- spec %d -----------\n',nspec)
    for nrec=1:Nrec
        fprintf('rec %d \n',nrec)
        out=yb_yinbird(queries{nspec,nrec},fs);
        pc_q{nspec,nrec}=out.f0yinbird*centsPerOct;
        
        out=yb_yinbird(stimuli{nspec,nrec},fs);
        pc_s{nspec,nrec}=out.f0yinbird*centsPerOct;
        
    end
end

save('TEST_pitchCurves_stimuliAndQueries_Nspec-by-Nrec','pc_q','pc_s','-v7.3')