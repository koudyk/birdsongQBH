% testing different methods of pitch tracking
clc;clear;close all; clear sound

rdir='F:\0.birdsongQBH\audio';
addpath(genpath(rdir))
load('b8_output_audioData_withAonly.mat')
d=recDetA; % structure with data information; recDet for recordings of quality A and B; recDetA for recordings of quality A only. 

% PARAMETERS TO BE TUNED
wsize_sec=.01; % seconds; window size (10 msec)
hop_sec=wsize_sec*.5; % seconds; overlap between windows
absThresh=.1; % absolute threshold for YIN
Nneighbours=1; % number of neighbouring points to either side of dip min that are considered when fitting a parabola
f0min=40; % Hz; minimum frequency
f0max=8000; % Hz; maximum frequency
fref=440; % reference frequency used by YIN to put the pitch curve in octaves
len_sec=3; % sec; length of audio to work with
vis=1; % visualize?
id=325520;
ws=[0.02 0.03 0.04];

figure
for na=find([d.id]==id)%43 % number of the audio file (in the d data structure)
n=0; clf
for nws=1:length(ws) 
    wsize_sec=ws(nws);
    
    clear Pp Fp 
% LOAD AUDIO
    afile=[num2str(d(na).id) '.wav'];
    %afile='short_northernCardinal.wav';
    %afile='short_veery.wav';
    [a,fs]=audioread(afile); % read audio file as a waveform
    a=a(:,1); % take only one channel %%%%%%%%%%%%%% NOT SURE WHAT'S THE BEST WAY TO DO THIS - MEAN? SELECT ONE?
    
% ONLY PART OF AUDIO?
    a=a(1:len_sec*fs);
    audiowrite('temp.wav',a,fs)
    afile='temp.wav';
    
% PARAMETERS (SET ACCORDING TO FS)   
    wsize=round(fs*wsize_sec);
    hop=round(fs*wsize_sec/2);
    zp=round(wsize*1.5); % length of zero-padded window
    f=(fs*(0:(zp/2)-1)/zp)'; % Hz; frequency scale for the result of the FFT
    t=(1000*(0:wsize-1)/fs)'; % ms; time scale for window
    fmin=0; fmax=fs/2;
    tmin=0; tmax=length(a)/fs;
    
% PROMINENT FREQUENCY     
    for nwin=1:floor(length(a)/hop)-1   %%% good windows 500:550
        beg=nwin*hop-hop+1; % beginning of the window
        win=a(beg:beg+wsize-1); % window of data for calculating pitch
        %win=[zeros(hop,1); win; zeros(hop,1)]; % zero-pad
        p2=abs(fft(win,zp)); % two-sided power spectrum for zero-padded window
        p1=p2(1:floor(length(p2)/2)); % single-sided power sepctrum
        ind=find(abs(f)<f0min | abs(f)>f0max); p1(ind)=0; % band-pass frequency filter
        if sum(p1)
            [Pp(nwin),i]=max(p1); % store power of max-power frequency
            Fp(nwin)=f(i); % store frequency of max-power frequency
        end
    end
     Fp(Pp<mean(Pp))=NaN;
     tFp=linspace(tmin,tmax,length(Fp));
     
     fscale=2;
     % visualize
     [ss,ff,tt,pp]=spectrogram(a,wsize,hop,wsize,fs); % spectrogram for background of images
%      [m,i]=(max(pp));
%      i(m<mean(m))=NaN;
%      plot(i)
     
     [fsize,tsize]=size(pp);
     pp=pp(1:floor(fsize/fscale),:);

     row=length(ws); col=2;
     n=n+1; subplot(row,col,n)
     imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),hold on % spectrogram
     set(gca(),'YDir','normal')
     plot(tFp,Fp,'k.-','linewidth',.5),title(['wsize = ' num2str(wsize/fs*1000) ' ms'])
     if n==1, title({'Prominent f0';  ['wsize = ' num2str(wsize/fs*1000) ' ms']}), end
% YIN
    % parameters
    p.minf0=f0min;
    p.maxf0=f0max;
    p.hop=floor(wsize/2);
    p.wsize=wsize;
    
    out=yin(afile,p);
    Fy=2.^out.f0.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    Fy=Fy(2:end-1); % there's an NaN at either end 
    tFy=linspace(tmin,tmax,length(Fy));
    
    % visualize
    
    row=length(ws); col=2;
    n=n+1; subplot(row,col,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),hold on % spectrogram
    set(gca(),'YDir','normal')
    plot(tFy,Fy,'k.-','linewidth',.5),title(['wsize = ' num2str(wsize/fs*1000) ' ms'])
    if n==2, title({'YIN';  ['wsize = ' num2str(wsize/fs*1000) ' ms']}),end
    
% YIN-bird
    



end
    clear sound, sound(a,fs)
   k=0;
   %k=waitforbuttonpress;
end
