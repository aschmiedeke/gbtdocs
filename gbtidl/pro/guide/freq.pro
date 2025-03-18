;+
; Change the x-axis on the plotter to frequency.
;
; @examples
; <pre>
;   freq          ; x-axis is now frequency
;   velo          ; now it's velocity
;   chan          ; now it's channels
; </pre>
;
; @version $Id$
;-
pro freq
   if (!g.plotter_axis_type ne 1) then begin
       !g.plotter_axis_type=1
       if not !g.frozen and !g.line then reshow
   endif
   return
end
