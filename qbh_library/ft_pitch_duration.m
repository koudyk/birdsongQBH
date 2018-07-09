function [ featVect_pitch_duration, t, mu_p, sigma_p, r_p] = ...
    ft_pitch_duration( pitchCurve_cents, hop_samples, fs )
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
% hop_samples - (audio samples) hop size used in calculating the 
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
N = length(pitchCurve_cents);
t = N * hop_samples / fs; % duration (sec)
mu_p = mean(pitchCurve_cents); % mean pitch height (cents)
sigma_p = std(pitchCurve_cents); % pitch deviation (cents)
r_p = max(pitchCurve_cents) - min(pitchCurve_cents); % pitch range (cents)

featVect_pitch_duration = [t mu_p sigma_p r_p];
end

