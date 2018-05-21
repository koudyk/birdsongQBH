clc;clear;close all
cd C:\Users\User\Documents\MATLAB\Projects\birdsongQBH

a=audioread('samef0_difftimbres.wav');
fs=8000;
%sound(a,fs)

% PREPROCESSING
Wpp=fs*.25; % window length for preprocessing (last number is the length in seconds)
Hpp=round(Wpp*.1); % hop factor for preprocessing(last number is the percentage of the window length that is the hop factor)
Tamp=.1; % amplitude threshold to get rid of noise

a=a/max(abs(a)); % set amplitude between -1 and 1
a=[zeros(Hpp,1); a; zeros(Hpp,1)]; % zero-pad signal
for nwin=1:floor(length(a)/Hpp)-1
    if max(abs(a(nwin*Hpp:nwin*Hpp+Hpp)))<Tamp % if there is no sound above the amplitude threshold (i.e., if it's prbably only noise in that window)
        a(nwin*Hpp:nwin*Hpp+Hpp)=0; % then set all values in that window to 0
    end
end

% PITCH ESTIMATION
Wpc=fs*.5;
Hpc=round(Wpc*.1);
a=[zeros(Hpc-Hpp,1); a; zeros(Hpc-Hpp,1)]; % zero-pad signal
Lpc=floor(length(a)/Hpc); % length of pitch curve (i.e., number of windows)
Tpow=.3;

for nwin=23%1:Lpc-1 % 23 is a good example window
    win=a(nwin*Hpc:nwin*Hpc+Hpc); % given window of audio
    win=[zeros(Hpc,1);win;zeros(Hpc,1)]; % zero pad signal for autocorrelation

% autocorrelation
    acf=xcorr(win); 
    subplot(2,1,1),plot(acf)
% FFT of ACF
    p2=abs(fft(acf));
    p2=p2/max(p2); % set power between 0 and 1
    p2(p2>Tpow)=0; % threshold power
    [pk loc]=findpeaks
    subplot(2,1,2),plot(p2)
    
    
    
    

end

