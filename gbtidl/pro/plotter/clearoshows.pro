; docformat = 'rst'

;+
; Clear any overlain plots (data containers plotted with oshow).  This
; removes them from the plotters state and does a reshow.
;
;-
pro clearoshows
    clearoshowslist
    reshow
end
