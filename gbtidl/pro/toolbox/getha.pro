;+
; Return the hour angle (HA) in decimal hours using the given
; data container.  Note that this returns the value in hours, not
; decimal degrees as getradec does.
;
; <p> For continuum data, a vector of hour angles (one at each
; integration) is returned.
;
; @param dc {in}{required}{type=data_container_struct} The data container to
; use.
;
; @returns HA in hours.
;
; @version $Id$
;-
function getha, dc
   hadec = gethadec(dc,/quiet)
   if n_elements(hadec) gt 2 then begin
       ha = hadec[0,*]
   endif else begin
       ha = hadec[0]
   endelse
   ; convert the value(s) to hours and return them
   return, ha/15.0d
end
