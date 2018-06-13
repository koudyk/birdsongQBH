clc;clear;%close all; clear sound
addpath(genpath('F:\0.birdsongQBH\audio'))
load('b8_output_audioData_withAonly.mat')
d=recDetA; % structure with data information; recDet for recordings of quality A and B; recDetA for recordings of quality A only. 

% PARAMETERS
maxf0=8000; % Hz; upper frequency cutoff for band-pass
minf0=200; % Hz; lower frequency cutoff for band-pass
fref=440; % Hz; reference frequency used by YIN to put the pitch curve in octaves
len_sec=3; % sec; length of audio to work with
wsize_fprom_sec=.01; % sec; window size for calculating the prominent freuqncies
wsize_yin_sec=.025; % sec; window size for YIN
ssize_yinbird_sec=.15; % sec; segment size for setting the minimum f0 for YIN-bird
n=0;
%ws=.01; % sec; window size(s) to try
plotRow=3; plotCol=3;

aa{1}='short_northernCardinal.wav';
aa{2}='short_veery.wav';
aa{3}='short_mourningDove.wav';
aa{4}=[num2str(d(1).id) '.wav'];

for na=1%:3
    clear Pp Fp minFp Fy Fyp 
    p.maxf0=maxf0;
    p.minf0=minf0;
%% LOAD AUDIO
    afile=aa{na};
    [a,fs]=audioread(afile); % read audio file as a waveform
    a=mean(a,2); %take mean of the two channels if there are 2
    
% CONSIDER SHORTER PART OF AUDIO?
%     a=a(1:len_sec*fs);
%     audiowrite('temp.wav',a,fs)
%     afile='temp.wav';
%     
%% SET PARAMETERS ACCORDING TO SAMPLING RATE
    wsize=floor(fs*wsize_fprom_sec); % window size for FFT 
    hop=floor(wsize/2); % overlap
    Nwin=floor(length(a)/hop)-1; % number of windows that fit in the signal
    zp=floor(wsize*1.5); % length of zero-padded window for calculating FFT
    f=(fs*(0:zp/2-1)/zp)'; % Hz; frequency scale
    tmin=0; tmax=length(a)/fs;
    
    % frequency filter    
    fmin=0; fmax=fs/2;
    [~,cu]=min(abs(f-maxf0)); % upper cut-off for band-pass frequency filter
    [~,cl]=min(abs(f-minf0)); % lower cut-off for band-pass frequency filter
    filt=ones(length(f),1);
    filt(1:cl)=0; filt(cu:end)=0;
    
    % for YIN
    p.wsize=floor(fs*wsize_yin_sec);
    p.hop=hop*2;
    
    % for YIN-bird
    ssize=floor(ssize_yinbird_sec*fs/hop);
    Nseg=floor(Nwin/ssize);
    
    % for visualizing
    fscale=2; % for down-scaling the frequency window of the spectrogram (bc don't need to see very high frequencies)
    
%% PROMINENT FREQUENCY
    for nwin=1:Nwin
        beg=nwin*hop-hop+1; % beginning of window
        win=a(beg:beg+wsize-1); % window of waveform for calculating prominent frequency
        p2=abs(fft(win,zp)); % 2-sided power spectrum
        p1=p2(1:floor(length(p2)/2)); % single-sided poser spectrum
        p1=p1.*filt; % set too-low and too-high frequencies to 0;
        if sum(p1)>0
            [Pp(nwin),i]=max(p1); % store power of max-power frequency
            Fp(nwin)=f(i); % store frequency of max-power frequency
        end
    end
    Fp(Pp<(mean(Pp)))=NaN; % set prominent frequencies below the mean prominent freuency to NaN
    tFp=linspace(tmin,tmax,length(Fp)); % time scale
    
%% YIN
    out=yin_k(afile,p); % run YIN
    Fy=2.^out.good.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    Fy=Fy(1:length(Fp)); % the last numbers always seem to be a NaN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tFy=linspace(tmin,tmax,length(Fy)); % time scale
        
%% YIN-BIRD
    for nseg=1:Nseg
        beg=nseg*ssize-ssize+1;
        seg=Fp(beg:beg+ssize-1);
        if nansum(seg)>0
            minFp(nseg)=nanmin(seg);
        else minFp(nseg)=0;
        end
    end
    
    Fyb=[];
    
    nonZero=find(minFp>0); 
    for nseg=1:Nseg
        if minFp(nseg)==0
            dif=abs(nonZero-nseg);
            [~,nn]=min(dif);
            minFp(nseg)=minFp(nonZero(nn))-2; % set minimum frequency; subtract 2 to account for discretization of frequency
        end
        p.minf0=minFp(nseg); % set minimum frequency to min prominent freq
        out=yin_k(afile,p); % use YIN
        beg=nseg*ssize-ssize+1;
        seg=out.good(beg:beg+ssize-1);
        Fyb=[Fyb seg];
    end
    Fyb(end:length(Fp))=out.good(length(Fyb:length(Fp))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment
    Fyb=2.^Fyb.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    Fyb=Fyb(1:length(Fp)); % there's an NaN at either end 
    tFyb=linspace(tmin,tmax,length(Fyb));

%% VISUALIZE

    % SPECTROGRAM
    fscale=2;
    [ss,ff,tt,pp]=spectrogram(a,wsize,hop,wsize,fs); % spectrogram for backgfloor of images
    [fsize,tsize]=size(pp);
    pp=pp(1:floor(fsize/fscale),:);
    
    % MINIMUM PROMINENT FREQUENCY
    minFp_hop=repelem(minFp,ssize); % hops; repeat the minimum frequencies to fill the entire segment of the pitch curve
    minFp_hop(end:end+length(Fp)-length(minFp_hop))=minFp_hop(end); % the end of the recording likely won't fit exactly into a window, so designate the min frequency of this last part as the min of the last window
    tminFp_hop=linspace(tmin,tmax,length(minFp_hop)); % time axis for minFp_hop
     
    % PROMINENT F0
    n=n+1; subplot(plotRow,plotCol,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),set(gca(),'YDir','normal'),hold on
    plot(tFp,Fp,'k.-','linewidth',.5),title(['wsize=' num2str(wsize/fs*1000) 'ms, hop=' num2str(hop/fs*1000) 'ms'])
    hold on, plot(tFp,minFp_hop,'r','linewidth',1),
    if n==1, title({'Prominent f0';  ['wsize=' num2str(wsize/fs*1000) 'ms, hop=' num2str(hop/fs*1000) 'ms']}), end
    
    % YIN
    n=n+1; subplot(plotRow,plotCol,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),set(gca(),'YDir','normal'),hold on
    plot(tFy,Fy,'k.-','linewidth',.5),title(['wsize=' num2str(p.wsize/fs*1000) 'ms, hop=' num2str(p.hop/fs*1000) 'ms'])
    hold on, plot(tFp,minFp_hop,'r','linewidth',1),
    if n==2, title({'YIN';  ['wsize=' num2str(p.wsize/fs*1000) ' ms, hop=' num2str(p.hop/fs*1000) 'ms']}),end

    % YIN-BIRD
    n=n+1; subplot(plotRow,plotCol,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),set(gca(),'YDir','normal'),hold on
    plot(tFyb,Fyb,'k.-','linewidth',.5),title(['wsize=' num2str(p.wsize/fs*1000) 'ms, hop=' num2str(p.hop/fs*1000) 'ms'])
    hold on, plot(tFp,minFp_hop,'r','linewidth',1), %legend('YIN-estimated pitch curve','YIB-bird minimum frequency for YIN')
    if n==3, title({'YIN-bird';  ['wsize=' num2str(p.wsize/fs*1000) ' ms, hop=' num2str(p.hop/fs*1000) 'ms']}),end
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    