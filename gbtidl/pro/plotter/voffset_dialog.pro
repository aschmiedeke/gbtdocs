;+
; The event handler for the velocity offset dialog used by the plotter.
;
; @param event {in}{required}{type=widget event structure} The event
; to be handled.
;
; @private_file
;
; @version $Id$
;-
pro voffset_dialog_event, event
    common gbtplot_common,mystate, xarray
    widget_control, event.id, get_uvalue=uvalue
    case uvalue of
        'VOFFVELDEF': widget_control,mystate.voff_veldef_id,set_value=event.value
        'VOFFSET': begin
            widget_control,mystate.voff_veldef_id,get_value=veldef
            voffset = event.value
            mystate.voff_pending = 1
            setvoffset,voffset,veldef=veldef
        end
        "Close": begin
            voffset_close, mystate.voffsetDialogMain
        end
        else: ; nothing to be done here
    endcase
end

;+
; The function that is called when "Close" is pressed.
; 
; @param widget_id {in}{required}{type=integer} The top-level ID to
; destroy.
;-
pro voffset_close, widget_id
    common gbtplot_common,mystate, xarray
    widget_control,widget_id,/destroy
    mystate.voffsetDialogMain = -1
end


;+
; This procedure initializes the velocity offset dialog widget
;
; @version $Id$
;-
pro init_voffset_dialog
    common gbtplot_common,mystate, xarray

    if (mystate.voffsetDialogMain ge 0) then begin
        ; widget is already active, just expose it
        widget_control, mystate.voffsetDialogMain, /show
    endif else begin
        mystate.voffsetDialogMain = widget_base(/col,uvalue='MAIN',title='Set Velocity Offset',KILL_NOTIFY='voffset_close')
        voffsetbase = widget_base(mystate.voffsetDialogMain,/row)
        actionrow = widget_base(mystate.voffsetDialogMain,/row)
        
        mystate.voff_field = cw_field(voffsetbase,/return_events,/floating,title='Voffset :', value=0.0, uvalue='VOFFSET')
        voffsetUnitLabel = widget_label(voffsetbase,value='km/s')
        desc = ['1\Veldef','0\Radio','0\Optical','0\True']
        voffsetVeldef = cw_pdmenu(voffsetbase,desc,uvalue='VOFFVELDEF',/return_name, ids=vids)
        mystate.voff_veldef_id = vids[0]
        widget_control,mystate.voff_veldef_id,set_value=mystate.voff_veldef
        ; get current voffset and set GUI accordingly
        voff = mystate.voffset
        ; that is in in TRUE m/s
        if (voff ne 0.0) then begin
            voff = veltovel(voff,strupcase(mystate.voff_veldef),'TRUE')
            widget_control, mystate.voff_field,set_value=voff/1.0d3
        endif

        cancelButton = widget_button(actionrow,value="Close",uvalue="Close")   

        widget_control,mystate.voffsetDialogMain,/realize
        xmanager,'voffset_dialog',mystate.voffsetDialogMain,/no_block
    endelse
end
