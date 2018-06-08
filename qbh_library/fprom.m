function [ F_prom, tF_prom, sg, sg_fig ] = fprom(audio,fs,fmin,fmax,wsize,hop)
% FPROM 
% Generates the prominent-frequency curve to be used in YIN-bird
% to dynamically determine the minimum frequency for YIN.
% This curve is calculated in the following way:
% 1) calculate the frequency spectrum for each time window of the
%    audio using the Fast Fourier Transform,
% 2) store the frequency and power of the frequency with the highest 
%    power for each window,
% 3) calculate the mean power of these maximum-power frequencies, and
% 4) set the prominent-frequency curve to be those maximum-power
%    frequencies that are greater than or equal to the mean 
%    maximum-power frequency.
%
% INPUTS
% audio     waveform of the audio or audio file (in a format readable by audioread)
% fs        samples/sec; sampling rate of the audio (required input if
%               the audio is input as a waveform)
% fmin      Hz; minimum frequency (lower cutoff of band-pass filter)
% fmax      Hz; maximum frequency (upper cutoff of band-pass filter)
% wsize     sec; window size for performing the fourier transform
% hop       percent of window size; hop length between windows
%
% OUTPUTS
% Fprom     Hz; prominent frequency   
% t_Fprom   sec; timescale of the Fprom output
% sg        output a figure displaying the frequency spectrum over
%           time with the prominent-frequency curve overlayed

if ischar(audio)
    [a,fs]=audioread(audio);
else a=audio;
    if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
end
a=mean(a,2); % take mean of the two channels if there are 2  
if nargin<6 || isempty(hop), hop=.5; end
if nargin<5 || isempty(wsize), wsize=.01; end
if nargin<4 || isempty(fmax), fmax=fs/2; end
if nargin<3 || isempty(fmin), fmin=0; end

% ADAPT PARAMETERS TO SAMPLING FREQUENCY
wsize=floor(fs*wsize); % frames; 
zp=2^nextpow2(wsize); % frames; size of zerp-padded window
hop=floor(wsize*hop); % frames;
Nwin=floor((length(a)-(wsize-hop))/hop); % total number of windows that fit in the waveform
fscale=(fs*(0:zp/2-1)/zp)'; % Hz; frequency scale correponding to the single-sided power spectrum 
tmax=wsize*Nwin/fs;

% frequency filter    
[~,fmax_i]=min(abs(fscale-fmax)); % upper cut-off for band-pass frequency filter
[~,fmin_i]=min(abs(fscale-fmin)); % lower cut-off for band-pass frequency filter
filt=ones(length(fscale),1);
filt(1:fmin_i)=0; filt(fmax_i:end)=0;

% CALCULATE PROMINENT-FREQUENCY CURVE
for nwin=1:Nwin % 208
    beg=nwin*hop-hop+1; % beginning of window
    win=a(beg:beg+wsize-1); % window of waveform for calculating prominent frequency
    p2=abs(fft(win,zp)); % 2-sided power spectrum
    p1=p2(1:floor(length(p2)/2)); % single-sided poser spectrum
    p1f=p1.*filt; % set too-low and too-high frequencies to 0;
    if nargout>2, sg(:,nwin)=p1; end % if they want to see the spectrogram, store the frequency spectrum for each window
    if sum(p1)>0
        [P_prom(nwin),i]=max(p1); % store power of max-power frequency
        F_prom(nwin)=fscale(i); % store frequency of max-power frequency
    end
end
if nargout>2,sg=10*log10(sg); end % convert power to decibels
F_prom(P_prom<(mean(P_prom)))=NaN; % set prominent frequencies below the mean prominent freuency to NaN
tF_prom=linspace(0,tmax,length(F_prom)); % time scale

% VISUALIZE
if nargout==4
    fmax_fig=max(F_prom)+3000; % Hz; maximum frequency for the spectrogram
    [~,fmax_i_fig]=min(abs(fscale-fmax_fig)); % index of the max frequency for the spectrogram
    sg=sg(fmin_i:fmax_i_fig,:); % only visualize the portion around the prominent-frequency curve
    sg_fig=figure;imagesc([0 tmax],[fmin fmax_fig],sg),set(gca(),'YDir','normal'),hold on
    plot(tF_prom,F_prom,'r','linewidth',1)
    ylabel('Frequency (Hz)'),xlabel('Time (sec)')
end
end

