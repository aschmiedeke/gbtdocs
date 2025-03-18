;+
; This procedure calibrates a single integration from a position switched scan pair.
; <p>
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
; @param s1 {in}{required}{type=structure}  the data structure from the on or off source scan
; @param s2 {in}{required}{type=structure}  the data structure from the on or off source scan
; @param tau {in}{optional}{type=float} tau at observation elevation
; @param tsys {in}{optional}{type=float} tsys at observation elevation
; @param ap_eff {in}{optional}{type=float} aperture efficiency
; @param smthoff {in}{optional}{type=integer} smooth factor for reference spectrum
; @param units {in}{optional}{type=string} takes the value 'Jy', 'Ta', or 'Ta*'
; same weight (1.0).
; @version $Id$
;
;-
pro dops_v2,s1,s2,tau,tsys,ap_eff,smthoff,units,ret_tsys,ret_tau
    compile_opt idl2
                                                                                                                                    
    elevation = s1.elevation * !pi/180.0
                                                                                                                                    
    nchans = n_elements(*s1.data_ptr)
    pct10 = nchans/10
    pct90 = nchans - pct10
                                                                                                                                    
    ; I assume whatever system temperature is given is correct and does not need to
    ; be corrected for atmosphere.
                                                                                                                                    
    if s2.procedure eq 'OnOff' then begin
        if smthoff gt 1 then off = smooth(*s2.data_ptr,smthoff) $
	   else off=*s2.data_ptr
        !g.s[0].tsys = tsys
        caldata = (*s1.data_ptr - off)/off * tsys
    endif else begin
        if smthoff gt 1 then off1 = smooth(*s1.data_ptr,smthoff) $
	   else off=*s1.data_ptr
        !g.s[0].tsys = tsys
        caldata = (*s2.data_ptr - off)/off * tsys
    endelse
                                                                                                                                    
    *!g.s[0].data_ptr = caldata
                                                                                                                                    
    if units eq 'Jy' or units eq 'Ta*' then begin
        ; apply opacity and spillover here
        correction = exp(tau/sin(elevation))*.99
        ; this much is common to Ta* and Jy
        *!g.s[0].data_ptr *= correction
        if units eq 'Jy' then begin
            *!g.s[0].data_ptr /= (2.85 * ap_eff)
        endif
    endif
    !g.s[0].units = units
    ret_tsys = tsys
    ret_tau = tau/sin(elevation)
end

