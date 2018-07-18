clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

list_excerpt=dir('excerpts_audioExcerpts_struct*');
Nspec=length(list_excerpt);

fs=44100; p.sr=fs;
quality=2;
ssize_sec=.068;
fmin_hz=30; 
fmax_hz=10000; p.maxf0=fmax_hz;
wsize_sec=.02;
wsize_samples=wsize_sec*fs;
hop_pwin=.1;
centsPerOctave = 1200;

for nspec=1:Nspec % species
    fprintf('\n--------------- nspec = %d ---------------\n',nspec)
    clear pitchCurves 
    load(list_excerpt(nspec).name) % segments for given species. Incl. variables audio_segs and xcID
    
    NXC=length(xcID); % number of xeno-canto recordings
    for nXC=1:NXC % Xeno-Canto file
        fprintf('\n spec %d, XC ID %d / %d',nspec,nXC,NXC)
        
        Nexcerpt=length(audio_excerpts{nXC});
        for nexcerpt=1:Nexcerpt % clean excerpt in the XC file
            excerpt=audio_excerpts{nXC}{nexcerpt};
            
            if length(excerpt)>wsize_samples % the audio excerpt must be longer than the window size for calculating the pitch curve
                r = yb_yinbird( excerpt,fs,p,quality, ssize_sec,...
                    fmin_hz,fmax_hz,wsize_sec,hop_pwin );
                pc=r.f0yinbird*centsPerOctave; % pitch curve converted to cents
                
                pitchCurves1{nXC}{nexcerpt} = pc;
                
                if sum(~isnan(pc))>0 
                    pitchCurves{nXC}{nexcerpt} = pc;
                else fprintf('empty pitch curve in excerpt %d / %d',nexcerpt,Nexcerpt)
                end
            end
        end

    end
    toDelete = find(cellfun('isempty',pitchCurves));
    pitchCurves(toDelete)=[];
    xcID(toDelete)=[];
    
    speciesFile=sprintf('pitchCurves_excerpts_cents_spc%02d_NXC-Nexcerpt',nspec);
    save(speciesFile,'pitchCurves','nspec','xcID','wsize_sec','ssize_sec',...
        'hop_pwin','fs','fmin_hz','fmax_hz','-v7.3')
    
end
