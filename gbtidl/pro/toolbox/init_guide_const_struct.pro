;+
; Initialize the GBTIDL guide_const_struct that holds physical constants.
; This is called by the startup script and probably should 
; not be called by the user.  Users of toolbox functions that make use
; of these physical constants outside of the GUIDE environment,
; need to call this procedure before using those toolbox procedures 
; and functions.
;
; @private_file
;
; @version $Id$
;-

PRO init_guide_const_struct
    ; see if we've been here before
    defsysv,'!gc',exist=exist
    if (not exist) then begin
        @guide_const_struct
        gc = {guide_const_struct}
        gc.light_speed = 2.99792458d8   ; speed of light in m/s
        gc.light_c = 2.99792458D+5      ; speed of light in km/sec
        gc.plank_h = 6.6260755D-27      ; Planck constant
        gc.newt_g =  6.67259D-8         ; Newton gravitational constant dyne cm^2 gm^-2
        gc.boltz_k = 1.380658D-16       ; Boltzman constant erg K-1
        gc.eV2erg =  1.60217733D-12     ; 1 eV to ergs
        gc.AU =      1.4960D+13         ; AU in cm
        gc.m_H =     1.673534D-24       ; hydrogen mass in gm
        gc.m_e =     9.1093897D-28      ; electron mass in gm
        gc.pc =      3.0857D+18         ; pc in cm
        gc.rad_sig = 5.67051D-5         ; radiation constant in erg cm-2 s-1 K-4

        ; make it read-only
        defsysv, '!gc', gc, 1
    endif
END
