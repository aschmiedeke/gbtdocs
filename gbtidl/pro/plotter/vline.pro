; docformat = 'rst'

;+
; Mark a verticle line at the given x-location.  Optionally include a
; label at the same x and the given y-location.
;
; :Params:
;   x : in, required, type=float
;       The x-location to draw the vertical line. In the current
;       x-axis units.
;
; :Keywords:
;   ylabel : in, optional, type=float
;       The y-location to put the optional label text. ylabel is 
;       required if label is specified.
;
;   label : in, optional, type=string
;       The label to associate with this vertical line.
;
;   noshow : in, optional, type=boolean
;       Don't immediately show the new vline. This is useful if you 
;       are stringing several vline calls together.  It keeps the 
;       plotter from updating after each call and make the whole 
;       operation run faster.  Simply call "reshow" when you are 
;       ready to show the final result.
;
;   ynorm : in, optional, type=boolean
;       The y-position for the label is in normalized coordinates 
;       when this keyword is set. That means that the label maintains
;       its position relative to the entire y-axis no matter what 
;       changes in y-range (zoom) and x-axis.
;
;   idstring : in, optional, type=string
;       An string to use to identify this particular vline. This can
;       be used in clearvlines to clear a particular vline or group 
;       of vlines having the same idstring. The default is an empty
;       string.
;
;-
pro vline, x, label=label, ylabel=ylabel, noshow=noshow, ynorm=ynorm, $
           idstring=idstring
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if n_elements(x) eq 0 then begin
        message,'Usage: vline, x[, label=label, ylabel=ylabel, /noshow, /ynorm',/info
        return
    endif
    if (keyword_set(label)) then begin
        if (not keyword_set(ylabel)) then begin
            message, 'ylabel is required when label is set',/info
            return
        endif
    endif else begin
        label = ''
        ylabel = 0.0
    endelse

    mystate.nvlines = mystate.nvlines+1
    if mystate.nvlines gt mystate.maxnvlines then begin
        ; add another 100 lines
        (*mystate.vline_pos) = [(*mystate.vline_pos), fltarr(100,2)]
        (*mystate.vline_txt) = [(*mystate.vline_txt), strarr(100)]
        (*mystate.vline_ynorm) = [(*mystate.vline_ynorm), intarr(100)]
        (*mystate.vline_idstring) = [*(mystate.vline_idstring), strarr(100)]
        mystate.maxnvlines += 100
    endif

    (*mystate.vline_pos)[mystate.nvlines-1,0] = x
    (*mystate.vline_pos)[mystate.nvlines-1,1] = ylabel
    (*mystate.vline_txt)[mystate.nvlines-1] = label
    (*mystate.vline_ynorm)[mystate.nvlines-1] = keyword_set(ynorm)
    thisidstring = ''
    if n_elements(idstring) then thisidstring = idstring[0]
    (*mystate.vline_idstring)[mystate.nvlines-1]=thisidstring
    if not keyword_set(noshow) then reshow

end
