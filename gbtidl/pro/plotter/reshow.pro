;+
; Reshow the contents of the data plotter.  
;
; <p> This is primarily used internally whenever the list of things
; overplotted on the main data container is changed (e.g. vline,
; annotate, gbtoplot, oshow, etc). However, it is also useful to users
; in two circumstances.  If you have killed the plotter window by
; clicking on the appropriate frame decoration in your display then
; reshow will cause it to reappear exactly as it was before.  It is
; also useful if you want to string together several vline or annotate
; calls before updating the plotter (using the /noshow argument in
; each call).  This can greatly speed up that operation.
;
; @examples
; <pre>
;     ; first, show something
;     getrec, 1
;     show
;     velo ; switch to velocity axis
;     ; make a vertical line at several places - label above y-axis
;     vline, 5.0, ylabel=1.05, label='A', /ynorm, /noshow
;     vline, 7.0, ylabel=1.05, label='A', /ynorm, /noshow
;     vline, 10.0, ylabel=1.05, label='A', /ynorm, /noshow
;     ; none of that has been plotted yet, use reshow to do that
;     reshow
; </pre>
;
; @uses <a href="../../devel/plotter/show_support.html">show_support</a>
;
; @version $Id$
;-
pro reshow
    show_support, /reshow
end
