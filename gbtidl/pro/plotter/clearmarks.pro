; docformat = 'rst'

;+
; Clear all marks (+ plus associated text) from the plotter.
;
; :Keywords:
;   noshow : in, optional, type=boolean
;       Don't immediately update the plotter. This is useful if you are
;       stringing several plotter calls together.  It keeps the plotter 
;       from updating after each call.
;
;-
pro clearmarks, noshow=noshow
    common gbtplot_common,mystate,xarray
    compile_opt idl2

    mystate.nmarkers = 0
    if not keyword_set(noshow) then reshow
end
