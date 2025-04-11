; docformat = 'rst'

;+
; Clear all overlays (gbtoplot and oshow results) from the plotter.
; This combines calls to clearoplots and clearoshows in to one
; function.  Baseline region boxes are also cleared with this call.
;
;-
pro clearovers
    clearoplotslist
    clearoshowslist
    showregion,/off
    reshow
end
