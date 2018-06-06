% testing different methods of pitch tracking
clc;clear;close all; clear sound

rdir='F:\0.birdsongQBH\audio';
addpath(genpath(rdir))
load('b8_output_audioData_withAonly.mat')
d=recDetA; % structure with data information; recDet for recordings of quality A and B; recDetA for recordings of quality A only. 

% PARAMETERS TO BE TUNED
wsize_sec=.01; % seconds; window size (10 msec)
f0min_Hz=40; % Hz; minimum frequency
f0max_Hz=8000; % Hz; maximum frequency


vis=1; % visualize?
k=1;
n=0;

ws=[0.001 0.005 0.01 0.025 0.05];
for nws=1:length(ws) 
    wsize_sec=ws(nws);
for na=43 % number of the audio file (in the d data structure)
    clear Pp Fp 
% LOAD AUDIO
    afile=[num2str(d(na).id) '.wav'];
    [a,fs]=audioread(afile); % read audio file as a waveform
    a=a(:,1); % take only one channel %%%%%%%%%%%%%% NOT SURE WHAT'S THE BEST WAY TO DO THIS - MEAN? SELECT ONE?
   
% PARAMETERS (SET ACCORDING TO FS)   
    wsize=round(fs*wsize_sec);
    zp=round(wsize*1.5); % length of zero-padded window
    f=(fs*(0:(zp/2)-1)/zp)'; % frequency scale for the result of the FFT
    t=(1000*(0:wsize-1)/fs)'; % time scale for window (in miliseconds)
    [~,f0min]=min(abs(f-f0min_Hz)); % minimum of the f0 search range 
    [~,f0max]=min(abs(f-f0max_Hz)); % maximum of the f0 search range
    
    for nwin=1:floor(length(a)/wsize)   %%% good windows 500:550
        beg=nwin*wsize-wsize+1; % beginning of the window
        win=a(beg:beg+wsize*1-1); % window of data for calculating pitch
        %win=[zeros(hop,1); win; zeros(hop,1)]; % zero-pad

% PROMINENT FREQUENCY 
        p2=abs(fft(win,zp)); % two-sided power spectrum for zero-padded window
        p1=p2(1:floor(length(p2)/2)); % single-sided power sepctrum
        if sum(p1)
            [Pp(nwin),i]=max(p1); % store power of max-power frequency
            Fp(nwin)=f(i); % store frequency of max-power frequency
        end
    end
    tFp=wsize_sec*(0:length(Fp)-1); % time scale for pitch curve
     Fp(Pp<mean(Pp))=NaN;
     
     row=length(ws); col=1;
     n=n+1; subplot(row,col,n),plot(tFp,Fp),title(['wsize = ' num2str(wsize/fs*1000) ' ms'])
     ylim([0 15000])
     if nws==length(nws),xlabel('time (sec)'),ylabel('frequency (Hz)'),end
end
    
end

sound(a,fs)
