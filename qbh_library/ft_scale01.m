function [ nFV ] = ft_scale01( FV, min_feat, range_feat )

if nargin<2, load('featureScalingParameters.mat'), end

%s=size(FV);
%if s(1) ~= 43, error('error: feature vectors should be columns'), end

nFV = bsxfun(@rdivide, bsxfun(@minus, FV, min_feat), range_feat);


end

