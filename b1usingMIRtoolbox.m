clc;clear;close all
cd('C:\Users\User\Documents\MATLAB\Projects\courseMIR\demo2\birdSounds')
a=audioread('cardinal_song_eg_2.mp3');
a=a(:,1);
%%
n=mirnovelty('cardinal_song_eg_1.mp3');
mirplayer(n)

%%
c=mirchromagram('cardinal_song_eg_2.mp3','Frame');
mirplayer(c)

%%
s=mirsimatrix(c);
n=mirnovelty(s);
mirplayer(n)
%%
s=mirsegment('cardinal_song_eg_1.mp3');
mirplayer(s)
%%
clip='robin_song_2.mp3';
n=mirnovelty(clip);
p=mirpeaks(n);
s=mirsegment(clip,p);
mirplayer(s)

%%
clip='robin_song_2.mp3';
p=mirpitch(clip,'Frame');
mirplayer(p)


