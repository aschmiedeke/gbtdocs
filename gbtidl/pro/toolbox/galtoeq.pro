; docformat = 'rst' 

;+
; Translate galactic coordinates to equatorial coordiantes.
;
; :Params:
;   glon : in, required, type=double
;       Galactic longitude, in degrees.
;   glat : in, required, type=double
;       Galactic latitude, in degrees.
;   equinox : in, required, type=double
;       The coordinate system EQUINOX in years.
;
; :Returns:
;   double precision [ra,dec] in degrees.
;
; :Uses:
;   `glactc <https://asd.gsfc.nasa.gov/archive/idlastro/ftp/pro/astro/glactc.pro>`_
;   `precess <https://asd.gsfc.nasa.gov/archive/idlastro/ftp/pro/astro/precess.pro>`_
;
;-
function galtoeq, glon, glat, equinox
    compile_opt idl2
    if (equinox lt 1975.0d) then begin
        glactc, ra, dec, 1950.0, glon, glat, 2, /DEGREE, /FK4
    endif else begin
        glactc, ra, dec, 2000.0d, glon, glat, 2, /DEGREE
    endelse
    if equinox ne 1950.0d and equinox ne 2000.0d then begin
        ; need to precess to desired equinox
        if equinox lt 1975.0d then begin
            precess, ra, dec, 1950.0d, equinox, /fk4
        endif else begin
            precess, ra, dec, 2000.0d, equinox
        endelse
    endif
    if n_elements(glon) gt 1 then begin
        result = dblarr(2,n_elements(glon))
        result[0,*] = ra
        result[1,*] = dec
    endif else begin
        result = [ra,dec]
    endelse
    return, result
end
