function [ featureVector, label] = ft_allFeatures(pc, ...
    hop_samples, fs_a)

if nargin<4 || isempty(fs_a), fs_a=44100; end % Hz
if nargin<3 || isempty(hop_samples), hop_samples=82; end
fsize_sec=.35; 

% PITCH/DURATION FEATURES
[fpd, label_fpd] = ft_pitch_duration( pc, hop_samples, fs_a );

% VIBRATO FEATURES
[fv, label_fv] = ft_vibrato(pc,hop_samples,fs_a,fsize_sec);

% CONTOUR TYPOLOGY
[fct, label_fct] = ft_contourTypology( pc );

% INTERVAL FEATURES
[fi, label_fi] = ft_intervals( pc );

featureVector = [fpd; fv; fct; fi;]';
label = [label_fpd; label_fv; label_fct; label_fi];

end

