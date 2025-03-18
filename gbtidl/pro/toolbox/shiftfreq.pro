;+
; Shift a frequency using a velocity offset.  Note that because of the
; nature of the non-true velocity definitions, this is not a simply
; reversable shift for anything by a TRUE velocity.  Namely,
; f=shiftfreq(shiftfreq(f,voffset),-voffset) will not result in the same
; value of f as you started out with for anything except
; veldef='TRUE'.  If you want to undo a frequency shift using the same
; voffset, use unshiftfreq.
;
; @param freq {in}{required}{type=double} The frequencies, in Hz, to
; shift.
;
; @param voffset {in}{required}{type=double} The velocity offset (m/s) to
; add to the frequencies (resulting frequencies are then appropriate
; for a frame moving at voffset relative to the original frame of
; freq).
;
; @keyword veldef {in}{optional}{type=string}{default='RADIO'} The
; velocity definition from one of RADIO, OPTICAL or TRUE.
;
; @returns the shifted frequencies in Hz.
;
; @version $Id$
;-
function shiftfreq, freq, voffset, veldef=veldef
    compile_opt idl2

    if (n_elements(freq) eq 0 or n_elements(voffset) eq 0) then begin
        print, 'Usage: newfreq = shiftfreq(freq, voffset, [veldef=veldef])'
        return, freq
    end

    if (voffset eq 0.0D) then return, freq

    if (not keyword_set(veldef)) then veldef='RADIO'

    scale = 1.0d
    case veldef of
        'RADIO': scale = (1.0D - voffset/!gc.light_speed)
        'OPTICAL': scale = 1.0D/(1.0D + voffset/!gc.light_speed)
        'TRUE': scale = sqrt((!gc.light_speed+voffset)/(!gc.light_speed-voffset))
        else: begin
            print, 'Unrecognized VELDEF, result is freq without any offset applied.'
            print, '  VELDEF must be one of "RADIO", "OPTICAL", "TRUE"'
            return, freq
        end
    endcase
    return, freq*scale
end
