; compile the prerequisites:
@scalUtils.pro
@scal.pro
createCalStruct
end

;---------getSnod----------------------------------------------------
;+
; Performs <B>scalar</B> Tcal calibration for a Subreflector Nod observation
; with Q, Ku, K-band, or W-band.
;
; <p> Combines data from the two beams in the 'correct' way.
; <p> Tant = mean(Tcal) * (SIG-REF)/(Cal_on-Cal_off)  -- units : Kelvin
; <p> Ta* = Tant*exp(tau*Airmass), if units="Ta*"
; <p> Store results in the PDC
;
; <p> <B>Note:</B> depends on routines in <a href="scalUtils.html">scalUtils.pro</a> 
; and <a href="scal.html">scal.pro</a>
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
; <p>units and tau added by F. Ghigo, NRAO-GB
;
; @param scan {in}{required}{type=integer} the scan number for the
; Track observation
; @keyword ifnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword plnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword refsmth {in}{optional}  Boxcar smoothing to
; be applied to REF and (Cal_on-Cal_off). Units are channels.
; @keyword units {in}{optional}{type=string} "Ta" or "Ta*".  If
; "Ta*" then the atmostpheric correction is done using tau.  Defaults
; to "Ta" (Tant in above equation).
; @keyword tau {in}{optional}{type=float} tzenith opacity, used if units="Ta*"
; 
; @version $Id$
;
; @file_comments scalarSubNod.pro provides routines for calibration of GBT
; observations done with subreflector nodding. e.g. observing scripts
; would be similar to:
; <pre>
;     SubBeamNod( src, scanDuration=120.0, beamName="MR12", 
;                 nodLenth=5, nodUnit="integrations" )
; </pre>
;
; <p>The routines in scalarSubNod.pro do calibration using a single Tcal
; (scalar) per spectral window (IF), using the values for Tcal from
; the sdfits file.  The calibrated Tant or Ta* is calculated and the
; resulting spectrum is stored in data container zero.
;
; <p>To calibrate subreflector nodding using vector Tcals, use the
; routines in <a href="getVctr.html">getVctr.pro</a>, after having derived the vector Tcals from
; an observation of a flux calibrator using the appropriate routines
; in <a href="scal.html">scal.pro</a>.
;
; <p><B>Note :</B> compiling this file invokes createCalStruct from <a href="scal.html">scal.pro</a>.
;
; <p><B>Contributed by: F. Ghigo, NRAO-GB</B>
;-
pro getSNod,scan,ifnum=ifnum,plnum=plnum,refsmth=refsmth,units=units,tau=tau

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(plnum) eq 0) then plnum = 0
     if (n_elements(refsmth) eq 0) then refsmth = 1
     if not keyword_set(tau)  then tau = 0.0 
     if not keyword_set(units)  then units = 'Ta'

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     ; The various beam/pol/phase combinations are averged into...
     resultAccum =  {accum_struct}
     accumclear, resultAccum

     ; Only appropriate for Ku, K-band, and Q-band
     sampler = [whichsampler(scan,ifnum,plnum,0), whichsampler(scan,ifnum,plnum,1)]

     for s = 0, 1 do begin

         accumclear, calOnAccum
         accumclear, calOffAccum
         accumclear, pos0Accum
         accumclear, pos1Accum
         
         ; Average records for all 4 combinations of cal on/off, subr pos 0 and 1
         pos0calOn = getchunk(count=count,scan=scan,sampler=sampler[s],cal='T',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sampler=sampler[s],cal='F',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sampler=sampler[s],cal='T',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sampler=sampler[s],cal='F',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; cOn/Off is the average of the cal on/off data
         ; p0, p1 are the average of the sub position 0 and 1

         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         if (refsmth gt 1) then begin
             *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
             *cOn.data_ptr = doboxcar1d(*cOn.data_ptr,refsmth,/nan,/edge_truncate)
             *cOff.data_ptr = doboxcar1d(*cOff.data_ptr,refsmth,/nan,/edge_truncate)
         endif

        ; Calculate Ta, update exposure time.  Flip sense for the correct phases
         data_copy,p0,result
         denom = *cOn.data_ptr - *cOff.data_ptr
         if (s eq 0) then begin
             *result.data_ptr = result.mean_tcal*(*p1.data_ptr - *p0.data_ptr)/denom
             tsys = result.mean_tcal * *p0.data_ptr/denom
         endif else begin
             *result.data_ptr = result.mean_tcal*(*p0.data_ptr - *p1.data_ptr)/denom
             tsys = result.mean_tcal * *p1.data_ptr/denom
         endelse

         result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)

        ; Store away mean value for Tsys and Tcal over central 90%
        nchan = n_elements(denom)
        n1 = floor(0.1*nchan)
        n2 = floor(0.9*nchan)

        result.tsys = mean(tsys[n1:n2],/nan)
        
        ; Average in this phase/feed/pol
        dcaccum,resultAccum,result,weight=1./result.tsys^2
    end

    ; Place results into the PDC
     accumave,resultAccum, result, /quiet
     result.units = "Ta"
     set_data_container,result,buffer=0

     ; if Ta*, correct for atmosphere, given the zenith tau
     if units eq 'Ta*' then begin
       zscale = exp( tau /sin(!pi*result.elevation/180.0))
       print,'tau,scale=',tau,zscale
       zspec = zscale * (*result.data_ptr)
       *result.data_ptr = zspec
       result.units = "Ta*"
       set_data_container,result,buffer=0
     endif
     
    ; Be a good boy and clean up memory
     data_free,pos0calOn & data_free,pos0calOff
     data_free,pos1calOn & data_free,pos1calOff
     data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
     data_free,result

end

;------getKASnod-------------------------------------------------------
;+
; Performs <B>scalar</B> Tcal calibration for a Subreflector Nod observation
; with Ka-band. 
; 
; <p> Combines data from the two beam/pols/phases in the 'correct' way.
; <p> Tant = mean(Tcal) * (SIG-REF)/(Cal_on-Cal_off)  -- units : Kelvin
; <p> Ta* = Tant*exp(tau*Airmass), if units="Ta*"
; <p> Stores results in the PDC
;
; <p> <B>Note:</B> depends on routines in <a href="scalUtils.html">scalUtils.pro</a> 
; and <a href="scal.html">scal.pro</a>
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
; <p>units and tau added by F. Ghigo, NRAO-GB
;
; @param scan {in}{required}{type=integer} the scan number for the
; Track observation
; @keyword ifnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword refsmth {in}{optional}  Boxcar smoothing to
; be applied to REF and (Cal_on-Cal_off). Units are channels.
; @keyword units {in}{optional}{type=string} Units: "Ta" or "Ta*".  If
; "Ta*" then the atmostpheric correction is done using tau.  Defaults
; to "Ta" (Tant in above equation).
; @keyword tau {in}{optional}{type=float} zenith opacity, used if units="Ta*"
;-
pro getKaSNod,scan,ifnum=ifnum, refsmth=refsmth, units=units,tau=tau

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(refsmth) eq 0) then refsmth = 1
     if not keyword_set(tau)  then tau = 0.0 
     if not keyword_set(units)  then units = 'Ta'

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     ; The various beam/pol/phase combinations are averged into...
     resultAccum =  {accum_struct}
     accumclear, resultAccum

     ; Only appropriate for Ka-band
     sampler = [whichsampler(scan,ifnum,1,0), whichsampler(scan,ifnum,0,1)]
     sigRef = ["T", "F"]

     for s = 0, 1 do begin

       for jSigRef = 0,1 do begin

         accumclear, calOnAccum
         accumclear, calOffAccum
         accumclear, pos0Accum
         accumclear, pos1Accum
         
         ; Average records for all 4 combinations of cal on/off, subr pos 0 and 1
         pos0calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=1)
	 ; print, 'Pos0 CalOn', count
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=1)
	 ; print, 'Pos0 CalOff', count
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=-1)
	 ; print, 'Pos1 CalOn', count
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=-1)
	 ; print, 'Pos1 CalOff', count
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         if (refsmth gt 1) then begin
             *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
             *cOn.data_ptr = doboxcar1d(*cOn.data_ptr,refsmth,/nan,/edge_truncate)
             *cOff.data_ptr = doboxcar1d(*cOff.data_ptr,refsmth,/nan,/edge_truncate)
         endif

        ; Calculate Ta, update exposure time.  Flip sense for the correct phases
         data_copy,p0,result
         denom = *cOn.data_ptr - *cOff.data_ptr
         if (s eq jSigRef) then begin
            *result.data_ptr = result.mean_tcal*(*p0.data_ptr - *p1.data_ptr)/denom
            tsys = result.mean_tcal * *p1.data_ptr/denom
         endif else begin
            *result.data_ptr = result.mean_tcal*(*p1.data_ptr - *p0.data_ptr)/denom
            tsys = result.mean_tcal * *p0.data_ptr/denom
         endelse

         result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)

        ; Store away mean value for Tsys and Tcal over central 90%
        nchan = n_elements(denom)
        n1 = floor(0.1*nchan)
        n2 = floor(0.9*nchan)

        result.tsys = mean(tsys[n1:n2],/nan)

        ; Average in this phase/feed/pol
        dcaccum,resultAccum,result,weight=1./result.tsys^2
       end
     end

    ; Place results into the PDC
     accumave,resultAccum, result, /quiet
     result.units = "Ta"
     set_data_container,result,buffer=0

     ; if Ta*, correct for atmosphere, given the zenith tau
     if units eq 'Ta*' then begin
       zscale = exp( tau /sin(!pi*result.elevation/180.0))
       print,'tau,scale=',tau,zscale
       zspec = zscale * (*result.data_ptr)
       *result.data_ptr = zspec
       result.units = "Ta*"
       set_data_container,result,buffer=0
     endif

    ; Be a good boy and clean up memory
     data_free,pos0calOn & data_free,pos0calOff
     data_free,pos1calOn & data_free,pos1calOff
     data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
     data_free,result

end

;-----------getSNodClassic-------------------------------------------
;+
; Performs "Classic" (Tsys(SIG_REF)/REF) <B>scalar</B> calibration for a Subreflector Nod observation
; with Q, Ku, K-band, or W-band.
;
; <p> Combines data from the two beams in the 'correct' way.
; <p> Tant = mean(Tsys) * (SIG-REF)/REF  -- units : Kelvin
; <p> Ta* = Tant * exp( tau*Airmass),  if units=Ta* 
; <p> Store results in the PDC
;
; <p> <B>Note:</B> depends on routines in <a href="scalUtils.html">scalUtils.pro</a> 
; and <a href="scal.html">scal.pro</a>
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
; <p>units and tau added by F. Ghigo, NRAO-GB
;
; @param scan {in}{required}{type=integer} the scan number for the
; Track observation
; @keyword ifnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword plnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword refsmth {in}{optional}  Boxcar smoothing to
; be applied to REF. Units are channels.
; @keyword units {in}{optional}{type=string} "Ta" or "Ta*".  If
; "Ta*" then the atmostpheric correction is done using tau.  Defaults
; to "Ta" (Tant in above equation).
; @keyword tau {in}{optional}{type=float} zenith opacity, used if units="Ta*"
;
;-
pro getSNodClassic,scan,ifnum=ifnum,plnum=plnum,refsmth=refsmth, units=units,tau=tau

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(plnum) eq 0) then plnum = 0
     if (n_elements(refsmth) eq 0) then refsmth = 1
     if not keyword_set(tau)  then tau = 0.0 
     if not keyword_set(units)  then units = 'Ta'

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     ; The various beam/pol/phase combinations are averged into...
     resultAccum =  {accum_struct}
     accumclear, resultAccum

     ; Only appropriate for Ku, K-band, and Q-band
     sampler = [whichsampler(scan,ifnum,plnum,0), whichsampler(scan,ifnum,plnum,1)]

     for s = 0, 1 do begin

         accumclear, calOnAccum
         accumclear, calOffAccum
         accumclear, pos0Accum
         accumclear, pos1Accum
         
         ; Average records for all 4 combinations of cal on/off, subr pos 0 and 1
         pos0calOn = getchunk(count=count,scan=scan,sampler=sampler[s],cal='T',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sampler=sampler[s],cal='F',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sampler=sampler[s],cal='T',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sampler=sampler[s],cal='F',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; cOn/Off is the average of the cal on/off data
         ; p0, p1 are the average of the sub position 0 and 1

         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         if (refsmth gt 1) then begin
             *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
         endif

	 ; Calculate Ta, update exposure time.  Flip sense for the correct phases
         data_copy,p0,result
         denom = *cOn.data_ptr - *cOff.data_ptr

         ; Store away mean value for Tsys over central 90%
         nchan = n_elements(denom)
         n1 = floor(0.1*nchan)
         n2 = floor(0.9*nchan)

         if (s eq 0) then begin
	     blah = *p0.data_ptr
             result.tsys = result.mean_tcal * mean(blah[n1:n2],/nan)/mean(denom[n1:n2],/nan)
             *result.data_ptr = result.tsys*(*p1.data_ptr - *p0.data_ptr)/*p0.data_ptr
         endif else begin
	     blah = *p1.data_ptr
             result.tsys = result.mean_tcal * mean(blah[n1:n2],/nan)/mean(denom[n1:n2],/nan)
             *result.data_ptr = result.tsys*(*p0.data_ptr - *p1.data_ptr)/*p1.data_ptr
         endelse

         result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)
        
         ; Average in this phase/feed/pol
         dcaccum,resultAccum,result,weight=1./result.tsys^2
    end

    ; Place results into the PDC
     accumave,resultAccum, result, /quiet
     result.units = "Ta"
     set_data_container,result,buffer=0

     ; if Ta*, correct for atmosphere, given the zenith tau
     if units eq 'Ta*' then begin
       zscale = exp( tau /sin(!pi*result.elevation/180.0))
       print,'tau,scale=',tau,zscale
       zspec = zscale * (*result.data_ptr)
       *result.data_ptr = zspec
       result.units = "Ta*"
       set_data_container,result,buffer=0
     endif
     
    ; Be a good boy and clean up memory
     data_free,pos0calOn & data_free,pos0calOff
     data_free,pos1calOn & data_free,pos1calOff
     data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
     data_free,result

end

;-------getKASNodClassic-------------------------------------------------------
;+
; Performs a "classic" (Tsys(SIG_REF)/REF) <B>scalar</B> calibration for a Subreflector Nod observation
; with Ka-band. 
; 
; <p> Combines data from the two beam/phases in the 'correct' way.
; <p> "Classic" : Tant = mean(Tsys) * (SIG-REF)/REF  -- units : Kelvin
; <p> Ta* = Tant * exp(tau*Airmass),  if units="Ta*"
; <p> Stores results in the PDC
;
; <p> <B>Note:</B> depends on routines in <a href="scalUtils.html">scalUtils.pro</a> 
; and <a href="scal.html">scal.pro</a>
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
; <p>units and tau added by F. Ghigo, NRAO-GB
;
; @param scan {in}{required}{type=integer} the scan number for the
; Track observation
; @keyword ifnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword refsmth {in}{optional}  Boxcar smoothing to
; be applied to REF. Units are channels.
; @keyword units {in}{optional}{type=string} "Ta" or "Ta*".  If
; "Ta*" then the atmostpheric correction is done using tau.  Defaults
; to "Ta" (Tant in above equation).
; @keyword tau {in}{optional}{type=float} tau : zenith opacity, used if units="Ta*"
;-
pro getKaSNodClassic,scan,ifnum=ifnum, refsmth=refsmth, units=units,tau=tau

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(refsmth) eq 0) then refsmth = 1
     if not keyword_set(tau)  then tau = 0.0 
     if not keyword_set(units)  then units = 'Ta'

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     ; The various beam/pol/phase combinations are averged into...
     resultAccum =  {accum_struct}
     accumclear, resultAccum

     ; Only appropriate for Ka-band
     sampler = [whichsampler(scan,ifnum,1,0), whichsampler(scan,ifnum,0,1)]
     sigRef = ["T", "F"]

     for s = 0, 1 do begin

       for jSigRef = 0,1 do begin

         accumclear, calOnAccum
         accumclear, calOffAccum
         accumclear, pos0Accum
         accumclear, pos1Accum
         
         ; Average records for all 4 combinations of cal on/off, subr pos 0 and 1
         pos0calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=1)
	 ; print, 'Pos0 CalOn', count
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=1)
	 ; print, 'Pos0 CalOff', count
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=-1)
	 ; print, 'Pos1 CalOn', count
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=-1)
	 ; print, 'Pos1 CalOff', count
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         if (refsmth gt 1) then begin
             *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
         endif

         ; Store away mean value for Tsys over central 90%
         nchan = n_elements(denom)
         n1 = floor(0.1*nchan)
         n2 = floor(0.9*nchan)

	 ; Calculate Ta, update exposure time.  Flip sense for the correct phases
         data_copy,p0,result
         denom = *cOn.data_ptr - *cOff.data_ptr
         if (s eq jSigRef) then begin
	     blah = *p1.data_ptr
             result.tsys = result.mean_tcal * mean(blah[n1:n2],/nan)/mean(denom[n1:n2],/nan)
             *result.data_ptr = result.tsys*(*p0.data_ptr - *p1.data_ptr)/*p1.data_ptr
         endif else begin
	     blah = *p0.data_ptr
             result.tsys = result.mean_tcal * mean(blah[n1:n2],/nan)/mean(denom[n1:n2],/nan)
             *result.data_ptr = result.tsys*(*p1.data_ptr - *p0.data_ptr)/*p0.data_ptr
         endelse

         result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)

        ; Average in this phase/feed/pol
        dcaccum,resultAccum,result,weight=1./result.tsys^2
       end
     end

    ; Place results into the PDC
     accumave,resultAccum, result, /quiet
     result.units = "Ta"
     set_data_container,result,buffer=0

     ; if Ta*, correct for atmosphere, given the zenith tau
     if units eq 'Ta*' then begin
       zscale = exp( tau /sin(!pi*result.elevation/180.0))
       print,'tau,scale=',tau,zscale
       zspec = zscale * (*result.data_ptr)
       *result.data_ptr = zspec
       result.units = "Ta*"
       set_data_container,result,buffer=0
     endif

    ; Be a good boy and clean up memory
     data_free,pos0calOn & data_free,pos0calOff
     data_free,pos1calOn & data_free,pos1calOff
     data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
     data_free,result

end


