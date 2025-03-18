;+
; <p>
; This procedure simply runs the getps_v2 routine for both polarizations of a scan,
; plots the individual polarizations, and then averages the polarizations, leaving
; the average in the register (and plotting it, too, on the screen).
; eventually it should take both feeds into account, but that is for later.
; This procedure retrieves and calibrates a total power position switched scan pair,
; which is followed by a on+off observation of a noise diode.  If the third scan in 
; the sequence is not a noise diode observation, the users must give hte scan number
; for the noise diode observation, using the "cal=" option.
; The data must be taken with the "OnOff" or "OffOn" procedures.
; This procedure will reject data not taken with one of those two
; procedures. This code should
; be used as a template for the user who may wish to develop more sophisticated
; calibration schemes.  The routine produces a spectrum calibrated in
; Ta (K).  Other recognized units are 'Ta*' and 'Jy'.
; <p>
; The only required parameter is the scan number.  This can be either scan
; in the sequence of two total power scans, and the paired scan is determined
; from the header.  Arguments to identify the IF number,
; polarization number and feed number are optional.  
; The program calculates Tsys based on the Tcal values, and cal_on/cal_off observations.
; The user can override this calculation by entering a system temperature.
; The procedure will NOT correct the Tsys for the observed elevation.
; If the data are calibrated to Ta* or Jy, then additional parameters are used.
; A tau value may be specified, and an aperture efficiency may be specified.
; The user is *strongly* encouraged to enter values for these calibration parameters,
; but they will be estimated if none is provided.
; <p>
; A parameter called smthoff can be used to smooth the reference spectrum prior
; to calibration.  In certain cases this can improve the signal to noise ratio,
; but it may degrade baseline shapes and artificially emphasize spectrometer
; glitches.  Use with care.  A value of smthoff=16 is often a good choice.
; <p> 
; By default, internal averaging of integrations is weighted by Tsys.
; To give all integrations equal weight instead, use the /eqweight
; flag.
;
; <p>
; NOTE: the procedure assumes you are firing a high cal (preferred for this type of observation).
; if you are not, you must say so, as this information is NOT recorded in the sdfits files.
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
;
; @param scan {in}{required}{type=integer} M&C scan number
; @keyword ifnum {in}{optional}{type=integer} IF number (starting with 0)
; @keyword fdnum {in}{optional}{type=integer} feed number (default 0)
; @keyword tau {in}{optional}{type=float} tau at observed elevation
; @keyword itsys {in}{optional}{type=float} tsys at observed elevation
; @keyword ap_eff {in}{optional}{type=float} aperture efficiency
; @keyword smthoff {in}{optional}{type=integer} smooth factor for reference spectrum
; @keyword units {in}{optional}{type=string} takes the value 'Jy', 'Ta', or 'Ta*'
; @keyword eqweight {in}{optional}{type=flag} if set, the default
; weighting is turned off and all integrations are averaged with the
; same weight (1.0).
;
; @version $Id$
;
;-

pro getps_v2all,scan,ifnum=ifnum,fdnum=fdnum,tau=tau,itsys=itsys,ap_eff=ap_eff,smthoff=smthoff,$
	units=units,eqweight=eqweight,calscan=calscan,ifile=ifile,caltype=caltype
    compile_opt idl2

    if (n_elements(scan) eq 0) then begin
        message, 'The scan number is required', /info
        return
    endif

    if not !g.lineio->is_data_loaded() then begin
        message,'No line data is attached yet, use filein or dirin.',/info
        return
    endif
                                                                                
    ; set defaults
    if n_elements(ifnum) eq 0 then ifnum = 0
    if n_elements(fdnum) eq 0 then fdnum = 0
    if n_elements(itsys) eq 0 then itsys = 1
    if n_elements(smthoff) eq 0 then smthoff = 1
    if n_elements(units) eq 0 then units = 'Ta'
    if keyword_set(eqweight) then weight = 1.0 ; else undefined and use default weight
    if not(keyword_set(ifile)) then ifile='default'
    if not(keyword_set(calscan)) then calscan=scan+2
    if not(keyword_set(caltype)) then caltype="hi"

    if (ifile eq 'default') then info = scan_info(scan)

    ; Cycle through all polarizations:
    if (ifile ne 'default') then begin
        pols=!g.lineio->get_index_values('POLARIZATION',scan=scan,file=ifile)
        n_polarizations=n_elements(pols[uniq(pols)])
    endif else n_polarizations=info.n_polarizations
    for plnum=0,n_polarizations-1 do begin 
      if (plnum eq 0) then sclear,1
        tsys=itsys
	freeze
	getps_v2,scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,tau=tau,$
            tsys=tsys,ap_eff=ap_eff,smthoff=smthoff,units=units,eqweight=eqweight,$
            calscan=calscan,ifile=ifile,caltype=caltype
	unfreeze
      if (plnum eq 0) then show $
	else oshow,color=!green
      freeze
      accum,1
    endfor
    ave,1
    unfreeze
    oshow,color=!white
    unfreeze
end
