clc,clear,close all
spec=1:10;
for n=1:length(spec)
    nspec=spec(n);

fileName=sprintf('pitchCurves_concatenatedSegments_cents_spc%02d_NXC-Nexcerpt.mat',nspec);
load(fileName)


%pc = pitchCurves_filled{1}{1};
NxcID=length(pitchCurves_concat);
NxcID = 1;
for nxcID=1:NxcID
    pc = pitchCurves_concat{nxcID}{1};
    vthresh=0;
    hop_samples=82;
    fs_a=44100;
    fsize_sec=.35;
    hop_pframe=.1;
    fv = ft_vibrato( pc,hop_samples,fs_a, fsize_sec);
    subplot(ceil(length(spec)/2),2,n)
    plot(pc)
    fv(end)=fv(end)*100;
    fv=round(fv);
    title(sprintf('r=%d, rv=%d, e=%d, re=%d, c=%d',fv(1),fv(2),fv(3),fv(4),fv(5)))
end
    

end

% %load('pitchCurves_concatenatedSegments_cents_spc06_NXC-Nexcerpt.mat')
% %signal = pitchCurves_concat{1}{1};
% 
% freq=2;
% amp=.6;
% len=3; 
% fs=1000;
% hop=100;
% fs_pc = floor(fs/hop); % sampling rate of the pitch curve
% 
% time=0:1/fs_pc:len-1/fs_pc;
% 
% Nplot=2;
% 
% fsize_sec = .5;
% hop_pframe = .1;
% pc=amp*sin(2*pi*time*freq);
% pc=pc+ .2*randn(size(pc));
% %signal=signal+sin(2*pi*time);
% %subplot(Nplot,1,1),plot(time,signal),title(sprintf('freq = %d Hz',freq))
% %fv = ft_vibrato(signal,0,hop,fs,fsize_sec,hop_pframe)
