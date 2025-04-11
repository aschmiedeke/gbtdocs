; docformat = 'rst'

;+
; This procedure unzooms to the full X- and Y-axis ranges
;
; :Keywords:
;   onestep : in, optional, type=boolean
;       When set, just unzoom by one level. This is equivalent to pressing
;       the "Unzoom" button on the plotter.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       unzoom
;
;-
pro unzoom, onestep=onestep
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif
                                                                                
    mystate.zoom = 0

    mystate.nzooms = keyword_set(onestep) ? mystate.nzooms-1 : 0

    if mystate.nzooms le 0 then begin
        ; show actually does most of the resetting for this case
        mystate.xfix = 0
        mystate.yfix = 0
        mystate.nzooms = 0
    endif else begin
        xmin = mystate.zoom1[mystate.nzooms,0]<mystate.zoom2[mystate.nzooms,0]
        xmax = mystate.zoom1[mystate.nzooms,0]>mystate.zoom2[mystate.nzooms,0]
        ymin = mystate.zoom1[mystate.nzooms,1]<mystate.zoom2[mystate.nzooms,1]
        ymax = mystate.zoom1[mystate.nzooms,1]>mystate.zoom2[mystate.nzooms,1]
        mystate.xrange = [xmin,xmax]
        mystate.yrange = [ymin,ymax]
    endelse
    zoom_text = string(mystate.nzooms,format='("Zoom Level:",i3)')
    widget_control,mystate.zoomlabel,set_value=zoom_text
    if mystate.nzooms le 0 then widget_control, mystate.unzoom_button, sensitive=0
    reshow
end
