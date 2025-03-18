;+
; Adjust the frame_velocity value in the primary data container (PDC,
; buffer 0)  using the external CASA library.
;
; <p>
; Other buffers can be adjusted using the buffer keyword.
;
; <p>Note that the first time this function is 
; called there will be a small delay while the shared library is
; loaded.  Subsequent calls will be substantially faster.
;
; <p><B>Contributed By: Bob Garwood, NRAO-CV</B>
;
; @keyword buffer {in}{out}{required}{type=data container}{default=0} 
; The data buffer to use.  This defaults to the primary data container
; (buffer 0).  The value of the frame_velocity in this buffer is 
; changed by calling this procedure.
; @keyword newframe {in}{optional}{type=string} The new reference
; frame to use.  If not supplied, the frame implied by
; the velocity_definition in this buffer will be used.  This string 
; must be one of TOPO, GEO, HEL, BAR, LSR, LSD, and GAL.  If this 
; is set, then the velocity_definition will be changed to match 
; this keyword.
;
; @uses dcfixframe, data_copy, set_data_container
;
; @examples
; <pre>
; ; adjust the frame velcity in the PDC
; fixvframe
; ; adjust it to the GAL (galactic) frame
; dcfixvframe,newframe='GAL'
; ; adjust it in the data in buffer 2
; fixvframe,buffer=2
; </pre>
;
; @version $Id$
;-
pro fixvframe, buffer=buffer, newframe=newframe
    compile_opt idl2

    if not !g.line then begin
        message,'This only works on continuum data',/info
        return
    endif

    thisbuffer = 0
    if n_elements(buffer) gt 0 then thisbuffer = buffer[0]
    if thisbuffer lt 0 or thisbuffer ge n_elements(!g.s) then begin
        message, string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
        return
    endif

    data_copy,!g.s[thisbuffer], dc
    dcfixvframe, dc, newframe=newframe
    set_data_container, dc, buffer=thisbuffer
    data_free, dc
end
