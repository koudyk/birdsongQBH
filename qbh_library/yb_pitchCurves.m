function [ f0s ] = yb_pitchCurves( audio,minf0s,quality,p )
%YB_PITCHCURVES calculates the pitch curve for each unique minimum
%frequency 
%
% INPUTS
% audio - audio file (in format readable by audioread)
% minf0s - minimum-frequency curve (in any time unit)
% quality - quality of the pitch curve, that is, amount of
        % aperiodicity masking
        % 0 = no masking
        % 1 = good (default)
        % 2 = best
% p - parameters to be input into YIN (see yin.m function for
% details). Optional input; defaults are yin's defaults. Note that if
% you enter p.sr or p.minf0, it will be overwritten
%
% OUTPUTS
% f0s - u by t matrix of pitch curves, where u is the number of unique
        % minimum frequencies in minf0s and t is time in spectrogram
        % time points (i.e., p.hop in yin). 
if nargin<3, quality=1; end

[~,p.sr]=audioread(audio); % set audio sample rate
Uminf0 = unique(minf0s); % Hz; unique minimum frequencies
f0s = zeros(length(Uminf0),length(minf0_hop));
for nUminf0 = 1:length(Uminf0) % number of unique min freq, i.e., number of times YIN must be run    
    p.minf0 = Uminf0(nUminf0); % Hz; set minumum frequency for  YIN
    r = yin_k(audio,p);
    
    % select pitch curve according to desired level of masking
    if     quality == 1, f0s(nUminf0,:) = r.good;
    elseif quality == 2, f0s(nUminf0,:) = r.best;
    elseif quality == 0, f0s(nUminf0,:) = r.f0;
    end
end
end

