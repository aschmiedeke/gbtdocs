; docformat = 'rst'

;+
; Free the y-axis to autoscale.  If the x-axis is also autoscaling,
; then all zoom information is reset to its initial values.
;
;-
pro freey
     common gbtplot_common,mystate,xarray

     if (not mystate.yfix) then return ; already freed

     if (not mystate.xfix) then freexy ; to reset zooms

     mystate.yfix = 0

     reshow
end
