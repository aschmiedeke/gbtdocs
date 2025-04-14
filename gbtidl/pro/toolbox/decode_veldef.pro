; docformat = 'rst' 

;+
; Parse the SDFITS VELDEF value into its two components, the velocity
; definition and velocity reference frame.  
;
; This value must contain 8 characters where the first 4 characters 
; describe the velocity definition and the last 4 characters describe 
; the reference frame. If the first 4 characters are recognized, they
; are expanded to be used in other toolbox functions 
; (e.g. :idl:pro:`velocity_axis`).  Recognized velocity definitions 
; and their expanded form are: RADI (RADIO), OPTI (OPTICAL), and RELA 
; (TRUE).  Any leading dash is removed from the last 4 characters 
; before that value is set.  In addition, OBS is translated to TOPO
; for topocentric.  The return value is 0 if there were problems
; (non-standard velocity definition, wrong number of characters, etc)
; and 1 if everything appears to be okay.
;
; :Params:
;   veldef : in, required, type=string
;       The value to decode.
;
;   velocity_definition : out, required, type=string
;       This will be one of the standard types, RADIO, OPTICAL, or TRUE,
;       or a copy of the first 4 characters (if the latter, the return 
;       value will be 0).
;
;   reference_frame : out, required, type=string
;       This will be the last 4 characters minus any leading dash.
;
; :Returns:
;   1 on success and 0 on failure.
;
;-
function DECODE_VELDEF, veldef, velocity_definition, reference_frame
    compile_opt idl2

    if (strlen(veldef) ne 8) then begin
        velocity_definition = 'RADIO'
        reference_frame = 'TOPO'
        return, -1
    endif

    result = 1
    velocity_definition = strmid(veldef, 0, 4)
    reference_frame = strmid(veldef, 4, 4)
    if (strmid(reference_frame, 0, 1) eq "-") then begin
        reference_frame = strmid(reference_frame, 1, 3)
    endif

    ; VELO was written by sdfits for some unknown amount of time
    ; it now writes RELA but this is to deal correctly with existing
    ; ouput of sdfits.
    case velocity_definition of
        "RADI": velocity_definition = "RADIO"
        "OPTI": velocity_definition = "OPTICAL"
        "RELA": velocity_definition = "TRUE"
        "VELO": velocity_definition = "TRUE"
        ELSE: begin
            ; fall back to radio definition
            velocity_definition = "RADIO"
            result = -1
        end
    endcase ;

    if (reference_frame eq "OBS") then reference_frame = "TOPO"

    return, result
END
