;+
; This procedure calibrates a single integration from a frequency
; switched scan.
;
; <p>The expected 4 spectra that are used here are the signal with no
; cal, the signal with cal, the reference with no cal and the
; reference with cal.  
; 
; <ul><li><a href="dototalpower.html">dototalpower</a> is used to get
; the total power for the two signal spectra and for the two reference
; spectra.  
; <li>These are then combined using
; <a href="dosigref.html">dosigref</a> to get the calibrated results.
; <ul><li>sigresult is done using the signal total power as
; the "signal" and the reference total power as the "reference"
; <li>refresult is done using the reference reference total power as
; the "signal" and the signal total power as the "reference".
; </ul>
; <li>See dototalpower and dosigref for details about
; each step in the process of producing the two results.
; </ul>
;
; <p><a href="dcfold.html">dcfold</a> can then be used to combine
; sigresult and refresult to produce a folded result. That step does
; not happen here.
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
; <p>The units of sigresult and refresult are "Ta".  Use 
; <a href="dcsetunits.html">dcsetunits</a> to change these units to
; something else.
;
; <p>This is used primarily by <a href="../guide/getfs.html">getfs</a>
; and this code does almost no argument checks or sanity checks.  The
; calling routine is expected to check that the 4 input spectra are
; compatible (all are valid data containers and all have the same
; number of data points).
;
; <p>It is the responsibility of the caller to ensure that sigResult
; and refResult are freed using <a href="data_free.html">data_free</a>
; when their use is finished (i.e. at the end of all anticipated calls
; to this function before returning to the calling level).  Failure to
; do that will result in memory leaks.  It is not necessary to free
; these data containers between consecutive calls to this function at
; the same IDL level (e.g. inside the same procedure).
;
; @param sigwcal {in}{required}{type=spectrum} An uncalibrated
; spectrum from the signal phase with the cal on.
; @param sig {in}{required}{type=spectrum} An uncalibrated
; spectrum from the signal phase with the cal off.
; @param refwcal {in}{required}{type=spectrum} An uncalibrated
; spectrum from the reference phase with the cal on.
; @param smoothref {in}{optional}{type=integer} Boxcar smooth width
; for reference spectrum.  No smoothing if not supplied or if value is
; less than or equal to 1.
; @keyword tsys {in}{optional}{type=float} tsys at zenith, this is
; converted to a tsys at the observed elevation.  If not suppled, the
; tsys for each integration is calculated as described elsewhere.
; @keyword tau {in}{optional}{type=float} tau at zenith, if not
; supplied, it is estimated using <a href="../toolbox/get_tau.html">get_tau</a>
; tau is only used when the requested units are other than the default
; of Ta and when a user-supplied tsys value at zenith is to be used.
; @keyword sigResult {out}{required}{type=spectrum} The result when
; using the signal phases as "sig" in dosigref.
; @keyword refResult {out}{optional}{type=spectrum} This result when
; using the reference phases as "sig" in dosigref.
;
; @version $Id$
;-

pro dofreqswitch,sigwcal,sig,refwcal,ref,smoothref,$
                 tsys=tsys,tau=tau,tcal=tcal,sigResult=sigResult, refResult=refResult
    compile_opt idl2

    dototalpower,sigTP,sig,sigwcal,tcal=tcal
    dototalpower,refTP,ref,refwcal,tcal=tcal

    ; is there a user-supplied tsys
    if n_elements(tsys) eq 1 then begin
        ; correct this for elevation
        ; both data containers matter here
        if n_elements(tau) eq 0 then begin
            thistauRef = get_tau(refTP.observed_frequency/1.0e9)
            thistauSig = get_tau(sigTP.observed_frequency/1.0e9)
        endif else begin
            thistauRef = tau
            thistauSig = tau
        endelse
        refTP.tsys = tsys * exp(thistauRef/sin(refTP.elevation))
        sigTP.tsys = tsys * exp(thistauSig/sin(sigTP.elevation))
    endif

    dosigref,sigResult,sigTP,refTP,smoothref
    dosigref,refResult,refTP,sigTP,smoothref
    ; calculate freq_switch_offset - just use the
    ; difference at channel 0 - assumes both spectra have
    ; the same default frequency axis
    sigResult.freq_switch_offset = chanToFreq(refResult,0.d) - chanToFreq(sigResult,0.0d)
    sigResult.tsysref = refResult.tsys
    refResult.freq_switch_offset = chanToFreq(sigResult,0.d) - chanToFreq(refResult,0.0d)
    refResult.tsysref = sigResult.tsys
    data_free,sigTP
    data_free,refTP
end
