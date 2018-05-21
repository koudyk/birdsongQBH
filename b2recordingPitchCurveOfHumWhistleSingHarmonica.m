clc; clear; close all
recObj=audiorecorder;

sec=5;
disp('Start.')
recordblocking(recObj, sec);
disp('End of Recording.');

play(recObj)
data=getaudiodata(recObj);

%%

fs=8000;
audiowrite('f0curve_whistle.wav',data,fs)

%% DO-RE-MI-RE-DO MELODIES (starting on middle C)

clc; clear; clf%close all

list=dir('f0curve*.wav');
fs=8000;
wlen=floor(fs/5);
hop=1;
Ta=.4;
Tp=.5;
BPF=[0 8000];
mxjump=500;

for n=1%:length(list)
    a(n).name=list(n).name(9:end-4);
    a(n).a=audioread(list(n).name);
    a(n).pcurve=pitchcurve(a(n).a,fs,wlen,hop,Ta,Tp,BPF,mxjump);
    plot(a(n).pcurve),hold on
    leglist{n}=a(n).name;  
end
legend(leglist);

%% SINGLE PITCHES (middle C)
clc;clear; close all
data=audioread('samef0_difftimbres2.wav');
fs=8000;

a(1).a=data(fs*2:fs*3);
a(1).inst='harmonica';

a(2).a=data(fs*4:fs*5);
a(2).inst='hum';

a(3).a=data(fs*6:fs*7);
a(3).inst='sing';

a(4).a=data(fs*10:fs*11);
a(4).inst='whistle';
wlen0=length(a(1).a)*2;
fscale=fs*(1:wlen0/2+1)/wlen0;
Cf=261.626;% frequency of middle C

for n=1:4
    clear px py ff
    a(n).fscale=fscale;
    P2=abs(fft(a(n).a , wlen0));
    P1=P2(1:wlen0/2+1);
    a(n).nP1=P1/max(P1);
    
    subplot(2,2,n)
    for f=1:15
        ff=f*Cf; % harmonics of middle C
        py=0:0.1:1;
        px(1,1:length(py))=ff;
        plot(px,py,'b'),hold on
    end
    plot(fscale,a(n).nP1,'k','lineWidth',2), hold on
    Tamp(1,1:length(fscale))=0.2;
    plot(fscale,Tamp,'r')
    title(a(n).inst);
    xlabel('frequency (Hz)')
    ylabel('amplitude (normalized)')
    xlim([0 length(fscale)/2+1])
    
    %legend('f0','f1','f2','f3','f4','f5','f6','f7','f8','f9','frequencies in signal')
    

    
    
end

