; docformat = 'rst' 

;+
; Find the scan_info associated with the paired scan implied by the
; supplied scan_info structure.  See :idl:pro:`scan_info` for a
; description of the contents of the structure expected as the info
; argument as well as the structure returned by this function.
;
; Scan's often come in pairs (OnOff,OffOn,Nod).  When the
; possibility of repeated scan numbers at different times and in
; different files (in the case of the use of dirin to open more than
; one fits file at a time) is taken into account, it becomes
; non-trivial to find the scan that is paired with a known scan.  This
; routine uses that known scan's scan_info structure to find the
; scan_info structure associated with the best guess as to the
; location of that scan's pair.  This returns -1 if no suitable paired
; scan could be found.
;
; The paired scan must have the appropriate relative scan number as
; implied by ``info.procseqn``. Since this works for scans taken as a pair
; by the same procedure then only procseqns of 1 or 2 are allowed.  If
; the procseqn in the info parameter (``info.procseqn``) is 1, then the
; paired scan must have a procseqn of 2.  Similarly, if ``info.procseqn`` is
; 2 then the paired scan must have a procseqn of 1.
;
; The paired scan must be found in the same file as given by
; info.file.
;
; When file and procseqn are not sufficient to resolve all
; ambiguities, then the scan closest to the ``info.timestamp`` in the
; appropriate direction is used to identify the best guess at the
; paired scan.  Appropriate direction means that if ``info.procseqn``
; implies that the paired scan came after the scan described by info,
; then it's timestamp must be after ``info.timestamp``.  Similarly, if the
; paired scan must have come before the scan described by info, then
; it's timestamp must come before ``info.timestamp``.
;
; This is primarily useful inside of the calibration routines
; (e.g. :idl:pro:`getps`) but it may also be useful to users writing their
; own processing routines.
;
; :Params:
;   info : in, required, type=structure
;       The ``scan_info`` structure of the scan who's pair is desired.
; 
; :Keywords:
;   keep : in, optional, type=boolean
;       When present, search the output file.
;
; :Returns:
;   The paired scan's ``scan_info`` structure.  If no pair could be
;   found, returns -1
;
;-
function find_paired_info, info, keep=keep
    compile_opt idl2

    if n_elements(info) eq 0 then begin
        usage,'find_paired_info'
        return,-1
    endif

    if size(info,/type) ne 8 then begin
        message,'invalid data type for info',/message
        return,-1
    endif

    if n_elements(info) gt 1 then begin
        message,'Only 1 info structure can be paired at a time',/info
        return,-1
    endif

    ; its an anonymous structure, so can't check on it's name
    ; don't waste a lot of time on checks here, just trap
    ; for bad errors
    catch,error_status
    if (error_status ne 0) then return,-1

    if info.procseqn lt 1 or info.procseqn gt 2 then return,-1

    thisScan = info.scan
    thisProcseqn = info.procseqn
    thisFile = info.file
    thisTime = info.timestamp

    otherScan = (info.procseqn eq 1) ? (thisScan+1):(thisScan-1)

    otherInfo = scan_info(otherScan,thisFile,/quiet,keep=keep,count=count)

    if count le 0 then return,-1

    if count gt 1 then begin
        otherTimes = otherInfo.timestamp
        allTimes = [thisTime,otherTimes]
        allTimes = allTimes[sort(allTimes)]
        thisIndx = where(allTimes eq thisTime)
        otherIndx = (info.procseqn eq 1) ? (thisIndx+1):(thisIndx-1)
        if otherIndx lt 0 or otherIndx ge n_elements(allTimes) then return,-1
        otherTime = (allTimes[otherIndx])[0]
        otherInfoIndx = where(otherTime eq otherTimes,count)
        if count ne 1 then return,-1
        otherInfo=otherInfo[otherInfoIndx]
    endif

    ; final check
    if otherInfo.procseqn lt 1 or otherInfo.procseqn gt 2 then return,-1
    if otherInfo.procseqn + info.procseqn ne 3 then return,-1

    return,otherInfo
end
