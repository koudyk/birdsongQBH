function [ featVect_global ] = ft_global( pitchCurves,vthresh,wsize_sec,hop_pwin,fsize_sec,hop_pframe,fs_a);

% pitchCurves - N-by-1 cell array of N pitch curves belonging to a
% given chunk of audio

% CONCATENATE PITCH CURVES
pitchCurve_concat = [];
for nseg=1:length(pitchCurves)
    pitchCurve = pitchCurves{nseg};
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
