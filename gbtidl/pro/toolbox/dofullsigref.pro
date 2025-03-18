
;+
; This procedure calibrates a single integration using four different
; uncalibrated spectrum data containers.
;
; <p>One pair of data containers
; are from the signal (source) and the other pair are the reference
; set of data containers.  Within each pair, one spectrum has signal
; from the cal and the other does not.  
;
; <ul><li><a href="dototalpower.html">dototalpower</a> is used to get
; the total power in each pair (signal and reference).
; <li> These are then combined in <a href="dosigref.html">dosigref</a>
; to get the calibrated result.
; </ul>
;
; <p> See dototalpower and dosigref for details about each step.
;
; <p>The user can optionally over-ride the reference system
; temperature calculated in dototalpower and used in dosigref by
; supplying a value for the tsys and tau keywords here.  tsys is the
; system temperate at tau=0.  If the user supplies this keyword, tsys
; is first adjusted to the elevation of the reference spectrum : 
; <pre>
; tsys_used = tsys*exp(tau/sin(elevation).  
; </pre>
; If tau is not supplied, then the <a href="get_tau.html">get_tau</a>
; function is used, using the reference observed_frequency to arrive
; at a very rough guess as to the zenith opacity, tau.  Users are
; encouraged to supply tau when they also supply tsys to improve the
; accuracy of this calculation. The adjusted tsys then becomes the
; reference spectrum's tsys value for use in dosigref.
;
; <p>The units of result is "Ta".  Use 
; <a href="dcsetunits.html">dcsetunits</a> to change these units to
; something else.
;
; <p>This is used primarily by <a href="../guide/getsigref.html">getsigref</a>
; and this code does almost no argument checks or sanity checks.  The
; calling routine is expected to check that the 4 input spectra are
; compatible (all are valid data containers and all have the same
; number of data points).
;
; <p>It is the responsibility of the caller to ensure that result
; is freed using <a href="data_free.html">data_free</a>
; when it is no longer needed (i.e. at the end of all anticipated calls
; to this function before returning to the calling level).  Failure to
; do that will result in memory leaks.  It is not necessary to free
; these data containers between consecutive calls to this function at
; the same IDL level (e.g. inside the same procedure).
;
; @param result {out}{required}{type=spectrum} The resulting spectrum
; data container.
; @param sigwcal {in}{required}{type=spectrum} An uncalibrated
; spectrum from the signal scan with the cal on.
; @param sig {in}{required}{type=spectrum} An uncalibrated
; spectrum from signal scan with the cal off.
; @param refwcal {in}{required}{type=spectrum} An uncalibrated
; spectrum from reference scan with the cal on.
; @param ref {in}{required}{type=spectrum} An uncalibrated
; spectrum from reference scan with the cal off.
; @param smoothref {in}{optional}{type=integer} Boxcar smooth width
; for reference spectrum.  No smoothing if not supplied or if value is
; less than or equal to 1.
; @param avgref {in}{optional}{type=boolean} If set, then the refwcal;
; is assumed to already be the average ref scan and no total power
; processing of the ref data is done here.  The ref argument is unused
; in this case.
; @keyword signocal {in}{optional}{type=boolean} If set, then there
; is no CAL data for the sig state.  sigwcal argument is ignored, only
; the sig argument is used as is.
; @keyword tsys {in}{optional}{type=float} tsys at zenith, this is
; converted to a tsys at the observed elevation.  If not suppled, the
; tsys for each integration is calculated as described elsewhere.
; @keyword tau {in}{optional}{type=float} tau at zenith, if not
; supplied, it is estimated using <a href="../toolbox/get_tau.html">get_tau</a>
; tau is only used when the requested units are other than the default
; of Ta and when a user-supplied tsys value at zenith is to be used.
; @keyword tcal {in}{optional}{type=float} Cal temperature (K) to use
; in the Tsys calculation.  If not supplied, the mean_tcal value from
; the header of the cal_off switching phase data in each integration
; is used.  This must be a scalar, vector tcal is not yet supported.
; @keyword retsigtsys {out}{optional}{type=float} The reference Tsys
; used here.
; @keyword retsigtsys {out}{optional}{type=float} The signal Tsys
; calculated here. If tsys is supplied, then retsigtsys is equal to
; retreftsys.  The signal Tsys is not actually used, mearly calculated
; and reported back through this keyword.
;
; @version $Id$
;-
pro dofullsigref,result,sigwcal,sig,refwcal,ref,smoothref,avgref,signocal=signocal,$
                 tsys=tsys,tau=tau,tcal=tcal,retsigtsys=retsigtsys,retreftsys=retreftsys
    compile_opt idl2
    
    if keyword_set(signocal) then begin
       ; use sig as is, ignore sigwcal
       data_copy,sig,sigTP
    endif else begin
       dototalpower,sigTP,sig,sigwcal,tcal=tcal
    endelse
       ; just make a copy
    if keyword_set(avgref) then begin
        ; just make a copy, already TP
        data_copy,refwcal,refTP
    endif else begin
        dototalpower,refTP,ref,refwcal,tcal=tcal
    endelse

    ; is there a user-supplied tsys
    if n_elements(tsys) eq 1 then begin
        ; correct this for elevation
        ; the refTP is the data container that matters here
        if n_elements(tau) eq 0 then begin
            thistau = get_tau(refTP.observed_frequency/1.0e9)
        endif else begin
            thistau = tau
        endelse
        refTP.tsys = tsys * exp(thistau/sin(refTP.elevation))
        sigTP.tsys = refTP.tsys
    endif
    retreftsys = refTP.tsys
    retsigtsys = sigTP.tsys

    dosigref,result,sigTP,refTP,smoothref
    data_free, sigTP
    data_free, refTP
end
