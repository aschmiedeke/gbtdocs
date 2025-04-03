; docformat = 'rst' 

;+
; Clear the given accum_struct, free's the pointer, zeros' values.
;
; :Params:
;   accumbuf : in, out, required, type=accum_struct structure
;       the structure to clear. 
;
;-
PRO accumclear, accumbuf
    compile_opt idl2

    on_error, 2

    if n_params() ne 1 then begin
        usage,'accumclear'
        return
    endif

    ; verify argument
    if (size(accumbuf,/type) ne 8 or tag_names(accumbuf,/structure_name) ne "ACCUM_STRUCT") then begin
        message,"accumbuf is not an accum_struct structure",/info
        return
    endif

    if (ptr_valid(accumbuf.data_ptr)) then ptr_free, accumbuf.data_ptr
    if (ptr_valid(accumbuf.wt_ptr)) then ptr_free, accumbuf.wt_ptr
    accumbuf.teff = 0.0
    accumbuf.tint = 0.0
    accumbuf.tsys_sq = 0.0
    accumbuf.tsys_wt = 0.0
    accumbuf.f_delt = 0.0D
    accumbuf.f_res = 0.0D
    accumbuf.n = 0
    if data_valid(accumbuf.template) gt 0 then data_free, accumbuf.template

END
