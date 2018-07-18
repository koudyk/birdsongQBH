clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('QUERIES_ptp000_2018-07-13-15-45-00.mat')
%load('featureVectors_normalized_allSpecies_Nexcerpt-by-Nfeature.mat')
load('STIMULI3.mat')
Nspec=10;

fs=44100;
queries = sortQueries(queries); % un-randomize order


%%
for nq = 1:length(queries)

    q = queries(nq).query;
    s = stimuli(nq).stimulus;
    
    out = yin_k(q);
    out.
    queries(nq).pitchCurve = 
    
%     title(queries(nq).spec)
%     subplot(211),    plot(s)
%     subplot(212),plot(q(1:length(s)))
%     
%     pause
    
%     sound(s,fs)
%     pause(length(s)/fs)
%     
%     sound(q,fs)
%     pause(length(q)/fs)
%     queries(nq).features_q = ft_normalizeFeatures(ft_allFeatures(q));
%     queries(nq).features_s = ft_normalizeFeatures(ft_allFeatures(s));
    
    
    
    
end
%%
%save('QUERIES_Wfeatures_ptp000_2018-07-13-15-45-00.mat','queries','ptp','order')