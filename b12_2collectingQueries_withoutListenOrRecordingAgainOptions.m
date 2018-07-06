clc,clear,close all
adir='F:\0.birdsongQBH\audio';
edir='F:\0.birdsongQBH\audio\examples';
qdir='F:\0.birdsongQBH\audio\queries';
addpath(genpath(adir))
load('b8_output_audioData_withAonly.mat')
cd(qdir)

play_len=3; % seconds - playing time
rec_len=1.25*play_len; % recording timed
fs_q=44100; % sampling rate for collecting queries
recObj=audiorecorder(fs_q,16,1); % record with bit-depth of 16 and for one channel
cp=.75; % countdown pause
d=recDetA; % data 

beep_fs=44100;
beep_len=.75;
beep=0.5*sin(2*pi*440*(0:1/beep_fs:beep_len));

% COLLECT PTP NUMBER
ptp=NaN;
while isnan(ptp)
    ptp=str2double(input('Please enter your participant number and then press Enter : ','s'));
end


% REAL DEAL
rdn=randperm(length(d)); % random order of stimulus presentation
for nna=1:3 %length(d),
    na=rdn(nna);
   % PLAY BIRDSONG
    clc,disp('Loading...')
    [a_b,fs_b]=audioread([num2str(d(na).id) '.wav']); 
    if na==1, k=input('Press Enter when ready to hear audio. ');
    else k=input('Press Enter when ready to hear next audio. ');
    end
    sound(a_b(1:play_len*fs_b),fs_b)
    pause(play_len)

    % RECORD QUERY
    clc,disp('Recording your imitation in 3'),pause(cp)
    clc,disp('Recording your imitation in 2'),pause(cp)
    clc,disp('Recording your imitation in 1'),pause(cp)
    clc,sound(beep,beep_fs),pause(beep_len),disp('Recording...')
    recordblocking(recObj,rec_len)
    pause(2)

    % SAVE QUERY        
    disp('Done recording, thank you. Saving...')
    a_q=getaudiodata(recObj);
    queryName=[sprintf('ptp%03d',ptp)...
        '_xc' sprintf('%08d',d(na).id)...
        '_t' datestr(now,'yyyy-mm-dd-HH-MM-SS')...
        '.wav'];
    audiowrite(queryName,a_q,fs_q);
    pause(2)  
end 

k=input(['Thank you very much for participating! '...
    'Please get the experimenter and inform them you are done.']);  

list=dir([sprintf('ptp%03d',ptp) '*']); % list of queries for given participant
destination='F:\0.birdsongQBH\audio\queries_backupTest_b12_2'; % destination for back-up copies of queries
for nq=1:length(list)
    clc,disp([num2str(nq) '/' num2str(length(list))])
    file=list(nq).name;
    copyfile(file,destination);
end
    






% %INSTRUCTIONS
% clc,input(['Thank you for participating in this experiment. '...
%     'For each trial, you will hear a recording of birdsong and then '...
%     'you will be asked to imitate what you hear. You may do the '...
%     'imitation in whatever manner you feel most appropriate. '...
%     'Please only press Enter when instructed to do so.'...
%     'Press Enter to continue.']);
% clc,input(['These recordings will be pubplished online '...
%     'under a WHICH licence, with participant identities anonymized. '...
%     'You may withdraw from this study at any '...
%     'time during the experiment or following data collection up until '...
%     'the time when the data is published. Feel free to pause for '...
%     'a break or a drink at any time between recordings.']);
% clc,input(['We will begin with a practice round including 3 trials. '...
%     'Press Enter to continue.'])


% % PRACTICE RUN
% for na=1:3
%     % PLAY BIRDSONG
%     clc,disp('Loading...')
%     [a_b,fs_b]=audioread([num2str(d(na).id) '.wav']); 
%     if na==1, k=input('Press Enter when ready to hear audio. ');
%     else k=input('Press Enter when ready to hear next audio. ');
%     end
%     sound(a_b(1:play_len*fs_b),fs_b)
%     pause(play_len+1)
% 
%     % RECORD QUERY
%     clc,disp('Recording your imitation in 3'),pause(cp)
%     clc,disp('Recording your imitation in 2'),pause(cp)
%     clc,disp('Recording your imitation in 1'),pause(cp)
%     clc,sound(beep,beep_fs),pause(beep_len),disp('Recording...')
%     recordblocking(recObj,rec_len)
%     pause(2)
% 
%     % SAVE QUERY        
%     disp('Done recording, thank you. Saving...')
%     aq=getaudiodata(recObj);
%     queryName=[ptp '_' d(na).id '_' datestr(now,'yyyy-mm-dd-HH-MM')];
%     pause(2)  
% end
% clc
% k=input(['Thank you for completing the practice run. '...
%     'If you have any questions or concerns, please contact the '...
%     'experimenter at this time. If you are ready to proceed to the '...
%     'experiment, press Enter.']);  




