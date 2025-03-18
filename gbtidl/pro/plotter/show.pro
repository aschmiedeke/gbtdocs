;+
; This procedure displays a spectral line data container in the plotter.  
; The primary data container is displayed by default.  Pass an integer in the 
; dc variable to show one of the other buffers, or pass a data container in 
; the dc parameter explicitly.
;
; @param dc {in}{optional}{type=data container or integer}{default=0} a data 
; container, or an integer global buffer number.  Defaults to the primary data
; container (buffer 0).
;
; @keyword color {in}{optional}{type=long integer}{default=!g.showcolor} The
; color for the data to be plotted.
;
; @keyword defaultx {in}{optional}{type=boolean} When defaultx is set, the
; reference frame, velocity definition, and units from the data header in
; will be used on the x-axis.  Otherwise, the current plotter settings are 
; retained.
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
; @examples
; <pre>
;    ; a simple use of show:
;    getrec,1
;    show
;
;    ; retrieve some records and place them in global data containers 1-10
;    for i=1,10 do begin & getrec,i & copy,0,i & end
;
;    show,2   ; show the data in buffer 2
;    show,5   ; show the data in buffer 5
;    oshow,6  ; overlay the data from buffer 6
; </pre>
;
; @uses <a href="../../devel/plotter/show_support.html">show_support</a>
;
; @version $Id$
;-
pro show, dc, color=color, defaultx=defaultx, smallheader=smallheader, $
          noheader=noheader
    if n_elements(dc) eq 0 then begin
        if n_elements(color) eq 0 then begin
            show_support,defaultx=defaultx,smallheader=smallheader,noheader=noheader
        endif else begin
            show_support,color=color,defaultx=defaultx,smallheader=smallheader,noheader=noheader
        endelse
    endif else begin
        if n_elements(color) eq 0 then begin
            show_support,dc,defaultx=defaultx,smallheader=smallheader,noheader=noheader
        endif else begin
            show_support,dc,color=color,defaultx=defaultx,smallheader=smallheader,noheader=noheader
        endelse
    endelse
end
