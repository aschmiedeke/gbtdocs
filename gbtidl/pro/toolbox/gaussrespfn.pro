;+
; Gaussian response function.  
;
; <p>This is simply a gaussian function centered at 0.0 with a given
; FWHM in channels.  It is used in esthanres and estboxres to estimate
; the new frequeny_resolution for hanning and boxcar smoothing using
; the old frequency_resolution.  Those methods assume a gaussian
; response function of FWHM = old frequency_resolution.  This function
; supplies those values.  The gaussian has a height of 1.0 at the center.
;
; @param r {in}{required}{type=float} The distance from the center in
; the same units as fwhm.  r may be a vector.
;
; @param fwhm {in}{required}{type=float} The full width and half
; maximum of the gaussian in the same units as r.
;
; @returns The Gaussian evaluated at r.
;
; @private
;
; @version $Id$
;-
function gaussrespfn, r, fwhm
    compile_opt idl2

    oldexcept = !except
    !except = 0  ; turn off underflow messages

    result = exp(-4.0*alog(2.)*(r/fwhm)^2)

    r=check_math()  ; clear any math error status
    !except = oldexcept

    return, result
end
