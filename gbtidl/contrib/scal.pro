;+
; Initializes or reinitializes the calCommon common block.
; <p>Must be called at least once before any processing
;
; @file_comments scal is a collection of routines for creating a
; vector Tcal from observations of a calibrator.  Supports:
; <ul>
; <li> single-beam On-Off and dual beam NOD obs (scal)
; <li> dual beam subr nodding Ku, K, Q (scalSubrNod)
; <li> Ka-band subr nodding (scalKaSubrNod)
; </ul>
; <p><B>User's Guide for Vector Calibration</B>
;
; <p>I will illustrate how one uses vector calibration by providing
; first a typical sequence of commands I use.  See the documentation
; for the individual routines for additional information. The library
; is maintained in three files, all of which are in the GBTIDL
; contribute area.
; <ul>
; <li> scal.pro - also contains this User's Guide.
; <li> <a href="scalUtils.html">scalUtils.pro</a>
; <li> <a href="getVctr.html">getVctr.pro</a>
; </ul>
;
; <p><B>Step (1)</B> -- Load in the libraries from the GBTIDL
;                       contribute area.
; <p><i>Note that the compile order is important in order to avoid
; errors</i>
; <p>Type:
; <pre>
;       GBTIDL -> .compile scalUtils.pro
;       GBTIDL -> .compile scal.pro
;       GBTIDL -> .compile getVctr.pro
; </pre>
; 
; <p><B>Step (2)</B> -- Connect to your data set
; <p>Type either:
; <pre>
;       GBTIDL -> filein, 'blah.fits'
; </pre>
; or
; <pre>
;       GBTIDL -> offline, 'projid'
; </pre>
; or
; <pre>
;       GBTIDL -> online
; </pre>
;
; <p><B>Step (3)</B> -- Create the common block where the calibration
;                       database will reside.
; <p>Type:
; <pre>
;       GBTIDL -> createCalStruct
; </pre>
; <p>Running this should empty the Tcal database.  I find I only need
; to run this command infrequently.  It must be done each GBTIDL
; session since the database is not retained between sessions.
;
; <p><B>Step (4)</B> -- Fill in the Tcal database.
; <p>The scal* examples below will use calibration scan 34 which is
; assumed to be toward a standard calibration source.  I tend to
; smooth the Tcal vectors to 1 MHz (smth=1).  See the documentation
; for scal.pro for how to specify a frequency-dependent functional
; form for opacity.  These scal* routines must be run once per IDL
; session.  Re-executing these commands with a new scan will overwrite
; the database with new Tcal vectors. 
;
;<p>How you generate Tcal vectors depends upon the observing mode and
;receiver.   
;<p><B>(4.a)</B> For Ka-band with subreflector nodding:
;<pre>
;	GBTIDL -> scalKaSubrNod, 34, tau=[0.023], ifnum=0, smth=1
;</pre>
;<p><B>(4.b)</B> For any subreflector nodding observation other than
;Ka-band, substitute for the above commands: 
;<pre>
;	GBTIDL -> scalSubrNod, 34, tau=[0.023], ifnum=0, plnum=0, smth=1
;	GBTIDL -> scalSubrNod, 34, tau=[0.023], ifnum=0, plnum=1, smth=1
;</pre>
;<p><B>(4.c)</B> For any NOD, Ka-band observation, substitute for the
;above commands: 
;<pre>
;	GBTIDL -> scal, 34, 35, tau=[0.023], ifnum=0, plnum=0, fdnum=0, smth=1
;	GBTIDL -> scal, 35, 34, tau=[0.023], ifnum=0, plnum=1, fdnum=1, smth=1
;</pre>
;Note how the order of the given scan numbers is reversed for the 2nd feed
;
;<p><B>(4.d)</B> For any NOD, non-Ka-band observation, substitute for
;the above commands: 
;<pre>
;	GBTIDL -> scal, 34, 35, tau=[0.023], ifnum=0, plnum=0, fdnum=0, smth=1
;	GBTIDL -> scal, 34, 35, tau=[0.023], ifnum=0, plnum=1, fdnum=0, smth=1
;	GBTIDL -> scal, 35, 34, tau=[0.023], ifnum=0, plnum=0, fdnum=1, smth=1
;	GBTIDL -> scal, 35, 34, tau=[0.023], ifnum=0, plnum=1, fdnum=1, smth=1
;</pre>
;Note how the order of the given scan numbers is reversed for the 2nd feed
;
;<p><B>(4.e)</B> For any On-Off, single-beam Ka-band observation,
;substitute for the above commands: 
;<pre>
;	GBTIDL -> scal, 34, 35, tau=[0.023], ifnum=0, plnum=0, fdnum=0, smth=1
;</pre>
;If you were using Off-On instead of On-Off observing, you will need
;to exchange the 34 for 35. 
;
;<p><B>(4.f)</B> For any On-Off, non-Ka-band observation, substitute for the above commands:
;<pre>
;	GBTIDL -> scal, 34, 35, tau=[0.023], ifnum=0, plnum=0, smth=1
;	GBTIDL -> scal, 34, 35, tau=[0.023], ifnum=0, plnum=1, smth=1
;</pre>
;If you were using Off-On instead of On-Off observing, you will need
;to exchange the 34 for 35 and 35 for 34.
;
;<p><B>Step (5)</B> -- Repeat for all IFNums
;<p>Repeat the above scal commands for each IFNum window, using a
;zenith opacity that may be different for each frequency window.  The
;Tcal vector for each window is stored separately in the database.
;
;<p><B>Step (6)</B> -- Check results (Optional)
;<p>I sometimes take a look at the results. 
;<pre>
;	GBTIDL -> plotCalDB
;</pre>
;See the comments in scal.pro for other plot options.
;
;<p><B>Step (7)</B> -- Apply Tcal vectors to actual observations
;<p>Now that the database contains Tcal vectors for every IFNum,
;PLnum, etc, you can start averaging scans for a particular source.
;Before averaging, you will need to remove the affects of the
;atmosphere at the elevation of the observation and maybe
;convert to Jy using the Ta2Flux routine.  Many ways to do
;this.  Here's one that will average up scans 41,42,...45,48,
;...52...  Scans 40-45 are assumed to have a different opacity than
;scans 48-52. 
;
;<p>Again, how you do this is receiver and observing mode dependent.
;
;<p><B>(7.a)</B> Assuming Ka-band subreflector nodding:
;<pre>
;	GBTIDL -> sclear
;	GBTIDL -> for s = 40, 45 do begin & getKaSubrNod, s, ifnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52 do begin & getKaSubrNod, s, ifnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> ave
;</pre>
;<p><B>(7.b)</B> For any subreflector nodding observation other than
;Ka-band, substitute for the above commands: 
;<pre>
;	GBTIDL -> sclear
;	GBTIDL -> for s = 40, 45 do begin & getVctrSubrNod, s, ifnum=0, plnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52 do begin & getVctrSubrNod, s, ifnum=0, plnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> for s = 40, 45 do begin & getVctrSubrNod, s, ifnum=0, plnum=1 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52 do begin & getVctrSubrNod, s, ifnum=0, plnum=1 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> ave
;</pre>
;<p><B>(7.c)</B> For any NOD, Ka-band observation, substitute for the
;above commands: 
;<pre>
;	GBTIDL -> sclear
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0, fdnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0, fdnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s+1, s, ifnum=0, plnum=1, fdnum=1 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s+1, s, ifnum=0, plnum=1, fdnum=1 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> ave
;</pre>
;Note how the s and s+1 arguments change when one averages in the data
;from the 2nd feed. 
;
;<p><B>(7.d)</B> For any NOD, non-Ka-band observation, substitute for
;the above commands: 
;<pre>
;	GBTIDL -> sclear
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0, fdnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0, fdnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=1, fdnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=1, fdnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s+1, s, ifnum=0, plnum=0, fdnum=1 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s+1, s, ifnum=0, plnum=0, fdnum=1 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s+1, s, ifnum=0, plnum=1, fdnum=1 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s+1, s, ifnum=0, plnum=1, fdnum=1 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> ave
;</pre>
;Note how the s and s+1 arguments change when one averages in the data
;from the 2nd feed. 
;
;<p><B>(7.e)</B>  For any On-Off, single-beam Ka-band observation,
;substitute for the above commands: 
;<pre> 
;	GBTIDL -> sclear
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> ave
;</pre>
;If you were using Off-On instead of On-Off observing, you will need
;to exchange the 's+1' everywhere there is an 's' and exchage 's'
;everywhere there is an 's+1'. 
;
;<p><B>(7.f)</B> For any On-Off, single-beam non-Ka-band observation,
;substitute for the above commands: 
;<pre>
;	GBTIDL -> sclear
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=0 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> for s = 40, 45, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=1 & Ta2Flux, tau=[0.026] & accum & end
;	GBTIDL -> for s = 48, 52, 2 do begin & getVctr, s, s+1, ifnum=0, plnum=1 & Ta2Flux, tau=[0.0275] & accum & end
;	GBTIDL -> ave
;</pre>
;If you were using Off-On instead of On-Off observing, you will need
;to exchange the 's+1' everywhere there is an 's' and exchage 's'
;everywhere there is an 's+1'. 
;
;<p><B>Step (8)</B> -- Repeat the generation of the above average but
;                      for ifnum=1, 2, 3, ... 
;<p>Repeat the above scal commands for each IFNum window, using a zenith
;opacity that may be different for each frequency window.  
;
;<p>Of course, you will need to change this workflow to match your own
;style and needs.  But, the above should give you a flavor of the
;sequence of how to process the various parts.  (You should expect
;typos since I didn't run anything through GBTIDL to check for
;syntax errors) 
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
;
; @version $Id$
;-
pro createCalStruct 
    common calCommon, calDatabase

    calstruct = {sampler:"", freqs:ptr_new(/allocate_heap), tcals:ptr_new(/allocate_heap), tau:ptr_new(/allocate_heap), eff:ptr_new(/allocate_heap), tsys:ptr_new(/allocate_heap), flux:ptr_new(/allocate_heap)}
    calDatabase = replicate(calstruct, 32)

    ; Unfortunately, the replicate also replicates the pointers -- they will all contain the same values.
    ; So, need to create new pointers for all but the first structure.
    for i = 1,31 do begin
          calDatabase[i] = {sampler:"", freqs:ptr_new(/allocate_heap), tcals:ptr_new(/allocate_heap), tau:ptr_new(/allocate_heap), eff:ptr_new(/allocate_heap), tsys:ptr_new(/allocate_heap), flux:ptr_new(/allocate_heap)}
    end
end

;+
; Plots the contents of the calibration DB.  The 'type' argument
; determines whether tsys, tcal (the default), tau, or eff are plotted
; 
; @keyword type {in}{optional}{type=string} The type of value to
; plot.  Choices are "tcal", "tsys", "tau", "eff", and "flux".
; Defaults to "tcal". 
;-
pro plotCalDB, type=type

    common calCommon, calDatabase

     if (n_elements(type) eq 0) then type='tcal'

     noPlot = 0
     xmin=1e34
     ymin=1e34
     xmax=-1e34
     ymax=-1e34
     for i = 0,31 do begin
         if (calDatabase[i].sampler ne "") then begin

            ; Summarize only central 90%
             nchan = n_elements(*calDatabase[i].freqs)
             n1 = floor(0.1*nchan)
             n2 = floor(0.9*nchan)
             print, i, calDatabase[i].sampler, mean((*calDatabase[i].tcals)[n1:n2],/nan), mean((*calDatabase[i].tsys)[n1:n2],/nan), mean((*calDatabase[i].tau)[n1:n2],/nan)

            ; Ue plot/oplot to plot desired results
             x = *calDatabase[i].freqs
             y = *calDatabase[i].tcals
             if (type eq 'tsys') then  y = *calDatabase[i].tsys
             if (type eq 'tau') then y = *calDatabase[i].tau
             if (type eq 'eff') then y = *calDatabase[i].eff
             if (type eq 'flux') then y = *calDatabase[i].flux
             xmin = min([xmin, min(x[n1:n2])])
             xmax = max([xmax, max(x[n1:n2])])
             ymin = min([ymin, min(y[n1:n2])])
             ymax = max([ymax, max(y[n1:n2])])
          endif
      end
      noPlot = 0
      for i = 0,31 do begin
         if (calDatabase[i].sampler ne "") then begin
            ; Summarize only central 90%
             x = *calDatabase[i].freqs
             y = *calDatabase[i].tcals
             if (type eq 'tsys') then  y = *calDatabase[i].tsys
             if (type eq 'tau') then y = *calDatabase[i].tau
             if (type eq 'eff') then y = *calDatabase[i].eff
             if (type eq 'flux') then y = *calDatabase[i].flux
             if (noPlot eq 0) then begin
                 plot, x, y, xrange=[xmin, xmax], yrange=[ymin, ymax]
                 noPlot = 1
             endif else begin
                 oplot, x, y
             endelse
          endif
      end
end

;+
; Retrieves data from the calibration DB and places the results into
; various data contains.
; <p>The user must supply the index of the entry to retrieve from the
; database.  The data containers will then contain:
; <ul>
; <li> DC 10 Freqs
; <li> DC 11 Efficiency
; <li> DC 12 Source flux
; <li> DC 13 Tau
; <li> DC 14 Tcal
; <li> DC 15 Tsys
; </ul>
;
; @param idx {in}{required}{type=integer} Cal database index number.
;-
pro getCalDB, idx

    common calCommon, calDatabase

    sampler = calDatabase[idx].sampler
    freqs = *calDatabase[idx].freqs
    tcals = *calDatabase[idx].tcals
    tauVctr = *calDatabase[idx].tau
    effVctr = *calDatabase[idx].eff
    tsys = *calDatabase[idx].tsys
    fluxVctr = *calDatabase[idx].flux

    nchan = n_elements(*calDatabase[idx].freqs)
    n1 = floor(0.1*nchan)
    n2 = floor(0.9*nchan)
    print, idx, sampler, mean(tcals[n1:n2],/nan), mean(effVctr[n1:n2],/nan), mean(fluxVctr[n1:n2],/nan), mean(tauVctr[n1:n2],/nan), mean(tsys[n1:n2],/nan)

;	DC 10 Freqs
;	DC 11 Efficiency
;	DC 12 Source flux
;	DC 13 Tau
;	DC 14 Tcal
;	DC 15 Tsys

    setdata,freqs,buffer=10
    setdata,effVctr,buffer=11
    setdata,fluxVctr,buffer=12
    setdata,tauVctr,buffer=13
    setdata,tcals,buffer=14
    setdata,tsys,buffer=15

end

;+
; Overwrites the contents of various scalars and vectors in the
; calibration database with the contents of IDL vectors.
; <p>The user must supply the index (idx) of the database entry that
; is to be overwritten to store plus the scalar or vectors to use.
; More than one scalar/vector can be overwritten with a single call.
; The scalars/vectors that can be overwritten are:
; <ul>
; <li> sampler - A string. The name of the Spectrometer sampler
;                associated with the DB index
; <li> freqs - A vector containing the frequencies associated with the
;              DB index 
; <li> tcals - A vector containing the frequency-dependent TCALs
;              associated with the DB index
; <li> tauVctr - A vector containing the frequency-dependent opacities
;                associated with the DB index
; <li> effVctr - A vector containing the frequency-dependent aperture
;                efficiencies associated with the DB index
; <li> tsys - A vector containing the frequency-dependent system
;             temperatures associated with the DB index
; <li> fluxVctr - A vector containing the frequency-dependent
;                 calibrator source flux associated with the DB index
; </ul>
;
; @param idx {in}{required}{type=integer} Cal database index number.
; @keyword sampler {in}{optional}{type=sampler} Sets the sampler value.
; @keyword freqs {in}{optional}{type=freqs} Sets the freqs value.
; @keyword tcals {in}{optional}{type=tcals} Sets the tcals value.
; @keyword tauVctr {in}{optional}{type=tauVctr} Sets the tauVctr value.
; @keyword effVctr {in}{optional}{type=effVctr} Sets the effVctr value.
; @keyword tsys {in}{optional}{type=tsys} Sets the tsys value.
; @keyword fluxVctr {in}{optional}{type=fluxVctr} Sets the fluxVctr value.
;-
pro setCalDB, idx, sampler=sampler, freqs=freqs, tcals=tcals, tauVctr=tauVctr, effVctr=effVctr, tsys=tsys, fluxVctr=fluxVctr

    common calCommon, calDatabase

;	DC 10 Freqs
;	DC 11 Efficiency
;	DC 12 Source flux
;	DC 13 Tau
;	DC 14 Tcal
;	DC 15 Tsys

    if (n_elements(sampler) ne 0) then calDatabase[idx].sampler = sampler
    if (n_elements(freqs) ne 0) then *calDatabase[idx].freqs = freqs
    if (n_elements(tcals) ne 0) then *calDatabase[idx].tcals = tcals
    if (n_elements(tauVctr) ne 0) then *calDatabase[idx].tau = tauVctr
    if (n_elements(effVctr) ne 0) then *calDatabase[idx].eff = effVctr
    if (n_elements(tsys) ne 0) then *calDatabase[idx].tsys = tsys
    if (n_elements(fluxVctr) ne 0) then *calDatabase[idx].flux = fluxVctr

end

;+
; Calculates Tcal, Tsys, ... from a Ka-band subreflector nodding
; observations with the hybrid phases cycling. 
;
; <p>Assumes the system is linear (Pwr_in = B*Pwr_out). 
;
; <p>Source fluxes are calculated in getFluxCalib for every channel.
; The routine uses the Ott et al polynomials coefficients for the
; fluxes of the 'standard' calibrators. Modify this routine when using
; frequencies outside the Ott fitting range or using a source not in
; the Ott catalog.
;
; <p>Modify getApEff and getTau if you want a frequency-dependent
; efficiency or opacity. getAppEff also allows for an elevation
; dependent efficiency.
;
; Results are stored in the calCommon common block.  The index entry
; is encoded as:
; <pre>
;    idx = ifnum + 8*s + 16*jSigRef
; </pre>
; where jsigRef = 0 or 1 for the two possible states of the hybrid and
; where s = 0 or 1 for the two possible states of the subreflector
;
; <p>The algorithm used is:
; <pre>
;    Scal = exp(-Tau*AirMass)*Flux*(CalOn - CalOff)/(SubrPos0 - SubrPos1)
;    Tcal = 2.8 * ap_eff * Scal
;    Tsys = Tcal * Ref_CalOff / (Ref_CalOn - Ref_CalOff)
; </pre>
;
; @param scan {in}{required}{type=integer} Scan number to process
; @keyword ifnum {in}{optional}{type=integer} Number of the spectral
; window.  If not supplied, will assume zero (1st window) 
; @keyword tau {in}{optional}{type=float} vector that encodes as
; polynomial coefficients the opacity at the zenith in nepers.  If not
; supplied, will assume the value returned by getTau.  See the
; documentation for getTau for the format of the vector.
; @keyword ap_eff {in}{optional}{type=float} 1 or 2-element vector
; that encodes aperture efficiency and it's frequency dependency.  If
; not supplied, will assume the value returned by getApEff .  See the
; documentation for getApEff for the format of the vector.
; @keyword smth {in}{optional}{type=value} The amount to boxcar smooth
; the data in MHz.  Sometimes mandatory if the source is weak and using
; very narrow channels.  Default is no smoothing
; @keyword src {in}{optional}{type=string} An optional string that
; allows one to override the source names used in the observations
; @keyword flux {in}{optional}{type=flux} An optional 1, 2, or
; 3-element vector that encodes the flux of the calibrator and
; it's frequency dependency.  See the documentation for
; getFluxCalib for the format of the vector.  If not supplied, the
; routine will attempt to use getFluxCalib internal database of fluxes
; for standard calibrator.s
; @keyword specindex {in}{optional}{type=specindex} An optional
; spectral index for the source.  Will be used only if flux is also
; given and only if flux is a single-element.
;
; @examples 
; getscalKaSubrNod,211,ifnum=0,tau=[0.034],smth=1,src='3C48'
; getscalKaSubrNod,212
;
;-
pro scalKaSubrNod,scan,ifnum=ifnum,tau=tau,ap_eff=ap_eff,smth=smth,src=src,flux=flux,specindex=specindex

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

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
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         ; No need to calculate freqs, taus, etc for every phase since these are
         ; identical for all phases
         if (jsigref eq 0 and s eq 0) then begin

            ; Use elevation, etc from the scan's mid point
            mid = count/2

            ; Determine if smoothing is to be done and by how much
            nbox=1
            if (n_elements(smth) ne 0) then begin
                nbox=floor(abs(smth/(pos0calOff[mid].frequency_interval/1.e6))+0.5)
            endif

            ; Retrieve elevation and source name, if not supplied as an argument
            elev=pos0calOff[mid].elevation
            if (n_elements(src) eq 0) then src = pos0calOff[mid].source
            
            ; freqs contains a vector of frequencies
            ; fluxVctr contains a vector of source fluxes
            ; tauVctr contains a vector of opacities
            ; effVctr contains vector of efficiencies

            num_chan = n_elements(*pos0calOff[mid].data_ptr)
            freqs = chantofreq(pos0calOff[mid],seq(0,num_chan-1))/1.e6
            if (n_elements(flux) ne 0) then begin
                fluxVctr = getFluxCalib(src,freqs,coeffs=flux)
            endif else begin
                fluxVctr = getFluxCalib(src,freqs,specindex=specindex)
            endelse
            tauVctr = getTau(freqs, coeffs=tau)
            effVctr = getApEff(elev, freqs, coeffs=ap_eff)

            scaleFactor = 2.8 * effVctr * fluxVctr * exp(-tauVctr*AirMass(elev))

         endif
         
         ; Flip the sense of calculation when beam != sigRef
         if (s eq jSigRef) then begin
            tcals = scaleFactor * (*con.data_ptr - *coff.data_ptr) / (*p0.data_ptr - *p1.data_ptr)
            tsys = tcals * *p1.data_ptr / (*con.data_ptr - *coff.data_ptr)
        endif else begin
            tcals = scaleFactor * (*con.data_ptr - *coff.data_ptr) / (*p1.data_ptr - *p0.data_ptr)
            tsys = tcals * *p0.data_ptr / (*con.data_ptr - *coff.data_ptr)
        endelse

        ; smooth
        if (nbox gt 1) then begin
            tcals = doboxcar1d(tcals,nbox,/nan,/edge_truncate)
            tsys = doboxcar1d(tsys,nbox,/nan,/edge_truncate)
        endif

        ; idx only works as a way to index Spectrometer/SP data.  May not work for future backends
        idx = ifnum + 8*s + 16*jSigRef

        ; summarize central 90%
        nchan = n_elements(freqs)
        n1 = floor(0.1*nchan)
        n2 = floor(0.9*nchan)
        print, idx, mean(tcals[n1:n2],/nan), mean(effVctr[n1:n2],/nan), mean(fluxVctr[n1:n2],/nan), mean(tauVctr[n1:n2],/nan), mean(tsys[n1:n2],/nan), nbox

        ; Store results into the common block database
        calDatabase[idx].sampler = sampler[s]
        *calDatabase[idx].freqs = freqs
        *calDatabase[idx].tcals = tcals
        *calDatabase[idx].tau = tauVctr
        *calDatabase[idx].eff = effVctr
        *calDatabase[idx].tsys = tsys
        *calDatabase[idx].flux = fluxVctr

        ; Be a good boy and clean up memory
        data_free,pos0calOn & data_free,pos0calOff
        data_free,pos1calOn & data_free,pos1calOff
        data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
      end
   end
end

;+
; Calculates Tcal,Tsys, ... from an on-off or nod (but not
; subreflector nod) observation of any receiver except Ka-band.
;
; <p>Assumes the system is linear (Pwr_in = B*Pwr_out).
;
; <p>Source fluxes are calculated in getFluxCalib for every channel.
; The routine uses the Ott et al polynomials coefficients for the
; fluxes of the 'standard' calibrators. Modify this routine when using
; frequencies outside the Ott fitting range or using a source not in
; the Ott catalog. 
;
; <p>Modify getApEff and getTau if you want a frequency-dependent
; efficiency or opacity.  getAppEff also allows for an elevation
; dependent efficiency. 
;
; <p>Results are stored in the calCommon common block.  The index
; entry is encoded as:
; <pre>
;    idx = ifnum + 8*plnum + 16*fdnum
; </pre>
;
; <p>The algorithm used is:
; <pre>
;    Scal = exp(-Tau*AirMass)*Flux*(Ref_CalOn - Ref_CalOff)/(Sig_CalOff - Ref_CalOff1)
;    Tcal = 2.8 * ap_eff * Scal
;    Tsys = Tcal * Ref_CalOff / (Ref_CalOn - Ref_CalOff)
; </pre>
;
; @param scan1 {in}{required}{type=integer} on-source scan number
; @param scan2 {in}{required}{type=integer} off-source scan number
; @keyword ifnum {in}{optional}{type=integer} I.F. number as used in
; standard "get" commands.  Defaults to zero.
; @keyword plnum {in}{optional}{type=integer} polarization number as
; used in standard "get" commands.  Defaults to zero.
; @keyword fdnum {in}{optional}{type=integer} feed number as used in
; standard "get" commands.  Defaults to zero.
; @keyword tau {in}{optional}{type=float} vector that encodes as
; polynomial coefficients the opacity at the zenith in nepers.  If not
; supplied, will assume the value returned by getTau.  See the
; documentation for getTau for the format of the vector.
; @keyword ap_eff {in}{optional}{type=float} 1 or 2-element vector
; that encodes aperture efficiency and it's frequency dependency.  If
; not supplied, will assume the value returned by getApEff .  See the
; documentation for getApEff for the format of the vector.
; @keyword smth {in}{optional}{type=value} The amount to boxcar smooth
; the data in MHz.  Sometimes mandatory if the source is weak and using
; very narrow channels.  Default is no smoothing
; @keyword src {in}{optional}{type=string} An optional string that
; allows one to override the source names used in the observations
; @keyword flux {in}{optional}{type=flux} An optional 1, 2, or
; 3-element vector that encodes the flux of the calibrator and
; it's frequency dependency.  See the documentation for
; getFluxCalib for the format of the vector.  If not supplied, the
; routine will attempt to use getFluxCalib internal database of fluxes
; for standard calibrator.s
; @keyword specindex {in}{optional}{type=specindex} An optional
; spectral index for the source.  Will be used only if flux is also
; given and only if flux is a single-element.
;
; @examples 
; getscal,211,212,ifnum=1,plnum=0,tau=[0.034],smth=1,src='3C48'
;
;-
pro scal,scan1,scan2,ifnum=ifnum,plnum=plnum,fdnum=fdnum,tau=tau,$
            ap_eff=ap_eff,smth=smth,src=src,flux=flux,specindex=specindex

    common calCommon, calDatabase

    ; default values for unsupplied arguments
    if (n_elements(ifnum) eq 0) then ifnum = 0
    if (n_elements(plnum) eq 0) then plnum = 0
    if (n_elements(fdnum) eq 0) then fdnum = 0

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     sampler = whichsampler(scan1,ifnum,plnum,fdnum)

    accumclear, calOnAccum
    accumclear, calOffAccum
    accumclear, pos0Accum
    accumclear, pos1Accum
         
    ; Average records for all 4 combinations of scan1/2, cal On/off
     pos0calOn = getchunk(count=count,scan=scan1,sig='T',sampler=sampler,cal='T')
     for i=0, (count-1) do begin
         dcaccum,calOnAccum,pos0calOn[i],weight=1
         dcaccum,pos0Accum,pos0calOn[i],weight=1
     end
     pos0calOff = getchunk(count=count,scan=scan1,sig='T',sampler=sampler,cal='F')
     for i=0, (count-1) do begin
         dcaccum,calOffAccum,pos0calOff[i],weight=1
         dcaccum,pos0Accum,pos0calOff[i],weight=1
     end
     pos1calOn = getchunk(count=count,scan=scan2,sig='T',sampler=sampler,cal='T')
     for i=0, (count-1) do begin
         dcaccum,calOnAccum,pos1calOn[i],weight=1
         dcaccum,pos1Accum,pos1calOn[i],weight=1
     end
     pos1calOff = getchunk(count=count,scan=scan2,sig='T',sampler=sampler,cal='F')
     for i=0, (count-1) do begin
         dcaccum,calOffAccum,pos1calOff[i],weight=1
         dcaccum,pos1Accum,pos1calOff[i],weight=1
     end

    ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
    accumave,calOnAccum, cOn, /quiet
    accumave,calOffAccum, cOff, /quiet
    accumave,pos0Accum, p0, /quiet
    accumave,pos1Accum, p1, /quiet

    ; Use elevation, etc from the scan's mid point
    mid = count/2

    ; Determine if smoothing is to be done and by how much
    nbox=1
    if (n_elements(smth) ne 0) then begin
        nbox=floor(abs(smth/(pos0calOff[mid].frequency_interval/1.e6))+0.5)
    endif

    ; Retrieve elevation and source name, if not supplied as an argument
    elev=pos0calOff[mid].elevation
    if (n_elements(src) eq 0) then src = pos0calOff[mid].source
            
    ; freqs contains a vector of frequencies
    ; fluxVctr contains a vector of source fluxes
    ; tauVctr contains a vector of opacities
    ; effVctr contains vector of efficiencies

    num_chan = n_elements(*pos0calOff[mid].data_ptr)
    freqs = chantofreq(pos0calOff[mid],seq(0,num_chan-1))/1.e6

    if (n_elements(flux) ne 0) then begin
        fluxVctr = getFluxCalib(src,freqs,coeffs=flux)
    endif else begin
        fluxVctr = getFluxCalib(src,freqs,specindex=specindex)
    endelse
    tauVctr = getTau(freqs, coeffs=tau)
    effVctr = getApEff(elev, freqs, coeffs=ap_eff)

    delAirMass = AirMass(pos1calOff[mid].elevation)-AirMass(elev)
    cfactor = tauVctr*delAirMass*(quickTatm(freqs, pos1calOff[mid].tambient) - 2.7)

    scaleFactor = (2.8 * effVctr * fluxVctr - cfactor) * exp(-tauVctr*AirMass(elev))

    tcals = scaleFactor * (*con.data_ptr - *coff.data_ptr) / (*p0.data_ptr - *p1.data_ptr)
    tsys = tcals * *p1.data_ptr / (*con.data_ptr - *coff.data_ptr)
    if (nbox gt 1) then begin
        tcals = doboxcar1d(tcals,nbox,/nan,/edge_truncate)
        tsys = doboxcar1d(tsys,nbox,/nan,/edge_truncate)
    endif

    ; idx only works as a way to index Spectrometer/SP data for upto 2 pols and 2 feeds.  
    ; May not work for future backends or receivers
    idx = ifnum + 8*plnum + 16*fdnum

    nchan = n_elements(freqs)
    n1 = floor(0.1*nchan)
    n2 = floor(0.9*nchan)
    print, idx, mean(tcals[n1:n2],/nan), mean(effVctr[n1:n2],/nan), mean(fluxVctr[n1:n2],/nan), mean(tauVctr[n1:n2],/nan), mean(tsys[n1:n2],/nan), nbox

    ; Store results into the common block database
    calDatabase[idx].sampler = sampler
    *calDatabase[idx].freqs = freqs
    *calDatabase[idx].tcals = tcals
    *calDatabase[idx].tau = tauVctr
    *calDatabase[idx].eff = effVctr
    *calDatabase[idx].tsys = tsys
    *calDatabase[idx].flux = fluxVctr

    ; Be a good boy and clean up memory
    data_free,pos0calOn & data_free,pos0calOff
    data_free,pos1calOn & data_free,pos1calOff
    data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
end

;+
; Calculates Tcal, Tsys, ...  from a subreflector nodding observations
; for all dual beam receivers *except* Ka-band.  
;
; <p>Assumes the system is linear (Pwr_in = B*Pwr_out).
;
; <p>Source fluxes are calculated in getFluxCalib for every channel.
; The routine uses the Ott et al polynomials coefficients for the
; fluxes of the 'standard' calibrators. Modify this routine when using
; frequencies outside the Ott fitting range or using a source not in
; the Ott catalog.
;
; <p>Modify getApEff and getTau if you want a frequency-dependent
; efficiency or opacity. getAppEff also allows for an elevation
; dependent efficiency. 
;
; <p>Results are stored in the calCommon common block.  The index
; entry is encoded as:
; <pre>
;    idx = ifnum + 8*plnum + 16*s
; </pre>
; where s = 0 or 1 for the two possible states of the subreflector
;
; <p>The algorithm used is:
; <pre>
;    Scal = exp(-Tau*AirMass)*Flux*(CalOn - CalOff)/(SubrPos0 - SubrPos1)
;    Tcal = 2.8 * ap_eff * Scal
;    Tsys = Tcal * Ref_CalOff / (Ref_CalOn - Ref_CalOff)
; </pre>
;
; @param scan {in}{required}{type=integer} Scan number to process
; @keyword  ifnum {in}{optional}{type=integer} ifnum as used on
; standard "get" commands
; @keyword  plnum {in}{optional}{type=integer} plnum as used on
; standard get" commands
; @keyword tau {in}{optional}{type=float} vector that encodes as
; polynomial coefficients the opacity at the zenith in nepers.  If not
; supplied, will assume the value returned by getTau.  See the
; documentation for getTau for the format of the vector.
; @keyword ap_eff {in}{optional}{type=float} 1 or 2-element vector
; that encodes aperture efficiency and it's frequency dependency.  If
; not supplied, will assume the value returned by getApEff .  See the
; documentation for getApEff for the format of the vector.
; @keyword smth {in}{optional}{type=value} The amount to boxcar smooth
; the data in MHz.  Sometimes mandatory if the source is weak and using
; very narrow channels.  Default is no smoothing
; @keyword src {in}{optional}{type=string} An optional string that
; allows one to override the source names used in the observations
; @keyword flux {in}{optional}{type=flux} An optional 1, 2, or
; 3-element vector that encodes the flux of the calibrator and
; it's frequency dependency.  See the documentation for
; getFluxCalib for the format of the vector.  If not supplied, the
; routine will attempt to use getFluxCalib internal database of fluxes
; for standard calibrator.s
; @keyword specindex {in}{optional}{type=specindex} An optional
; spectral index for the source.  Will be used only if flux is also
; given and only if flux is a single-element.
;
; @examples
; getscalSubrNod,211,ifnum=0,tau=[0.034],smth=1,src='3C48'
; getscalSubrNod,212
;
;-
pro scalSubrNod,scan,ifnum=ifnum,plnum=plnum,tau=tau,ap_eff=ap_eff,smth=smth,src=src,flux=flux,specindex=specindex

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(plnum) eq 0) then plnum = 0

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

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

         ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         ; No need to calculate freqs, taus, etc for every phase since these are
         ; identical for all phases
         if (s eq 0) then begin

            ; Use elevation, etc from the scan's mid point
            mid = count/2

            ; Determine if smoothing is to be done and by how much
            nbox=1
            if (n_elements(smth) ne 0) then begin
                nbox=floor(abs(smth/(pos0calOff[mid].frequency_interval/1.e6))+0.5)
            endif

            ; Retrieve elevation and source name, if not supplied as an argument
            elev=pos0calOff[mid].elevation
            if (n_elements(src) eq 0) then src = pos0calOff[mid].source
            
            ; freqs contains a vector of frequencies
            ; fluxVctr contains a vector of source fluxes
            ; tauVctr contains a vector of opacities
            ; effVctr contains vector of efficiencies

            num_chan = n_elements(*pos0calOff[mid].data_ptr)
            freqs = chantofreq(pos0calOff[mid],seq(0,num_chan-1))/1.e6
            if (n_elements(flux) ne 0) then begin
                fluxVctr = getFluxCalib(src,freqs,coeffs=flux)
            endif else begin
                fluxVctr = getFluxCalib(src,freqs,specindex=specindex)
            endelse
            tauVctr = getTau(freqs, coeffs=tau)
            effVctr = getApEff(elev, freqs, coeffs=ap_eff)

            scaleFactor = 2.8 * effVctr * fluxVctr * exp(-tauVctr*AirMass(elev))

         endif
         
         ; Flip sense for the correct phases
         if (s eq 0) then begin
            tcals = scaleFactor * (*con.data_ptr - *coff.data_ptr) / (*p1.data_ptr - *p0.data_ptr)
            tsys = tcals * *p0.data_ptr / (*con.data_ptr - *coff.data_ptr)
        endif else begin
            tcals = scaleFactor * (*con.data_ptr - *coff.data_ptr) / (*p0.data_ptr - *p1.data_ptr)
            tsys = tcals * *p1.data_ptr / (*con.data_ptr - *coff.data_ptr)
        endelse

        ; smooth
        if (nbox gt 1) then begin
            tcals = doboxcar1d(tcals,nbox,/nan,/edge_truncate)
            tsys = doboxcar1d(tsys,nbox,/nan,/edge_truncate)
        endif

        ; idx only works as a way to index Spectrometer/SP data.  May not work for future backends
        idx = ifnum + 8*plnum + 16*s

        ; summarize central 90%
        nchan = n_elements(freqs)
        n1 = floor(0.1*nchan)
        n2 = floor(0.9*nchan)
        print, idx, mean(tcals[n1:n2],/nan), mean(effVctr[n1:n2],/nan), mean(fluxVctr[n1:n2],/nan), mean(tauVctr[n1:n2],/nan), mean(tsys[n1:n2],/nan), nbox

        ; Store results into the common block database
        calDatabase[idx].sampler = sampler[s]
        *calDatabase[idx].freqs = freqs
        *calDatabase[idx].tcals = tcals
        *calDatabase[idx].tau = tauVctr
        *calDatabase[idx].eff = effVctr
        *calDatabase[idx].tsys = tsys
        *calDatabase[idx].flux = fluxVctr

        ; Be a good boy and clean up memory
        data_free,pos0calOn & data_free,pos0calOff
        data_free,pos1calOn & data_free,pos1calOff
        data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
   end
end
