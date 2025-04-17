; docformat = 'rst'

;+
; Fill in the indicated data container at modelbuffer using the
; primary data container and the most recently fit parameters in
; !g.polyfit and !g.nfit.  Optionally use a smaller nfit than
; !g.nfit. 
;
; *Note*: bmodel does not do any fitting.  Use :idl:pro:`baseline` or 
; :idl:pro:`bshape` to generate a new fit.
;
; Since orthogonal polynomials are used internally, using up
; to any nfit less than or equal to the value of nfit used when the
; polynomials was generated is itself the fit that would have resulted
; had that smaller nfit been used in the first place.  In this way,
; bmodel can be used to generate the model fit for any value of nfit
; up to the nfit actually used to generate the most recently fit
; polynomial. 
;
; :Keywords:
; 
;   modelbuffer : in, optional, type=integer, default=1
;       The buffer number of the data container to use to hold the model.
;       Defaults to 1 if not supplied.
;
;   nfit : in, optional, type=integer
;       Only use at most nfit parameters.  If !g.nfit is less then nfit, 
;       then only !g.nfit parameters will be used and a warning will be issued.
; 
;   ok : out, optional, type=boolean
;       1 on success, 0 on failure.
;
; :Examples:
; 
;   .. code-block:: IDL
;
;       ; put the model in !g.s[1]
;       bmodel
;       ; put the model in !g.s[10], using nfit=5
;       nfit,5
;       bmodel, modelbuffer=10
;       ; put the model with nfit=2 into buffer 11
;       bmodel modelbuffer=11, nfit=2
; 
; :Uses:
; 
;   :idl:pro:`DATA_VALID`
;   :idl:pro:`getbasemodel`
;
;-
pro bmodel, modelbuffer=modelbuffer, nfit=nfit, ok=ok
    compile_opt idl2

    if (n_elements(modelbuffer) eq 0) then modelbuffer = 1

    maxbuffer = !g.line ? n_elements(!g.s) : n_elements(!g.c)

    if  (modelbuffer lt 0 or modelbuffer gt maxbuffer) then begin
        message, 'requested modelbuffer does not exist',/info
        return
    endif

    model_data = getbasemodel(nfit=nfit,ok=ok)

    if ok then begin
        copy,0,modelbuffer
        if (!g.line) then begin
            *!g.s[modelbuffer].data_ptr = model_data
        endif else begin
            *!g.c[modelbuffer].data_ptr = model_data
        endelse
    endif
end
