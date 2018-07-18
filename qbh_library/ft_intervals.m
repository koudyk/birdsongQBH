function [ fv_i, label, mu_i, sigma_i, skewness_i, kurtosis_i ] =...
    ft_intervals( pc )
% ft_global - calculates global features of a pitch curve, 
% as listed in:
%
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
%   Musical genre classification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%
% INPUTS
% pitchCurveSegments_cents - (cents) N-by-1 cell array of N, T-by-1 
%       pitch curves belonging to a given excerpt of audio. N is the
%       number of segments in the excerpt, and T is the number of time
%       points in each segment.
%
% OUTPUTS
% featVect_global - vector of global features of the excerpts,
%       including the following features in this order, which can
%       also be individual outputs:
%       - mu_i - mean interval size between consecutive contours (cents)
%       - sigma_i - standard deviation of the intervals between
%               consecutive contours (cents)
%       - skewness_i - skewness of the intervals between
%               consecutive contours (cents)
%       - kurtosis_i - kurtosis of the intervals between
%               consecutive contours (cents)
%

% CHECK NUMBER OF SEGMENTS
% if length(pitchCurveSegments_cents)==1 % if there is only one segment
%     mu_i = 0;
%     sigma_i = 0;
%     skewness_i = 0;
%     kurtosis_i = 0;
%   
% else % if there is more than one segment

% SEGMENT PITCH CURVE
pc_seg = pc_segConcat(pc);    
Nseg=length(pc_seg);

if ~isempty(pc_seg)
% GET BEGINNINGS & ENDS OF SEGMENTS
    for nseg=1:length(pc_seg)
        pitchCurve = pc_seg{nseg};
        begs(nseg) = pitchCurve(1);
        fins(nseg) = pitchCurve(end);
    end

% INTERVAL FEATURES
    intervals = abs(begs(2:end) - fins(1:end-1));
    mu_i = mean(intervals);
    sigma_i = std(intervals);
    skewness_i = skewness(intervals);
    kurtosis_i = kurtosis(intervals);

    fv_i = [mu_i sigma_i skewness_i kurtosis_i]';
else fv_i = zeros(4,1);
end
    fv_i(isnan(fv_i))=0;
label={'mean interval','interval variation',...
    'interval skewness','interval kurtosis'}';
end 
