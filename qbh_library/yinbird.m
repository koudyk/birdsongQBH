function [ F_yb,t,sg,sg_fig] = yinbird( audioFile,fs,quality,ssize,fmin,fmax,wsize,hop)
% YINBIRD  - pitch curve as calculated by YIN-bird
% calculates the pitch curve according to the method outlined in 
    % O’Reilly, C., & Harte, N. (2017). Pitch tracking of bird 
    % vocalizations and an automated process using YIN-bird. 
    % Cogent Biology, 3(1), 1322025.
%
% INPUTS
% a         audio file (in format readable by audioread)
% fs        samples/sec; sampling rate of the audio (required input if
%               the audio is input as a waveform)
% quality   quality of the YIN pitch-curve estimate; 
%               0=raw pitch curve; includes pitch estimates for 
%                 aperiodic sounds
%               1='good' pitch curve
%               2='best' pitch curve
% ssize     sec; segment size for YIN-bird
% minf0     Hz; minimum frequency for YIN
% maxf0     Hz; maximum frequency for YIN
% wsize     sec; window size for performing the fourier transform
% hop       percent of window size; hop length between windows
%
% OUTPUTS
% F_yb      Hz; pitch curve calculated by YIN-bird  
% t         sec; timescale of the F_yinbird output
% ps_t      output a figure displaying the frequency spectrum over
%           time with the prominent-frequency curve overlayed


[a,fs]=audioread(audioFile);
a=mean(a,2); % take mean of the two channels if there are 2  

if nargin<7 || isempty(wsize), wsize=.025; end
if nargin<8 || isempty(hop), hop=.05; end
if nargin<6 || isempty(fmax), fmax=fs/2; p.maxf0=fmax; end
if nargin<5 || isempty(fmin), fmin=0; p.minf0=0; end
if nargin<4 || isempty(ssize), ssize=.15; end
if nargin<3 || isempty(quality), quality=0;

wsize=floor(fs*wsize); 
hop=floor(wsize*hop); 
Nwin=floor((length(a)-(wsize-hop))/hop);
tmax=wsize*Nwin/fs;
[Fp,~,sg]=fprom(a,fs,fmin,fmax,.01,.5); % PROMINENT FREQUENCY
hop_fft=floor(length(a)/length(Fp));
ssize=floor(ssize*fs/hop_fft); % segment size
Nseg=floor(length(Fp)/ssize); % number of segments that fit in the audio
fref=440; % Hz; reference frequency used by YIN to put the pitch curve in octaves

p.wsize=wsize;
p.hop=hop;
p.maxf0=fmax;
p.minf0=fmin;

% SET MINIMUM-FREQUENCY CURVE FOR DYNAMICALLY SETTING THE MIN FREQUENCY FOR YIN
for nseg=1:Nseg
    beg=nseg*ssize-ssize+1;
    seg=Fp(beg:beg+ssize-1);
    if nansum(seg)>0
        minFp(nseg)=nanmin(seg); % minimum prominent frequency for given segment
    else minFp(nseg)=0;
    end
end

F_yb=[];
nonZero=find(minFp>0); 
for nseg=1:Nseg
    if minFp(nseg)==0
        [~,nnbr]=min(abs(nonZero-nseg)); % nearest neighbour (preferring left if equidistant)
        minFp(nseg)=minFp(nonZero(nnbr))-2; % set minimum frequency; subtract 2 to account for discretization of frequency
    end
    p.minf0=minFp(nseg); % set minimum frequency to min prominent freq
    out=yin_k(audioFile,p); % use YIN to analyze entire audio with the given min frequency 
    if quality==1, f0=out.good; 
    elseif quality==0, f0=out.f0; 
    elseif quality==2, f0=out.best; 
    end
    beg=nseg*ssize-ssize+1;
    %%%%%%%%%%%PROBLEM HERE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    seg=f0(beg:beg+ssize-1); % segment of the YIN pitch curve that corresponds to the given segment of the min-frequency curve
    F_yb=[F_yb seg]; % concatenate the segments to form a full pitch curve
end
F_yb(end:length(Fp))=f0(length(F_yb:length(Fp))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment
F_yb=2.^F_yb.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
F_yb=F_yb(1:length(Fp)); % there's an NaN at either end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t=linspace(0,tmax,length(F_yb));

% VISUALIZE
if nargout==4
    fmax_fig=round(max(F_yb)+3000); % Hz; maximum frequency for the spectrogram
    %[~,fmax_i_fig]=min(abs(fscale-fmax_fig)); % index of the max frequency for the spectrogram
    sg=sg(1:fmax_fig,:); % only visualize the portion around the prominent-frequency curve
    sg_fig=figure;imagesc([0 tmax],[fmin fmax_fig],sg),set(gca(),'YDir','normal'),hold on
    plot(tF_prom,F_prom,'r','linewidth',1)
    ylabel('Frequency (Hz)'),xlabel('Time (sec)')
end

end

