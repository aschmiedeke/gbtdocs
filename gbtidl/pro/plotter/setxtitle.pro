;+
; Sets the x title for the gbtidl plotter given the xaxis type.
; This is intended for internal gbtidl plotter use only.
;
; @param type {in}{required}{type=integer} The type of x-axis to
; generate a title for.  Recognized types are 0=Channels, 1=Frequency,
; and 2=Velocity.  mystate.xtitle is set to title.  This is
; normally followed by a call to show.
;
; @private_file
;
; @version $Id$
;-
pro setxtitle, type
    compile_opt idl2
    common gbtplot_common, mystate, xarray

    mystate.xtitle = type
    case type of
        0: begin
            mystate.xtitle = 'Channels'
            if (mystate.xoffset ne 0.0) then begin
                mystate.xtitle += ' - ' + strcompress(string(mystate.xoffset),/remove_all)
            endif
        end
        1: begin
            mystate.xtitle = 'Frequency (' + mystate.xunit
            if (mystate.xoffset ne 0.0) then begin
                if (mystate.xoffset lt 0.0) then begin
                    mystate.xtitle += ' + '
                    xoffset = abs(mystate.xoffset)
                endif else begin
                    mystate.xtitle += ' - '
                    xoffset = mystate.xoffset
                endelse
                mystate.xtitle += strcompress(string(xoffset, format=('(G12.7)')),/remove_all)
            endif
            mystate.xtitle += ')'
            mystate.xtitle = mystate.frame + ' ' + mystate.xtitle
        end
        2: begin
            mystate.xtitle = 'Velocity ('  + mystate.xunit
            if (mystate.xoffset ne 0.0) then begin
                if (mystate.xoffset lt 0.0) then begin
                    mystate.xtitle += ' + '
                    xoffset = abs(mystate.xoffset)
                endif else begin
                    mystate.xtitle += ' - '
                    xoffset = mystate.xoffset
                endelse
                mystate.xtitle += strcompress(string(xoffset, format=('(G12.7)')),/remove_all)
            endif
            mystate.xtitle += ') ' + mystate.veldef
            mystate.xtitle = mystate.frame + ' ' + mystate.xtitle
        end
    endcase

    if (mystate.voffset ne 0 and type ne 0) then begin
        ; always report this in km/s
        ; convert to current veldef, eventually store veldef to use here
        voff = veltovel(mystate.voffset,mystate.veldef,'TRUE')
        voff /= 1.d3
        ; and reverse sign
        delta = textoidl('\Delta')
        mystate.xtitle += '  ' + delta + 'V=' + strcompress(string(voff, format=('(G10.5)')),/remove_all) + " km/s"
        if (type eq 1) then begin
            mystate.xtitle += ' ' + mystate.veldef
        endif

    endif
end
