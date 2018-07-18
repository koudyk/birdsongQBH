function [ pitchCurve ] = yin_queries( audio,par )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    
if ~isfield(par,'fs'),         par.fs = 44100; end,         
if ~isfield(par,'wsize_sec'),  par.wsize_sec = .02; end,    
if ~isfield(par,'hop_pwin'),   par.hop_pwin = .1; end,      
if ~isfield(par,'aperThresh'), par.aperThresh = .1; end,    
if ~isfield(par,'fmin_hz'),    par.fmin_hz = 30; end,       
if ~isfield(par,'fmax_hz'),    par.fmax_hz = .1; end,       
if isfield(par,'yinPar'),      p=par.yinPar; end

wsize_samp = floor(par.fs*par.wsize_sec);
hop_samp = floor(wsize_samp*par.hop_pwin); 

p.sr = par.fs;
p.maxf0 = par.fmax_hz;
p.minf0 = par.fmin_hz;
p.wsize = wsize_samp;% samples; window size
p.hop = hop_samp; % samples; hop

centsPerOctave = 1200;    
    
r = yin(audio,p);
pitchCurve = r.f0 * centsPerOctave;
pitchCurve(r.ap0 > par.aperThresh) = nan;

end

