;+
; This procedure sets the reference frame to be used in
; constructing the x-axis prior to displaying the data.
;
; @param frame {in}{required}{type=string} The reference frame to
; use.  Recognized velocity definitions are the same ones found in the
; frames menu in the plotter.
;
; @version $Id$
;-

pro setframe, frame
    common gbtplot_common,mystate,xarray
    if (n_elements(frame) eq 0) then begin
        message,'Usage: setframe, frame',/info
        return
    endif
    if (data_valid(*mystate.dc_ptr) le 0) then begin
        ; nothing has been plotted, just set it and return
        mystate.frame = frame
    endif else begin
        if (mystate.frame ne frame) then begin
            if (mystate.xunit ne 'Channels') then begin
                convertxstate, mystate.xunit, frame, mystate.veldef, mystate.absrel, mystate.voffset
                reshow
            endif else begin
                ; its irrelevant for channels
                mystate.frame = frame
            endelse
        endif
    endelse
    if widget_info(mystate.frame_id,/valid) then $
      widget_control,mystate.frame_id,set_value=frame
end
