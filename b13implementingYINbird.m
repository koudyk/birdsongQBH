clc;clear;close all; clear sound

rdir='F:\0.birdsongQBH\audio';
addpath(genpath(rdir))
load('b8_output_audioData_withAonly.mat')

uc=8000; % Hz, upper-bound of bird vocalization frequency range
lc=200; % Hz, lower-bound of bird vocalization frequency range
wsize_sec=.01; % window size in seconds
%stdFilt=3.5; 
d=recDetA; % recDet for recordings of quality A and B; recDetA for recordings of quality A only. 
highMean=1000; % Hz
lpfc_highRange=750; % Hz; low-pass frequency cut off for birds with a higher frequency range

figure
k=1; c=0;
i=find([d.id]==366609);
while k==1
for na=i%=30:length(d)%randperm(length(d))
    c=c+1; disp([num2str(c) ' - ' num2str(d(na).id)])
    clear F_Fprom P_Fprom
    
% LOAD AUDIO
    afile=[num2str(d(na).id) '.wav'];
    [a,fs]=audioread(afile);
    a=a(:,1); % because YIN uses the first column of audio
    a=a(1:length(a));
    

    wsize=floor(fs*wsize_sec);
    zeroPad=floor(wsize*1.5); % for fft to zero pad the window of analysis
    fscale=fs*(0:(zeroPad/2))/zeroPad;
    [~,hpfc]=min(abs(fscale-uc)); % high-pass frequency threshold
    [~,lpfc]=min(abs(fscale-lc)); 


    for nwin=1:floor(length(a)/wsize)
        beg=nwin*wsize-wsize+1; % beginning of the window
            %start=695000; % good window as an example
        win=a(beg:beg+wsize-1);
        p2=abs(fft(win,zeroPad)); % double-sided power spectrum
        p1=p2(1:floor(length(p2)/2)); % single-sided power spectrum
        p1(1:lpfc)=0; % don't consider frequencies lower than 200 Hz (as did the YIN-bird people)
        p1(hpfc:end)=0;
        if sum(p1)>0
            [P_Fprom(nwin), i]=max(p1); % store power and frequency of highest peak
            F_Fprom(nwin)=fscale(i);
        end
    end
    clear sound,sound(a,fs)
    clf, clear s1 s2 s3 %wsize_sec
    s1=subplot(3,1,1);plot(F_Fprom,'.-');title({[d(na).en ', na = ' num2str(na)], 'max-power frequency for each frame'});
    
    F_Fprom(P_Fprom<mean(P_Fprom))=NaN; % take only prominant frequencies whose power is above the mean of the prominent frequencies
    s2=subplot(3,1,2);plot(F_Fprom,'.-'); title('max-power frequencies above the mean power of max-power frequencies');
    
    if d(na).lowFreqRange==0 % if the mean frequency is high
        y='Yes';
        F_Fprom(F_Fprom<lpfc_highRange)=NaN; 
    else y='No';
    end
    s3=subplot(3,1,3);plot(F_Fprom,'.-'); title(['higher lpf? ' y ]);
    
    linkaxes([s1 s2 s3]);
%     u=nanmean(F_Fprom)+nanstd(F_Fprom)*2;
%     l=nanmean(F_Fprom)-nanstd(F_Fprom)*stdFilt;
%     
%     hold on, plot(repmat(u,length(F_Fprom),1))
%     hold on, plot(repmat(l,length(F_Fprom),1))
%     
%     F_Fprom(F_Fprom<l)=NaN;
%     F_Fprom(F_Fprom>u)=NaN;
%     
%     s3=subplot(3,1,3),plot(F_Fprom,'.-'), title(['only values within ' num2str(stdFilt) ' st devs of mean frequency']) 

    k=0;
    k=waitforbuttonpress;                           

end
end
%     clf
%     subplot(2,1,1),plot(win)
%     subplot(2,1,2),plot(p1),hold on, plot(F_Fprom(nwin),P_Fprom(nwin),'*'),hold off
%     sound(win,fs)
    %m=input(num2str(nwin),'s');


%subplot(3,1,),plot(p2)

%subplot(3,1,2),plot(P_Fprom)
%subplot(3,1,3),spectrogram(win,512,256,512,fs,'yaxis')

% [s,f,t,p]=spectrogram(a,512,256,512,fs,'yaxis','MinThreshold',-.5);
% clf,(imagesc(abs(p)))
%%

% 
% 
% 
%     t=length(a)/1000;
%     zeroPad=length(a)*1.5;
%     fscale=fs*(0:(zeroPad/2))/zeroPad;
%     p2=abs(fft(a,zeroPad));
%     [m,i]=max(p2)
%     %plot(p2)
%     
%     if m>t
%         ft=fscale(i);
%         F_Fprom(F_Fprom>=ft)=NaN;
%     end