;+
; Show header information for the primary data container or any other
; data container.
;
; @param dc {in}{type=data container}{optional} The data container to
; use.  Defaults to the primary data container. 
;
; @examples
; <pre>
;   header
;   ; or, this is the same thing
;   header, !g.s[0]
; </pre>
;
; @uses <a href="../toolbox/scalevals.html">scalevals</a>
; @uses <a href="../toolbox/eqtogal.html">eqtogal</a>
; @uses <a href="../toolbox/getradec.html">getradec</a>
; @uses <a href="../toolbox/getradec.html">getgal</a>
; @uses <a href="../toolbox/ra2ha.html">ra2ha</a>
; @uses <a href="http://idlastro.gsfc.nasa.gov/ftp/pro/astro/adstring.pro">adstring</a>
;
;-  
pro header,dc
   compile_opt idl2

   if not !g.line then begin
       message,"header does not yet work in continuum mode.",/info
       return
   endif


   if (n_elements(dc) eq 0) then dc = !g.s[0]
   if (size(dc,/type) eq 2) then dc = !g.s[dc]
   isvalid = data_valid(dc,name=name)
   if (name ne 'SPECTRUM_STRUCT') then begin
      message,"header does not yet work in continuum mode.",/info
      return
   end
   if (isvalid eq -1) then begin
       message,'dc must be either continuum or spectrum', /info
       return
   endif
   if (isvalid eq 0) then begin
       message,'No spectrum is available.',/info
       return
   endif

   utcstring = adstring(dc.utc/3600.0)
   lststring = adstring(dc.lst/3600.0)
   expstring = strmid(adstring(dc.exposure/3600.0),1)

   radecValue = getradec(dc,/quiet)
   radec=strtrim(adstring(radecValue[0],radecValue[1],0),2) ; RA,DEC string
   az = dc.azimuth
   el = dc.elevation

   ha = ra2ha(radecValue[0],dc.lst)/15.0d
   ; get galactic coords here
   g = getgal(dc,/quiet)
   if dc.coordinate_mode eq 'OTHER' then begin
       ; pretend that the value is RA DEC and go from that
       if (dc.equinox eq 0.0) then dc.equinox=2000.0d
       g=eqtogal(dc.longitude_axis, dc.latitude_axis, dc.equinox)
   endif

   scalevals,dc.observed_frequency,fsky,fskyprefix
   scalevals,dc.line_rest_frequency,frest,frestprefix
   nchan=n_elements(*(dc.data_ptr))
   scalevals,dc.bandwidth,bw,bwprefix
   scalevals,abs(dc.frequency_interval),delf,delfprefix ; freq interval
   proc = dc.procedure
   if proc eq 'Nod' then proc = '  Nod'

   print,format='(80("-"))'
   print, leftjustify(dc.projid,14), leftjustify(dc.source,24), leftjustify(dc.observer,15), $
          format='("Proj: ",A14,"   Src   : ",A24,"    Obs : ",A15)'
   print
   print, dc.scan_number, radec, fsky, fskyprefix, $
          format='("Scan:",I10,"        RADec : ",A22,"     Fsky: ",F10.6,1x,A1,"Hz")'
   print, dc.integration, leftjustify(string(dc.equinox,format='(F6.1)'),21), frest, frestprefix, $
          format='("Int :",I10,"        Eqnx  :  ",A21,"     Frst: ",F10.6,1x,A1,"Hz")'
   print, strtrim(dc.polarization,2), leftjustify(string(dc.source_velocity/1.0e3,format='(F9.1)'),9,1), leftjustify(dc.velocity_definition,11), bw, bwprefix, $
          format='("Pol :     ",A5,"        V     :  ",A9,4x,A11,"  BW  : ",F7.3,4x,A1,"Hz")'
   print, dc.if_number, az, el, delf, delfprefix, $
          format='("IF  :     ",I5,"        AzEl  :  ",F7.3,6x,F6.3,2x,"     delF: ",F7.3,4x,A1,"Hz")'
   print, dc.feed, g[0], g[1], leftjustify(string(dc.exposure,format='(F8.1)'),8,1), $
          format='("Feed:     ",I5,"        Gal   :  ",F7.3, 5x, F7.3, 3x, "    Exp :  ",A8, "  s")'
   print, leftjustify(proc,10), utcstring, leftjustify(dc.date,11),dc.mean_tcal, $
          format='("Proc:     ",A10,"   UT    : ",A11,3x,A10,"   Tcal: ",F7.2,"    K")'
   print, dc.procseqn, leftjustify(lststring,11), leftjustify(string(ha,format='(F6.2)'),7,1), dc.tsys, $
          format='("Seqn:       ",I3,"        LST/HA: ",A11,3x,A6,"       Tsys: ",F7.2,"    K")'

   print,format='(80("-"))'

end
