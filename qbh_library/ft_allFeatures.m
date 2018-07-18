function [ featureVector, label] = ft_allFeatures(pc, par)

if nargin<2, par.fs = 44100; end
if ~isfield(par,'fs'),         par.fs = 44100; end,        
if ~isfield(par,'wsize_sec'),  par.wsize_sec = .02; end,   
if ~isfield(par,'hop_pwin'),   par.hop_pwin = .1; end,     

% PITCH/DURATION FEATURES
[fpd, label_fpd] = ft_pitch_duration( pc,par );

% VIBRATO FEATURES
[fv, label_fv] = ft_vibrato(pc,par);

% INTERVAL FEATURES
[fi, label_fi] = ft_intervals( pc );

% CONTOUR TYPOLOGY
[fct, label_fct] = ft_contourTypology( pc );

featureVector = [fpd; fv; fi; fct;]';
label = [label_fpd; label_fv; label_fi; label_fct];

end

