;+
; Add entries to "the stack", which is a list of numbers
; that can be used in batch operations.  The list is stored in
; the variable !g.astack.  The new entries are appended on to
; the existing list.  Use <a href="astack.html">astack</a> to get values from the stack.
;
; @param first {in}{required}{type=integer} The first value to be
; added to the stack.
;
; @param last {in}{optional}{type=integer} The last value to be
; added to the stack.  If this is omitted, only a single entry
; equal to first will be appended.
;
; @param step {in}{optional}{type=integer} The increment between values.
; If omitted, a step of 1 will be used.
;
; @examples
;    add numbers 25, 30 through 39, and the odd indexes from 41
;    through 51 to the stack.
; <pre>
;    addstack, 25
;    addstack, 30, 39
;    addstack, 41, 51, 2
; </pre>
;
; @uses <a href="appendstack.html">appendstack</a>
;
; @version $Id$
;-
PRO addstack, first, last, step
    compile_opt idl2

    ; check arguments
    if (n_elements(first) eq 0) then begin
        message, 'Usage: addstack, first[, last][, step]',/info
        return
    endif

    if (n_elements(last) eq 0) then last = first

    if (n_elements(step) eq 0) then step = 1

    ifirst = long(first[0])
    ilast = long(last[0])
    istep = long(step[0])

    if (istep eq 0) then istep = 1

    if (ifirst gt ilast and istep gt 0) then begin
        tmp = ilast
        ilast = ifirst
        ifirst = tmp
    endif

    ntoadd = long(abs(ifirst-ilast) / istep) + 1L

    addme = lindgen(ntoadd) * istep + ifirst

    appendstack, addme
END
