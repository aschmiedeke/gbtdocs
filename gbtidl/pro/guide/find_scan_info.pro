;+
; Find a scan info from the current line filein matching the given scan,
; file, timestamp, and instance values.  The matching scan_info is
; returned.  See <a href="scan_info.html">scan_info</a> for more
; information on the returned structure.
;
; <p>This is used by all of the standard calibration routines to get
; the scan_info for the requested scan.  It is encapsulated here to
; make it easy to adapt and understand those calibration routines.
;
; If there was a problem, the return value will not be structure (it
; will be -1).
;
; Because this is designed to be called from another routine, any
; error messages are displayed using the prefix appropriate to the
; calling routine.
;
; @param scan {in}{required}{type=integer} Scan number to get
; information on.  This must be provided unless timestamp is provided.
; @keyword timestamp {in}{optional}{type=string} The M&C timestamp associated
; with the desired scan. When supplied, scan and instance are ignored.
; @keyword instance {in}{optional}{type=integer} Which occurence
; of this scan should be used.  Default is 0.
; @keyword file {in}{optional}{type=string} Limit the search for
; matching scans to a specific file.  If omitted, scans are found in
; all files currently opened through filein (a single file) or dirin
; (possibly multiple files).
; @returns A single scan_info structure.  Returns -1 if a match can
; not be found.
;
; @uses <a href="../toolbox/select_data.html">select_data</a>
; @uses <a href="scan_info.html">scan_info</a>
;
; @private_file
;
; @version $Id$
;-
function find_scan_info, scan, timestamp=timestamp, $
  instance=instance, file=file
    compile_opt idl2

    if n_elements(timestamp) gt 0 then begin
        if n_elements(timestamp) gt 1 then begin
            message,'only one timestamp can be specified',level=-1,/info
            return,-1
        endif
        recs = select_data(!g.lineio,count=count,timestamp=timestamp,file=file)
        if count le 0 then begin
            if n_elements(file) gt 0 then begin
                message,'No data having that timestamp is available in file='+file,level=-1,/info
            endif else begin
                message,'No data having that timestamp is available.',level=-1,/info
            endelse
            return,-1
        endif
        thisScan = !g.lineio->get_index_values('SCAN',index=recs[0])
        if n_elements(file) gt 0 then begin
            thisFile = !g.lineio->get_index_values('FILE',index=recs[0])
            info = scan_info(thisScan,thisFile,count=count)
        endif else begin
            info = scan_info(thisScan,count=count)
        endelse
        if count lt 0 then message,'Unexpectedly did not find a matching scan - this should never happen'
        theseTimes = info.timestamp
        thisInstance = where(theseTimes eq timestamp)
        if thisInstance lt 0 then $
          message,'Unexpectedly did not find matching timestamp in scan_info record - this should never happen'
        info = info[thisInstance]
    endif else begin
        info = scan_info(scan,file,count=count,/quiet)
        if count le 0 then begin
            if n_elements(file) gt 0 then begin
                message,'That scan is not available in file='+file,level=-1,/info
            endif else begin
                message,'That scan is not available.',level=-1,/info
            endelse
            return,-1
        endif
        if n_elements(instance) gt 0 then begin
            if instance ge count then begin
                message,'Requested instance does not exist, it must be < '+strtrim(count,2),level=-1,/info
                return,-1
            endif
            info = info[instance]
        endif else begin
            if count gt 1 then begin
                message,'More than one scan found, using the first one (instance=0)',level=-1,/info
            endif
            info = info[0]
        endelse
    endelse

    return,info
end
