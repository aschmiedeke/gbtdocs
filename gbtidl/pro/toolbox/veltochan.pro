; docformat = 'rst' 

;+
; Convert velocity (m/s) to channel number using
; the supplied data container.  The velocity's frame and definition can also be supplied.
;
; :Params:
;   data : in, required, type=spectrum
;       The spectrum data container to use to get the necessary header information.
;
;   vels : in, required
;       The velocities (m/s) to convert, may be an array of values.
;
; :Keywords:
;   frame : in, optional, type=string
;       The rest frame that the velocities are in. Known rest frames are listed in
;       :idl:pro:`frame_velocity`. Defaults to the frame given in data.velocity_definition.
;
;   veldef : in, optional, type=string
;       The velocity definition in use from RADIO, OPTICAL, or TRUE. Defaults to the value
;       found in data.velocity_definition. 
;
; :Returns:
;   channel number.
;
; :Uses:
;   :idl:pro:`data_valid`
;   :idl:pro:`decode_veldef`
;   :idl:pro:`chantofreq`
;   :idl:pro:`freqtovel`
;   :idl:pro:`veltofreq`
;   :idl:pro:`freqtochan`
; 
;-
function veltochan, data, vels, frame=frame, veldef=veldef
    compile_opt idl2

    ; argument check on data
    if (data_valid(data, name=name) le 0) then begin
        message, "invalid or undefined data structure"
        ; message will cause things to fail here.
    endif

    if (name ne 'SPECTRUM_STRUCT') then begin
        message, "data must be a spectrum structure"
        ; message will cause things to fail here.
    endif

    hasVeldef = 0
    if (n_elements(frame) eq 0) then begin
        if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
            message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
        endif
        hasVeldef = 1
        frame = v_frame
    endif else begin
        if (size(frame,/type) ne 7) then begin
            message, "frame has the wrong type, using value from data.velocity_definition", /info
            if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
                message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
            endif
            hasVeldef = 1
            frame = v_frame
        endif
    endelse

    if (n_elements(veldef) eq 0) then begin
        if (not hasVeldef) then begin
            if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
                message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
            endif
        endif
        veldef = v_def
    endif else begin
        if (size(veldef,/type) ne 7) then begin
            message, "veldef has the wrong type, using value from data.velocity_definition", /info
            if (not hasVeldef) then begin
                if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
                    message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
                endif
            endif
            veldef = v_def
        endif 
    endelse

    result = double(vels)

    ; convert that to frequency
    result = veltofreq(result, data.line_rest_frequency, veldef=veldef)

    ; and convert that to channel number
    result = freqtochan(data, result, frame=frame)

    return, result
end
