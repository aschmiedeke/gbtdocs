;+
; Initialize the GUIDE global structure.
;
; <p>This is called by the startup script and probably should not be
; called by the user. 
;
; <p>The data containers are initialized using <a href="../toolbox/data_new.html">data_new</a>.
; <p>
; The input io objects are simply initialized with the default
; constructors.
; <p>
; The lineoutio object is initialized with "GBTIDL_KEEP.fits".
; <p>
; The astack has a size of 5120 elements.
; <p>
; Line mode is the default mode.
; <p>
; The printer is set to the PRINTER environment variable or 'lp' if
; PRINTER is not set.
;
; @private_file
;
; @version $Id$
;-

PRO init_guide_struct
    compile_opt idl2, hidden
   
    !g.version = '2.10.1'

    !g.interactive = hastty()

    for i=0, (n_elements(!g.s)-1) do begin
        !g.s[i] = data_new()
    endfor
    for i=0, (n_elements(!g.c)-1) do begin
        !g.c[i] = data_new(/continuum)
    endfor
    !g.plotter_axis_type = 1
    !g.sprotect = 1
    !g.lineio = obj_new('io_sdfits_line')
    !g.contio = obj_new('io_sdfits_cntm')
    !g.lineoutio = obj_new('io_sdfits_writer')
    ; point at a default name in the current directory
    !g.lineoutio->set_file,'GBTIDL_KEEP.fits'
    !g.line_filein_name = ''
    !g.cont_filein_name = ''
    !g.line_fileout_name = 'GBTIDL_KEEP.fits'
    ; if this is in batch mode, don't use 'more' style paging
    if !g.interactive eq 0 then begin
        !g.lineio->set_more_format_off
        !g.contio->set_more_format_off
        !g.lineoutio->set_more_format_off
    endif
    !g.astack = ptr_new(lonarr(5120))
    !g.line = 1
    sclear
    !g.regions = replicate(-1,2,100)
    !g.printer = getenv('PRINTER')
    if (strlen(!g.printer) eq 0) then !g.printer = 'lp'
    !g.tau0 = 0.0
    !g.ap_eff = 0.7
    !g.nsave = -1

    ; initialize the display settings here
    !g.has_display = init_display()
    !g.frozen = !g.has_display ? 0 : 1
    if !g.has_display then begin
       ; various default colors
       !g.background = !black
       !g.foreground = !white
       !g.showcolor = !red
       !g.oshowcolor = !white
       !g.crosshaircolor = !green
       !g.zlinecolor = !green
       !g.markercolor = !green
       !g.annotatecolor = !green
       !g.oplotcolor = !white
       !g.vlinecolor = !green
       !g.zoomcolor = !cyan
       !g.gshowcolor = !white
       !g.gausstextcolor = !white
       !g.highlightcolor = !cyan
    endif ; else there is no display and these don't matter
    ; default to a color postscript
    !g.colorpostscript = 1
END

