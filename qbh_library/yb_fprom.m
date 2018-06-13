function [ Fprom ] = yb_fprom( audio,fs,fmin,fmax,wsize_sec,hop_pwin )
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

    [Psp,Fsp,Tsp]=yb_spectrogram(audio,fs,fmin,fmax,wsize_sec,hop_pwin );
    Fprom=nanmax(Psp);
end

