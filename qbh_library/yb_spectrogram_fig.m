function [ fig_sg ] = yb_spectrogram_fig(P,F,T)
% YB_SPECTROGRAM_FIG creates a figure out of the ouputs of the
% YB_SPECTROGRAM funciton


    
    fig_sg=imagesc([T(1) T(end)],[F(1) F(end)],P);
    set(gca(),'Ydir','normal')
    xlabel('Time (sec)'), ylabel('Frequency (Hz)')

end

