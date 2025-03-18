;+
; Plot a data container on top of (over) the current plot.
; The x-axis will be automatically constructed to match that of the
; current plot.  If the plot is not zoomed, the x and y range will be
; adjusted to accomodate this data along with all previously plotted
; data. If overlays are turned off, calling this automatically turns
; it on. 
;
; @param dc {in}{optional}{type=data container or integer}{default=0} The data container
; to over plot.  If an integer is entered here, it is the global
; buffer number to over plot.  If not specified, the primary (0) data
; container is used.
;
; @keyword color {in}{optional}{type=color}{default=!g.oshowcolor} A color to use when
; drawing the line.
;
; @examples
; <pre>
;    getrec,1   ; retrieve record 1 into !g.s[0]
;    copy,0,1   ; copy the data container !g.s[0] to !g.s[1]
;    getrec,2   ; retrieve record 2 into !g.s[0]
;    show,0     ; show record 2
;    oshow,1    ; overlay record 1
; </pre>
;
; @version $Id$
;-
pro oshow, dc, color=color
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    on_error,2

    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif

    if n_elements(dc) eq 0 then dc = !g.line ? !g.s[0] : !g.c[0]

    thisdc = dc

    ; If an integer is passed, use it as a buffer number into the global DC's
    if size(thisdc,/type) ne 8 then begin
        thisdc = long(thisdc)
        if thisdc lt 0 or thisdc gt 15 then begin $
            message,"Bad DC identifier.",/informational
            return
        endif
        thisdc = !g.line ? !g.s[thisdc] : !g.c[thisdc]
    endif

    if (data_valid(thisdc,name=type) le 0) then begin
        message,"Invalid data container",/informational
        return
    endif

    if mystate.line and type ne "SPECTRUM_STRUCT" then begin
        message,"Can not oshow continuum data on a spectrum",/info
        return
    endif
    if not mystate.line and type ne "CONTINUUM_STRUCT" then begin
        message,"Can not oshow spectral line data on continuum",/info
        return
    endif

    if (not mystate.overshows) then mystate.overshows = 1

    if (not keyword_set(color)) then color = !g.oshowcolor

    x = makeplotx(thisdc)
    ostruct = {dc_ptr:ptr_new(/allocate_heap), x:double(x), color:color, next:ptr_new()}
    *ostruct.dc_ptr = data_new()
    data_copy, thisdc, *ostruct.dc_ptr

    ; append to the end of the list
    thisptr = mystate.oshows_ptr
    if (ptr_valid(thisptr)) then begin
        while (1) do begin
            if (not ptr_valid((*thisptr).next)) then begin
                (*thisptr).next = ptr_new(ostruct)
                break
            endif
            thisptr = (*thisptr).next
        endwhile
    endif else begin
        mystate.oshows_ptr = ptr_new(ostruct)
    endelse

    ; and show just this one if the zoom level is > 0
    if (mystate.nzooms gt 0) then begin
        oldwin = !d.window
        wset,mystate.win_id
        nchan = n_elements(*thisdc.data_ptr)
        if (color ge 0) then begin
            oplot, ostruct.x[mystate.bdrop:(nchan-mystate.edrop-1)], (*thisdc.data_ptr)[mystate.bdrop:(nchan-mystate.edrop-1)], color=color
            wset,mystate.pix_id
            oplot, ostruct.x[mystate.bdrop:(nchan-mystate.edrop-1)], (*thisdc.data_ptr)[mystate.bdrop:(nchan-mystate.edrop-1)], color=color
        endif else begin
            oplot, ostruct.x[mystate.bdrop:(nchan-mystate.edrop-1)], (*thisdc.data_ptr)[mystate.bdrop:(nchan-mystate.edrop-1)]
            wset,mystate.pix_id
            oplot, ostruct.x[mystate.bdrop:(nchan-mystate.edrop-1)], (*thisdc.data_ptr)[mystate.bdrop:(nchan-mystate.edrop-1)]
        endelse
        wset,mystate.win_id
        wset,oldwin
    endif else begin
        ; need to do a reshow to possibly rescale the y and x axis
        reshow
    endelse

    end
    
