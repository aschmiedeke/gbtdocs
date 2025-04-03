; docformat = 'rst' 

;+
; Convert a frequency in one rest frame to an equivalent frequency in
; a new rest frame.
;
; :Params:
;   dc : in, required, type=spectrum
;       The spectrum data container to use to get the necessary header 
;       information for the conversion between the two frames.
;
;   freq : in, required, type=double
;       The frequencies, in Hz, to convert.
;
;   toframe : in, required, type=string
;       The desired rest frame.  Known rest frames are listed in
;       :idl:pro:`frame_velocity`.
;
;   fromframe : in, required, type=string
;       The rest frame appropriate for freq.  Known rest frames are 
;       listed in :idl:pro:`frame_velocity`.
;
; :Returns:
;   the converted frequency
;
;-
function freqtofreq, dc, freq, toframe, fromframe
    compile_opt idl2

    if (fromframe eq toframe) then return, freq ; nothing to do

    vframe = frame_velocity(dc, toframe, fromframe,/bootstrap)
    return, freq * sqrt((!gc.light_speed + vframe)/(!gc.light_speed-vframe))
end
