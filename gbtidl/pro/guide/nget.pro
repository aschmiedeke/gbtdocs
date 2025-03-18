; docformat = 'rst'

;+
; Get a previously saved data container with the matching
; nsave number, and put it in the indicated global buffer number.
;
; Only spectral line data can currently be fetched using an nsave number.
;
; nget fetchs data from the output file (keep file) unless infile is set.
; 
; Flags (set via <a href="flag.html">flag</a>) can be selectively applied or ignored using 
; the useflag and skipflag keywords.  Only one of those two keywords
; can be used at a time (it is an error to use both at the same time).
; Both can be either a boolean (/useflag or /skipflag) or an array of
; strings.  The default is /useflag, meaning that all flag rules that
; have been previously set are applied when the data is fetched from
; disk, blanking data as described by each rule.  If /skipflag is set,
; then all of the flag rules associated with this data are ignored and
; no data will be blanked when fetched from disk (it may still contain
; blanked values if the actual values in the disk file have already
; been blanked by some other process).  If useflag is a string or
; array of strings, then only those flag rules having the same
; idstring value are used to blank the data.  If skipflag is a string
; or array of strings, then all flag rules except those with the same
; idstring value are used to blank the data. 
;
; :Params:
;   nsave : in, required, type=long
;       nsave number to be retrieved
; 
; :Keywords:
;   buffer : in, optional, type=long
;       global buffer number where the retrieved spectrum is stored (defaults to 0).
;   infile : in, optional, type=boolean
;       if set, use line input file instead of the output file.
;   useflag : in, optional, type=boolean or string, default=true
;       Apply all or just some of the flag rules?
;   skipflag : in, optional, type=boolean or string
;       Do not apply any or do not apply a few of the flag rules?
;   
; :Returns:
;   ok : out, optional, type=boolean
;       status output
;
; :Uses: 
;   <a href="set_data_container.html">set_data_container</a>
;
; :Examples:
;
;   ; get some data    
;   getps,10
;   ; do stuff to it and save result in nsave=50
;   nsave,50
;   ; do more stuff to that data, but oops, thats no good
;   ; back to previous state
;   nget,50
;
;-
pro nget,nsave,buffer=buffer,infile=infile,useflag=useflag,skipflag=skipflag,ok=ok
    compile_opt idl2

    ok = 0

    if (n_elements(nsave) eq 0) then begin
        usage,'nget'
        return
    endif

    lbuffer = 0
    if (n_elements(buffer) gt 0) then lbuffer = buffer

    if n_elements(useflag) gt 0 and n_elements(skipflag) gt 0 then begin
        message,'Useflag and skipflag can not be used at the same time',/info
        return
    endif

    if !g.line then begin
        if (lbuffer lt 0 or lbuffer ge n_elements(!g.s)) then begin
            message,string(n_elements(!g.s),format='buffer is out of range: 0:%i3'),/info
            return
        endif
     endif else begin
        message,'Continuum data can not be fetched from a keep file, sorry.',/info
        return
    endelse


    ; and get it
    count=0
    if keyword_set(infile) then begin
        dc = !g.lineio->get_spectra(nsave=nsave,count,useflag=useflag,skipflag=skipflag)
    endif else begin
        dc = !g.lineoutio->get_spectra(nsave=nsave,count,useflag=useflag,skipflag=skipflag)
    endelse
    
    if count ne 1 then begin
        message, "Could not retrieve spectrum with nsave number: "+string(nsave), /info
        ok = 0
        return
    endif else begin
        if (data_valid(dc) gt 0) then begin
            nblanks = count_blanks(dc[0],ntot)
            if nblanks eq ntot then begin
                message,'All the data in the item fetched is blanked.',/info
            endif
            set_data_container, dc, buffer=lbuffer
            data_free, dc
        endif else begin
            message, 'Fetched data appears to be empty or invalid',/info
            ok = 0
            return
        endelse
    endelse

    ok = 1
    return

end
    
