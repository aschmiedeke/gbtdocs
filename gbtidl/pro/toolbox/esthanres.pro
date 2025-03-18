;+
; Estimate the new frequency_resolution after hanning smoothing
; something with a known old frequency_resolution.
;
; <p>This estimates the new frequency_resolution by assuming that the
; frequeny_resolution is the FWHM of a gaussian response function and
; that the ratio of the widths is equal to the inverse ratio of
; the heights of the response functions before and after the
; smoothing.  Since a hanning function isn't a Gaussian, this
; will be inaccurate to some degree.  The initial response function
; may also not be Gaussian.  Tests against a full convolution as well
; as tests involving noise from real GBT data indicate that this
; estimate is accurate to within a few percent.
;
; <p>The hanning procedure uses this function to adjust the
; frequency_resolution of the data container.
;
; @param oldres {in}{required}{type=float} The frequency_resolution
; in channels before hanning smoothing.
;
; @returns the frequency resolution in channels after hanning
; smoothing.
;
; @examples
; <pre>
;   ; what would the new resolution be of the PDC after hanning
;   ; smoothing
;   print,
;
;   esthanres(!g.s[0].frequency_resolution/abs(!g.s[0].frequency_interval))
; </pre>
;
; @uses <a href="gaussrespfn.html">gaussrespfn</a>
;
; @version $Id$
;-
function esthanres, oldres
    compile_opt idl2

    x = [-1.0,0.0,1.0]
    resp = gaussrespfn(x,oldres)
    newht = total(resp * [0.25,0.5,0.25])
    return, oldres/newht
end
