;+
; Translate equatorial coordiantes to galactic coordinates.
;
; @param ra {in}{required}{type=double} RA, in degrees.
; @param dec {in}{required}{type=double} Dec, in degrees.
; @param equinox {in}{required}{type=double} The coordinate system
; EQUINOX in years.
;
; @returns double precision [glon, glat] in degrees.
;
; @uses <a href="http://idlastro.gsfc.nasa.gov/ftp/pro/astro/glactc.pro">glactc</a>
; @uses <a href="http://idlastro.gsfc.nasa.gov/ftp/pro/astro/precess.pro">precess</a>
;
; @version $Id$
;-
function eqtogal, ra, dec, equinox
    compile_opt idl2
    thisequinox = equinox
    thisra = ra
    thisdec = dec
    if equinox ne 1950.0d and equinox ne 2000.0d then begin
        ; need to precess to nearest of 1950 or 2000
        if equinox lt 1975.0d then begin
            precess, thisra, thisdec, thisequinox, 1950.0d, /fk4
            thisequinox = 1950.0d
        endif else begin
            precess, thisra, thisdec, thisequinox, 2000.0d
            thisequinox = 2000.0d
        endelse
    endif
   if (thisequinox eq 1950.0d) then begin
       glactc, thisra, thisdec, thisequinox, glon, glat, 1, /DEGREE, /FK4
   endif else begin 
       glactc, thisra, thisdec, thisequinox, glon, glat, 1, /DEGREE
   endelse
   if n_elements(ra) gt 1 then begin
       result = dblarr(2,n_elements(ra))
       result[0,*] = glon
       result[1,*] = glat
   endif else begin
       result = [glon,glat]
   endelse
   return, result
end
