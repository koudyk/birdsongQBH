function [ pitchCurve_oct,r,fig_yb,fig_ybVy ]  =  yb_yinbird( audio,par)
%	YB_YINBIRD calculates the pitch curve for birdsong, 
%   implementing YIN-bird (O'Reilley & Harte, 2017).	
%				
%	OUTPUTS (variable - (units) description)			
%	f0_yb     - (Hz) f-by-1 vector of fundamental-frequency 
%               values (f0) estimated with YIN-bird.
%	T         - (sec) t-by-1 vector of time values for the pitch curve.
%   r         - output structure of the YIN function.
%%%%%%%%%%%%%%%%%  DESCRIBE OUTPUTS IN r, take out T and f0_yb%%%%%%%%%%%%%%%%%%%%%%%%
%	fig       - outputs a figure with the pitch curve and the 
%               minimum-frequency curve overlayed over the spectrogram 
%               for the given file.
%				
%	INPUTS			
%	audio     -  audio file (in a format readable by the audioread 
%                funciton) or as a waveform (in which case you must 
%                input the sampling rate fs)
%	fs        -  (samples) sampling rate of the audio file
%   oct_or_hz -  enter 'octaves' to get pitch curves in octaves
%                relative to 440 Hz (A4).
%                Enter 'hz' to get pitch curves in frequency (Hz)
%	ssize_sec -  (sec) segments size. The pitch curve will for 
%                the audio within a given segment will be 
%                determined by YIN using the minimum-frequency 
%                determined as the minimum prominent frequency 
%                for that segment.
%	fmin_hz   -  (Hz) minimum of frequency range.
%	fmax_hz   -  (Hz) maximum of frequency range.
%	wsize_sec -  (sec) window size for calculating the frequency-power spectrum 
%	hop_pwin  -  (percent of window size) hop value.

if nargin<2, par.fs = 44100; end

if ischar(audio), [a,par.fs] = audioread(audio);
else a = audio;
end
a=mean(a,2);

if ~isfield(par,'fs'),         par.fs = 44100; end,         fs = par.fs;
if ~isfield(par,'wsize_sec'),  par.wsize_sec = .02; end,    wsize_sec = par.wsize_sec;
if ~isfield(par,'hop_pwin'),   par.hop_pwin = .1; end,      hop_pwin = par.hop_pwin;
if ~isfield(par,'aperThresh'), par.aperThresh = .1; end,    aperThresh = par.aperThresh;
if ~isfield(par,'ssize_sec'),  par.ssize_sec = .068; end,   ssize_sec = par.ssize_sec;
if ~isfield(par,'fmin_hz'),    par.fmin_hz = 30; end,       fmin_hz = par.fmin_hz;
if ~isfield(par,'fmax_hz'),    par.fmax_hz = .1; end,       fmax_hz = par.fmax_hz;
if isfield(par,'yinPar'),      p=par.yinPar; end

p.sr = fs;
p.maxf0 = fmax_hz;
wsize_samp = floor(fs*wsize_sec); p.wsize = wsize_samp;% samples; window size
hop_samp = floor(wsize_samp*hop_pwin); p.hop = hop_samp; % samples; hop
hop_sec = hop_samp/fs;
ssize_hop = floor((1/hop_sec)*ssize_sec);
fref_hz = 440; % Hz; reference frequency used by YIN to put the pitch curve in octaves

overlap_samp=wsize_samp-hop_samp;
[~,F,T,P] = spectrogram(a,wsize_samp,overlap_samp,[],fs);

% MINIMUM-FREQUENCY CURVE FOR YIN
[minf0_hop,minf0_seg,~,Fprom_hop]  =  yb_minf0( a,par );

% CALCULATE PITCH CURVE FOR EACH UNIQUE MINIMUM FREQUENCY
Uminf0 = unique(minf0_hop); % Hz; unique minimum frequencies
%f0s = zeros(length(Uminf0),length(minf0_hop));
for nUminf0 = 1:length(Uminf0) % number of unique min freq, i.e., number of times YIN must be run    
    p.minf0 = Uminf0(nUminf0); % Hz; set minumum frequency for  YIN
    r_temp = yin(audio,p);
    f0 = r_temp.f0;
    f0(r_temp.ap0 > aperThresh) = nan;
    f0s(nUminf0,:) = f0;
end

% PIECE TOGETHER FINAL PITCH CURVE USING THE PITCH CURVE THAT WAS GENERATED WITH THE SEGMENT'S MIN F0 
pitchCurve_oct = [];
Nseg = floor(length(minf0_hop)/ssize_hop); % total number of segments that fit into the prominent-frequency curve     
for nseg = 1:Nseg
    minf0 = minf0_seg(nseg);
    i_Uminf0 = find(Uminf0 == minf0); % index in unique min f0s of the current min f0 - for finding which f0 curve to use for this segment
    f0 = f0s(i_Uminf0,:); % pitch curve that was calculated with the desired min f0
    beg = nseg * ssize_hop - ssize_hop + 1;
    seg = f0(beg : beg + ssize_hop - 1);
    pitchCurve_oct = [pitchCurve_oct seg];
end
pitchCurve_oct(end:length(r_temp.f0)) = f0s(i_Uminf0,length(pitchCurve_oct:length(T))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment

%f0yb_hz = f0yb_hz(1:length(minf0_hop)); % there's an NaN at the end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%not sure why or if this is the right way to deal with it %%%%%%%%%%%%

% PLAIN YIN
p.minf0 = fmin_hz;    
r = yin_k(a,p);

% make yin and spectrogram output the same length
T = [nan T]; % add preceeding NaN (becasue it seems that there's always a NaN at the beginning of YIN's pitch curve)
minf0_hop = [nan minf0_hop];
Fprom_hop = [nan Fprom_hop'];

T(end+1:length(r.f0)) = NaN; % if needed, add trailing NaNs
minf0_hop(end+1:length(r.f0)) = NaN;
Fprom_hop(end+1:length(r.f0)) = NaN;

% ADD YINBIRD OUTPUTS TO YIN'S 'r' OUTPUT
r.f0yinbird = pitchCurve_oct;
r.timescale_sec = T;
r.minf0_hz = minf0_hop;
r.Fprom_hz = Fprom_hop;

% CONVERT OUTPUT TO FREQUENCY (HZ) INSTEAD OF OCTAVES
r.f0_hz  =  2.^ r.f0 .*fref_hz; 
r.f0yinbird_hz = 2.^ r.f0yinbird .*fref_hz;

if nargout >1 
    fmax_hz_plot = min([fmax_hz max(r.f0yinbird_hz)+1000]);
    fmin_hz_plot = max([fmin_hz min(r.f0yinbird_hz)-1000]);
    [~,fmax_i] = min(abs(F-fmax_hz_plot));
    [~,fmin_i] = min(abs(F-fmin_hz_plot));
    P = P(fmin_i:fmax_i,:);
end

if nargout==2 % plot YIN-bird pitch curve
    fig_yb=figure;
    imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
    set(gca(),'Ydir','normal')
    %hold on, plot(T,r.Fprom_hz,'g')
    hold on, plot(T,r.minf0_hz,'w')
    hold on, plot(T,r.f0yinbird_hz,'r-','linewidth',1.5)
    %legend('Prominent frequency curve','Minimum frequency for YIN','YIN-bird pitch estimate')
    legend('Minimum frequency for YIN','YIN-bird pitch estimate')
    title('YIN-bird') 
    ylabel('Frequency (Hz)'), xlabel('Time (sec)')
end

if nargout == 3 % plot yin and yin bird 
    fig_ybVy=figure; fig_yb=fig_ybVy;
    subplot(2,1,1)
    imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
    set(gca(),'Ydir','normal')

    yf0 = r.f0_hz;
    yf0(r_temp.ap0 > aperThresh) = nan;
    
    hold on, plot(T,yf0,'r-', 'linewidth',1.5)
    title('YIN')
    ylabel('Frequency (Hz)'), xlabel('Time (sec)')
    
    subplot(2,1,2);
    imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
    set(gca(),'Ydir','normal')
    hold on, plot(T,r.minf0_hz,'w')
    hold on, plot(T,r.f0yinbird_hz,'r-','linewidth',1.5)
    title('YIN-bird')
    ylabel('Frequency (Hz)'), xlabel('Time (sec)')
end
end




%%

% 
% if ischar(audio)
% [a,fs] = audioread(audio);
% else a = audio;
%     if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
% end
% a = mean(a,2); % take mean of the two channels if there are 2 
% if nargin<9|| isempty(hop_pwin), hop_pwin = .1; end % proportion of window size; hop factor
% if nargin<8 || isempty(wsize_sec), wsize_sec = .02; end % sec; window size
% if nargin<7 || isempty(fmax_hz), fmax_hz = 10000; end % Hz; max frequency
% if nargin<6 || isempty(fmin_hz), fmin_hz = 30; end % Hz; min frequency (recommended by YIN-bird (O'Reilley & Harte, 2017))
% if nargin<5 || isempty(ssize_sec), ssize_sec = .068; end % sec; segment size for dynamically setting the minimum f0 for YIN
% if nargin<3 || isempty(quality),quality=1; end % quality; 1='good', 2='best', 0=raw (including pitch estimates at times when the signal is deemed aperiodic)
% 
% p.sr = fs;
% wsize = floor(fs*wsize_sec); p.wsize = wsize;% samples; window size
% hop = floor(wsize*hop_pwin); p.hop = hop; % samples; hop
% hop_sec = hop/fs;
% ssize_hop = floor((1/hop_sec)*ssize_sec);
% Nwin = floor( (length(a)-(wsize-hop))/hop); % number of windows that fit into the audio
% fref = 440; % Hz; reference frequency used by YIN to put the pitch curve in octaves
% 
%     overlap=wsize-hop;
%     [~,F,T,P] = spectrogram(a,wsize,overlap,[],fs);
% 
% % MINIMUM-FREQUENCY CURVE FOR YIN
% [minf0_hop,minf0_seg,T_minf0_seg,Fprom_hop]  =  yb_minf0( a,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  );
% 
% % CALCULATE PITCH CURVE FOR EACH UNIQUE MINIMUM FREQUENCY
% Uminf0 = unique(minf0_hop); % Hz; unique minimum frequencies
% %f0s = zeros(length(Uminf0),length(minf0_hop));
% for nUminf0 = 1:length(Uminf0) % number of unique min freq, i.e., number of times YIN must be run    
%     p.minf0 = Uminf0(nUminf0); % Hz; set minumum frequency for  YIN
%     r_temp = yin_k(audio,p);
%     
%     % select pitch curve according to desired level of masking
%     if     quality == 1, f0s(nUminf0,:) = r_temp.f0good;
%     elseif quality == 2, f0s(nUminf0,:) = r_temp.f0best;
%     elseif quality == 0, f0s(nUminf0,:) = r_temp.f0;
%     end
% end
% 
% 
% % PIECE TOGETHER FINAL PITCH CURVE USING THE PITCH CURVE THAT WAS GENERATED WITH THE SEGMENT'S MIN F0 
% f0yb_oct = [];
% Nseg = floor(length(minf0_hop)/ssize_hop); % total number of segments that fit into the prominent-frequency curve     
% for nseg = 1:Nseg
%     minf0 = minf0_seg(nseg);
%     i_Uminf0 = find(Uminf0 == minf0); % index in unique min f0s of the current min f0 - for finding which f0 curve to use for this segment
%     f0 = f0s(i_Uminf0,:); % pitch curve that was calculated with the desired min f0
%     beg = nseg * ssize_hop - ssize_hop + 1;
%     seg = f0(beg : beg + ssize_hop - 1);
%     f0yb_oct = [f0yb_oct seg];
% end
% f0yb_oct(end:length(r_temp.f0)) = f0s(i_Uminf0,length(f0yb_oct:length(T))); % use the minimum f0 from the last full segment to calculate the pitch curve for the portion of the file that doesn't fill a segment
% 
% %f0yb_hz = f0yb_hz(1:length(minf0_hop)); % there's an NaN at the end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%not sure why or if this is the right way to deal with it %%%%%%%%%%%%
% 
% % PLAIN YIN
% p.minf0 = fmin_hz;    
% r = yin_k(a,p);
% 
% % make yin and spectrogram output the same length
% T = [nan T]; % add preceeding NaN (becasue it seems that there's always a NaN at the beginning of YIN's pitch curve)
% minf0_hop = [nan minf0_hop];
% Fprom_hop = [nan Fprom_hop'];
% 
% T(end+1:length(r.f0)) = NaN; % if needed, add trailing NaNs
% minf0_hop(end+1:length(r.f0)) = NaN;
% Fprom_hop(end+1:length(r.f0)) = NaN;
% 
% % ADD YINBIRD OUTPUTS TO YIN'S 'r' OUTPUT
% r.f0yinbird = f0yb_oct;
% r.timescale_sec = T;
% r.minf0_hz = minf0_hop;
% r.Fprom_hz = Fprom_hop;
% 
% % CONVERT OUTPUT TO FREQUENCY (HZ) INSTEAD OF OCTAVES
% r.f0_hz  =  2.^ r.f0 .*fref; 
% r.f0best_hz = 2.^ r.f0best .*fref;
% r.f0good_hz = 2.^ r.f0good .*fref;
% r.f0yinbird_hz = 2.^ r.f0yinbird .*fref;
% 
% if nargout >1 
%     fmax_hz_plot = min([fmax_hz max(r.f0yinbird_hz)+1000]);
%     fmin_hz_plot = max([fmin_hz min(r.f0yinbird_hz)-1000]);
%     [~,fmax_i] = min(abs(F-fmax_hz_plot));
%     [~,fmin_i] = min(abs(F-fmin_hz_plot));
%     P = P(fmin_i:fmax_i,:);
% end
% 
% if nargout==2 % plot YIN-bird pitch curve
%     fig_yb=figure;
%     imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
%     set(gca(),'Ydir','normal')
%     %hold on, plot(T,r.Fprom_hz,'g')
%     hold on, plot(T,r.minf0_hz,'w')
%     hold on, plot(T,r.f0yinbird_hz,'r-','linewidth',1.5)
%     %legend('Prominent frequency curve','Minimum frequency for YIN','YIN-bird pitch estimate')
%     legend('Minimum frequency for YIN','YIN-bird pitch estimate')
%     title('YIN-bird') 
%     ylabel('Frequency (Hz)'), xlabel('Time (sec)')
% end
% 
% if nargout == 3 % plot yin and yin bird 
%     fig_ybVy=figure; fig_yb=fig_ybVy;
%     subplot(2,1,1)
%     imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
%     set(gca(),'Ydir','normal')
%     % select pitch curve according to desired level of masking
%     if     quality == 1, yf0 = r.f0good_hz;
%     elseif quality == 2, yf0 = r.f0best_hz;
%     elseif quality == 0, yf0 = r.f0_hz;
%     end
%     hold on, plot(T,yf0,'r-', 'linewidth',1.5)
%     title('YIN')
%     ylabel('Frequency (Hz)'), xlabel('Time (sec)')
%     
%     subplot(2,1,2);
%     imagesc([0 max(T)],[fmin_hz_plot,fmax_hz_plot],10*log10(P));
%     set(gca(),'Ydir','normal')
%     hold on, plot(T,r.minf0_hz,'w')
%     hold on, plot(T,r.f0yinbird_hz,'r-','linewidth',1.5)
%     title('YIN-bird')
%     ylabel('Frequency (Hz)'), xlabel('Time (sec)')
% end
% end