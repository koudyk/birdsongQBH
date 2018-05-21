


%% Pitch curve of birdsong and human imitationclc; clf
clc; clear; close all

cd('C:\Users\User\Documents\MATLAB\Projects\courseMIR\demo2\birdSounds')
q=audioread('cardinal_query_1.mp3'); aud(2).ca=q(:,1); clear q
e=audioread('cardinal_song_eg_2.mp3'); aud(1).ca=e(:,1); clear e
%%
fs=44100;
%wlen=floor(fs/44);
wlen=floor(fs/50);
hop=floor(wlen/2);
Ta=.1;
Tp=.3;
BPF=[0 8000];
mxjump=wlen/2;
width=.6;
height=.5;
figure('units','normalized','outerposition',[0 0 width height])
for n=1%1:length(aud)
    f0curve=pitchcurve(aud(n).ca,fs,wlen,hop,Ta,Tp,BPF,mxjump);
    %tscale=((1:length(f0curve))*hop)/fs;
    %plot(tscale,f0curve,'lineWidth',3),hold on
    plot(f0curve,'lineWidth',3),hold on
end
xlabel('Time')% (sec)')
ylabel('Frequency')% (Hz)')
%('Pitch curve of birdsong and human imitation')
%legend('Bird','Human imitation')
title('Pitch curve')
set(gca,'FontSize',30)
set(gca,'xtick',[],'ytick',[])
xlim([0 length(f0curve)])


%%




%%
clc; clearvars -except aud; close all
fs=44100;
%wlen=floor(fs/44);
wlen=floor(fs/50);
hop=floor(wlen/2);
Ta=.1;
Tp=.3;
BPF=[0 8000];
a=aud(2).ca;
a(abs(a/max(a))<Ta)=0; % threshold out low-amplitude sound (noise)

wlen0=wlen+2*hop; % window length when zero padded, for FFT
fscale=fs*(0:(wlen0/2))/wlen0; % frequency scale

for nwin=100%1:floor((length(a)-wlen)/hop)
    wbeg=floor((nwin-1)*hop+1);
    win=a( wbeg :  wbeg+wlen-1);
%         Y=fft(win,wlen0);
%         P2=abs(Y); % double-sided power spectrum
        P2=abs(fft(win,wlen0)); % double-sided frequency-power spectrum
        P1=P2(1:wlen0/2+1); % single-sided""
        
        nP1=P1/max(P1);% normalize power
%        f=find(nP1<athres); nP1(f)=0; % filter out low-amp frequencies
        P1(nP1<Tp)=0; % filter out low-power frequencies
%         P1(1:BPF(1)-1)=0; P1(BPF(2)+1:end)=0;

        [pks,locs]=findpeaks(P1);
        if ~isempty(pks)
            [~,i]=max(pks);            
            f0curve(nwin)=fscale(locs(i));
        else f0curve(nwin)=NaN; 
        end
%  clf,plot(fscale,P1),hold on
%  plot(fscale(locs(i)),60,'*')
end 

plot(fscale,nP1,'lineWidth',3)
xlabel('Frequency (Hz)')
ylabel('Power (normalized)')
title('Frequencies in 20-msec window')
set(gca,'FontSize',30)

tscale=((1:length(win))/fs)*1000;
figure,plot(tscale,win,'lineWidth',3)
xlabel('Time (msec)')
ylabel('Amplitude (normalized)')
title('20-msec window of birdsong')
set(gca,'FontSize',30)

tscale=((1:length(a))/fs);
figure,plot(tscale,a/max(a),'lineWidth',3)
xlabel('Time (sec)')
ylabel('Amplitude (normalized)')
title('20-msec window of birdsong')
ylim([-1 1])
xlim([1 length(a)/fs])
set(gca,'FontSize',30)
%%

clc; clearvars -except aud; close all
fs=44100;
%wlen=floor(fs/44);
wlen=floor(fs/50);
hop=floor(wlen/2);
Ta=.1;
Tp=.3;
BPF=[0 8000];
mxjump=wlen/2;
a=aud(1).ca;

a(abs(a/max(a))<Ta)=0; % threshold out low-amplitude sound (noise)

wlen0=wlen+2*hop; % window length when zero padded, for FFT
fscale=fs*(1:(wlen0/2+1))/wlen0; % frequency scale

for nwin=15%:floor((length(a)-wlen)/hop) % used 100 for human imitation
    wbeg=floor((nwin-1)*hop+1);
    win=a( wbeg :  wbeg+wlen-1);
%         Y=fft(win,wlen0);
%         P2=abs(Y); % double-sided power spectrum
        P2=abs(fft(win,wlen0)); % double-sided frequency-power spectrum
        P1=P2(1:wlen0/2+1); % single-sided""
        
        nP1=P1/max(P1);% normalize power
%        f=find(nP1<athres); nP1(f)=0; % filter out low-amp frequencies
        P1(nP1<Tp)=0; % filter out low-power frequencies
        P1(1:BPF(1)-1)=0;
        P1(BPF(2)+1:end)=0;

        [pks,locs]=findpeaks(P1);
        if ~isempty(pks)
            [~,i]=max(pks);            
            f0curve(nwin)=fscale(locs(i));
        else f0curve(nwin)=0; 
        end
        if nwin>2 ...
                && abs(f0curve(nwin)-f0curve(nwin-1))>mxjump ...
                && abs(f0curve(nwin-1)-f0curve(nwin-2))>mxjump
            f0curve(nwin-1)=0;
        end
end
f0curve(f0curve==0)=NaN;
width=.6;
height=.5;
figure('units','normalized','outerposition',[0 0 width height])
plot(fscale,nP1,'lineWidth',2)
xlabel('Frequency')% (Hz)')
ylabel('Power')
title('Frequencies in the 20-msec window')
set(gca,'FontSize',30)
set(gca,'xtick',[],'ytick',[])

tscale=((1:length(win))/fs)*1000;
figure('units','normalized','outerposition',[0 0 width height])
plot(tscale,win,'lineWidth',2)
xlabel('Time')% (msec)')
ylabel('Amplitude')
title('20-msec window of waveform')
set(gca,'FontSize',30)
ylim([-1 1])
set(gca,'xtick',[],'ytick',[])

fin=length(a);
tscale=((1:length(a))/fs);
figure('units','normalized','outerposition',[0 0 width height])
plot(tscale(1:fin),a(1:fin)/max(a),'lineWidth',2),hold on
xlabel('Time')% (sec)')
ylabel('Amplitude')
title('Birdsong audio waveform')
ylim([-1 1])
xlim([0 length(a)/fs])
set(gca,'FontSize',30)
set(gca,'xtick',[],'ytick',[])
plot(tscale(wbeg),0,'*',tscale(wbeg+wlen-1),0,'*')





