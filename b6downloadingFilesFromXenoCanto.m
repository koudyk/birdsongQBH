%% 23.4.2018 downloading data from XenoCanto
clc;clear; close all
rdir='F:\0.birdsongQBH\audio';  % root directory for saving the audio files
cd('C:\Users\User\Downloads') % make sure the wget.exe file is in the current directory

names_sci={'cardinalis cardinalis','geothlypis philadelphia',... % scientific names (in the format 'genus species')
    'melospiza melodia','poecile atricapillus',...
    'zenaida macroura','zonotrichia albicollis'};
names_common={'northern cardinal','mourning warbler',...
    'song sparrow','black-capped chickadee',...
    'mourning dove','white-throated sparrow'};
type='song'; % only download recordings labelled as 'song' (because other vocalizations can be hard to distinguish between species)
q='C'; % quality greater than C
recDet=struct([]);
noDownload=[];
noBkgdSp='Background</td><td valign=''top''>none'; % if there are no background species in the recording, this string will be found in the html of the given recording's webpage
fsBefore='<tr><td>Sampling rate</td><td>'; % text before the sampling rate in the html of the given recording's webpage
fsAfter=' (Hz)</td></tr>'; % text after the sampling rate in the html of the given recording's webpage

for nspec=1:length(names_sci);
    x=strsplit(names_common{nspec});
    folder=[num2str(nspec) '_' x{1} '_' x{2}];
    mkdir(rdir, folder)  % folder for audio from given species
    URL_json=['https://www.xeno-canto.org/api/2/recordings?query='... % URL for the json of the list of recordings
        x{1} '%20' x{2} '%20type:' type '%20q>:' q]; % COMMON NAMES (get more results by searching the common names)
        %'gen:' x{1} '%20sp' x{2} '%20type:' type '%20q>:' q]; % SCIENTIFIC NAMES        
     r=webread(URL_json);
     recMeta(nspec).name=names_common{nspec}; % meta info about the recordings for each species
     recMeta(nspec).N=length(r.recordings); % number of recordings
    
    for nrec=1:length(r.recordings)
        clc,disp(['--------------species ' num2str(nspec) '/' num2str(length(names_common)) ' - recording ' num2str(nrec) '/' num2str(length(r.recordings))])

% determine sampling rate
        html=webread(r.recordings(nrec).url); % download html
        r.recordings(nrec).fs=str2double( html(  strfind(html,fsBefore)+length(fsBefore)  :  strfind(html,fsAfter)  ) );

% download file
        filewav=[r.recordings(nrec).id '.wav']; % name for the .wav file
        URL=['https:' r.recordings(nrec).file]; % URL where the audio can be downloaded from
        system(['wget ' URL ]); % get audio file located at that URL
         if ~exist('C:/Users/User/Downloads/download', 'file')==0 % if the audio file was successfully downloaded
            r.recordings(nrec).dwnld=1;
            %r.recordings(nrec).audio=audioread('download');
            %r.recordings(nrec).sec=length(r.recordings(nrec).audio)/r.recordings(nrec).fs; % length of the audio file, in seconds
            audio=audioread('download');
            r.recordings(nrec).sec=length(audio)/r.recordings(nrec).fs; % length of the audio file, in seconds
            audiowrite(filewav,audio,r.recordings(nrec).fs) % convert to .wav file
            system(['move ' filewav ' ' rdir '\' folder '\' filewav ]); % move to destination folder (for some reason, I can't use wget unless the .exe file in the current directory, so I'd have to put it in each destination folder if I didn't want to change folders)
            delete('download') % delete file from Downloads 
         else r.recordings(nrec).dwnld=0; % the audio file wasn't downloaded
         end
         
% determine whether there are background species in the recording; this info is not in the json, but it is on the html page for the given recording
        if isempty(strfind(html,noBkgdSp)) % if the line indicating no background species is not found in the html (i.e., if there are background species)
            r.recordings(nrec).bkgd=1;
        else r.recordings(nrec).bkgd=0;
        end
    end    
    recMeta(nspec).N_noBkgd=sum([r.recordings.bkgd]); % number of recordings witout background species
    recMeta(nspec).T_sec=sum([r.recordings.sec]); % total seconds of audio for each species
    recDet=[recDet; r.recordings]; % details about each recording (all species in one structure)
end, %clear x n names_sci names_common type q temp r

cd(rdir)
save('b6_output_audioData','recMeta','recDet')

