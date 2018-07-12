function [ fct, label ] = ft_contourTypology( pc_original )
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



% QUANTIZE PITCH TO AVOID SMALL PITCH VARIATIONS AFFECTING THE CONTOUR
% TYPE (as done by Salamon, Rocha, and Gomez (2012))
%pc_semitones = round(pc_original/100); % cents to semitones 

% SEGMENT AND CONCATENATE PITCH CURVE
[pc_seg, pc_concat] = pc_segConcat(pc_original);
%[pc_seg, pc_concat] = pc_segConcat(pc_semitones);
Nseg=length(pc_seg);

if ~isempty(pc_concat)
% CONCOUR TYPOLOGY FOR SEGMENTS AND FOR CONCATENATED SEGMENTS
    ct = zeros(Nseg,12);
    for nseg=1:Nseg + 1 % plus one because the final one is the concatenated segments
    % SPECIFY PITCH CURVE TO BE CLASSIFIED    
        if nseg<=Nseg, pc=pc_seg{nseg};
        else pc=pc_concat;
        end

    % CALCULATE POINTS USED FOR CLASSIFICATION
        I = pc(1); % INITIAL pitch
        F = pc(end); % FINAL pitch
        H = max(pc); % HIGHEST pitch
        L = min(pc); % LOWEST pitch

    % CLASSIFY
        if     H==I && I> F && F==L, ct(nseg,1) = 1; 
        elseif H> I && I> F && F==L, ct(nseg,2) = 1;  
        elseif H==I && I> F && F> L, ct(nseg,3) = 1;   
        elseif H> I && I> F && F> L, ct(nseg,4) = 1;  

        elseif H==I && I==F && F==L, ct(nseg,5) = 1; 
        elseif H> I && I==F && F==L, ct(nseg,6) = 1;  
        elseif H==I && I==F && F> L, ct(nseg,7) = 1;   
        elseif H> I && I==F && F> L, ct(nseg,8) = 1; 

        elseif L==I && I< F && F==H, ct(nseg,9) = 1;  
        elseif L==I && I< F && F< H, ct(nseg,10) = 1; 
        elseif L< I && I< F && F==H, ct(nseg,11) = 1; 
        elseif L< I && I< F && F< H, ct(nseg,12) = 1; 

        else disp('ERROR: missing contour types in function')
        end

    end
    if Nseg>1;
        fct1=sum(ct(1:Nseg,:))/Nseg;
    else fct1 = ct(1,:);
    end
    fct =[fct1 ct(Nseg+1,:)]';
else fct=zeros(24,1);
end

label={'Proportion of segments with contour type H=I>F=L',...
    'Proportion of segments with contour type H>I>F=L',...
    'Proportion of segments with contour type H=I>F>L',...
    'Proportion of segments with contour type H>I>F>L',...
    ...
    'Proportion of segments with contour type H=I=F=L',...
    'Proportion of segments with contour type H>I=F=L',...
    'Proportion of segments with contour type H=I=F>L',...
    'Proportion of segments with contour type H>I=F>L',...
    ...
    'Proportion of segments with contour type L=I<F=H',...
    'Proportion of segments with contour type L=I<F<H',...
    'Proportion of segments with contour type L<I<F=H',...
    'Proportion of segments with contour type L<I<F<H',...
    ...
    ...
    'Whether concatenated segments are of contour type H=I>F=L',...
    'Whether concatenated segments are of contour type H>I>F=L',...
    'Whether concatenated segments are of contour type H=I>F>L',...
    'Whether concatenated segments are of contour type H>I>F>L',...
    ...
    'Whether concatenated segments are of contour type H=I=F=L',...
    'Whether concatenated segments are of contour type H>I=F=L',...
    'Whether concatenated segments are of contour type H=I=F>L',...
    'Whether concatenated segments are of contour type H>I=F>L',...
    ...
    'Whether concatenated segments are of contour type L=I<F=H',...
    'Whether concatenated segments are of contour type L=I<F<H',...
    'Whether concatenated segments are of contour type L<I<F=H',...
    'Whether concatenated segments are of contour type L<I<F<H'}';
end
