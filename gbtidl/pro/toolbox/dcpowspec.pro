;+
; Compute the power spectrum for the supplied data container, which
; is overwritten with the result.  Uses 
; <a href="../toolbox/dcfft.html#_dcfft">dcfft</a> to do the fft.  This is simply
; the sum of squares of the real and imaginary parts of the fft on the
; data.
;
; @param dc {in}{out}{required}{type=data container} The data
; container to use for both input and output.
;
; @uses <a href="../toolbox/dcfft.html#_dcfft">dcfft</a>
;
; @version $Id$
;-
pro dcpowspec,dc
    compile_opt idl2

    if n_elements(dc) eq 0 then begin
        message,'Usage: dcpowspec, dc',/info
        return
    endif

    if data_valid(dc) le 0 then begin
        message, 'dc does not contain any valid data',/info
        return
    endif
    f = dcfft(dc)
    setdcdata,dc,real_part(f)^2 + imaginary(f)^2
end

