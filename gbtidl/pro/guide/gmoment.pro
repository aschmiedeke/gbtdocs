; docformat = 'rst'

;+
; Find the first 3 moments of a region of the data in buffer 0.
;
; The three moments are:
; 
; .. code-block:: IDL
; 
;   m[0] = sum(data(i) * delta_x(i))
;   m[1] = sum(data(i)*x(i))/m[0]
;   m[2] = sqrt(sum(data(i)*(x(i)-m[1])^2)/m[0])
; 
; where the sums are over the region of interest, the x and delta_x
; values are the channel centers and spacings in the currently
; displayed x-axis units.  delta_x is calculated independently for
; each channel and centered at that channel.  The results are printed
; out and returned through the ret keyword. The display of the results
; can be turned off through the use of the ``/quiet`` flag.
;
; The region is given in the currently displayed x-axis units and
; the sum starts from the channel number nearest ``bmoment`` and ends at the
; channel number nearest ``emoment``.  If the ``/chan`` keyword is used, then
; ``bmoment`` and ``emoment`` are given in channels.  If a region is not
; specified the user is prompted to use the cursor on the plotter to
; mark the region. ``/full`` can be used to force gmoment to use all channels.
;
; Blanked values are ignored.
;
; The structure returned through the ``re`` keyword has these fields.
;   * **bchan** The first channel used.
;   * **echan** The last channel used.
;   * **nchan** The total number of channels used.
;   * **xmin** The minimum x-axis value (bchan or echan)
;   * **xmax** The maximum x-axis value (bchan or echan)
;   * **moments** A 3-element array giving the moments, in the order described above.
;   * **moment_unts** A 3-element string array giving the units for each moment.
;
; gmoment was chosen because IDL already has a moment function.
;
; :Params:
;   bmoment : in, optional, type=float
;       Start of region in x-axis units.
;   emoment : in, optional, type=float
;       End of region in x-axis units.
; 
; :Keywords:
;   chan : in, optional, type=boolean
;       Range specified in channels?
;   full : in, optional, type=boolean
;       Compute moments for full spectrum?
;   quiet : in, optional, type=boolean
;       Suppress the printing of the moments.
;   ret : out, optional, type=structure
;       Structure containing the results.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       gmoment, 1000, 1520, ret=ret
; 
;-
pro gmoment, bmoment, emoment, chan=chan, full=full, quiet=quiet, ret=ret
    compile_opt idl2

    if n_params() eq 1 then begin
        ; both bmoment and emoment or neither must be supplied, this is an error
        usage,'moment'
        return
    endif

    hasXaxis = not (n_elements(getxarray()) eq 1 and (getxarray())[0] eq -1)

    nels = !g.line ? data_valid(!g.s[0]) : data_valid(!g.c[0])
    if nels le 0 then begin
        message,'No data in primary data container',/info
        return
    endif

    chanRange = getstatsrange('moments', nels, bmoment, emoment, full=full, chan=chan)
    if n_elements(chanRange) eq 1 then begin
        message,'range is out of bounds for this data',/info
        return
    endif

    bchan = chanRange[0]
    echan = chanRange[1]
    chans = lindgen(echan-bchan+1) + bchan
    midleft = chans - 0.5
    midright = chans + 0.5
    xchans = chantox(chans)
    deltax = abs(chantox(midright) - chantox(midleft))
    data = !g.line ? (*(!g.s[0].data_ptr))[chans] : (*(!g.c[0].data_ptr))[chans]
    finiteData = finite(data)
    if total(finiteData) eq 0 then begin
        message,'All of the data in that range is blanked',/info
        return
    endif
    finiteIndex = where(finiteData)
    data = data[finiteIndex]
    xchans = xchans[finiteIndex]
    deltax = deltax[finiteIndex]

    mom0 = total(data*deltax,/double)
    mom1 = total(data*xchans*deltax,/double) / mom0
    mom2 = sqrt(total(data*deltax*(xchans - mom1)^2,/double)/mom0)

    yunits = strtrim(!g.line ? !g.s[0].units : !g.c[0].units, 2)
    xunits = strtrim(getxunits(),2)
    xyunits = yunits + "." + xunits
    ret = {bchan:bchan,echan:echan,nchan:n_elements(finiteIndex),xmin:min(xchans),xmax:max(xchans), $
           moments:[mom0,mom1,mom2], moment_units:[xyunits, xunits, xunits]}

    if not keyword_set(quiet) then begin
        print,'    Chans    bchan    echan        Xmin          Xmax'
        print,ret.nchan,bchan,echan,ret.xmin,ret.xmax, $
              format='(1x,I8,1x,I8,1x,I8,1x,G13.7,1x,G13.7)'
        print

        ; this keeps the labels aligned with the values and units'
        mom0Str = string(mom0,xyunits,format='(x,g11.5,x,a)')
        mom1Str = string(mom1,xunits,format='(x,g11.5,x,a)')
        mom2Str = string(mom2,xunits,format='(x,g11.5,x,a)')
        mom0StrValLen = strlen(strtrim(mom0Str,1))
        mom0Space = strlen(mom0Str) - mom0StrValLen
        mom0Pad = mom0Space + mom0StrValLen/2 - 3
        mom0Remain = strlen(mom0Str) - mom0Pad - 7
        mom1StrValLen = strlen(strtrim(mom1Str,1))
        mom1Space = strlen(mom1Str) - mom1StrValLen
        mom1Pad = mom0Remain + mom1Space + mom1StrValLen/2 - 2
        mom1Remain = strlen(mom0Str) - mom1Pad - 5
        mom2StrValLen = strlen(strtrim(mom2Str,1))
        mom2Space = strlen(mom2Str) - mom2StrValLen
        mom2Pad = mom1Remain + mom2Space + mom2StrValLen/2 - 3

        if mom0Pad le 0 then mom0Pad = 1
        if mom1Pad le 0 then mom1Pad = 1
        if mom2Pad le 0 then mom2Pad = 1

        fmt = '(' + strtrim(string(mom0Pad),2) + 'x,a,' + $
              strtrim(string(mom1Pad),2) + 'x,a,' + strtrim(string(mom2Pad),2) + 'x,a)'
        print,'Zeroeth','First','Second',format=fmt
        print,mom0Str,mom1Str,mom2Str
    endif

end
