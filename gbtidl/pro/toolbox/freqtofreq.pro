;+
; Convert a frequency in one rest frame to an equivalent frequency in
; a new rest frame.
;
; @param dc {in}{required}{type=spectrum} The spectrum data
; container to use to get the necessary header information for the
; conversion between the two frames.
;
; @param freq {in}{required}{type=double} The frequencies, in Hz, to
; convert.
;
; @param toframe {in}{required}{type=string} The desired rest 
; frame.  Known rest frames are listed in
; <a href="frame_velocity.html">frame_velocity.html</a>.
;
; @param fromframe {in}{required}{type=string} The rest frame
; appropriate for freq.  Known rest frames are listed in
; <a href="frame_velocity.html">frame_velocity.html</a>.
;
; @returns the converted frequency
;
; @version $Id$
;-
function freqtofreq, dc, freq, toframe, fromframe
    compile_opt idl2

    if (fromframe eq toframe) then return, freq ; nothing to do

    vframe = frame_velocity(dc, toframe, fromframe,/bootstrap)
    return, freq * sqrt((!gc.light_speed + vframe)/(!gc.light_speed-vframe))
end
