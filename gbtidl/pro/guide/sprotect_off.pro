; docformat = 'rst'

;+
; Turns off write protection for nsave numbers.  When off, rows in
; index file with nsave numbers can be changed.
;
;-
PRO sprotect_off
    compile_opt idl2
    !g.sprotect = 0
END
