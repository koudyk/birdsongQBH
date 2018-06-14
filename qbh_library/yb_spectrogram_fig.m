function [ fig_sg ] = yb_spectrogram_fig(P,F,T)
% YB_SPECTROGRAM_FIG creates a figure out of the ouputs of the
% YB_SPECTROGRAM funciton
%				
%	OUTPUTS			
%	fig_sg    - spectrogram figure		
%				
%	INPUTS (variable - (units) description)			
%	P         - (dB)f-by-t matrix of decibels, where f is the frequency 
%               bins and t is the time bins.
%	F         - (Hz) f-by-1 vector of frequency values corresponding 
%               to each frequency bin in P.
%	T         - (sec) t-by-1 vector of time values corresponding 
%               to each time bin in P.
%	NOTE: these inputs are outputs of YB_SPECTROGRAM			
    fig_sg=imagesc([T(1) T(end)],[F(1) F(end)],P);
    set(gca(),'Ydir','normal')
    xlabel('Time (sec)'), ylabel('Frequency (Hz)')

end

