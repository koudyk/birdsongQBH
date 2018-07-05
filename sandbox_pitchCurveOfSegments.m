%clc,clear%,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)
list_segs=dir('clean*');
Nspec=length(list_segs);

fs=44100; p.sr=fs;
quality=2;
ssize_sec=.068;
fmin_hz=30; 
fmax_hz=10000; p.maxf0=fmax_hz;
wsize_sec=.01;
hop_pwin=.1;


%%

clear f0

for nspec=1:Nspec
    fprintf('--------------- nspec = %d ---------------\n',nspec)
    load(list_segs(nspec).name) % segments for given species
    for nXC=1%:length(audio_segs)
        xc=xcID(nXC);
        for nseg=1%:length(audio_segs{nXC})
            seg=audio_segs{nXC}{nseg};
            [r]=yb_yinbird( seg,fs,p,quality, ssize_sec,fmin_hz,fmax_hz,wsize_sec,hop_pwin );
            f0{nspec}=r.f0yinbird_hz;

        end
    end
end
f0_all_best=f0;
save('PITCHCURVES_test_onePerSpecies','f0_all_best','f0_all_good')
%%

load 'PITCHCURVES_test_onePerSpecies'
fs=44100;
maxGap_sec=.05;
minLength_sec=.01;
wsize = floor(fs*wsize_sec);
hop = floor(wsize*hop_pwin);
maxGap_hop = floor(maxGap_sec*fs/hop);
minLength_hop = floor(minLength_sec*fs / hop);



figure
for nspec=1:Nspec
f0=f0_all_best{nspec};
notNan=find(~isnan(f0)); % indexes of elements of the pitch curve that are not NaN
dif=[notNan 0]-[0 notNan];

i_begs=find(dif>maxGap_hop); % notNan indexes of beginnings of segments
begs=notNan(i_begs);  % pitch curve indexes of beginnings of segments

i_fins=i_begs(2:end)-1; % notNan indexes of ends of segments
fins=notNan(i_fins); % pitch curve indexes of ends of segments
fins(end+1)=abs(dif(end));

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

end

