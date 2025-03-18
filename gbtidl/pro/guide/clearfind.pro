;+
; Clear a selection parameter or several selection parameters used by
; <a href="find.html">find</a>
; <p>
; Use <a href="setfind.html">setfind</a> to set a selection parameter.
; <p>
; Use <a href="listfind.html">listfind</a> to list a selection parameter.
;
; @param param {in}{optional}{type=string} The selection parameter(s)
; to clear.  Minimum-matching is used to find the selection parameters
; matching this value.  If param is not supplied or is an empty
; string, all parameters are cleared.  If all parameters are to be
; cleared (param is not set or is an empty string) then only those
; parameters appropriate for the given mode (line or continuum) are
; cleared.
;
; @examples
; See <a href="find.html">find</a>
; 
; @version $Id$
;-
pro clearfind, param
    compile_opt idl2
    fnames = tag_names(!g.find)
    if n_elements(param) gt 0 then begin
        thiscount = 0
        for i=0,(n_elements(param)-1) do begin
            thisindex = getfindindex(param[i],count=count,mode=mode)
            if count eq 0 then begin
                print,param[i],' is not a valid selection parameter, choose from'
                print,fnames
                return
            endif
            if thiscount eq 0 then begin
                index = thisindex
                thiscount = count
            endif else begin
                index = [index,thisindex]
                thiscount += count
            endelse
        end
    endif else begin
        if !g.line then begin
            ; clear all but the last three of fnames
            index = indgen(n_elements(fnames)-3)
        endif else begin
            ; clear 0 through nsave plus last three
            nsave = where(fnames eq 'NSAVE')
            index = intarr(nsave+4)
            index[0:nsave] = indgen(nsave+1)
            index[nsave+1] = n_elements(fnames)-3
            index[nsave+2] = index[nsave+1]+1
            index[nsave+3] = index[nsave+2]+1
        endelse
    endelse
    for i=0,(n_elements(index)-1) do begin
        !g.find.(index[i]) = ''
    end
end
