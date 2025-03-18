;+
; Undo the effects of shiftvel using the same voffset (do not use its
; negative here).  See the comments in shiftvel.  This is intended to
; only be used on a quantity that is the result from shiftvel.
;
; @param vel {in}{required}{type=double} The velocities, in m/s, to
; unshift.
;
; @param voffset {in}{required}{type=double} The velocity offset (m/s) to
; remove.  This should be the same value used in a previous call to shiftvel.
;
; @keyword veldef {in}{optional}{type=string}{default='RADIO'} The
; velocity definition from one of RADIO, OPTICAL or TRUE.
;
; @returns the unshifted velocities in m/s.
;
; @version $Id$
;-
function unshiftvel, vel, voffset, veldef=veldef
    compile_opt idl2

    if (n_elements(vel) eq 0 or n_elements(voffset) eq 0) then begin
        print, 'Usage: newvel = unshiftvel(vel, voffset, [veldef=veldef])'
        return, vel
    end
    
    if (not keyword_set(veldef)) then veldef = 'RADIO'

    if (voffset eq 0.0D) then return, vel

    result = vel
    case veldef of
        'RADIO': result = (vel - voffset)/(1.d - voffset/!gc.light_speed)
        'OPTICAL': result = (vel - voffset)/(1.d + voffset/!gc.light_speed)
        'TRUE': result = shiftvel(vel,-voffset,veldef=veldef) ; TRUE is the same
        else: begin
            print, 'Unrecognized VELDEF, result is vel without any offset applied.'
            print, '  VELDEF must be one of "RADIO", "OPTICAL", "TRUE"'
        end
    endcase
    return, result
end
            
