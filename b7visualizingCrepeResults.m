clc,clear,close all
cd 'C:\Users\User\Documents\MATLAB\Projects\birdsongQBH\a_good_course'
x=csvread('100744_44k.f0.csv',2);

clf
fs=100;
y=fftfilter(x(:,3),100,0,5);

subplot(3,1,1),semilogy(x(:,1),(x(:,2))*12)
subplot(3,1,2),plot(x(:,3))
subplot(3,1,3),plot(x(:,1),(y>.5).*x(:,2))
%%
clc,clear
system('cd C:\Users\User\Desktop & hello.cmd')