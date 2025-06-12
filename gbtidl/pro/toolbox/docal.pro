; docformat = 'rst'

;+
; This procedure gets the cal signal from a single cal-switched
; integration. 
;
; The result is the difference of the data in the two data
; containers:
; 
; .. code-block:: IDL
; 
;   (*result.data_ptr) = (*sig_on.data_ptr - *sig_off.data_ptr)/2.0
; 
; The tsys in the result is meanTsys as calculated by :idl:pro:`dcmeantsys`.
; The integration and exposure times in the result are the sum of those
; two times from each data container. All other header parameters in
; the result are copies of their values in the sig_off spectrum.  
; dcmeantsys uses the mean_tcal value found in the sig_off data container 
; unless the user supplies a tcal value using the tcal keyword. The 
; mean_tcal value in result will reflect the actual tcal value used (as 
; resulted by dcmeantsys).
;
; This simple routine is designed to be called from a more
; complicated routine like getcal.  This does not check the arguments
; for consistency or type.
;
; It is the responsibility of the caller to ensure that result
; is freed using :idl:pro:`data_free` when it is no longer needed (i.e. 
; at the end of all anticipated calls to this function before returning
; to the calling level). Failure to do that will result in memory leaks. 
; It is not necessary to free these data containers between consecutive 
; calls to this function at the same IDL level (e.g. inside the same 
; procedure).
;
; :Params:
;   result : out, required, type=spectrum
;       The result as described above.
;   sig_off : in, out, required, type=spectrum
;       An uncalibrated spectrum with no cal signal.
;   sig_on : in, required, type=spectrum
;       An uncalibrated spectrum with a cal signal.
;   
; :Keyword:
;   tcal : in, optional, type=float
;       A scalar value for the cal temperature (K). If not supplied. 
;       sig_off.mean_tcal will be used.
;
;-
pro docal,result,sig_off,sig_on,tcal=tcal
    compile_opt idl2

    data_copy,sig_off,result
    result.tsys = dcmeantsys(sig_off,sig_on,tcal=tcal,used_tcal=used_tcal)
    result.mean_tcal = used_tcal
    *result.data_ptr = (*sig_on.data_ptr - *sig_off.data_ptr)/2.0
    result.exposure = sig_off.exposure + sig_on.exposure
    result.duration = sig_off.duration + sig_on.duration

end
