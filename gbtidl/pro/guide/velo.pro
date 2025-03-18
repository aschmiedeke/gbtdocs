;+
; Change the x-axis on the plotter to velocity.
;
; @examples
; <pre>
;   velo          ; x-axis is now velocity
;   chan          ; now it's channels
;   freq          ; now it's frequency
; </pre>
;
; @version $Id$
;-
pro velo
   if (!g.plotter_axis_type ne 2) then begin
       !g.plotter_axis_type=2
       if not !g.frozen and !g.line then reshow
   endif
   return
end
