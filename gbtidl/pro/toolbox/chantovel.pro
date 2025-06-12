; docformat = 'rst'

;+
; Convert channel number to velcity (m/s) using
; the supplied data container.  Optionally return the velocity in
; another reference frame.
;
; "Params:
;   data : in, required, type=spectrum
;       The spectrum data container to use to get the necessary header
;       information.
;
;   chans : in, required
;       The channel numbers to convert, may be an array of values.
;
; :Keywords:
;   frame : in, optional, type=string
;       The rest frame to convert to.  Known rest frames are listed in
;       :idl:pro:`frame_velocity`. Defaults to the frame given in 
;       data.velocity_definition.
;
;   veldef : in, optional, type=string
;       The velocity definition to use from RADIO, OPTICAL, or TRUE. 
;       Defaults to value found in data.velocity_definition. 
;
;   true_frame : out, optional, type=string
;       The actual rest frame used in constructing the velocity axis.  
;       The only way this will not equal the frame argument is if that 
;       argument was invalid. In that case, this keyword will be the 
;       same as the frame in data.velocity_definition.
;
;   true_veldef : out, optional, type=string
;       The actual velocity frame used in constructing the velocity axis.
;       The only way this will not equal the frame argument is if that 
;       argument was invalid. In that case, this keyword will be the same
;       as data.velocity_definition.
;
; :Returns:
;   velocity (m/s)
;
; :Uses:
;   :idl:pro:`DATA_VALID`
;   :idl:pro:`chantofreq`
;   :idl:pro:`freqtovel`
; 
;-
function chantovel, data, chans, frame=frame, veldef=veldef, $
            true_frame=true_frame, true_veldef=true_veldef
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

    veldefs=["RADIO","OPTICAL","TRUE"]
    if (n_elements(veldef) eq 0) then begin
        if (not hasVeldef) then begin
            if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
                message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
            endif
            hasVeldef = 1
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
            hasVeldef = 1
            veldef = v_def
        endif 
    endelse
    ; check veldef value
    if (where(veldefs eq veldef) eq -1) then begin
        if (not hasVeldef) then begin
            ; has not yet tried to find veldef from the data, do it now
            if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
                message, "Problems deciphering data.velocity_definition, velocities may be wrong", /info
            endif
            if (where(veldefs eq veldef) eq -1) then begin
                veldef = 'RADIO'
                message, 'unrecognized velocity definition, using RADIO',/info
            endif else begin
                message, 'unrecognized velocity definition, using value from data',/info
            endelse
            hasVeldef = 1
        endif else begin
            ; this IS from the data, fall back to RADIO
            veldef = 'RADIO'
            message, 'unrecognized velocity definition, using RADIO',/info
        endelse
    endif

    ; start by converting to frequency in desired frame
    result = chantofreq(data, chans, frame=frame)

    ; convert that to velocity
    result = freqtovel(result, data.line_rest_frequency, veldef=veldef)

    true_frame = frame
    true_veldef = veldef

    return, result
end
