; docformat = 'rst' 

;+
; Get the RA and DEC at the requested equinox from a data container.
;
; This returns the Right Ascension and Declination as a 2-element
; vector (for spectral line data) or array (with dimension of [2,the
; number of integrations] for continuum data) appropriate for the given
; data container given the requested equinox.  If equinox is not
; supplied, the value in the header is used if present and set,
; otherwise 2000.0 is used (e.g. if the data container holds GALACTIC 
; coordinates).  The values in the longitude_axis and latitude_axis
; are used as is the coordinate_mode.  If the coordinate_mode is RADEC
; and the equinox argument is not supplied or it matches the equinox
; in the data container, then those values are returned as is.
;
; If the data container's coordinate_mode field is OTHER then
; the values are returned as is and a warning message is emited.
; That warning message can be suppressed if /quiet is set.
;
; :Params:
;   dc : in, required, type=data container
;       The data container to get the coordinate values from.
;   equinox : in, optional, type=double
;       The equinox to use (decimal years).  Defaults to the value of
;       dc.equinox.
;
; :Keywords:
;   quiet : in, optional, type=boolean
;       When set, warning messages are suppressed.
;
; :Returns:
;   vector (spectral line) or array (continuum) holding RA and DEC in degrees.
;
;-
function getradec, dc, equinox, quiet=quiet
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

    if n_elements(equinox) eq 0 then begin
        equinox = dc.equinox
        if equinox lt 1900.0 then equinox = 2000.0d
    endif

    case dc.coordinate_mode of
        'RADEC': begin
            if dc.equinox ne equinox then begin
                fk4 = 0
                if dc.equinox lt 1975.0 then fk4 = 1
                precess, longaxis, lataxis, dc.equinox, equinox, fk4=fk4
            endif
        end
        'GALACTIC': begin
            thisradec = galtoeq(longaxis, lataxis, equinox)
            if n_elements(thisradec) gt 2 then begin
                longaxis = thisradec[0,*]
                lataxis = thisradec[1,*]
            endif else begin
                longaxis = thisradec[0]
                lataxis = thisradec[1]
            endelse
        end
        'HADEC': begin
            longaxis = ha2ra(longaxis, lst)
            if dc.equinox ne equinox then begin
                fk4 = 0
                if dc.equinox lt 1975.0 then fk4 = 1
                precess, longaxis, lataxis, dc.equinox, equinox, fk4=fk4
            endif
        end
        'AZEL': begin
            hor2eq,lataxis,longaxis,(mjd+2400000.5D),ra,dec,lat=dc.site_location[1],$
                   lon=dc.site_location[0],refract_=0,aberration_=0,altitude=dc.site_location[2]
            longaxis = ra
            lataxis = dec
            ; above are in J2000
            if equinox ne 2000.0d then precess, longaxis, lataxis, 2000.0d, equinox
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
