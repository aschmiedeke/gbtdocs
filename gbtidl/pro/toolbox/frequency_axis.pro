;+
; Construct a frequency axis from a data structure.
;
; @param data {in}{required}{type=spectrum} The data structure to
; use in constructing a frequency axis.
;
; @keyword frame {in}{optional}{type=string}  The reference frame to
; use.  If not supplied, the data.frequency_type value will be
; used.  See <a href="frame_velocity.html">frame_velocity</a> for a
; full list of supported reference frames.
;
; @keyword true_frame {out}{optional}{type=string} The actual rest frame used in
; constructing the frequency axis.  The only way this will not equal
; the frame argument is if that argument was invalid.  In that
; case, this keyword will be the same as the frame in
; data.frequency_type.
;
; @returns A vector of frequencies (Hz).  May also set the
; keywords. Returns -1 on a severe error.  If the ref_frame
; is invalid this will use the values found in the data structure
; and the values of the true_frame keyword will be
; set.
;
; @uses <a href="chantofreq.html">chantovel</a>
;
; @version $Id$
;-
FUNCTION FREQUENCY_AXIS, data, frame=frame, true_frame=true_frame
    compile_opt idl2

    ; trap for errors, return -1 on error
    catch, error_status
    if (error_status ne 0) then return, -1

    ; argument check on data
    if (data_valid(data, name=name) le 0) then begin
        message, "invalid or undefined data structure", /info
        return, -1
    endif


    if (name ne 'SPECTRUM_STRUCT') then begin
        message, "data must be a spectrum structure", /info
        return, -1
    endif

    ; additional argument checking happens in chantovel
    return, chantofreq(data, dindgen(n_elements(*data.data_ptr)), $
                      frame=frame, true_frame=true_frame)

END
