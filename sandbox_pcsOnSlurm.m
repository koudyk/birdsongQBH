clc;clear

% PITCH CURVE PARAMETERS
list_excerpts=dir('excerpts_audioExcerpts_species*'); % audio waveform excerpts
par.fs=44100;
par.wsize_sec = .02; 
par.hop_pwin = .1; % (proportion of the window size)
par.aperThresh = .2; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
par.ssize_sec = .068; % size of the segments in which to calculate the minimum frequency for YIN
par.fmin_hz = 30;
par.fmax_hz = 10000;

% FEATURE PARAMETERS
par.vsize_sec = .35; % window size for calculating vibrato
par.vminf_hz = 3;
par.vmaxf_hz = 15;


centsPerOctave = 1200;
Nspec=10;

% PITCH CURVE 
for nspec=1:Nspec
    disp('---------------------------------------')
    load(list_excerpts(nspec).name); % excerpts
    toDelete=[];
    Nexcerpt = length(excerpts); % number of Xeno-Canto IDs
    
    parfor nexcerpt = 1:Nexcerpt
        fprintf('\n spc %02d, excerpt %d / %d',nspec,nexcerpt,Nexcerpt)
        e = excerpts(nexcerpt).audio;
        pc = yb_yinbird(e,par) * centsPerOctave;
        if sum(~isnan(pc)) > 0 % if no pitch curve is exctracted
            excerpts(nexcerpt).pitchCurve_cents = pc;
        else toDelete = [toDelete nexcerpt];
        end
    end
    excerpts(toDelete)=[];
%     fileName = sprintf('excerpts_pitchCurves_species%02d',nspec);
%     save(fileName,'excerpts','par','-v7.3')
end
