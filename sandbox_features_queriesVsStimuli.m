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
Nfeat=43;
for nspec=1:Nspec
    for nrec=1:Nrec
        disp(nrec)
        % PITCH CURVE
        out=yb_yinbird(queries{nspec,nrec},fs);
        qa=out.f0yinbird*centsPerOct;
        
        out=yb_yinbird(stimuli{nspec,nrec},fs);
        sa=out.f0yinbird*centsPerOct;
        
        % CALCULATE FEATURES
        if ~isempty(qa) && ~isempty(sa)
            qf = ft_allFeatures(qa);
            sf = ft_allFeatures(sa);
        else disp('error')
            qf = zeros(1,Nfeat);
            sf = zeros(1,Nfeat);
        end
                
        % NORMALIZE FEATURE VECTORS
        qfn = ft_normalizeFeatures(qf);
        sfn = ft_normalizeFeatures(sf);
        
        subplot(5,2,nspec)
        plot(sfn,qfn,'.'), hold on
        
%         subplot(5,2,nrec)
%         plot(1:Nfeat,sfn),hold on, plot(1:Nfeat,qfn)
%         legend('stimulus','query')
%         xlabel('features')
        
        
        
    end
end