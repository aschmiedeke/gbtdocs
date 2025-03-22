; docformat = 'rst' 

;+
; Change the x-axis on the plotter to channels.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       chan          ; x-axis is now channels
;       freq          ; now it's frequency
;       velo          ; now it's velocity
; 
;-
pro chan
   if (!g.plotter_axis_type ne 0) then begin
       !g.plotter_axis_type=0
       if not !g.frozen then reshow
   endif
   return
end
