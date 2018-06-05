%% 25.5.2018 visualizing the pitch curve and confidence in the pitch estimation
% as done by CREPE

clc,clear,close all
cd 'F:\0.birdsongQBH\audio\1_northern_cardinal'
temp=csvread('416549.f0.csv',2); % the 2 tells it to start to read from the second row, since the first is a header row
%% 
clf
t=temp(:,1); % time
p=temp(:,2); % pitch curve
c=temp(:,3); % confidence
fs=find(t==1);
low=0;
high=5;
cf=fftfilter(c,fs,low,high); % filtered confidence
thresh_cf=.2; % confidence threshold

p1=subplot(4,1,1);semilogy(t,p,'.'),title('raw pitch curve')
p2=subplot(4,1,2);plot(t,c,'.'),title('raw confidence levels')
p3=subplot(4,1,3);plot(t,cf,'.'),title(['bp-filtered confidence levels (' num2str(low) ' to ' num2str(high) ' Hz)'])
p4=subplot(4,1,4);semilogy(t,(cf>thresh_cf).*p,'.'),title(['pitch curve thresholded by filtered confidence>' num2str(thresh_cf)])
linkaxes([p1,p4],'xy')
linkaxes([p2,p3],'xy')

%% what is the upper limit of CREPE?
% run this section while watching the online demo for when the pitch
% curve disappears at the top
%https://marl.github.io/crepe/
len=.2; % length of tone (seconds)
t=0:1/fs:len;
for f=500:10:3000 % frequencies
    disp(f)
    s=sin(2*pi*t*f);
    sound(s,fs)
    pause(len)
end
% about 2000 Hz



%% BROKEN
%%
%%

clc;clear;close all
cd('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH\a_good_course')
fs=44100;
a=audioread('00000_44k.mp3');
%sound(a,fs)

 audiowrite('00000_44k_x2.wav',a,fs/2)
% 
 a2=audioread('00000_44k_x2.wav');
sound(a2,fs/3)
%% quick way to determine highest frequency
acf=xcorr(a2(:,2));
%plot(acf)

p2=real(fft(a2));
plot(p2) 
%% maybe better to find general frequency range for all of the birdsong
clc;clear;close all
fs=44100;
cd('C:\Users\User\Documents\MATLAB\Projects\birdsongQBH\a_good_course')
% mourning dove might be too low
a=audioread('38819_44k.wav');
%sound(a(6*fs:11.5*fs),fs)
audiowrite('short_mourningDove.wav',a(6*fs:11.5*fs),fs)
%%
a=audioread('short_mourningDove.wav');
audiowrite('doveSame.wav',a,fs/2)
a2=audioread('doveSame.wav');
sound(a2,fs)
%sound(a(1:2:end),fs)


