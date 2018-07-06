function [ segments,fig ] = segmentPitchCurve( pitchCurve,maxGap_sec,minLength_sec,wsize_sec,hop_pwin,fs )
% segmentPitchCurve - segments a pitch curve based on two parameters:
% 1) a maximum allowable gap between pieces of the pitch curve, and 
% 2) a minimum allowable length for a piece to be considered a pitch
% curve.
%
% INPUTS
% pitchCurve - pitch curve (could be in octaves or Hz - it doesn't
%       make a difference).
% maxGap_sec - (sec) maximum allowable gap between pieces of the 
%       pitch curve before they are separated into different segments.
% minLength_sec - (sec) mimimum length of a segment for it to be
%       kept in the set of segments.
% wsize_sec - (sec) window size that was used for calculating the
%       pitch curve.
% hop_pwin - (proportion of window) hop size that was used for 
%       calculating the pitch curve.
% fs - (samples/sec) sampling frequency of audio
%
% OUTPUTS
% segments - segments of the pitch curve (in same pitch units as the
%       input pitchCurve, i.e., octaves or Hz).


    f0=pitchCurve;
    if isempty(f0)
        disp('Error: no pitch curve detected')
    end
%     fs=44100;
%     maxGap_sec=.05;
%     minLength_sec=.01;
    wsize = floor(fs*wsize_sec);
    hop = floor(wsize*hop_pwin);
    maxGap_hop = floor(maxGap_sec*fs/hop);
    minLength_hop = floor(minLength_sec*fs / hop);

    notNan=find(~isnan(f0)); % indexes of elements of the pitch curve that are not NaN
    gaps=[notNan 0]-[0 notNan];
    
% SEGMENT PITCH CURVE AT LARGE ENOUGH GAPS IN TIME
    i_bigGapsFins=find(gaps>maxGap_hop); % notNan indexes of the ends of gaps (i.e., beginning of segments)
    begs=notNan(i_bigGapsFins);  % pitch curve indexes of beginnings of segments

    i_bigGapBegs=i_bigGapsFins(2:end)-1; % notNan indexes of the beginnings of gaps
    fins=notNan(i_bigGapBegs); % pitch curve indexes of ends of segments
    fins(end+1)=abs(gaps(end));

% JOIN PITCH CURVES THAT ARE TOO SHORT
    i_tooShort=find((fins-begs)<minLength_hop);
    begs(i_tooShort)=[];
    fins(i_tooShort)=[];
    
    Nseg=length(begs);
    segments=cell(Nseg,1);
    
    for nseg=1:Nseg
        segments{nseg}=f0(begs(nseg) : fins(nseg));
    end
    
    if nargout==2, % if they want a figure
        fig=figure; 
        for nseg=1:Nseg
            subplot(ceil(Nseg/2),2,nseg)
            plot(segments{nseg})
        end
    end

end

