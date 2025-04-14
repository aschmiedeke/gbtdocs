; docformat = 'rst' 

;+
; Smooth a data container with a boxcar smoothing of a certain
; width, in channels. For odd width, this uses the built-in idl
; SMOOTH function.  For even widths this uses :idl:pro:`doboxcar1d` 
; and the reference channel is moved left by 1/2 channel width.
;
; Replaces the contents of the data being smoothed with the smoothed
; data.  Use the GUIDE procedure, BOXCAR, to smoothing data containers
; in the !g structure.
;
; For spectrum data containers, the frequency_resolution is set 
; using :idl:pro:`estboxres`. 
;
; :Params:
;   dc : in, required, type=data container
;       The data container to be smoothed. The data values are
;       modified by this procedure.
; 
;   width : in, required, type=integer
;       Width of boxcar in channels. 
;
; :Keywords:
;   decimate : in, optional, type=boolean
;       If set, the data container is reduced - taking every width 
;       channels starting at channel 0.
;
; :Uses:
;   :idl:pro:`doboxcar1d`
;   :idl:pro:`doextract`
;
;-
pro dcboxcar, dc, width, decimate=decimate
    compile_opt idl2

    if n_elements(dc) eq 0 or n_elements(width) eq 0 then begin
        message,'Usage: dcboxcar, dc, width[, decimate=decimate]',/info
        return
    end

    nch=data_valid(dc,name=name)
    if nch le 0 then begin
        message, 'dc contains no valid data.',/info
        return
    endif

    if (width le 0 or width gt nch) then begin
        message,string(nch,format='("Width must be between 1 and ",i)'),/info
        return
    endif

    *dc.data_ptr = doboxcar1d(*dc.data_ptr,width,/edge_truncate,/nan)
    if width mod 2 eq 0 and name eq 'SPECTRUM_STRUCT' then begin
        dc.reference_channel -= 0.5
    endif

    if name eq 'SPECTRUM_STRUCT' then begin
        chanRes = dc.frequency_resolution / abs(dc.frequency_interval)
        chanRes = estboxres(width,chanRes)
        dc.frequency_resolution = chanRes * abs(dc.frequency_interval)
    endif

    if keyword_set(decimate) then begin
        newdc = dcextract(dc,0,(nch-1),width)
        data_copy,newdc,dc
        data_free,newdc
    endif
end
