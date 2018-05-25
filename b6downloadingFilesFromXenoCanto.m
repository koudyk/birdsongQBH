%% 23.4.2018 downloading data from XenoCanto
clc;clear; close all
rdir='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH\audio';  % root directory for saving the audio files
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
t=0;
noBkgdSp='Background</td><td valign=''top''>none'; % if there are no background species in the recording, this string will be found in the html of the given recording's webpage

for nspec=1:2%:length(names_sci);
    x=strsplit(names_common{nspec});
    folder=[num2str(nspec) '_' x{1} '_' x{2}];
    %mkdir(folder); % folder for audio from given species
    URL_json=['https://www.xeno-canto.org/api/2/recordings?query='... % URL for the json of the list of recordings
        x{1} '%20' x{2} '%20type:' type '%20q>:' q]; % COMMON NAMES
        %'gen:' x{2} '%20sp' x{1} '%20type:' type '%20q>:' q]; % SCIENTIFIC NAMES        
     r=webread(URL_json);
     recMeta(nspec).name=names_common{nspec}; % meta info about the recordings for each species
     recMeta(nspec).N=length(r.recordings);
    
    for nrec=1:3%length(r.recordings)
% download file
        filename=[r.recordings(nrec).id '.wav'];
        URL=['https:' r.recordings(nrec).file];
        system(['wget ' URL]); % get audio file located at that URL
        system(['move download ' rdir '\' folder '\' filename]); % move it to the given species' folder and change its name (it's automatically named 'download')
        
% determine whether there are background species in the recording; this info is not in the json, but it is on the html page for the given recording
        html=webread(r.recordings(nrec).url); % download html
        if isempty(strfind(html,noBkgdSp)) % if the line indicating no background species is not found in the html (i.e., if there are background species)
            r.recordings(nrec).bkgd=1;
        else r.recordings(nrec).bkgd=0;
        end
    end    
    recMeta(nspec).N_noBkgd=sum([r.recordings.bkgd]); % number of recordings witout background species
    recDet=[recDet; r.recordings]; % details about each recording (all species in one structure)
end, %clear x n names_sci names_common type q temp r


%% doesn't work because the time isn't indicated for all recordings
% can determine length when load audio


% % calculate total time for each species
%         temp=str2double(strsplit(r.recordings(nrec).time,':'));
%         t=t+temp(1)+(temp(2)/60);
%     end
%     metainfo(nspec).time=t;
