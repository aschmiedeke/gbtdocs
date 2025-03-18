;+
; Generate flag table entries using QuadrantDetector columns in the
; associated SDFITS file (QD_XEL, QD_EL, and QD_BAD).
;
; <p>A flag table entry is made for an integration within a scan as
; follows:
; <ul><li> If QD_BAD is 0, flag the data based on the threshold value
; <li> If QD_BAD is 1 or -1 (all possible values other than 0), flag
; the data if the flag_qd_bad keyword is set otherwise (the default)
; do not flag the data.
; </ul>
;
; <p> Data which pass the QD_BAD test should be flagged for that
; integration if 
; <pre>
;   (ABS(QD_XEL) / HPBW) > thresh
;   HPBW = 740 / (observed_frequency in GHz)
; </pre>
; Where the units of QD_XEL and HPBW in the above are arcseconds and thresh
; defaults to 0.2 if not specified.
;
; <p>The idstring value is used to tag all flag table entries written by
; this routine.  If not supplied it defaults to QD_BADDATA.
;
; <p>This procedure will not reflag any scan where any flag entries
; already exist with the same idstring.  If you want to regenerate the
; flag table (e.g. using a different threshold or flag_qd_bad value)
; choose a different idstring or remove all existing flags with that
; idstring using the <a href="unflag.html">unflag</a> procedure.
;
; <p>This uses the main data file unless the keep keyword is set, in
; which case it uses the keep file.
;
; <p>This only works on spectral line data.
;
; <p>On completion, a table is printed giving the following statistics
; for each unique source name encountered: the total time observed for
; that source (this is the duration, not the exposure), the total time
; flagged, the percent flagged, and the percent of data that had a
; non-zero QD_BAD value.
;
; <p>For older SDFITS files that lack the QD columns, this routine
; prints a warning message without flagging any data.
;
; @param scans {in}{required}{type=integer} The scan number(s) to
; flag.  If not supplied, use all scans.  This can be vector of scan
; numbers
; @keyword thresh {in}{optional}{type=float}{default=0.2} The threshold
; to use when flagging using good QD_XEL values.  Defaults to 0.2.
; @keyword idstring {in}{optional}{type=string}{default="QD_BADDATA"}
; The tag to give each flag entry written by this routine.  Defaults
; to "QD_BADDATA".
; @keyword flag_qd_bad {in}{optional}{type=boolean} If set, flag all
; data having non-zero values of QD_BAD, otherwise data with QD_BAD is
; not flagged.
; @keyword keep {in}{optional}{type=boolean} If set, flag using the 
; keep file, otherwise use the default data file.
;
; @version $Id$
;-
pro qdflag, scans, thresh=thresh, idstring=idstring, flag_qd_bad=flag_qd_bad, keep=keep
  compile_opt idl2

  on_error,2

  ; must be in spectral line mode
  if not !g.line then begin
     message,'This does not work in continuum mode, sorry.', level=-1, /info
     return
  endif

  ; defaults
  thisThresh = 0.2
  flagString = "QD_BAD"

  if n_elements(thresh) gt 0 then begin
     thisThresh = float(thresh[0])
  endif

  if n_elements(idstring) gt 0 then begin
     flagString = idstring[0]
  endif

  doFlagBadQD = keyword_set(flag_qd_bad)
     
  scanNos = get_scan_numbers(count,/unique,keep=keep)

  if count le 0 then begin
     message,'No data found.',level=-1,/info
     return
  endif

  scanCount = 0
  if n_elements(scans) eq 0 then begin
     doScans = scanNos
     scanCount = count
  endif else begin
     for i=0,(n_elements(scans)-1) do begin
        tmp = where(scanNos eq scans[i],count)
        if count gt 0 then begin
           if scanCount eq 0 then begin
              doScans = scans[i]
           endif else begin
              doScans = [doScans,scans[i]]
           endelse
           scanCount += 1
        endif
     endfor
  endelse
  if scanCount le 0 then begin
     message,'Requested scans not found.',level=-1,/info
  endif

  fio = !g.lineio
  if keyword_set(keep) then begin
     fio = !g.lineoutio
  endif

  stats = -1
  objects = -1

  for i=0,(scanCount-1) do begin
     thisScan = doScans[i]
     if fio->is_scan_flagged(thisScan,idstring=flagString) then continue
     qdCols = fio->get_columns(["QD_XEL","QD_BAD","DATE_OBS","TIMESTAMP","OBSFREQ","DURATION","OBJECT"],scan=thisScan)
     if size(qdCols,/type) ne 8 then continue
     if size(qdCols.missing,/type) eq 7 then begin
                                ; this means that some columns were
                                ; missing - no point in continuing
        return
     endif
     ; final sanity check, there should be just one unique TIMESTAMP
     if n_elements(uniq(qdCols.timestamp)) ne 1 then begin
        msg = String(thisScan,format="('Multiple scans exist with the same scan number, these scans cannot be flagged indepndently and are skipped here.  Scan number:',I6)")
        message,msg,level=-1,/info
        continue
     endif
     ; prepare to update stats on this object
     thisObject = qdCols.object[0]
     if size(objects,/type) ne 7 then begin
        objIndx = -1
     endif else begin
        objIndx = where(objects eq thisObject)
        objIndx = objIndx[0]
     endelse
     objTag = -1
     objLoc = -1

     if objIndx lt 0 then begin
        ; new object
        objStats = {object:thisObject,tDur:0.0,tFlag:0.0,tBadQD:0.0}
     endif else begin
                                ; this should be easier - damn
                                ; case-insensitive IDL, need to start
                                ; with character, inability to index
                                ; on a string variable - just the
                                ; integer associated with that tag.
        objTag = strupcase(strcompress('TAG'+string(objIndx),/remove_all))
        objLoc = where(tag_names(stats) eq objTag)
                                ; I've decided not to be
                                ; paranoid here and so will not verify that
                                ; loc is >= 0 and that the object
                                ; field found at that loc is thisObject
        objStats = stats.(objLoc)
     endelse
     ; find the unique timestamps - equivalent to integration numbers
     intIndexes = uniq(qdCols.date_obs,sort(qdCols.date_obs))
     ; find the min OBSFREQ to get max HPBW appropriate for this scan
     minObsfreqGHz = min(qdCols.obsfreq)/1.e9
     ; HPBW in degrees
     hpbw = 740./minObsfreqGHz/3600.0
     qd_xel = qdcols.qd_xel[intIndexes]
     qd_bad = qdcols.qd_bad[intIndexes]
     tdurs = qdcols.duration[intIndexes]
     ; convert durations to hours
     objStats.tDur += total(tdurs)/3600.0
     thisObject = qdcols.object[0]
     relXel = abs(qd_xel)/hpbw
     goodQDFlags = where((qd_bad eq 0) and (relXel gt thisThresh), goodFlagCount)
     badQDFlags = where(qd_bad ne 0, badFlagCount)
     if badFlagCount gt 0 then objStats.tBadQD += total(tdurs[badQDFlags])/3600.0
     ; need vector of integration numbers here
     if (goodFlagCount gt 0) or ((badFlagCount gt 0) and doFlagBadQD) then begin
        ; something needs to be flagged
        intNums = lindgen(n_elements(qd_xel))
        if goodFlagCount gt 0 then begin
           flag, thisScan, intnum=intNums[goodQDFlags], idstring=flagString, keep=keep
           objStats.tFlag += total(tdurs[goodQDFlags])/3600.0
        endif
        if (badFlagCount gt 0) and doFlagBadQD then begin
           flag, thisScan, intNum=intNums[badQDFlags], idstring=flagString, keep=keep
           objStats.tFlag += total(tdurs[badQDFlags])/3600.0
        endif
     endif
     ; add it into results structure
     if size(stats,/type) ne 8 then begin
        ; everything is new
        objects = [thisObject]
        objIndx = 0
        objTag = strupcase(strcompress('tag'+string(objIndx),/remove_all))
        stats = create_struct(objTag,objStats)
     endif else begin
        if objLoc eq -1 then begin
            ; new object
           objects = [objects,thisObject]
           objIndx = n_elements(objects)-1
           objTag = strupcase(strcompress('tag'+string(objIndx),/remove_all))
           stats = create_struct(stats,objTag,objStats)
        endif else begin
           ; replace
           stats.(objLoc) = objStats
        endelse
     endelse      
  endfor

  if size(stats,/type) eq 8 then begin
     tagList = tag_names(stats)
     ; totals
     tot_tDur = 0.0
     tot_tFlag = 0.0
     tot_tBadQD = 0.0
     print,'Target               Total Time  Time Flagged   Pct Flagged  Pct Bad QD'
     fmtString = "(a-20,f7.2,' hr',3x,f7.2,' hr',6x,f5.1,'% ',7x,f5.1,'%')"
     for i=0,n_elements(objects)-1 do begin
        objTag = strupcase(strcompress('tag'+string(i),/remove_all))
        objLoc = where(tagList eq objTag)
        objStats = stats.(objLoc[0])
        print,objects[i],objStats.tDur,objStats.tFlag,100.0*(objStats.tFlag/objStats.tDur),100.0*(objStats.tBadQD/objStats.tDur),$
              format=fmtString
        tot_tDur += objStats.tDur
        tot_tFlag += objStats.tFlag
        tot_tBadQD += objStats.tBadQD
     endfor
     print,'All',tot_tDur, tot_tFlag, 100.0*(tot_tFlag/tot_tDur), 100.0*(tot_tBadQD/tot_tDur), format=fmtString
  endif else begin
     message,'No data found.  Are the scans already flagged?',/info
  endelse
end
