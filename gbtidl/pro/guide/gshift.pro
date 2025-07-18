; docformat = 'rst' 

;+
; Procedure to shift data in a GUIDE data buffer by a given 
; number of channels.
;
; This uses :idl:pro:`dcshift`. Please read the documentation for that 
; toolbox function for all the details about how shifting of data
; containers is implemented.  This documentation is very thin and is
; primarily useful as a syntax reminder for the usage procedure.
;
; See :idl:pro:`fshift` or :idl:pro:`vshift` for examples showing how
; this is used to align spectra prior to averaging.
;
; :Params:
;   offset : in, required, type=floating point
;       The number of channels to shift the data (positive shifts things
;       towards higher channels, negative shifts things towards lower 
;       channels).
;
; :Keywords:
;   buffer : in, optional, type=integer
;       The GUIDE data buffer to shift. All shifting is done in place
;       and so the data in this buffer is modified by this procedure.
;   wrap : in, optional, type=boolean
;       Data shifted off one end of the array appears on the other end
;       of the array (it wraps around as a result of the shift) when 
;       this is set.  Otherwise, as data is shifted it is blanked 
;       (replaced by NaNs) and data shifted off the end is lost.
;   ftol : in, optional, type=floating point, default=0.01
;       Fractional shifts (the non-integer portion of offset) are only
;       done when they are larger than ftol.  Set this value to >= 1.0
;       to turn off all fractional shifts.
;   linear : in, optional, type=boolean
;       When set, use the linear interpolation provided by INTERPOL for 
;       any fractional shift larger than ftol.
;   quadratic : in, optional, type=boolean
;       When set, use the quadratic interpolation provided by INTERPOL
;       for any fractional shift larger than ftol.
;   lsquadratic : in, optional, type=boolean
;       When set, use the lsquadratic (lest squares quadratic) interpolation
;       provided by INTERPOL for any fractional shift larger than ftol.
;   spline : in, optional, type=boolean
;       When set, use the spline interpolation provided by INTERPOL for
;       any fractional shift larger than ftol.
;   cubic : in, optional, type=boolean
;       When set, use the cubic interpolation provided by INTERPOLATE for any
;       fractional shift larger than ftol.  The value of the CUBIC keyword in
;       the INTERPOLATE call is set to -0.5.
;   nowelsh : in, optional, type=boolean
;       When set, the shifted data is NOT windowed using the Welsh function. 
;       This is ignored when a non-FFT-based fraction shift is done
;   nopad : in, optional, type=boolean
;       When set, the data is NOT padded with 0s to the next higher power of
;       2 prior to the FFT and shift.  The data are never padded for the
;       non-FFT-based fractional shifts.
;   ok : out, optional, type=boolean
;       This is set to 1 on success or 0 on failure (e.g. bad arguments).
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getps, 30
;       accum           ; first in, no alignment needed yet
;       getps, 31
;       fs = fshift()   ; shift to align in frequency
;       gshift, fs      ; actually do the shift
;       accum           ; now it can be added to the accumulation
;       ave
;
; :Uses:
;   :idl:pro:`dcshift`
;   :idl:pro:`DATA_COPY`
;   :idl:pro:`set_data_container`
;   :idl:pro:`DATA_FREE`
;
;-
pro gshift, offset, buffer=buffer, wrap=wrap, ftol=ftol, linear=linear, $
            quadratic=quadratic, lsquadratic=lsquadratic, spline=spline, $
            cubic=cubic, nowelsh=nowelsh, nopad=nopad, ok=ok
    compile_opt idl2

    on_error, 2

    ok = 0

    if not !g.line then begin
        message,"GSHIFT only works in line mode, sorry.",/info
        return
    endif

    if n_elements(offset) eq 0 then begin
        usage,'gshift'
        return
    endif
    
    if keyword_set(buffer) eq 0 then buffer=0

    if (buffer lt 0 or buffer ge n_elements(!g.s)) then begin
        message,string(n_elements(!g.s),format='("buffer must be >= 0 and < ",i2)'),/info
        return
    endif
    
    data_copy,!g.s[buffer],shifted
    dcshift,shifted,offset,wrap=wrap,ftol=ftol,linear=linear,$
            quadratic=quadratic, lsquadratic=lsquadratic, spline=spline, $
            cubic=cubic, nowelsh=nowelsh, nopad=nopad, ok=ok
    if not ok then begin
        message,'There was a problem shifting the data',/info
        if data_valid(shifted) ge 0 then data_free,shift
    endif else begin
        set_data_container,shifted,buffer=buffer
    endelse

    if data_valid(shifted) ge 0 then data_free,shifted
end
