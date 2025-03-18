;+
; Create a new data_struct of the requested data type (spectrum or
; continuum) and containing the given array, if supplied.  For
; continuum data, when the data array is supplied, the additional
; pointers (date, utc, mjd, etc) are set to double precision vectors
; of 0s having the same number of elements as arr.
; 
; @param arr {in}{optional}{type=integer}{default=u1ndefined} The data
; pointer that this data_struct will hold.  If arr is not provided,
; then the data pointer will point to an undefined variable.
;
; @keyword spectrum {in}{optional}{default=set} When this is set, a spectrum
; structure will be returned.  That is the default behavior.
;
; @keyword continuum {in}{optional}{default=unset} When this is set, a
; continuum structure will be returned.  spectrum and continuum are mutually
; exclusive.
;
; @keyword nocheck {in}{optional}{default=unset} When this is set,
; the input parameter checking is turned off.  Usefull for speed.
;
; @returns requested data structure of given size or -1 on failure.
;
; @version $Id$
;-
FUNCTION DATA_NEW, arr, spectrum=spectrum, continuum=continuum, nocheck=nocheck
    compile_opt idl2

   if (not keyword_set(nocheck)) then begin
                                ; check inputs
        if n_params() eq 1 then begin
           info = size(arr,/structure)
            if ((info.type eq 0) || (info.type ge 6 and info.type le 11)) then begin
                message, 'arr must be numeric', /info
                return, -1
            endif
            if (info.n_dimensions ne 1) then begin
                message, 'arr must be 1-dimensional',/info
                return, -1
            endif
            length = n_elements(arr)
        endif
        
        if (keyword_set(spectrum) and keyword_set(continuum)) then begin
            message, 'Only one of spectrum or continuum can be used at a time',/info
            return, -1
        endif
    endif

    ; spectrum defaults, unless continuum is present
    if (keyword_set(continuum)) then begin
        result = {continuum_struct}
        if (n_params() eq 1) then begin
            ; initialize other arrays to 0's of same length as arr
            zeros = dblarr(n_elements(arr))
            result.date = ptr_new(strarr(n_elements(arr)))
            result.utc = ptr_new(zeros)
            result.mjd = ptr_new(zeros)
            result.longitude_axis = ptr_new(zeros)
            result.latitude_axis = ptr_new(zeros)
            result.lst = ptr_new(zeros)
            result.azimuth = ptr_new(zeros)
            result.elevation = ptr_new(zeros)
            ; except subref_state, all 1s
            result.subref_state = ptr_new(make_array(n_elements(arr),/int,value=1))
            ; and qd_el, qd_xel are all NaNs
            result.qd_el = ptr_new(make_array(n_elements(arr),value=!values.d_nan))
            result.qd_xel = ptr_new(make_array(n_elements(arr),value=!values.d_nan))
            ; and qd_bad is all -1
            result.qd_bad = ptr_new(make_array(n_elements(arr),/int,value=-1))
        endif else begin
            result.date = ptr_new(/allocate_heap)
            result.utc = ptr_new(/allocate_heap)
            result.mjd = ptr_new(/allocate_heap)
            result.longitude_axis = ptr_new(/allocate_heap)
            result.latitude_axis = ptr_new(/allocate_heap)
            result.lst = ptr_new(/allocate_heap)
            result.azimuth = ptr_new(/allocate_heap)
            result.elevation = ptr_new(/allocate_heap)
            result.subref_state = ptr_new(/allocate_heap)
            result.qd_el = ptr_new(/allocate_heap)
            result.qd_xel = ptr_new(/allocate_heap)
            result.qd_bad = ptr_new(/allocate_heap)
        endelse
    endif else begin
        result = {spectrum_struct}
    endelse

    ; both have data_ptr fields
    if (n_params() eq 1) then begin
        result.data_ptr = ptr_new(arr)
    endif else begin
        result.data_ptr = ptr_new(/allocate_heap)
    endelse

    return, result
end
