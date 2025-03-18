;+
; Find the sampler name which corresponds to the given if, feed, and
; polarization numbers in the scan.  This value is the same as the
; sampler_name in the data containers associated with that if, feed,
; and polarization numbers in the scan.
;
; <p>A single value is always returned.  If the same scan
; appears more than once in the data file then a value corresponding
; to instance will be returned.  If instance is not used then the
; value corresponding to the first instance (instances=0) will be
; returned.  The instance and file keywords can be used to ensure 
; that a single scan is used.  Alternatively, the timestamp keyword
; can be used to ensure that a single scan is used (scan and instance
; are ignored in that case).
;
; <p>If the requested combination of if, feed, and polarization
; numbers is not found in the scan, the returned value is an empty
; string.
;
; @param scan {in}{required}{type=integer} scan number
; @param ifnum {in}{required}{type=integer} IF number
; @param plnum {in}{required}{type=integer} polarization number
; @param fdnum {in}{required}{type=integer} feed number
; @keyword instance {in}{optional}{type=integer} Which occurence
; of this scan should be used.  Default is 0.
; @keyword file {in}{optional}{type=string} When specified, limit the search 
; for this scan (and instance) to this specific file.  Default is all files.
; @keyword timestamp {in}{optional}{type=string} The M&C timestamp associated
; with the desired scan. When supplied, scan and instance are ignored.
; @keyword quiet {in}{optional}{type=boolean} When set, suppress most
; error messages.  Useful when being used within another procedure.
; @returns sampler name
;
;
; @version $Id$
;-
function whichsampler, scan, ifnum, plnum, fdnum, instance=instance,$
                       file=file,timestamp=timestamp,quiet=quiet
    compile_opt idl2

    result = ''

    if n_params() ne 4 then begin
        usage,'whichsampler'
        return, result
    endif

    if n_elements(timestamp) gt 0 then begin
        if n_elements(timestamp) gt 1 then begin
            if not keyword_set(quiet) then message,'only one timestamp can be specified',level=-1,/info
            return,result
        endif
        ; first, find out if this timestamp happens at all
        recs = select_data(!g.lineio,count=count,timestamp=timestamp,file=file)
        if count le 0 then begin
            if n_elements(file) gt 0 then begin
                if not keyword_set(quiet) then message,'No data having that timestamp is available in file='+file,level=-1,/info
            endif else begin
                if not keyword_set(quiet) then message,'No data having that timestamp is available.',level=-1,/info
            endelse
            return,result
        endif 
        ; okay to use
        thisTimestamp = timestamp
    endif else begin
        if n_elements(scan) gt 1 then begin
            if not keyword_set(quiet) then message,'only one scan can be specified',level=-1,/info
            return,result
        endif
        ; first, find out if this scan happens at all
        info = scan_info(scan,file,count=count,/quiet)
        if count le 0 then begin
            if n_elements(file) gt 0 then begin
                if not keyword_set(quiet) then message,'That scan is not available in file='+file,level=-1,/info
            endif else begin
                if not keyword_set(quiet) then message,'That scan is not available.',level=-1,/info
            endelse
            return,result
        endif
        if n_elements(instance) gt 0 then begin
            if instance ge count then begin
                if not keyword_set(quiet) then message,'Requested instance does not exist, it must be < '+strtrim(count,2),level=-1,/info
                return,result
            endif
            info = info[instance]
        endif else begin
            if count gt 1 then begin
                if not keyword_set(quiet) then message,'More than one scan found, using the first one (instance=0)',level=-1,/info
            endif
            info=info[0]
        endelse
        thisTimestamp = info.timestamp
    endelse

    ; now, do the full selection using an appropriate timestamp
    recs = select_data(!g.lineio,count=count,timestamp=thisTimestamp,file=file,ifnum=ifnum,plnum=plnum,fdnum=fdnum)
    if count le 0 then begin
        if not keyword_set(quiet) then message,'No data with those index numbers can be found',level=-1,/info
        return,result
    endif

    ; get the SAMPLER_NAMEs
    samplerNames = !g.lineio->get_index_values('SAMPLER',index=recs)
    sortNames = samplerNames[sort(samplerNames)]
    if n_elements(uniq(sortNames)) gt 1 and not keyword_set(quiet) then begin
        uniqNames = sortNames[uniq(sortNames)]
        message,'More than one sampler found, this should never happen',level=-1,/info
        message,string('Returning first sampler found.  Full list is : ', uniqNames),level=-1,/info
    endif

    return, samplerNames[0]
end
