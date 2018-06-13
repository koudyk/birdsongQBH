function [P_sp,F_sp,T_sp,fig_sp]=spect(a,fs,fmin,fmax,wsize_sec,hop_pwin);
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
    F_sp=(fs*(0 : wsize_zp/2 -1)/wsize_zp)'; % % Hz; frequency info for spectrogram
    T_sp=linspace(0,wsize*Nwin/fs); % sec; time information for spectrogram
    
    % frequency filter
    [~,fmax_i]=min(abs(F_sp-fmax)); % upper cut-off for band-pass frequency filter
    [~,fmin_i]=min(abs(F_sp-fmin)); % lower cut-off for band-pass frequency filter
    filt=zeros(length(F_sp),1); % filter
    filt(fmin_i:fmax_i)=ones;
    
    P_sg=zeros(wsize_zp,Nwin);
    for nwin=1:Nwin 
        beg=nwin*hop-hop+1;
        win=a(beg:beg+wsize-1); % window of waveform for calculating prominent frequency
        p2=abs(fft(win,zp)); % 2-sided power spectrum
        p1=p2(1:floor(length(p2)/2)); % single-sided power spectrum
        p1=p1.*filt; % set too-low and too-high frequencies to 0;
        P_sg(:,nwin)=p1; % power per frequency bin per second (i.e., spectrogram)
    end
    P_sg=10*log10(P_sg); % convert power to decibels;
    
    if nargout==4 % if they want the figure
        sg=P_sg(fmin_i:fmax_i);
        fig_sp=figure;imagesc([0 T_sp(end)],[fmin fmax],sg)
        set(gca(),'YDir','normal')
        ylabel('Frequency (Hz)'),xlabel('Time (sec)')
        close fig_sp
    end
end
