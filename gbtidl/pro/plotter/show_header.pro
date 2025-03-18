;+
; This procedure draws header information on the plot.  It is intended
; to be used only by the other gbtidl plotter procedures.  It is not
; an end-user procedure.
;
; @keyword dc {in}{optional}{type=data container} data container
; @keyword charsize {in}{optional}{type=float} character size; needed for ps generation
; @keyword label_dc {in}{optional}{type=string} label for DC, shown at
; bottom of plot by time stamp
; @keyword foreground {in}{optional}{type=color}{default=!g.foreground}
; The foreground color.
; @keyword nocolor {in}{optional}{type=boolean}{default=F} When set,
; all fields are printed with the foreground color.  When not set (the
; default), some fields are highlighted with color (!green and !red).
; @keyword noshow {in}{optional}{type=boolean} When set, then nothing
; is printed on the plot surface.  This is to be used with height so
; that show_support can know how much space to reserve for the header.
; @keyword height {out}{optional}{type=integer} The number of lines,
; in units of charsize where 1 line is large enough to hold one row of
; charsize characters, that this header will take.  Since the header might
; be small, this number can vary.  This should be used with /noshow so
; that show_support can reserve an appropriate amount of space for the
; header and expand the plot surface when possible.
;
; @private_file
;
; @version $Id$
;-
pro show_header,dc=dc,charsize=charsize,label_dc = label_dc,foreground=foreground, nocolor=nocolor, $
                noshow=noshow, height=height
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    ; this is not called unless headertype is 1 (small) or 2 (full)
    height = (mystate.headertype eq 1) ? 4 : 10
    if keyword_set(noshow) then return

    if (n_elements(dc) eq 0) then dc = !g.s[0]
    if (n_elements(charsize) eq 0) then charsize=1.4
    if (n_elements(dcstring) eq 0) then dcstring=' '
    if (n_elements(foreground) eq 0) then foreground=!g.foreground
    if keyword_set(nocolor) then begin
        greenHighlight = foreground
        redHighlight = foreground
    endif else begin
        greenHighlight = !green
        redHighlight = !red
    endelse

    if mystate.headertype eq 1 then begin
        ; source line is 3.0 characters from top
        sline = 1.0 - 3.0*(charsize/1.4)*float(!d.y_ch_size)/float(!d.y_size)
    endif else begin
        ; 1.6 characters in Y per line
        yincr = 1.6*(charsize/1.4)*float(!d.y_ch_size)/float(!d.y_size)
        ; first line is 2.0 characters from top of y_size
        line1 = 1.0 - 2.0*(charsize/1.4)*float(!d.y_ch_size)/float(!d.y_size)
        line2 = line1 - yincr
        line3 = line2 - yincr
        ; source line is 8.0 characters from top
        sline = 1.0 - 8.0*(charsize/1.4)*float(!d.y_ch_size)/float(!d.y_size)
        xyouts,0.06,line1,"Scan",/normal,charsize=charsize,color=foreground
        xyouts,string(dc.scan_number,format='(I10)'),charsize=charsize,color=highlight
        if mystate.line then begin
            xyouts,0.06,line2,dc.date,/normal,charsize=charsize,color=foreground
        endif else begin
            xyouts,0.06,line2,(*dc.date)[0],/normal,charsize=charsize,color=foreground
        endelse
        xyouts,0.06,line3,strmid(dc.observer,0,20),/normal,charsize=charsize,color=foreground
        if mystate.line then $
          xyouts,0.25,line1,string(dc.source_velocity/1.0e3,$
                                   dc.velocity_definition,format='("V   : ",F9.1," ",A8)'),$
                 /normal,charsize=charsize,color=foreground
        stint=strmid(adstring(dc.exposure/3600.0),1)
        xyouts,0.25,line2,string(stint,format='("Int  : ",x,A10)'),/normal,charsize=charsize,color=foreground
        if mystate.line then begin
            xyouts,0.25,line3,string(adstring(dc.lst/3600.0),format='("LST : ",A11)'),/normal,charsize=charsize,$
                   color=foreground
        endif else begin
            nint = n_elements(*dc.data_ptr)
            mid = nint/2 - 1
            if mid lt 0 then mid = 0
            midlst = (*dc.lst)[mid]
            xyouts,0.25,line3,string(adstring(midlst/3600.0),$
                                     format='("LST : ",A11)'),/normal,charsize=charsize,$
                   color=foreground
        endelse
        scalevals,dc.observed_frequency,fsky,fskyprefix
        if mystate.line then scalevals,dc.line_rest_frequency,frest,frestprefix
        scalevals,dc.bandwidth,bw,bwprefix
        if mystate.line then $
          xyouts,0.5,line1,string(frest,frestprefix,format='("F0   : ",F9.5,x,a1,"Hz")'), $
                 /normal,charsize=charsize,color=foreground
        xyouts,0.5,line2,string(fsky,fskyprefix,  format='("Fsky : ",F9.5,x,a1,"Hz")'), $
               /normal,charsize=charsize,color=foreground
        xyouts,0.5,line3,string(bw,bwprefix,$
                                format='("BW   : ",F8.4,x,a1,"Hz")'),/normal,charsize=charsize,$
               color=foreground
        xyouts,0.7,line1,string(dc.polarization,format='("Pol: ",A4)'),$
               /normal,charsize=charsize,color=foreground
        xyouts,0.7,line2,string(dc.if_number,format='("IF : ",I4)'),/normal,charsize=charsize,color=foreground
        xyouts,0.7,line3,strmid(dc.projid,0,20),/normal,charsize=charsize,color=foreground
        xyouts,0.85,line1,string(dc.tsys,format='("Tsys: ",F7.2)'),/normal,charsize=charsize,color=foreground
        xyouts,0.85,line2,string(dc.mean_tcal,format='("Tcal: ",F7.2)'),$
               /normal,charsize=charsize,color=foreground
        xyouts,0.85,line3,dc.procedure,/normal,charsize=charsize,color=foreground
    endelse
    ; this puts the source off in space ... 
    ; used to get the width so it can be centered without being seen
    sname = strtrim(dc.source)
    xyouts,0.45,-2.0,sname,width=width,/normal,charsize=charsize*1.5,charthick=1.5,color=greenHighlight
    startat=0.5-width/2.0
    xyouts,startat,sline,sname,/normal,charsize=charsize*1.5,charthick=1.5,color=greenHighlight
    if mystate.line then begin
        radec = getradec(dc,/quiet)
        xyouts,0.06,sline,strtrim(adstring(radec[0],radec[1],1),2),/normal,charsize=charsize,$
               color=foreground
        if mystate.headertype eq 1 then begin
            dlen = strlen(dc.date)
            xstart = 1.0 - ((dlen+14.0) * charsize/1.4) * float(!d.x_ch_size)/float(!d.x_size)
        endif else begin
            ha=ra2ha(radec[0],dc.lst)/15.0d
            xyouts,0.71,sline,string(dc.azimuth,dc.elevation,ha,$
                                     format='("Az: ",F5.1,"  El: ",F5.1,"  HA: ",F5.2)'),$
                   /normal,charsize=charsize,color=foreground
            endelse
    endif else begin
        ; show positions nearest the middle integrations
        radec = getradec(dc,/quiet)
        nint = n_elements(*dc.data_ptr)
        mid = nint/2 - 1
        if mid lt 0 then mid = 0
        midRA = radec[0,mid]
        midDec = radec[1,mid]
        midaz = (*dc.azimuth)[mid]
        midel = (*dc.elevation)[mid]
        xyouts,0.06,sline,strtrim(adstring(midRA,midDec,1),2),/normal,charsize=charsize,color=foreground
        if mystate.headertype eq 1 then begin
            dlen = strlen((*dc.date)[0])
            xstart = 1.0 - ((dlen+14.0) * charsize/1.4) * float(!d.x_ch_size)/float(!d.x_size)
            xyouts,xstart,sline,(*dc.date)[0],/normal,charsize=charsize,color=foreground
        endif else begin
            midlst = (*dc.lst)[mid]
            ha=ra2ha(midRA,midlst)/15.0d
            xyouts,0.71,sline,string(midaz,midel,ha,format='("Az: ",F5.1,"  El: ",F5.1,"  HA: ",F5.2)'),$
                   /normal,charsize=charsize,color=foreground
        endelse
    endelse
end

