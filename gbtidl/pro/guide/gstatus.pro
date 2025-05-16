; docformat = 'rst' 

;+
; Summarize the status of GBTIDL as found in the global structure used
; by GBTIDL (``!g``).
;
; This summarizes the parts of the ``!g`` structure that the user
; is most likely to care about.  ``help,!g,/struct`` is useful, but
; only if you know exactly what you are looking for.  Many fields
; in ``!g`` are not intended to be manipulated directly by the user
; and even those that are are sometimes difficult to interpret.
;
; Using ``/full`` adds plotter color settings to the output.
;
; See also the description of the contents of the ``!g`` structure 
; :ref:`here <The !g Structure>`.
;
;
; :Keyword:
;   full : in, optional, type=boolean
;       If set, color settings are also summarized. 
;       The default is to omit that information.
;
; :examples:
; 
;   .. code-block:: IDL
; 
;       gstatus
; 
;-
pro gstatus, full=full
    compile_opt idl2

    ; can we use more
    if !g.interactive then begin
        openw, out, '/dev/tty', /get_lun, /more
    endif else begin
        ; just write to stdout
        out = -1
    endelse

    mode = !g.line ? 'LINE' : 'CONTINUUM'
    printf,out,''
    printf,out,'Status of GBTIDL version ',!g.version, ' : ', mode
    printf,out,''
    linein = (strlen(!g.line_filein_name) gt 0) ? !g.line_filein_name : '_not opened_'
    contin = (strlen(!g.cont_filein_name) gt 0) ? !g.cont_filein_name : '_not opened_'
    lineout = (strlen(!g.line_fileout_name) gt 0) ? !g.line_fileout_name : '_not opened_'
    printf,out,'    line filein: ', linein
    printf,out,'    cont filein: ', contin
    printf,out,'   line fileout: ', lineout
    printf,out,'    nsave is ',((!g.sprotect) ? '':'NOT '),'write protected'
    printf,out,''
    printf,out,'   plotter is ', !g.frozen ? 'frozen':'unfrozen'
    printf,out,'   region boxes are ', !g.regionboxes ? 'persistent': 'not persistent', ' (!g.regionboxes)'
    printf,out,''
    printf,out,'        printer: ', !g.printer
    printf,out,'colorpostscript: ', (!g.colorpostscript) ? 'yes' : 'no'
    printf,out,''
    printf,out,'   stack acount: ', !g.acount
    printf,out,'        nregion: ', !g.nregion
    printf,out,'           nfit: ', !g.nfit
    printf,out,'     last nsave: ', !g.nsave
    printf,out,''

    if keyword_set(full) then begin
        printf,out,'Colors'
        printf,out,'    background   ',getbangcolor(!g.background)
        printf,out,'    foreground   ',getbangcolor(!g.foreground)
        printf,out,'     showcolor   ',getbangcolor(!g.showcolor)
        printf,out,'    oshowcolor   ',getbangcolor(!g.oshowcolor)
        printf,out,'    oplotcolor   ',getbangcolor(!g.oplotcolor)
        printf,out,'    gshowcolor   ',getbangcolor(!g.gshowcolor)
        printf,out,'gausstextcolor   ',getbangcolor(!g.gausstextcolor)
        printf,out,'highlightcolor   ',getbangcolor(!g.highlightcolor)
        printf,out,'crosshaircolor   ',getbangcolor(!g.crosshaircolor)
        printf,out,'    zlinecolor   ',getbangcolor(!g.zlinecolor)
        printf,out,'   markercolor   ',getbangcolor(!g.markercolor)
        printf,out,' annotatecolor   ',getbangcolor(!g.annotatecolor)
        printf,out,'    vlinecolor   ',getbangcolor(!g.vlinecolor)
        printf,out,'     zoomcolor   ',getbangcolor(!g.zoomcolor)
        printf,out,''
    endif

    if out ne -1 then free_lun, out
end


