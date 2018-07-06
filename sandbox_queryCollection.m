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

% COLLECT PTP NUMBER
ptp=NaN;
while isnan(ptp)
    ptp=str2double(input('Please enter your participant number and then press Enter : ','s'));
end, clc


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
%         queryName=[sprintf('ptp%03d',ptp)...
%             '_xc' sprintf('%08d',d(na).id)...
%             '_t' datestr(now,'yyyy-mm-dd-HH-MM-SS')...
%             '.wav'];
%         audiowrite(queryName,query,fs);
        
        
    end
end

save('QUERIES_test_NspecByNrec','queries')
