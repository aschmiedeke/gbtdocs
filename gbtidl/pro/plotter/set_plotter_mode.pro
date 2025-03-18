;+
; Internal plotter function to set the mode (line or continuum)
; depending on the current contents of mystate.data_ptr.
;
; @hidden_file
;
; @version $Id$
;-
pro set_plotter_mode
    compile_opt idl2
    common gbtplot_common,mystate, xarray

    mystate.line = tag_names(*mystate.dc_ptr,/structure) eq 'SPECTRUM_STRUCT'

    if (mystate.line) then begin
        widget_control,mystate.frame_id,sensitive=1
        widget_control,mystate.veldef_id,sensitive=1
        widget_control,mystate.xunits_id,sensitive=1
        for i=0,(n_elements(mystate.setv_ids)-1) do widget_control,mystate.setv_ids[i],sensitive=1
    endif else begin
        widget_control,mystate.frame_id,sensitive=0
        widget_control,mystate.veldef_id,sensitive=0
        widget_control,mystate.xunits_id,sensitive=0
        for i=0,(n_elements(mystate.setv_ids)-1) do widget_control,mystate.setv_ids[i],sensitive=0
    endelse
end
