;+
; Initialize some things related to the graphics display.  This should be 
; done at startup.  It is done here in this function to watch for errors.  
; An error here most likely means that there is no graphical display available.
;
; @returns 1 on success else 0.
;
; @private_file
;
; @version $Id$
;-
function init_display
    
    catch, error_status
    if error_status ne 0 then return, 0

    device, true_color=24, decomposed=0
    ; make IDL refresh hidden windows
    device, RETAIN=2
    ; setcolors, /test    <- if executed this shows the names of the colors
    setcolors, /system_variables  ; makes the color names !colorname sys vars

    return, 1
end 
