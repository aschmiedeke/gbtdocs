; docformat='rst'

;+
; Average the records listed in the stack.
;
; The data retrieval is done using :idl:pro:`getchunk`. See the documentation 
; there for a longer discussion on the useflag and skipflag keywords
; also found here.
;
; :Keywords:
; 
;   noclear : in, optional, type=boolean
;       If this is set, the accum buffer is not cleared prior to averaging 
;       the records
;   
;   useflag : in, optional, type=boolean or string, default=true
;       Apply all or just some of the flag rules?
;   
;   skipflag : in, optional, type=boolean or string
;       Do not apply any or do not apply a few of the flag rules?
; 
;   keep : in, optional, type=boolean
;       If this is set, the records are fetched from the keep file.
;
; :Examples:
; 
;   Add index number 25, 30 through 39, and the odd indexes from 41
;   through 51 to the stack, and average them.
; 
;   .. code-block:: IDL
;
;       addstack, 25
;       addstack, 30, 39
;       addstack, 41, 51, 2
;       avgstack
; 
;   An example showing the use of the /noclear keyword.
; 
;   .. code-block:: IDL
;
;       addstack, 25
;       addstack, 30, 39
;       avgstack, /noclear      ; see the result so far, do not clear it
;       emptystack
;       addstack, 50, 90, 2 
;       avgstack                ; builds on the previous result
;                               ; cleared after this use of avgstack
; 
;-
pro avgstack,noclear=noclear,useflag=useflag,skipflag=skipflag,keep=keep
    compile_opt idl2
    if not !g.line then begin
       message,'accum only works on spectral line data, can not avgstack continuum data, sorry',/info
       return
    endif
    if !g.acount le 0 then begin
       message,'The stack is empty, nothing to average.',/info
       return
    endif
    
    oldFrozen = !g.frozen
    freeze
    if not keyword_set(noclear) then sclear
    accumCountStart = !g.accumbuf[0].n
                                ; work out what the best nPerChunk is
                                ; 1000 rows is reasonable for 4K
                                ; spectra, scale it appropriately
    chunkSize = 1000*4096
    ; protect against problems getting values - likely the file 
    ; doesn't match the selection
    catch, error_status
    if error_status ne 0 then begin
       message,'Could not fetch some or all of the data',/info
       message,'Check arguments or try re-populating the stack',/info
       if not oldFrozen then unfreeze
       ; simplest to just do this
       heap_gc
       return
       catch,/cancel ; may not be necessary
    endif
    if keyword_set(keep) then begin
       nchCol = !g.lineoutio->get_index_values("NUMCHN")
    endif else begin
       nchCol = !g.lineio->get_index_values("NUMCHN")
    endelse
    nch = max(nchCol[(*!g.astack)[0:(!g.acount-1)]])
    nPerChunk = round(chunkSize/nch)
    if !g.acount le 1.2*nPerChunk then begin
       ; get everything in one chunk - up to an extra 20% of nPerChunk
       nPerChunk = !g.acount
       nChunk = 1
    endif else begin
       if abs(nPerChunk-!g.acount/2.0) le 0.1*nPerChunk then begin
          ; within 10% of the half of acount, split it evenly
          nPerChunk = round(!g.acount/2.0)
          nChunk = 2
       endif else begin
                                ; otherwise leave it as is
          nChunk = !g.acount / nPerChunk
          if nChunk*nPerChunk lt !g.acount then nChunk = nChunk + 1
       endelse
    endelse
       
    for c=0,(nChunk-1) do begin
       first = c*nPerChunk
       last = first+nPerChunk-1
       if last ge !g.acount then last = (!g.acount-1)
       indices = (*!g.astack)[first:last]
       chunk = getchunk(count=count,index=indices,keep=keep,useflag=useflag,skipflag=skipflag)
       if count ne (last-first+1) then message,'Problems getting data'
       for i=0,(n_elements(chunk)-1) do begin
          accum,dc=chunk[i]
       endfor
       data_free,chunk
    endfor
    ; the data is in hand, cancel the catch
    catch, /cancel

    if not oldFrozen then unfreeze
    accumCount = !g.accumbuf[0].n-accumCountStart
    if accumCount eq 0 then begin
        message,'All of the records retrieved using the stack were blanked.',/info
        if !g.accumbuf[0].n ne 0 then begin
            ave, noclear=noclear
        endif else begin
            if not !g.frozen then show
        endelse
    endif else begin
        if accumCount ne !g.acount then begin
            message,'Skipped '+strtrim(!g.acount - accumCount,2)+' records in average due to blanked data',/info
        endif
        ave, noclear=noclear
    endelse
end
