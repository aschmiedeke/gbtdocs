;+
; Set the units and convert the data to those units using the model
; described here.  
;
; <p>This assumes that the units in the data container are in Ta,
; which is what they are immediately after the initial standard
; calibration (e.g. <a href="dofreqswitch.html">dofreqswitch</a>).
; There is no attempt to look at the units field in the data container
; to see if this is appropriate or to undo any previous unit
; conversion prior to applying this conversion.
;
; <p>The recognized units and their associated scale factors are:
; <ul><li>Ta - data are unchanged
; <li> Ta* - scale = exp(tau/sin(elevation))/0.99
; <li> Jy - scale = exp(tau/sin(elevation))/0.99 / (2.85*ap_eff)
; </ul>
; The elevation is taken directly from the data container.  Tau, the
; zenith opacity, may be supplied by the user. If not supplied, then
; the <a href="get_tau.html">get_tau</a> function is used, using the
; observed_frequency value from the data container.  The aperture
; efficiency (ap_eff) can also be supplied by the user.  If not
; supplied then the <a href="get_ap_eff.html">get_ap_eff</a> function
; is used, using the observed_frequency from the data container.
;
; <p>Users are strongly encouraged to supply values for these keywords
; since the defaults are not very accurate.
; 
; @param dc {in}{required}{type=data container} The data container to
; use.
; @param units {in}{optional}{type=string}{default='Ta'} The units to
; set, chosen from 'Ta','Ta*',and 'Jy'.
; @keyword tau {in}{optional}{type=float} tau at zenith
; @keyword ap_eff {in}{optional}{type=float} aperture efficiency
; @keyword ret_tau {out}{optional}{type=float} The tau actually used
; here.
; @keyword ret_ap_eff {out}{optional}{type=float} The ap_eff actually
; used here.
; @keyword ok {out}{optional}{type=boolean} This is 0 (false) if the
; units were unrecognized or tau and ap_eff were not between 0 and 1.
; In that case, the data are unchanged.  Otherwise this is 1 (true).
;
; @version $Id$
;-
pro dcsetunits,dc,units,tau=tau,ap_eff=ap_eff,$
               ret_tau=ret_tau,ret_ap_eff=ret_ap_eff,ok=ok
    compile_opt idl2

    ok = 0
    if n_elements(dc) eq 0 then begin
        usage,'dcsetunits'
        return
    endif

    if n_elements(units) eq 0 then begin
        thisUnits = 'Ta'
    endif else begin
        thisUnits = units
    endelse

    if n_elements(tau) eq 0 then begin
        ret_tau = get_tau(dc.observed_frequency/1.0e9)
    endif else begin
        ret_tau = tau
    endelse

    if ret_tau lt 0.0 or ret_tau gt 1.0 then begin
        message,'Invalid tau value - it should be between 0 and 1',/info
        return
    endif

    if n_elements(ap_eff) eq 0 then begin
        ret_ap_eff = get_ap_eff(dc.observed_frequency/1.0e9)
    endif else begin
        ret_ap_eff = ap_eff
    endelse

    if ret_ap_eff lt 0.0 or ret_ap_eff gt 1.0 then begin
        message,'Invalid ap_eff value - it should be between 0 and 1',/info
        return
    endif

    if thisUnits eq 'Jy' or thisUnits eq 'Ta*' then begin
        ; apply opacity and spillover

        correction = exp(ret_tau/sin(dc.elevation*!pi/180.0))/0.99
        if thisUnits eq 'Jy' then begin
            ; and unit conversion
            correction /= (2.85 * ret_ap_eff)
        endif
        *dc.data_ptr *= correction
    endif else begin
        if thisUnits ne 'Ta' then begin
            message,'Unrecognized units - must be one of Ta, Ta* or Jy',/info
            return
        endif
    endelse
    dc.units = thisUnits
    ok = 1
end
