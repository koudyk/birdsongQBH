function [ fct, label ] = ft_contourTypology( pc_segs )
% ft_countourTypology - categorize the type of contour in the pitch
% curve using Adam's (1976) 15 categories of melodic contour
% typologies

% typologies.
%
% The types are defined in Table 3 on p. 196 of:
% Adams, C. R. (1976). Melodic contour typology. Ethnomusicology, 179-215.
% https://www.jstor.org/stable/pdf/851015.pdf
%
% and they were used for pitch-curve classelseification in 
% Salamon, J., Rocha, B. M. M., & G?mez, E. (2012, March). 
%   Musical genre classelseification using melody features extracted 
%   from polyphonic music signals. In ICASSP (pp. 81-84).
%
% INPUTS
% pitchCurve_cents - (cents) pitch curve i.g., a T-by-1 vector of
%       pitch values over time.
%
% OUTPUTS
% contourType - an integer between 1 and 12 indicating the type of
%       contour in the pitch curve.
Nseg = length(pc_segs);
ct_segs = zeros(Nseg,12);

for nseg=1:Nseg + 1
    
    if nseg<=Nseg
        pc_cents=pc_segs{nseg};
    else 
        pc_cents=[];
    for nseg=1:Nseg
        pc_cents=[pc_cents pc_segs{nseg}];
    end
    pc_cents(isnan(pc_cents))=[];
    end

    % QUANTIZE PITCH TO AVOID SMALL PITCH VARIATIONS AFFECTING THE CONTOUR
    % TYPE (as done by Salamon, Rocha, and Gomez (2012))
    pc = round(pc_cents/100); % cents to semitones

    I = pc(1); % INITIAL pitch
    F = pc(end); % FINAL pitch
    H = max(pc); % HIGHEST pitch
    L = min(pc); % LOWEST pitch

    if     H==I && I> F && F==L, ct_segs(nseg,1) = 1; 
    elseif H> I && I> F && F==L, ct_segs(nseg,2) = 1;  
    elseif H==I && I> F && F> L, ct_segs(nseg,3) = 1;   
    elseif H> I && I> F && F> L, ct_segs(nseg,4) = 1;  

    elseif H==I && I==F && F==L, ct_segs(nseg,5) = 1; 
    elseif H> I && I==F && F==L, ct_segs(nseg,6) = 1;  
    elseif H==I && I==F && F> L, ct_segs(nseg,7) = 1;   
    elseif H> I && I==F && F> L, ct_segs(nseg,8) = 1; 

    elseif L==I && I< F && F==H, ct_segs(nseg,9) = 1;  
    elseif L==I && I< F && F< H, ct_segs(nseg,10) = 1; 
    elseif L< I && I< F && F==H, ct_segs(nseg,11) = 1; 
    elseif L< I && I< F && F< H, ct_segs(nseg,12) = 1; 

    else disp('ERROR: missing contour types in function')
    end

end

fct=sum(ct_segs(1:Nseg,:));
fct =[fct ct_segs(Nseg+1,:)];

label={'H=I>F=L',...
    'H>I>F=L',...
    'H=I>F>L',...
    'H>I>F>L',...
    ...
    'H=I=F=L',...
    'H>I=F=L',...
    'H=I=F>L',...
    'H>I=F>L',...
    ...
    'L=I<F=H',...
    'L=I<F<H',...
    'L<I<F=H',...
    'L<I<F<H'};
end
