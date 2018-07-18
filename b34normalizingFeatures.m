clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('featureVectors_allSpecies_Nexcerpt-by-Nfeature')
feat=features_allspec;
%%
Nfeat=43;
Nexcerpt=length(feat);
needNormalize = 1:19;

for nfeat = needNormalize
    nonNan = find(~isnan(feat(:,nfeat)));
    mu_feat(nfeat)=nanmean(feat(nonNan,nfeat));
    sigma_feat(nfeat)=std(feat(nonNan,nfeat));
    
    for nexcerpt=1:Nexcerpt
        fv_e_n(nexcerpt,nfeat) = (feat(nexcerpt,nfeat)-mu_feat(nfeat))/sigma_feat(nfeat);
    end
end

needNotNormalize = 20:Nfeat;
mu_feat(needNotNormalize) = 0;
sigma_feat(needNotNormalize)= 1;

save('normalizationParameters_perFeature','mu_feat','sigma_feat','-v7.3')
save('featureVectors_normalized_allSpecies_Nexcerpt-by-Nfeature',...
    'fv_e_n','xcID_allspec','spec_allspec','-v7.3')

temp3=zscore(feat);
%%
%dif=nansum(nansum(abs(fv_e_n-temp3)))
    