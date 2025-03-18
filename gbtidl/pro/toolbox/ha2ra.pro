;+
; Convert an hour angle (HA) in decimal hours to a Right Ascension (RA) in
; degrees using the given LST in seconds. 
; 
; <p>The returned value (RA) is always a postive number between 0 and
; 360.  This works for vectors (lst must either be a single scalar or
; a vector of the same length as the HA argument).
;
; @param ha {in}{required}{type=floating point} The hour angle(s) to
; convert (in degrees).
;
; @param lst {in}{required}{type=floating point} The LST (in seconds)
; to use in the conversion.  If this is a vector, it must have the
; same number of elements as ha.
;
; @returns RA (right ascension) in degrees.  The returned value is
; always between 0.0 and 360.0.  Returns NaN on error (missing
; arguments or bad number of elements in lst).
;
; @version $Id$
;-
function ha2ra, ha, lst
   compile_opt idl2
   
   if n_elements(ha) eq 0 or n_elements(lst) eq 0 then begin
       usage,'ha2ra'
       return, !values.d_nan
   endif

   if n_elements(lst) ne 1 and n_elements(lst) ne n_elements(ha) then begin
       message,'lst must have only 1 element or the same number of elements as ha',/info
       return, !values.d_nan
   endif

   ra = 15.0 * lst/3600.0 - ha
   indx = where(ra gt 360.)
   if indx[0] ge 0 then ra[indx] -= 360.0
   indx = where(ra lt 0.)
   if indx[0] ge 0 then ra[indx] += 360.0

   return, ra
end
