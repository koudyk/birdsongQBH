%% 29.05.2018 using the downloadXC.m function to download the audio
% and audio metadata for the BirdsongQBH project
clc;clear
names={...
%     'northern cardinal',...
%     'black-capped chickadee',...
%     'mourning dove',...
%     'white-throated sparrow',...
%     'veery',...
%     'eastern screech owl',...
    'red-eyed vireo'};
nums=7;
type='song';
quality='C'; % greater than C (i.e., A or B)
dwnldDir='F:\0.birdsongQBH\audio';
wgetDir='C:\Users\User\Downloads';

[ recDet2, recMeta2 ] = downloadXC( wgetDir, dwnldDir,names,nums,type,quality );


cd(dwnldDir)
load('b8_output_audioData')
recDet=[recDet; recDet2];
recMeta=[recMeta'; recMeta2];
save('b8_output_audioData','recDet','recMeta')