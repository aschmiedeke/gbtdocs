; docformat = 'rst' 

;+
; Flip the data end-to-end in the supplied data container.
; 
; For line data the value of frequency_increment and reference_channel
; are also changed appropriately so that, as displayed, there will be
; no change in appearance.  This is useful if you need to combine
; (e.g. average) two data containers where the frequency increments
; have opposite signs.  
;
; For continuum data (where the need to invert is less obvious), all
; of the time-dependent arrays are also flipped (utc, mjd, etc).
;
; The invert is done in place. 
;
; This procedure can not be used on the global guide data containers 
; because they are passed by value.
;
; :Params:
;   dc : in, required, type=data container
;       The data container to be smoothed. The data values are modified 
;       by this procedure.
; 
;-
pro dcinvert, dc
    compile_opt idl2

    nch=data_valid(dc,name=name)
    if nch le 0 then begin
        message, 'No valid data found to invert.',/info
        return
    endif

    *dc.data_ptr = reverse(*dc.data_ptr)

    case name of
        'SPECTRUM_STRUCT': begin
            dc.frequency_interval = -dc.frequency_interval
            dc.reference_channel = nch - 1 - dc.reference_channel
        end
        'CONTINUUM_STRUCT': begin
            *dc.date = reverse(*dc.date)
            *dc.utc = reverse(*dc.utc)
            *dc.mjd = reverse(*dc.mjd)
            *dc.longitude_axis = reverse(*dc.longitude_axis)
            *dc.latitude_axis = reverse(*dc.latitude_axis)
            *dc.lst = reverse(*dc.lst)
            *dc.azimuth = reverse(*dc.azimuth)
            *dc.elevation = reverse(*dc.elevation)
        end
        else: message,'Unknown data container structure name ' + name,/info
    endcase
end
