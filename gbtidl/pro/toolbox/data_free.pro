;+
; Free the data pointer in a data structure.  This should only be
; used when the data structure is no longer necessary since it leaves
; the data pointer in an invalid state.
; 
; @param data_struct {in}{out}{required}{type=data_container_struct} The
; struct to free.
;
; @version $Id$
;-
PRO DATA_FREE, data_struct
    compile_opt idl2

    ; check on match in data_struct's type
    if (data_valid(data_struct, name=name) eq -1) then begin
        message, 'data_struct must be a valid continuum or spectrum structure',/info
        return
    endif

    for i=0,(n_elements(data_struct)-1) do begin
        ; both have data_ptr
        if ptr_valid(data_struct[i].data_ptr) then ptr_free, data_struct[i].data_ptr

        ; continuum has more
        if (name eq 'CONTINUUM_STRUCT') then begin
            if ptr_valid(data_struct[i].date) then ptr_free, data_struct[i].date
            if ptr_valid(data_struct[i].utc) then ptr_free, data_struct[i].utc
            if ptr_valid(data_struct[i].mjd) then ptr_free, data_struct[i].mjd
            if ptr_valid(data_struct[i].longitude_axis) then ptr_free, data_struct[i].longitude_axis
            if ptr_valid(data_struct[i].latitude_axis) then ptr_free, data_struct[i].latitude_axis
            if ptr_valid(data_struct[i].lst) then ptr_free, data_struct[i].lst
            if ptr_valid(data_struct[i].azimuth) then ptr_free, data_struct[i].azimuth
            if ptr_valid(data_struct[i].elevation) then ptr_free, data_struct[i].elevation
            if ptr_valid(data_struct[i].subref_state) then ptr_free, data_struct[i].subref_state
            if ptr_valid(data_struct[i].qd_el) then ptr_free, data_struct[i].qd_el
            if ptr_valid(data_struct[i].qd_xel) then ptr_free, data_struct[i].qd_xel
            if ptr_valid(data_struct[i].qd_bad) then ptr_free, data_struct[i].qd_bad
        endif
    end

    return
end
