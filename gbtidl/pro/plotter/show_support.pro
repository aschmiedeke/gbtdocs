;+
; This procedure is the workhorse behind show, reshow, and write_ps.
; It is expected that users will use those proecdures rather than
; use this directly, although there is no loss of functionality in
; using this directly.  The top-level interface was split into three
; procedures to make each less confusing.
;
; This procedure displays a spectral line data container.  If no
; dc is passed, the global container is used.
;
; @param dc {in}{optional}{type=data container or integer}{default=0} a data container,
; or an integer global buffer number.  Defaults to the primary data
; container (buffer 0).
;
; @keyword postscript {in}{optional}{type=boolean} If set, then this
; write to a postscript file given by filename.
;
; @keyword portrait {in}{optional}{type=boolean} If set and the
; postcript keyword is also set, then the postscript will be generated
; in portrait mode instead of the default landscape mode.
;
; @keyword filename {in}{optional}{type=string} Filename to use for
; postscript file.  A valid file must be supplied when postscript is
; set. This keyword is ignored unless postscript is set.
;
; @keyword reshow {in}{optional}{type=boolean} When set, then dc
; argument is ignored and the previously set xarray will be re-used
; here.  This allows other routines to set the xarray and speeds up
; this procedure when the same data is being reshown.
;
; @keyword defaultx {in}{optional}{type=boolean} When set, the default
; x-axis (frame, velocity definition, units from the data header in
; absolute units) will be used.  In the default case (unset), the current
; settings are retained.
;
; @keyword color {in}{optional}{type=long integer}{default=!g.showcolor} The
; color for the primary data.
;
; @keyword smallheader {in}{optional}{type=boolean} When set, only a
; small, one line header consisting of RA, DEC, source name, and date
; is placed at the top of the plot.  The footer line is displayed when
; smallheader is set.  By default, the full, multi-line
; header and the single line footer are displayed.
;
; @keyword noheader {in}{optional}{type=boolean} When set, no header
; information is displayed at the top of the plot or below the x-axis
; label of the plot (footer).  This takes precedence over smallheader.
; By default, the full, multi-line header and the single line footer
; are displayed.
;
; @private_file
;
; @version $Id$
;-
pro show_support,dc,postscript=postscript,filename=filename,reshow=reshow, $
         defaultx=defaultx,portrait=portrait,color=color, smallheader=smallheader, $
         noheader=noheader
    common gbtplot_common,mystate,xarray

    plotterEmpty = data_valid(*mystate.dc_ptr) le 0
    if (plotterEmpty and keyword_set(reshow)) then return

    if not keyword_set(postscript) and not gbtplot() then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif

    if (n_elements(color) eq 0) then begin
        if (keyword_set(reshow)) then begin
            ; reuse last use color
            color = mystate.lastshowcolor
        endif else begin
            ; default color
            color = !g.showcolor
        endelse
    endif

    mystate.lastshowcolor = color

    foreground = !g.foreground
    background = !g.background
    usecolor = 1
    ; postscript always has white background, ensure forground is always black
    if keyword_set(postscript) then begin
        foreground=!black
        ; this background is used as a comparison later on, it doesn't 
        ; actually matter to the postscript device
        background=!white
        ; the following controls how everything NOT forground and background behave
        if not !g.colorpostscript then begin
            usecolor = 0
            color=foreground
        endif
    endif

    label_dc = ' '
    newx = 0

    oplotsCleared = 0

    if (not keyword_set(reshow)) then begin
        mystate.headertype = 2
        if keyword_set(smallheader) then mystate.headertype =1
        if keyword_set(noheader) then mystate.headertype = 0

        clearannotations,/noshow
        if n_params() ne 1 then begin
            this_dc = !g.line ? !g.s[0] : !g.c[0]
        endif else begin
            this_dc = dc
        endelse

        ; If an integer is passed, use it as a buffer number
        dctype = size(this_dc,/type)
        if (dctype eq 2 or dctype eq 3) then begin
            if this_dc lt 0 or this_dc gt 15 then begin $
                message,"Bad buffer number.",/informational
                return
            endif
            label_dc = string('Data Container ',this_dc, format='(A,I2)')
            this_dc = !g.line ? !g.s[this_dc] : !g.c[this_dc]
        endif

        if (data_valid(this_dc,name=type) le 0) then begin
            message,"Invalid data container",/informational
            return
        endif

        newx = 1

        if type eq "CONTINUUM_STRUCT" and mystate.line then begin
            clear
            plotterEmpty = 1
            mystate.line = 0
        endif
    
        data_copy, this_dc, *mystate.dc_ptr
        set_plotter_mode
        
        clearoplotslist
        oplotsCleared = 1
        clearoshowslist
    endif 

    if (*mystate.dc_ptr).units eq 'Jy' then mystate.ytitle = 'Flux Density (Jy)' $
    else if (*mystate.dc_ptr).units eq 'Ta*' then mystate.ytitle = 'Antenna Temperature (Ta*)' $
    else if (*mystate.dc_ptr).units eq 'Ta' then mystate.ytitle = 'Antenna Temperature (Ta)' $
    else if strlen((*mystate.dc_ptr).units) eq 0 then mystate.ytitle = 'Intensity' $
    else mystate.ytitle=(*mystate.dc_ptr).units

    ; force continuum data to be in chan line type only
    if not mystate.line then !g.plotter_axis_type = 0

    if (plotterEmpty or keyword_set(defaultx)) then begin
        ; set frame, default units, veldef, absrel for this scan
        newAbsrel = 'Abs'
        if mystate.line then begin
            veldef_ok = decode_veldef((*mystate.dc_ptr).velocity_definition, v_def, v_frame)
            if (veldef_ok le 0) then begin
                message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
            endif
            newFrame = v_frame
            newVeldef = v_def
            newXoffset = 0.0D
            if (veldef_ok gt 0) then begin
                                ; start out with frequencies, scaled appropriately
                                ; use value of reference frequency as a guide to best scaling
                scalevals,(*mystate.dc_ptr).observed_frequency,fsky,fskyprefix
                case fskyprefix of
                    'G': begin
                        newXunit = 'GHz'
                        newXscale = 1.d9
                    end
                    'M': begin
                        newXunit = 'MHz'
                        newXscale = 1.d6
                    end
                    'k': begin
                        newXunit = 'kHz'
                        newXscale = 1.d3
                    end
                    else: begin
                        newXunit = 'Hz'
                        newXscale = 1.d
                    end
                endcase
                newXtype = 1
            endif else begin
                newXunit = 'Channels'
                newXtype = 0
                newXscale = 1.d
            endelse
        endif else begin
            newFrame = 'TOPO'
            newVeldef = 'RADIO'
            newXoffset = 0.0D
            newXunit = 'Channels'
            newXtype = 0
            newXscale = 1.d
        endelse
        if keyword_set(defaultx) then begin
            ; convert existing state to the new state
            ; scale and type happens automatically here via newXunit
            convertxstate,newXunit, newFrame, newVeldef,newAbsrel,newXoffset
            ; make sure the plotter axis type in !g matches this one
            !g.plotter_axis_type = mystate.xtype
        endif else begin
            ; set the state directly here
            mystate.frame = newFrame
            mystate.veldef = newVeldef
            mystate.xoffset = newXoffset
            mystate.xunit = newXunit
            mystate.xscale = newXscale
            mystate.xtype = newXtype
            mystate.absrel = newAbsrel
        endelse
        widget_control, mystate.frame_id,set_value=mystate.frame
        widget_control, mystate.absrel_id,set_value=mystate.absrel
        widget_control, mystate.veldef_id,set_value=mystate.veldef
        widget_control, mystate.xunits_id,set_value=mystate.xunit
        newx = 1
    endif

    if (!g.plotter_axis_type ne mystate.xtype) then begin
        case !g.plotter_axis_type of 
            0: begin
                if mystate.line then begin
                    setxunit, 'Channels',/noreshow
                endif else begin
                    setxunit, 'Channels',/noreshow
                endelse
            end
            1: begin
                ; 'Frequency'
                ; work out what scaling is best
                scalevals,(*mystate.dc_ptr).observed_frequency,fsky,fskyprefix
                newunits = fskyprefix + 'Hz'
                setxunit, newunits,/noreshow
            end
            2: setxunit, 'km/s',/noreshow
            else: begin
                message,'Unknown !g.plotter_axis_type value, using default units',/info
                defaultx = 1
            end
        endcase
        newx = 1
    endif

    if (newx) then begin
        if (mystate.absrel eq 'Rel') then begin
            mystate.xoffset = newxoffset(mystate.xtype, mystate.xscale, mystate.frame, mystate.veldef)
        endif else begin
            mystate.xoffset = 0.0D
        endelse
        setxarray
    endif

    yptr = (*mystate.dc_ptr).data_ptr

   ; reassign the actual values to dummy values, to accomodate bdrop and edrop
    nchan = (size(*yptr))[1]
    if (mystate.bdrop+mystate.edrop) ge nchan then begin
        message,'bdrop and edrop exclude all channels, nothing to show',/info
        return
    endif
    xarray2 = xarray[mystate.bdrop:(nchan-mystate.edrop-1)]
    yval2 = (*yptr)[mystate.bdrop:(nchan-mystate.edrop-1)]

    updatePixmap = 1

    charsize = 1.4
    xcharleft = 16.0
    xcharright = 8.0
    if mystate.headertype eq 0 then begin
        ychartop = 1.0
        ycharbottom = 5.0
    endif else begin
        show_header,/noshow,height=ychartop
        ycharbottom = 6.0
    endelse

    if (keyword_set(postscript)) then begin
        if (n_elements(filename) eq 0) then begin
            message,'No filename set for postscript, can not continue'
            return
        endif
        if (strlen(filename) eq 0) then return ; user cancelled out of dialog
        set_plot,'PS'
	; the use of scale, xoff, and yoff here is to get landscape
        ; to not come out inverted - the default case (seascape).
        ; The portrait numbers are the default case.
        if (keyword_set(portrait)) then begin
            charsize = 0.9
            hdrCharsize = 0.85
            if !g.colorpostscript then begin
                device,file=filename,/color,/portrait,/inches,scale=1.0, $
                       xoff=0.75,yoff=5.0
            endif else begin
                device,file=filename,/portrait,/inches,scale=1.0, $
                       xoff=0.75,yoff=5.0
            endelse
        endif else begin
            charsize = 1.2
            hdrCharsize = 1.1
            if !g.colorpostscript then begin
                device,file=filename,/color,/landscape,/inches,scale=-1.0, $
                       xoff=7.75,yoff=0.75
            endif else begin
                device,file=filename,/landscape,/inches,scale=-1.0, $
                       xoff=7.75,yoff=0.75
            endelse
            xcharleft = 8.0
            xcharright = 4.0
        endelse
        annCharsizeFactor = charsize
        updatePixmap = 0
    endif else begin
        hdrCharsize = charsize
        annCharsizeFactor = 1.0
        oldwin=!d.window
        wset,mystate.win_id
    endelse

    xcharleft *= (charsize/1.4)
    xcharright *= (charsize/1.4)
    ycharbottom *= (hdrCharsize/1.4)
    ychartop *= (hdrCharsize/1.4)

    ; buffers on left and right of plot, scaled by character size
    xleftpad = xcharleft * !d.x_ch_size
    xrightpad = xcharright * !d.x_ch_size
    ; buffers on bottom and top of plot
    ybottompad = ycharbottom* !d.y_ch_size
    ytoppad = ychartop * !d.y_ch_size

   ; use x_size and y_size to get appropriate plotpos
    x0 = xleftpad / float(!d.x_size)
    x1 = float(!d.x_size-xrightpad)/float(!d.x_size)
    y0 = ybottompad / float(!d.y_size)
    y1 = float(!d.y_size-ytoppad)/float(!d.y_size)
    plotpos = [x0,y0,x1,y1]

    ; find x and y range of data and any overlays
    ; first x - x and y are treated differently
    minx = min(xarray2,max=maxx)
    thisptr = mystate.oshows_ptr
    while (ptr_valid(thisptr)) do begin
        this_struct = *thisptr
        thisData = (*this_struct.dc_ptr).data_ptr
        nchan = n_elements(*thisData)
        if (mystate.bdrop+mystate.edrop lt nchan) then begin
            ; okay to show this one, else skip silently
            thisminx = min(this_struct.x[mystate.bdrop:(nchan-mystate.edrop-1)], max=thismaxx)
            minx = minx < thisminx
            maxx = maxx > thismaxx
        endif
        thisptr = this_struct.next
    endwhile
    xrange=[minx,maxx]
    xstyle=1
    if (mystate.xfix) then xrange=mystate.xrange

    ; then y - only want min and max within xrange
    ; convert xrange to channels
    chxrange = round(xtochan(xrange)) - mystate.bdrop
    if chxrange[1] lt chxrange[0] then begin
        tmp=chxrange[0]
        chxrange[0] = chxrange[1]
        chxrange[1] = tmp
    endif
    if chxrange[0] lt 0 then chxrange[0] = 0
    if chxrange[1] lt 0 then chxrange[1] = 0
    if chxrange[0] ge n_elements(yval2) then chxrange[0] = n_elements(yval2)-1
    if chxrange[1] ge n_elements(yval2) then chxrange[1] = n_elements(yval2)-1
    blankCount = count_blanks(*mystate.dc_ptr,fullCount)
    primaryBlanked = blankCount eq fullCount
    miny = min(yval2[chxrange[0]:chxrange[1]],max=maxy,/nan)
    if not finite(miny) then begin
        miny = 0.0
        maxy = 1.0
    endif else begin
        if miny eq maxy then begin
            ; pad +- 5%
            padSize = 0.05*miny
            miny -= padSize
            maxy += padSize
        endif
    endelse
    thisptr = mystate.oshows_ptr
    while (ptr_valid(thisptr)) do begin
        this_struct = *thisptr
        thisData = (*this_struct.dc_ptr).data_ptr
        nchan = n_elements(*thisData)
        ; convert xrange to channels in this overshow
        chxrange = round(xtochan(xrange,dc=*this_struct.dc_ptr))
        if chxrange[1] lt chxrange[0] then begin
            tmp=chxrange[0]
            chxrange[0] = chxrange[1]
            chxrange[1] = tmp
        endif
        if chxrange[0] lt 0 then chxrange[0] = 0
        if chxrange[1] lt 0 then chxrange[1] = 0
        if chxrange[0] ge nchan then chxrange[0] = nchan-1
        if chxrange[1] ge nchan then chxrange[1] = nchan-1
        thisminy = min((*thisData)[chxrange[0]:chxrange[1]], max=thismaxy,/nan)
        if (finite(thisminy)) then begin
            miny = miny < thisminy
            maxy = maxy > thismaxy
        endif
        thisptr = this_struct.next
    endwhile
    yrange=[miny,maxy]
    ystyle=18
    if (mystate.yfix) then begin
        yrange=mystate.yrange
        ystyle=1
    endif

    if ((mystate.nzooms eq 0  or (not mystate.xfix and not mystate.yfix)) and mystate.nzooms ne 0) then begin
        ; *fix values are 0, reset zooms to all the way out
        mystate.nzooms = 0
        mystate.xrange = [0.0,0.0]
        mystate.nzooms = 0
        mystate.xfix = 0
        mystate.yfix = 0
        widget_control, mystate.unzoom_button, sensitive=0
        zoom_text = string(mystate.nzooms,format='("Zoom Level:",i3)')
        widget_control,mystate.zoomlabel,set_value=zoom_text
    endif

    mystate.maxChan = xtochan(xrange[1])
    mystate.minChan = xtochan(xrange[0])
    if (mystate.minChan gt mystate.maxChan) then begin
        tmp = mystate.minChan
        mystate.minChan = mystate.maxChan
        mystate.maxChan = tmp
    endif
    mystate.chanPerPix = abs(mystate.maxChan-mystate.minChan) / (mystate.xsize * (plotpos[2]-plotpos[0]))

    ; first plot sets axes et al, but doesn't plot any data
    plot,xrange,yrange,xrange=xrange,yrange=yrange,xstyle=xstyle,ystyle=ystyle,/nodata,$
         pos=plotpos,xtitle=mystate.xtitle,ytitle=mystate.ytitle, $
         xcharsize=charsize, ycharsize=charsize, background=background, color=foreground
    ; oplot actually plots the data in the appropriate color
    if primaryBlanked then begin
        xyouts,0.5,0.5,'Blanked Data',alignment=0.5,/normal,charsize=3,charthick=2.0,color=forground
    endif else begin
        oplot,xarray2,yval2,color=color
    endelse
    ; and the header
    nocolor = usecolor ? 0 : 1
    if mystate.headertype ne 0 then begin
        show_header,dc=*mystate.dc_ptr,charsize=hdrCharsize,label_dc=label_dc,foreground=foreground,$
                    nocolor=nocolor
        show_footer,charsize=hdrCharsize,label_dc=label_dc,foreground=foreground,nocolor=nocolor
    endif
    ; again in the other pixmap if necessary
    if (updatePixmap) then begin
        wset,mystate.pix_id
        plot,xrange,yrange,xrange=xrange,yrange=yrange,xstyle=xstyle,ystyle=ystyle,/nodata,$
             pos=plotpos,xtitle=mystate.xtitle,ytitle=mystate.ytitle, $
             xcharsize=charsize, ycharsize=charsize, background=background, color=foreground
        if primaryBlanked then begin
            xyouts,0.5,0.5,'Blanked Data',alignment=0.5,/normal,charsize=3,charthick=2.0,color=forground
        endif else begin
            oplot, xarray2,yval2,color=color
        endelse
        if mystate.headertype ne 0 then begin
            show_header,dc=*mystate.dc_ptr,charsize=hdrCharsize,label_dc=label_dc,foreground=foreground,$
                        nocolor=nocolor
            show_footer,charsize=hdrCharsize,label_dc=label_dc,foreground=foreground,nocolor=nocolor
        endif
        mystate.xrange = !x.crange
        mystate.yrange = !y.crange
        wset,mystate.win_id
    endif

    thisptr = mystate.oshows_ptr
    if (mystate.overshows) then begin
        while (ptr_valid(thisptr)) do begin
            this_struct = *thisptr
            thisData = (*this_struct.dc_ptr).data_ptr
            nchan = n_elements(*thisData)
            if (mystate.bdrop + mystate.edrop) lt nchan then begin
                thisColor = this_struct.color
                if not usecolor or thisColor eq background then thisColor=foreground
                oplot, this_struct.x[mystate.bdrop:(nchan-mystate.edrop-1)], (*thisData)[mystate.bdrop:(nchan-mystate.edrop-1)], color=thisColor
                if  (updatePixmap) then begin
                    wset,mystate.pix_id
                    oplot, this_struct.x[mystate.bdrop:(nchan-mystate.edrop-1)], (*thisData)[mystate.bdrop:(nchan-mystate.edrop-1)], color=thisColor
                    wset,mystate.win_id
                endif
            endif
            thisptr = this_struct.next
        endwhile
    endif
    if (mystate.overplots or mystate.showRegions) then begin
        mystate.hasRegions = 0
        thisPtr = mystate.oplots_ptr
        while ptr_valid(thisPtr) do begin
            thisItem = *thisPtr
            ; warning, oplotlistitem may change thisItem
            oplotlistitem, thisItem, usecolor, background, foreground, updatePixmap
            isregion = thisItem.idstring eq "__showregion"
            if mystate.showRegions and isregion then mystate.hasRegions = 1
            thisPtr = thisItem.next
        endwhile
    endif
    ; if the overplots were cleared, !g.regionboxes is true and the 
    ; mystate.showRegions toggle is true, show the regions
    if oplotsCleared then begin
        if !g.regionboxes and mystate.showRegions then begin
            showregion
        endif else begin
            mystate.showRegions = 0
        endelse
    endif

    mkcolor = !g.markercolor
    if not usecolor or mkcolor eq background then mkcolor=foreground
    for i=0,mystate.nmarkers-1 do begin
        oplot,[(*mystate.marker_pos)[i,0]],[(*mystate.marker_pos)[i,1]],psym=1,color=mkcolor
        xyouts,(*mystate.marker_pos)[i,0],(*mystate.marker_pos)[i,1],(*mystate.marker_txt)[i],color=mkcolor
        if (updatePixmap) then begin
            wset,mystate.pix_id
            oplot,[(*mystate.marker_pos)[i,0]],[(*mystate.marker_pos)[i,1]],psym=1,color=mkcolor
            xyouts,(*mystate.marker_pos)[i,0],(*mystate.marker_pos)[i,1],(*mystate.marker_txt)[i],color=mkcolor
            wset,mystate.win_id
        endif
    end
    vcolor = !g.vlinecolor
    if not usecolor or vcolor eq background then vcolor=foreground
    for i=0,mystate.nvlines-1 do begin
        oplot,[(*mystate.vline_pos)[i,0],(*mystate.vline_pos)[i,0]],mystate.yrange,color=vcolor
        if (*mystate.vline_ynorm)[i] then begin
            yline = (*mystate.vline_pos)[i,1] * (mystate.yrange[1] - mystate.yrange[0]) + mystate.yrange[0]
        endif else begin
            yline = (*mystate.vline_pos)[i,1]
        endelse
        xyouts,(*mystate.vline_pos)[i,0],yline,(*mystate.vline_txt)[i],color=vcolor
        if (updatePixmap) then begin
            wset,mystate.pix_id
            oplot,[(*mystate.vline_pos)[i,0],(*mystate.vline_pos)[i,0]],mystate.yrange,color=vcolor
            xyouts,(*mystate.vline_pos)[i,0],yline,(*mystate.vline_txt)[i],color=vcolor
            wset,mystate.win_id
        endif
    end
    for i=0,mystate.n_annotations-1 do begin
        thisColor=(*mystate.ann_color)[i]
        if not usecolor or thisColor eq background then thisColor=foreground
        if ((*mystate.ann_normal)[i]) then begin
            xyouts,(*mystate.xyannotation)[i,0],(*mystate.xyannotation)[i,1],(*mystate.annotation)[i], /normal, $
			color=thisColor, charsize=(*mystate.ann_charsize)[i]*annCharsizeFactor
            if (updatePixmap) then begin
                wset,mystate.pix_id
                xyouts,(*mystate.xyannotation)[i,0],(*mystate.xyannotation)[i,1],(*mystate.annotation)[i], /normal, $
			color=thisColor, charsize=(*mystate.ann_charsize)[i]*annCharsizeFactor
                wset,mystate.win_id
            endif
        endif else begin
            xyouts,(*mystate.xyannotation)[i,0],(*mystate.xyannotation)[i,1],(*mystate.annotation)[i], $
			color=thisColor, charsize=(*mystate.ann_charsize)[i]*annCharsizeFactor
            if (updatePixmap) then begin
                wset,mystate.pix_id
                xyouts,(*mystate.xyannotation)[i,0],(*mystate.xyannotation)[i,1],(*mystate.annotation)[i], $
			color=thisColor, charsize=(*mystate.ann_charsize)[i]*annCharsizeFactor
                wset,mystate.win_id
            endif
        endelse
    end
    zcolor = !g.zlinecolor
    if not usecolor or zcolor eq background then zcolor=foreground
    if mystate.zline eq 1 then begin
        oplot,mystate.xrange,[0,0],color=zcolor
        if (updatePixmap) then begin
            wset,mystate.pix_id
            oplot,mystate.xrange,[0,0],color=zcolor
            wset,mystate.win_id
        endif
    endif
    if (keyword_set(postscript)) then begin
        device,/close
        set_plot,'X'
        print,'Postscript file written: ', filename
    endif else begin
        ; select default to get this out of the way
        wset,oldwin
    endelse

    return
end
