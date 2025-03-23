; docformat = 'rst'

;+
; Change the x-axis on the plotter to velocity.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       velo          ; x-axis is now velocity
;       chan          ; now it's channels
;       freq          ; now it's frequency
; 
;-
pro velo
   if (!g.plotter_axis_type ne 2) then begin
       !g.plotter_axis_type=2
       if not !g.frozen and !g.line then reshow
   endif
   return
end
