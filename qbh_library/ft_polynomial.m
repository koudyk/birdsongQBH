function [ featVect_polynomial] =  ft_polynomial( pc,hop_samples,fs_a)

if nargin<3, fs_a=44100; end
if nargin<2, hop_samples=82; end

fs_pc = floor(fs_a/hop_samples); % sampling rate of the pitch curve
time = 0:1/fs_pc:length(pc)-1/fs_pc;

degree = 3;
p=polyfit( time,pc,degree);
    


end