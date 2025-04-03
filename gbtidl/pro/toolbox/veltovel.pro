; docformat = 'rst' 

;+
; Convert a velocity in one velocity definition to an equivalent
; velocity in another definition.
;
; :Params:
;   vel : in, required, type=double
;       The velocity, in m/s, to convert.
;
;   toveldef : in, required, type=string
;       The desired velocity definition. Must be one of 'TRUE',
;       'OPTICAL' and 'RADIO'.
;
;   fromveldef : in, required, type=string
;       The input velocity definition. Must be one of 'TRUE',
;       'OPTICAL' and 'RADIO'
;
; :Returns:
;   the converted velocity in m/s.
;
;-
function veltovel, vel, toveldef, fromveldef
    compile_opt idl2

    if (fromveldef eq toveldef) then return, vel ; nothing to do

    result = vel/!gc.light_speed
    ; convert to true
    case fromveldef of
        'RADIO': begin
            result = (2.D * result - result*result) / (2.D - 2.D * result + result*result)
        end

        'OPTICAL': begin
            result = (2.d * result + result*result) / (2.D + 2.D * result + result*result)
        end
        else: ; nothing to do
    endcase

    ; convert from true

    case toveldef of
        'RADIO': begin
            result = 1.D - sqrt((1.D - result)/(1.D + result))
        end

        'OPTICAL': begin
            result = sqrt((1.D + result)/(1.D - result)) - 1.D
        end

        else: ; nothing to do
    endcase
    return, result * !gc.light_speed
end
