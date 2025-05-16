; docformat = 'rst'

;+
; Plot the Hydrogen, :math:`\alpha`, :math:`\beta`, :math:`\gamma`, helium :math:`\alpha`, :math:`beta` and carbon :math:`\alpha` recombination lines.
;
; Originally by Glen Langston, glangsto\@nrao.edu
;
; :Keywords:
;   doPrint : in, optional, type=boolean, default=0
;       optionally print the line frequencies.  The printed frequencies
;       are the line frequencies in the frame being displayed on the plotter.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       recomball,/doprint
;
; :Uses:
;   :idl:pro:`recombh`
;   :idl:pro:`recombhe`
;   :idl:pro:`recombc`
;
;-
pro recomball,doPrint=doPrint
    compile_opt idl2

    on_error,2

    if not !g.line then begin
        message,'This only works with spectral line data.',/info
        return
    endif

    if n_elements(doPrint) eq 0 then doPrint = 0 ; if no doPrint arg, no print

    recombh,1,doPrint=doPrint   ; hydrogen alpha
    recombh,2,doPrint=doPrint  ; hydrogen beta
    recombh,3,doPrint=doPrint   ; hydrogen gamma

    recombhe,1,doPrint=doPrint  ; helium alpha
    recombhe,2,doPrint=doPrint  ; helium beta

    recombc,1,doPrint=doPrint   ; carbon alpha

    return
end   ; end of recombAll
