; docformat = 'rst'

;+
; This procedure sets the velocity definition to be used in
; constructing the x-axis prior to displaying the data.
;
; :Params:
;   veldef : in, required, type=string
;       The velocity definition to use. Recognized velocity
;       definitions are 'Radio', 'Optical', and 'True'.
;
;-
pro setveldef, veldef
    common gbtplot_common,mystate,xarray

    if n_params() ne 1 then begin
	message,'Usage: setveldef, veldef',/info
        return
    endif
    upveldef = strupcase(veldef)
    if upveldef ne 'RADIO' and upveldef ne 'OPTICAL' and upveldef ne 'TRUE' then begin
        message,'Unrecognized veldef, must be one of RADIO, OPTICAL, or TRUE',/info
        return
    endif
    if (data_valid(*mystate.dc_ptr) le 0) then begin
        ; nothing has been plotted, just set it and return
        mystate.veldef = upveldef
    endif else begin
        if (mystate.veldef ne upveldef) then begin
            if (mystate.xtype eq 2 or mystate.voffset ne 0.0d) then begin
                convertxstate, mystate.xunit, mystate.frame, upveldef, mystate.absrel, mystate.voffset
                reshow
            endif else begin
                ; its irrelevant for non-velocity axes
                mystate.veldef = upveldef
            endelse
        endif
    endelse
    if widget_info(mystate.veldef_id,/valid) then $
         widget_control,mystate.veldef_id,set_value=veldef
end
