; docformat = 'rst'

;+
; List a specified selection parameter or all selection parameter
; values used by :idl:pro:`find`.
;
; This allows you to quickly tell the value of one or all of the
; selection parameters used by FIND.  The set of parameters is the
; column names as reported by :idl:pro:`listcols`.
;
; *Note:* Only those parameters that have actually been set
; are listed unless a listing for specific parameters has been
; requested.
;
; Use :idl:pro:`setfind` to set selection parameters.
;
; Use :idl:pro:`clearfind` to clear selection parameters.
;
; :Params:
;   param : in, optional, type=string
;       The selection parameter(s) to list.  Minimum-matching is used 
;       to find the selection parameter matching this value.  If param 
;       is not supplied or is an empty string, all parameters are listed.
;       Only parameters appropriate for the current mode (line or continuum)
;       are shown unless a specific parameter is requested.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       listfind  ; show all set find parameters
;       listfind,'scan'  ; show the value of the SCAN selection parameter
;       listfind,['scan','int','plnum'] ; show the values of 3 selection params
;
;-
pro listfind, param
    compile_opt idl2

    fnames = tag_names(!g.find)
    mode = !g.line ? 'LINE' : 'CONT'
    showall = 0
    if n_elements(param) gt 0 then begin
        thiscount = 0
        for i=0,(n_elements(param)-1) do begin
            thisindex = getfindindex(param[i],count=count)
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
        showall = 1
    endif else begin
        if !g.line then begin
            ; use all but the last three of fnames
            index = indgen(n_elements(fnames)-3)
        endif else begin
            ; use 0 through nsave + last 3
            nsave = where(fnames eq 'NSAVE')
            index = intarr(nsave+4)
            index[0:nsave] = indgen(nsave+1)
            nf = n_elements(fnames)
            index[(nsave+1)] = nf-3
            index[(nsave+2)] = nf-2
            index[(nsave+3)] = nf-1
        endelse
    endelse
    count = 0
    for i=0,(n_elements(index)-1) do begin
        thisindx = index[i]
        thisval = !g.find.(thisindx)
        if size(thisval,/type) eq 7 then begin
            if strlen(thisval) gt 0 then begin
                if not showall and count eq 0 then begin
                    print,'All set FIND parameters for ',mode,' mode'
                endif
                print,fnames[thisindx],' ',thisval
                count += 1
            endif else begin
                if showall then print,fnames[thisindx],' unset'
            endelse
        endif else begin
            if thisval ge 0 then begin
                if not showall and count eq 0 then begin
                    print,'All set FIND parameters for ',mode,' mode'
                endif
                print,fnames[thisindx],' ',thisval
                count += 1
            endif else begin
                if showall then print,fnames[thisindx],' unset'
            endelse
        endelse
    end
    if not showall and count eq 0 then begin
        print,'All FIND parameters for ',mode,' mode are unset'
    endif
end
