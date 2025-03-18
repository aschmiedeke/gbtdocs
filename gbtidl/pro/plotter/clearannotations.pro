;+
; Removes all annotations from the current plot.
;
; @keyword noshow {in}{optional}{type=boolean} If set, don't call reshow
; here.
;
; @version $Id$
;-
pro clearannotations, noshow=noshow
    common gbtplot_common,mystate,xarray

    mystate.n_annotations = 0
    if (not keyword_set(noshow)) then reshow
    return
end
