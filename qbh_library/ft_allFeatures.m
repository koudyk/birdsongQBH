function [ featureVector, label] = ft_allFeatures(pc_segs, ...
    hop_samples, fs_a)

if nargin<4 || isempty(fs_a), fs_a=44100; end % Hz
if nargin<3 || isempty(hop_samples), hop_samples=82; end
fsize_sec=.35; 

if ~iscell(pc_segs), 
    pcs{1,1}=pc_segs;
else pcs=pc_segs;
end

Nseg=length(pcs);
pc_concat=[];
for nseg=1:Nseg
    pc_concat=[pc_concat pcs{nseg}];
end
pc_concat(isnan(pc_concat))=[];

% PITCH/DURATION FEATURES
[fpd, label_fpd] = ft_pitch_duration_segs( pcs, hop_samples, fs_a );

% VIBRATO FEATURES
[fv, label_fv] = ft_vibrato(pc_concat,hop_samples,fs_a,fsize_sec);

% CONTOUR TYPOLOGY
[fct, label_fct] = ft_contourTypology( pcs );

% INTERVAL FEATURES
[fi, label_fi] = ft_intervals( pcs );

featureVector = [fpd fv fct fi];
label = [label_fpd label_fv label_fct label_fi];

end

