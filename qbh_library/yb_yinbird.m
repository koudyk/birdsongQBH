function [ F_yb,T,fig ] = yb_yinbird( audio,fs,qual,p,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin )
    if ischar(audio)
    [a,fs]=audioread(audio);
    else a=audio;
        if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
    end
    a=mean(a,2); % take mean of the two channels if there are 2 
    if nargin<9|| isempty(hop_pwin), hop_pwin=.5; end % proportion of window size; hop factor
    if nargin<8 || isempty(wsize_sec), wsize_sec=.01; end % sec; window size
    if nargin<7 || isempty(fmax_hz), fmax_hz=8000; end % Hz; max frequency
    if nargin<6 || isempty(fmin_hz), fmin_hz=30; end % Hz; min frequency (recommended by YIN-bird (O'Reilley & Harte, 2017))
    if nargin<5 || isempty(ssize_sec), ssize_sec=.15; end % sec; segment size for dynamically setting the minimum f0 for YIN
    if nargin<4 || isempty(qual),qual=2; end % quality; 1='good', 2='best', 0=raw (including pitch estimates at times when the signal is deemed aperiodic)
    wsize=floor(fs*wsize_sec); p.wsize=wsize;% samples; window size
    hop=floor(wsize*hop_pwin); p.hop=hop; % samples; hop
    Nwin=floor( (length(a)-(wsize-hop))/hop); % number of windows that fit into the audio
    T=linspace(0,p.hop*Nwin/fs,Nwin); % sec; time information for spectrogram
    fref=440; % Hz; reference frequency used by YIN to put the pitch curve in octaves

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
        if qual==1, f0=out.good;
        elseif qual==2, f0=out.best;
        elseif qual==0, f0=out.f0;
        end
        f0s(nUminf0,:)=f0(1:length(minf0_hop));
    end

% PIECE TOGETHER FINAL PITCH CURVE USING THE PITCH CURVE THAT WAS GENERATED WITH THE SEGMENT'S MIN F0 
    F_yb=[];
    Nseg=floor(length(minf0_hop)/ssize_hop); % total number of segments that fit into the prominent-frequency curve     
    for nseg=1:Nseg
        
        minf0=minf0_seg(nseg);
        i=find(Uminf0==minf0); % index in unique min f0s of the current min f0 - for finding which f0 curve to use for this segment
        f0=f0s(i,:); % pitch curve that was calculated with the desired min f0
        beg=nseg * ssize_hop - ssize_hop + 1;
        seg=f0(beg : beg + ssize_hop - 1);
        F_yb=[F_yb seg];
    end
    F_yb(end:length(minf0_hop))=out.good(length(F_yb:length(minf0_hop))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment
    F_yb=2.^F_yb.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    F_yb=F_yb(1:length(minf0_hop)); % there's an NaN at the end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%not sure why or if this is the right way to deal with it %%%%%%%%%%%%
    
    if nargout==3
        [P,F,T]=yb_spectrogram(audio,fs,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );
        minf0_hop = yb_minf0(audio,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );

        % visualize
        fig=yb_spectrogram_fig(P,F,T); % spectrogram
        hold on, plot(T,minf0_hop)
        hold on, plot(T,F_yb,'linewidth',2)
    end
end