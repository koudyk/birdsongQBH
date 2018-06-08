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
cu_hz=8000; % Hz; lower cutoff for band-pass
cl_hz=200; % Hz; upper cutoff for band-pass
fref=440; % reference frequency used by YIN to put the pitch curve in octaves
len_sec=3; % sec; length of audio to work with

ws=[.0068];% .01 .02]; % sec; window sizes to try
for na=43%find([d.id]==id)%43 % number of the audio file (in the d data structure)
n=0; 
for nws=1:length(ws) 
    wsize_sec=ws(nws);
    
    clear Pp Fp 
% LOAD AUDIO
    afile=[num2str(d(na).id) '.wav'];
    %afile='short_northernCardinal.wav';
    %afile='short_veery.wav';
    %afile='short_mourningDove.wav';
    [a,fs]=audioread(afile); % read audio file as a waveform
    a=mean(a,2); %take mean of the two channels if there are 2

    
% CONSIDER SHORTER PART OF AUDIO?
    a=a(1:len_sec*fs);
    audiowrite('temp.wav',a,fs)
    afile='temp.wav';
    
% PARAMETERS (SET ACCORDING TO FS)   
    wsize=floor(fs*wsize_sec);
    hop=floor(wsize/2);
    zp=floor(wsize*1.5); % length of zero-padded window
    f=(fs*(0:(zp/2)-1)/zp)'; % Hz; frequency scale for the result of the FFT
    t=(1000*(0:wsize-1)/fs)'; % ms; time scale for window
    fmin=0; fmax=fs/2;
    tmin=0; tmax=length(a)/fs; 
    
    % frequency filter
    [~,cu]=min(abs(f-cu_hz)); % upper cut-off for band-pass frequency filter
    [~,cl]=min(abs(f-cl_hz)); % lower cut-off for band-pass frequency filter
    filt=ones(length(f),1);
    filt(1:cl)=0; filt(cu:end)=0;

% PROMINENT FREQUENCY     
    for nwin=1:floor(length(a)/hop)-1   %%% good windows 500:550
        beg=nwin*hop-hop+1; % beginning of the window
        win=a(beg:beg+wsize-1); % window of data for calculating pitch
        %win=[zeros(hop,1); win; zeros(hop,1)]; % zero-pad
        p2=abs(fft(win,zp)); % two-sided power spectrum for zero-padded window
        p1=p2(1:floor(length(p2)/2)); % single-sided power sepctrum
        p1=p1.*filt; % set too-low and too-high frequencies to 0
        if sum(p1)>0
            [Pp(nwin),nn]=max(p1); % store power of max-power frequency
            Fp(nwin)=f(nn); % store frequency of max-power frequency
        end
    end
     Fp(Pp<(mean(Pp)))=NaN; % keep only those prominent frequencies above the mean prominent frequency
     tFp=linspace(tmin,tmax,length(Fp)); % time axis for frequency values

% YIN
    p.minf0=cl_hz;
    p.maxf0=cu_hz;
    p.wsize=wsize;
    p.hop=floor(p.wsize/2);
    
    out=yin(afile,p);
    Fy=2.^out.f0.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    Fy=Fy(2:end-1); % there's an NaN at either end 
    tFy=linspace(tmin,tmax,length(Fy));

% YIN-BIRD
    % FIND THE MINIMUM PROMINENT FREQUENCY FOR EACH TIME SEGMENT
    ssize_sec=.15; % sec; segment size
    ssize=floor(ssize_sec*fs/hop);
    Nseg=floor(length(Fp)/ssize);
    for nseg=1:Nseg;
        beg=nseg*ssize-ssize+1; 
        seg=Fp(beg:beg+ssize-1);
        if nansum(seg)>0 % if the segment contains a pitch curve
             minFp(nseg)=nanmin(seg);
        else minFp(nseg)=0;
        end
    end
    
    % FOR EMPTY SEGMENTS, DESIGNATE THE MIN FREQ AS THE NEAREST
    % NEIGHBOUR (PREFERRING THE PREVIOUS IF EQUIDISTANT TO LEFT AND
    % RIGHT)
    nonZero=find(minFp>0); % indexes of all segments that have a min freq, for finding the nearest neighbour to those without a min freq  
    for nseg=1:Nseg
        if minFp(nseg)==0 % if the segment is empty, start looking for the nearest neighbour to the left and right
            dif=abs(nonZero-nseg);
            [~,nn]=min(dif); % nearest neighbour, prefering the left if equidistant
            minFp(nseg)=minFp(nonZero(nn));
        end
    end
    minFp=minFp-5;
    
    minFp_hop=repelem(minFp,ssize); % repeat the minimum frequencies to fill the entire segment of the pitch curve
    minFp_hop(end:end+length(Fp)-length(minFp_hop))=minFp_hop(end); % the end of the recording likely won't fit exactly into a window, so designate the min frequency of this last part as the min of the last window
    tminFp_hop=linspace(tmin,tmax,length(minFp_hop)); % time axis for minFp_hop
    
    % USE YIN IN EACH SEGMENT, WITH THE DESIGNATED MINIMUM FREQUENCY    
    Fyb=[];
    for nseg=1:Nseg-1
        p.minf0=minFp(nseg);
        beg=nseg*ssize-ssize+1;
        out=yin(afile,p);
        seg=out.f0(beg:beg+ssize-1);
        Fyb=[Fyb seg]; 
    end
    temp=Fyb;
    Fyb=2.^Fyb.*fref; % convert YIN's pitch curve from octaves relative to 440 Hz to Hz. 
    Fyb=Fyb(2:end-1); % there's an NaN at either end 
    tFyb=linspace(tmin,tmax,length(Fyb));
    
% VISUALIZE

    % SPECTROGRAM
    fscale=2;
    [ss,ff,tt,pp]=spectrogram(a,wsize,hop,wsize,fs); % spectrogram for backgfloor of images
    [fsize,tsize]=size(pp);
    pp=pp(1:floor(fsize/fscale),:);
     
    % PROMINENT F0
    row=length(ws); col=3;
    n=n+1; subplot(row,col,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),set(gca(),'YDir','normal'),hold on
    plot(tFp,Fp,'k.-','linewidth',.5),title(['wsize=' num2str(wsize/fs*1000) 'ms, hop=' num2str(hop/fs*1000) 'ms'])
    hold on, plot(tFp,minFp_hop,'r','linewidth',1),
    if n==1, title({'Prominent f0';  ['wsize=' num2str(wsize/fs*1000) 'ms, hop=' num2str(hop/fs*1000) 'ms']}), end
    
    % YIN
    n=n+1; subplot(row,col,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),set(gca(),'YDir','normal'),hold on
    plot(tFy,Fy,'k.-','linewidth',.5),title(['wsize=' num2str(wsize/fs*1000) 'ms, hop=' num2str(hop/fs*1000) 'ms'])
    hold on, plot(tFp,minFp_hop,'r','linewidth',1),
    if n==2, title({'YIN';  ['wsize=' num2str(wsize/fs*1000) ' ms, hop=' num2str(hop/fs*1000) 'ms']}),end

    % YIN-BIRD
    n=n+1; subplot(row,col,n)
    imagesc([tmin tmax], [fmin fmax/fscale], 10*log10(pp)),set(gca(),'YDir','normal'),hold on
    plot(tFyb,Fyb,'k.-','linewidth',.5),title(['wsize=' num2str(wsize/fs*1000) 'ms, hop=' num2str(hop/fs*1000) 'ms'])
    hold on, plot(tFp,minFp_hop,'r','linewidth',1), %legend('YIN-estimated pitch curve','YIB-bird minimum frequency for YIN')
    if n==3, title({'YIN-bird';  ['wsize=' num2str(wsize/fs*1000) ' ms, hop=' num2str(hop/fs*1000) 'ms']}),end
end
   % clear sound, sound(a,fs)
   k=0;
   %k=waitforbuttonpress;
end
% plot(tFp,Fp),hold on, plot(tFp,minFp_hop),
% xlabel('time (sec)'),ylabel('frequency (Hz)')
% legend('F_p_r_o_m','minimum F_p_r_o_m for the given segment')
% title('YIN-bird: dynamically determining the minimum frequency for YIN')

%%

    % STEP 1: calculate prominent-frequency curve, with values less
    % than the mean prominent frequency set to NaN 
    % (done above, stored in 'Fp')
    
    % STEP 2: segment and determine minimum f0 in each segment.
    % They suggest basing the segment size on the size of the  bird 
    % corpus (i.e., based on execution time).
    % Looks like they used a segment size of 3000 frames or maybe
    % they divided the entire clip into 30 segments.
    % If the segment is empty of prominent frequencies over the mean
    % Fp, then the min for that segment is set as the nearest
    % neighbour, with precedence given to the previous neighbour when
    % neighbours are equally close. 
    
    %%
    
%                 if r<length(mm), if mm(r)==0, r=r+1; end, end
%             if l>0, if mm(l)==0, l=l-1; end, end
    %%
% clc;close all
% ssize=floor(fs*0.068); % segment size; corresponds to 3000 frames for 44.1 kHz fs
%     for nseg=1:(length(Fp)/ssize)
%         beg=nseg*ssize-ssize+1;
%         win=Fp(beg:beg+wsize-1);
%         disp(length(win))
%     end


%% % finding the prominent-frequency curve using the spectrogram
%      [m,i]=(max(pp)); 
%      i(m<mean(m))=NaN;
%      for m=1:length(i)
%          if ~isnan(i(m))
%             Fp_s(m)=f(i(m));
%          else Fp_s(m)=NaN;
%          end
%      end
%      tFp=linspace(tmin,tmax,length(i));

%%
%     for nseg=1:floor(length(Fp)/ssize)
%         if minFp(nseg)==0 % if the segment is empty, start looking for the nearest neighbour to the left and right
%             r=nseg; l=nseg;
%             if and(r<length(minFp),minFp(r)==0), r=r+1; end % nearest neighbour to the right
%             if and(l>1,minFp(l)==0), l=l-1; end % nearest neighbour to the left
% 
%             if r-nseg < nseg-l, nn=r; % the neighbour to the RIGHT is nearer
%             elseif r-nseg < nseg-l, nn=l; %  the neighbour to the LEFT is nearer
%             else nn=l;  % they're both equally near, therefore, use the one to the left
%             end
%             minFp(nseg)=minFp(nn);
%         end
%     end
%     minFp_hop=repelem(minFp,ssize); % repeat the minimum frequencies to fill the entire segment of the pitch curve
%     minFp_hop(end:end+length(Fp)+1-length(minFp_hop))=minFp_hop(end); % the end of the recording likely won't fit exactly into a window, so designate the min frequency of this last part as the min of the last window
% 
