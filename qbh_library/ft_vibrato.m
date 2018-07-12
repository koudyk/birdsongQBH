function [ featVect_vibrato, label, v_r, v_e, v_c, vibrato_presence] = ...
    ft_vibrato( pc,hop_a_samples,fs_a,...
    fsize_sec)
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
if nargin<4 || isempty(fsize_sec), fsize_sec=.35; end
if nargin<3 || isempty(fs_a), fs_a=44100; end
if nargin<2 || isempty(hop_a_samples), hop_a_samples=82; end

% CONCATENATE SEGMENTED PITCH CURVE
[~, pc_concat] = pc_segConcat(pc);

fs_pc = floor(fs_a/hop_a_samples); % sampling rate of the pitch curve
fsize = floor(fsize_sec*fs_pc); % frame size%
%fhop = floor(fsize*hop_pframe); % hop size for vibrato-calculation frames
fhop=1;
freqScale = fs_pc * (0:floor(fsize/2)) /floor(fsize);
minFreq=3; %Hz
maxFreq=15; %Hz
[~,i_minFreq] = min(abs(freqScale-minFreq));
[~,i_maxFreq] = min(abs(freqScale-maxFreq));
minPower = 1000;
Nframe = floor( (length(pc_concat)-(fsize-fhop)) / fhop); % total number of frames that fit into the pitch curve


v_r_perFrame = zeros(Nframe,1); % VIBRATO RATE per frame
v_e_perFrame = zeros(Nframe,1); % VIBRATO EXTENT per frame
v_c_perFrame = zeros(Nframe,1); % VIBRATO COVERAGE per frame

win = hanning(fsize); % hanning window

for nframe=1:Nframe
    beg = nframe * fhop - fhop + 1;
    frame = pc_concat(beg : beg+fsize-1);
    win = hanning(fsize); % hanning window
    frame = frame .* win'; 
   
    if ~isempty(frame)
        p2 = abs(fft(frame));
        p1 = p2(1:floor(length(p2)/2)+1);
        p1(p1<minPower)=0;
        
        [~, maxIndex] = max(p1);   
        if freqScale(maxIndex) > 0
            p1(1:i_minFreq)=0; % lower frequency limit for vibrato
            p1(i_maxFreq:end)=0;
            [maxValue, maxIndex] = max(p1); 
            v_r_perFrame(nframe) = freqScale(maxIndex);
            v_e_perFrame(nframe) = maxValue;
            v_c_perFrame(nframe) = 1;
        end      
        end  
        
% VISUALIZE THE FULL CURVE, THE CURRENT FRAME, AND THE FFT OF THE
% CURRENT FRAME 

%         clf
%         subplot(3,1,1),plot(pc)
%         hold on, plot(beg,pc(beg),'*'),hold on, plot(beg+fsize-1,pc(beg+fsize-1),'*')
%         subplot(3,1,2),plot(frame),title(sprintf('frame %d / %d',nframe,Nframe))
%         subplot(3,1,3),plot(freqScale,p1)
%         title(sprintf('%d Hz, %d power',freqScale(maxIndex), maxValue))
%         pause
        
end

%v_c=sum(v_e_perFrame>

v_r_perFrame(v_r_perFrame==0)=NaN; 
v_e_perFrame(v_e_perFrame==0)=NaN; 

if sum(v_c_perFrame)>0
    v_r = nanmean(v_r_perFrame); %  VIBRATO RATE MEAN
    v_rv = nanstd(v_r_perFrame); % VIBRATO RATE VARIATION
    v_e = nanmean(v_e_perFrame); %  VIBRATO EXTENT MEAN
    v_ev = nanstd(v_e_perFrame); % VIBRATO EXTENT VARIATION
    v_c = mean(v_c_perFrame); %  VIBRATO COVERAGE
    vibrato_presence = 1; % PRESENCE OF VIBRATO IN THE PITCH CURVE
else
    v_r = 0;
    v_rv = 0;
    v_e = 0;
    v_ev = 0;
    v_c = 0;
    vibrato_presence = 0;
end
featVect_vibrato = [v_r v_rv v_e v_ev v_c]';
label={'mean vibrato rate (Hz)','vibrato rate variation (Hz)',...
    'mean vibrato extent','vibrato extent variation',...
    'vibrato coverage (scale 0-1)'}';

end
%     %%
%     if ~isempty(frame)
%         p2 = abs(fft(frame));
%         frame = frame-mean(frame);
%         frame = frame .* win.'; % apply hanning window
% 
%         if ~isempty(p1>vthresh)
%             [maxValue, maxIndex] = max(p1);
%             v_r_perFrame(nframe) = freqScale(maxIndex);
%             v_e_perFrame(nframe) = maxValue;
%             v_c_perFrame(nframe) = 1;
%         end      
%         
% %         subplot(2,1,1),plot(frame)
% %         subplot(2,1,2),plot(freqScale,p1)
% %         title(freqScale(maxIndex))
% %         pause
%         
%     end
% end
% 
% if sum(v_c_perFrame)>0
%     v_r = mean(v_r_perFrame); % mean VIBRATO RATE
%     v_e = mean(v_e_perFrame); % mean VIBRATO EXTENT
%     v_c = mean(v_c_perFrame); % mean VIBRATO COVERAGE
%     vibrato_presence = 1; % PRESENCE OF VIBRATO IN THE PITCH CURVE
% else
%     v_r = 0;
%     v_e = 0;
%     v_c = 0;
%     vibrato_presence = 0;
% end
% featVect_vibrato = [v_r v_e v_c];
% 
% 
% end

