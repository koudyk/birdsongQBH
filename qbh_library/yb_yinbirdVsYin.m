function [ r,fig ] = yb_yinbird( audio,fs,p,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin )
%	YB_YINBIRD calculates the pitch curve for birdsong, 
%   implementing YIN-bird (O'Reilley & Harte, 2017).	
%				
%	OUTPUTS (variable - (units) description)			
%	f0_yb     - (Hz) f-by-1 vector of fundamental-frequency 
%               values (f0) estimated with YIN-bird.
%	T         - (sec) t-by-1 vector of time values for the pitch curve.
%   r         - output structure of the YIN function.
%	fig       - outputs a figure with the pitch curve and the 
%               minimum-frequency curve overlayed over the spectrogram 
%               for the given file.
%				
%	INPUTS			
%	audio     -  audio file (in a format readable by the audioread 
%                funciton) or as a waveform (in which case you must 
%                input the sampling rate fs)
%	fs        -  (samples) sampling rate of the audio file
%	ssize_sec -  (sec) segments size. The pitch curve will for 
%                the audio within a given segment will be 
%                determined by YIN using the minimum-frequency 
%                determined as the minimum prominent frequency 
%                for that segment.
%	fmin_hz   -  (Hz) minimum of frequency range.
%	fmax_hz   -  (Hz) maximum of frequency range.
%	wsize_sec -  (sec) window size for calculating the frequency-power spectrum 
%	hop_pwin  -  (percent of window size) hop value.


if ischar(audio)
[a,fs]=audioread(audio);
else a=audio;
    if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
end
a=mean(a,2); % take mean of the two channels if there are 2 
if nargin<8|| isempty(hop_pwin), hop_pwin=.5; end % proportion of window size; hop factor
if nargin<7 || isempty(wsize_sec), wsize_sec=.025; end % sec; window size
if nargin<6 || isempty(fmax_hz), fmax_hz=10000; end % Hz; max frequency
if nargin<5 || isempty(fmin_hz), fmin_hz=30; end % Hz; min frequency (recommended by YIN-bird (O'Reilley & Harte, 2017))
if nargin<4 || isempty(ssize_sec), ssize_sec=.068; end % sec; segment size for dynamically setting the minimum f0 for YIN

wsize=floor(fs*wsize_sec); p.wsize=wsize;% samples; window size
hop=floor(wsize*hop_pwin); p.hop=hop; % samples; hop
Nwin=floor( (length(a)-(wsize-hop))/hop); % number of windows that fit into the audio
fref=440; % Hz; reference frequency used by YIN to put the pitch curve in octaves
p.sr=fs;

[~,F,T,P]=spectrogram(a,wsize,hop,wsize,fs);

% MINIMUM-FREQUENCY CURVE FOR YIN
[minf0_hop,minf0_seg,T_minf0_seg] = yb_minf0( audio,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );
ssize_hop=T_minf0_seg(2)-T_minf0_seg(1); % hops (i.e., spectrogram time points); segment size
%ssize_samples=ssize_hop*hop;

Uminf0=unique(minf0_seg); % Hz; unique minimum frequencies
%f0s=zeros(length(Uminf0,length(minf0_hop)));
for nUminf0=1:length(Uminf0) % number of unique min freq, i.e., number of times YIN must be run

% CALCULATE PITCH CURVE FOR EACH UNIQUE MIN F0    
    p.minf0=Uminf0(nUminf0); % Hz; set minumum frequency for  YIN
    r=yin_k(audio,p);
    f0s(nUminf0,:)=r.good;
end

% PIECE TOGETHER FINAL PITCH CURVE USING THE PITCH CURVE THAT WAS GENERATED WITH THE SEGMENT'S MIN F0 
f0yb_oct=[];
Nseg=floor(length(minf0_hop)/ssize_hop); % total number of segments that fit into the prominent-frequency curve     
for nseg=1:Nseg
    minf0=minf0_seg(nseg);
    i=find(Uminf0==minf0); % index in unique min f0s of the current min f0 - for finding which f0 curve to use for this segment
    f0=f0s(i,:); % pitch curve that was calculated with the desired min f0
    beg=nseg * ssize_hop - ssize_hop + 1;
    seg=f0(beg : beg + ssize_hop - 1);
    f0yb_oct=[f0yb_oct seg];
end
f0yb_oct(end:length(r.f0))=r.f0(length(f0yb_oct:length(T))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment

%f0yb_hz=f0yb_hz(1:length(minf0_hop)); % there's an NaN at the end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%not sure why or if this is the right way to deal with it %%%%%%%%%%%%

% PLAIN YIN
p.minf0=fmin_hz;    
r=yin_k(a,p);
f0y_hz = 2.^ r.good .*fref; % convert pitch curve from octaves relative to 440 Hz to Hz. 
f0yb_hz=2.^f0yb_oct.*fref; 

% make yin and spectrogram output the same length
T=[nan T];
minf0_hop=[nan minf0_hop];

T(end+1:length(r.f0))=NaN;
minf0_hop(end+1:length(r.f0))=NaN;

% ADD YINBIRD OUTPUTS TO YIN'S 'r' OUTPUT
r.yinbird=f0yb_hz; % add the yinbird pitch curve to yin's output
r.minf0_hop=minf0_hop; % need the nan's to make them the same length
r.timescale=T;


% VISUALIZE
if nargout==2 % plot pitch curve on top of spectrogram
    fmax_hz_plot=min([fmax_hz max(f0yb_hz)+1000]);
    fmin_hz_plot=max([fmin_hz min(f0yb_hz)-1000]);
    [~,fmax_i]=min(abs(F-fmax_hz_plot)); % upper cut-off for band-pass frequency filter
    [~,fmin_i]=min(abs(F-fmin_hz_plot)); % lower cut-off for band-pass frequency filter
    P=P(fmin_i:fmax_i,:);
    
    fig=figure;
    subplot(2,1,1)
    imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
    set(gca(),'Ydir','normal')
    hold on, plot(T,f0y_hz,'r-', 'linewidth',2)
    title('YIN')
    ylabel('Frequency (Hz)'), xlabel('Time (sec)')
    
    subplot(2,1,2);
    imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
    set(gca(),'Ydir','normal')
    hold on, plot(T,minf0_hop,'w')
    hold on, plot(T,f0yb_hz,'r-','linewidth',2)
    title('YIN-bird')
    ylabel('Frequency (Hz)'), xlabel('Time (sec)')
    
end
end