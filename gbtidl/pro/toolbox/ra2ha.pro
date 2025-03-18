;+
; Convert a Right Ascension (RA) in degrees to an hour angle (HA) in
; degrees using the given LST in seconds. 
; 
; <p>The returned value (HA) is always between -180.0 and +180.0.  
; This works for vectors (lst must either be a single scalar or
; a vector of the same length as the RA argument).
;
; @param ra {in}{required}{type=floating point} The right ascensions(s) to
; convert (in degrees).
;
; @param lst {in}{required}{type=floating point} The LST (in seconds)
; to use in the conversion.  If this is a vector, it must have the
; same number of elements as ra.
;
; @returns HA (hour angle) in degrees.  The returned value is
; always between -180. and 180.0.  Returns NaN on error (missing
; arguments or bad number of elements in lst).
;
; @version $Id$
;-
function ra2ha, ra, lst
   compile_opt idl2
   
   if n_elements(ra) eq 0 or n_elements(lst) eq 0 then begin
       usage, 'ra2ha'
       return, !values.d_nan
   endif

   if n_elements(lst) ne 1 and n_elements(lst) ne n_elements(ra) then begin
       message,'lst must have only 1 element or the same number of elements as ra',/info
       return, !values.d_nan
   endif

   ha = 15.0 * lst/3600.0 - ra
   indx = where(ha gt 180.)
   if indx[0] ge 0 then ha[indx] -= 360.0
   indx = where(ha lt -180.)
   if indx[0] ge 0 then ha[indx] += 360.0

   return, ha
end
