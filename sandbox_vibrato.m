clc,clear,close all
%load('pitchCurves_concatenatedSegments_cents_spc06_NXC-Nexcerpt.mat')
%signal = pitchCurves_concat{1}{1};

freq=8;
amp=.6;
len=3; 
hop=100;
time=0:1/hop:len;
fs=1000;
Nplot=2;

fsize_sec = 10;
hop_pframe = .5;
signal=amp*sin(2*pi*time*freq);
signal=signal+ .2*randn(size(signal));
%signal=signal+sin(2*pi*time);
%subplot(Nplot,1,1),plot(time,signal),title(sprintf('freq = %d Hz',freq))
%fv = ft_vibrato(signal,0,hop,fs,fsize_sec,hop_pframe)

%clc,clear,close all
load('pitchCurves_concatenatedSegments_cents_spc06_NXC-Nexcerpt.mat')
signal = pitchCurves_concat{1}{1};
fv = ft_vibrato(signal,0,82,44100,2,.1)