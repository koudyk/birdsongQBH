function [ featVect_pitch_duration, label, t, mu_p, sigma_p, r_p] = ...
    ft_pitch_duration( pc, hop_a_samples, fs_a )

% ft_pitch_duration - calculates the pitch- and duration-related
% features of a pitch curve, as listed in:
%
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
%   Musical genre classification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%
% INPUTS
% pitchCurve_cents - (cents) pitch curve i.g., a T-by-1 vector of
%       pitch values over time
% hop_a_samples - (audio samples) hop size used in calculating the 
%       pitch curve.
% fs - (Hz) sampling rate of the audio that the pitch curve was
%       calculated from.
%
% OUTPUTS
% featVect_pitch_duration - vector of features of the excerpts 
%       relating to the pitch and duration of the pitch curves,
%       including the following features in this order, which can
%       also be individual outputs:
%       - t - (sec) duration
%       - mu_p - (cents) mean pitch height
%       - sigma_p - (cents) pitch deviation
%       - r_p - (cents) pitch range
% 

N = length(pc);
t = N * hop_a_samples / fs_a; % duration (sec)
mu_p = mean(pc); % mean pitch height (cents)
sigma_p = std(pc); % pitch deviation (cents)
r_p = max(pc) - min(pc); % pitch range (cents)
tv = mean(abs( [0 pc]-[pc 0]));

featVect_pitch_duration = [t mu_p sigma_p r_p tv];
label={'duration (sec)','mean pitch height (cents)','pitch deviation (cents)',...
    'pitch range (cents)','total variation in pitch (cents)'};
end

