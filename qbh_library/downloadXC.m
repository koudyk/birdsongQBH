function [ recDet, recMeta ] = downloadXC( wgetDir, dwnldDir,names,type,quality,maxQuantity,nums )
%downloadXC 
    % Downloads audio from Xeno-Canto for given bird species and given
    % type of vocalization and quality of recording.
    % NOTE: this function requires the 'wget' function used by the
    % Windows Command Prompt to download the contents of a webpage. 
% INPUTS
    % wgetDir = directory with the wget.exe file
    % dwnldDir = directory where the audio will be downloaded to
    % names = cell array of species names (scientific or common)
    % nums = vector of species numbers
    % type = type of vocalization (call, song, )
    % quality = quality of recording; the quality will be greater than the letter provided(A, B, C, D)
    % maxNum = maximum number of recordings to be downloaded
    
% OUTPUTS
    % recDet = details about each recordings
    % recMeta = meta-information about all the recordings for each species
    % noDownload = list of files that were not successfully downloaded
%
%
% e.g., [ recDet, recMeta ] = downloadXC( 'C:\Users\User\Downloads', 'F:\0.birdsongQBH\audio','northern cardinal','song','C' )
%
% created by Kendra Oudyk 05.2018
if nargout<6, maxQuantity=Inf; end

cd(wgetDir)
recDet=struct([]); % details about each recording

% for searching the html for the given recording's webpage
noBkgdSp='Background</td><td valign=''top''>none'; % if there are no background species in the recording, this string will be found in the html of the given recording's webpage
fsBefore='<tr><td>Sampling rate</td><td>'; % text before the sampling rate in the html of the given recording's webpage
fsAfter=' (Hz)</td></tr>'; % text after the sampling rate in the html of the given recording's webpage

for nspec=1:length(names);
    n=strsplit(names{nspec});
    folder=['spc' num2str(nums(nspec))];
    name_for_URL=[]; % species name (input) for the URL (i.e., with spaces replaced by '%20')
    for nn=1:length(n) 
        folder=[folder '_' n{nn}]; % replace spaces in the bird names with '_' 
        name_for_URL=[name_for_URL n{nn} '%20']; % the '%20' puts a space in the search. Essentially this line replaces the spaces between words in the name with '%20'
    end
    mkdir(dwnldDir, folder)  % folder for audio from given species
    URL_json=['https://www.xeno-canto.org/api/2/recordings?query='... % URL for the json of the list of recordings
        name_for_URL 'type:' type '%20q>:' quality]; 
    r=webread(URL_json);
    %recMeta(nspec).specID=nums(nspec);
    recMeta(nspec).name=names{nspec}; % meta info about the recordings for each species
    r.recordings(cellfun('isempty',strfind({r.recordings.q},'no score'))==0)=[]; % exclude recordings with no quality rating
       
    Ndwnld=min([length(r.recordings) maxQuantity]);
    ndwnld=0;
    for nrec=1:length(r.recordings)
        disp(['--------------species ' num2str(nspec) '/' num2str(length(names)) ' - recording ' num2str(nrec) ...
            ', download ' num2str(ndwnld) '/' num2str(Ndwnld)])
        r.recordings(nrec).id=str2double(r.recordings(nrec).id); % change id from a string to a number
        r.recordings(nrec).extra=0;
        r.recordings(nrec).bkgd=0;
        r.recordings(nrec).error=0;
        r.recordings(nrec).dwnld=0;
        
        if nrec<=Ndwnld % if it isn't over the desidred number of files
            html=webread(r.recordings(nrec).url); % download html

% CHECK FOR BACKGROUND SPECIES (on html, not json)
            if ~isempty(strfind(html,noBkgdSp)) % if the line indicating no background species is  found in the html (i.e., if there are NO background species)
                r.recordings(nrec).bkgd=0; % 0 indicates no background species (at least, none indicated)  
              
% ATTEMPT TO DOWNLOAD FILE
                if ~exist([wgetDir '\download'], 'file')==0, delete('download'), end % if a previous audio file exists, delete it
                URL=['https:' r.recordings(nrec).file]; % URL where the audio can be downloaded from
                system(['wget ' URL ]); % get audio file located at that URL

% SAVE AS .WAV IF IT DOWNLOADS
                if ~exist([wgetDir '\download'], 'file')==0  % if the audio file was successfully downloaded
                        ndwnld=ndwnld+1;
                        audio=audioread('download');
                        r.recordings(nrec).fs=str2double( html( ... % sampling rate
                            strfind(html,fsBefore)+length(fsBefore)  : ...
                            strfind(html,fsAfter)  ) ); 
                        filewav=['spc' num2str(nums(nspec)) '_xc' num2str(r.recordings(nrec).id) '.wav']; % name for the .wav file
                        audiowrite(filewav,audio,r.recordings(nrec).fs) % convert to .wav file
                        system(['move ' filewav ' ' dwnldDir '\' folder '\' filewav ]); % move to destination folder (for some reason, I can't use wget unless the .exe file in the current directory, so I'd have to put it in each destination folder if I didn't want to change folders)
                        delete('download') % delete file from folder with wget.exe file 

% METADATA - RECORDINGS  
                        r.recordings(nrec).dwnld=1; % 1 indicates the audio was downloaded
                        r.recordings(nrec).sec=length(audio)/r.recordings(nrec).fs; % length of the audio file, in seconds

                else r.recordings(nrec).error=1; % the audio file wasn't downloaded because of some error
                end % no error?  
            else r.recordings(nrec).bkgd=1; % 1 indicates presence of background species
            end % no bkgrnd?
        else r.recordings(nrec).extra=1; % it was because there were already enough files downloaded
        end % <=Ndwnld? 
    end % nrec
% METADATA - SPECIES
    r.species.num_dwnld=sum([r.recordings.dwnld]);
    r.species.total_time_sec=sum([r.recordings.sec]);
    r.species.noDwnld_bkgdBirds=sum([r.recordings.bkgd]);
    r.species.noDwnld_error=sum([r.recordings.error]);
    r.species.noDwnld_overMaxQuanity=sum([r.recordings.extra]);
    
% METADATA - RECORDINGS - DOWNLOADED RECORDINGS ONLY
    temp=r.recordings;
    temp([temp.dwnld]==0)=[];
    r.recordings_dwnldd=temp;
    
% SAVE in download folder
    metaFileName=['bQBHmeta_' folder(5:end) '_' datestr(now,'yyyy-mm-dd') '.mat'];
    save(fullfile(dwnldDir,metaFileName),'r') 
end % nspec

end

