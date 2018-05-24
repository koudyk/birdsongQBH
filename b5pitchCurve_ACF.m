clc;clear;close all
cd C:\Users\User\Documents\MATLAB\Projects\birdsongQBH
a=audioread('samef0_difftimbres.wav'); fs=8000;
%a=audioread('doReMe.wav'); fs=44100;
%a=audioread('00000_44k.mp3'); fs=44100;
sound(a,fs)

% PREPROCESSING
Wpp=fs*.1; % window length for preprocessing (last number is the length in seconds)
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
Wpc=fs*1; % window length for pitch-curve estimation
Hpc=round(Wpc*.1); % hop factor for pitch-curve estimation
a=[zeros(Hpc-Hpp,1); a; zeros(Hpc-Hpp,1)]; % zero-pad signal
Lpc=floor(length(a)/Hpc); % length of pitch curve (i.e., number of windows)
Tpow=.5; % power threshold (for eliminating frequency peaks resulting from noise)

t=(0:Hpc:((Lpc*Hpc)-2*Hpc))/fs; % time scale
f=fs*(0:((Wpc*3)/2))/(Wpc*3); % frequency scale
figs=0; if figs==1, Nfig=3;  end % visualize pitch calculation?
  
for nwin=1:Lpc-1 % 23 is a good example window
    n=0;
    win=a(nwin*Hpc:nwin*Hpc+Hpc); % given window of audio
    if ~sum(win)==0
    win=[zeros(Wpc,1);win;zeros(Wpc,1)]; % zero pad the signal for autocorrelation
% autocorrelation
        acf=xcorr(win); 
        pause(.1)
% FFT of ACF
        p2=abs(fft(acf));
        p2=p2/max(p2); % set power between 0 and 1
        p2(p2<Tpow)=0; % threshold power (eliminate frequency peaks resulting from noise)
        if ~sum(nwin)==0
            [m, locs]=max(p2);
            %if ~isempty(pks)
                pc(nwin)=locs(1);
            %else,pc(nwin)=NaN;
            %end
        else pc(nwin)=NaN;
        end
                                            % visualize
                                                    if figs==1; clf
                                                        subplot(Nfig,1,1),plot(win),title(num2str(nwin))
                                                        subplot(Nfig,1,2),plot(acf)
                                                        subplot(Nfig,1,3),plot(p2),hold on, plot(locs(1),m(1),'*'), pause(.2) 
                                                    end
    else pc(nwin)=NaN;
    end
end

close all
%pc=pc(Wpc/Hpc:end-1);
plot(pc,'.-')
%plot(t,pc)

