; docformat = 'rst'

;+
; This procedure calibrates a single integration from a Nod scan pair.
;
; An integration in each scan in a standard Nod scan pair contains
; data from two beams (b1 and b2 here).  And the data from each beam
; contains one spectrum with the cal on and one with no cal.  There
; are then 8 spectra to be combined here.  This assumes that data
; identified with scan 1 (s1) here has the signal data in beam 1 and
; the reference data in beam 2.  Then in scan 2 (s2) the reference
; data is beam 1 and the signal data is in beam 2.
;
; * Each cal on, cal off pair for a specific beam and scan are
;   combined using :idl:pro:`dototalpower` to
;   produce 4 spectra.  Each spectra also has a tsys associated with it.
; * The signal from scan 2 (the beam 2 data) is combined with the
;   reference from scan 1 (the beam 1 data) using :idl:pro:`dosigref`
; * The signal from scan 1(the beam 1 data) is combined with the
;   reference from scan 2 (the beam 2 data) also using dosigref.
; * These two calibrated spectra are combined using 
;   :idl:pro:`dcaccum` to produce the final calibrated
;   result.
; 
; See dototalpower and dosigref for details about each step.
;
; The returned tsys (ret_tsys) are the 4 system temperatures
; calculed in the first step (from dototalpower).  They are, in order,
; the system temperatures from scan 1 and beam 1 (signal in scan 1),
; scan 1 and beam 2 (reference in scan 1), scan 2 and beam 1
; (reference in scan 2) and scan 2 and beam 2 (signal in scan 2).
; The system temperature in the result is a weighted combination of
; the two reference system temperatures as described in dcaccum.
;
; The user can optionally over-ride the system
; temperatures calculated in dototalpower and used in dosigref by
; supplying a value for the tsys and tau keywords here.  tsys is the
; system temperate at tau=0.  If the user supplies this keyword, tsys
; is first adjusted to the elevation of the reference spectrum 
; :math:`tsys_used = tsys*exp(tau/sin(elevation)`.  
; 
; If tau is not supplied, then the :idl:pro:`get_tau`
; function is used, using the reference observed_frequency to arrive
; at a very rough guess as to the zenith opacity, tau.  Users are
; encouraged to supply tau when they also supply tsys to improve the
; accuracy of this calculation. The adjusted tsys then becomes the
; reference spectrum's tsys value for use in dosigref.  In that case,
; the returned tsys values are the corrected, user-supplied tsys
; values using the elevation from the appropriate scan.
;
; The units of result is "Ta".  Use :idl:pro:`dcsetunits` to change
; these units to something else.
;
; This is used primarily by :idl:pro:`getnod` and this code does almost
; no argument checks or sanity checks.  The calling routine is expected
; to check that the 8 input spectra are compatible (all are valid data 
; containers and all have the same number of data points).
;
; It is the responsibility of the caller to ensure that result is freed
; using :idl:pro:`DATA_FREE` when it is no longer needed (i.e. at the end
; of all anticipated calls to this function before returning to the
; calling level).  Failure to do that will result in memory leaks. It 
; is not necessary to free these data containers between consecutive 
; calls to this function at the same IDL level (e.g. inside the same
; procedure).
;
; :Params:
;   result : out, required, type=data container
;       This is the resulting data container.  
;   s1_b1_off: in, required, type=spectrum
;       An uncalibrated spectrum from feed 0 (source/tracking feed)
;       in scan 1 with the cal off.
;   s1_b1_on: in, required, type=spectrum
;       An uncalibrated spectrum from feed 0 (source/tracking feed) 
;       in scan 1 with the cal on.
;   s2_b1_off: in, required, type=spectrum 
;       An uncalibrated spectrum from feed 0 (reference/non-tracking feed)
;       in scan 2 with the cal off. 
;   s2_b1_on: in, required, type=spectrum
;       An uncalibrated spectrum from feed 0 (reference/non-tracking feed)
;       in scan 2 with the cal on.
;   s1_b2_off : in, required, type=spectrum
;       An uncalibrated spectrum from feed 1 (reference/non-tracking feed) 
;       in scan 1 with the cal off.
;   s1_b2_on : in, required, type=spectrum
;       An uncalibrated spectrum from feed 1 (reference/non-tracking feed) 
;       in scan 1 with the cal on.
;   s2_b2_off : in, required, type=spectrum 
;       An uncalibrated spectrum from feed 1 (source/tracking feed) in 
;       scan 2 with the cal off.
;   s2_b2_on : in, required, type=spectrum
;       An uncalibrated spectrum from feed 1 (source/tracking feed) in
;       scan 2 with the cal on.
;   smoothref : in, optional, type=integer 
;       Boxcar smooth width for reference spectrum. No smoothing if not 
;       supplied or if value is less than or equal to 1.
;   ret_tsys : out, optional, type=float
;       internal use
; 
; :Keywords:
;   avgref: in, optional, type=boolean
;       If set, then the off-signal terms (reference) are assumed to be 
;       already averaged and no total power processing of that data is 
;       done here.  These terms are s1_b2_off, s1_b2_on, s2_b1_off, and
;       s2_b1_on.  Of these 4 terms, only s1_b2_off and s2_b1_off are 
;       actually used when this keyword is set.   
;   tsys : in, optional, type=float
;       tsys at zenith, this is converted to a tsys at the observed elevation.
;       If not suppled, the tsys for each integration is calculated as described
;       elsewhere.
;   tau : in, optional, type=float
;       tau at zenith, if not supplied, it is estimated using :idl:pro:`get_tau`
;       tau is only used when the requested units are other than the default
;       of Ta and when a user-supplied tsys value at zenith is to be used.
;   tcal : in, optional, type=float
;       Cal temperature (K) to use in the Tsys calculation.  If not supplied,
;       the mean_tcal value from the header of the cal_off switching phase data
;       in each integration is used.  This must be a scalar, vector tcal is not 
;       yet supported.
;   eqweight : in, optional, type=boolean 
;       When set, average the two beams with equal weight, else use default 
;       weighting.
;   single_beam : out, optional, type=boolean
;       When set, one of the two beams was blanked. Useful for reporting back
;       to the user.
;
;-
pro donod,result,s1_b1_off,s1_b1_on,s2_b1_off,s2_b1_on,s1_b2_off,s1_b2_on,s2_b2_off,s2_b2_on,smoothref,$
          ret_tsys,avgref=avgref,tsys=tsys,tau=tau,tcal=tcal,eqweight=eqweight,single_beam=single_beam
    compile_opt idl2

    if keyword_set(eqweight) then weight=1.0
    single_beam = 0

    dototalpower,sigs1,s1_b1_off,s1_b1_on,tcal=tcal
    dototalpower,sigs2,s2_b2_off,s2_b2_on,tcal=tcal
    if keyword_set(avgref) then begin
       ; just make a copy, already total power
       data_copy, s1_b2_off, refs1
       data_copy, s2_b1_off, refs2
    endif else begin
       dototalpower,refs1,s1_b2_off,s1_b2_on,tcal=tcal
       dototalpower,refs2,s2_b1_off,s2_b1_on,tcal=tcal
    endelse

    ; is there a user-supplied tsys
    if n_elements(tsys) eq 1 then begin
        ; correct this for elevation
        if n_elements(tau) eq 0 then begin
            ; assume all data containers have the same
            ; observed_frequency
            thistau = get_tau(sigs1.observed_frequency/1.0e9)
        endif else begin
            thistau = tau
        endelse
        sigs1.tsys = tsys*exp(thistau/sin(sigs1.elevation*!pi/180.0))
        refs1.tsys = tsys*exp(thistau/sin(refs1.elevation*!pi/180.0))
        refs2.tsys = tsys*exp(thistau/sin(refs2.elevation*!pi/180.0))
        sigs2.tsys = tsys*exp(thistau/sin(sigs2.elevation*!pi/180.0))
    endif

    ret_tsys = [sigs1.tsys,refs1.tsys,refs2.tsys,sigs2.tsys]

    dosigref,calb1,sigs1,refs2,smoothref
    dosigref,calb2,sigs2,refs1,smoothref

    thisaccum = {accum_struct}
    dcaccum,thisaccum,calb1,weight=weight,/quiet
    dcaccum,thisaccum,calb2,weight=weight,/quiet
    if thisaccum.n le 0 then begin
        ; both results must have all blanked data.
        ; both should be all NaNs, set that in result
        data_copy, calb1, result
        accumclear,thisaccum
        return
    endif
    single_beam = thisaccum.n eq 1
    accumave,thisaccum,result,/quiet
    accumclear,thisaccum

    data_free, sigs1
    data_free, sigs2
    data_free, refs1
    data_free, refs2
    data_free, calb1
    data_free, calb2
end
