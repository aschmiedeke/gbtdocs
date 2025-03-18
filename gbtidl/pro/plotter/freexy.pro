;+
; Free the x and y axes to autoscale.  All zoom information 
; is reset to its initial values.
;
; @version $Id$
;-
pro freexy
     common gbtplot_common,mystate,xarray

     if (not mystate.xfix and not mystate.yfix) then return ; already freed

     mystate.xfix = 0
     mystate.yfix = 0

     ; the zoom information is actually updated by reshow
     reshow
end
