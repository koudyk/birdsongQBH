function [ featVect_global, p_h, p_l, r_g, v_g, mu_i, sigma_i, skewness_i, kurtosis_i ] =...
    ft_global( pitchCurves_cents,vthresh,wsize_sec,hop_pwin,fsize_sec,hop_pframe,fs_a)
% ft_global - calculates global features of a pitch curve, 
% as listed in:
%
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
%   Musical genre classification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%
% INPUTS
% pitchCurves_cents - (cents) N-by-1 cell array of N, T-by-1 
%       pitch curves belonging to a given excerpt of audio. N is the
%       number of segments in the excerpt, and T is the number of time
%       points in each segment.
%
% OUTPUTS
% featVect_global - vector of global features of the excerpts,
%       including the following features in this order, which can
%       also be individual outputs:
%       - p_h - global highest pitch (cents)
%       - p_l - global lowest pitch (cents)
%       - r_g - global pitch range (cents)
%       - v_g - global vibrato presence (0-1)
%       - mu_i - mean interval size between consecutive contours (cents)
%       - sigma_i - standard deviation of the intervals between
%               consecutive contours (cents)
%       - skewness_i - skewness of the intervals between
%               consecutive contours (cents)
%       - kurtosis_i - kurtosis of the intervals between
%               consecutive contours (cents)
%

% CONCATENATE PITCH CURVES
pitchCurve_concat = [];
for nseg=1:length(pitchCurves_cents)
    pitchCurve = pitchCurves_cents{nseg};
    pitchCurve_concat = [pitchCurve_concat pitchCurve];
    [~,v_g_eachSegment(nseg)]=ft_vibrato( pitchCurve,vthresh,wsize_sec,hop_pwin,fsize_sec,hop_pframe,fs_a);
    begs(nseg) = pitchCurve(1);
    fins(nseg) = pitchCurve(end);
end
intervals = begs(2:end) - fins(1:end-1);

p_h = max(pitchCurve_concat); % GLOBAL HIGHEST PITCH
p_l = min(pitchCurve_concat); % GLOBAL LOWEST PITCH
r_g = p_h - p_l; % GLOBAL PITCH RANGE
v_g = mean(v_g_eachSegment); % GLOBAL VIBRATO PRESENCE

% INTERVAL FEATURES
mu_i = mean(intervals);
sigma_i = std(intervals);
skewness_i = skewness(intervals);
kurtosis_i = kurtosis(intervals);

featVect_global = [p_h p_l r_g v_g mu_i sigma_i skewness_i kurtosis_i];
end 
