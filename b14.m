clc;clear;close all; clear sound

rdir='F:\0.birdsongQBH\audio';
addpath(genpath(rdir))
load('b8_output_audioData_withAonly.mat')
d=recDetA; % data; recDet for recordings of quality A and B; recDetA for recordings of quality A only. 

% PARAMETERS
wsize_sec=.01; % window size in seconds
maxf_H=7000; % Hz; max frequency for birds with High frequency range
minf_H=750; % Hz; min frequency for birds with High frequency range
maxf_L=1000; % Hz; max frequency for birds with Low frequency range
minf_L=200; % Hz; min frequency for birds with Low frequency range

secBWphrase=1; % seconds of silence between phrases

figure
k=1; c=0;
 if k==1
    for na=2%:length(d)
        while d(na).exclusion >0, na=na+1; end
            c=c+1; disp([num2str(c) ' - ' num2str(d(na).id)])
            clear F_Fprom P_Fprom begs fins F P

% LOAD AUDIO
            afile=[num2str(d(na).id) '.wav'];
            [a,fs]=audioread(afile);
            a=a(:,1); % because YIN uses the first column of audio
            a=a(1:length(a));

% SET PARAMETERS ACCORDING TO FS
            wsize=floor(fs*wsize_sec);
            zeroPad=floor(wsize*1.5); % length of zero padded window
            fscale=(0:(zeroPad/2)) / zeroPad;
            fscale=fs*(fscale-round(fscale));

% DETERMINE FREQUENCY WITH HIGHEST POWER FOR EACH WINDOW    
            for nwin=1:floor(length(a)/wsize)
                beg=nwin*wsize-wsize+1; % beginning of the window
                    %start=695000; % good window as an example
                win=a(beg:beg+wsize-1); % given window
                p2=abs(fft(win,zeroPad)); % double-sided power spectrum
                p1=p2(1:floor(length(p2)/2)); % single-sided power spectrum
                %clf,plot(p1),ylim([0 10]),hold on

        % PREPROCESS - FILTER FREQUENCIES NOT LIKELY TO BE BIRDSONG
                    if d(na).lowFreqRange==0
                         ind=find(abs(fscale)<minf_H | abs(fscale)>maxf_H); % for species with a HIGH frequency range
                    else ind=find(abs(fscale)<minf_L | abs(fscale)>maxf_L); % for species with a LOW frequency range
                    end
                    p1(ind)=0; % set frequencies outside desired band to 0
                    %plot(p1); k=0;    k=waitforbuttonpress; 
                if sum(p1)>0
                    [P(nwin), i]=max(p1); % store power and frequency of highest peak
                    F(nwin)=fscale(i);
                end
            end
% TAKE ONLY PROMINENT FREQUENCIES WHOSE POWER IS ABOVE THE MEAN OF THE
% PROMINENT FREQUENCIES
            F(P<mean(P))=NaN;   
          %  clf,plot(F),hold on
    
            
% SMOOTH PITCH CURVES
            fs_F=fs/wsize;
            %Ff=fftfilter(F,fs_F,0,1);
          
            
% SEGMENT by silence
    % SYLLABLES
            temp=F; temp(isnan(temp))=0;
            sb=find([temp 0]-[0 temp]==[F 0]); % syllable beginnings
            sb=sb(1:end-1);
            
            se=find([0 temp]-[temp 0]==[0 F]); % syllable ends
            se=se(2:end)-1;
    % PHRASES
            pb=sb(([sb 0]-[0 se])> (fs_F*secBWphrase));
            


% VISUALIZE/LISTEN
            clear sound,sound(a,fs)
            clf,plot(F),hold on
            %plot(Ff),hold on
            plot(sb,F(sb),'*'), hold on,
            plot(se,F(se),'*'), hold on,
            
            plot(pb,F(pb),'*'),
            legend('pitch curve', 'segment beginnings','segment ends','phrase beginnings')

k=waitforbuttonpress;   
    end
end






%%
% 
%             % don't let too-short segments be segments
%             i=find(abs(fins-begs)<2);
%             begs(i)=[];
%             fins(i)=[];

%     begs=findpeaks((1:length(F)).*isnan(F))+1;
%     ends=findpeaks((length(F):-1:1).*isnan(F))-1;
% 
%     
%     plot(F),hold on
%     plot(begs,F(begs),'*'), hold on
%     plot(ends,F(ends),'*')
    %temp=zeros(length(F),1);
%     temp=[];
%     temp(ends)=max(F);
%     temp(temp==0)=NaN;
%     plot(temp)
%     
    
    
%     for n=2:length(F)-1
%         if isnan(F(n)), 
%             ce(n)=ce(n-1)+1;
%             cb(n)=cb(n-1)-1;
%         end
%     end
   %         cc=0;
    %         for nl=1:length(locs)-1
    %             seg=F(locs(nl):locs(nl+1));
    %             if sum(find(seg))>2
    %                 cc=cc+1;
    %                 L(cc)=locs(nl);
    %             end
    %         end


    %         subplot(2,1,2),plot(F),hold on
    %         tempplot=[];
    %         tempplot(L)=max(F);
    %         tempplot(L-1)=0;
    %         plot(tempplot)
    
    
    
    
%     % SEGMENT
%         % segment
% %             temp=F; 
% %             temp(isnan(temp))=0;
% %             locs=findchangepts(temp,'Statistic','linear','MinThreshold',100000000);
% 
%     % VISUALIZE/LISTEN
%             clear sound,sound(a,fs)
%     %        s1=subplot(3,1,1);plot(F_Fprom,'.-'); title('pitch curve');
%              %subplot(2,1,1),
%              plot(F),hold on
% %             tempplot=[];
% %             tempplot(locs)=max(F);
% %             tempplot(locs-1)=0;
%            % plot(tempplot)


%     c=(length(F):-1:1).*isnan(F);
%     begs=findpeaks(c);
%     c=(1:length(F)).*isnan(F);
%     fins=findpeaks(c);
%     
%     plot(F),hold on
%     temp=[];
%     temp(begs)=max(F);
%     temp(begs-1)=0;
%     plot(temp)

% clc,close all
% 
% x=findchangepts(y,'Statistic','linear','MinThreshold',1000000)
% %x=findchangepts(y,'Statistic','linear','MinThreshold',100)
% 
% plot(F_Fprom),hold on
% 
% %line(x,max(F_Fprom))
% 
% xx=[];
% xx(x)=max(F_Fprom);
% xx(x-1)=0;
% plot(xx);
% 
% % xx=zeros(length(F_Fprom),1);
% % xx(x)=max(F_Fprom);
% % xx(xx==0)=NaN;
% % is=find(xx>0);
% % xx(is-1)=0;
% % plot(xx)
% %line(xx)
