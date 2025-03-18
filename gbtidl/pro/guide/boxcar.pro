; docformat = 'rst'

;+
; Smooth the primary data container (the PDC, !g.s[0]) with a boxcar
; of a certain width, in channels.  
;
; Replaces the contents of the data being smoothed with the smoothed
; data.
;
; For odd width, this uses the built-in idl SMOOTH function.  For
; even widths this uses :idl:pro:`doboxcar1d` and the reference channel is 
; moved left by 1/2 channel width.
;
; Other buffers (0 to 15) can be used instead of the PDC by
; supplying a value for the buffer keyword.
;
; For spectrum data containers, the frequency_resolution is set 
; using :idl:pro:`estboxres` 
;
; :Params:
; 
;   width : in, required, type=integer
;       Width of boxcar in channels. 
;
;   buffer : in, optional, type=integer, default=0
;       global buffer number to use (0-15).
;
;   decimate : in, optional, type=boolean
;       If set, the data container is reduced - taking every width 
;       channels starting at channel 0.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getps, 25            ; get some data into the PDC
;       copy,0,10            ; for use later in this example
;       copy,0,11            ; also for use later
;       boxcar, 3            ; 3 channel boxcar smooth
;       boxcar, 5, buffer=10 ; 5 channel smooth on buffer 10
;       show,10              ; show the smoothed result
;       copy,11,0            ; unsmoothed copy back to the PDC
;       boxcar, 5, /decimate ; with decimation
; 
; :Uses:
;
;   :idl:pro:`doboxcar1d`
;   :idl:pro:`dcextract`
;
;-
pro boxcar, width, buffer=buffer, decimate=decimate
    compile_opt idl2

    if n_elements(width) eq 0 then begin
        message,'Usage: boxcar, width[, buffer=buffer, decimate=decimate]',/info
        return
    end

    if n_elements(buffer) eq 0 then buffer=0

    if !g.line then begin
        if buffer lt 0 or buffer gt n_elements(!g.s) then begin
            message,string(n_elements(!g.s),format='("Buffer must be between 0 and ",i2)'),/info
            return
        endif
        nch=data_valid(!g.s[buffer])
        if nch le 0 then begin
            message, 'No valid data found to smooth.',/info
            return
        endif
        if (width le 0 or width gt nch) then begin
            message,string(nch,format='("Width must be between 1 and ",i)'),/info
            return
        endif
        *!g.s[buffer].data_ptr = doboxcar1d(*!g.s[buffer].data_ptr,width,/nan,/edge_truncate)
        if width mod 2 eq 0 then begin
            !g.s[buffer].reference_channel -= 0.5
        endif

        chanRes = !g.s[buffer].frequency_resolution / abs(!g.s[buffer].frequency_interval)
        chanRes = estboxres(width,chanRes)
        !g.s[buffer].frequency_resolution = chanRes * abs(!g.s[buffer].frequency_interval)

        if keyword_set(decimate) then begin
            newdc = dcextract(!g.s[buffer],0,(nch-1),width)
            set_data_container,newdc,buffer=buffer,/noshow
            data_free, newdc
        endif
    endif else begin
        if buffer lt 0 or buffer gt n_elements(!g.c) then begin
            message,string(n_elements(!g.c),format='("Buffer must be between 0 and ", i2)'),/info
            return
        endif
        nch=data_valid(!g.c[buffer])
        if nch le 0 then begin
            message, 'No valid data found to smooth.',/info
            return
        endif
        if (width le 0 or width gt nch) then begin
            message,string(nch,format='("Width must be between 1 and ",i)'),/info
            return
        endif
        *!g.c[buffer].data_ptr = doboxcar1d(*!g.c[buffer].data_ptr,width,/nan,/edge_truncate)
        if width mod 2 ne 0 then begin
            message,'Warning: boxcar with an even width for continuum data skews the result towards early times',/info
        endif
        if keyword_set(decimate) then begin
            newdc = dcextract(!g.c[buffer],0,(nch-1),width)
            set_data_container,newdc,buffer=buffer,/noshow
            data_free, newdc
        endif
    endelse
    if not !g.frozen and buffer eq 0 then show
end
