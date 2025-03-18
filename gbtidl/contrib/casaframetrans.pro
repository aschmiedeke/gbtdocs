;+
; Simple function to translate GBTIDL reference frame strings to 
; those recognized by the CASA library.  Used by casaframevel.
;
; <p><B>Contributed By: Bob Garwood, NRAO-CV</B>
;
; @param gframe {in}{required}{type=string} The GBTIDL reference
; frame string (one of TOPO, GEO, HEL, BAR, LSR, LSD, or GAL).
; 
; @returns the corresponding CASA string.  A warning is printed if 
; gframe is 'HEL' since heliocentric is not supported by CASA.
; BARY (barycentric) is used instead.  Also, a warning is printed
; if gframe is unrecognized.  In that case, the return value is TOPO.
;
; @version $Id$
;-
function casaframetrans, gframe
    compile_opt idl2

    if n_elements(gframe) eq 0 then begin
        usage,'casaframetrans'
        return, 'TOPO'
    endif

    result = 'TOPO'
    tmpgframe = strupcase(gframe)

    case tmpgframe of
        'TOPO': result = 'TOPO'
        'GEO': result = 'GEO'
        'HEL': begin
            result = 'BARY'
            message,'HEL is unsupported in CASA, using BARY instead',/info
        end
        'BAR': result = 'BARY'
        'LSR': result = 'LSRK'
        'LSD': result = 'LSRD'
        'GAL': result = 'GALACTO'
        else: begin
            result = 'TOPO'
            message,'Unrecognized gframe value, using TOPO',/info
        end
    endcase

    return, result
end
