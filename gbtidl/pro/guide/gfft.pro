;+ 
; Do an FFT or an inverse FFT on the data container(s) indicated by
; the arguments.  This always overwrites the data array in those data
; containers with the result.  
;
; <p>In the case of the forward FFT (the default), if a buffer number
; for the imaginary part is omitted, it is assumed that the input
; array is a pure real array (the imaginary part is all 0 and any
; data at the imag_buffer location is ignored on input (and
; overwritten on output).   
;
; <p>The units of the x-axis and the data are not changed here.  The
; user needs to keep track of the state of their data containers.  If
; a non-zero bdrop or edrop are used, the resulting data containers
; will be shortened by that many elements using <a href="../toolbox/dcextract.html">dcextract</a>. 
; Consequently, it may not be appropriate to use the same bdrop and
; edrop on an inverse FFT as it was when the FFT was first done.
;
; <p>See the discussion in <a href="../toolbox/dcfft.html">dcfft</a> on how inverse is used for spectral-line 
; data vs continuum data.  For spectral-line data, an FFT is a
; transformation from frequency to time and an inverse FFT is a
; transformation in the other direction.  For continuum data, an FFT
; is a transformation from time to frequency and an inverse FFT is a
; transformation in the other direction. 
;
; @param real_buffer {in}{out}{optional}{type=integer}{default=0} The
; global buffer number from which the real values going in to the 
; FFT are obtained.  The real values from the result are overwritten 
; to this location.  Defaults to buffer 0.
;
; @param imag_buffer {in}{out}{optional}{type=integer}{default=1} The
; global buffer number from which the imaginary values going in to the
; FFT are obtained.  The imaginary values from the result are
; overwritten to this location.  If this parameter is omitted on the 
; forward transformation (inverse is not set) then the input values 
; are assumed to be all real (the imaginary part is all 0) and any
; data at this location is ignored and overwritten on output. Defaults
; to buffer 1.
;
; @keyword inverse {in}{optional}{type=boolean} When set, the inverse
; FFT is performed as described above.
;
; @keyword bdrop {in}{optional}{type=integer}{default=0} The number of
; channels to exclude from the FFT at the beginning.
;
; @keyword edrop {in}{optional}{type=integer}{default=0} The number of
; channels to exclude from the FFT at the end.
;
; @examples
; <pre>
;   getps, 34    ; get some data
;   gfft         ; uses buffer 0, result in 0 (real) and 1 (imag)
;   oshow, 1
;   gfft, 0, 1, /inverse  ; the other direction
; </pre>
;
; @uses <a href="../toolbox/dcfft.html">dcfft</a>
; @uses <a href="../toolbox/dcextract.html">dcextract</a>
;
; @version $Id$
;-
pro gfft,real_buffer,imag_buffer,inverse=inverse,bdrop=bdrop,edrop=edrop
    compile_opt idl2

    pureReal = 1

    if (n_elements(real_buffer) eq 0) then real_buffer = 0
    if (n_elements(imag_buffer) eq 0) then begin
        imag_buffer = 1
        if (keyword_set(inverse)) then pureReal = 0
    endif else begin
        pureReal = 0
    endelse

    if (!g.line) then begin
        if (real_buffer gt n_elements(!g.s) or real_buffer lt 0) then begin
            message, string((n_elements(!g.s)-1),format='("real_buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        if (imag_buffer gt n_elements(!g.s) or imag_buffer lt 0) then begin
            message, string((n_elements(!g.s)-1),format='("imag_buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        ; real_buffer must have valid data
        nin = data_valid(!g.s[real_buffer])
        if nin le 0 then begin
            message,string(real_buffer,format='("No valid data seen at buffer ",i2)'),/info
            return
        endif
        if pureReal then begin
            data = dcfft(!g.s[real_buffer],inverse=inverse,bdrop=bdrop,edrop=edrop)
        endif else begin
            nout = data_valid(!g.s[imag_buffer])
            if nout le 0 then begin
                message,string(imag_buffer,format='("No valid data seen at buffer ",i2)'),/info
                return
            endif
            if nout ne nin then begin
                message,'Size of data in real_buffer and imag_buffer are not the same',/info
                return
            endif
            data = dcfft(!g.s[real_buffer],!g.s[imag_buffer],inverse=inverse,bdrop=bdrop,edrop=edrop)
        endelse
        ; if data is not complex, a problem occurred, dcfft will have emitted the 
        ; error, just return here
        if size(data,/type) ne 6 then return

        ; dcfft will set bdrop and edrop if not set by here
        if bdrop ne 0 or edrop ne 0 then begin
            newdc = dcextract(!g.s[real_buffer],bdrop,(nin-edrop-1))
            set_data_container,newdc,buffer=real_buffer,/noshow
            data_free,newdc
        endif
        copy,real_buffer,imag_buffer
        setdata,real_part(data),buffer=real_buffer
        setdata,imaginary(data),buffer=imag_buffer
    endif else begin
        if (real_buffer gt n_elements(!g.c) or real_buffer lt 0) then begin
            message, string((n_elements(!g.c)-1),format='("real_buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        if (imag_buffer gt n_elements(!g.c) or imag_buffer lt 0) then begin
            message, string((n_elements(!g.c)-1),format='("imag_buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        ; real_buffer must have valid data
        nin = data_valid(!g.c[real_buffer])
        if nin le 0 then begin
            message,string(real_buffer,format='("No valid data seen at buffer ",i2)'),/info
            return
        endif
        if pureReal then begin
            data = dcfft(!g.c[real_buffer],inverse=inverse,bdrop=bdrop,edrop=edrop)
        endif else begin
            nout = data_valid(!g.c[imag_buffer])
            if nout le 0 then begin
                message,string(imag_buffer,format='("No valid data seen at buffer ",i2)'),/info
                return
            endif
            if nout ne nin then begin
                message,'Size of data in real_buffer and imag_buffer are not the same',/info
                return
            endif
            data = dcfft(!g.c[real_buffer],!g.c[imag_buffer],inverse=inverse,bdrop=bdrop,edrop=edrop)
        endelse
        ; if data is not complex, a problem occurred, dcfft will have emitted the 
        ; error, just return here
        if size(data,/type) ne 6 then return

        ; dcfft will set bdrop and edrop if not set by here
        if bdrop ne 0 or edrop ne 0 then begin
            newdc = dcextract(!g.c[real_buffer],bdrop,(nin-edrop-1))
            set_data_container,newdc,buffer=real_buffer,/noshow
            data_free,newdc
        endif
        copy,real_buffer,imag_buffer
        setdata,real_part(data),buffer=real_buffer
        setdata,imaginary(data),buffer=imag_buffer
    endelse
end
