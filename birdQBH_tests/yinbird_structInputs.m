function [ f,t,sg,fig ] = yinbird_structInputs( audioFile,fs,s,p )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% p.wsize
% p.hop
% p.maxf0
% p.minf0

% p ; parameters for yin and for calculating the spectrogram
if isfield(p,'wsize'), p.ssize=floor(fs*p.wsize); 
else p.wsize=floor(fs*.02); end
if isfield(p,'hop'), p.hop=floor(p.wsize*p.hop); 
else p.hop=floor(p.wsize/2); end
if isfield(p,'maxf0'), maxf0=p.maxf0; else maxf0=8000; end % Hz; upper frequency cutoff for band-pass
if isfield(p,'minf0'), minf0=p.minf0; else minf0=200; end  % Hz; lower frequency cutoff for band-pass

% frequency filter
zp=2^nextpow2(p.wsize); % length of zero-padded window for FFT
fscale=(fs*(0:zp/2-1)/zp)'; % Hz; frequency scale for single-sided power spectrum, which results from the FFT
[~,maxf0_i]=min(abs(fscale-maxf0)); % upper cut-off for band-pass frequency filter
[~,minf0_i]=min(abs(fscale-minf0)); % lower cut-off for band-pass frequency filter
filt=zeros(length(fscale),1);
filt(fmin_i:fmax_i)=ones;

% m ; parameters for min-f0 curve for yin-bird
if isfield(s,'ssize'), s.ssize=floor(fs*s.wsize); % segment size
else s.wsize=floor(fs*.02); end
if isfield(s,'hop'), s.hop=floor(s.wsize*p.hop);
else s.hop=floor(p.wsize/2); end



    
    






end

