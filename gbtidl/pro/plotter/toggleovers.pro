; docformat = 'rst'

;+
; Toggle the overlays (oshows and gbtoplots) on and off.  Use the ``/on``
; or ``/off`` keywords to ensure that the overlays are either on or off
; (otherwise it simply toggles the state).
;
; If both ``/on`` and ``/off`` are used at the same time, an error message
; is printed and the state of the zero line is not changed.
;
; :Keywords:
;   on : in, optional, type=boolean
;       Turn the overlays on.
;   off : in, optional, type=boolean
;       Turn the overlays off.
;
;-
pro toggleovers, on=on, off=off
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if keyword_set(on) and keyword_set(off) then begin
        message,'/on and /off can not be used at the same time',/info
        return
    endif

    newOPstate = mystate.overplots
    newOSstate = mystate.overshows

    if keyword_set(on) then begin
        newOPstate = 1
        newOSstate = 1
    endif else begin
        if keyword_set(off) then begin
            newOPstate = 0
            newOSstate = 0
        endif else begin
            newOPstate = 1-mystate.overplots
            newOSstate = 1-mystate.overshows
        endelse
    endelse

    if mystate.overplots ne newOPstate or mystate.overshows ne newOSstate then begin
        mystate.overplots = newOPstate
        mystate.overshows = newOSstate
        reshow
    endif
end
    
