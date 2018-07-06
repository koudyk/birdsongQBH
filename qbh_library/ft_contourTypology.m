function [ contourType ] = ft_contourTypology( pitchCurve_octaves )
% ft_countourTypology - categorize the type of contour in the pitch
% curve using Adam's (1976) 15 categories of melodic contour
% typologies

% The types are defined in Table 3 on p. 196 of:
% Adams, C. R. (1976). Melodic contour typology. Ethnomusicology, 179-215.


% QUANTIZE PITCH TO AVOID SMALL PITCH VARIATIONS AFFECTING THE CONTOUR
% TYPE (as done by Salamon, Rocha, and Gomez (2012))
pitchCurve_cents = pitchCurve_octaves*1200; % octaves to cents
pitchCurve_semitones = round(pitchCurve_cents/100); % cents to semitones

I = pitchCurve_semitones(1); % INITIAL pitch
F = pitchCurve_semitones(end); % FINAL pitch
H = max(pitchCurve_semitones); % HIGHEST pitch
L = min(pitchCurve_semitones); % LOWEST pitch

if H==I && I>F  && F==L, contourType = 1;  end
if H>I  && I>F  && F==L, contourType = 2;  end
if H==I && I>F  && F>L,  contourType = 3;  end
if H>I  && I>F  && F>H,  contourType = 4;  end

if H==I && I==F && F==L, contourType = 5;  end
if H>I  && I==F && F==L, contourType = 6;  end
if H==I && I==F && F>L,  contourType = 7;  end
if H>I  && I==F && F>L,  contourType = 8;  end

if L==I && I<F  && F==L, contourType = 9;  end
if L==I && I<F  && F<L,  contourType = 10; end
if L<I  && I<F  && F==L, contourType = 11; end
if L<I  && I<F  && F<L,  contourType = 12; end

end
