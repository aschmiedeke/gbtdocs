; docformat = 'rst'

;+
; This procedure multiplies the data from two data containers stored
; in the global buffers 0-15. 
;
; If no parameters are passed, then the data from buffers 0 and 1
; are multiplied and the result is stored in buffer 0.  If two
; parameters are supplied, the data from the first buffer number is
; multiplied by the data from the second buffer number and the result
; of the is stored in buffer 0.  If three parameters are supplied, the
; result is stored in the third (output) buffer number.
;
; out = in1 * in2
;
; :Params:
; 
;   in1 : in, optional, type=integer
;       First input data buffer number
;   in2 : in, optional, type=integer
;       Second input data buffer number #2
;   out : in, optional, type=integer
;       Output data buffer number.
;
; :Examples:
; 
;   .. code-block:: IDL
;    
;       getrec,1
;       copy,0,1
;       getrec,2
;       multiply
;
;       getrec,1
;       copy,0,10
;       getrec,2
;       copy,0,11
;       multiply,10,11,12   ; The data from buffers 10 and 11 are multiplied
;                           ; and the result is stored in buffer 12
;
; :Uses:
;   
;   :idl:pro:`dcadd`
;   :idl:pro:`dcpaircheck`
;
;-
pro multiply, in1, in2, out
    on_error, 2

    if n_params() eq 0 then begin
       in1 = 0
       in2 = 1
       out = 0
    end else if n_params() eq 2 then begin
       if in1 lt 0 or in1 gt 15 or in2 lt 0 or in2 gt 15 then begin
          message,'Illegal data container number.  Must be between 0 and 15.',/info
          return
       endif
       out = 0
    end else if n_params() eq 3 then begin
       if in1 lt 0 or in1 gt 15 or in2 lt 0 or in2 gt 15 or out lt 0 or out gt 15 then begin
          message,'Illegal data container number.  Must be between 0 and 15.',/info
          return
       endif
    end else begin
       message,'Incorrect number of parameters.',/info
       return
    end
                                                                                                                                 
    if !g.line then begin
        if (dcpaircheck(!g.s[in1],!g.s[in2],msg) ne 1) then begin
            message,msg+' Cannot multiply, spectra incompatible',/info
            return
        endif
        frozen = !g.frozen
        freeze
        a = dcmultiply(!g.s[in1],!g.s[in2])
        if in1 ne out then copy,in1,out
        setdata,a,buffer=out
        if not frozen then unfreeze
    endif else begin
        if (dcpaircheck(!g.c[in1],!g.c[in2],msg) ne 1) then begin
            message,msg+' Cannot multiply, continua incompatible',/info
            return
        endif
        frozen = !g.frozen
        freeze
        a = dcmultiply(!g.c[in1],!g.c[in2])
        if in1 ne out then copy,in1,out
        setdata,a,buffer=out
        if not frozen then unfreeze
    endelse
    if out eq 0 and not !g.frozen then show, out

end


