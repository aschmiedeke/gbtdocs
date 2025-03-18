;+
; Add some data into an accum_struct.  Not intended for use by general
; users.
; 
; <ul><li>The data is : sum(wt*data)
; <li>The times are :  sum(teff), sum(tint)
; <li>The wt is : sum(wt)
; <li>The tsys_sq is :  sqrt(sum(max(wt)*Tsys^2))
; <li>The frequency resolution is the maximum of all f_res values used
; during the accumulation.
; </ul>
;
; <p>f_delt is used as a check to see if the channel spacing matches
; the ongoing average.  A check on f_res is also done.  These warning 
; messages can be supressed by setting the /quiet flag.  The warning 
; message is issued if the two values do not agree to within
; f_delt/nchan.
;
; <p>If a weight (wt) is not supplied, it will be teff*f_res/Tsys^2
;
; <p>wt can either be a scalar or it can be a vector having the same
; number of elements as data.
;
; <p>If all of data is blanked (not a number) then it is complete
; ignored and the accumulated weight, times, and system temperatures
; are unchanged.  If individual regions are blanked - the weight at
; those channels is 0.  When an average is requested (accumave) this
; weight array is used to rescale the data.  That weight array is also
; available when the average is requested.  If that weight array is
; used as input in a future average, the averaging can continue from
; the same point as before.
;
; <p>If all of the weight values (supplied or the default value as
; described above) are not finite (not a number) this routine behaves
; as if the data are blanked and the data are ignored and the
; accumulated values are unchanged.
;
; <p>If the Tsys value is not finite (not a number) but the
; weights and data are at least partially finite, then the Tsys value
; is ignored in the ongoing weighted Tsys^2 accumulation.  The
; weights used in the Tsys^2 accumulation are kept separate from the
; data weights.
;
; @param accumbuf {in}{required}{type=accum_struct structure} The
; structure to hold the results of this accumlation. Care must be
; taken if this is !g.accumbuf.  Simply passing it in will not work
; because global values are passed by value not reference.  See
; the code in accum.pro for an example of how to use this in that case.
;
; @param data {in}{required}{type=float array} The data to add to the
; accumulation structure.  It must have the same number of elements as
; the ongoing accumulation (if this is not the first one added in).
;
; @param teff {in}{optional}{type=float} Effective integration time
; (s).
; 
; @param tsys {in}{required}{type=float} System temperature (K).
;
; @param f_res {in}{required}{type=float} Frequency resolution (Hz).
; This is usually not the same as the channel spacing.  It is always
; positive.  
;
; @param tint {in}{required}{type=float} Integration time (s).  Time spent
; taking data, including blanking time (duration).  If not supplied,
; teff will be used.
;
; @param f_delt {in}{required}{type=float} Channel spacing.
;
; @keyword wt {in}{optional}{type=float} Weight to give this data.
;
; @keyword quiet {in}{optional}{type=boolean} If set, suppress warning
; messages about f_res and f_delt not matching values in accumbuf.
;
; @private
;
; @version $Id$ 
;-
PRO accumulate, accumbuf, data, teff, tsys, f_res, tint, f_delt, wt=wt, $
                quiet=quiet
    compile_opt idl2

    if n_params() lt 7 then begin
        usage,'accumulate'
        return
    endif
    
    ; argument check
    if (tag_names(accumbuf,/structure_name) ne 'ACCUM_STRUCT') then begin
        message, 'accumbuf is not the right type of structure'
        return
    endif

    ; If all of this data is bad, ignore it completely
    finiteData = finite(data)
    if total(finiteData) eq 0 then begin
        return
    endif

    ; substitute defaults where necessary
    if (n_elements(tint) eq 0) then tint = teff

    ; early version of sdfits didn't have a DURATION, so it will be 0.0
    ; watch for teff=0.0, leads to zero weight
    if teff le 0.0 then begin
        message,'negative or zero EXPOSURE,  using 1s',/info
        teff = 1.0
    endif

    if tint lt teff then tint = teff

    tsys_sq = tsys^2
    if (n_elements(wt) eq 0) then begin
        localWt = teff * f_res / tsys_sq
    endif else begin
        localWt = wt
    endelse
    if (n_elements(localWt) gt 1 and n_elements(localWt) ne n_elements(data)) then begin
        message,'wt has more than 1 element but is not the same number of elements as data, can not continue'
        return
    endif

    if total(finite(localWt)) eq 0 then begin
       ; the weights are all NaN, ignore this entirely
       return
    endif

    wtData = localWt*data
    tsysWt = max(localWt)
    wtTsys_sq = tsysWt*tsys_sq
    if not finite(tsys_sq) then begin
       ; ignore Tsys when it's not finite (NaN)
       tsysWt = 0.0
       wtTsys_sq = 0.0
    endif

    if (accumbuf.n eq 0) then begin
        ; first one in, free data ptr as necessar
        if ptr_valid(accumbuf.data_ptr) then ptr_free,accumbuf.data_ptr
        accumbuf.data_ptr = ptr_new(wtData)
        if n_elements(localWt) eq 1 then begin
            wtArray = make_array(n_elements(wtData),/float,value=localWt)
        endif else begin
            wtArray = localWt
        endelse
        nanDataIndx = where(finite(data,/nan),nanCount)
        if nanCount gt 0 then wtArray[nanDataIndx] = 0.0
        accumbuf.wt_ptr = ptr_new(wtArray,/no_copy)
        accumbuf.teff = teff
        accumbuf.tint = tint
        accumbuf.f_res = f_res
        accumbuf.tsys_sq = wtTsys_sq
        accumbuf.tsys_wt = tsysWt
        accumbuf.f_delt = f_delt
        accumbuf.n = 1
    endif else begin
        ; require that the number of elements be the same
        if (n_elements(data) ne n_elements(*accumbuf.data_ptr)) then begin
            message, 'Number of elements in data differs from accum buf - nothing added to accumbuf',/info
            return
        endif
        
        if not keyword_set(quiet) then begin
            ftol = abs(f_delt)/n_elements(data)
            if abs(f_delt - accumbuf.f_delt) gt ftol then begin
                message, 'Warn: the channel_spacing is different from that in accumbuf',/info
            endif
            if abs(f_res - accumbuf.f_res) gt ftol then begin
                message, 'Warn: the frequency resolution is different from that in accumbuf.',/info
                message, '      Use gsmooth or dcsmooth to make the resolutions agree.',/info
            endif
        endif

        ; watch for blanked data 
        finiteAccum = finite(*accumbuf.data_ptr)
        bothOkIndx = where(finiteAccum and finiteData,count)
        if count gt 0 then begin
            (*accumbuf.data_ptr)[bothOkIndx] += wtData[bothOkIndx]
            (*accumbuf.wt_ptr)[bothOkIndx] += localWt
        endif
        onlyDataOkIndx = where(not finiteAccum and finiteData,count)
        if count gt 0 then begin
            (*accumbuf.data_ptr)[onlyDataOkIndx] = wtData[onlyDataOkIndx]
            (*accumbuf.wt_ptr)[onlyDataOkIndx] = localWt
        endif
        accumbuf.teff += teff
        accumbuf.tint += tint
        accumbuf.tsys_sq += wtTsys_sq
        accumbuf.tsys_wt += tsysWt
        if f_res gt accumbuf.f_res then accumbuf.f_res = f_res
        accumbuf.n += 1
    endelse
END
