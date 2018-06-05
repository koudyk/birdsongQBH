clc;clear;close all
clear sound
% visualizations
pe_yin=1;
pe_me=0;
visWin=0; if visWin==1, Nfig=3;  end % visualize pitch calculation?

% audio file
 
cd('F:\0.birdsongQBH\audio\spc1_northern_cardinal')
list=dir('*.wav');
%=randi(length(list),1);
n=94;
file=list(n).name
[a, fs]=audioread(list(n).name);
a=mean(a,2);

% parameters
% wsize_pp=fs*3; % window length for preprocessing (last number is the length in seconds)
% hop_pp=round(wsize_pp*.01); % hop factor for preprocessing(last number is the percentage of the window length that is the hop factor)
% Tamp=.3; % amplitude threshold to get rid of noise
Tpow=.0005;
wsize=round(fs*.01);
hop=round(wsize*.1);
fref=440;

% PREPROCESSING
% a=a/max(abs(a)); % set amplitude between -1 and 1
% a=[zeros(wsize_pp,1); a; zeros(wsize_pp,1)]; % zero-pad signal
% a0=a;
% for nwin=1:floor(length(a)/hop_pp)-wsize_pp/hop_pp
%     if max(abs(a(nwin*hop_pp:nwin*hop_pp+wsize_pp)))<Tamp % if there is no sound above the amplitude threshold (i.e., if it's prbably only noise in that window)
%         a(nwin*hop_pp:nwin*hop_pp+wsize_pp)=0; % then set all values in that window to 0
%     end
% end
%a=a0.*(abs(a)>0);
%a(a==0)=NaN;
%Nplot=3; nplot=1;
%subplot(Nplot,1,nplot),plot(a)%,hold on, plot(a)
%title('waveform')
%title(['waveform preprocessing, with amp> ' num2str(Tamp) ', win=' num2str(wsize_pp/fs) ' sec, hop=' num2str(hop_pp/fs) 'sec'])
%legend('before pp','after pp')

% PITCH ESTIMATION
%nplot=nplot+1; subplot(Nplot,1,nplot),spectrogram(a,wsize,hop,wsize,fs,'yaxis'),colorbar('off')
%audiowrite('temp.wav',a,fs);
p.wsize=wsize;
p.hop=hop;
out=yin(file,p);

% POST PROCESSING

f0=out.f0 .* (out.pwr>Tpow); % mask out locations in the pitch curve where there is low periodicity
f0(f0==0)=NaN;
f0=2.^f0 * fref /1000; % frequency in kHz
hold on, plot(f0)
    
subplot(2,1,1),spectrogram(a,wsize,hop,wsize,fs,'yaxis'),colorbar('off')
subplot(2,1,2),plot(f0)
%    nplot=nplot+1; subplot(Nplot,1,nplot),plot(f0)
%    title(['YIN pitch curve, win=' num2str(wsize/fs) ' sec; hop=' num2str(hop/fs)])


% if pe_me==1
%     Lpc=floor(length(a)/hop); % length of pitch curve (i.e., number of windows)
%     Tpow=.5; % power threshold (for eliminating frequency peaks resulting from noise)
%     Frange=[20 4000];
% %     t=(0:hop:((Lpc*hop)-2*hop))/fs; % time scale
% %     f=fs*(0:((wsize*3)/2))/(wsize*3); % frequency scale
%     for nwin=1:Lpc-1
%         %disp(['win ' num2str(nwin) '/' num2str(Lpc-1)])
%         n=0;
%         win=a(nwin*hop:nwin*hop+hop); % given window of audio
%         if ~sum(win)==0
%         win=[zeros(wsize,1);win;zeros(wsize,1)]; % zero pad the signal for autocorrelation
%     
%             acf=xcorr(win);  % autocorrelation
%     
%             p2=abs(fft(acf)); % FFT of ACF
%             p1=p2(1:floor(length(p2)/2)); % single-sided power spectrum
%             p1=p1/max(p1); % set power between 0 and 1
%             p1(p1<Tpow)=0; % threshold power (eliminate frequency peaks resulting from noise)
%             p1(1:Frange(1))=0; p1(Frange(2):end)=0;
%                 [pks, pkLocs]=findpeaks(p1);
%             if ~isempty(pks)
%                 if sum(f0)==0
%                     f0(nwin)=pkLocs(1);
%                 else
%                     [~,closePkLoc]=min(abs(pkLocs-f0(nwin-1))); % index of frequency that is closest to the current frequency
%                     f0(nwin)=pkLocs(closePkLoc);
%                 end
%                 
%             else f0(nwin)=NaN;
%             end
%                                                     % visualize each window
%                                                     if visWin==1; clf
%                                                         subplot(Nfig,1,1),plot(win),title(num2str(nwin))
%                                                         subplot(Nfig,1,2),plot(acf)
%                                                         if ~sum(p1)==0
%                                                             subplot(Nfig,1,3),plot(p1),hold on, plot(pkLocs(closePkLoc),pks(closePkLoc),'*'), pause(.2) 
%                                                         end
%                                                         pause(.3)
%                                                     end
%             clear pks pkLocs closePkLoc
% 
%         else f0(nwin)=NaN;
%         end
%     end
% fref=440;
% nplot=nplot+1; subplot(Nplot,1,nplot),plot(log2(f0/fref),'.'), title(['pitch curve, with win=' num2str(wsize/fs) ' sec; hop=' num2str(hop/fs)])
% 
% end
sound(a,fs)





