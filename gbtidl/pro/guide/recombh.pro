; docformat = 'rst'

;+
; Plot the Hydrogen recombination lines for quantum jump of dN.
; Defaults to plotting the alpha lines (dN=1).
;
; Originally by Glen Langston, glangsto\@nrao.edu
;
; Molecular Formula from Tools of RadioAstronomy, Rolfs and Wilson,
; 2000, pg 334
; 
; .. math::
;       
;   v_{ki} = Z^2 R_M \left(\frac{1}{i^2} - \frac{1}{k^2}\right),
; 
; where :math:`R_M = R_\infty/(1 + m/M)`
; 
; .. math::
;       
;   v_{ki} = R_A \left(\frac{1}{i^2}  - \frac{1}{k^2}\right) (k > i)
; 
; where for hydrogen values (MHz), :math:`R_a = 3.28805129\times 10^9`
;
; :Params:
;   dn : in, optional, type=integer, default=1
;       The quantum jump to calculate (1 is alpha, 2 is beta, etc).
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
;       recombh,2,/doprint
;
; :Uses:
;   :idl:pro:`veltovel`
;   :idl:pro:`shiftvel`
;   :idl:pro:`shiftfreq`
;   :idl:pro:`show`
;   :idl:pro:`vline`
;   :idl:pro:`getxrange`
;   :idl:pro:`getyrange`
;   :idl:pro:`getplotterdc`
;
;-
pro recombh,dn,doPrint=doPrint
    compile_opt idl2

    on_error,2

    if not !g.line then begin
        message,'This only works with spectral line data.',/info
        return
    endif

    linesdrawn = 0

    freq

    ; Molecular Formula from Tools of RadioAstronomy, Rolfs and Wilson,
    ; 2000, pg 334
    ;
    ;  v_ki = Z^2 R_M ( 1/i^2  - 1/k^2), where R_M = R_infinity/(1 + m/M)
    ;  v_ki = R_A     ( 1/i^2  - 1/k^2) (k > i)
    ; Hydrogen values (MHz)
    Ra = 3.28805129E9
    ; do alpha lines by default

    if n_elements(dn) eq 0 then dn = 1
    if n_elements(doPrint) eq 0 then doPrint = 0

    yrange = getyrange(empty=empty)
    if empty then begin
        message,'Nothing in the plotter',/info
        return
    endif
    ; use full values of x, not just xrange, so that if we are zoomed
    ; when unzoom happens, the currently hidden lines will be shown
    x = getxarray()
    xmax = x[n_elements(x)-1]
    xmin = x[0]
    if xmax lt xmin then begin
        tmp = xmax
        xmax = xmin
        xmin = tmp
    endif
    ymax = yrange[1]
    ymin = yrange[0]
    yrange = ymax - ymin

    ; get source velocity as a true velocity, use DC in the plotter
    pdc = getplotterdc()
    vdef = pdc.velocity_definition
    ok = decode_veldef(vdef, veldef, vframe)
    ; this is the TRUE velocity in vframe
    vsrel = veltovel(pdc.source_velocity, 'TRUE',veldef)
    ; this is the current velocity offset that the user has set in 
    ; the plotter - that is a real velocity offset.
    vxOffset = getxvoffset()
    ; the velocity offset to actually shift the rest frequencies
    vshift = shiftvel(-vsrel,+vxoffset,veldef='TRUE')

    ; use this to get the doppler factor, just pick any frequency
    ; use observed_frequency - easy to get
    dopplerFactor = shiftfreq(pdc.observed_frequency, vshift, veldef='TRUE') / pdc.observed_frequency

    ; xoffset - this is a simple linear offset, applied last
    xoffset = getxoffset()
    xunits = getxunits()

    ; scale Ra to appropriate units
    case xunits of 
        'Hz': Ra = Ra * 1.d6
        'kHz': Ra = Ra * 1.d3
        'MHz': Ra = Ra
        'GHz': Ra = Ra * 1.d-3
    endcase

    yincr=0.03

    greeks=['\alpha','\beta','\gamma','\delta','\epsilon',$
            '\zeta','\eta','\theta','\iota','\kappa', $
            '\lambda','\mu','\nu','\xi','\omikron','\pi']

    atom = 'H'
    if (dn lt 15) then greek = greeks[dn-1]
    if (dn gt 14) then greek=':' + string(dn,form='(I0)') + ':'

    i = 1                           ; start at highest energy, lowest level
    ; now step through all likely lines, from high freq to low
    idstring = '__recombh_'+strtrim(string(dn),2)
    ; only clear when needed, but not too often
    hasCleared = 0
    repeat begin
        k = double(i + dn)
        x = double(i)
        ; calculate the frequency in plotter units
        xij = double((1./(x*x)) - 1./(k*k))*Ra*dopplerFactor 
        xij = xij - xoffset ; now with correct offset
        if ((xij gt xmin) && (xij lt xmax)) then begin
            if (not hasCleared) then begin
                clearvlines,idstring=idstring,/noshow
                hasCleared = 1
            endif
            textLabel = textoidl(atom + string(i,form='(I0)') + greek)
            vline, xij, label=textLabel, ylabel=1.0+yincr, /noshow, /ynorm, idstring=idstring
            linesdrawn = 1
            if (doPrint) then print, 'H levels = ',i+dn,' -> ',i,' nu = ', xij
        endif
        i = i + 1
        ; if past lowest frequency, exit
    endrep until (xij lt xmin or i gt 350)
    if linesdrawn then reshow

    return
end   ; end of recombh
