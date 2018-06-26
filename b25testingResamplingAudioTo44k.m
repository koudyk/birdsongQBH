clc;close all; clear
load('QBH_metaData_2018-06-25.mat')

[a22,fs22]=audioread('spc03_xc00223421.wav');
a22=mean(a22,2);

[a48,fs48]=audioread('spc01_xc00407827.wav');
a48=mean(a48,2);

fs44=44100;

target_a48=resample(a48,fs44,fs48);
target_a22=resample(a22,fs44,fs22);

sec=2;
sound(a48(1:fs48*sec),fs48)
pause(sec)
sound(target_a48(1:fs44*sec),fs44)
pause(sec)

sound(a22(1:fs22*sec),fs22)
pause(sec)
sound(target_a22(1:fs44*sec),fs44)