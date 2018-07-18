clc,clear%,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(fullfile(exhard,'queries'))

load('STIMULI_test_NspecByNrec.mat')
Nspec=size(stimuli,1);
Nrec=size(stimuli,2);
fs=44100; % Hz
qlen=1; % query length, in multiples of the stimulus length
recObj=audiorecorder(fs,16,1); % record with bit-depth of 16 and for one channel
cp=.25; % countdown pause
queries = cell(Nspec,Nrec);
beep_len=.5;
beep=0.25*sin(2*pi*440*(0:1/fs:beep_len));


%% INSTRUCTIONS
clc,input(['Thank you for participating! \n \n'...
    'For each trial, you will hear a recording of birdsong and then '...
    'you will be asked to imitate what you heard. \n \nYou may do the '...
    'imitation in whatever manner you feel most appropriate '...
    '(i.e., singing, humming, whistling, etc.).'...
    '\n \nPlease only press Enter when instructed to do so.'...
    '\n \n \n \n------------- Press Enter to continue -------------']);
clc,input(['These recordings will be pubplished online '...
    'under an open-access licence, with participant identities anonymized. '...
    'This means that your name will not be publicly connected '...
    'to any of the data or to reports on research using the data. '...
    '\n \nYou may withdraw from this study at any '...
    'time during during or following data collection up until '...
    'the time when the data is published. \n \nFeel free to pause for '...
    'a break at any time between recordings.'...
    '\n \n \n \n------------- Press Enter to continue -------------']);
clc,input(['We will begin with a practice round including 3 trials. '...
    '\n \n \n \n------------- Press Enter to continue -------------'])

%% COLLECT PTP NUMBER
clc
ptp=NaN;
while isnan(ptp)
    ptp=str2double(input('Please enter your participant number and then press Enter : ','s'));
end, clc

%% PRACTICE RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% REAL DEAL
for nrec=1:Nrec
    for nspec=1:Nspec
        stim=stimuli{nspec,nrec};
        slen=length(stim)/fs; % audio length
        
        % PLAY STIMULUS
        k=input('Press Enter when ready to hear audio. ');
        sound(stim,fs)
        pause(slen+1)
        
        % RECORD QUERY
        clc,disp('Recording your imitation in 3'),pause(cp)
        clc,disp('Recording your imitation in 2'),pause(cp)
        clc,disp('Recording your imitation in 1'),pause(cp)
        clc,sound(beep,fs),pause(beep_len),disp('Recording...')
        recordblocking(recObj,slen*qlen)
        pause(2)
        
        % SAVE QUERY
        disp('Done recording, thank you.')
        query=getaudiodata(recObj);
        queries{nspec,nrec}=getaudiodata(recObj);
 
    end
end

%% SAVE
fileName = sprintf('QUERIES_ptp%03d_Nspec-by-Nrec_%s',ptp,datestr(now,'yyyy-mm-dd-HH-MM-SS');
save(fileName,'queries',ptp,)
