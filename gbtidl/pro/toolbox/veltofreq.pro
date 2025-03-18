;+
; Convert velocity(m/s) to frequency using the given rest
; frequency and velocity definition.  The units of the returned result
; (Hz, MHz, GHz, etc) are the same as that of the rest frequency
; argument.  The velocity must be in m/s.
;
; @param vel {in}{required} Velocity in m/s
; @param restfreq {in}{required} Rest frequency.  The units of restfreq
; the units of the returned result.
; @keyword veldef {in}{optional}{type=string} The velocity definition
; which must be one of OPTICAL, RADIO, or TRUE.  Defaults to RADIO.
;
; @returns frequency in same units as restfreq argument.
;
; @version $Id$
;-
function veltofreq, vel, restfreq, veldef=veldef
    compile_opt idl2

    if (not keyword_set(veldef)) then veldef = "RADIO"

    result = double(vel) / !gc.light_speed
    case veldef of
        'RADIO': result = (1.0d - result) * restfreq
        'OPTICAL': result = restfreq / (result + 1.0d)
        'TRUE': result = restfreq * sqrt((1.d - result)/(1.d + result))
        else: message, 'unrecognized velocity definition'
    endcase

    return, result
end
