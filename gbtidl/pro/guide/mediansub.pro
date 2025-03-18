;+
; Subtract the median filtered values of the given width, in channels,
; from the data.   The result replaces the original data values. 
;
; <p>Uses the IDL MEDIAN function to get the median filtered array.
; 
; @param width {in}{required}{type=integer} The desired number of
; channels to use in performing the median filter.
; @keyword buffer {in}{optional}{type=integer}{default=0} The data container to
; use.  This defaults to the primary data container (0).
; 
; @examples
; <pre>
;    ; subtract a median filter of width 200 channels
;    mediansub,200
; </pre>
;
; @uses <a href="../toolbox/dcmediansub.html">dcmediansub</a>
;
; @version $Id$
;-

pro mediansub, width, buffer=buffer
    compile_opt idl2

    if n_elements(width) eq 0 then begin
        usage,'mediansub'
        return
    endif

    thisbuffer = 0
    if n_elements(buffer) ne 0 then thisbuffer = buffer

    if thisbuffer lt 0 or thisbuffer gt n_elements(!g.s) then begin
        message,string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
        return
    endif

    ; OK here because nothing by the data values are changed
    dcmediansub, !g.s[thisbuffer], width, ok=ok
    if not ok then return

    if not !g.frozen then show
end

