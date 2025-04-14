; docformat = 'rst' 

;+
; Convert frequency to velocity (m/s) using the given rest
; frequency and velocity definition.  The units (Hz, MHz, GHz, etc)
; of the frequencies to convert must match that of the rest frequency 
; argument.
;
; :Params:
;   freq : in, required
;       Frequency. Units must be the same as the units of restfreq.
; 
;   restfreq : in, required
;       Rest frequency. Units must be the same as those of freq.
; 
; :Keywords:
;   veldef : in, optional, type=string
;       The velocity definition which must be one of OPTICAL, RADIO,
;       or TRUE.  Defaults to RADIO.
;
; :Returns:
;   velocity in m/s
;
;-
function freqtovel, freq, restfreq, veldef=veldef
    compile_opt idl2

    if (not keyword_set(veldef)) then veldef = "RADIO"

    case veldef of
        'RADIO': result = !gc.light_speed * (1.0d - double(freq) / restfreq)
        'OPTICAL': result = !gc.light_speed * (restfreq / double(freq) - 1.0d)
        'TRUE': begin
            g = (double(freq) / restfreq)^2
            result = !gc.light_speed * (1.0d - g) / (1.0d + g)
        end
        else: message, 'unrecognized velocity definition'
    endcase 

    return, result
end
