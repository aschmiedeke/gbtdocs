;+
; Procedure to show the regions in !g.regions (baseline regions).
;
; <p>Previously shown regions are first erased and then the current
; regions are shown on the plotter as boxes where the y-size of each
; box it the RMS of the data within that box.  You must set the the
; value of !g.regionboxes to 1 if you want these region boxes to 
; persist when a new spectrum is plotted using <b>show</b>.  The default
; behavior (!g.regionboxes=0) is to clear all overlaid plots,
; including region boxes, on each use of <b>show</b>.
;
; <p>The idstring used when plotting the boxes is '__showregion'.  
; That can be used in <b>gbtoplots</b> to turn off just these regions.
; Any region that already contains that id string will be removed by
; this procedure.
;
; @keyword off {in}{optional}{type=boolean} If set, the regions are
; turned off on the plotter and no new regions are drawn. The regions
; remain set in !g.regions, they are simply not shown in the plotter.
;
; @version $Id$
;-
pro showregion, off=off
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if not keyword_set(off) then begin
        ; first, clear any previously shown regions
        clearoplots, idstring='__showregion'

        for i = 0, !g.nregion-1 do begin
            rmsbox, !g.regions[0,i], !g.regions[1,i], *(*mystate.dc_ptr).data_ptr, idstring='__showregion'
        endfor
        mystate.showRegions = 1
    endif else begin
        mystate.showRegions = 0
        reshow
    endelse
end
