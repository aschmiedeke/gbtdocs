; docformat = 'rst'

;+
; Set the element of the appropriate GUIDE data structure array.
;
; If !g.line is true, the value is copied into the desired buffer in
; !g.s, otherwise it is copied in to !g.c.  This is most often used
; when working with toolbox procedures and function where a data
; container is used directly as an IDL variable and then copied into
; the guide structure so that it can be used with guide procedures and
; functions (e.g. show).
;
; :Params:
;   data : in, required
;       A data container (continuum or spectrum) to put into the 
;       indicated location.
;
; :Keywords:
;   buffer : in, optional, type=integer
;       The location to put the data. When not supplied the 0 location
;       is used.
;   ignore_line : in, optional, type=boolean
;       When set, the value of !g.line is ignored and the choice of
;       which data array to use is determined by the contents of data.
;   noshow : in, optional, type=boolean
;       Normally, if buffer is 0 and !g.frozen is 0 then show is called
;       at the end.  If this is set, that behavior is turned off.
;
;-
pro set_data_container, data, buffer=buffer, $
        ignore_line=ignore_line, noshow=noshow
    compile_opt idl2

    ; validate arguments
    if (data_valid(data, name=name) gt 0) then begin
        if (n_elements(buffer) eq 0) then begin
            buffer = 0
        endif else begin
            maxbuffer = (!g.line) ? n_elements(!g.c) : n_elements(!g.s)
            if (buffer lt 0 or buffer ge maxbuffer) then begin
                message, string((maxbuffer-1),format='("buffer must be >= 0 and <= ",i2)'),/info
                return
            endif
        endelse
        ; data_copy can't be used here because !g.s[buffer] and !g.c[buffer] are system 
        ; variables and they will be passed by value, not reference
        if (not keyword_set(ignore_line)) then begin
            if (name eq 'SPECTRUM_STRUCT' and !g.line eq 0) then begin
                message, 'Data container is SPECTRUM_STRUCT but GUIDE is in continuum mode',level=-1,/info
                message, 'Can not continue',/info
	        return
            endif
            if (name eq 'CONTINUUM_STRUCT' and !g.line) then begin
                message, 'Data container is CONTINUUM_STRUCT but GUIDE is in line mode',level=-1,/info
                message, 'Can not continue',/info
	        return
            endif
        endif

        ok2show = 0
        if (name eq 'SPECTRUM_STRUCT') then begin
            data_free, !g.s[buffer]
            !g.s[buffer] = data[0]
            ; now copy the pointer values, making new pointers here
            !g.s[buffer].data_ptr = ptr_new(*(data[0].data_ptr))
            ok2show = !g.line
        endif else begin
            data_free, !g.c[buffer]
            !g.c[buffer] = data[0]
            ; now copy the pointer values, making new pointers here
            !g.c[buffer].data_ptr = ptr_new(*(data[0].data_ptr))
            ; must be CONTINUUM_STRUCT
            !g.c[buffer].date = ptr_new(*(data[0].date))
            !g.c[buffer].utc = ptr_new(*(data[0].utc))
            !g.c[buffer].mjd = ptr_new(*(data[0].mjd))
            !g.c[buffer].longitude_axis = ptr_new(*(data[0].longitude_axis))
            !g.c[buffer].latitude_axis = ptr_new(*(data[0].latitude_axis))
            !g.c[buffer].lst = ptr_new(*(data[0].lst))
            !g.c[buffer].azimuth = ptr_new(*(data[0].azimuth))
            !g.c[buffer].elevation = ptr_new(*(data[0].elevation))
            !g.c[buffer].subref_state = ptr_new(*(data[0].subref_state))
            !g.c[buffer].qd_el = ptr_new(*(data[0].qd_el))
            !g.c[buffer].qd_xel = ptr_new(*(data[0].qd_xel))
            !g.c[buffer].qd_bad = ptr_new(*(data[0].qd_bad))
            ok2show = not !g.line
        endelse

        if (!g.frozen eq 0 and buffer eq 0 and ok2show and not keyword_set(noshow)) then show
        if (n_elements(data) gt 1) then begin
            message, 'more than one item found - ignoring all but the first', level=-1,/info
        endif
    endif else begin
        message, 'data container appears to be empty or invalid, nothing to set',/info,level=-1
    endelse
return
end
