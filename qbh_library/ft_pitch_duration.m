function [ fv_pd, label] = ft_pitch_duration( pc, hop_a_samples, fs_a )

% ft_pitch_duration - calculates the pitch- and duration-related
% features of a pitch curve, as listed in:
%
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
%   Musical genre classification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%

if nargin<3 || isempty(fs_a), fs_a=44100; end
if nargin<2 || isempty(hop_a_samples), hop_a_samples=82; end

% SEGMENT AND CONCATENATE PITCH CURVE
[pc_seg, pc_concat] = pc_segConcat(pc);
Nseg=length(pc_seg);

% initialize
temp=zeros(1,Nseg);
t_perSeg = temp;
mu_p_perSeg = temp;
sigma_p_perSeg = temp;
r_p_perSeg = temp;
tv_perSeg = temp;


% FEATURES PER SEGMENT
for nseg=1:Nseg
    pc = pc_seg{nseg};
    N = length(pc);
    t_perSeg(nseg) = N * hop_a_samples / fs_a;
    mu_p_perSeg(nseg) = nanmean(pc); 
    sigma_p_perSeg(nseg) = nanstd(pc); 
    r_p_perSeg(nseg) = max(pc) - min(pc); 
    tv_perSeg(nseg) = nanmean(abs( [0 pc]-[pc 0])); 
end
Mt = mean(t_perSeg);
Mmu_p = mean(mu_p_perSeg); 
Msigma_p = mean(sigma_p_perSeg); 
Mr_p = mean(r_p_perSeg); 
Mtv = mean(tv_perSeg); 

% FEATURES FOR CONCATENATED SEGMENTS
N = length(pc_concat);
t = N * hop_a_samples / fs_a; % duration (sec)
mu_p = mean(pc_concat); % mean pitch height (cents)
sigma_p = std(pc_concat); % pitch deviation (cents)
r_p = max(pc_concat) - min(pc_concat); % pitch range (cents)
if isempty(r_p),r_p=NaN; end
tv = mean(abs( [0 pc_concat]-[pc_concat 0])); % total variation (cents (??))

fv_pd = [t mu_p sigma_p r_p tv Mt Mmu_p Msigma_p Mr_p Mtv]';
label={'duration (sec)','mean pitch height (cents)','pitch deviation (cents)',...
    'pitch range (cents)','total variation in pitch (cents)',...
    'mean duration of segments (sec)','mean mean pitch heigh of segments (sec)',...
    'mean pitch deviation of segments (sec)','mean pitch range of segments (cents)',...
    'mean total variation of segments (cents?)'}';


end