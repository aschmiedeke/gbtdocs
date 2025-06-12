; docformat = 'rst' 

;+
; Function to return a default aperture efficiency, given an
; observing frequency.  Used in the calibration routines.
;
; The formula comes from the Ruze equation, using a surface accuracy
; of 390 microns.  Currently the aperture efficiency returned is
; independent of elevation.  For observations at low elevations it
; is especially important for the observer to bypass the default value
; returned by this routine.
;
; :Params:
;   freq : in, required, type=float
;       Observing frequency in GHz
;   elev : in, optional, type=float
;       Observing elevation in degrees; currently not used.
; 
; :Returns:
;   the aperture efficiency
; 
; :Examples:
; 
;   .. code-block:: IDL
; 
;       apeff = get_ap_eff(18.5)
;       print,apeff
;
;-
function get_ap_eff,freq,elev

   compile_opt idl2

   ; Check parameters
   if n_elements(freq) ne 1 then begin
      message,"A frequency must be supplied.",/info
      return, 0
   endif
   if freq gt 115.0 or freq lt 0.0 then begin
      message,"Frequency out of range.",/info
      return, 0
   endif
   if n_elements(elev) ne 0 then begin
      message,"Elevation is not used in the current version of get_ap_eff",/info
   endif

   ap_eff = 0.71 * exp(-(4.0*!pi*freq*1.0e9*0.039*1.0e-5/!gc.light_c)^2)
   return,ap_eff
end
