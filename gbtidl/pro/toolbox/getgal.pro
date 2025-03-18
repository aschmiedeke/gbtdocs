;+
; Get galactic coordinates from a data container.
;
; <p>This returns the galactic longitude and latitude as a 2-element
; vector (for spectral line data) or array (with dimension of [2, the
; number of integrations] for continuum data) appropriate for the given
; data container.  The values in the longitude_axis and latitude_axis
; are used as is the coordinate_mode.  If the coordinate_mode is GALACTIC
; then those values are returned as is.
;
; <p>If the data container's coordinate_mode field is OTHER then
; the values are returned as is and a warning message is emited.
; That warning message can be suppressed if /quiet is set.
;
; @param dc {in}{required}{type=data container} The data container to
; get the coordinate values from.
; @keyword quiet {in}{optional}{type=boolean} When set, warning
; messages are suppressed.
;
; @returns vector (spectral line) or array (continuum) holding
; galactic longitude and latitude, in degrees.
;
; @version $Id$
;-
function getgal, dc, quiet=quiet
    compile_opt idl2

    npts = data_valid(dc,name=type)
    if npts lt 0 then message,'DC is not a valid data container'

    if type eq 'SPECTRUM_STRUCT' then begin
        longaxis = dc.longitude_axis
        lataxis = dc.latitude_axis
        lst = dc.lst
        mjd = dc.mjd
    endif else begin
        if npts eq 0 then begin
            if not keyword_set(quiet) then begin
                message,'Continuum data is empty, no coordinates to use - using zeros',/info
            endif
            longaxis = 0
            lataxis = 0
            lst = 0
            mjd = 0
        endif else begin
            longaxis = *dc.longitude_axis
            lataxis = *dc.latitude_axis
            lst = *dc.lst
            mjd = *dc.mjd
        endelse
    endelse

    case dc.coordinate_mode of
        'RADEC': begin
            latlong = eqtogal(longaxis, lataxis, dc.equinox)
            if n_elements(latlong) gt 2 then begin
                longaxis = latlong[0,*]
                lataxis = latlong[1,*]
            endif else begin
                longaxis = latlong[0]
                lataxis = latlong[1]
            endelse
        end
        'GALACTIC': ; nothing to be done here
        'HADEC': begin
            ; convert HA to RA
            longaxis = ha2ra(longaxis,lst)
            latlong = eqtogal(longaxis, lataxis, dc.equinox)
            if n_elements(latlong) gt 2 then begin
                longaxis = latlong[0,*]
                lataxis = latlong[1,*]
            endif else begin
                longaxis = latlong[0]
                lataxis = latlong[1]
            endelse
        end
        'AZEL': begin
            hor2eq,lataxis,longaxis,(mjd+2400000.5D),ra,dec,lat=dc.site_location[1],$
                   lon=dc.site_location[0],refract_=0,aberration_=0,altitude=dc.site_location[2]
            longaxis = ra
            lataxis = dec
            ; above are in J2000
            latlong = eqtogal(longaxis, lataxis, dc.equinox)
            if n_elements(latlong) gt 2 then begin
                longaxis = latlong[0,*]
                lataxis = latlong[1,*]
            endif else begin
                longaxis = latlong[0]
                lataxis = latlong[1]
            endelse
        end
        else: begin
            if not keyword_set(quiet) then begin
                msg = 'Unable to convert from ' + dc.coordinate_mode + ' to RADEC, returning values as is'
                message,msg,/info
            endif
        end
    endcase

    if n_elements(longaxis) eq 1 then begin
        result = [longaxis, lataxis]
    endif else begin
        result = dblarr(2,n_elements(longaxis))
        result[0,*] = longaxis
        result[1,*] = lataxis
    endelse
    
    return, result
end
