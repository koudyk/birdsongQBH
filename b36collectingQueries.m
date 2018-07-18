tic
clc,clear%,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)

load('STIMULI3.mat')
load('PRACTICE.mat')
[clap, fs_clap]=audioread('CLAP.wav');
Nstim=100;
Nspec=size(stimuli,1);
Nrec=size(stimuli,2);
fs=44100; % Hz
qlen=1; % query length, in multiples of the stimulus length
recObj=audiorecorder(fs,16,1); % record with bit-depth of 16 and for one channel
cp=1; % countdown pause
% beep_len=.5;
% beep=0.25*sin(2*pi*440*(0:1/fs:beep_len));


%% COLLECT PTP NUMBER
disp('Thank you for participating!')

ptp=NaN;
while isnan(ptp)
    ptp=str2double(input(...
        'Please enter your participant number (then press Enter) : ','s'));
end, clc

%% PRACTICE RUN
clc,input(['We will begin with a practice round including 3 trials. '...
    '\n \nFeel free to adjust the volume during this practice round.' ...
    '\n \n \n \n------------- Press Enter to continue -------------'])

clc,input([...
    'For each trial, '...
    'you will hear an excerpt of birdsong, and then '...
    'you will be asked to imitate what you heard. \n \n'...
    'The sound of a clap will mark the end of the birdsong and '...
    'the beginning of the recording period for your query. \n \n '...
    'The imitation may be done however you like (e.g., whistling, ',...
    'humming, singing, etc.)'...
    '\n \n \n \n------------- Press Enter to continue -------------']);

for nstim = 1:3
    clc
    stim=practice(nstim).audio;
    slen=length(stim)/fs; % audio length

    % PLAY STIMULUS
    k=input('\n PRACTICE ------------- Press Enter to hear audio -------------\n');
    disp('Playing audio...')
    sound(stim,fs)
    pause(slen)
    
    % CLAP
    sound(clap, fs)
    pause(length(clap)/fs)

    % RECORD QUERY
    disp('Recording your imitation...')
    recordblocking(recObj,slen*qlen+2)    

end
clc,input(['Thank you! The practice round is over. '...
    '\n \n If you have any questions, please ask before continuing.'...
    '\n \n \n \n------------- Press Enter to continue -------------']);



%% REAL DEAL
c=0;
order = randperm(Nstim);
stimuli(1).query=[];
stimuli(1).stimulusOrder = [];
for nstim = order
clc
    c=c+1; 
    fprintf('%d / %d',c,Nstim)
    stim=stimuli(nstim).stimulus;
    slen=length(stim)/fs; % audio length

    % PLAY STIMULUS
    k=input('\n------------- Press Enter to hear audio -------------\n');
    disp('Playing audio...')
    sound(stim,fs)
    pause(slen)

    % CLAP
    sound(clap, fs)
    pause(length(clap)/fs)
    
    % RECORD QUERY
    disp('Recording your imitation...')
    recordblocking(recObj,slen*qlen+2)

    % SAVE QUERY
    disp('Done recording, thank you.')
    queries(c)=stimuli(nstim);
    queries(c).stimulusOrder = c;
    queries(c).query = getaudiodata(recObj);
    
end

%% SAVE
fileName = sprintf('queries_long_ptp%03d_%s',ptp,datestr(now,'yyyy-mm-dd-HH-MM-SS'));
save(fileName,'queries','ptp')

toc




%% INSTRUCTIONS
% clc,input(['Thank you for participating! \n \n'...
%     'For each trial, you will hear an excerpt of birdsong and then '...
%     'you will be asked to imitate what you heard. \n \n'...
%     'The imitation may be done however you like (e.g., whistling, ',...
%     'humming, singing, etc.)'...
%     '\n \nPlease only press Enter when instructed to do so.'...
%     '\n \n \n \n------------- Press Enter to continue -------------']);
% clc,input(['You will not be able to re-record your imitations, but '...
%     'don''t worry about how ''good'' your imitations sound. '...
%     'The purpose is to gather immediate imitations, not practiced '...
%     'and perfected imitations. ']);
% clc,input(['These recordings will be pubplished online '...
%     'under an open-access licence, with participant identities anonymized. '...
%     'This means that your name will not be publicly connected '...
%     'to any of the data or to reports on research using the data. '...
%     '\n \nYou may withdraw from this study at any '...
%     'time during during or following data collection up until '...
%     'the time when the data is published. \n \nFeel free to pause for '...
%     'a break at any time between recordings.'...
%     '\n \n \n \n------------- Press Enter to continue -------------']);
% clc,input(['We will begin with a practice round including 3 trials. '...
%     '\n \nFeel free to adjust the volume during this practice round' ...
%     '\n \n \n \n------------- Press Enter to continue -------------'])

