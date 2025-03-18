;+
; Undo the effects of shiftfreq using the same voffset (do not use its
; negative here).  See the comments in shiftfreq.  This is intended to
; only be used on a quantity that is the result from shiftfreq.
;
; @param freq {in}{required}{type=double} The frequencies, in Hz, to
; unshift.
;
; @param voffset {in}{required}{type=double} The velocity offset (m/s) to
; remove.  This should be the same value used in a previous call to shiftfreq.
;
; @keyword veldef {in}{optional}{type=string}{default='RADIO'} The
; velocity definition from one of RADIO, OPTICAL or TRUE.
;
; @returns the unshifted frequencies in Hz.
;
; @version $Id$
;-
function unshiftfreq, freq, voffset, veldef=veldef
    compile_opt idl2

    if (n_elements(freq) eq 0 or n_elements(voffset) eq 0) then begin
        print, 'Usage: newfreq = unshiftfreq(freq, voffset, [veldef=veldef])'
        return, freq
    end

    if (voffset eq 0.0D) then return, freq

    if (not keyword_set(veldef)) then veldef='RADIO'

    result = freq
    case veldef of
        'RADIO': result = freq / (1.0D - voffset/!gc.light_speed)
        'OPTICAL': result = freq * (1.0D + voffset/!gc.light_speed)
        'TRUE': result = shiftfreq(freq,-voffset,veldef=veldef) ; TRUE is the same
        else: begin
            print, 'Unrecognized VELDEF, result is freq without any offset applied.'
            print, '  VELDEF must be one of "RADIO", "OPTICAL", "TRUE"'
        end
    endcase
    return, result
end
