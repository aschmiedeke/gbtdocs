; docformat = 'rst'

;+
; This procedure subtracts the data from two data containers stored in
; the global buffers 0-15.  
;
; If no parameters are passed, then the data from buffer 1 is
; subtracted from buffer 0 and the result is stored in buffer 0.  If
; two parameters are supplied, the second is subtracted from the first
; and the result is stored in buffer 0.  If three parameters are
; supplied, the second is subtracted from the first and the result is
; stored in the third. 
;
; out = in1 - in2
;
; 
; :Params:
;   in1 : in, optional, type=integer
;       Input data container #1
;   in2 : in, optional, type=integer
;       Input data container #2
;   out : in, optional, type=integer
;       Output data container
;
; :Examples:
;
;   .. code-block:: IDL
; 
;       getrec,1
;       copy,0,1
;       getrec,2
;       subtract
;
;       getrec,1
;       copy,0,10
;       getrec,2
;       copy,0,11
;       subtract,10,11,12   ; The data from buffer 11 is subtracted from buffer 10
;                           ; and the result is stored in buffer 12
; 
; :Uses:
;   :idl:pro:`dcsubtract`
;   :idl:pro:`dcpaircheck`
;
;-
pro subtract, in1, in2, out

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
            message,msg+' Cannot subtract, spectra incompatible',/info
            return
        endif
        frozen = !g.frozen
        freeze
        a = dcsubtract(!g.s[in1],!g.s[in2])
        if in1 ne out then copy,in1,out
        setdata,a,buffer=out
        if not frozen then unfreeze
    endif else begin
        if (dcpaircheck(!g.c[in1],!g.c[in2],msg) ne 1) then begin
            message,msg+' Cannot subtract, continua incompatible',/info
            return
        endif
        frozen = !g.frozen
        freeze
        a = dcsubtract(!g.c[in1],!g.c[in2])
        if in1 ne out then copy,in1,out
        setdata,a,buffer=out
        if not frozen then unfreeze
    endelse
    if out eq 0 and not !g.frozen then show, out

end
