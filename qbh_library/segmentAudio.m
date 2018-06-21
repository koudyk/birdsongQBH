function [ segs ] = segmentAudio( audio,annotation,saveSegments,fs )
% INPUTS
%   audio - waveform or audio file (in format readable by audioread)
%   SVannotation - Sonic Visualizer regions annotation layer text file.
%           col 1 - (sec) region onsets
%           col 2 - (nominal) region labels
%           col 3 - (sec) region lengths
%           rows  - segments
%   fs - audio sampling rate (samples/sec). This is only needed if 
%           'audio' is a waveform, not an audio file
%   saveSegments - 1: save segments as waveform .mat files
%          0: don't save
%
% OUTPUTS
%   segs - (waveforms) segments of the waveform of the audio, in a n-by-1 cell
%           array, where n is the number of segments.


% LOAD AUDIO
if ischar(audio)
[a,fs]=audioread(audio);
else a=audio;
    if nargin<4 || isempty(fs), disp('Missing sampling rate'), end
end
a=mean(a,2);

% LOAD ANNOTATION FILE
anno=load(annotation);

% CONVERT ANNOTATION FILE TO FRAMES
begs=floor(anno(:,1)*fs); % beginnings of segments
lens=floor(anno(:,3)*fs); % lengths
fins=begs+lens; % ends of segments
if fins(end)>length(a)
    fins(end)=length(a);
end

% SEGMENT
Nseg=size(anno,1); % total number of segments for given file
segs=cell(Nseg,1);
for nseg=1:Nseg
    seg=a(begs(nseg):fins(nseg));
    segs{nseg,1}=seg;
    if saveSegments==1, 
        fileName= ['SEG_' annotation(1:end-4) '_' num2str(nseg) '_' num2str(fs)];
        save(fileName,'seg')
    end
    
end
  
    
% % METADATA
% meta.id=annotation(2:end-4);
% meta.lens
end

