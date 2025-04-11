; docformat = 'rst'

;+
; Set the x-axis range either directly or with the cursor.  If
; interacting via the cursor, mouse button 3 aborts out of this
; function without changing the x-axis range.
;
; :Params:
;   x1 : in, optional, type=double
;       Desired minimum x-axis value in the current x-axis units.
;       If not supplied, the cursor will be used to set this.
;
;   x2 : in, optional, type=double
;       Desired maxiumum x-axis value in the current x-axis units.
;       This must be supplied if x1 has also been supplied.
;
; :Note:
;   If x2 is less than x1, this procedure will reverse them
;   internally before they are used.
; 
;-
pro setx,x1,x2
    common gbtplot_common,mystate,xarray
    if (n_params() eq 1) then begin
        message,'Usage: setx, [x1, x2] ; supply both or neither of x1 and x2, not 1 argument',/info
        return
    endif else begin
        if (n_params() eq 0) then begin
            ; get x1 and x2 via cursor calls
            c = click()
            if (c.button eq 4) then return else x1=c.x
            gbtoplot,[x1,x1],[mystate.yrange],color=!cyan,index=index
            c = click()
            clearoplots,index=index
            if (c.button eq 4) then return else x2=c.x
        endif
    endelse
    xmin = x1<x2
    xmax = x1>x2
    ; watch for repeat calls with same arguments
    if (xmin eq mystate.xrange[0] and xmax eq mystate.xrange[1]) then return

    ymin = mystate.yrange[0]
    ymax = mystate.yrange[1]
    mystate.xfix = 1
    gbtzoom, xmin, xmax, ymin, ymax
return
end

