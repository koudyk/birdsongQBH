function [ featVect_pitch_duration, label] = ...
    ft_pitch_duration_segs( pc_segs, hop_a_samples, fs_a )

% ft_pitch_duration - calculates the pitch- and duration-related
% features of a pitch curve, as listed in:
%
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
%   Musical genre classification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%
if ~iscell(pc_segs), 
    pcs{1,1}=pc_segs;
else pcs=pc_segs;
end

Nseg=length(pcs);

% initialize
temp=zeros(1,Nseg);
t_perSeg = temp;
mu_p_perSeg = temp;
sigma_p_perSeg = temp;
r_p_perSeg = temp;
tv_perSeg = temp;

% FEATURES PER SEGMENT
for nseg=1:Nseg
    pc = pcs{nseg};
    N = length(pc);
    t_perSeg(nseg) = N * hop_a_samples / fs_a; % duration (sec)
    mu_p_perSeg(nseg) = nanmean(pc); % mean pitch height (cents)
    sigma_p_perSeg(nseg) = nanstd(pc); % pitch deviation (cents)
    r_p_perSeg(nseg) = max(pc) - min(pc); % pitch range (cents)
    tv_perSeg(nseg) = nanmean(abs( [0 pc]-[pc 0])); % total variation (cents (??))
end
Mt = mean(t_perSeg); % duration (sec)
Mmu_p = mean(mu_p_perSeg); % mean pitch height (cents)
Msigma_p = mean(sigma_p_perSeg); % pitch deviation (cents)
Mr_p = mean(r_p_perSeg); % pitch range (cents)
Mtv = mean(tv_perSeg); % total variation (cents (??))

% FEATURES FOR WHOLE EXCERPT (I.E., FROM CONCATENATED SEGMENTS
pc_concat=[];
for nseg=1:Nseg
    pc_concat=[pc_concat pc_segs{nseg}];
end
pc_concat(isnan(pc_concat))=[];

N = length(pc_concat);
t = N * hop_a_samples / fs_a; % duration (sec)
mu_p = mean(pc_concat); % mean pitch height (cents)
sigma_p = std(pc_concat); % pitch deviation (cents)
r_p = max(pc_concat) - min(pc_concat); % pitch range (cents)
tv = mean(abs( [0 pc_concat]-[pc_concat 0]));

featVect_pitch_duration = [t mu_p sigma_p r_p tv Mt Mmu_p Msigma_p Mr_p Mtv];
label={'duration (sec)','mean pitch height (cents)','pitch deviation (cents)',...
    'pitch range (cents)','total variation in pitch (cents)',...
    'mean duration of segments (sec)','mean mean pitch heigh of segments (sec)',...
    'mean pitch deviation of segments (sec)','mean pitch range of segments (cents)',...
    'mean total variation of segments (cents?)'};


end


