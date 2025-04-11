; docformat = 'rst'

;+
; Procedure to set the velocity offset in the plotter, in the current frame.
;
; :Params:
;   voffset : in, optional, type=double
;       The new velocity offset in km/s. If not supplied it uses the source
;       velocity of the spectrum in the plotter. In that case, the veldef also 
;       comes from the spectrum in the plotter and the veldef keyword here is
;       not used. If there is no spectrum in the plotter, it does nothing.
;   veldef : in, optional, type=string
;       The velocity definition to use. If not set, the current definition in 
;       use in the plotter will be used.
;
;-
pro setvoffset, voffset, veldef=veldef
    compile_opt idl2
    common gbtplot_common, mystate, xarray

    if (n_elements(voffset) eq 0) then begin
        ; anything in the plotter?
        if data_valid(*mystate.dc_ptr) le 0 then return

        newvoffset = (*mystate.dc_ptr).source_velocity
        ok=decode_veldef((*mystate.dc_ptr).velocity_definition,newveldef,frame)
    endif else begin
        if (n_elements(veldef) eq 0) then veldef=mystate.veldef
        newveldef = strupcase(veldef)

        if (newveldef ne 'RADIO' and newveldef ne 'OPTICAL' and newveldef ne 'TRUE') then begin
            message,'veldef must be one or RADIO, OPTICAL, or TRUE',/info
            return
        endif

        newvoffset = voffset * 1.0d3
    endelse

    ; actual offset is always stored as TRUE
    newTrueVoffset = veltovel(newvoffset, 'TRUE', newveldef)

    mystate.voff_veldef=strmid(newveldef,0,1)+strlowcase(strmid(newveldef,1))
    if (not mystate.voff_pending and mystate.voffsetDialogMain ge 0) then begin
        ; update the GUI
        widget_control, mystate.voff_field, set_value=newvoffset/1.d3
        widget_control, mystate.voff_veldef_id,set_value=mystate.voff_veldef
    endif else begin
        mystate.voff_pending = 0
    endelse

    if (newTrueVoffset ne mystate.voffset) then begin
        convertxstate, mystate.xunit, mystate.frame, mystate.veldef, mystate.absrel, newTrueVoffset
        reshow
    endif
end
