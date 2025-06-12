; docformat = 'rst'

;+
; Convert channel number to frequency (Hz) using
; the supplied data container.  Optionally return the frequency in
; another reference frame from that given in the data.
;
; :Params:
;   data : in, required, type=spectrum
;       The spectrum data container to use to get the necessary header 
;       information.
;
;   chans : in, required
;       The channel numbers to convert, may be an array of values.
;
; :Keywords:
;   frame : in, optional, type=string
;       The rest frame to convert to. Known rest frames are listed in
;       :idl:pro:`frame_velocity`.  Defaults to the frame given in
;       the data.frequency_type.
;
;   true_frame : out, optional, type=string
;       The actual rest frame used in constructing the frequencies.  
;       The only way this will not equal the frame argument is if 
;       that argument was invalid. In that case, this keyword will
;       be the same as the frame in data.frequency_type.
;
; :Returns:
;   frequencies (Hz)
;
; :Uses:
;   :idl:pro:`DATA_VALID`
;   :idl:pro:`frame_velocity`
; 
;-
function chantofreq, data, chans, frame=frame, true_frame=true_frame
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

    ; start by constructing the frequency axis
    result = double(chans)
    result = result - data.reference_channel
    result = result * data.frequency_interval
    result = result + data.reference_frequency
    offset = 0.0

    ; result is now in frame given in data.frequency_type
    result = freqtofreq(data, result, frame, data.frequency_type)
    true_frame = frame

    return, result
end
