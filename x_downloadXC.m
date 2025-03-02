function [ recDet, recMeta ] = x_downloadXC( wgetDir, dwnldDir,names,type,quality )
%downloadXC 
    % Downloads audio from Xeno-Canto for given bird species and given
    % type of vocalization and quality of recording.
    % NOTE: this function requires the 'wget' function used by the
    % Windows Command Prompt to download the contents of a webpage. 
% INPUTS
    % wgetDir = directory with the wget.exe file
    % dwnldDir = directory where the audio will be downloaded to
    % names = cell array of names (scientific or common)
    % type = type of vocalization (call, song, )
    % quality = quality of recording; the quality will be greater than the letter provided(A, B, C, D)
% OUTPUTS
    % recDet = details about each recordings
    % recMeta = meta-information about all the recordings for each species
    % noDownload = list of files that were not successfully downloaded
%
%
% e.g., [ recDet, recMeta ] = downloadXC( 'C:\Users\User\Downloads', 'F:\0.birdsongQBH\audio','northern cardinal','song','C' )
%
% created by Kendra Oudyk 05.2018

cd(wgetDir)
recDet=struct([]); % details about each recording

% for searching the html for the given recording's webpage
noBkgdSp='Background</td><td valign=''top''>none'; % if there are no background species in the recording, this string will be found in the html of the given recording's webpage
fsBefore='<tr><td>Sampling rate</td><td>'; % text before the sampling rate in the html of the given recording's webpage
fsAfter=' (Hz)</td></tr>'; % text after the sampling rate in the html of the given recording's webpage

for nspec=1:length(names);
    n=strsplit(names{nspec});
    folder=num2str(nspec); % put the species number at the beginning of the folder name
    name_for_URL=[]; % species name (input) for the URL (i.e., with spaces replaced by '%20')
    for nn=1:length(n) 
        folder=[folder '_' n{nn}]; % replace spaces in the bird names with '_' 
        name_for_URL=[name_for_URL n{nn} '%20']; % the '%20' puts a space in the search. Essentially this line replaces the spaces between words in the name with '%20'
    end
    mkdir(dwnldDir, folder)  % folder for audio from given species
    URL_json=['https://www.xeno-canto.org/api/2/recordings?query='... % URL for the json of the list of recordings
        name_for_URL 'type:' type '%20q>:' quality]; 
    r=webread(URL_json);
    recMeta(nspec).name=names{nspec}; % meta info about the recordings for each species
    recMeta(nspec).N=length(r.recordings); % number of recordings
    
    for nrec=1:length(r.recordings)
        clc,disp(['--------------species ' num2str(nspec) '/' num2str(length(names)) ' - recording ' num2str(nrec) '/' num2str(length(r.recordings))])
        html=webread(r.recordings(nrec).url); % download html
% determine sampling rate
        r.recordings(nrec).fs=str2double( html(  strfind(html,fsBefore)+length(fsBefore)  :  strfind(html,fsAfter)  ) );

% determine whether there are background species in the recording; this info is not in the json, but it is on the html page for the given recording
        if isempty(strfind(html,noBkgdSp)) % if the line indicating no background species is not found in the html (i.e., if there are background species)
            r.recordings(nrec).bkgd=1;
        else r.recordings(nrec).bkgd=0;
        end        
        
% download file
        filewav=[r.recordings(nrec).id '.wav']; % name for the .wav file
        URL=['https:' r.recordings(nrec).file]; % URL where the audio can be downloaded from
        system(['wget ' URL ]); % get audio file located at that URL
         if ~exist([wgetDir '\download'], 'file')==0 % if the audio file was successfully downloaded
            r.recordings(nrec).dwnld=1;
            audio=audioread('download');
            r.recordings(nrec).sec=length(audio)/r.recordings(nrec).fs; % length of the audio file, in seconds
            audiowrite(filewav,audio,r.recordings(nrec).fs) % convert to .wav file
            system(['move ' filewav ' ' dwnldDir '\' folder '\' filewav ]); % move to destination folder (for some reason, I can't use wget unless the .exe file in the current directory, so I'd have to put it in each destination folder if I didn't want to change folders)
            delete('download') % delete file from folder with wget.exe file 
         else r.recordings(nrec).dwnld=0; % the audio file wasn't downloaded
         end
    end    
    recMeta(nspec).N_noBkgd=sum([r.recordings.bkgd]); % number of recordings witout background species
    recMeta(nspec).T_sec=sum([r.recordings.sec]); % total seconds of audio for each species
    recMeta(nspec).noDwnld=find([r.recordings.dwnld]==0); % list which recordings were not successfully downloaded
    recDet=[recDet; r.recordings]; % details about each recording (all species in one structure)
end
end


