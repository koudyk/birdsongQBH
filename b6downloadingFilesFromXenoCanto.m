%% 23.4.2018 downloading data from XenoCanto
clc;clear; close all
rdir='C:\Users\User\Documents\MATLAB\Projects\birdsongQBH\audio';
cd('C:\Users\User\Downloads') % make sure the wget.exe file is in the current directory

names_sci={'cardinalis cardinalis','geothlypis philadelphia',... 
    'melospiza melodia','poecile atricapillus',...
    'zenaida macroura','zonotrichia albicollis'};
names_common={'northern cardinal','mourning warbler',...
    'song sparrow','black-capped chickadee',...
    'mourning dove','white-throated sparrow'};
type='song';
q='C';
recDet=struct([]);

t=0;
for nspec=1%:length(names_sci);
    x=strsplit(names_common{nspec});
    folder=[num2str(nspec) '_' x{1} '_' x{2}];
    %mkdir(folder); % folder for audio from given species
    
    URL_json=['https://www.xeno-canto.org/api/2/recordings?query='... % URL for the json of the list of recordings
        x{1} '%20' x{2} '%20type:' type '%20q>:' q]; % COMMON NAMES
        %'gen:' x{2} '%20sp' x{1} '%20type:' type '%20q>:' q]; % SCIENTIFIC NAMES
        
    r=webread(URL_json);
    
    recDet=[recDet; r.recordings]; % details about each recordings
    recMeta(nspec).name=names_common{nspec}; % meta info about the recordings for each species
    recMeta(nspec).no=length(r.recordings);
    
    for nrec=1%:3%length(r.recordings)
        filename=[r.recordings(nrec).id '.wav'];
        URL=['https:' r.recordings(nrec).file];
        system(['wget ' URL]); % get audio file located at that URL
        system(['move download ' rdir '\' folder '\' filename]); % move it to the given species' folder and change its name (it's automatically named 'download')
        
        %audiowrite(
        
        
    end
end, %clear x n names_sci names_common type q
%%


%% calculating total time for each species
%     temp=str2double(strsplit(a(n).time,':'));
%     t=t+temp(1)+(temp(2)/60);
%     metainfo(nspec).time=t;

