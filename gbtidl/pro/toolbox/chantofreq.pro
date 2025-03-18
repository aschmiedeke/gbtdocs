;+
; Convert channel number to frequency (Hz) using
; the supplied data container.  Optionally return the frequency in
; another reference frame from that given in the data.
;
; @param data {in}{required}{type=spectrum} The spectrum data
; container to use to get the necessary header information.
;
; @param chans {in}{required} The channel numbers to convert, may be
; an array of values.
;
; @keyword frame {in}{optional}{type=string} The rest frame to convert
; to.  Known rest frames are listed in
; <a href="frame_velocity.html">frame_velocity.html</a>.  Defaults to the frame given in
; the data.frequency_type.
;
; @keyword true_frame {out}{optional}{type=string} The actual rest frame used in
; constructing the frequencies.  The only way this will not equal
; the frame argument is if that argument was invalid.  In that
; case, this keyword will be the same as the frame in
; data.frequency_type.
;
; @returns frequencies (Hz)
;
; @uses <a href="data_valid.html">data_valid</a>
; @uses <a href="frame_velocity.html">frame_velocity</a>
; 
; @version $Id$
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
