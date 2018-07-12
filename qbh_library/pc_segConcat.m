function [ pc_seg,pc_concat ] = pc_segConcat( pc )

% SEGMENT PITCH CURVE
pc_seg=segmentPitchCurve(pc); % pitch curve segments
Nseg=length(pc_seg);

% CONCATENATE SEGMENTS
pc_concat=[]; % concatenated pitch curve segments
for nseg=1:Nseg
    pc_concat=[pc_concat pc_seg{nseg}];
end
pc_concat(isnan(pc_concat))=[];

end

