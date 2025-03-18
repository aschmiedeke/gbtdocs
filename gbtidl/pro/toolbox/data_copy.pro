;+
; Copy the data container from in to out.
;
; This procedure can be used to generate a new data container, or to
; copy one data container into an existing data container.  However, it
; cannot be used to copy into one of the global data containers.
; To copy a data container stored as a local variable into a global
; data container, use the procedure set_data_container.
; 
; @param in {in}{required}{type=data_container_struct} The data container
; copied.  This can be identified by a local valiable or it can be
; a global data container, such as !g.s[0]
;
; @param out {out}{required}{type=data_container_struct} The data container to receive
; the copy.  This can be a local variable, but NOT a global data container.
;
; @examples
; <pre>
; get, mc_scan=22, cal='F', sig='T', pol='XX', if_num=1, int=1 ; sig
; data_copy,!g.s[0],spec
; a = getdcdata(spec)
; a = a * 2.0
; setdcdata,spec,a
; show,spec
; data_free, spec  ; clean up memory
; </pre>
;
; @uses <a href="data_valid.html">data_valid</a>
; @uses <a href="data_free.html">data_free</a>
;
; @version $Id$
;-
PRO DATA_COPY, in, out
    compile_opt idl2

    ; check on match in data_struct's type
    if (data_valid(in, name=name) eq -1) then begin
        message, 'in must be a valid continuum or spectrum structure',/info
        return
    endif

    ; preserve the ptrs in out
    outDataPtr = -1
    outDatePtr = -1
    outUtcPtr = -1
    outMjdPtr = -1
    outLongPtr = -1
    outLatPtr = -1
    outLstPtr = -1
    outAzPtr = -1
    outElPtr = -1
    outSubrefPtr = -1
    outQdElPtr = -1
    outQdXelPtr = -1
    outQdBadPtr = -1

    if data_valid(out, name=outname) ge 0 then begin
        if outname ne name then begin
            ; not the same type, free out
            data_free,out
        endif else begin
            ; if one is valid they are all valid
            outDataPtr = out.data_ptr
            if (name eq 'CONTINUUM_STRUCT') then begin
                outDatePtr = out.date
                outUtcPtr = out.utc
                outMjdPtr = out.mjd
                outLongPtr = out.longitude_axis
                outLatPtr = out.latitude_axis
                outLstPtr = out.lst
                outAzPtr = out.azimuth
                outElPtr = out.elevation
                outSubrefPtr = out.subref_state
                outQdElPtr = out.qd_el
                outQdXelPtr = out.qd_xel
                outQdBadPtr = out.qd_bad
            endif
        endelse
    endif

    ; copy everything, including pointers
    out = in

    ; restore the out pointers
    if not ptr_valid(outDataPtr) then begin
        ; none of them are valid
        out.data_ptr = ptr_new(/allocate_heap)
        if (name eq 'CONTINUUM_STRUCT') then begin
            out.date = ptr_new(/allocate_heap)
            out.utc = ptr_new(/allocate_heap)
            out.mjd = ptr_new(/allocate_heap)
            out.longitude_axis = ptr_new(/allocate_heap)
            out.latitude_axis = ptr_new(/allocate_heap)
            out.lst = ptr_new(/allocate_heap)
            out.azimuth = ptr_new(/allocate_heap)
            out.elevation = ptr_new(/allocate_heap)
            out.subref_state = ptr_new(/allocate_heap)
            out.qd_el = ptr_new(/allocate_heap)
            out.qd_xel = ptr_new(/allocate_heap)
            out.qd_bad = ptr_new(/allocate_heap)
        endif
    endif else begin
        ; all of them are valid
        out.data_ptr = outDataPtr
        if (name eq 'CONTINUUM_STRUCT') then begin
            out.date = outDatePtr
            out.utc = outUtcPtr
            out.mjd = outMjdPtr
            out.longitude_axis = outLongPtr
            out.latitude_axis = outLatPtr
            out.lst = outLstPtr
            out.azimuth = outAzPtr
            out.elevation = outElPtr
            out.subref_state = outSubrefPtr
            out.qd_el = outQdElPtr
            out.qd_xel = outQdXelPtr
            out.qd_bad = outQdBadPtr
        endif
    endelse

    ; now copy the data values into the pointers
    ; all pointers should be valid here
    if data_valid(in) eq 0 then begin
        if size(*out.data_ptr,/type) ne 0 then begin
            ; no other way to do this, I think
            ; if one is not undefined, they all defined
            ; they need to be undefined here
            ptr_free, out.data_ptr
            out.data_ptr = ptr_new(/allocate_heap)
            if (name eq 'CONTINUUM_STRUCT') then begin
                ptr_free, out.date
                ptr_free, out.utc
                ptr_free, out.mjd
                ptr_free, out.longitude_axis
                ptr_free, out.latitude_axis
                ptr_free, out.lst
                ptr_free, out.azimuth
                ptr_free, out.elevation
                ptr_free, out.subref_state
                ptr_free, out.qd_el
                ptr_free, out.qd_xel
                ptr_free, out.qd_bad              
                out.date = ptr_new(/allocate_heap)
                out.utc = ptr_new(/allocate_heap)
                out.mjd = ptr_new(/allocate_heap)
                out.longitude_axis = ptr_new(/allocate_heap)
                out.latitude_axis = ptr_new(/allocate_heap)
                out.lst = ptr_new(/allocate_heap)
                out.azimuth = ptr_new(/allocate_heap)
                out.elevation = ptr_new(/allocate_heap)
                out.subref_state = ptr_new(/allocate_heap)
                out.qd_el = ptr_new(/allocate_heap)
                out.qd_xel = ptr_new(/allocate_heap)
                out.qd_bad = ptr_new(/allocate_heap)
            endif
        endif ; else they are already set
    endif else begin
        *out.data_ptr = *in.data_ptr
        if (name eq 'CONTINUUM_STRUCT') then begin
            *out.date = *in.date
            *out.utc = *in.utc
            *out.mjd = *in.mjd
            *out.longitude_axis = *in.longitude_axis
            *out.latitude_axis = *in.latitude_axis
            *out.lst = *in.lst
            *out.azimuth = *in.azimuth
            *out.elevation = *in.elevation
            *out.subref_state = *in.subref_state
            *out.qd_el = *in.qd_el
            *out.qd_xel = *in.qd_xel
            *out.qd_bad = *in.qd_bad
        endif
    endelse

    return
end
