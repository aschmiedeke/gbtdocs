;+
; The event handler for the gbtidl print dialog used by the plotter.
;
; @param event {in}{required}{type=widget event structure} The event
; to be handled.
;
; @private_file
;
; @version $Id$
;-
pro gbtprint_dialog_event, event
    common gbtplot_common,mystate, xarray
    widget_control, event.id, get_uvalue=uvalue
    case uvalue of
        "GHOST": begin
            ; disable printerText
            if (event.select) then begin
                widget_control,mystate.printDialogPrinter,sensitive=0
                widget_control,mystate.printDialogFile,/sensitive
                mystate.print = 0
            endif
        end
        "PRINTER": begin
            ; enable printerText
            if (event.select) then begin
                widget_control,mystate.printDialogPrinter,/sensitive
                widget_control,mystate.printDialogFile,sensitive=0
                mystate.print = 1
            endif
        end
        "PRINT": begin
            if mystate.print then begin
               ; spool to printer here
                widget_control, mystate.printDialogPrinter, get_value=value
                !g.printer = value
                if (mystate.landscape) then begin
                    print_ps,device=!g.printer
                endif else begin
                    print_ps,device=!g.printer,/portrait
                endelse
            endif else begin
                ; spool to ghostview here
                widget_control, mystate.printDialogFile, get_value=value
                if (mystate.landscape) then begin
                    write_ps,value
                endif else begin
                    write_ps,value,/portrait
                endelse
                cmd = 'ghostview ' + value + ' &'
                spawn,cmd
            endelse
            ; need current values of the widget
            widget_control,mystate.printDialogMain,/destroy
        end
        "CANCEL": begin
            widget_control,mystate.printDialogMain,/destroy
        end
        ; PORTRAIT and LAND events always come together
        ; only watch for LAND
        "LAND": mystate.landscape = event.select eq 1
        "COLOR": !g.colorpostscript = event.select eq 1
        else: ; nothing to be done here
    endcase
end


;+
; This procedure initializes the gbtidl print dialog widget
;
; @version $Id$
;-
pro init_gbtprint_dialog
    common gbtplot_common,mystate, xarray

    mystate.printDialogMain = widget_base(/col,uvalue='MAIN',title='Print')
    filerow = widget_base(mystate.printDialogMain,/row)
    printerrow = widget_base(mystate.printDialogMain,/row)
    orientrow = widget_base(mystate.printDialogMain,/row)
    colorrow = widget_base(mystate.printDialogMain,/row)
    actionrow = widget_base(mystate.printDialogMain,/row)

    fileLabel = widget_label(filerow,value="File :")
    mystate.printDialogFile = $
       widget_text(filerow,value="gbtidl.ps",/editable,uvalue="FILE")

    printerLabel = widget_label(printerrow,value="Printer: ")
    printerBase = widget_base(printerrow,/row,/exclusive)
    ghostButton = widget_button(printerBase,value="Ghostview",uvalue="GHOST")
    printerButton = widget_button(printerBase,value="Printer",uvalue="PRINTER")

    mystate.printDialogPrinter = $
       widget_text(printerrow,value=!g.printer,/editable,uvalue="PRINTERNAME")
    
    orientLabel = widget_label(orientrow,value="Orientation: ")
    orientBase = widget_base(orientrow,/row,/exclusive)
    portraitButton = widget_button(orientBase,value="Portrait",$
                                   uvalue="PORTRAIT")
    landButton = widget_button(orientBase,value="Landscape",uvalue="LAND")

    colorBase = widget_base(colorrow,/row,/nonexclusive)
    colorButton = widget_button(colorBase,value="Color",uvalue="COLOR")
    
    printButton = widget_button(actionrow,value="Print",uvalue="PRINT")
    cancelButton = widget_button(actionrow,value="Cancel",uvalue="CANCEL")

    widget_control,mystate.printDialogFile,sensitive=0
    widget_control,mystate.printDialogPrinter,/input_focus

    ; ensure that their current state reflects the truth
    if mystate.print then begin 
        widget_control, printerButton, /set_button
        widget_control, mystate.printDialogFile,sensitive=0
        widget_control,mystate.printDialogPrinter,/sensitive
        widget_control, mystate.printDialogPrinter,/input_focus
    endif else begin
        widget_control, ghostButton, /set_button
        widget_control, mystate.printDialogFile,/sensitive
        widget_control,mystate.printDialogPrinter,sensitive=0
    endelse
    if mystate.landscape then begin
        widget_control, landButton, /set_button
    endif else begin
        widget_control, portraitButton, /set_button
    endelse
    if !g.colorpostscript then begin
        widget_control, colorButton, /set_button
    endif else begin
        widget_control, colorButton, set_button=0
    endelse

    widget_control,mystate.printDialogMain,/realize
    xmanager,'gbtprint_dialog',mystate.printDialogMain

end
