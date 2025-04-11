; docformat = 'rst'

;+
; Convert the given channels numbers to the x values appropriate for
; the currently displayed data container and x-axis settings.
;
; :Params:
;   chans : in, required, type=array
;       The channel numbers to convert.
;
; :Keywords:
;   type : in, optional, type=integer
;       The axis array type (0=channels, 1=frequency, 2=velocity). 
;       If not supplied, it will use the current x-axis type. When 
;       type is **not** the currently displayed x-axis type, the 
;       scaling is to standard SI units (m/s, Hz, and channels).
;
;   dc : in, optional, type=data container
;       A data container to use.  If not supplied, the most recently 
;       plotted (via show) data container is used.
;
; :Returns:
;   The converted channel numbers in the x-axis units currently
;   displayed.  If there is a problem (invalid arguments, no data found,
;   etc.) then the returned value is the chans argument.
;
; :Examples:
;   Get the x-axis value at channel 100 for the current plot
; 
;       .. code-block:: IDL
; 
;           a=chantox(100)
;
;
;   Get the frequency at channel 100 for the current plot
;   *Note* that the units of a depend on what the current x-axis is.
;   If x-axis is frequency, the units (MHz, GHz, Hz) will be the 
;   same as that in the current display.  If the x-axis is something
;   else, then the units of a will be Hz.
; 
;       .. code-block:: IDL
; 
;           a = chantox(100,type=1)
;
;
;   Get the velocity at channel 100 for a data container at
;   buffer 7.
; 
;       .. code-block:: IDL
; 
;           a = chantox(100,type=2,dc=!g.s[7])
; 
;-
function chantox, chans, type=type, dc=dc
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if n_params() ne 1 then begin
        message,'Usage: chantox(chans[, type=type, dc=dc])',/info
        ; this returns an undefined value, which is probably a good thing
        return,chans
    endif

    thisType = mystate.xtype
    thisDC = *mystate.dc_ptr
 
    if n_elements(type) eq 1 then thisType = type

    if n_elements(dc) eq 1 then begin
        if size(dc,/type) ne 8 then begin
            message,'The dc keyword value must be a data container',/info
            return,chans
        endif
        if data_valid(dc) le 0 then begin
            message,'The supplied dc value is not valid or is an empty data container',/info
            return,chans
        endif
        thisDC = dc
    endif else begin
        if data_valid(*mystate.dc_ptr) le 0 then begin
            if !g.line then begin
                thisDC=!g.s[0]
            endif else begin
                thisDC=!g.c[0]
            endelse
            if data_valid(thisDC) le 0 then begin
                message,'No data is known to the plotter and the primary data container is empty',/info
                return,chans
            endif
        endif
    endelse

    xscale = mystate.xscale
    if (n_elements(type) eq 0) then type = mystate.xtype

    name = tag_names(thisDC,/structure_name)

    if name eq "CONTINUUM_STRUCT" and type ne 0 then begin
        message,'type must be 0 (chans) for continuum data',/info
        return,chans
    endif

    if (type ne mystate.xtype) then xscale = 1.0

    result = convertxvalues(thisDC, chans, 1.0d, 0, '','',0.0d, 0.0d, $
                            xscale, type, mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset)

    return, result
end
