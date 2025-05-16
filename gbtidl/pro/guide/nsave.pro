; docformat = 'rst'

;+
; Save a data container to the current fileout with the indicate NSAVE
; value.  If the ``!g.sprotect`` flag is true and nsave already exists,
; then the output file will not be changed and a message to that
; effect will be printed out.  Otherwise, if nsave exists it will be
; overwritten with the data being saved so that there will only be at
; most one instance of each nsave value in any file.  The data can be
; recovered by specifying the nsave search parameter.  See the
; examples.
;
; :Params:
;   nsave : in, required, type=integer
;       The output nsave to use when saving this data.
;
; :Keywords: 
;   buffer : in, optional, type=integer, default=0
;       The global buffer number to use when saving to disk.
;
;   dc : in, optional, type=data container
;       A specific data container to save.  If dc is set, buffer is ignored.
;
;   ok : out, optional, type=integer
;       Optionally return the exit status of this procedure.  This is
;       1 on success and 0 on failure.  This is chiefly useful when used 
;       inside another procedure or function.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getps,10  ; get some data
;       ; do stuff to it
;       nsave,50  ; its now in nsave=50
;       ; do more stuff to that data, oops, thats no good
;       ; back to previous state
;       kget,nsave=50
; 
;-
pro nsave,nsave,buffer=buffer,dc=dc,ok=ok
    compile_opt idl2

    ok = 0

    if (n_elements(nsave) eq 0) then begin
        print,'Usage:  nsave, nsave[, buffer=buffer,dc=dc,ok=ok]'
        print,'  output nsave must be supplied.'
        print,'  buffer defaults to 0, primary data container.'
        print,'  dc is optional data container, overrides buffer'
        print,'  ok is the return status, 1 is good 0 is bad.'
        return
    endif

    if (n_elements(buffer) eq 0) then buffer = 0

    usedc = 0
    if (n_elements(dc) ne 0) then begin
        if data_valid(dc) le 0 then begin
            message,'No valid data in dc keyword value',/info
            return
        endif
        usedc = 1
    endif else begin
        if !g.line then begin
            if (buffer lt 0 or buffer ge n_elements(!g.s)) then begin
                message,string(n_elements(!g.s),format='buffer is out of range: 0:%i3'),/info
                return
            endif
            if data_valid(!g.s[buffer]) le 0 then begin
                message,string(buffer,format='No valid data in line data containers at %i2'),/info
                return
            endif
        endif else begin
            message,'continnuum data can not be kept yet',/info
            return
        endelse
    endelse

    ; ready to save, make sure the protection status is in sync
    if !g.sprotect then begin
        !g.lineoutio->set_sprotect_on
    endif else begin
        !g.lineoutio->set_sprotect_off
    endelse

    ; and save it
    status=0
    if usedc then begin
        !g.lineoutio->nsave_spectrum, dc, nsave, status
    endif else begin
        !g.lineoutio->nsave_spectrum, !g.s[buffer], nsave, status
    endelse

    if status eq 0 then begin
        if !g.sprotect then begin
            message,'Could not save data, !g.sprotect is true,',/info
        endif else begin
            message,'Could not save data - check for other error messages,',/info
        endelse
    endif else begin
        ok = 1
        !g.nsave = nsave
    endelse

    return
end
    
