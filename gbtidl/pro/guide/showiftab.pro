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
  

