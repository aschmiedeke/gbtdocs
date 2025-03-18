;+
; Shift a velocity using a velocity offset.  Note that because of the
; nature of the non-true velocity definitions, this is not a simply
; reversable shift for anything by a TRUE velocity.  Namely,
; v=shiftvel(shiftvel(v,voffset),-voffset) will not result in the same
; value of v as you started out with for anything except
; veldef='TRUE'.  If you want to undo a velocity shift using the same
; voffset, use unshiftvel.
;
; @param vel {in}{required}{type=double} The velocities, in m/s, to
; shift.
;
; @param voffset {in}{required}{type=double} The velocity offset (m/s) to
; add to the velocities (resulting velocities are then appropriate
; for a frame moving at voffset relative to the original frame of
; vel).
;
; @keyword veldef {in}{optional}{type=string}{default='RADIO'} The
; velocity definition from one of RADIO, OPTICAL or TRUE.
;
; @returns the shifted velocities in m/s.
;
; @version $Id$
;-
function shiftvel, vel, voffset, veldef=veldef
    compile_opt idl2

    if (n_elements(vel) eq 0 or n_elements(voffset) eq 0) then begin
        print, 'Usage: newvel = shiftvel(vel, voffset, [veldef=veldef])'
        return, vel
    end
    
    if (not keyword_set(veldef)) then veldef = 'RADIO'

    if (total(voffset) eq 0.0D) then return, vel

    result = vel
    case veldef of
        'RADIO': result = vel + voffset - vel*voffset/!gc.light_speed
        'OPTICAL': result = vel + voffset + vel*voffset/!gc.light_speed
        'TRUE': result = (vel+voffset) / (1.0D + vel*voffset/!gc.light_speed^2)
        else: begin
            print, 'Unrecognized VELDEF, result is vel without any offset applied.'
            print, '  VELDEF must be one of "RADIO", "OPTICAL", "TRUE"'
        end
    endcase
    return, result
end
            
