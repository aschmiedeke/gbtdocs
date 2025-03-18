;+
; Convert the given x-axis value to channels assuming that the x-axis
; values are in the same units and settings of the currently displayed
; x-axis.
;
; @param xvalues {in}{required}{type=array} The x-axis values to
; convert.
;
; @keyword dc {in}{optional}{type=data container} An alternative data
; container to use. If not supplied, the most recently plotted (via
; show) data container is used.
;
; @returns The converted channel numbers.
;
; @version $Id$
;-
function xtochan, xvalues, dc=dc
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if n_elements(dc) eq 0 then begin
        dc = *mystate.dc_ptr
        if data_valid(dc) le 0 then begin
            if !g.line then begin
                dc = !g.s[0]
            endif else begin
                dc = !g.c[0]
            endelse
        endif
    endif

    if (data_valid(dc) le 0) then return, xvalues

    result = convertxvalues(dc, xvalues, mystate.xscale, mystate.xtype, $
                            mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                            1.0d, 0, '', '', 0.0d, 0.0d)
    return, result
end
