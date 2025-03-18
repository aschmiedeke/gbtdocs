;+
; Utility function used by setfind, listfind, and clearfind to
; translate a parameter name into an index number in the !g.find
; structure.  Additional information on that index is also returned.
;
; @param param {in}{required}{type=string} The parameter to locate in
; !g.find.  minimum-match is allowed here.  Case is
; unimportant. Arrays of parameters are not allowed (-1 will be
; returned).
;
; @keyword mode {out}{optional}{type=integer} The mode that this is
; appropriate for.  -1 is all modes, 0 is line and 1 is continuum.
; 
; @keyword count {out}{optional}{type=integer} The number of matches
; to param found in !g.find.
;
; @returns Index values of param.  Returns -1 if not found.
;
; @private_file
;
; @version $Id$
;-
function getfindindex, param, mode=mode, count=count
    compile_opt idl2

    mode = -1
    count = 0

    if n_elements(param) ne 1 then return,-1

    itsparam = strtrim(strupcase(param),2)
    if strlen(itsparam) eq 0 then return, -1

    ; min-match
    paramregex = '^' + itsparam + '.*'
    fnames = tag_names(!g.find)
    index = where(stregex(fnames,paramregex,/boolean),count)

    if count eq 1 then begin
        ; last 3 are continuum-only
        if index ge (n_elements(fnames)-3) then begin
            mode = 1
        endif else begin
            ; NSAVE is the last mode=0 index
            nsaveindx = where(fnames eq 'NSAVE')
            if index gt nsaveindx then mode = 0
        endelse
    endif
    return,index
end
