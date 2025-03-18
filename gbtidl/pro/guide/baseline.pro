;+
; Fit and subtract a polynomial baseline.  The procedure works on
; the contents of buffer 0 (the primary data container).  Both
; continuum and line data are supported.
;
; <p>See the notes for <a href="bshape.html">bshape</a> for more details since this procedure 
; uses bshape for much of its work.
;
; <p>Use <a href="bshape.html">bshape</a> if you want to fit the baseline and (usually) 
; show the fit on the plotter without actually subtracting the fit
; from the data.
;
; <p>Use <a href="bsubtract.html">bsubtract</a> to subtract a baseline using the baseline 
; coefficients stored previously in the !g structure. Coefficients are
; stored in !g, for example, by running bshape.
;
; <p>Use <a href="bmodel.html">bmodel</a> to generate a baseline model from the coefficients and 
; store it in the buffer specified in modelbuffer.
;
; <p>Use <a href="bshow.html">bshow</a> to overplot a baseline model.
;
; <p>Use <a href="subtract.html">subtract</a> to subtract the data of one buffer (which might contain 
; a baseline model) from another.
;
; @keyword nfit {in}{optional}{type=integer} The order of the polynomial
; to fit.  Defaults to the value stored in !g.nfit, which can be set
; by the nfit procedure or, if nfit is set here, then the value
; of !g.nfit is set too.
;
; @keyword modelbuffer {in}{optional}{type=integer} The buffer number to
; hold the evaluated fit (the model).
;
; @keyword ok {out}{optional}{type=boolean} 1 on success, 0 on failure.
;
; @examples
; ; Get some data, set some regions, fit and subtract a 2nd order
; ; polynomial, storing the model (fitted baseline) into buffer 10.
; <pre>
;    getrec,20
;    nregion,[100,500,700,1000,1600,2000]
;    nfit,2
;    baseline,modelbuffer=10
; </pre>
; ; The step involving nfit can be omitted as follows:
; <pre>
;    baseline,nfit=2,modelbuffer=10
; </pre>
; ; Examine a fit first, then subtract it.
; <pre>
;    getnod, 10  ; first get some data
;    setregion   ; set the baseline region with the cursor
;    nfit, 5
;    bshape
;    baseline
; </pre>
;
; @uses <a href="bshape.html">bshape</a>
; @uses <a href="bsubtract.html">bsubtract</a>
;
; @version $Id$
;-


pro baseline, nfit=nfit, modelbuffer=modelbuffer, ok=ok
    compile_opt idl2

    ; this does the actual fit
    bshape, nfit=nfit, modelbuffer=modelbuffer, /noshow, ok=ok

    if not ok then return ; bshape will emit any errors

    bsubtract, nfit=nfit  ; bsubtract will show the result
end

