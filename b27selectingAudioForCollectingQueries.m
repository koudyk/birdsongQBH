clc,clear%,close all, clear sound
laptop='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH';
exhard='F:\0.birdsongQBH\audio'; %external harddrive
addpath(genpath(exhard))
addpath(genpath(laptop))
cd(exhard)
list_segs=dir('clean*');
Nspec=length(list_segs);
fs=44100;
NperSpec=10;

stimuli=cell(Nspec,NperSpec);

for nspec=1:Nspec
    load(list_segs(nspec).name)
    nperSpec=0;
    for nXC=1:NperSpec
        [~,i_longest]=max(cellfun('length',audio_segs{nXC}));
        a=audio_segs{nXC}{i_longest};
        stimuli{nspec,nXC}=a;
        sound(a,fs)
        pause(length(a)/fs + .25)
    end
    
end

%save('STIMULI_test_NspecByNrec','stimuli')
