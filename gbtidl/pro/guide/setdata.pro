;+
; Convenience function for setting data array of a data container.
;
; @param value {in}{required}{type=float} data values to be inserted into the
; data container.  Either a single float value or an array of floats
; are valid.
;
; @param elements {in}{optional}{type=long}{default=all} The data array indices to be 
; changed.  Use one integer to set a single element in the data array.  Use
; a two element array to specify a range to be set.
;
; @keyword buffer {in}{optional}{type=integer}{default=0} The data container
; buffer number from which the data values are retrieved.
;
; @examples
; Put the first spectra into !g.s[0], retrieve all its data, and then just the first element
; <pre>
;    filein,'file.fits'
;    getrec,1
;    help, *!g.s[0].data_ptr
;    <PtrHeapVar257> FLOAT     = Array[2048]
;    x = fltarr(1026)
;    setdata, x
;    help, *!g.s[0].data_ptr
;    <PtrHeapVar257> FLOAT     = Array[1026]
;    setdata, 2.5, 0
;    help, (*!g.s[0].data_ptr)[0]
;    <PtrHeapVar257> FLOAT     = 2.5
; </pre>
;
; @uses <a href="../toolbox/data_valid.html">data_valid</a>
; @uses <a href="../toolbox/setdcdata.html">setdcdata</a>
;
;-
pro setdata, value, elements, buffer=buffer 
    compile_opt idl2

    if (n_elements(value) eq 0) then begin
        message,'Usage: setdata, value[, elements][, buffer=buffer]',/info
        return
    endif
    ; default - retrieve data from the primary data container
    if n_elements(buffer) eq 0 then to_buffer=0 else to_buffer=buffer

    if (!g.line) then begin
        if (to_buffer gt n_elements(!g.s) or to_buffer lt 0) then begin
            message, string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        if (data_valid(!g.s[to_buffer]) le 0) then begin
            message,'No data at given buffer',/info
            return
        endif
        if n_elements(elements) ne 0 then begin
            setdcdata,!g.s[to_buffer], value, elements
        endif else begin
            setdcdata,!g.s[to_buffer], value
        endelse    
    endif else begin
        if (to_buffer gt n_elements(!g.c) or to_buffer lt 0) then begin
            message, string((n_elements(!g.c)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        if (data_valid(!g.c[to_buffer]) le 0) then begin
            message,'No data at given buffer',/info
            return
        endif
        if n_elements(elements) ne 0 then begin
            setdcdata,!g.c[to_buffer], value, elements
        endif else begin
            setdcdata,!g.c[to_buffer], value
        endelse    
    endelse

    if (to_buffer eq 0 and not !g.frozen) then show

    return

END
    
