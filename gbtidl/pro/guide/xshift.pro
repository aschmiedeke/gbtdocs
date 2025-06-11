; docformat = 'rst' 

;+ 
; This function returns a value that, when given as the argument to
; gshift, will shift the primary data container such that it is aligned
; in the current displayed x-axis with the data in the 
; accumulation buffer.  If there is no ongoing accumulation then this
; function returns 0.  The units of the returned value are channels.
; The primary data container must be shifted that many channels in
; order to align in the current x-axis with the data in the
; accumulation buffer.
;
; You can use an alternate data container by setting ``buffer``.  You
; can use an alternate global accumulation buffer by setting ``accumnum``.
;
; :Params:
;   accumnum : in, type=integer, default=0
;       accum buffer to use. Defaults to the primary buffer, 0. There
;       are 4 buffers total so this value must be between 0 and 3,
;       inclusive.
;
; :Keywords:
;   buffer : in, optional, type=integer, default=0
;       The data container that will eventually be shifted. Defaults
;       to the primary data container (0).
;
; :Returns:
;   shift, in channels, to be used as argument to shift. Returns 0.0 on failure.
;
; :Examples:
; 
;   Accumulate several PS scans
; 
;   .. code-block:: IDL
; 
;       sclear          ; clear the accumulation
;       getps, 31       ; get the first scan
;       freeze          ; turn off auto-update of the plotter
;
;       ; at this point, set the X-axis units using the plotter GUI
;
;       accum           ; add the first spectrum to the accumulator
;       getps, 32       ; get the next scan, plotter is not auto-updated
;       gshift,xshift() ; shift to align the spectrum to the accum'ed spectrum
;       accum           ; and add it to the accum buffer
;       unfreeze
;       ave
; 
; :Uses:
;   :idl:pro:`dcxshift`
;
;-
function xshift, accumnum, buffer=buffer
    compile_opt idl2

    on_error, 2

    if not !g.line then begin
        message,'XSHIFT only works in line mode, sorry.',/info
        return,0.0
    endif

    if n_elements(accumnum) eq 0 then accumnum = 0

    if (accumnum lt 0 or accumnum gt 3) then begin
        message,'accumnum must be in the range 0 to 3',/info
        return, 0.0
    endif

    if n_elements(buffer) eq 0 then buffer=0

    if (buffer lt 0 or buffer ge n_elements(!g.s)) then begin
        message,string(n_elements(!g.s),format='("buffer must be >= 0 and < ",i2)'),/info
        return,0.0
    endif
    
    return, dcxshift(!g.accumbuf[accumnum], !g.s[buffer])
end
