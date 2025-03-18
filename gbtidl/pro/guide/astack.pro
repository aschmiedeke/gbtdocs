;+
; Function to return the value of a specific element of the stack.
;
; @param elem {in}{optional}{type=long integer} The index of
; the element to return.  If elem is omitted, the entire contents of
; the stack up through (!g.acount-1) is returned as an array.
; @keyword count {out}{optional}{type=long integer} The number of
; elements returned (0, 1 or !g.acount).
;
; @returns -1 on error (out of limits), a warning message also
; appears.
; @examples
; 
; A simple use of astack:
; 
; <pre>
;    ; stack contains [ 10,  12,  14,  20,  25, 28] to begin
;    my_elem = astack(3)
;    ; my_elem contains the value 20
; </pre>
;
; A more substantive use.  The following procedure averages all of
; the data from scans listed in the stack.
;
; <pre>
; pro myavg,_extra=extra
; freeze
; for i=0,!g.acount-1 do begin
;     getnod,astack(i),plnum=0,units='Jy',_extra=extra
;     accum
;     getnod,astack(i),plnum=1,units='Jy',_extra=extra
;     accum
; endfor
; ave
; unfreeze
; end
; </pre>
;
; In this example, select is used with astack to flag data using
; flagrec.  This is useful if the data isn't easily described using
; the parameters available in the flag procedure.  The end result here
; is that all of the data having a source equal to "Orion" and
; polarization equal to "RR" in IF number 3 is flagged from channel
; 500 through channel 520.
;
; <pre>
;   emptystack  ; clear the stack first
;   select, source='Orion', polarization='RR', ifnum=3 ; populate the stack
;   a = astack(count=count)
;   if count gt 0 then flagrec,a,bchan=500,echan=520,idstring='RFI-Orion'
; </pre>
;
; @version $Id$
;-
function astack, elem, count=count
    compile_opt idl2

    count = 0
    result = -1

    if !g.acount le 0 then begin
        message,'The stack is empty',/info
    endif else begin
        if n_elements(elem) eq 0 then begin
            result = (*!g.astack)[0:(!g.acount-1)]
            count = !g.acount
        endif else begin
            if (elem lt 0 or elem ge !g.acount) then begin
                message, 'elem is out of bounds', /info
            endif else begin
                result = (*!g.astack)[elem]
            endelse
        endelse
    endelse

    return, result
end
