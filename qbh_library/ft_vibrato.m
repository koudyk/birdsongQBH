function [ featVect_vibrato, vibrato_presence] = ft_vibrato( pitchCurve,vthresh,wsize_sec,hop_pwin,fsize_sec,hop_pframe,fs_a)
% ft_vibrato
    wsize = floor(wsize_sec*fs_a); % window size for calculating the pitch curve
    hop=floor(wsize*hop_pwin); % hop for calculating the pitch curve
    hop_sec = hop/fs; 
    fs_pc = hop/hop_sec; % sampling rate of the pitch curve
    fsize = floor(fsize_sec*fs_pc); % frame size
    fsize_zp = 2^nextpow2(fsize); % zero-padded frame size
    fhop = floor(fsize*hop_pframe); % hop size for vibrato-calculation frames
    freqScale=(fs_pc*(0 : fsize_zp/2 -1)/fsize_zp)';
    Nframe = floor( (length(pitchCurve)-(fsize-fhop)) / fhop); % total number of frames that fit into the pitch curve
    
    v_r_perFrame = zeros(Nframe,1); % VIBRATO RATE per frame
    v_e_perFrame = zeros(Nframe,1); % VIBRATO EXTENT per frame
    v_c_perFrame = zeros(Nframe,1); % VIBRATO COVERAGE per frame
   
    
    for nframe=1:Nframe
        beg = nframe * fhop - fhop + 1;
        frame = pitchCurve(beg : beg+fsize-1);
        if ~isempty(frame)
            p2 = abs(fft(frame,fsize_zp));
            p1 = p2(1:floor(length(p2)/2));
            
            if ~isempty(p1>vthresh)
                [maxValue, maxIndex] = max(p1);
                v_r_perFrame(nframe) = freqScale(maxIndex);
                v_e_perFrame(nframe) = maxValue;
                v_c_perFrame(nframe) = 1;
            end      
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

