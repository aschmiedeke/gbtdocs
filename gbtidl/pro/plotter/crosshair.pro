; docformat = 'rst'

;+
; This procedure toggles a flag to draw a crosshair cursor.  Use the
; /on or /off keywords to ensure that the crosshair is on or off
; (otherwise it simply toggles the state).
;
; If both /on and /off are used at the same time, an error message
; is printed and the state of the zero line is not changed.
;
; :Keywords:
;   on : in, optional, type=boolean
;       Turn the crosshair on.
;   off : in, optional, type=boolean
;       Turn the corrhair off.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       crosshair
;
;-
pro crosshair, on=on, off=off
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if keyword_set(on) and keyword_set(off) then begin
        message,'/on and /off can not be used at the same time',/info
        return
    endif

    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif

    newstate = mystate.crosshair
    if keyword_set(on) then begin
        newstate = 1
    endif else begin
        if keyword_set(off) then begin
            newstate = 0
        endif else begin
            newstate = 1-mystate.crosshair
        endelse
    endelse

    if mystate.crosshair ne newstate then begin
        mystate.crosshair = newstate
        oldwin = !d.window
        wset,mystate.win_id
        device,copy=[0,0,mystate.xsize,mystate.ysize,0,0,mystate.pix_id]
        wset,oldwin
    endif
end

