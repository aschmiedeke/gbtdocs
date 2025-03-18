;+
; Overplots using oplot on to the GBT plotter's surface.  It also
; remembers the x and y values so that they can be replotted as needed
; (e.g. the x-axis changes).  Overplots, if toggled off, are
; automatically toggled on by a call to gbtoplot.
;
; @param x {in}{optional}{type=numerical vector} The x values to
; be plotted.  If omitted, then x is assumed to be channels starting
; at 0 and going through n_elements(y) - 1.  When supplied, it must
; have the same number of elements as y.  Unless chan is specified,
; this is assumed to be in the same units as the existing x axis.
;
; @param y {in}{required}{type=numerical vector}. The y values to
; be plotted.
;
; @keyword color {in}{optional}{type=long integer}{default=!g.oplotcolor}
; The color of the line to be plotted.
;
; @keyword chan {in}{optional}{type=boolean} When set, the x axis is
; assumed to be in channels and a conversion to the existing x axis is
; necessary to plot them.  That conversion is done using the header
; information of the primary plot (the argument to the most recent
; show).
;
; @keyword index {out}{optional}{type=integer} Returns the index
; associated with this oplot.  This index can be used to clear this
; over plot using clearoplots.  Note that once an index is cleared,
; subsequent indexes are renumbered - i.e. there are never any gaps in
; in index number.
;
; @keyword idstring {in}{optional}{type=string} A string that can be
; used to identify this oplot and thereby group oplots together.  This
; is most useful with clearoplots to remove just those oplots with the
; same idstring.  Withing GBTIDL, all internal id strings begin with
; two underscores so that they are less likely to conflict with 
; user-defined idstrings.  The default is ''.
;
; @version $Id$
;-
pro gbtoplot, x, y, color=color, chan=chan, index=index, idstring=idstring
    compile_opt idl2
    common gbtplot_common,mystate, xarray

    if n_params() eq 0 then begin
        usage,'gbtoplot'
        return
    endif
    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif

    ; just one argument?
    if (n_params() eq 1) then begin
        ; just y
        locy = x
        locx = findgen(n_elements(locy))
        locchan = 1
    endif else begin
        if (n_elements(y) ne n_elements(x)) then begin
            message,'x and y must have the same number of elements',/info
            return
        endif
        locy = y
        locx = x
        locchan = keyword_set(chan) ? chan:0
    endelse

    loccolor = !g.oplotcolor
    if keyword_set(color) then loccolor = color

    ostruct = {x:double(locx), y:locy, fnname:'', params:-1, color:loccolor, $
               next:ptr_new(), prev:ptr_new(), plotme:1, idstring:''}

    if n_elements(idstring) then ostruct.idstring=idstring

    gbtoplot_support, ostruct, index, chan=locchan
end
