function [ featVect_pitch_duration ] = ft_pitch_duration( pitchCurve, hop, fs )
% ft_pitch_duration - calculates the pitch- and duration-related
% features of a pitch curve
    N = length(pitchCurve);

    t = N * hop / fs; % duration (sec)
    mu_p = mean(pitchCurve); % mean pitch height (cents)
    sigma_p = std(pitchCurve); % pitch deviation (cents)
    r_p = max(pitchCurve) - min(pitchCurve); % pitch range (cents)

    featVect_pitch_duration = [t mu_p sigma_p r_p];
end

