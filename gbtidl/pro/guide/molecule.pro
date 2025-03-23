; docformat = 'rst' 

;+
; Plot the molecular line frequencies for previously detected
; molecular lines stored in !g.molecules on the currently displayed
; plot at the appropriate location given the current x-axis.
;
; *Note:* The display is changed to show frequency as the x-axis
; if it is not already doing so.  
;
; *Note:* It is assumed that you want them shown
; at their rest frequency in the frequency reference frame current in
; use on the plotter adjusted for any source velocity.  If the source
; velocity has already been used to adjust the x-axis display then
; this routine will plot the molecule lines at their rest frequencies
; without any offset.  Use the */novsource* keyword to turn off
; any consideration of the source velocity - lines are simply plotted
; at their rest frequencies no matter what the source velocity is or 
; what the displayed x-axis is.
;
; The set of lines to be search can be narrowed by supplying a formula
; or name.  Wildcards are allowed and arrays of formula and names can
; be supplied.
;
; Only lines with an upper state energy less than or equal to the
; *elimit* value (in K) are shown.  The default value for this keyword is 50 K.
;
; To show fewer lines use a lower *elimit* value or select specific
; lines using the *formula* or *name* keywords.
;
; The *indices* keyword can be used to return the set of indices in the
; !g.molecules array of molecule_struct structures.  This can be used
; to get access to full information if desired.  See :idl:pro:`moleculeread` 
; for a description of the contents of the molecule_struct structure. 
;
; The line information was extracted from the Database for
; Astronomical Spectroscopy - `Splatalogue <https://www.splatalogue.net>`_ 
; specifically tailored for the available spectral line coverage of
; the GBT. Splatalogue is a fully rationalized and extended
; compilation of existing spectroscopic resources for use by the
; astronomical community including, but not limited too, the JPL,
; CDMS, Lovas/NIST, Frank Lovas' own Spectral Line Atlas of
; Interstellar Molecules (SLAIM) catalogs. 
;
; Splatalogue is maintained at the North American ALMA Science Center
; with cooperation from the East Asian and European ALMA Regional
; Centers. The Splatalogue Subsystem Scientist is Anthony Remijan. 
;
; For questions, comments, suggestions or concerns about Splatalogue
; please submit a Helpdesk ticket through the 
; `ALMA Science Portal <http://help.almascience.org>`_.
;
; The text file containing the line information is found at
; $GBT_IDL_DIR/pro/guide/GBTIDL_RFF.csv  
;
; :Keywords:
;   formula : in, optional, type=string(s), default=''
;       optionally filter the list of molecules to those whose formula
;       matches this string. Wildcards are allowed following the rules
;       of the IDL STRMATCH function.  If formula is array of strings, 
;       each element is used separately and the final list is the set 
;       of all lines with a formula matching any of the strings on that
;       list.  If not supplied, the entire list is used.  The filter is
;       case insensitive.
;   name : in, optional, type=string(s), default=''
;       optionally filter the list of molecules to those whose name matches
;       this string. Wildcards are allowed following the rules of the IDL
;       STRMATCH function.  If name is array of strings, each element is
;       used separately and the final list is the set of all lines with
;       a name matching any of the strings on that list.  If not supplied,
;       the entire list is used.  The filter is case-insensitive.
;   doprint : in, optional, type=boolean, default=0
;       optionally print the line frequencies.  The printed frequencies
;       are the line frequencies in the frame being displayed on the plotter.
;   elimit : in, optional, type=double, default=50.0
;       Only lines with an upper state energy less than or equal to this
;       limit will be plotted. The units are Kelvin. Lowering this limit 
;       reduces the number of lines plotted. 
;   indices : out, optional, type=integer
;       The list of indices in !g.molecules of the lines that were plotted.
;       This can be used to get the original information (e.g. rest frequency)
;       of the lines marked on the plot.  This has a value of -1 when no lines
;       were plotted.
;   novsource : in, optional, type=boolean
;       Optionally set this to turn off any consideration of the source
;       velocity when marking the locations of any molecule lines.
;
; :Examples:
;
;   .. code-block:: IDL
; 
;       molecule,formula='NH3*'                 ; All instances of ammonia
;       molecule,formula=['NH3*','HCCCHO*']     ; Two formulas to match
;       molecule,name=['ammonia','2-propynal']  ; Alternative
;       molecule,elimit=20                      ; lower the upper state energy cutoff to 20 K
;       molecule,indices=indices                ; get the indices of the species plotted
;       print,!g.molecules[indices].name        ; print out their names
; 
; :Uses:
;   :idl:pro:`moleculeread`
;   :idl:pro:`freq`
;   :idl:pro:`veltovel`
;   :idl:pro:`shiftvel`
;   :idl:pro:`shiftfreq`
;   :idl:pro:`decode_veldef`
;   :idl:pro:`show`
;   :idl:pro:`vline`
;   :idl:pro:`getxrange`
;   :idl:pro:`getyrange`
;   :idl:pro:`getxvoffset`
;   :idl:pro:`getxunits`
;   :idl:pro:`getxoffset`
;   :idl:pro:`getplotterdc`
;   :idl:pro:`textoidl` 
; 
;-
pro molecule, formula=formula, name=name, doprint=doprint, elimit=elimit, indices=indices, novsource=novsource
    compile_opt idl2
    on_error,2

    if n_elements(doprint) eq 0 then doprint = 0
    indices = -1

    if not !g.line then begin
        message,'This only works with spectral line data.',/info
        return
    endif

    ; check on user error in specifying formula or name
    ; this is common:  formula=H2CCNH instead of "H2CCNH"
    ; the former likely results in an undefined value being
    ; sent in so the usual n_elements test sees it as unset
    ; by the user and shows all lines.  Instead, use arg_present
    ; and n_elements to warn the user they probably didn't
    ; mean to do that.  Suggest that they forgot to use quotes.
    if n_elements(name) eq 0 and arg_present(name) then begin
       message,'name keyword was supplied but is empty.',/info
       message,'Did you forget to put the name within quotes?',/info
       return
    endif
    if n_elements(formula) eq 0 and arg_present(formula) then begin
       message,'formula keyword was supplied but is empty.',/info
       message,'Did you forget to put the formula within quotes?',/info
       return
    endif

    ; if they are supplied, they must be strings
    if n_elements(name) gt 0 and size(name,/type) ne 7 then begin
       message,'name keyword must be a string',/info
       return
    endif
    if n_elements(name) gt 0 and size(name,/type) ne 7 then begin
       message,'formula keyword must be a string',/info
       return
    endif

    if n_elements(elimit) le 0 then elimit = 50.0
    

    freq                        ; set x axis to frequency

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

    ; check for lines in range
    yrange = ymax - ymin
    yincr=0.04                 ; compute reason-able tag posion offsets
    yOffset= -4.0*yincr        ; start from bottom most position
    nShow = 0                  ; count number of lines shown

    moleculeRead          ; read in molecule frequencies
                                ; will not duplicate any effort if
                                ; already read

    ; select by formula
    count = 0
    indx = -1
    matches = -1
    if n_elements(formula) gt 0 then begin
       for i=0,n_elements(formula)-1 do begin
          thisMatch = strmatch(!g.molecules.formula,formula[i],/fold_case)
          if count eq 0 then begin
             matches = thisMatch
          endif else begin
             matches = matches + thisMatch
          endelse
          count = count + 1
       endfor
    endif
    if n_elements(name) gt 0 then begin
       for i=0,n_elements(name)-1 do begin
          thisMatch = strmatch(!g.molecules.name,name[i],/fold_case)
          if count eq 0 then begin
             matches = thisMatch
          endif else begin
             matches = matches + thisMatch
          endelse
          count = count + 1
       endfor
    endif

    if count gt 0 then begin       
       indx = where(matches gt 0,count)
       if count le 0 then begin
          message,'No molecules matching formula(s) and name(s)',/info
          return
       endif
    endif else begin
       ; everything through !g,nmol
       indx = lindgen(!g.nmol)
    endelse

    ; final filter on energy
    eLimIndx = where(!g.molecules[indx].upperStateE le elimit,count)
    if count le 0 then begin
       if n_elements(name) gt 0 or n_elements(formula) gt 0 then begin
          message,'No molecules matching formula(s) and name(s) with upper state energies less than elimit',/info
       endif else begin
          message,'No molecules with upper state energies less than elimit',/info
       endelse
       return
    endif
    
    indx = indx[eLimIndx]

    plotted = lonarr(n_elements(indx))
      
    if keyword_set(novsource) then begin
       dopplerFactor = 1.0
    endif else begin
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
    endelse

    ; xoffset - this is a simple linear offset, applied last
    xoffset = getxoffset()

    xunits = getxunits()

    ; find scale from xunits to MHz
    fscale = 1.d
    case xunits of 
        'Hz': fscale = 1.d6
        'kHz': fscale = 1.d3
        'MHz': fscale = 1.d
        'GHz': fscale = 1.d-3
    endcase

    ; clear any previously displayed molecule vertical lines
    clearvlines,idstring='__molecule',/noshow

    ;For all selected molecular lines
    for i = 0, (n_elements(indx)-1) do begin

       ; get frequency in appropriate frame
       thisMol = !g.molecules[indx[i]]
       xf = thisMol.freq        ;
       xf = xf * dopplerFactor  ; still in MHz
       xf = xf * fscale         ; now in plotter units
       xf = xf - xoffset        ; now with correct offset

       ; if line is in the plotted range
       if ((xf gt xmin) and (xf lt xmax)) then begin
          plotted[i] = 1
          textLabel = textoidl( strtrim(string(thisMol.formula)))
          ; actually mark line location, with formula
          vline, xf,label=textLabel, ylabel=yOffset+1.0,/noshow,/ynorm, idstring='__molecule'
          nShow = nShow + 1                                 ; count lines plotted
          yOffset = yOffset + yincr                         ; move to next text position
          if (yOffset ge -yincr) then yOffset = -4.*yincr   ; cycle back to first
          if (doprint) then print, thisMol.formula,' nu = ', xf
       endif
       ; if past both x end points, exit
    endfor
    reshow

    plIndx = where(plotted,plCount)
    if plCount gt 0 then indices = indx[plIndx]       

    return
end ; end of molecule
