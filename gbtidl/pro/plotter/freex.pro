; docformat = 'rst'

;+
; Free the x-axis to autoscale.  If the y-axis is also autoscaling,
; then all zoom information is reset to its initial values.
;
;-
pro freex
     common gbtplot_common,mystate,xarray

     if (not mystate.xfix) then return ; already freed

     if (not mystate.yfix) then freexy ; to reset zooms

     mystate.xfix = 0

     reshow
end
