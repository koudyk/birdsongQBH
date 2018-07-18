
clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)


% PITCH CURVE PARAMETERS
list_excerpts=dir('excerpts_audioExcerpts_species*'); % audio waveform excerpts
par.fs=44100;
par.wsize_sec = .02; 
par.hop_pwin = .1; % (proportion of the window size)
par.aperThresh = .2; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
par.ssize_sec = .068; % size of the segments in which to calculate the minimum frequency for YIN
par.fmin_hz = 30;
par.fmax_hz = 10000;

% FEATURE PARAMETERS
par.vsize_sec = .35; % window size for calculating vibrato
par.vminf_hz = 3;
par.vmaxf_hz = 15;


centsPerOctave = 1200;
Nspec=10;
Nfeat=43;
% PITCH CURVE 
for nspec=1:Nspec
    disp('---------------------------------------')
    load(list_excerpts(nspec).name); % excerpts
    toDelete=[];
    Nexcerpt = length(excerpts); % number of Xeno-Canto IDs
    for nexcerpt = 1:Nexcerpt
        fprintf('\n spc %02d, excerpt %d / %d',nspec,nexcerpt,Nexcerpt)
        e = excerpts(nexcerpt).audio;
        pc = yb_yinbird(e,par) * centsPerOctave;
        if sum(~isnan(pc)) > 0 % if no pitch curve is exctracted
            excerpts(nexcerpt).pitchCurve_cents = pc;
        else toDelete = [toDelete nexcerpt];
        end
    end
    excerpts(toDelete)=[];
    fileName = sprintf('excerpts_pitchCurves_species%02d',nspec);
    save(fileName,'excerpts','par','-v7.3')
end
     
% FEATURES
list_pitchCurve = dir('excerpts_pitchCurves_species*');
for nspec=1:Nspec
    disp('---------------------------------------')
    load(list_pitchCurve(nspec).name); % excerpts
    Nexcerpt = length(excerpts); % number of Xeno-Canto IDs
    for nexcerpt = 1:Nexcerpt
        fprintf('\n spc %02d, excerpt %d / %d',nspec,nexcerpt,Nexcerpt)
        pc = excerpts(nexcerpt).pitchCurve_cents;
        excerpts(nexcerpt).featureVector = ft_allFeatures(pc,par);
    end
    fileName = sprintf('excerpts_featureVector_species%02d',nspec);
    save(fileName,'excerpts','par','-v7.3')
end

% NORMALIZATION PARAMETERS FEATURES

list_featureVector = dir('excerpts_featureVector_species*');
allFVs = []; % feature vectors from all species
allXCs = [];
for nspec=1:Nspec
    disp('---------------------------------------')
    load(list_featureVector(nspec).name); % excerpts
    Nexcerpt = length(excerpts);
    allFVs = [allFVs reshape([excerpts.featureVector],[Nfeat, Nexcerpt])];
    allXCs = [allXCs [excerpts.xcID]];
end
fileName = 'excerpts_featureVectors_allSpecies';
save(fileName,'allFVs','allXCs','par','-v7.3')

clc
load 'excerpts_featureVectors_allSpecies';
Nexcerpt=length(allFVs);
needNormalize = 1:19; % features that need normalizing
needNotNormalize = 20:43; % features that don't need normalizing 
     % (they are by definition between 0-1 or they are a boolean)

min_feat(needNormalize) = min(allFVs(needNormalize,:)'); 
range_feat(needNormalize) = range(allFVs(needNormalize,:)'); 
min_feat(needNotNormalize) = 0;
range_feat(needNotNormalize)= 1;


save('featureScalingParameters','min_feat','range_feat','-v7.3')

allFVs_01 = ft_scale01(allFVs, min_feat', range_feat');
save('excerpts_featureVectors_allSpecies_scaled','allFVs','allFVs_01','allXCs','-v7.3')

% QUERY PITCH CURVE 

load('QUERIES_ptp000_2018-07-13-15-45-00.mat')
Nquery = 100;
qFVs = [];
qXCs = [];
for nquery=1:Nquery
    disp(nquery)
    a = queries(nquery).query;
    pcYB = yb_yinbird(a,par);
   
    fv = ft_allFeatures(pcYB,par);
    
    
    queries(nquery).pitchCurve = pcYB;
    queries(nquery).featureVector = fv;
    qFVs = [qFVs; fv];
end
qXCs = [queries.xcID];
fileName = 'QUERIES_ptp000_2018-07-13-15-45-00.mat';
save(fileName,'queries','ptp','par')
%%
clc
qFVs_01 = ft_scale01(qFVs);

 fileName = 'queries_featureVectors_allSpecies_scaled';
 save(fileName, 'qFVs','qFVs_01','qXCs')

%%

load('excerpts_featureVectors_allSpecies_scaled.mat')
load('queries_featureVectors_allSpecies_scaled.mat')

qFVs_01=qFVs_01';

%%
Nquery = 100;
for nquery = 1%:Nquery
    q = qFVs_01(:,nquery);
    [sorted,i_sort] = sort(sum(abs(bsxfun(@minus,allFVs_01,q))));
    xcID = qXCs(nquery);
    sorted_list = allXCs(i_sort);
    
    rank = find(sorted_list == xcID);
    
end








