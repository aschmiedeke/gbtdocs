;+
; This procedure allows the user to specify baseline regions using
; the mouse. 
; <p>
; Use the left mouse button to mark the regions to be fit.  Vertical
; lines will be drawn at each click.  Use the right mouse button to
; exit (the right-click does NOT register a mark for the baseline
; range.)  A box will then be drawn to identify the ranges just set,
; where the upper and lower bounds of the box are mean + sigma and
; mean - sigma.
;
; <p><a href="../plotter/showregion.html">showregion</a> can be used to show the current region boxes at 
; any time.  The boxes can be made permanently visible on the plotter
; by setting the !g.regionboxes value to 1.
;
; @version $Id$
;-
pro setregion
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if data_valid(getplotterdc()) le 0 then begin
        message,'Nothing has been plotted',/info
        return
    endif
    npts = 0
    xpts = lonarr(200)
    vmarks = lonarr(200)
    yrange = mystate.yrange

    showregion,/off

    print, 'Use the left button to mark the region and the right button to exit'

    while (1) do begin
        c = click()

        if (c.button eq 4) then break
        if (c.button eq 2) then continue

        gbtoplot,[c.x,c.x],yrange,color=!white,index=index
        xpts[npts] = c.chan
        vmarks[npts] = index
        npts += 1
    endwhile

    if (npts le 0) then return

    indx = lindgen(npts)

    nregion, xpts[indx]
    clearoplots,index=vmarks[indx]

    showregion
end
