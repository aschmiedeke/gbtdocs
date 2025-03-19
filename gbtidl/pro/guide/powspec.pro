; docformat = 'rst'

;+
; Compute the power spectrum for the indicated data container, which
; is overwritten with the result.  Uses :idl:pro:`dcfft` to do the fft.
; This is simply the sum of squares of the real and imaginary parts of
; the fft on the data.
;
; Use :idl:pro:`dcpowspec` to get the power spectrum for a non-global 
; data container.
;
; :Params:
;   buffer : in, out, optional, type=integer, default=0
;       The global buffer number to use for both input and output.
;
; :Uses:
;   :idl:pro:`dcfft`
;
;-
pro powspec,buffer
    compile_opt idl2

    if n_elements(buffer) eq 0 then buffer=0

    frozen = !g.frozen
    freeze
    if !g.line then begin
        if buffer lt 0 or buffer ge n_elements(!g.s) then begin
            message, string(n_elements(!g.s),format='("buffer must be between 0 and ",i2)'),/info
            if not frozen then unfreeze
            return
        endif
        if data_valid(!g.s[buffer]) le 0 then begin
            message, 'No valid data found at buffer',/info
            if not frozen then unfreeze
            return
        endif
        f = dcfft(!g.s[buffer])
        setdata,real_part(f)^2 + imaginary(f)^2,buffer=buffer
    endif else begin
        if buffer lt 0 or buffer ge n_elements(!g.c) then begin
            message, string(n_elements(!g.c),format='("buffer must be between 0 and ",i2)'),/info
            if not frozen then unfreeze
            return
        endif
        if data_valid(!g.c[buffer]) le 0 then begin
            message, 'No valid data found at buffer',/info
            if not frozen then unfreeze
            return
        endif
        f = dcfft(!g.c[buffer])
        setdata,real_part(f)^2 + imaginary(f)^2,buffer=buffer
    endelse
    if not frozen then begin
        if buffer eq 0 then chan
        unfreeze
        if buffer eq 0 then show
    endif
end

