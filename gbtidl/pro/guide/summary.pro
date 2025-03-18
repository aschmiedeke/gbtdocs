
;+
; This procedure lists a summary of the input dataset.  The listing
; can be sent to a file instead of directly to the current screen.
;
; <p>This is designed to work with un-calibrated GBT data and is
; likely to give confusing results for other data.  For other data,
; <a href="list.html">list</a> is usually more useful.
;
; <p><b>Note:</b> The numbers (nIF, nInt, nFd) are the number of unique
; values for each parameter (ifnum, intnum, fdnum) found for that
; scan.  All combinations of all possible values of ifnum, intnum,
; fdnum, and plnum may not be present in that scan.
;
; @param file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;
; @keyword bscan {in}{optional}{type=integer} The smallest scan number
; to summarize.  Scan numbers less than bscan are ignored.  When
; unspecified no scans are excluded by this keyword.
;
; @keyword escan {in}{optional}{type=integer} The largest scan number
; to summarize.  Scan numbers larger than escan are ignored.  When
; unspecified no scans are excluded by this keyword.
;
;
; @examples
; <pre>
;    filein,'myfile.fits'
;    summary
;       ; summarize the same output to a file instead of the screen
;    summary,'myfile.summary'
;       ; summarize starting from scan 14
;    summary, bscan=14
;       ; summarize through scan 24
;    summary, escan=24
;       ; summarize from scan 14 through scan 24
;    summary, bscan=14, escan=24
; </pre>
; 
;
; @version $Id$
;-

pro summary, file, bscan=bscan, escan=escan
    compile_opt idl2

    if not !g.line then begin
        message,'Summary is not available for continuum data, sorry.',/info
        return
    endif

    if !g.lineio->get_num_index_rows() le 0 then begin
        message,'No line data is attached yet, use filein or dirin.',/info
        return
     endif

    if n_elements(bscan) gt 1 or n_elements(escan) gt 1 then begin
       message,'bscan and escan must be single values',/info
       return
    endif

    smin = 0L
    if n_elements(bscan) eq 1 then smin = bscan
    smax = long(2LL^31-1)
    if n_elements(escan) eq 1 then smax = escan

    ; can we use more
    usemore = 0
    fileout=''
    if n_elements(file) eq 0 then begin
        if !g.interactive then begin
            usemore = 1
            fileout='/dev/tty'
        endif
    endif else begin
        fileout = file
    endelse
        
    if strlen(fileout) gt 0 then begin
        openw, out, fileout, /get_lun, more=usemore
    endif else begin
        ; just write to stdout, without using more
        out = -1
    endelse

    printf,out,'  Scan           Source      Vel    Proc Seq    RestF nIF nInt nFd     Az    El'
    printf,out,'-------------------------------------------------------------------------------'

    scans = !g.lineio->get_index_values("SCAN")
    times = !g.lineio->get_index_values("TIMESTAMP")
    indx = lonarr(n_elements(scans))
    count = 0
    oldscan = -1
    oldtime = ''
    for i=0,n_elements(scans)-1 do begin
        scan = scans[i]
        if scan lt smin or scan gt smax then continue
        if scan ne oldscan or times[i] ne oldtime then begin
            indx[count] = i
            count += 1
            oldscan = scan
            oldtime = times[i]
        endif
    endfor

    if (count eq 0) then return

    indx = indx[0:(count-1)]

    az = !g.lineio->get_index_values("AZIMUTH",index=indx)
    el = !g.lineio->get_index_values("ELEVATION",index=indx)
    source = !g.lineio->get_index_values("SOURCE",index=indx)
    proc = !g.lineio->get_index_values("PROCEDURE",index=indx)
    seqn = !g.lineio->get_index_values("PROCSEQN",index=indx)
    vel = !g.lineio->get_index_values("VELOCITY",index=indx)
    restf = !g.lineio->get_index_values("RESTFREQ",index=indx)

    procedure = strarr(count)
    nifs = intarr(count)
    nints = lonarr(count)
    nfeeds = intarr(count)

    scans = scans[indx]
    times = times[indx]
    sortedScans = scans[sort(scans)]
    hasInfo = intarr(count)

    for i=0,(n_elements(scans)-1) do begin
        if not hasInfo[i] then begin
            scaninfo = scan_info(scans[i],count=count,/quiet)
            for j=0,(count-1) do begin
                thisInfo = scaninfo[j]
                indx = where(scans eq thisInfo.scan)
                indx2 = where(times[indx] eq thisInfo.timestamp,finalCount)
                indx =indx[indx2]
                if finalCount lt 1 then begin
                    if out ne -1 then free_lun, out
                    message,'Unexpected error, unable to continue, please report this. Sorry.'
                endif
                for k=0,(finalCount-1) do begin
                    thisIndx = indx[k]
                    procedure[thisIndx] = thisInfo.procedure
                    nifs[thisIndx] = thisInfo.n_ifs
                    nints[thisIndx] = thisInfo.n_integrations
                    nfeeds[thisIndx] = thisInfo.n_feeds
                    hasInfo[thisIndx] = 1
                endfor
            endfor
        endif
        thissource = source[i]
        if strlen(thissource) gt 16 then thissource = strmid(thissource,0,15) + "*"

        printf,out,scans[i],thissource,vel[i]/1e3,$
               procedure[i],seqn[i],restf[i]/1e9,nifs[i], $
               nints[i], nfeeds[i], az[i], el[i], $
               format='(i6,1x,a16,1x,f8.1,1x,a7,x,i3,2x,f7.3,1x,i3,1x,i4,1x,i3,2x,f5.1,x,f5.1)'
    endfor

    if out ne -1 then begin
        free_lun, out
        if n_elements(file) gt 0 then begin
            if strlen(file) gt 0 then print, 'Summary written to : ', file
        endif
    endif
end
