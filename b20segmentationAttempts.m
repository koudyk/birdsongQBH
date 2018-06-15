

clc,clear,%close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

% PARAMETERS
wsize_sp_sec=.01;
hop_sp_p=.5;
ssize=.068;
minf0=200; p.minf0=minf0;
maxf0=8000; p.maxf0=maxf0;
quality=2;
wsize_ispc_sec=.5; % (sec) length of consecutive empty numbers that qualifies as not part of a phrase
hop_ispc_p=.2; % (proportion of wsize) 

% SELECT AUDIO
ns=2;

cd(exhard)
list_s=dir('spc*');
cd([exhard '\' list_s(ns).name])
list_a=dir('*.wav'); % short audio files 
NA=1:5;%length(list_a)-3:length(list_a);
Ncol=1; % number of colums in subplot
Nsec=20;

% cd(laptop)
% list_a=dir('short*.wav');
c=0;
figure
for na=NA
    audio=list_a(na).name;
    [a,fs_a]=audioread(audio);
    if length(a)>Nsec*fs_a % if it's longer than Nsec seconds
        a=audioread(audio,[1, Nsec*fs_a]);
    end
    p.sr=fs_a;
    [f0{na},t{na}]=yb_yinbird(a,fs_a,quality,p,ssize,minf0,maxf0,wsize_sp_sec,hop_sp_p);
    clc

wsize_sp_samp=floor(fs_a * wsize_sp_sec); % samples; window size
hop_sp_samp=floor(wsize_sp_samp * hop_sp_p); % samples; hop
fs_f=hop_sp_samp; % sampling rate of spectrogram and YIN pitch curve

c=c+1;
f=f0{na};
wsize=floor(wsize_ispc_sec*fs_f); % (samples)
hop=floor(wsize*hop_ispc_p);
Nwin=floor( (length(f)-(wsize-hop))/hop);% number of windows that fit into the pitch curve  
ispc_win=zeros(Nwin,1); % is pitch curve - boolean
for nwin=1:Nwin
    beg=nwin*hop-hop+1;
    fin=beg+wsize-1;
    win=f(beg:fin);
    if nansum(win)>0 % there is  pitch curve in the window
        ispc_win(nwin)=1;
    end
    wtime(nwin,:)=[beg fin];
end
% end of recording that doesn't fit into a window - set it to previous
% value
ispc=repelem(ispc_win,hop); % in hops

if ispc(fin-(wsize-hop))==1,
    ispc(end:length(f))=1;
else ispc(end:length(f))=0;
end

subplot(ceil(length(NA)/Ncol),Ncol,c)
[P,F,T]=yb_spectrogram(a,fs_a);
yb_spectrogram_fig(P,F,T);
hold on
plot(t{na},f,'linewidth',2),hold on
plot(t{na},ispc*max(f)+1000,'linewidth',2)

end
    






