;+
; <p>
; This function converts poln letters to the standard fits numbers
; The only argument is the polarization.  
;
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
;
; @version $Id$
;
;-
;
function convert_pol,pol

  if (pol eq 'I' or pol eq 'i') then ipol=1
  if (pol eq 'Q' or pol eq 'q') then ipol=2
  if (pol eq 'U' or pol eq 'u') then ipol=3
  if (pol eq 'V' or pol eq 'v') then ipol=4
  if (pol eq 'RR' or pol eq 'rr') then ipol=-1
  if (pol eq 'LL' or pol eq 'll') then ipol=-2
  if (pol eq 'RL' or pol eq 'rl') then ipol=-3
  if (pol eq 'LR' or pol eq 'lr') then ipol=-4
  if (pol eq 'XX' or pol eq 'xx') then ipol=-5
  if (pol eq 'YY' or pol eq 'yy') then ipol=-6
  if (pol eq 'XY' or pol eq 'xy') then ipol=-7
  if (pol eq 'YX' or pol eq 'yx') then ipol=-8

  return,ipol

  end
