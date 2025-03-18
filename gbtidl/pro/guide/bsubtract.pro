;+
; Subtract a baseline using the stored coefficients in !g.polyfit and
; !g.nfit from the data in the primary data container.
;
; <p>Note that bsubtract does not itself do any fitting.  This only
; subtracts the result of the most recent fit.  Since the fitted
; polynomials are orthogonal, using up to !g.nfit of them is itself a
; valid fit at the lower order.
;
; @keyword nfit {in}{optional}{type=integer} Only use at most nfit 
; parameters.  If !g.nfit is less then nfit, then only !g.nfit
; parameters will be used and a warning will be issued.
;
; @keyword ok {out}{optional}{type=boolean} 1 on success, 0 on failure.
;
; @examples
; <pre>
; nfit=7
; bshape                        ; generate a 7th order fit
; copy,0,10                     ; keep for later use
; ; subtract the baseline
; bsubtract
; ; or, subtract a lower order fit
; copy,10,0
; bsubtract, nfit=2
; </pre>
; 
; @uses <a href="getbasemodel.html">getbasemodel</a>
;
; @version $Id$
;-
pro bsubtract, nfit=nfit, ok=ok
    compile_opt idl2

    model = getbasemodel(nfit=nfit,ok=ok)

    if ok then begin        
        if (!g.line) then begin
            *!g.s[0].data_ptr -= model
        endif else begin
            *!g.c[0].data_ptr -= model
        endelse
    endif
    if not !g.frozen then show
end
