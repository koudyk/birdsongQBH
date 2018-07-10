clc,clear,close all
load('pitchCurves_concatenatedSegments_cents_spc05_NXC-Nexcerpt.mat')
load('pitchCurves_segments_cents_spc05_NXC-Nexcerpt.mat')


pc=pitchCurves_concat{1}{1};
pc_segs=pitchCurves{1}{1};

plot(pc)
ft=ft_allFeatures(pc,pc_segs)