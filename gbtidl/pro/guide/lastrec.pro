;+
; Returns the record number (index) of the most recently
; retrieved data container.
;
; <p>In line mode, this is the most recently retrieved record number
; from the input line file.  In continuum mode, this is the most
; recently retrieved record number from the input continuum file.  If
; the /keep keyword is used, this is the most recently retrieved
; record number from the output line file (the keep file).
;
; <p>This is -1 if nothing has been retrieved from that data source or
; if the data source is empty.
;
; <p>If multiple data containers were retrieved in a single call
; (e.g. using one of the calibration routines such as getfs) then this
; will be the largest record number in the set of records that were
; retrieved.
;
; @keyword keep {in}{optional}{type=boolean}  If set, returns the
; record number (index) of the data container most recently retrieved
; from the output line file (the keep file).
;
; @returns An integer giving the record number (index) of the last
; record fetched from the data source.  Returns -1 if nothing has been
; fetched so far from that data source.
;
; @examples
; <pre>
;   getps, 6000
;   a = lastrec()
; </pre>
; 
; @version $Id$
;-
function lastrec, keep=keep
    compile_opt idl2

    result = -1
    if keyword_set(keep) then begin
        result = !g.lineoutio->get_last_record()
    endif else begin
        thisIO = !g.line ? !g.lineio : !g.contio
        result = thisIO->get_last_record()
    endelse

    return, result
end
