; docformat = 'rst'

;+
; This procedure places a text string on the plot
;
; :Params:
;   x {in}{required}{type=float} X position of the string
;   y {in}{required}{type=float} Y position of the string
;   text {in}{required}{type=string} The text to write
; 
; :Keywords:
;   color : in, optional, type=integer, default=!g.annotatecolor
;       Text color index
;   charsize : in, optional, type=float
;       character size
;   normal : in, optional, type=boolean
;       positions are normalized coordinates.
;   noshow : in, optional, type=boolean
;       Don't immediately show the new annotation. This is useful
;       if you are stringing several annotations together. It keeps 
;       the plotter from updating after each call.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       annotate,10.5,1.5,'Hello',color=!blue,charsize=2.0
;
;-
pro annotate,x,y,text,color=color,charsize=charsize,normal=normal,noshow=noshow
    common gbtplot_common,mystate,xarray
    if n_params() ne 3 then begin
       message,'Usage: annotate, x, y, text[,color=color,charsize=charsize,/normal,/noshow]',/info
       return
    endif
    mystate.n_annotations = mystate.n_annotations+1
    if mystate.n_annotations ge mystate.maxn_annotations then begin
        ; add another 100
        (*mystate.annotation) = [(*mystate.annotation),strarr(100)]
        (*mystate.xyannotation) = [(*mystate.xyannotation),fltarr(100,2)]
        (*mystate.ann_color) = [(*mystate.ann_color),intarr(100,3)]
        (*mystate.ann_charsize) = [(*mystate.ann_charsize),fltarr(100)]
        (*mystate.ann_normal) = [(*mystate.ann_normal),intarr(100)]
        mystate.maxn_annotations += 100
    end
    (*mystate.annotation)[mystate.n_annotations-1] = text
    (*mystate.xyannotation)[mystate.n_annotations-1,*] = [x,y]
    if n_elements(color) ne 0 then (*mystate.ann_color)[mystate.n_annotations-1] = color $
        else (*mystate.ann_color)[mystate.n_annotations-1] = !g.annotatecolor
    if n_elements(charsize) ne 0 then (*mystate.ann_charsize)[mystate.n_annotations-1] = charsize $
        else (*mystate.ann_charsize)[mystate.n_annotations-1] = 1.0
    (*mystate.ann_normal)[mystate.n_annotations-1] = keyword_set(normal)
    if (not keyword_set(noshow)) then reshow
end

