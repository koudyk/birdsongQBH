clc,clear,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

load('STIMULI_test_NspecByNrec.mat') % stimuli variable
load('QUERIES_test_NspecByNrec.mat') % queries variable

fs=44100; p.sr=fs;
quality=2;
ssize_sec=.068;
fmin_hz=30; 
fmax_hz=10000; p.maxf0=fmax_hz;
wsize_sec=.01;
hop_pwin=.1;
Nspec=10;
Nrec=10;

%%

clear f0

for nspec=1:Nspec
    fprintf('--------------- nspec = %d ---------------\n',nspec)
    for nrec=1:10
        query=queries{nspec,nrec}; % segments for given species
        [r]=yb_yinbird( query,fs,p,quality, ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin );
        f0_q{nspec,nrec}=r.f0yinbird;
        
        stimulus=stimuli{nspec,nrec}; % segments for given species
        [r]=yb_yinbird( stimulus,fs,p,quality, ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin );
        f0_s{nspec,nrec}=r.f0yinbird;
    end
end
save('PITCHCURVES_test_stimuliAndQueries','f0_q','f0_s')
%%
fs=44100;
maxGap_sec=.01;
minLength_sec=.01;
wsize = floor(fs*wsize_sec);
hop = floor(wsize*hop_pwin);
maxGap_hop = floor(maxGap_sec*fs/hop);
minLength_hop = floor(minLength_sec*fs / hop);

for stim_quer=1:2
    if stim_quer==1, 
        f0s=f0_s;
        s_q='stimulus';
    else f0s = f0_q;
        s_q='query';
    end
    nrec=2;
    figure
    for nspec=1:Nspec
        f0=f0s{nspec,nrec};
        notNan=find(~isnan(f0)); % indexes of elements of the pitch curve that are not NaN
        if ~isempty(notNan)
            gaps=[notNan 0]-[0 notNan];

            % DEFINE SEGMENTS AS PIECES SEPARATED BY LONG ENOUGH GAPS
            % IN TIME
            i_bigGapsFins=find(gaps>maxGap_hop); % notNan indexes of the ends of gaps
            begs=notNan(i_bigGapsFins);  % pitch curve indexes of beginnings of segments
            
%             % FIND TOO-BIG LEAPS IN FREQUENCY
%             freqDiff = [f0 0]-[0 f0];
%             i_bigLeaps = 

            i_bigGapBegs=i_bigGapsFins(2:end)-1; % notNan indexes of the beginnings of gaps
            fins=notNan(i_bigGapBegs); % pitch curve indexes of ends of segments
            fins(end+1)=abs(gaps(end));

            i_tooShort=find((fins-begs)<minLength_hop);
            begs(i_tooShort)=[];
            fins(i_tooShort)=[];

            subplot(5,2,nspec)
            plot(f0)
            hold on, plot(begs,f0(begs),'*')
            hold on, plot(fins,f0(fins),'*')
            if nspec==1,
                legend('pitch curve','segment beginnings','segment ends'),
                title(sprintf('min length = %d ms; max gap = %d ms',minLength_sec*1000,maxGap_sec*1000))
            end
            if nspec==2,title(s_q),end
        end

    end
end

%%
nrec=2;
for n=1:10
    s=stimuli{n,nrec};
    sound(s,fs)
    pause(length(s)/fs)
    
    q=queries{n,nrec};
    sound(q,fs)
    pause(length(q)/fs)
end
%%



pitchCurve=f0s{1,4};
maxGap_sec = .05;
minLength_sec = .05;
wsize_sec = .01;
hop_pwin = .1;
fs = 44100;
[ segments,fig ] = segmentPitchCurve( pitchCurve,maxGap_sec,minLength_sec,wsize_sec,hop_pwin,fs );
