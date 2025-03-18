;+
; Internal procedure to plot an item in the oplot list.
;
; @hidden_file
; @version $Id$
;-
pro oplotlistitem, item, usecolor, background, foreground, updatePixmap
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    itsColor = item.color
    oldwin = !d.window
    if !d.name ne 'PS' then wset,mystate.win_id
    if not usecolor or itsColor eq background then itsColor = foreground

    if (strlen(item.fnname) gt 0) then begin
        ; its a function, need to generate x and y
        catch, error_status
        if (error_status ne 0) then begin
            message,'Problem displaying a plot using this function: '+ item.fnname,/info
            help,/last_message,output=errtext
            print,errtext[0]
            return
        endif
        arr = call_function(item.fnname,item.params,mystate.minChan,mystate.maxChan, mystate.chanPerPix, count=count);
        catch,/cancel
        item.plotme = count ne 0
        if item.plotme then begin
            if (size(arr,/n_dimensions) ne 2) then begin
                message,'Problem with plot function - did not return a 2D array : '+ item.fnname,/info
                return
            endif
            ; watch for change in number of elements of x and y
            if count ne n_elements(item.x) then begin
                ; can not reuse
                x = arr[0,*]
                y = arr[1,*]
                ostruct = {x:x, y:y, fnname:item.fnname, params:item.params, color:item.color, $
                           next:item.next, prev:item.prev, plotme:item.plotme, idstring:item.idstring}
                if (ptr_valid(ostruct.prev)) then begin
                    ptr_free,(*ostruct.prev).next
                    (*ostruct.prev).next = ptr_new(ostruct)
                    if ptr_valid(ostruct.next) then begin
                        (*ostruct.next).prev = (*ostruct.prev).next
                    endif
                endif else begin
                    ptr_free,mystate.oplots_ptr
                    mystate.oplots_ptr = ptr_new(ostruct)
                    if ptr_valid(ostruct.next) then begin
                        (*ostruct.next).prev = mystate.oplots_ptr
                    endif
                endelse
                item = ostruct

            endif else begin
                ; can re-use
                item.x = arr[0,*]
                item.y = arr[1,*]
            endelse
            ; convert item.x to current x values 
            parsexunit, mystate.xunit, curscale, curtype
            item.x = convertxvalues(*mystate.dc_ptr, item.x, 1.0d, 0, '', '', 0.d, 0.d, $
                                    curscale, curtype, mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset)
        endif
    endif
    if not item.plotme then return
    if (itsColor ge 0) then begin
        oplot,item.x, item.y, color=itsColor
    endif else begin
        oplot, item.x, item.y
    endelse
    if (updatePixmap) then begin
        oldwin = !d.window
        wset,mystate.pix_id
        if (itsColor gt 0) then begin
            oplot, item.x, item.y, color=itsColor
        endif else begin
            oplot, item.x, item.y
        endelse
        wset,mystate.win_id
    endif
    if !d.name ne 'PS' then wset,oldwin
end
