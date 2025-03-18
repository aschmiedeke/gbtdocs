;+
; Set the y-axis range either directly or with the cursor.  If
; interacting via the cursor, mouse button 3 aborts out of this
; function without changing the y-axis range.
;
; @param y1 {in}{optional}{type=double} Desired minimum y-axis value
; in the current y-axis units.  If not supplied, the cursor will be
; used to set this.
;
; @param y2 {in}{optional}{type=double} Desired maxiumum y-axis
; value in the current y-axis units.  This must be supplied if y1
; has also been supplied.
;
; If y2 is less than y1, this procedure will reverse them
; internally before they are used.
; 
; @version $Id$ 
;-
pro sety,y1,y2
    common gbtplot_common,mystate,xarray
    if (n_params() eq 1) then begin
        message,'Usage: sety, [y1, y2] ; supply both or neither of y1 and y2, not 1 argument',/info
        return
    endif else begin
        if (n_params() eq 0) then begin
            ; get y1 and y2 via cursor calls
            c = click()
            if (c.button eq 4) then return else y1=c.y
            gbtoplot,[mystate.xrange],[y1,y1],color=!cyan,index=index
            c = click()
            clearoplots,index=index
            if (c.button eq 4) then return else y2=c.y
        endif
    endelse
    ymin = y1<y2
    ymax = y1>y2
    ; watch for repeat calls with same arguments
    if (ymin eq mystate.yrange[0] and ymax eq mystate.yrange[1]) then return
    xmin = mystate.xrange[0]
    xmax = mystate.xrange[1]
    mystate.yfix = 1
    gbtzoom, xmin, xmax, ymin, ymax
return
end

