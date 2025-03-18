;+
; Class provides an interface for reading/writing sdfits files that contain spectral line data.
; @inherits sdfits
; @file_comments
; Class provides an interface for reading/writing sdfits files that contain spectral line data.
; @private_file
;-
PRO line_sdfits__define
    compile_opt idl2, hidden

    ls = { line_sdfits, inherits sdfits }    

END

;+
; Class constructor - object is constructed and file may be checked for validity
; @param file_name {in}{optional}{type=string} full path name to sdfits file
; @keyword new {in}{optinal}{type=boolean} is this a new file?
;_
FUNCTION LINE_SDFITS::init, file_name, new=new, _EXTRA=ex
    compile_opt idl2, hidden

    ; file name passed?
    if (n_params() eq 1) then begin
        r = self->FITS::init( file_name, _EXTRA=ex )
        ; if this is not a new fits file, check its properties
        if (r eq 1) and (keyword_set(new) eq 0) then begin
            r = self->check_file_validity(/verbose)
            if (r eq 0) then begin 
                print, 'error initing line_sdfits object'
                return, 0
            endif    
        endif    
    endif else begin
        r = self->FITS::init(_EXTRA=ex)
    endelse

    return, r
    
END

;+
; Checks sdfits file for basic validity, and also that it contains spectral line data
; @returns 0,1
; @uses SDFITS::check_sdfits_properties
;-
FUNCTION LINE_SDFITS::check_file_validity, _EXTRA=ex
    compile_opt idl2
    
    ; see if we need to print out problems
    if keyword_set(verbose) then loud=1 else loud=0

    ; check that basic sdfits properties are correct
    if (self->check_sdfits_properties( _EXTRA=ex ) eq 0) then return, 0
    
    ; is it for the right backend?
    backend = self->get_extension_header_value("BACKEND")

    ; valid header values for this must be strings
    if (size(backend,/TYPE) eq 7) then begin
        if (backend ne "VEGAS") and (backend ne "Spectrometer") and (backend ne "Spectral Processor") and (backend ne "SpectralProcessor") then begin
            ;if loud then print, "sdfits file is for wrong backend: "+backend
            print, "sdfits file is for wrong backend: "+backend
            return, 0
        endif
    endif

    ; passes all tests
    return, 1
    
END

;+
; Set the flags in the supplied flag_file object as appropriate for
; VEGAS_SPURS using the current contents of this FITS file
;
; Nothing is flagged if SDFITVER is not present (any value) and 
; INSTRUME is "VEGAS" in the primary HDU.
;
; The VEGAS spur columns are also necessary: VSPRPIX, VSPRVAL, VSPDELT.
;
; @param flagFile {in}{required}{type=flag file object} The flag file
; to use when setting any flags.
; @keyword flagcenteradc {in}{optional}{type=boolean} When set, the
; center ADC spur is also flagged.  Normally that spur is left
; unflagged because sdfits usually replaces the value at that location
; with an average of the two adjacent channels and so that spur does
; not need to be flagged since it's been interpolated.
; @returns number of flags set (integer).  0 if none set.
;-
FUNCTION LINE_SDFITS::flagVegasSpurs, flagFile, flagcenteradc=flagcenteradc
  compile_opt idl2

  ; tests to verify that this looks OK to flag
  if not self->has_header_keyword("SDFITVER") then return, 0
  if not self->has_header_keyword("INSTRUME") then return, 0
  if not (self.primary_header->get_key_value("INSTRUME") eq "VEGAS") then return, 0

  nExt = self->get_number_extensions()

  ; do nothing if there are no extensions past the primary HDU
  if nExt le 0 then return, 0

  ; good to go
  flagCount = 0
                                ; if this order is changed, adjust the
                                ; order of the variables in the
                                ; fxbreadm call below
  cols = ["SCAN","IFNUM","FDNUM","VSPRVAL","VSPRPIX","VSPDELT"]
  colNums = [-1,-1,-1,-1,-1,-1]
  funit = -1
  for i=1,nExt do begin
     ; open the file at that extension - do error handling here
     catch, error_status
     if error_status ne 0 then begin
                                ; some problem, print it out and
                                ; return, this should not happen
        print,"An error occured while attempting to read the VEGAS spur columns"
        print,"Error index : ", error_status
        print,"Error message : ", !error_state.msg
        print,"Can not continue, flag file is likely not complete"
        catch,/cancel
        if funit ne -1 then fxbclose,funit
        return, -1
     endif
     catch,/cancel

     fxbopen, funit, self.file_name, i
     ; determine the column numbers, if any not found, silently return
     errmsg = ''
     for j=0,n_elements(colNums)-1 do begin
        colNum = fxbcolnum(funit,cols[j],errmsg=errmsg)
        if errmsg ne '' then begin
           print,'The SDFITS file(s) lack the columns necessary to flag VEGAS spurs'
           fxbclose,funit
           return, -1
        endif
        colNums[j] = colNum
     endfor
     ; and get the values
     ; order of cols must match order of arguments
     fxbreadm, funit, cols, scan, ifnum, fdnum, vsprval, vsprpix, vspdelt
     ; done with funit
     fxbclose, funit
     ; and done with error catching
     catch,/cancel
     ; work out NCHAN
     dataForm = strtrim(self->get_column_type(i,column_name="DATA"),2)
     nchan = long64(strmid(dataForm,0,(strlen(dataForm)-1)))
     nRows = n_elements(scan)
     counter = 0
     while nRows gt 0 do begin
        thisScan = scan[0]
        scanRows = where(scan eq thisScan, complement=otherRows, ncomplement=nRows)
        thisScanIfnum = ifnum[scanRows]
        thisScanFdnum = fdnum[scanRows]
        thisScanVsprval = vsprval[scanRows]
        thisScanVsprpix = vsprpix[scanRows]
        thisScanVspdelt = vspdelt[scanRows]
        if nRows gt 0 then begin
           scan = scan[otherRows]
           ifnum = ifnum[otherRows]
           fdnum = fdnum[otherRows]
           vsprval = vsprval[otherRows]
           vsprpix = vsprpix[otherRows]
           vspdelt = vspdelt[otherRows]
        endif
        scanRowCount = n_elements(scanRows)
        while scanRowCount gt 0 do begin
           thisIfnum = thisScanIfnum[0]
           thisFdnum = thisScanFdnum[0]
           thisVsprval = thisScanVsprval[0]
           thisVsprpix = thisScanVsprpix[0]
           thisVspdelt = thisScanVspdelt[0]
           ; spur values must be finite, else skip
           if finite(thisVsprval) and finite(thisVsprpix) and finite(thisVspdelt) then begin
                                ; 1 subtracted here because the FITS
                                ; values are 1-relative and IDL is 0-relative
              spurChans = dcspurchans(thisVsprval,thisVsprpix-1,thisVspdelt,nchan,docenterspur=flagcenteradc,count=count)
              if count gt 0 then begin
                 ; something to flag
                 flagFile->set_flag, scan, ifnum=thisIfnum, fdnum=thisFdnum, bchan=spurChans, echan=spurChans, id='VEGAS_SPUR'
                 flagFile->append_index_value_recnums, '*'
                 flagCount = flagCount + 1
              endif
           endif 
           theseRows = where(thisScanIfnum eq thisIfnum and thisScanFdnum eq thisFdnum, complement=moreRows, ncomplement=scanRowCount)
           if scanRowCount gt 0 then begin
              thisScanIfnum = thisScanIfnum[moreRows]
              thisScanFdnum = thisScanFdnum[moreRows]
              thisScanVsprval = thisScanVsprval[moreRows]
              thisScanVsprpix = thisScanVsprpix[moreRows]
              thisScanVspdelt = thisScanVspdelt[moreRows]
           endif
           counter = counter + 1
        endwhile
     endwhile     
  endfor

  return, flagCount
END
