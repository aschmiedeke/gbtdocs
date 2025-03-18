;+
; This procedure divides the data from two data containers stored in
; the global buffers 0-15.  If no parameters are passed, then the data
; from buffer 0 is divided by buffer 1 and the result is stored in
; buffer 0.  If two parameters are supplied, the data at the first
; buffer number is divided by the data at the second buffer number and
; the result is stored in buffer 0.  If three parameters are supplied,
; the result is stored in the third (output) buffer number.
;
; <p> out = in1 / in2
;
; @param in1 {in}{optional}{type=integer} First input data buffer number
; @param in2 {in}{optional}{type=integer} Second input data buffer number
; @param out {in}{optional}{type=integer} Output data buffer number
;
; @examples
; <pre>
;    getrec,1
;    copy,0,1
;    getrec,2
;    divide
;
;    getrec,1
;    copy,0,10
;    getrec,2
;    copy,0,11
;    divide,10,11,12     ; The data from buffer 10 is divided by buffer 11
;                        ; and the result is stored in buffer 12
; </pre>
;
; @uses <a href="../toolbox/dcdivide.html">dcdivide</a>
; @uses <a href="../toolbox/dcpaircheck.html">dcpaircheck</a>
;
; @version $Id$
;-
pro divide, in1, in2, out

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
            message,msg+' Cannot divide, spectra incompatible',/info
            return
        endif
        frozen = !g.frozen
        freeze
        a = dcdivide(!g.s[in1],!g.s[in2])
        if in1 ne out then copy,in1,out
        setdata,a,buffer=out
        if not frozen then unfreeze
    endif else begin
        if (dcpaircheck(!g.c[in1],!g.c[in2],msg) ne 1) then begin
            message,msg+' Cannot divide, continua incompatible',/info
            return
        endif
        frozen = !g.frozen
        freeze
        a = dcdivide(!g.c[in1],!g.c[in2])
        if in1 ne out then copy,in1,out
        setdata,a,buffer=out
        if not frozen then unfreeze
    endelse
    if out eq 0 and not !g.frozen then show, out

end
