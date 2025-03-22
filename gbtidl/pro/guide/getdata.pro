; docformat = 'rst' 

;+
; Extract some or all of the data array from one of the global buffers.
;
; Use of getdata frees the user from having to deal with pointers
; by providing a copy of some or all of the data array in one of the
; global buffers (data containers).
;
; :Params:
;   buffer : in, optional, type=integer, default=0
;       The data container buffer from which the data are retrieved 
;       (defaults to buffer 0). 
;   elements : in, optional, type=integer, default=all
;       A subset of the full data array can be retrieved by specifying
;       either a single data array index, or a two-element array to
;       specify a range of data array indices. Defaults to all elements.
;
; :Keywords:
;   count : out, optional, type=integer
;       The total number of elements returned.  On error, this will be
;       0 and the returned value for this function will be -1.
;
; :Returns:
;   The extracted data.
;
; :Examples:
; 
;   .. code-block:: 
; 
;       filein,'file.fits'
;       getrec,0
;       x = getdata()
;       help, x
;       X               FLOAT     = Array[1026]
;       y = getdata(0,0)
;       help, y
;       Y               FLOAT     = 34.5000
;       z = getdata(0,[0,2])
;       help, z
;       z               FLOAT     = Array[3]
; 
; :Uses:
;   :idl:pro:`data_valid`
;   :idl:pro:`getdcdata`
;
;-
FUNCTION getdata, buffer, elements, count=count
    compile_opt idl2

    count = 0
    ; default - retrieve data from the primary data container
    if n_elements(buffer) eq 0 then buffer=0

    if (!g.line) then begin
        if (buffer gt n_elements(!g.s) or buffer lt 0) then begin
            message, string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
            return, -1
        endif
        if data_valid(!g.s[buffer]) le 0 then begin
            message,'No valid data at the given buffer',/info
            return, -1
        endif
        if n_elements(elements) ne 0 then begin
            data = getdcdata(!g.s[buffer], elements)
        endif else begin
            data = getdcdata(!g.s[buffer])
        endelse    
    endif else begin
        if (buffer gt n_elements(!g.c) or buffer lt 0) then begin
            message, string((n_elements(!g.c)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
            return, -1
        endif
        if data_valid(!g.c[buffer]) le 0 then begin
            message,'No valid data at the given buffer',/info
            return, -1
        endif
        if n_elements(elements) ne 0 then begin
            data = getdcdata(!g.c[buffer], elements)
        endif else begin
            data = getdcdata(!g.c[buffer])
        endelse    
    endelse
    count = n_elements(data)
    return, data
END
    
