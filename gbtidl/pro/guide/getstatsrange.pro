; docformat = 'rst' 

;+
; Used by stats and moments to convert a region that might be in the
; x-axis units into a region in channels.  Both procedures work on the
; same rules and so this function encapsulates them in one place.
; This is not intended to be used by GUIDE users directly.
;
; :Params:
;   name : in, required, type=string
;       String inserted into prompt
;   nels : in, required, type=integer
;       Total number of data elements
;   brange : in, optional, type=float
;       Starting value in x-axis units
;   erange : in, optional, type=float
;       Ending value in x-axis units
; 
; :Keywords:
;   full : in, optional, type=boolean
;       Compute stats for full spectrum?
;   chan in, optional, type=boolean
;       Ranges are in channels?
; 
; :Returns:
;   2-element array with [bchan,echan] giving region in channels. 
;   Returns -1 on error (bchan and echan both out of range).
; 
; @private_file 
;-
function getstatsrange, name, nels, brange, erange, full=full, chan=chan
    compile_opt idl2

    hasXaxis = not (n_elements(getxarray()) eq 1 and (getxarray())[0] eq -1)
    if keyword_set(full) ne 0 then begin
        bchan = 0
        echan = n_elements(*!g.s[0].data_ptr)-1
    end else if (n_elements(brange) eq 0 or n_elements(erange) eq 0 ) then begin
       ; if no display, fall back to full range here
        if not !g.has_display then begin
            bchan = 0
            echan = nels-1
        endif else begin
            clearvlines,idstring='__stats'
            print,'Click twice to define ',name,' region'
            a = click()
            vline,a.x,idstring='__stats'
            thisbrange = a.x
            a = click()
            vline,a.x,idstring='__stats'
            thiserange = a.x
            bchan = xtochan(thisbrange)
            echan = xtochan(thiserange)
        endelse
    end else begin
        ; if no x-axis, then fall back to channels
        if not hasXaxis or keyword_set(chan) then begin
            bchan = brange
            echan = erange
        endif else begin
            bchan = xtochan(brange)
            echan = xtochan(erange)
        endelse
    end
    if (bchan lt 0 and echan lt 0) or (bchan ge nels and echan ge nels) then begin
        result = -1
    endif else begin
        if bchan gt echan then begin
            tmp = bchan & bchan = echan & echan = tmp
        end
        bchan = round(bchan)
        echan = round(echan)
        if bchan lt 0 then bchan = 0
        if echan ge nels then echan = nels
        result = [bchan,echan]
    endelse

    return, result
end
