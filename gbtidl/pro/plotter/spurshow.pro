; docformat = 'rst'

;+
; Using the current displayed data container, mark any VEGAS ADC spurs
; associated with it using vertical lines (vline).
;
; If the vegas spur header parameters are invalid or there are no
; spurs found within the number of channels present in the data then
; no vertical lines will be drawn.
;
; All of these vertical lines will have the idstring 'vegas_spur'.
; They can all be cleared by using clearvlines for that idstring.
;
; *Note*: Vertical lines are persistent in the GBTIDL plotter. They
; remain as different data containers are displayed. clearvlines or
; clear must be used to erase these lines.
;
; This routine always clears all 'vegas_spur' vertical lines before
; it tries to redraw any at the spur locations.
;
; :Keywords:
;   showcenteradc : in, optional, type=boolean
;       When set, the marked spurs will include the center ADC spur.  
;       Normally this is unset and the center ADC spur is not marked. 
;       The usual sdfits behavior is to replace the data value at the 
;       center ADC spur with the average of the two adjacent channels.
;
;-
pro spurshow, showcenteradc=showcenteradc
  compile_opt idl2
  common gbtplot_common,mystate,xarray

  clearvlines,idstring='vegas_spur',/noshow

  nchan = data_valid(*mystate.dc_ptr)
  if nchan le 0 then return

  vsprval = (*mystate.dc_ptr).vsprval
  vsprpix = (*mystate.dc_ptr).vsprpix
  vspdelt = (*mystate.dc_ptr).vspdelt

  if not (finite(vsprval) and finite(vsprpix) and finite(vspdelt)) then begin
     ; necessary in case clearvlines has something pending
     reshow
     return
  endif

  spurChans = dcspurchans(vsprval, vsprpix, vspdelt, nchan, count=count, docenterspur=showcenteradc)

  if count le 0 then begin
     ; necessary in case clearvlines has something pending
     reshow
     return
  endif

  ; there IS something to plot.  Convert to the current xaxis
  xSpurChans = chantox(spurChans)

  ; and plot them
  for i=0,(count-1) do begin
     vline,xSpurChans[i],/noshow,idstring='vegas_spur'
  endfor

  ; and refresh the display
  reshow

end
