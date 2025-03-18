;+
; Convert a zpectrometer data container to a standard GBTIDL data
; container.
;
; <p>The output data container, dc, is reused if possible (it has the
; appropriate type and size).  If it can not be used, free_data is
; first used to clean up the pointers that it contains and then a new
; data container is constructed using data_new.
;
; <p>By default, the LAGS array is used and the returned data
; container is a continuum data container.  If the DATA array is
; requested (using the DATA flag) then a spectrum data container is
; returned.  It is the responsibility of the caller to free the
; returned data container as necessary using data_free.
;
; <p>scan_number will hold the mc_scan value and procseqn will hold the
; zpectrometer scan value.
;
; <p>cal_state will hold the diode value
;
; <p>if_number will hold the beindex value
;
; @param zdc {in}{required}{type=zpectrometer data container} a
; zpectrometer data container
;
; @param dc {out}{required}{type=continuum or spectrum data container}
; The new data container holding the lags or data values and header
; values as appropriate.
;
; @keyword data {in}{optional}{type=boolean} When set, fill the data
; array in the output data container using the data array in the
; zpectrometer data container.  The default behavior is to use the
; lags array.
;
; @keyword status {out}{optional}{type=boolean} This is true (1) when
; the conversion has been successfull.
;
; @version $Id$
;-
pro zdc_to_dc, zdc, dc, data=data, status=status
    compile_opt idl2
    
    status = 0

    if n_elements(zdc) eq 0 then begin
        usage,'zdc_to_dc'
        return
    endif

   ; zdc must be an anonymous structure
    if size(zdc,/type) ne 8 then begin
        message,'zdc must be a structure',/info
        return
    endif

    if tag_names(zdc,/structure_name) ne "" then begin
        message,'zdc was not an anonymous structure as expected',/info
        return
    endif

    ; can't rely on anything being there.
;    catch, error_status
;    if error_status ne 0 then begin
;        print, 'Unexpected problem copying from zdc, can not continue'
;        print, 'Perhaps zdc is not a zpectrometer data container'
;        print, 'Error index: ', error_status
;        print, 'Error message: ', !error_state.msg
;        return
;        catch,/cancel
;    endif

    ; new data container of right type and data array value
    if keyword_set(data) then begin
        ndc = data_valid(dc,name=name)
        if name ne "SPECTRUM_STRUCT" or ndc ne n_elements(zdc.data) then begin
            if ndc gt 0 then data_free, dc
            dc = data_new(zdc.data,/spectrum)
        endif else begin
            *dc.data_ptr = zdc.data
        endelse
    endif else begin
        ndc = data_valid(dc,name=name)
        if name ne "CONTINUUM_STRUCT" or ndc ne n_elements(zdc.lags) then begin
            if ndc gt 0 then data_free, dc
            dc = data_new(zdc.lags,/continuum)
        endif else begin
            *dc.data_ptr = zdc.lags
        endelse
    endelse

    ; things common to both standard dc types
    dc.units = 'counts'
    dc.source = zdc.object
    dc.observer = zdc.observer
    dc.projid = zdc.projid
    dc.scan_number = zdc.mc_scan
    dc.procseqn = zdc.scan
    dc.procedure = zdc.procname
    dc.procsize = zdc.procsize
    ; no switch_state equivalent
    ; no switch_sig equivalend
    dc.sig_state = 1 ; no sig_state equivalent
    dc.cal_state = zdc.diode
    dc.integration = 0 ; not available 
    dc.if_number = zdc.beindex
    dc.obsid = zdc.obsid
    dc.backend = zdc.backend
    dc.frontend = zdc.frontend
    dc.exposure = zdc.exposure
    dc.duration = zdc.duration
    dc.tambient = zdc.tambient
    dc.pressure = zdc.pressure
    dc.humidity = zdc.humidity
    dc.tsys = zdc.tsys
    dc.mean_tcal = zdc.tcal
    dc.tsysref = 1.0  ; unavailable
    dc.telescope = zdc.telescop
    dc.site_location = [zdc.sitelong, zdc.sitelat, zdc.siteelev]
    ; this should work, and is independent of the type of dc
    dc.coordinate_mode = !g.lineio->coord_mode_from_types(zdc.ctype2, zdc.ctype3)
    dc.polarization = zdc.polariz
    dc.polarization_num = 0
    dc.feed = 0
    dc.srfeed = 0
    dc.feed_num = 0
    dc.feedxoff = 0.0
    dc.feedeoff = 0.0
    dc.sampler_name = ''
    dc.bandwidth = zdc.bandwid
    dc.observed_frequency = zdc.obsfreq
    dc.sideband = 'L'
    dc.equinox = zdc.equinox
    dc.timestamp = zdc.timestamp

    ; decipher date_obs
    dateObs = fitsdateparse(zdc.date_obs)
    justTheDate = strmid(zdc.date_obs,0,10)
    utc = (dateObs[3]*60.0+dateObs[4])*60.0+dateObs[5]
    juldate,dateObs,thismjd

    ; dc type-specific fields
    if keyword_set(data) then begin
        dc.zero_channel = !values.d_nan
        dc.nsave = -1
        dc.date = justTheDate
        dc.utc = utc
        dc.frequency_type = !g.lineio->format_sdfits_freq_type(zdc.ctype1)
        dc.reference_frequency = zdc.crval1
        dc.reference_channel = zdc.crpix1
        dc.frequency_interval = zdc.cdelt1
        dc.frequency_resolution = zdc.freqres
        dc.center_frequency = zdc.crval1
        dc.longitude_axis = zdc.crval2
        dc.latitude_axis = zdc.crval3
        dc.velocity_definition = zdc.veldef
        dc.frame_velocity = zdc.vframe
        dc.lst = zdc.lst
        dc.azimuth = zdc.azimuth
        dc.elevation = zdc.elevatio
        dc.line_rest_frequency = zdc.restfreq
        dc.source_velocity = zdc.vsource
        dc.freq_switch_offset = 0.0
        ; may or may not be there
        tagNames = tag_names(zdc)
        if where(tagNames eq 'SUBREF_STATE') ge 0 then begin
            dc.subref_state = zdc.subref_state
        endif else begin
            ; default to 1
            dc.subref_state = 1
        endelse
    endif else begin
        ; these are all constant
        ndata = n_elements(zdc.lags)
        last = ndata-1
        (*dc.longitude_axis)[0:last] = zdc.crval2
        (*dc.latitude_axis)[0:last] = zdc.crval3
        (*dc.azimuth)[0:last] = zdc.azimuth
        (*dc.elevation)[0:last] = zdc.elevatio
        (*dc.date)[0:last] = justTheDate
        (*dc.utc)[0:last] = utc
        (*dc.mjd)[0:last] = thismjd
        (*dc.lst)[0:last] = zdc.lst
    endelse

    status = 1

    return
end
