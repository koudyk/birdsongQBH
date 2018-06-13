function [ minf0_hop, minf0_seg,T_minf0_seg, Fprom] = yb_minf0( audio,fs,ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin  )
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
    %hop_sp_sec=Tsp(2)-Tsp(1); % sec; hop of the spectrogram 
    fs_sp=floor(1/(Tsp(2)-Tsp(1))); % hops/sec; time sampling rate for the spectrogram
    [Pprom,i]=nanmax(Psp);
    Fprom=Fsp(i);
    Pprom(Pprom<0)=NaN;
    Fprom(Pprom<(nanmean(Pprom)))=NaN;  

% MINIMUM PROMINENT FREQUENCY FOR EACH SEGMENT
    ssize=floor(fs_sp*ssize_sec); % hops (i.e, spectrogram time points); segment size
    Nseg=floor(length(Fprom)/ssize); % total number of segments that fit into the prominent-frequency curve     
    for nseg=1:Nseg
        beg=nseg*ssize-ssize+1;
        seg=Fprom(beg:beg+ssize-1);
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

