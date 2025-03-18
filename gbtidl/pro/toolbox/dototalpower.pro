;+
; This procedure calibrates a single integration from a total power
; scan.
;
; <p>The result is the average of the data in the two data
; containers:
; <pre>
;     (*result.data_ptr) = (*sig_off.data_ptr + *sig_on.data_ptr)/2.0
; </pre>
;  The tsys in the result is meanTsys as calculated by
; <a href="../toolbox/dcmeantsys.html">dcmeantsys</a>.  The
; integration and exposure times in the result are the sum of those
; two times from each data container. All other header parameters in
; the result are copies of their values in the sig_off 
; spectrum.  dcmeantsys uses the mean_tcal value found in the sig_off
; data container unless the user supplies a tcal value using the tcal
; keyword.  The mean_tcal value in result will reflect the actual
; tcal value used (as resuted by dcmeantsys).
;
; <p>This simple routine is designed to be called from a more
; complicated routine like gettp.  This does not check the arguments
; for consistency or type.
;
; <p>It is the responsibility of the caller to ensure that result
; is freed using <a href="data_free.html">data_free</a>
; when it is no longer needed (i.e. at the end of all anticipated calls
; to this function before returning to the calling level).  Failure to
; do that will result in memory leaks.  It is not necessary to free
; these data containers between consecutive calls to this function at
; the same IDL level (e.g. inside the same procedure).
;
; @param result {out}{required}{type=spectrum} The result as described
; above.
; @param sig_off {in}{out}{required}{type=spectrum} An uncalibrated
; spectrum with no cal signal.
; @param sig_on {in}{required}{type=spectrum} An uncalibrated
; spectrum with a cal signal.
; @keyword tcal {in}{optional}{type=float} A scalar value for the cal
; temperature (K).  If not supplied. sig_off.mean_tcal will be used.
;
; @version $Id$
;-
pro dototalpower,result,sig_off,sig_on,tcal=tcal
    compile_opt idl2

    data_copy,sig_off,result
    result.tsys = dcmeantsys(sig_off,sig_on,tcal=tcal,used_tcal=used_tcal)
    result.mean_tcal = used_tcal
    ; ignore float underflows
    
    oldExcept=!except
    !except=0
    *result.data_ptr = (*sig_off.data_ptr + *sig_on.data_ptr)/2.0
    ; clear them
    ret=check_math(mask=32)
    ; reset except state
    !except=oldExcept
    result.exposure = sig_off.exposure + sig_on.exposure
    result.duration = sig_off.duration + sig_on.duration

end
