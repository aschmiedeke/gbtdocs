; docformat = 'rst'

;+
; Save a spectrum to the output file.
;
; The data in the primary data container (buffer 0) is saved to the
; currently opened output file.  The user can optionally save another
; buffer (0 to 15) or a specific data container by supplying a value
; for the dc parameter.  Use :idl:pro:`fileout` to open an output file.
; Use :idl:pro:`kget` to retrieve data from the output file (:idl:pro:`nget`
; can also be used, the file can also be opened using :idl:pro:`filein`
; but only if some other file is already opened as the output file (the
; same file can not be opened by filein and fileout at the same time).
;
; Only spectral line data can be saved to disk at this time.
;
; :Params:
;   dc : in, optional, type=data container or integer, default=0
;       a data container, or an integer global buffer number. Defaults
;       to the primary data container (buffer 0).
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getnod,30
;       fileout,'mysave.fits'
;       keep
;       getnod,32
;       keep
;       getfs,48,/nofold
;       keep                    ; saves buffer 0 by default
;       keep,1                  ; saves buffer 1
;
;-
PRO keep,dc
    compile_opt idl2

    thisdc = 0
    if n_params() ne 1 then thisdc = 0 else thisdc = dc

    dctype = size(thisdc,/type)
    if dctype eq 8 then begin
        if data_valid(thisdc,name=type) le 0 then begin
            message,'data container is invalid, can not continue',/info
            return
        endif
        if type ne "SPECTRUM_STRUCT" then begin
            message,'Only spectrum data containers can be kept at this time, sorry.',/info
            return
        endif
        !g.lineoutio->write_spectra,thisdc
    endif else begin
        if (dctype eq 2 or dctype eq 3) then begin
            if (!g.line ne 1) then begin
                message, 'continuum data can not yet be kept, sorry.',/info
                return
            endif
            if thisdc lt 0 or thisdc ge n_elements(!g.s) then begin
                message,'Bad buffer number, must be >= 0 and < '+strtrim(string(thisdc),2),/info
                return
            endif
            ; veryify that there's something in !g.s[thisdc]
            if data_valid(!g.s[thisdc]) le 0 then begin
                message,'Data container at buffer '+strtrim(string(thisdc),2)+' is empty, nothing to keep',/info
                return
            endif
            !g.lineoutio->write_spectra,!g.s[thisdc]
        endif else  begin
            message,'dc argument must be a data container structure or an integer',/info
            usage,'keep'
            return
        endelse
    endelse
END
