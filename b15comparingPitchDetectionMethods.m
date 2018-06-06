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
f0min_Hz=40; % Hz; minimum frequency
f0max_Hz=8000; % Hz; maximum frequency


vis=1; % visualize?
k=1;
while k==1
for na=43 % number of the audio file (in the d data structure)
% LOAD AUDIO
    afile=[num2str(d(na).id) '.wav'];
    [a,fs]=audioread(afile); % read audio file as a waveform
    a=a(:,1); % take only one channel %%%%%%%%%%%%%% NOT SURE WHAT'S THE BEST WAY TO DO THIS - MEAN? SELECT ONE?
   
% PARAMETERS (SET ACCORDING TO FS)   
    wsize=round(fs*wsize_sec);
    hop=round(fs*hop_sec);
    zp=wsize+2*hop; % length of zero-padded window
    f=(fs*(0:(zp/2)-1)/zp)'; % frequency scale for the result of the FFT
    t=(1000*(0:wsize-1)/fs)'; % time scale for window (in miliseconds)
    [~,f0min]=min(abs(f-f0min_Hz)); % minimum of the f0 search range 
    [~,f0max]=min(abs(f-f0max_Hz)); % maximum of the f0 search range
    
    for nwin=500:floor(length(a)/hop)-1   %%% good windows 500:550
        beg=nwin*hop-hop+1; % beginning of the window
        win=a(beg:beg+wsize*1-1); % window of data for calculating pitch
        %win=[zeros(hop,1); win; zeros(hop,1)]; % zero-pad

% PROMINENT FREQUENCY 
        p2=abs(fft(win,zp)); % two-sided power spectrum for zero-padded window
        p1=p2(1:floor(length(p2)/2)); % single-sided power sepctrum
        if sum(p1)
            [Pp(nwin),i]=max(p1); % store power of max-power frequency
            Fp(nwin)=f(i); % store frequency of max-power frequency
        end

    tau=0; % lag
    for c=1:length(win) % counter
        x1=win(1:end-tau);% un-shifted signal, getting shorter
        x2=win(tau+1:end); % shifted signal

%         x1=[win(1:end-tau); zeros(c,1)]; % un-shifted signal, getting shorter
%         x2=[zeros(c,1); win(tau+1:end)]; % shifted signal
        
% 1) AUTOCORRELATION FUNCTION
        acf(c)=x1'*x2; 
        
% 2) DIFFERENCE FUNCTION
        df(c)=sum((x1-x2).^2);
        
% CUMULATIVE MEAN NORMALIZED DIFFERENCE FUNCTION     
        if tau==0, dfn(c)=1;
        else dfn(c)=df(c)/(mean(df(1:c))); 
        end
        
        tau=tau+1; % lag; shift the lag at the sampling rate (YIN p. 1929)
    end
    
% ABSOLUTE THRESHOLD
    dfnt=dfn;
    dfnt(dfnt>absThresh)=NaN;
    
% PARABOLIC INTERPOLATION
    
    % find dips
    [~,dips]=findpeaks(-dfnt);
    dip_dfnt=dips(1); % first below-threshold dip
    [~,dips]=findpeaks(-df);
    [~,closestDip]=min(abs(dips-dip_dfnt)); % find corresponding dip in df
    dip_df=dips(closestDip);
    x=df(i-Nneighbours:i+Nneighbours); % dip and its immediate neighbours
    
    
    
    

    
% LISTEN/VISUALIZE
if vis==1
    sound(win,fs)
    n=0;
    row=4;
    col=2;
    n=n+1;subplot(row,col,n),plot(t,win), title('window of waveform'),ylim([min(a) max(a)])
        xlabel('time (mms)')
        
    [~,i]=max(p1);
    n=n+1;subplot(row,col,n),plot(f,p1), title(['single-sided power spectrum from FFT (peak=' num2str(round(f(i))) ' Hz)']), ylim([0 100])
        xlabel('frequency (Hz)')
    n=n+1;subplot(row,col,n),plot(t,acf), title('1) autocorrelation function'), ylim([-100 100])
    n=n+1;subplot(row,col,n),plot(t,df),title('2) difference function'), ylim([0 200])
    n=n+1;subplot(row,col,n),plot(t,dfn), title('3) cumulative-mean-normalized difference function'), ylim([-1 4])
    n=n+1;subplot(row,col,n),plot(t,dfnt), title(['4) absolute-thresholded at ' num2str(absThresh)]),ylim([-.3 .3]),hold on
        plot(t,repmat(absThresh,1,length(df))),hold off

    k=0;
    k=waitforbuttonpress;
end
    end
     Fp(Pp<mean(Pp))=NaN;
end
end
sound(win,fs)
