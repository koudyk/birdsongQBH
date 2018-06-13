function [P,F,T]=yb_spectrogram(audio,fs,fmin,fmax,wsize_sec,hop_pwin)

    if ischar(audio)
    [a,fs]=audioread(audio);
    else a=audio;
        if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
    end
    a=mean(a,2); % take mean of the two channels if there are 2  
    if nargin<6 || isempty(hop_pwin), hop_pwin=.5; end % proportion of window size; hop factor
    if nargin<5 || isempty(wsize_sec), wsize_sec=.01; end % sec; window size
    if nargin<4 || isempty(fmax), fmax=fs/2; end % Hz; max frequency
    if nargin<3 || isempty(fmin), fmin=30; end % Hz; min frequency (recommended by YIN-bird (O'Reilley & Harte, 2017))

    wsize=floor(fs*wsize_sec); % samples; window size
    hop=floor(wsize*hop_pwin); % samples; hop
    Nwin=floor( (length(a)-(wsize-hop))/hop); % number of windows that fit into the audio
    wsize_zp=2^nextpow2(wsize); % zerp-padded window size
    F=(fs*(0 : wsize_zp/2 -1)/wsize_zp)'; % % Hz; frequency info for spectrogram
    T=linspace(0,hop*Nwin/fs,Nwin); % sec; time information for spectrogram

    % frequency filter
    [~,fmax_i]=min(abs(F-fmax)); % upper cut-off for band-pass frequency filter
    [~,fmin_i]=min(abs(F-fmin)); % lower cut-off for band-pass frequency filter
    filt=zeros(length(F),1); % filter
    filt(fmin_i:fmax_i)=ones;
    
    P=zeros(wsize_zp/2,Nwin);
    for nwin=1:Nwin 
        beg=nwin*hop-hop+1;
        win=a(beg:beg+wsize-1); % window of waveform for calculating prominent frequency
        p2=abs(fft(win,wsize_zp)); % 2-sided power spectrum
        p1=p2(1:floor(length(p2)/2)); % single-sided power spectrum
        p1=p1.*filt; % set too-low and too-high frequencies to 0;
        P(:,nwin)=p1; % power per frequency bin per second (i.e., spectrogram)
    end
    P=10*log10(P); % convert power to decibels;
    P=P(fmin_i:fmax_i,:);
    F=F(fmin_i:fmax_i);

end
