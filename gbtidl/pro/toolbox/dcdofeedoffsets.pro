; docformat = 'rst' 

;+
; Apply or remove the feed offsets in the supplied data container.
;
; *Note:* The feed offsets need only be applied for old
; (fitsver earlier than 1.7) data written by gbtidl.  Data produced by
; sdfits from fitsver 1.7 on has had the feed offsets applied by
; sdfits.  In addition, GBTIDL applies all feed offsets by default
; when reading from SDFITS files having an SDFITSVER keyword (files
; produced by sdfits).  Other old SDFITS file are likely produced by
; GBTIDL using KEEP or SAVE and it's impossible to tell whether
; any non-zero feed offsets found there have been applied to the
; positions and so GBTIDL does not automatically apply the feed
; offsets when reading that data.
;
; This applies (default) or removes (when the /remove keyword is
; set) any non-zero feed offset values (feedxoff and feedeoff) found
; in the supplied data container.  If /reportonly is used then
; information is printed about what the new coordinate values would
; have been but the data container remains unchanged.
;
; Feed offsets can only be applied if the longitude and latitude
; coordinates can be converted to and from Azimuth and Elevation.
; Recognized coordinate systems are "RADEC","HADEC","GALACTIC",and
; "AZEL".  If the offsets can not be applied (or removed) the status
; value will be set to 0.  When successfull, the status value is 1.
;
; This works with spectral line and continuum data containers.
;
; :Params:
;   dc : in, required, type=data container
;       The data container to be used. The longitude, latitude, azimuth,
;       and elevation values are changed by this procedure unless /reportonly
;       is set.
; :Keywords:
;   remove : in, optional, type=boolean, default=0
;       When set, remove the feed offsets from the positions. The default
;       is to apply the feed offsets.
;   reportonly : in, optional, type=boolean, default=0
;       When set, generate a report only. No values in dc are changed when that
;       is set.  For continuum data containers, the report is generated for
;       a position near the middle integration.
;   status : out, optional, type=integer
;   On success, this is set to 1.  On failure it is set to 0.
;
;-
pro dcdofeedoffsets, dc, remove=remove, reportonly=reportonly, status=status
  compile_opt idl2

  if data_valid(dc,name=dc_name) le 0 then begin
     message,'No valid data in dc.',/info
     status = 0
     return
  endif

  status = 1

  ; zero offsets - do nothing
  if dc.feedxoff eq 0.0 and dc.feedeoff eq 0.0 then begin
     if keyword_set(reportonly) then begin
        print,"Zero offsets - nothing to be done"
     endif
     return
  endif

  telLat = dc.site_location[1]
  telLong = dc.site_location[0]
  telAlt = dc.site_location[2]

  isSpectrum = dc_name eq 'SPECTRUM_STRUCT'

  if isSpectrum then begin
     dcLat = dc.latitude_axis
     dcLong = dc.longitude_axis
     dcEl = dc.elevation
     dcAz = dc.azimuth
     jd = dc.mjd + 2400000.5d

     if keyword_set(reportonly) then begin
        origDcLat = dcLat
        origDcLong = dcLong
        origDcAz = dcAz
        origDcEl = dcEl
     endif
  endif else begin
     ; must be continuum data
     dcLat = *dc.latitude_axis
     dcLong = *dc.longitude_axis
     dcEl = *dc.elevation
     dcAz = *dc.azimuth
     jd = *dc.mjd + 2400000.5d

     if keyword_set(reportonly) then begin
        ; we're only reporting on something near the center
        ; so don't bother coverting anything other than that
        cent = n_elements(dcLat) / 2
        print,'Continuum report for sample number : ', cent
        dcLat = dcLat[cent]
        dcLong = dcLong[cent]
        dcEl = dcEl[cent]
        dcAz = dcAz[cent]
        jd = jd[cent]
        origDcLat = dcLat
        origDcLong = dcLong
        origDcAz = dcAz
        origDcEl = dcEl
     endif
  endelse

  ; get long and lat to az el
  ; these all work just fine for vector coordinates
  case dc.coordinate_mode of
     "AZEL": begin
        rawAz = dcLong
        rawEl = dcLat
     end
     "GALACTIC": begin
        ; galactic to FK5, J2000.0
        glactc, rawRA, rawDEC, 2000.0, dcLong, dcLat, 2, /degree
        ; FK5 to azel
        eq2hor, rawRA, rawDEC, jd, rawEl, rawAz, lat=telLat, lon=telLong, altitude=telAlt
     end
     "HADEC": begin
        ; Hour angle, dec to alt-az
        hadec2altaz, dcLong, dcLat, telLat, rawEl, rawAz
     end
     "RADEC": begin
        case dc.radesys of
           "FK4": begin
              ; need to precess to 1950.0?
              if dc.equinox ne 1950.0 then begin
                 precess, dcLong, dcLat, dc.equinox, 1950.0d, /fk4
              endif
              ; fk4 to fk5
              jprecess, dcLong, dcLat, rawRA, rawDEC
           end
           "FK5": begin
              ; need to precess to 2000.0?
              if dc.equinox ne 2000.0 then begin
                 precess, dcLong, dcLat, dc.equinox, 2000.0d
              endif
              rawRA = dcLong
              rawDEC = dcLat
           end
           else: begin
              ; unrecognized type
              print,"Unrecognized RADESYS value, can not apply offsets: ", dc.radesys
              status = 0
              return
           end
        endcase
        ; FK5 to azel
        eq2hor, rawRA, rawDEC, jd, rawEl, rawAz, lat=telLat, lon=telLong, altitude=telAlt
     end
     else: begin
        ; "OTHER" plus unrecognized coordinate types
        print,"Can not apply offsets to given coordiante type: ", dc.coordiante_mode
        status = 0
        return
     end
  endcase

  ; add or remove the offsets
  if not keyword_set(remove) then begin
     ; default - apply the offsets
     newEl = rawEl - dc.feedeoff
     newAz = rawAz - dc.feedxoff / cos(newEl * !pi/180.D0)

     ; and the values of the header az/el - likely to not be 
     ; the same as newAz,newEl for many reasons
     newHdrEl = dcEl - dc.feedeoff
     newHdrAz = dcAz - dc.feedxoff / cos(newHdrEl*!pi/180.D0)

  endif else begin
     ; remove the offsets
     newAz = rawAz + dc.feedxoff / cos(rawEl * !pi/180.D0)
     newEl = rawEl + dc.feedeoff

     ; and the values of the header az/el - likely to not be 
     ; the same as newAz,newEl for many reasons
     newHdrAz = dcAz + dc.feedxoff / cos(dcEl*!pi/180.D0)
     newHdrEl = dcEl + dc.feedeoff
  endelse

  ; and convert back to original coordinate system
  case dc.coordinate_mode of
     "AZEL": begin
        newLong = newAz
        newLat = newEl
     end
     "GALACTIC": begin
        ; azel to FK5
        hor2eq, newEl, newAz, jd, newRA, newDEC, lat=telLat, lon=telLong, alt=telAlt
        ; FK5 to galactic
        glactc, newRA, newDEC, 2000.0, newLong, newLat, 1, /degree
     end
     "HADEC": begin
        ; alt-az to ha, dec
        altaz2hadec, newEl, newAz, telLat, newLong, newLat
     end
     "RADEC": begin
        ; azel to FK5
        hor2eq, newEl, newAz, jd, newRA, newDEC, lat=telLat, lon=telLong, alt=telAlt
        if dc.radesys eq "FK5" then begin
           newLong = newRA
           newLat = newDEC
           ; need to precess to some other equinox?
           if dc.equinox ne 2000.0 then begin
              precess, newLong, newLat, 2000.0d, dc.equinox
           endif
        endif else begin
           ; must be FK4
           ; FK5 to FK4
           bprecess, newRA, newDEC, newLong, newLat
           ; need to precess to some other equinox?
           if dc.equinox ne 1950.0 then begin
              precess, newLong, newLat, 1950.0d, dc.equinox
           endif
        endelse
     end
     ; no need for an else in this case, it shouldn't ever happen
  endcase

  ; report or change values
  if keyword_set(reportonly) then begin
     if dc.coordinate_mode eq "RADEC" or dc.coordinate_mode eq "HADEC" then begin
        print,"Original Lat/Lon: ", adstring(origDcLong, origDcLat,2)
        print,"     new Lat/Lon: ", adstring(newLong, newlat,2)
     endif else begin
        print,"Original Lat/Lon: ", origDcLong, origDcLat
        print,"     new Lat/Lon: ", newLong, newlat
     endelse
     print,"Original Az/El  : ", origDcAz, origDcEl
     print,"     new Az/El  : ", newHdrAz, newHdrEl
     print,"Offsets (deg) xel/el: ", dc.feedxoff, dc.feedeoff
  endif else begin
     ; change them
     if isSpectrum then begin
        dc.longitude_axis = newLong
        dc.latitude_axis = newLat
        dc.azimuth = newHdrAz
        dc.elevation = newHdrEl
     endif else begin
        *dc.longitude_axis = newLong
        *dc.latitude_axis = newLat
        *dc.azimuth = newHdrAz
        *dc.elevation = newHdrEl
     endelse
  endelse
end
