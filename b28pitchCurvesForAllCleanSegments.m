clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

list_clean=dir('clean*');
Nspec=length(list_clean);

fs=44100; p.sr=fs;
quality=2;
ssize_sec=.068;
fmin_hz=30; 
fmax_hz=10000; p.maxf0=fmax_hz;
wsize_sec=.02;
wsize_samples=wsize_sec*fs;
hop_pwin=.1;
%%
tooShort=[];
for nspec=5:Nspec % species
    fprintf('\n--------------- nspec = %d ---------------\n',nspec)
    load(list_clean(nspec).name) % segments for given species. Incl. variables audio_segs and xcID
    
    NXC=length(audio_segs); % number of xeno-canto recordings
    for nXC=1:NXC % Xeno-Canto file
        fprintf('\n XC ID %d / %d',nXC,NXC)
        xc=xcID(nXC);
        
        Nclean=length(audio_segs{nXC});
        for nclean=1:Nclean % clean chunk in the XC file
            clean=audio_segs{nXC}{nclean};
            if length(clean)>wsize_samples % the audio excerpt must be longer than the window size for calculating the pitch curve
                [r]=yb_yinbird( clean,fs,p,quality, ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin );
                pitchCurves{nXC}{nclean}=r.f0yinbird_hz;
            else tooShort = [tooShort xc];
                fprintf('\n********TOO SHORT XC, nXC %d, %d nclean %d *********',xc,nXC,nclean)
            end
        end
    end
    speciesFile=sprintf('pitchCurves_spc%02d_NXC-Nclean',nspec);
    save(speciesFile,'pitchCurves','xcID','wsize_sec','ssize_sec',...
        'hop_pwin','fs','fmin_hz','fmax_hz','tooShort','-v7.3')
    
end
