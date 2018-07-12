function [ fv_n ] = ft_normalizeFeatures( fv )

load('normalizationParameters_perFeature.mat') % mean and st. dev. across excerpts

fv_n = (fv-mu_feat) ./sigma_feat;



end

