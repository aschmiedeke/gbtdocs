;+
; Subtract the median filtered values of the given width, in channels,
; from the data.  The result replaces the original data values. 
;
; <p>Uses the IDL MEDIAN function to get the median filtered array.
; 
; @param dc {in}{required}{type=data container} The data container to
; smooth.
; @param width {in}{required}{type=integer} The desired number of
; channels to use in performing the median filter.
; @keyword ok {out}{optional}{type=boolean} Returns 1 if everything went
; ok, 0 if it did not (missing parameter, empty or invalid dc, bad width).
; 
; @examples
; <pre>
;    ; dc already exists and is a valid data container
;    ; subtract a median filter of width 200
;    dcmediansub,dc,200
; </pre>
;
; @uses <a href="data_valid.html">data_valid</a>
;
; @version $Id$
;-

pro dcmediansub, dc, width, ok=ok
    compile_opt idl2

    ok = 0
    if n_params() ne 2 then begin
        usage,'dcsmediansub'
        return
    endif

    nels = data_valid(dc,name=name)
    if name ne 'SPECTRUM_STRUCT' then begin
        message,'dcsmooth only works on spectrum data containers',/info
        return
    endif
    if nels le 0 then begin
        message,'Data container is empty',/info
        return
    endif
    
    if (n_elements(width) ne 1) then begin
        message,'width must be a scalar, positive integer',/info
        return
    endif

    iwidth = fix(width)
    if width ne iwidth or iwidth le 0 then begin
        message,'width must be a scalar, positive integer',/info
        return
    endif

    (*dc.data_ptr) = (*dc.data_ptr) - median(*dc.data_ptr,iwidth)
    ok = 1
end
