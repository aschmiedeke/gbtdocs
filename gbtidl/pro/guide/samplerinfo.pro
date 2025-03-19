; docformat = 'rst'

;+
; Find the if, feed, and polarization numbers  which corresponds to the
; given sampler name in the scan.
;
; A three-element array is returned having the value
; (ifnum,plnum,fdnum) corresponding to the IF, feed, and polarization
; numbers associated with the given sampler name and scan.
;
; If the same scan appears more than once in the data file then the
; value corresponding to instance will be returned.  If instance is
; omitted, the first instance (instance=0) will be returned.
; The instance and file keywords can be used to ensure that a single
; scan is used.  Alternatively, the timestamp keyword can be used to
; ensure that a single scan is used (scan and instance are ignored in
; that case). 
;
; If the requested sampler is not found in the scan, the all values
; of the returned array will be -1.
;
; There is no check to make sure that there is just one
; (ifnum,plnum,fdnum) associated with the given sampler.  The values for
; the first matching sampler are returned.
;
; :Params: 
;   scan {in}{required}{type=integer} scan number
;   sampler {in}{required}{type=string} sampler name
; 
; :Keywords:
;   instance : in, optional, type=integer
;       Which occurence of this scan should be used. Default is 0.
;   file : in, optional, type=string
;       When specified, limit the search for this scan (and instance) to
;       this specific file.  Default is all files.
;   timestamp : in, optional, type=string
;       The M&C timestamp associated with the desired scan. When supplied,
;       scan and instance are ignored.
;   quiet : in, optional, type=boolean
;       When set, suppress most error messages.  Useful when being used
;       within another procedure.
;   recs : out, optional, type=integer array
;       This contains the records (index numbers) from this sampler in 
;       the indicated scan. This is useful when you want to fetch that 
;       data immediately using getchunk since that will not involve any 
;       further selection and hence will be faster.  This is used by all
;       of the get* calibration routines (which use get_calib_data, where 
;       the work is actually done).  If there is no matching data, this 
;       value will be -1.
; 
; :Returns:
;   array of [ifnum,plnum,fdnum]
;
;-
function samplerinfo, scan, sampler, instance=instance, $
                      file=file,timestamp=timestamp,quiet=quiet, $
                      recs=recs

    compile_opt idl2

    result = [-1,-1,-1]
    recs = -1

    if n_params() ne 2 then begin
        usage,'samplerinfo'
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
            recs=-1
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
            count = 0
            return,result
        endif
        if n_elements(instance) gt 0 then begin
            if instance ge count then begin
                if not keyword_set(quiet) then message,'Requested instance does not exist, it must be < '+strtrim(count,2),level=-1,/info
                count = 0
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
    if recs[0] ne -1 then begin
        ; start from recs, just select on sampler
        recs = select_data(!g.lineio,count=count,index=recs,sampler=sampler)
    endif else begin
        recs = select_data(!g.lineio,count=count,timestamp=thisTimestamp,file=file,sampler=sampler)
    endelse

    if count le 0 then begin
        if not keyword_set(quiet) then message,'No data with those index numbers can be found',level=-1,/info
        count=0
        recs = -1
        return,result
    endif

    ; get the FDNUM, IFNUM, PLNUM values
    fdNum = !g.lineio->get_index_values('FDNUM',index=recs[0])
    ifNum = !g.lineio->get_index_values('IFNUM',index=recs[0])
    plNum = !g.lineio->get_index_values('PLNUM',index=recs[0])

    return, [ifNum,plNum,fdNum]
end
