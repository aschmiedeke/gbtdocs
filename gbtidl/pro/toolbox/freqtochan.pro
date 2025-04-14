; docformat = 'rst' 

;+
; Convert frequency (Hz) to channel number using
; the supplied data container. The frequency may be expressed in 
; another reference frame from that given in the data.
;
; :Params:
;   data : in, required, type=spectrum
;       The spectrum data container to use to get the necessary header 
;       information.
;
;   freqs : in, required; 
;       The frequencies to convert (Hz), may be an array of values.
;
; :Keywords:
;   frame : in, optional, type=string
;       The rest frame that the frequencies are in. Known rest frames
;       are listed in :idl:pro:`frame_velocity`. Defaults to the frame 
;       given in the data container.
;
;   true_frame : out, optional, type=string
;       The actual rest frame used in converting the frequencies. The
;       only way this will not equal the frame argument is if that
;       argument was invalid. In that case, this keyword will be the 
;       same as the frame in data.frequency_type.
;
; :Returns:
;   channel number.
;
; :Uses:
;   :idl:pro:`data_valid`
;   :idl:pro:`frame_velocity`
; 
;-
function freqtochan, data, freqs, frame=frame, true_frame=true_frame
    compile_opt idl2

    ; argument check
    if (data_valid(data, name=name) le 0) then begin
        message, "invalid or undefined data structure"
        ; message will cause things to fail here.
    endif

    if (name ne 'SPECTRUM_STRUCT') then begin
        message, "data must be a spectrum structure"
        ; message will cause things to fail here.
    endif

    if (n_elements(frame) eq 0) then begin
        frame = data.frequency_type
    endif else begin
        if (size(frame,/type) ne 7) then begin
            message, "refframe has the wrong type, using value from data.frequency_type",/info
            frame = data.frequency_type
        endif else begin
            if (frame eq "OBS") then frame = "TOPO"
        endelse
    endelse

    result = double(freqs)

    result = freqtofreq(data, result, data.frequency_type, frame)

    result = temporary(result) - data.reference_frequency
    result = temporary(result) / data.frequency_interval
    result = temporary(result) + data.reference_channel

    true_frame = frame

    return, result;
end
