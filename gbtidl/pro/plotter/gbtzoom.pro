;+
; Set the zoom level in the gbtidl plotter.  This is intended for internal
; plotter use.  Users should use setxy to set the zoom level manually.
;
; @param xmin {in}{required}{type=double} The desired new minimum x value.
; @param xmax {in}{required}{type=double} The desired new maximum x value.
; @param ymin {in}{required}{type=double} The desired new minimum y value.
; @param ymax {in}{required}{type=double} The desired new maximum y value.
;
; @private_file
;
; @version $Id$
;-
pro gbtzoom,xmin,xmax,ymin,ymax
    common gbtplot_common,mystate,xarray

    mystate.xrange = [xmin,xmax]
    mystate.yrange = [ymin,ymax]
    mystate.nzooms = mystate.nzooms+1
    nz1 = mystate.nzooms
    mystate.zoom = 0
    mystate.zoom1[nz1,*] = [xmin,ymin]
    mystate.zoom2[nz1,*] = [xmax,ymax]

    widget_control, mystate.unzoom_button,sensitive=1
    zoom_text = string(mystate.nzooms, format='("Zoom Level:",i3)')
    widget_control,mystate.zoomlabel,set_value=zoom_text
    reshow
    return
end
