;+
; Get the average from an ongoing accumulation. 
;
; <p>The dc argument will contain the result.  The wtarray keyword
; will contain the value of the weight array used at the time of the
; average.  This can be used in a subsequent dcaccum or accum
; call.
;
; <p>The contents of the accum buffer are cleared as a 
; consequence of calling accumave, unless the noclear keyword is set.
;
; <p>Note: It is a good idea to use <a href="accumclear.html">accumclear</a> 
; to clear the accum buffer before using it the first time so that
; you can be certain it is starting from a cleared (empty) state.
;
; <p>Note: The frequency_resolution in dc will be the maximum
; resolution in all of the data containers used in the accumulation.
;
; @param accumbuf {in}{out}{required}{type=accum_struct} The
; accumulation buffer to use.
;
; @param dc {out}{required}{type=spectrum} The resulting average.
;
; @keyword noclear {in}{optional}{type=boolean}{default=F} When set, the
; contents of the global accum buffer are not cleared.  This is useful
; when you want to see what the current average is but also plan on
; continuing to add data to that average.  If this is not set, you
; would need to restart the accumulation to average more data.
;
; @keyword quiet {in}{optional}{type=boolean}{default=F} Normally, accumave
; announces how many spectra were averaged.  Setting this turns that
; announcement off.  This is especially useful when multiple accum
; buffers are used within a procedure.
;
; @keyword wtarray {out}{optional}{type=float} Optionally return the
; weight array (same length as the data in the dc parameter) used in
; constucting the average.
; 
; @keyword count {out}{optional}{type=integer} The number of spectra
; that have been averaged.  Returns -1 on an error.  If count=0 then
; the other output arguments (dc and wtarray) are unchanged by this
; procedure.
;
; @examples
; <pre>
; a = {accum_struct}
; accumclear, a  ; not necessary here, but good practice
; get,index=1
; dcaccum, a, !g.s[0]
; get,index=2
; dcaccum, a, !g.s[0]
; accumave, a, myavg
; show, myavg
; data_free, myavg ; be sure and clean up when done
; ; or the same step at the end, but get the average
; ; note that the previous dcaccum etc. must be repeated here
; ; since accumave cleared the average
; accumave, a, myavg, wtarray=myweight
; show, myavg
; data_copy, myavg, mywt
; setdcdata, mywt, wtarray  ; put the weight array in a copy of the data
; show, mywt ; show the weight array
; ; clean up when done
; data_free, myavg
; data_free, mywt
; </pre>
;
; <p> Note: the accum_struct structure used here has internal
; pointers.  Use <a href="accumclear.html">sclear</a> to clear them,
; either implicitly (by use of accumave) or explicitly.
;
; @uses <a href="accumclear.html">accumclear</a>
; @uses <a href="data_copy.html">data_copy</a>
;
; @version $Id$
;-
pro accumave, accumbuf, dc, noclear=noclear, quiet=quiet, wtarray=wtarray, count=count
    compile_opt idl2

    on_error, 2

    if n_params() ne 2 then begin
        usage,'accumave'
        count = -1
        return
    endif

    if (size(accumbuf,/type) ne 8 or tag_names(accumbuf,/structure_name) ne "ACCUM_STRUCT") then begin
        message,"accumbuf is not an accum_struct structure",/info
        count = -1
        return
    endif

    count = accumbuf.n
    if (accumbuf.n ne 0) then begin
        wtarray = *accumbuf.wt_ptr
        *accumbuf.template.data_ptr = *accumbuf.data_ptr / wtarray
        accumbuf.template.duration = accumbuf.tint
        ; tsys_wt is usually max(wtarray) but may not be if 
        ; a Tsys=NaN was used and the normal weighting involving
        ; Tsys was not used.  In that case, the spectrum appears
        ; in the accumulation but Tsys does not contribute to the
        ; the tsys_sq sum.
        accumbuf.template.tsys = sqrt(accumbuf.tsys_sq / accumbuf.tsys_wt)
        ; final check, if tsys is not finite, replace it by 1.0
        if not finite(accumbuf.template.tsys) then begin
           accumbuf.template.tsys = 1.0
        endif
        accumbuf.template.exposure = accumbuf.teff
        accumbuf.template.frequency_resolution = accumbuf.f_res

        data_copy, accumbuf.template, dc

        if (not keyword_set(noclear)) then accumclear, accumbuf

        if not keyword_set(quiet) then message, 'Average of :' + string(count) + ' spectra',/info
    endif
end
