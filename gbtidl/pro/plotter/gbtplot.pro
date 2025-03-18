common gbtplot_common,mystate,xarray

;+
; The event handler for the gbtidl plotter.
;
; @param event {in}{required}{type=widget event structure} The event
; to be handled.
;
; @private_file
;
; @version $Id$
;-
pro gbtplot_event,event
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    set_viewport
    widget_control,event.id,get_uvalue=uvalue

    ; ignore everything if noPlotEvents is set
    if mystate.noPlotEvents then return

    case uvalue of
        'MAIN': begin
            evtname = tag_names(event,/structure)
            if (evtname eq 'WIDGET_BASE') then handle_resize, event.x, event.y
        end
        'FILE': begin
            case event.value of
                'Exit': 	begin
                    wdelete,mystate.pix_id
                    widget_control,event.top,/destroy
                end
                'Print ...': init_gbtprint_dialog
                'Write PS': write_ps,/prompt
                'Write ASCII': write_ascii,/prompt
            endcase
        end
        'OPT':  begin
            case event.value of
                'Crosshair': crosshair
                'Zeroline': zline
                'Toggle Histogram': histogram
                'Toggle Region Boxes': begin
                    if mystate.showRegions then begin
                        ; turn them off
                        showregion,/off
                    endif else begin
                        ; turn them on
                        showregion
                    endelse
                end
                'Clear Marks': begin
                    clearvlines,/noshow
                    clearmarks
                end
                'Clear Vertical Lines': clearvlines
                'Toggle Overlays': toggleovers
                'Clear Overlays': clearovers
                'Clear Annotations': clearannotations
                'Set Voffset=Vsource': setvoffset
                'Set Voffset=0': setvoffset,0.0
                'Set Voffset ...': init_voffset_dialog
            endcase
        end
        'LeftClick': begin
            case event.value of
                'Marker': begin
                    widget_control,mystate.leftlabel,set_value='Left Click: Set Marker'
                    mystate.leftbutton = 0
                end
                'VLine':  begin
                    widget_control,mystate.leftlabel,set_value='Left Click: Set V Line'
                    mystate.leftbutton = 1
                end
                'Position': begin
                    widget_control,mystate.leftlabel,set_value='Left Click: Show Cursor Postion'
                    mystate.leftbutton = 2
                end
                'Null': begin
                    widget_control,mystate.leftlabel,set_value='Left Click: Null'
                    mystate.leftbutton = 3
                end
            endcase
        end
        'XUnits': setxunit, event.value
        'Frame': setframe, event.value
        'Veldef': setveldef,event.value
        'AbsRel': setabsrel, event.value
        'AutoUpdate': begin
            case event.value of
                'On': unfreeze
                'Off': freeze
            endcase
        end
        'PRT': begin
            if (strlen(!g.printer) eq 0) then begin
                init_gbtprint_dialog
            endif else begin
                if (mystate.landscape) then begin
                    print_ps,device=!g.printer
                endif else begin
                    print_ps,device=!g.printer,/portrait
                endelse
            endelse
        end
        'UNZ': unzoom,/onestep
        'PLOT': begin
            oldwin = !d.window
            wset,mystate.win_id
            xdevice = event.x
            ydevice = event.y
            position_text=''    ;
            data_coord = gbtcursormoved(xdevice, ydevice,position_text=position_text)
            if mystate.zoom eq 1 then begin
		; Need to unset histogram mode if it is on, because otherwise the
		; plots command dumps annoying messages to the console
		old_sym = !p.psym
		!p.psym = 0
                nz = mystate.nzooms+1
                device,copy=[0,0,mystate.xsize,mystate.ysize,0,0,mystate.pix_id]
                plots,[mystate.zoom1[nz,0],mystate.zoom1[nz,0]],[mystate.zoom1[nz,1],data_coord[1]],color=!g.zoomcolor
                plots,[data_coord[0],data_coord[0]],[mystate.zoom1[nz,1],data_coord[1]],color=!g.zoomcolor
                plots,[mystate.zoom1[nz,0],data_coord[0]],[mystate.zoom1[nz,1],mystate.zoom1[nz,1]],color=!g.zoomcolor
                plots,[mystate.zoom1[nz,0],data_coord[0]],[data_coord[1],data_coord[1]],color=!g.zoomcolor
		!p.psym = old_sym
                ; without this call, the subsequent wset,-1 causes the 
                ; last line to not get plotted, weird.
                wset,mystate.win_id
            endif
            case event.press of
                ; left mouse button
                '1' : 	begin
                    case mystate.leftbutton of
                        0 : begin
                            setmarker,data_coord[0],data_coord[1],text=position_text
                            ; refresh if the plotter is currently frozen
                            if !g.frozen then reshow
                        end
                        1 : begin
                            vline, data_coord[0], label=position_text, ylabel=data_coord[1]
                        end
                        2 : begin
                            print,'Cursor position: ',data_coord[0],data_coord[1]
                        end
                        3: begin
                        end
                    endcase
                end
		; middle mouse button
                '2' : 	begin
                    nz1 = mystate.nzooms+1
                    if mystate.zoom eq 0 then begin
                        mystate.zoom1[nz1,*] = data_coord[0:1]
                        mystate.zoom = 1
                    endif else begin
                        mystate.zoom2[nz1,*] = data_coord[0:1]
                        xmin = mystate.zoom1[nz1,0]<mystate.zoom2[nz1,0]
                        xmax = mystate.zoom1[nz1,0]>mystate.zoom2[nz1,0]
                        ymin = mystate.zoom1[nz1,1]<mystate.zoom2[nz1,1]
                        ymax = mystate.zoom1[nz1,1]>mystate.zoom2[nz1,1]
                        mystate.xfix = 1
                        mystate.yfix = 1
                        gbtzoom, xmin, xmax, ymin, ymax
                    endelse
                end
		; right mouse button: use to abort a zoom
		'4' : begin
                    if (mystate.zoom ne 0) then begin
                        mystate.zoom = 0
                        reshow
                    endif
                end
                else:
            endcase
            ; return wset to default
            wset,oldwin
        end
        else: 
    endcase
    return
end

;+
; This procedure initializes the gbtidl plotter state, the actual
; plotter is initialized as necessary by gbtplotter. 
;
; @version $Id$
;-
pro init_gbtplot_state
    compile_opt idl2
    common gbtplot_common,mystate, xarray
	
    mystate = { $
                    ; current sizesm $
        xsize:950, ysize:400, xpad:0, ypad:0, $
                    ; widget IDs $
        main:0L, win_id:0, pix_id:0,  setv_ids:[0L,0L,0L], xunits_id:0L, frame_id:0L, $
	unzoom_button:0L, plot1:0L, $
        veldef_id:0L, absrel_id:0L, voffsetDialogMain:0L, voff_field:0L, voff_veldef_id:0L, $
        print_button:0L, printDialogMain:0L, printDialogPrinter:0L, printDialogFile:0L, $
                    ; text settings $
        title:'Hello' ,xtitle:'Channels', ytitle:'Intensity', $
        xylabel:0L, zoomlabel:0L, $
        autolabel:0L, $
                    ; widget states $
        voff_pending:0, voff_veldef:'Radio', veldef:'Radio', absrel:'Abs', $
        leftbutton:3, leftlabel:0L, $
        print:1, landscape:1, crosshair:0, labelfrozen:0, $
                     ; suspend reacting to PLOT events
        noPlotEvents:0, $
                     ; x-axis information $
        xoffset:0.0d, voffset:0.0d, xtype:1, xscale:0.0d, xunit:'Channels', frame:'TOPO', $
                     ; what actually gets plotted $
        xrange:[0.0,0.0],yrange:[0.0,0.0], $
        bdrop:0, edrop:0, $
        nzooms:0, zoom:0, zoom1:fltarr(100,2), zoom2:fltarr(100,2), $
        xfix:0, yfix:0, $
                     ; overlays $
                     ; markers $
        marker:1, zline:0, $
        marker_pos:ptr_new(fltarr(100,2)),marker_txt:ptr_new(strarr(100)), $
        nmarkers:0, maxnmarkers:100, $
                     ; vertical lines $
        nvlines:0, maxnvlines:100, vline_pos:ptr_new(fltarr(100,2)), vline_txt:ptr_new(strarr(100)), $
        vline_ynorm:ptr_new(intarr(100)), vline_idstring:ptr_new(strarr(100)), $
                     ; annotations $
	n_annotations:0, maxn_annotations:100, annotation:ptr_new(strarr(100)), $
        xyannotation:ptr_new(fltarr(100,2)), ann_color:ptr_new(intarr(100,3)), $
        ann_charsize:ptr_new(fltarr(100)), ann_normal:ptr_new(intarr(100)), $
                     ; overplots $
        oplots_ptr:ptr_new(), overplots:1, hasRegions:0, showRegions:0, $
        maxChan:0.0d, minChan:0.0d, chanPerPix:0.d, $
                     ; overshows $
        oshows_ptr:ptr_new(), overshows:1, $
                     ; the most recently used show color $
        lastshowcolor:0L, $
                     ; header type, 0=none, 1=short, 2=full
        headertype:0, $
                     ; this is True during a restart by gbtplot
        restartInProgress:0, $
                     ; the primary data container being displayed $
	dc_ptr:ptr_new(/allocate_heap), $
                     ; is this in line mode $
        line:1 $
    }

    ; this signals that there is no plotter active
    mystate.main = -1

    ; using a pointer allows this to be passed by reference
    if (ptr_valid(mystate.dc_ptr)) then ptr_free, mystate.dc_ptr
    mystate.dc_ptr = ptr_new(data_new())

    clearoplotslist
    mystate.oplots_ptr = ptr_new()

    clearoshowslist
    mystate.oshows_ptr = ptr_new()

    mystate.xunit = 'Frequency'
    mystate.xtype = 1
    mystate.xscale = 1.0d
    !g.plotter_axis_type = mystate.xtype
    mystate.frame = 'TOPO'
    mystate.veldef = 'RADIO'
    mystate.absrel = 'Abs'
    mystate.voffsetDialogMain = -1
    mystate.voff_veldef = 'Radio'

    ; sync up with guide
    mystate.line = !g.line
end

;+
; This function checks on the value of mystate.main and, if it is not
; a valid widget it checks to make sure that the DISPLAY environment
; variable is set and, if set, it creates the plotter.  The function
; returns 1 if a plotter is available and 0 if a plotter could not be
; created.
;
; @returns status (1 if available, 0 if not available)
;
; @version $Id$
;-
function gbtplot
    compile_opt idl2
    common gbtplot_common,mystate, xarray

    if not !g.has_display then return, 0

    if mystate.restartInProgress gt 0 then begin
        mystate.restartInProgress += 1
        if mystate.restartInProgress gt 10 then begin
            message,'Problems restarting plotter - infinite loop detected, can not continue.'
        endif
        return,widget_info(mystate.main,/valid_id)
    endif

    catch, error_status
    if error_status ne 0 then return, 0

    if not widget_info(mystate.main,/valid_id) then begin
        oldwin=!d.window
        mystate.main = widget_base(/col,group=group,/tracking,/tlb_size_events,uvalue='MAIN',title='GBTIDL Plotter')
        mystate.restartInProgress = 1
        menu = widget_base(mystate.main,/row,/frame)

        desc = ['1\File','0\Print ...','0\Write PS','0\Write ASCII','2\Exit']
        filemenu = cw_pdmenu(menu,desc,uvalue='FILE',/return_name)

        ; if the Set Voffset .. options move in this menu, be sure 
        ; and update mystate.setv_ids below
        desc = ['1\Options','0\Crosshair','0\Zeroline','0\Toggle Histogram','0\Toggle Region Boxes','0\Clear Marks','0\Clear Vertical Lines','0\Clear Overlays','0\Toggle Overlays','0\Clear Annotations','0\Set Voffset=Vsource','0\Set Voffset=0','0\Set Voffset ...']
        optmenu = cw_pdmenu(menu,desc,uvalue='OPT',/return_name, ids=ids)
        mystate.setv_ids=ids[8:10]

        desc = ['1\LeftClick','0\Null','0\Position','0\Marker','0\VLine']
        leftclickmenu = cw_pdmenu(menu,desc,uvalue='LeftClick',/return_name)

        desc = ['1\XUnits','0\Channels','0\Hz','0\kHz','0\MHz','0\GHz','0\m/s','0\km/s']
        xunits = cw_pdmenu(menu,desc,uvalue='XUnits',/return_name, ids=ids)
        ; first returned ID is top menu, set it to display "Channels"
        mystate.xunits_id = ids[0]
        widget_control,mystate.xunits_id,set_value=mystate.xunit

        desc = ['1\Frame','0\TOPO','0\LSR','0\LSD','0\GEO','0\HEL','0\BAR','0\GAL']
        frames = cw_pdmenu(menu,desc,uvalue='Frame',/return_name, ids=ids)
        ; first returned ID is top menu, set it to display "TOPO"
        mystate.frame_id = ids[0]
        widget_control,mystate.frame_id,set_value=mystate.frame

        desc = ['1\Veldef','0\Radio','0\Optical','0\True']
        veldef = cw_pdmenu(menu,desc,uvalue='Veldef',/return_name, ids=ids)
        ; first returned ID is top menu, set it to display "Radio"
        mystate.veldef_id = ids[0]
        widget_control,mystate.veldef_id,set_value=mystate.veldef

        desc = ['1\AbsRel','0\Abs','0\Rel']
        absrel = cw_pdmenu(menu,desc,uvalue='AbsRel',/return_name, ids=ids)
        ; first returned ID is top menu, set it to display "Abs"
        mystate.absrel_id = ids[0]
        widget_control,mystate.absrel_id,set_value=mystate.absrel

        mystate.unzoom_button = widget_button(menu,value='Unzoom',uvalue='UNZ',sensitive=0)
        desc = ['1\Auto Update','0\On','0\Off']
        autoupdate_menu = cw_pdmenu(menu,desc,uvalue='AutoUpdate',/return_name)

        mystate.print_button = widget_button(menu,value='Print',uvalue='PRT')
        base1 = widget_base(mystate.main,/row,uvalue='BASE1')
        mystate.plot1 = widget_draw(base1,uvalue='PLOT',retain=2, xsize=mystate.xsize, $
	        ysize=mystate.ysize,/button_events,/motion)
        base2 = widget_base(mystate.main,/row,uvalue='BASE2')
        bottomrowbase = widget_base(base2,/row)
        mystate.leftlabel = widget_label(bottomrowbase,value='Left Click: Null', $
		/dynamic_resize,/frame)
        mystate.xylabel = widget_label(bottomrowbase,value=' X:              Y:              ', $
		/frame)
        mystate.zoomlabel = widget_label(bottomrowbase,value='Zoom Level:  0',/frame)
        mystate.autolabel= widget_label(bottomrowbase,value='Auto Update: Off',/frame)
        mystate.labelFrozen = 0
        setplotterautoupdate
    
        widget_control,mystate.main,/realize
	; without this, the "Print" button gets the input focus initially which
	; can lead to unexpected prints initially if the user keeps typing after the
	; initial display without realizing they have an active plotter that now
	; has focus
	widget_control,mystate.plot1,/input_focus 
        mystate.win_id = !d.window
	erase,!g.background
        window,/free,/pixmap,xsize=mystate.xsize,ysize=mystate.ysize
        mystate.pix_id = !d.window
        erase,!g.background
	
        wset,mystate.win_id
        xmanager,'gbtplot',mystate.main,/no_block

        msize=widget_info(mystate.main,/geometry)
        mystate.xpad = msize.xsize-mystate.xsize
        mystate.ypad = msize.ysize-mystate.ysize

        if data_valid(*mystate.dc_ptr) gt 0 then reshow

        mystate.restartInProgress = 0;
        
        ; reset to default ID
        wset,oldwin
    endif

    return, widget_info(mystate.main,/valid_id)
end
