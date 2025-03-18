;+
; Get the Azimuth and Elevation from a data container's longitude_axis
; and latitude_axis header words.
;
; <p>This returns the Azimuth and Elevation as a 2-element
; vector (for spectral line data) or array (with dimension of [2,
; number of integrations] for continuum data) appropriate for the given
; data container.  The values in the longitude_axis and latitude_axis
; are used as is the coordinate_mode.  If the coordinate_mode is AZEL
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
; Azimuth and Elevation in degrees.
;
; @version $Id$
;-
function getazel, dc, quiet=quiet
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
            ; precess to nearest of 1950 or 2000
            b1950=0
            if (dc.equinox lt 1975.0d) then begin
                b1950=1
                if (dc.equinox ne 1950.0d) then precess, longaxis, lataxis, dc.equinox, 1950.0d, /fk4
            endif else begin
                if (dc.equinox ne 2000.0d) then precess, longaxis, lataxis, dc.equinox, 2000.0d
            endelse
            eq2hor,longaxis,lataxis,(mjd+2400000.5D),alt,az,lat=dc.site_location[1],$
                   lon=dc.site_location[0],refract_=0,aberration_=0,altitude=dc.site_location[2],b1950=b1950
            longaxis = az
            lataxis = alt
        end
        'GALACTIC': begin
            radec = galtoeq(longaxis, lataxis, dc.equinox)
            if n_elements(radec) gt 2 then begin
                longaxis = radec[0,*]
                lataxis = radec[1,*]
            endif else begin
                longaxis = radec[0]
                lataxis = radec[1]
            endelse
            ; above are in J2000
            eq2hor,longaxis,lataxis,(mjd+2400000.5D),alt,az,lat=dc.site_location[1],$
                   lon=dc.site_location[0],refract_=0,aberration_=0,altitude=dc.site_location[2]
            longaxis = az
            lataxis = alt
        end
        'HADEC': begin
            longaxis = ha2ra(longaxis, lst)
            ; precess to nearest of 1950 or 2000
            b1950=0
            if (dc.equinox lt 1975.0d) then begin
                b1950=1
                if (dc.equinox ne 1950.0d) then precess, longaxis, lataxis, dc.equinox, 1950.0d, /fk4
            endif else begin
                if (dc.equinox ne 2000.0d) then precess, longaxis, lataxis, dc.equinox, 2000.0d
            endelse
            eq2hor,longaxis,lataxis,(mjd+2400000.5D),alt,az,lat=dc.site_location[1],$
                   lon=dc.site_location[0],refract_=0,aberration_=0,altitude=dc.site_location[2],b1950=b1950
            longaxis = az
            lataxis = alt
        end
        'AZEL': ; nothing to do here
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
