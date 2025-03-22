; docformat = 'rst' 

;+
; This procedure truncates, or clips, data values above and below
; specified limits.  Data value can alternatively be blanked using the
; /blank flag. In that case, data values outside the limits are
; replaced by blanks (NaN).
; 
; :Params:
;   datamin : in, required, type=float
;       min value to clip
;   datamax : in, required, type=float
;       max value to clip
; 
; :Keywords:
;   buffer : in, optional, type=integer, default=0
;       which global buffer to use.
;   blank : in, optional, type=boolean
;       Replace clipped values with NaN instead of the clipping limit.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getps,101,plnum=1,ifnum=1
;       show
;       clip,-0.3,1.4,/blank
;       show
;
; :Uses:
;   :idl:pro:`dcclip`
;
;-
pro clip, datamin, datamax, buffer=buffer, blank=blank
    compile_opt idl2

    if n_elements(datamin) eq 0 or n_elements(datamax) eq 0 then begin
        message,'Usage: clip, datamin, datamax [, buffer=buffer]',/info
        return
    end

    if n_elements(buffer) eq 0 then buffer=0

    if !g.line then begin
        if buffer lt 0 or buffer gt n_elements(!g.s) then begin
            message,string(n_elements(!g.s),format='("Buffer must be between 0 and ",i2)'),/info
            return
        endif
        nch=data_valid(!g.s[buffer])
        if nch le 0 then begin
            message, 'No valid data in that data container.',/info
            return
        endif
        if datamin gt datamax then begin
            message,"datamin must be less than datamax.",/info
            message,'Usage: clip, datamin, datamax [, buffer]',/info
            return
        endif
        dcclip, !g.s[buffer], datamin, datamax, blank=blank
    endif else begin
        if buffer lt 0 or buffer gt n_elements(!g.c) then begin
            message,string(n_elements(!g.c),format='("Buffer must be between 0 and ",i2)'),/info
            return
        endif
        nch=data_valid(!g.c[buffer])
        if nch le 0 then begin
            message, 'No valid data in that data container.',/info
            return
        endif
        if datamin gt datamax then begin
            message,"datamin must be less than datamax.",/info
            message,'Usage: clip, datamin, datamax [, buffer]',/info
            return
        endif
        dcclip, !g.c[buffer], datamin, datamax, blank=blank
    endelse
    if not !g.frozen and buffer eq 0 then show
end
