; docformat = 'rst' 

;+
; Summarize the valid ifnum, fdnum, plnum combinations for a scan.
;
; :Params:
;   scan : in, required, type=integer
;       Scan number of interest.
;   keep : in, optional, type=boolean
;       If set, the summary uses information from the keep file.
;
; :Examples:
;   A scan where all combinations of 2 IFs, 8 feeds, and 4 polarization
;   is present.
; 
;   .. code-block:: IDL
; 
;       showiftab,35
;  
;   .. code-block:: text
; 
;       Scan : 35
;       ifnum fdnum plnum
;         0:1   0:7   0:4
;
;   In this scan, feed 0 has just plnum 2 for both IFs, feed 1 has just plnum 1
;   for the same IFs, and feeds 2 through 7 have plnum 0 and 1 for the
;   second if.
; 
;   .. code-block:: IDL
; 
;       GBTIDL -> showiftab,33
;  
;   .. code-block:: text
; 
;       Scan : 33
;       ifnum fdnum plnum
;         0:1     0     2
;         0:1     1     1
;           1   2:7   0:1
;
; :Uses:
;   :idl:pro:`scan_info` 
;
;-
pro showiftab, scan, keep=keep
  compile_opt idl2
  
  if (n_elements(scan) eq 0) then begin
     usage,'showiftab'
     return
  endif

  si = scan_info(scan,keep=keep, count=count)
  if count le 0 then return

  for i = 0,(count-1) do begin
     thisTab = si[i].iftable
     thisScan = si.scan

     print,' '
     print,'     Scan : ', strtrim(thisScan,2)
     ; all of the work happens in doiftab
     count = -1
     doiftab,thisTab,maskstruct,count
     masks = maskstruct.masks[0:(count-1)]

     fmtarr = strarr(count,3)
     for i=0,count-1 do begin
        theseIndexes = {ifnum:maskStruct.indexes.ifnum[where(masks[i].ifnum)], $
                        fdnum:maskStruct.indexes.fdnum[where(masks[i].fdnum)], $
                        plnum:maskStruct.indexes.plnum[where(masks[i].plnum)]}
        thisLabel = 'A'+strtrim(i,2)
        if i eq 0 then begin
           indexStruct = create_struct(thisLabel,theseIndexes)
        endif else begin
           indexStruct = create_struct(indexStruct,thisLabel,theseIndexes)
        endelse

        fmtarr[i,0] = setArrFmt(theseIndexes.ifnum)
        fmtarr[i,1] = setArrFmt(theseIndexes.fdnum)
        fmtarr[i,2] = setArrFmt(theseIndexes.plnum)
     endfor

     sortOrder = sortIndexStruct(indexStruct)

     ifwid = max([strlen('ifnum'),max(strlen(fmtarr[*,0]))])
     fdwid = max([strlen('fdnum'),max(strlen(fmtarr[*,1]))])
     plwid = max([strlen('plnum'),max(strlen(fmtarr[*,2]))])
     fmt = '(5x,A'+strtrim(ifwid,2)+',x,A'+strtrim(fdwid,2)+',x,A'+strtrim(plwid,2)+')'
     print,'ifnum','fdnum','plnum',format=fmt
     for j=0,count-1 do begin
        indx = sortOrder[j]
        print,fmtarr[indx,0],fmtarr[indx,1],fmtarr[indx,2],format=fmt
     endfor
        
  endfor
end
  
;+ 
; Used internally in showiftab
;
; Format an array of *num (ifnum, fdnum or plnum) into a string.
;
; Compresses adjacent values into "a:b" sequence to cover the entire
; range.
;
; No internal error checking on the validity of arr.
;
; @param arr {in}{required}{type=integer array} Array to format.
; Assumed to be already sorted, without duplicates.
; @returns formatted string
;
; @private
;-
function setArrFmt, arr
  compile_opt idl2

  ; assumes all elements of arr are non-negative integers
  result = ""
  lastVal = -1
  pending = 0
  for i=0,n_elements(arr)-1 do begin
     thisVal = arr[i]
     if lastVal lt 0 then begin
        result += strtrim(thisVal,2)
        lastVal = thisVal
     endif else begin
        if (thisVal-lastVal) eq 1 then begin
           lastVal = thisVal
           pending = 1
        endif else begin
           if pending then begin
              result += ":" + strtrim(lastVal,2) +","
           endif else begin
              result += ","
           endelse
           result += strtrim(thisVal,2)
           lastVal = thisVal
           pending = 0
        endelse
     endelse
  endfor
  if pending then begin
     result += ":" + strtrim(lastVal,2)
  endif

  return,result
end

;+
; Process an iftable array returned by scan_info.
;
; Sets idxstruct to be a structure holding one instance of all of the
; index values for each quanity (ifnum, plnum, fdnum) and idxcount
; indicies of masks for each quantity.  All combinations of the index
; values corresponding to the true values (1) for the masks for each
; instance in that exist.  The masks and index values are then used to
; print out a table summarizing the 3D iftable array.
;
; There is no internal checking on the validity of the input values.
;
; This routine is called recursively, each call sets the current
; idxcount entry in idxstruct, increments idxcount, and calls it again
; if there remain additional elements in iftable that have not yet
; been accounted for in idxstruct.
;
; On return, idxstruct may contain more than idxcount elements, but
; only the first ixcount elements should be used.
;
; idxstruct is initialized if idxcount is <= 0.
;
; idxstruct has two fields: 'indexes' and 'masks'.  
; idxstruct.indexes has 3 fields: 'ifnum', 'fdnum', and 'plnum'.  Each
; of which are integer vectors holding the complete set of integer
; indexes available for that field (e.g. [0,1,2,3]).  They are here
; for convenience. 
; idxstruct.masks is an array of structures, each element has 3
; fields: 'ifnum', 'fdnum', and plnum'.  Each of which are
; integer vectors where 1 indicates the corresponding index in the
; indexes structure is in use for that set of masks and 0 indicates it
; is not in use.
;
; @param iftab {in}{required}{type=3D integer array} The iftable
; array.  The 3 axes are, in order, ifnum, plnum, and fdnum.  Elements
; are 1 when data exists with that combination and 0 if no data exists
; for that combination.
; @param idxstruct {out}{required}{type=structure} The structure set by
; this routine.  Valid through the first idxcount elements of the
; masks field.
; @param idxcount {out}{required}{type=integer} The current size of
; idxstruct already in use.
;
; @private
;-
pro doiftab,iftab,idxstruct,idxcount
  compile_opt idl2

  dim = size(iftab,/dim)
  ; correct for any degnerate axes
  if n_elements(dim) eq 1 then begin
     dim = [dim,1,1]
  endif
  if n_elements(dim) eq 2 then begin
     dim = [dim,1]
  endif

  if idxcount le 0 then begin
     ; first time through, initialize idxstruct using dim
     indexes = {ifnum:lindgen(dim[0]),fdnum:lindgen(dim[1]),plnum:lindgen(dim[2])}
     idxcount = 0
     masks = {ifnum:lonarr(dim[0]),fdnum:lonarr(dim[1]),plnum:lonarr(dim[2])}

     ; do the simplest case here
     if total(iftab) eq n_elements(iftab) then begin
        masks.ifnum[*] = 1
        masks.fdnum[*] = 1
        masks.plnum[*] = 1
        idxstruct = {indexes:indexes,masks:[masks]}
        idxcount = 1
        return
     endif

     ; anticipate more than we need
     ; This is way more than the worst case should be, but
     ; it's not obvious to me what that worst case is.
     ; This shouldn't be too onerous to just be lazy and do this.
     idxstruct = {indexes:indexes,masks:replicate(masks,(dim[0]*dim[1]*dim[2]))}
  endif

  ; find first non-zero element -> (ifnum, fdnum, plnum)
  felem = where(iftab,count)
  if count le 0 then return

  loc = array_indices(dim,felem[0],/dim)
  ifnum=loc[0]
  fdnum=loc[1]

  ; find all pols that are non-zero for that (ifnum, fdnum)
  ; this use of where actually returns the plnum values directly
  plArr = where(iftab[ifnum,fdnum,*],count)
  plmask = idxstruct.masks[idxcount].plnum
  plmask[plArr] = 1
        
  ; find any other feeds that are non-zero for that (ifnum and all plArr)
  fdnums = idxstruct.indexes.fdnum
  fdmask = idxstruct.masks[idxcount].fdnum
  for i=0,dim[1]-1 do begin
     thisPL = iftab[ifnum,i,plArr]
     fdmask[i] = total(thisPL) eq n_elements(iftab[thisPL])
  endfor
  fdArr = fdnums[where(fdmask)]

  
  ; find all other ifnums that are non-zero for all (fdArr, plArr)
  ifnums = idxstruct.indexes.ifnum
  ifmask = idxstruct.masks[idxcount].ifnum
  ; no obvious way involving using both fdArr and plArr as indices directly
  for i=0,dim[0]-1 do begin
     for j=0,n_elements(fdArr)-1 do begin
        thisPL = iftab[i,fdArr[j],plArr]
        thisOK = total(thisPL) eq n_elements(thisPL)
        if j eq 0 then begin
           ifmask[i] = thisOK
        endif else begin
           ifmask[i] = ifmask[i] and thisOK
        endelse
     endfor
  endfor
  ifArr = ifnums[where(ifmask)]
        
  ; put masks back into idxstruct
  idxstruct.masks[idxcount].ifnum = ifmask
  idxstruct.masks[idxcount].fdnum = fdmask
  idxstruct.masks[idxcount].plnum = plmask

  ; next one goes here
  idxcount += 1

  ; make new iftab array with those now marked as zero
  newIftab = iftab
  ; can't just set this just using all indices at once
  for i=0,n_elements(ifArr)-1 do begin
     for j=0,n_elements(fdArr)-1 do begin
        for k=0,n_elements(plArr)-1 do begin
           newIftab[ifArr[i],fdArr[j],plArr[k]] = 0
        endfor
     endfor
  endfor

  ; if any non-zero remain, call this procedure again
  if total(newIftab) gt 0 then begin
     ; recursion is your friend
     doiftab,newIftab,idxstruct,idxcount
  endif

  ; and return
end

;+
; Used during the sorting process in showiftab
;
; Compares two vectors of integers (will be vectors
; of index values, e.g. ifnum).
;
; Sorting rules are:
;   compare the first element
;   if equal compare the length
;      if equal compare the first non-equal element
;
; @param a {in}{required}{type=integer vector} 
; @param b {in}{required}{type=integer vector}
; @returns -1 if a<b, 0 if a==b, and 1 if a>b
;
; @private
;-
function compareIndexList, a, b
  compile_opt idl2

  ; use first element only
  if a[0] lt b[0] then return,-1
  if a[0] gt b[0] then return,1

  ; shortest list comes first
  if n_elements(a) lt n_elements(b) then return,-1
  if n_elements(a) gt n_elements(b) then return,1

  ; based on first non-equal element
  firstNE = where(a ne b)
  if firstNE ge 0 then begin
     if a[firstNE] lt b[firstNE] then return,-1
     return,1
  endif

  ; everyuthing is equal
  return,0
end

;+
; Used during the sorting process in showiftab
;
; Compares two index structures of ifnum, fdnum, and
; plnum fields.
;
; Uses compareIndex list to compare the individual index lists.
;
; First compares based on ifnum values
;   if equal, compare based on fdnum values
;      if equal, compare based on plnum values.
;
; @param a {in}{required}{type=structure}
; @param b {in}{required}{type=structure}
; @returns -1 if a<b, 0 if a==b, and 1 if a>b
; @private
;-
function compareIndexStructs, a, b
  compile_opt idl2

  result = compareIndexList(a.ifnum,b.ifnum)
  if result eq 0 then begin
     result = compareIndexList(a.fdnum,b.fdnum)
     if result eq 0 then begin
        result = compareIndexList(a.plnum,b.plnum)
     endif
  endif
  return, result
end

;+
; The sort function used by showiftab.
;
; This is a simple sort.  These structures are going to be small so
; this should be cheap and the extra effort to code something more
; efficient just isn't worth it.
;
; @param a {in}{required}{type=structre} The index structure to sort,
; as used by showiftab.
; @returns the sorted indexes into a to be used to print the formatted
; summaries in a sorted order.
; @private
;-
function sortIndexStruct, a
  ; sort the index structure in a using the above comparison structs
  ; The structure is expected to be small, use a simple sort
  ; technique here as opposed to something more efficient on large
  ; arrays.  It's just never going to be needed here.
  compile_opt idl2

  ntags = n_tags(a)
  index = lindgen(ntags)
  for i=0,ntags-2 do begin
     jmin = i
     jminIndx = index[i]
     for j=(jmin+1),ntags-1 do begin
        jIndx = index[j]
        if compareIndexStructs(a.(jIndx),a.(jminIndx)) lt 0 then begin
           jmin=j
           jminIndx = index[jmin]
        endif
     endfor
     if jmin ne i then begin
        tmp = index[i]
        index[i] = index[jmin]
        index[jmin] = tmp
     endif
  endfor
  return,index
end

