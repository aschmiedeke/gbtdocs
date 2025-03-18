;+
; Construct a velocity axis from a data structure.
;
; @param data {in}{required}{type=spectrum} The data structure to
; use in constructing a velocity axis.
;
; @keyword veldef {in}{optional}{type=string} The velocity definition to
; use, chosen from 'RADIO', 'OPTICAL', and 'TRUE'.  If not supplied,
; the data.velocity_definition value will be used.
;
; @keyword frame {in}{optional}{type=string}  The reference frame to
; use.  If not supplied, the data.velocity_definition value will be
; used.  See <a href="frame_velocity.html">frame_velocity</a> for a
; full list of supported reference frames.
;
; @keyword true_frame {out}{optional}{type=string} The actual rest frame used in
; constructing the velocity axis.  The only way this will not equal
; the frame argument is if that argument was invalid.  In that
; case, this keyword will be the same as the frame in data.velocity_definition.
;
; @keyword true_veldef {out}{optional}{type=string} The actual velocity frame used
; in constructing the velocity axis.  The only way this will not equal
; the frame argument is if that argument was invalid.  In that
; case, this keyword will be the same as data.velocity_definition.
;
; @returns A vector of velocities (m/s).  May also set the
; keywords. Returns -1 on a severe error.  If the veldef or ref_frame
; are invalid this will use the values found in the data structure
; and the values of the true_veldef and true_frame keywords will be
; set.
;
; @uses <a href="chantovel.html">chantovel</a>
;
; @version $Id$
;-
FUNCTION VELOCITY_AXIS, data, veldef=veldef, frame=frame, $
           true_frame=true_frame, true_veldef=true_veldef
    compile_opt idl2

    ; trap for errors, return -1 on error
    catch, error_status
    if (error_status ne 0) then begin
        print, !error_state.msg
        return, -1
    endif

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
    return, chantovel(data, dindgen(n_elements(*data.data_ptr)), $
                      veldef=veldef, frame=frame, $
                      true_frame=true_frame, true_veldef=true_veldef)

END
