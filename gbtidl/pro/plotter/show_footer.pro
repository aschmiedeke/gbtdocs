;+
; This procedure draws footer information on the plot.  It is intended
; to be used only by the other gbtidl plotter procedures.  It is not
; an end-user procedure.
;
; @keyword charsize {in}{optional}{type=float} Header character size;
; needed for ps generation
; @keyword label_dc {in}{optional}{type=string} label for DC, shown at
; bottom of plot by time stamp
; @keyword foreground {in}{optional}{type=color}{default=!g.foreground}
; The foreground color.
; @keyword nocolor {in}{optional}{type=boolean}{default=F} When set,
; all fields are printed with the foreground color.  When not set (the
; default), some fields are highlighted with color (!green and !red).
;
; @private_file
;
; @version $Id$
;-
pro show_footer,charsize=charsize,label_dc = label_dc,foreground=foreground, nocolor=nocolor
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if (n_elements(charsize) eq 0) then charsize=1.4
    if (n_elements(foreground) eq 0) then foreground=!g.foreground
    if keyword_set(nocolor) then begin
        greenHighlight = foreground
        redHighlight = foreground
    endif else begin
        greenHighlight = !green
        redHighlight = !red
    endelse

    ; annotations at the bottom are 0.8 characters from the bottom
    botLine = 0.8*(charsize/1.4)*float(!d.y_ch_size)/float(!d.y_size)
    xyouts,0.68,botLine,label_dc,/normal,charsize=charsize/1.4,color=redHighlight
    xyouts,0.8,botLine,systime(),/normal,charsize=charsize/1.4,color=foreground
    if ((mystate.bdrop gt 0) or (mystate.edrop gt 0)) then $
      xyouts,0.02,botLine,string(mystate.bdrop,mystate.edrop,format='("bdrop : ",I4,"  edrop : ",I4)'), $
             /normal,charsize=charsize/1.4,color=foreground

end
