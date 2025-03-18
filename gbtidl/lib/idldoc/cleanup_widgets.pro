;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Cleanup handler for an object-widget program.  Calls the "cleanup_widgets"
; method of the object-widget program.  The object reference for the program
; must be stored in the TLB's UVALUE.
;
; @param top {in}{required}{type=widget ID} widget identifier of the top-level
;        base
;-
pro cleanup_widgets, top
    compile_opt idl2

    widget_control, top, get_uvalue=self
    self->cleanup_widgets, top
end
