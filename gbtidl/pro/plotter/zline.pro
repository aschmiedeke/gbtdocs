; docformat = 'rst'

;+
; This procedure toggles a flag to draw a horizontal line on the plot
; at the zero level.  Use the /on or /off keywords to ensure that
; the zero line plot is on or off (otherwise it simply toggles the
; state).
;
; If both /on and /off are used at the same time, an error message
; is printed and the state of the zero line is not changed.
;
; :Keywords:
;   on : in, optional, type=boolean
;       Turn the zero line on.
;   off : in, optional, type=boolean
;       Turn the zero line off.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       zline
;
;-
pro zline, on=on, off=off
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if keyword_set(on) and keyword_set(off) then begin
        message,'/on and /off can not be used at the same time',/info
        return
    endif

    newstate = mystate.zline
    if keyword_set(on) then begin
        newstate = 1
    endif else begin
        if keyword_set(off) then begin
            newstate = 0
        endif else begin
            newstate = 1-mystate.zline
        endelse
    endelse
    if mystate.zline ne newstate then begin
        mystate.zline = newstate
	reshow
    endif
end
