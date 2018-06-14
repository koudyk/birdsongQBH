function [ minf0_hop, minf0_seg,T_minf0_seg,Fprom_hop] = yb_minf0( audio,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  )
%	YB_MINF0 calculates the minimum-frequency curve for dynamically 
%   setting the minimum frequency of YIN in YIN-bird.			
%				
%	OUTPUTS (variable - (units) description)			
%	minf0_hop  - (hops, i.e., spectrogram time values)	
%                f-by-1 vector of minimum frequencies 
%   minf0_seg  - (segments) s-by-1 vector of minimum frequencies 
%   T_minf0_seg- (sec) s-by-1 vector of time values corresponding to
%                 segments.
%	Fprom_hop  - (hops, i.e., spectrogram time values) 	
%                f-by-1 vector of prominent frequencies 
%                (i.e., the maximum frequency for each window, 
%                with maximum frequencies set to NaN if they 
%                are below the mean maximum frequency across time). 
%				
%	INPUTS			
%	audio     -  audio file (in a format readable by the audioread 
%                funciton) or as a waveform (in which case you must 
%                input the sampling rate fs)
%	fs        - (samples) sampling rate of the audio file
%	ssize_sec - (sec) segments size. The pitch curve will for 
%                the audio within a given segment will be 
%                determined by YIN using the minimum-frequency 
%                determined as the minimum prominent frequency 
%                for that segment.
%	fmin_hz   - (Hz) minimum of frequency range.
%	fmax_hz   - (Hz) maximum of frequency range.
%	wsize_sec - (sec) window size for calculating the frequency-power spectrum 
%	hop_pwin  - (percent of window size) hop value.


    if ischar(audio)
    [a,fs]=audioread(audio);
    else a=audio;
        if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
    end
    a=mean(a,2); % take mean of the two channels if there are 2 
    if nargin<7 || isempty(hop_pwin), hop_pwin=.5; end % proportion of window size; hop factor
    if nargin<6 || isempty(wsize_sec), wsize_sec=.01; end % sec; window size
    if nargin<5 || isempty(fmax_hz), fmax_hz=fs/2; end % Hz; max frequency
    if nargin<4 || isempty(fmin_hz), fmin_hz=30; end % Hz; min frequency (recommended by YIN-bird (O'Reilley & Harte, 2017))
    if nargin<3 || isempty(ssize_sec), ssize_sec=.068; end % sec; segment size for dynamically setting the minimum f0 for YIN
    
% PROMINENT-FREQUENCY CURVE
    [Psp,Fsp,Tsp]=yb_spectrogram(audio,fs,fmin_hz,fmax_hz,wsize_sec,hop_pwin );
    hop_sec=Tsp(2)-Tsp(1); % sec; spectrogram hop size (i.e., seconds to one time value in spectrogram)
    %hop_samples=floor(hop_sec*fs); % audio samples; spectrogram hop size (i.e., audio samples to one time value in spectrogram)
    fs_sp=1/hop_sec;
    [Pprom,i]=nanmax(Psp);
    Fprom_hop=Fsp(i);
    Pprom(Pprom<0)=NaN;
    Fprom_hop(Pprom<(nanmean(Pprom)))=NaN;  

% MINIMUM PROMINENT FREQUENCY FOR EACH SEGMENT
    ssize=floor(fs_sp*ssize_sec); % hops (i.e, spectrogram time points); segment size
    Nseg=floor(length(Fprom_hop)/ssize); % total number of segments that fit into the prominent-frequency curve     
    for nseg=1:Nseg
        beg=nseg*ssize-ssize+1;
        seg=Fprom_hop(beg:beg+ssize-1);
        if nansum(seg)>0
             minf0_seg(nseg)=nanmin(seg);
        else minf0_seg(nseg)=0;
        end
        T_minf0_seg(nseg)=beg;
    end
    minf0_seg=floor(minf0_seg/100)*100; % round to nearest 100 Hz
    minf0_seg=minf0_seg-5; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    minf0_seg(minf0_seg<0)=0;
    
% SET SEGEMENTS WITHOUT A FPROM CURVE TO THE VALUE OF THE NEAREST-NEIGHBOURING SEGMENT (PREFERRING LEFT) 
    nonZero=find(minf0_seg>0);
    for nseg=1:Nseg
        if minf0_seg(nseg)==0;
            dif=abs(nonZero-nseg);
            [~,nn]=min(dif); % nearest neighbour
            minf0_seg(nseg)=minf0_seg(nonZero(nn));
        end
    end 
    minf0_hop=repelem(minf0_seg,ssize);
    minf0_hop(end:length(Tsp))=minf0_hop(end);
        
end

