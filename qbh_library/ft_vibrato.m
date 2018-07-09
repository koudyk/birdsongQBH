function [ featVect_vibrato, v_r, v_e, v_c, vibrato_presence] = ...
    ft_vibrato( pc,vthresh,hop_samples,fs_a,...
    fsize_sec, hop_pframe)
% ft_vibrato - calculates the vibrato-related features of a pitch
% curve, as listed in:
%
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
%   Musical genre classification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%
% INPUTS
% pitchCurve_cents - (cents) pitch curve i.g., a T-by-1 vector of
%       pitch values over time
% vthresh - (???) threshold on the extent of vibrato that indicates
%       whether/not the frame contains vibrato. 
% hop_samples - (audio samples) hop size used in calculating the 
%       pitch curve.
%
% OUTPUTS
% featVect_vibrato - vector of features relating to vibrato,
%       including the following features in this order, which can
%       also be individual outputs:
%       - v_r - (Hz) vibrato rate (mean over frames)
%       - v_e - (???) vibrato extent (mean over frames)
%       - v_c - (scale of 0-1) vibrato coverge (i.e., ratio of frames
%               with vibrato to the total number of frames)
% vibrato_presence - (boolean) indicates whether the segment contains
%       vibrato (1) or not (0)

%hop_sec = hop_samples/fs_a; 

fs_pc = floor(fs_a/hop_samples); % sampling rate of the pitch curve
fsize = floor(fsize_sec*fs_pc); % frame size
%fsize_zp = 2^nextpow2(fsize); % zero-padded frame size
fhop = floor(fsize*hop_pframe); % hop size for vibrato-calculation frames
%freqScale=(fs_pc*(0 : fsize_zp/2 -1)/fsize_zp)';
freqScale = fs_pc* (0:floor(fsize/2))/floor(fsize);
freqScale = freqScale * fs_a/hop_samples; % to get the frequency values back into the original timing
Nframe = floor( (length(pc)-(fsize-fhop)) / fhop); % total number of frames that fit into the pitch curve

v_r_perFrame = zeros(Nframe,1); % VIBRATO RATE per frame
v_e_perFrame = zeros(Nframe,1); % VIBRATO EXTENT per frame
v_c_perFrame = zeros(Nframe,1); % VIBRATO COVERAGE per frame


for nframe=1:Nframe
    beg = nframe * fhop - fhop + 1;
    frame = pc(beg : beg+fsize-1);
    win = hanning(fsize); % hanning window
    frame = frame .* win'; 
    
    if ~isempty(frame)
        p2 = abs(fft(frame));
        p1 = p2(1:floor(length(p2)/2)+1);
        %p1=p1/(sum(p1.^2));
        %p1(1:2)=0;

        if ~isempty(p1>vthresh)
            [maxValue, maxIndex] = max(p1);
            v_r_perFrame(nframe) = freqScale(maxIndex);
            v_e_perFrame(nframe) = maxValue;
            v_c_perFrame(nframe) = 1;
        end      
        
%         subplot(2,1,1),plot(frame)
%         subplot(2,1,2),plot(freqScale,p1)
%         title(freqScale(maxIndex))
%         pause
        
    end
end

if sum(v_c_perFrame)>0
    v_r = mean(v_r_perFrame); % mean VIBRATO RATE
    v_e = mean(v_e_perFrame); % mean VIBRATO EXTENT
    v_c = mean(v_c_perFrame); % mean VIBRATO COVERAGE
    vibrato_presence = 1; % PRESENCE OF VIBRATO IN THE PITCH CURVE
else
    v_r = 0;
    v_e = 0;
    v_c = 0;
    vibrato_presence = 0;
end
featVect_vibrato = [v_r v_e v_c];


end

