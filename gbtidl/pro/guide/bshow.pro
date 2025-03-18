;+
; Overplot a baseline using the stored coefficients in !g.polyfit and
; !g.nfit and the data in the primary data container (number of
; channels only).
;
; <p>Note that bshow does not itself do any fitting.  This only show
; the result of the most recent fit.  Since the fitted polynomials are
; orthogonal, using up to !g.nfit of them is itself a valid fit at the
; lower order.
;
; @keyword nfit {in}{optional}{type=integer} Only use at most nfit
; parameters.  If !g.nfit is less then nfit, then only !g.nfit
; parameters will be used and a warning will be issued.
;
; @keyword ok {out}{optional}{type=boolean} This is set to 1 on
; success and 0 on failure.  
;
; @keyword color {in}{optional}{type=color}{default=!g.oshowcolor} The
; color to use for the overplot.
; 
; @examples
; <pre>
;    bshape, nfit=7, /noshow     ; fit a 7th order polynomial
;    bshow                       ; show it
;    bshow, nfit=5, color=!blue  ; show the 5th order fit 
; </pre>
;
; @uses <a href="getbasemodel.html">getbasemodel</a>
; @uses <a href="../plotter/gbtoplot.html">gbtoplot</a>
;
; @version $Id$
;-
pro bshow, nfit=nfit, ok=ok, color=color
    compile_opt idl2

    model = getbasemodel(nfit=nfit, ok=ok)       

    if ok then gbtoplot, model, /chan, color=color
end
