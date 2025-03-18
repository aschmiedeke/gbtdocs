;+
; Switch to continuum mode.  The value of !g.line is set to 0.  That
; value is used by several procedures and functions to decide how they
; should behave (e.g. <a href="get.html">get</a>).  
;
; @examples
; <pre>
;   cont                 ; continuum mode
;   filein,'mydcr.fits'  ; open a continuum data FITS file from the DCR
;   getrec, 10           ; plot some data
;   line                 ; back to line mode
;                        ; any previously opened data (via filein or
;                        ; dirin) in line mode remains open (and the
;                        ; continuum data opened here is also still
;                        ; open).
; </pre>
;
; @version $Id$
;-
PRO cont
    compile_opt idl2
    !g.line = 0
END
