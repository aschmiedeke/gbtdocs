; docformat = 'rst' 

;+
; Function to return a default zenith opacity, given an
; observing frequency.  Used in the calibration routines.
;
; These values are simply best guesses.  The user should replace
; this routine as required for the program at hand.
;
; :Params:
;   freq : in, required, type=float
;       Observing frequency in GHz
; 
; :Returns:
;   the zenith opacity
; 
; :Examples:
;
;   .. code-block:: IDL
; 
;       apeff = get_ap_eff(18.5)
;       tau = get_tau(18.5)
;       print, apeff, tau
; 
;-
function get_tau,freq

   compile_opt idl2

   ; Check parameters
   if n_elements(freq) ne 1 then begin
      message,"A frequency must be supplied.",/info
      return, 0
   endif
   if freq gt 115.0 then begin
      message,"Frequency out of range.",/info
      return, 0
   endif

   ; Set the aperture efficiency
   if freq gt 52.0 then $
      tau = 0.2 $
   else if freq gt 18.0 and freq lt 26.0 then $
      tau = 0.008 + exp(sqrt(freq))/8000.0 + exp(-(freq-22.2)^2/2.0)/40.0 $
   else $
      tau = 0.008 + exp(sqrt(freq))/8000.0
   return,tau
end
