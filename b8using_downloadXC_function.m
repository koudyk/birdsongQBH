%% 15.6.2018 using the downloadXC.m function to download the audio
% and audio metadata for the BirdsongQBH project

clc,clear,%close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))

basic=sort({...
    'northern cardinal'...
    'black-capped chickadee'...
    'mourning dove'...
    'white-throated sparrow'...
    'red-eyed vireo'...
    'sora'...
    'common yellowthroat'...
    'prairie warbler'...
    'black-throated blue warbler'...
    'veery'
    });

dwnldDir=exhard;
wgetDir='C:\Users\User\Downloads';

advanced = {'type:song' 'q>:C' };
maxQuantity=Inf;
nums=1:length(basic);
targetFs=44100;
tic
[ meta ] = downloadXC(  wgetDir, dwnldDir,basic,nums,advanced,targetFs,maxQuantity);
toc % Elapsed time is 6153.665652 seconds.


%%
% clc,clear,%close all, clear sound
% laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
% exhard='F:\0.birdsongQBH\audio'; %external harddrive
% addpath(genpath(exhard))
% addpath(genpath(laptop))
% 
% names=sort({...
%     'northern cardinal'...
%     'black-capped chickadee'...
%     'mourning dove'...
%     'white-throated sparrow'...
%     'red-eyed vireo'...
%     'sora'...
%     'common yellowthroat'...
%     'prairie warbler'...
%     'black-throated blue warbler'...
%     'veery'
%     });
% 
% dwnldDir=exhard;
% wgetDir='C:\Users\User\Downloads';
% type='song';
% %quality='B'; % greater than B (i.e., A)
% quality='C'; % greater than C (i.e., A or B)
% maxQuantity=Inf;
% nums=1:length(names);
% targetFs=44100;
% 
% tic
% [ meta ] = downloadXC( wgetDir, dwnldDir,names,type,quality,maxQuantity,nums,targetFs); %,maxNum );
% toc % Elapsed time is 5114.166943 seconds.
% %% adding another species
% 
% clc,clear,%close all, clear sound
% laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
% exhard='F:\0.birdsongQBH\audio'; %external harddrive
% addpath(genpath(exhard))
% addpath(genpath(laptop))
% 
% %names={'Veery'};
% names={'Black-throated blue warbler'};
% 
% dwnldDir=exhard;
% wgetDir='C:\Users\User\Downloads';
% type='song';
% %quality='B'; % greater than B (i.e., A)
% quality='C'; % greater than C (i.e., A or B)
% maxQuantity=Inf;
% 
% cd(exhard)
% list_spc=dir('spc*');
% Nspec=length(list_spc); % number of species already downloaded
% nums=Nspec+1:Nspec+length(names); % species number(s) for the new species
% 
% [ recDet, recMeta ] = downloadXC( wgetDir, dwnldDir,names,type,quality,maxQuantity,nums); %,maxNum );
% 
% 
% % cd(dwnldDir)
% % save(['b8_output_audioData_' datestr(now,'yyyy-mm-dd')],'recDet','recMeta')
% 
% 
