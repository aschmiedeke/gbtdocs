;+
; Function to return the polynomial using the most recently fitted
; baseline coefficients and !g.nfit or the nfit keyword using the
; data in the primary data container.  This function is used in
; all of the GUIDE baseline related functions but may also be useful
; in other uses.
;
; <p>Note that getbasemodel does not do any fitting.  Use <a href="baseline.html">baseline</a> or <href="bshape.html">bshape</a>
; to generate a new fit.
;
; <p>Since orthogonal polynomials are used internally, using up
; to any nfit less than or equal to the value of nfit used when the
; polynomials were generated is itself the fit that would have resulted
; had that smaller nfit been used in the first place.  In this way,
; getbasemodel can be used to generate the model fit for any value of
; nfit up to the nfit actually used to generate the most recently fit
; polynomial. 
;
; @keyword nfit {in}{optional}{type=integer} Only use at most nfit
; parameters.  If !g.nfit is less then nfit, then only !g.nfit parameters will
; be used and a warning will be issued.
;
; @keyword ok {out}{optional}{type=boolean} 1 on success, 0 on failure.
;
; @returns Array corresponding to the polynomial at !g,polyfit through nfit
; evaluated at all of the channels in the primary data container.  Returns
; -1 on failure (ok will be 0).
;
; @examples
; <pre>
;    getrec, 20                            ; get some data
;    nregion,[100,500,700,1000,1600,2000]  ; set up regions to fit
;    nfit,7                                ; 7th order fit
;    bmodel                                ; do the fit
;    lastfit = getbasemodel()              ; get the fit
;    lastfit_n2 = getbasemodel(nfit=2)     ; only use up to 2nd order terms
; </pre>
;    
;
; @uses <a href="../toolbox/ortho_poly.html">ortho_poly</a>
; @uses <a href="../toolbox/data_valid.html">data_valid</a>
;
; @version $Id$
;-
function getbasemodel, nfit=nfit, ok=ok
    compile_opt idl2

    ok = 0
    if !g.nfit < 0 then begin
        message, 'There is no fit to use', /info
	return,-1
    endif

    npts = !g.line ? data_valid(!g.s[0]) : data_valid(!g.c[0])

    if (npts le 0) then begin
        message, 'There is no data in the primary data container',/info
        return,-1
    endif

    allChans = dindgen(npts)
    if keyword_set(nfit) then begin
	nfit_used = nfit < !g.nfit
	if nfit_used ne nfit then message,'Actual nfit used = ' + string(nfit_used), /info
    endif else begin
        nfit_used = !g.nfit
    endelse

    ok = 1
    return, ortho_poly(allChans, !g.polyfit[*,0:nfit_used])
end
