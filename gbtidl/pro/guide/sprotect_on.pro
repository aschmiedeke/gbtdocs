; docformat = 'rst' 

;+
; Turns on write protection for nsave numbers. When on, rows in index
; file with nsave numbers cannot be changed.
;
;-
PRO sprotect_on
    compile_opt idl2
    !g.sprotect = 1
END
