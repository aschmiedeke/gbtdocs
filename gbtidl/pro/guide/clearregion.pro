; docformat = 'rst'

;+
; Clears all baseline regions by resetting !g.nregion to 0.  Any
; region boxes displayed on the plotter are also erased.
;
; :Examples:
;
;   .. code-block:: IDL
;
;       setregion                 ; interactively set a region
;       clearregion               ; clear them all 
;       nregion,[100,200,500,700] ; set them by hand
;
;-
pro clearregion
    !g.nregion = 0
    ; this unplots the regions but doesn't change the 
    ; state of plotter toggle 
    clearoplots, idstring='__showregion'
end
