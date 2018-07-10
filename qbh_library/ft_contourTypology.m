function [ fb_ct, label ] = ft_contourTypology( pc_segs )
% ft_countourTypology - categorize the type of contour in the pitch
% curve using Adam's (1976) 15 categories of melodic contour
% typologies.
%
% The types are defined in Table 3 on p. 196 of:
% Adams, C. R. (1976). Melodic contour typology. Ethnomusicology, 179-215.
% https://www.jstor.org/stable/pdf/851015.pdf
%
% and they were used for pitch-curve classelseification in 
% Salamon, J., Rocha, B. M. M., & Gómez, E. (2012, March). 
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

fb_ct = zeros(1,12);
fb_ct = zeros(1,12);
Nseg = length(pc_segs);
for nseg=1:Nseg
    pc_cents=pc_segs{nseg};

    % QUANTIZE PITCH TO AVOID SMALL PITCH VARIATIONS AFFECTING THE CONTOUR
    % TYPE (as done by Salamon, Rocha, and Gomez (2012))
    pc = round(pc_cents/100); % cents to semitones

    I = pc(1); % INITIAL pitch
    F = pc(end); % FINAL pitch
    H = max(pc); % HIGHEST pitch
    L = min(pc); % LOWEST pitch

    
    if     H==I && I> F && F==L, fb_ct(1) = fb_ct(1) +1;  
    elseif H> I && I> F && F==L, fb_ct(2) = fb_ct(2) +1;  
    elseif H==I && I> F && F> L, fb_ct(3) = fb_ct(3) +1;  
    elseif H> I && I> F && F> L, fb_ct(4) = fb_ct(4) +1;  

    elseif H==I && I==F && F==L, fb_ct(5) = fb_ct(5) +1;  
    elseif H> I && I==F && F==L, fb_ct(6) = fb_ct(6) +1;  
    elseif H==I && I==F && F> L, fb_ct(7) = fb_ct(7) +1;  
    elseif H> I && I==F && F> L, fb_ct(8) = fb_ct(8) +1;  

    elseif L==I && I< F && F==H, fb_ct(9)  = fb_ct(9) +1;   
    elseif L==I && I< F && F< H, fb_ct(10) = fb_ct(10) +1; 
    elseif L< I && I< F && F==H, fb_ct(11) = fb_ct(11) +1; 
    elseif L< I && I< F && F< H, fb_ct(12) = fb_ct(12) +1; 

    else disp('ERROR: missing contour types in function')
    end

end

fb_ct = fb_ct/Nseg;

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
