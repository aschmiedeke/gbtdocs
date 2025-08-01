; docformat = 'rst' 

;+
; Switch to line mode.  
;
; The value of !g.line is set to 1.  That value is used by several
; procedures and functions to decide how they should behave 
; (e.g. :idl:pro:`get`).
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       cont                 ; continuum mode
;       filein,'mydcr.fits'  ; open a continuum data FITS file from the DCR
;       getrec, 10           ; plot some data
;       line                 ; back to line mode
;                            ; any previously opened data (via filein or
;                            ; dirin) in line mode remains open (and the
;                            ; continuum data opened here is also still
;                            ; open).
; 
;-
PRO line
    compile_opt idl2
    !g.line = 1
END
