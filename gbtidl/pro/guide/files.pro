; docformat = 'rst' 

;+
; Prints the file names being used for I/O.
;
; *NOTE:* This relies on the information at !g.line_filein_name,
; !g.cont_filein_name and !g.line_filout_name to be correct.
; :idl:pro:`gstatus` can also be used to show the files currently in 
; use (along with other GBTIDL information).
;
; :Keywords:
;   full : in, optional, type=boolean
;       When set, expand the file names to their full paths using
;       the IDL file_expand_path function.
; 
; :Examples:
; 
;   .. code-block:: IDL
; 
;       filein, '/home/line.fits'
;       cont
;       filein, '/home/continuum.fits'
;       files, /full ; print full path names
; 
;       spectral line  in : /home/fsfold.fits
;       spectral line out : /home/GBTIDL_KEEP.fits
; 
;       continuum  in : /home/continuum.fits
; 
;
; Note that GBTIDL_KEEP.fits, is the default output file and it is
; opened automatically on startup.
;
;-
pro files, full=full

    line_in = !g.line_filein_name
    cont_in = !g.cont_filein_name
    line_out = !g.line_fileout_name

    if strlen(line_in) eq 0 then begin
        line_in = 'Not connected.'
    endif else begin
        if keyword_set(full) then line_in = file_expand_path(line_in)
    endelse

    if strlen(cont_in) eq 0 then begin
        cont_in = 'Not connected.'
    endif else begin
        if keyword_set(full) then cont_in = file_expand_path(cont_in)
    endelse

    if strlen(line_out) eq 0 then begin
        line_out = 'Not connected.'
    endif else begin
        if keyword_set(full) then line_out = file_expand_path(line_out)
    endelse

    print
    print,line_in, format='("spectral line in  : ",a)'
    print,line_out,format='("spectral line out : ",a)'
    print
    print,cont_in, format='("continuum     in  : ",a)'
    print

end
