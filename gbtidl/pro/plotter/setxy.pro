; docformat = 'rst'

;+
; Use a box cursor to set the x-axis and y-axis scaling or provide
; those values directly.
;
; If there are no arguments, then gbtbox_cursor is used to set the
; region of interest. 
; 
;   * Click Left button to set box bottom right corner.
;   * Drag Left button to move box.
;   * Drag Middle button near a corner to resize box.
;   * Right button when done.
; 
; If any one argument is present, they must all be present.
;
; :Params:
;   xmin : in, optional, type=double
;       The desired new minimum x value.
;   xmax : in, optional, type=double
;       The desired new maximum x value.
;   ymin : in, optional, type=double 
;       The desired new minimum y value.
;   ymax : in, optional, type=double 
;       The desired new maximum y value.
;
;-
pro setxy,xmin,xmax,ymin,ymax
    common gbtplot_common,mystate,xarray


    if ((n_params() gt 0) and (n_params() lt 4)) then begin
        message,'Usage: setxy,xmin,xmax,ymin,ymax',/info
        return
    endif

    if (n_params() eq 0) then begin
        ok = gbtplot()
        if not ok then begin
            message,'No plotter!  Check your DISPLAY environment variable setting.',/info
            return
        endif

        ; set initial position of box_cursor 
        c = click()
        x0=c.xdevice
        y0=c.ydevice
        nx=50
        ny=50

        gbtbox_cursor,x0,y0,nx,ny,/init,/message

        blc=[x0,    y0,    0.]
        brc=[x0+nx, y0,    0.]
        tlc=[x0,    y0+ny, 0.]
        trc=[x0+nx, y0+ny, 0.]

        oldwin = !d.window
        wset, mystate.win_id
        blc=convert_coord(blc,/device,/to_data)
        brc=convert_coord(brc,/device,/to_data)
        tlc=convert_coord(tlc,/device,/to_data)
        trc=convert_coord(trc,/device,/to_data)
        wset,oldwin

        xmin=blc[0] & xmax=brc[0] &
        ymin=blc[1] & ymax=tlc[1] &
    endif

    ; watch for repeat calls with same arguments
    if (xmin eq mystate.xrange[0] and xmax eq mystate.xrange[1] and $
        ymin eq mystate.yrange[0] and ymax eq mystate.yrange[1]) then return

    mystate.xfix = 1
    mystate.yfix = 1
    gbtzoom, xmin, xmax, ymin, ymax

    return
end
