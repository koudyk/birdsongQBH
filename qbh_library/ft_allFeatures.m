function [ featureVector ] = ft_allFeatures( pitchCurve_cents, hop_samples, fs, pitchCurveSegments_cents)



% PITCH/DURATION FEATURES
fpd = ft_pitch_duration( pitchCurve_cents, hop_samples, fs );

% VIBRATO FEATURES


% CONTOUR TYPOLOGY
fct = ft_contourTypology( pitchCurve_cents );



featureVector = [fpd fct];

% INTERVAL FEATURES
if nargin==4;
    fi = ft_intervals( pitchCurveSegments_cents );
    featureVector = [featureVector fi];
end

end

