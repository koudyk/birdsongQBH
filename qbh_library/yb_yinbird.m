function [ f0_yb,T,fig ] = yb_yinbird( audio,fs,quality,p,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin )
%	YB_YINBIRD calculates the pitch curve for birdsong, 
%   implementing YIN-bird (O'Reilley & Harte, 2017).	
%				
%	OUTPUTS (variable - (units) description)			
%	f0_yb     - (Hz) f-by-1 vector of fundamental-frequency 
%               values (f0) estimated with YIN-bird.
%	T         - (sec) t-by-1 vector of time values for the pitch curve.
%	fig       - outputs a figure with the pitch curve and the 
%               minimum-frequency curve overlayed over the spectrogram 
%               for the given file.
%				
%	INPUTS			
%	audio     -  audio file (in a format readable by the audioread 
%                funciton) or as a waveform (in which case you must 
%                input the sampling rate fs)
%	fs        -  (samples) sampling rate of the audio file
%	quality	  -  quality of the pitch curve. 
%                   1 = good (default)
%                   2 = best
%                   0 = raw (i.e., includes pitch estimates at times 
%                       when the signal is deemed aperiodic)
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
    if nargin<9|| isempty(hop_pwin), hop_pwin=.5; end % proportion of window size; hop factor
    if nargin<8 || isempty(wsize_sec), wsize_sec=.01; end % sec; window size
    if nargin<7 || isempty(fmax_hz), fmax_hz=fs/2; end % Hz; max frequency
    if nargin<6 || isempty(fmin_hz), fmin_hz=30; end % Hz; min frequency (recommended by YIN-bird (O'Reilley & Harte, 2017))
    if nargin<5 || isempty(ssize_sec), ssize_sec=.068; end % sec; segment size for dynamically setting the minimum f0 for YIN
    if nargin<3 || isempty(quality),quality=1; end % quality; 1='good', 2='best', 0=raw (including pitch estimates at times when the signal is deemed aperiodic)
    
    wsize=floor(fs*wsize_sec); p.wsize=wsize;% samples; window size
    hop=floor(wsize*hop_pwin); p.hop=hop; % samples; hop
    Nwin=floor( (length(a)-(wsize-hop))/hop); % number of windows that fit into the audio
    T=linspace(0,hop*Nwin/fs,Nwin); % sec; time info for the spectrogram
    fref=440; % Hz; reference frequency used by YIN to put the pitch curve in octaves
    p.sr=fs;
    
% MINIMUM-FREQUENCY CURVE FOR YIN
    [minf0_hop,minf0_seg,T_minf0_seg] = yb_minf0( audio,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );
    ssize_hop=T_minf0_seg(2)-T_minf0_seg(1); % hops (i.e., spectrogram time points); segment size
    ssize_samples=ssize_hop*hop;
    
    Uminf0=unique(minf0_seg); % Hz; unique minimum frequencies
    for nUminf0=1:length(Uminf0) % number of unique min freq, i.e., number of times YIN must be run
        clear filt
        
% CALCULATE PITCH CURVE FOR EACH UNIQUE MIN F0    
        p.minf0=Uminf0(nUminf0); % Hz; set minumum frequency for  YIN
        out=yin_k(audio,p);
        
        % select pitch curve correponding to the desired quality
        if quality==1, f0=out.good;
        elseif quality==2, f0=out.best;
        elseif quality==0, f0=out.f0;
        end
        f0s(nUminf0,:)=f0(1:length(minf0_hop));
    end

% PIECE TOGETHER FINAL PITCH CURVE USING THE PITCH CURVE THAT WAS GENERATED WITH THE SEGMENT'S MIN F0 
    f0_yb=[];
    Nseg=floor(length(minf0_hop)/ssize_hop); % total number of segments that fit into the prominent-frequency curve     
    for nseg=1:Nseg
        
        minf0=minf0_seg(nseg);
        i=find(Uminf0==minf0); % index in unique min f0s of the current min f0 - for finding which f0 curve to use for this segment
        f0=f0s(i,:); % pitch curve that was calculated with the desired min f0
        beg=nseg * ssize_hop - ssize_hop + 1;
        seg=f0(beg : beg + ssize_hop - 1);
        f0_yb=[f0_yb seg];
    end
    f0_yb(end:length(minf0_hop))=out.good(length(f0_yb:length(minf0_hop))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment
    f0_yb=2.^f0_yb.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    f0_yb=f0_yb(1:length(minf0_hop)); % there's an NaN at the end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%not sure why or if this is the right way to deal with it %%%%%%%%%%%%
    
    if nargout==3
        [P,F,T]=yb_spectrogram(audio,fs,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );
        minf0_hop = yb_minf0(audio,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );

        % visualize
        fig=yb_spectrogram_fig(P,F,T); % spectrogram
        hold on, plot(T,minf0_hop)
        hold on, plot(T,f0_yb,'linewidth',2)
    end
end