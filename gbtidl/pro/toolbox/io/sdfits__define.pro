;+
; This class has all the same functionality as its superclass FITS, but contains special
; handling for known characteristics of sdfits files, for example what columns to expect
; in an extension.
; @file_comments
; This class has all the same functionality as its superclass FITS, but contains special
; handling for known characteristics of sdfits files, for example what columns to expect
; in an extension.
; @inherits fits
; @private_file
;-
PRO sdfits__define
   compile_opt idl2, hidden

    f1 = { sdfits, inherits fits, $
         fitsver:"", $
         sdfitver:"", $
         sdfitver_number:"", $
         from_gbtidl:0, $
         auto_offsets:0 $
         }

END

;+
; Invokes the base class (FITS) update_file_properties and then sets
; the SDFITS properties
; @uses FITS::update_file_properties
;-
PRO SDFITS::update_file_properties
  compile_opt idl2, hidden

  ; reset sdfits properties to defaults
  self.fitsver = ""
  self.sdfitver = ""
  self.sdfitver_number = ""
  self.from_gbtidl = 0
  self.auto_offsets = 0

  self->FITS::update_file_properties

  if obj_valid(self.primary_header) then begin
     fitsver = self.primary_header->get_key_value("FITSVER")
     if size(fitsver,/type) eq 2 then begin
        ; it returned -1 and this keyword doesn't exist
        fitsver = '0'
     endif
     self.fitsver = fitsver

     sdfitver = self.primary_header->get_key_value("SDFITVER")
     if size(sdfitver,/type) eq 2 then begin
        ; it returned -1 and this keyword doesn't exist
        sdfitver = "sdfits ver1.1"
     endif
     self.sdfitver = sdfitver

     version = self.sdfitver
     if strlen(version) gt 3 then begin
        version=strmid(version,10)
     endif else begin
        version='1.1'
     endelse
     self.sdfitver_number = version

     ; the quick test for GBTIDL
     if self->has_header_keyword("GUIDEVER") then begin
        self.from_gbtidl = 1
     endif else begin
        ; older versions (mis)used SDFITVER
        if strlen(self.sdfitver) gt 5 then begin
           if strmid(self.sdfitver,0,6) eq 'GBTIDL' then begin
              self.from_gbtidl = 1
           endif
        endif
     endelse

     ; should beam offsets be automatically applied 
     if self.from_gbtidl eq 0 then begin
        ; FITSVER < 1.7 - expect just one decimal and only integers
        parts = strsplit(self.fitsver,'.',/extract)
        if n_elements(parts) eq 2 then begin
           if stregex(parts[0],'^[0-9]+$',/boolean) and stregex(parts[1],'^[0-9]+$',/boolean) then begin
              if parts[0] lt '1' or (parts[0] eq '1' and parts[1] lt '7') then self.auto_offsets = 1
           endif
        endif
     endif

  endif
 end

;+
; Checks wether the header contains given keyword
; @param keyword {in}{required}{type=string} keyword to check
; @returns 1 - has keyword; 0 - does not.
;-
FUNCTION SDFITS::has_header_keyword, keyword
    compile_opt idl2, hidden

    if obj_valid(self.primary_header) then begin
        value = self.primary_header->get_key_value(keyword)
        if size(value,/type) eq 2 then begin
            ; if returned -1 then this keyword doesn't exist
            return, 0
        endif else begin
            return, 1
        endelse
    endif else begin
        return, 0
    endelse

END

;+
; Checks wether this file was created by gbtidl or not
; @returns 1 - created by gbtidl, 0 - not.
;-
FUNCTION SDFITS::is_gbtidl_file
    compile_opt idl2, hidden

    return, self.from_gbtidl
END
    
;+
; Returns the sdfits program version used to create this file
; @returns '1.1' if there any problems, other wise, value of SDFITVER keyword
;-
FUNCTION SDFITS::get_sdfits_version_number
    compile_opt idl2

    return, self.sdfitver_number
END

;+
; Returns the sdfits program version used to create this file
; @returns 'sdfits ver 1.1' if there any problems, other wise, value of SDFITVER keyword
;-
FUNCTION SDFITS::get_sdfits_version
    compile_opt idl2

    return, self.sdfitver
 END

;+
; Returns the FITSVER value found in the primary header
; @ returns '0.0' if there are any problems.
;-
FUNCTION SDFITS::get_fitsver
  compile_opt idl2

  return, self.fitsver
END

;+
; Should any existing non-zero beam offsets be automatically applied
; when reading data from this file.
;
; This is only 1 (true) if the file is not from GBTIDL, if the SDFITVER
; keyword value exists, and if the FITSVER version is earlier than
; 1.7.  Otherwise 0 (false) is returned.
;-
FUNCTION SDFITS::auto_apply_offsets
  compile_opt idl2

  return, self.auto_offsets
END

;+
; Creates a new blank fits file, with primary header info tagged for Green Bank
; @param file_name {in}{type=string} full path name of fits file to create
; @uses fxhmake
; @uses fxwrite
; @uses fxhmodify
;-
PRO SDFITS::create_sdfits_file, file_name
    compile_opt idl2

    version_string = 'GBTIDL ver'+strtrim(!g.version,2)

    self->set_file_name, file_name

    fxhmake,header,/initialize,/extend,/date

    fxwrite,self.file_name,header

    fxhmodify, self.file_name,'origin','NRAO Green Bank','origin of observation'
    fxhmodify, self.file_name,'telescop','NRAO_GBT','the telescope used'
    fxhmodify, self.file_name,'guidever',version_string,'this file was created by gbtidl'
    fxhmodify, self.file_name,'fitsver','1.9','FITS definition version'
    
    ; init file properties
    self.num_extensions = 0 

    *self.extension_names = ['']
    *self.extension_types = ['0']
    *self.axis = intarr(20)  ;[1,ext_num]

END

;+
; Retrives the size of the DATA column in given extension
; @param extension {in}{required}{type=long} extension number (1-based) for which data column length is needed
; @ returns length of DATA column for given extension
;-
FUNCTION SDFITS::get_extension_data_size, extension
    compile_opt idl2

    data_size = self->get_column_type(extension, column_name='DATA')
    parts = strsplit(data_size,'E',/extract)
    data_size = long(parts[0])
    return, data_size

END

;+
; Retrieves the size of the DATA column for the last extension
; @returns size of DATA column
; @private
;-
FUNCTION SDFITS::get_last_extension_data_size
    compile_opt idl2

    return, self->get_extension_data_size(self->get_number_extensions())

END

;+ 
; Retrives the keywords from a header that do not define the columns of the extension
; @param header {in}{type=array} string array of extension header keyword-value pairs
; @param non_virtual_list {in}{type=array} list of keywords that DO NOT describe columsn, but should NOT be included as virtuals
; @returns structure represneting the keywords-value pairs found
; @private
;-
FUNCTION SDFITS::get_virtual_columns, header, non_virtual_list
    compile_opt idl2
 
    virtual_count = 0

    ; go through each line in the header
    for i=0,n_elements(header)-1 do begin
        ; see if it is a key = value pair
        parts = strsplit(header[i],"=",/extract,count=count)
        if (count ne 0) and (n_elements(parts) gt 1) then begin
            key = strtrim(parts[0],2)
            ; see if the key is NOT in the list of keys to ignore
            if (self->string_in_list(key,non_virtual_list) eq 0) then begin
                count = 0
                value = fxpar(header,key)
                ; append to the struct using key = value as the the new tag, value pair
                if (virtual_count eq 0) then begin
                    virtuals = create_struct(key,value)
                endif else begin
                    virtuals = create_struct(virtuals,key,value)
                endelse
             virtual_count = virtual_count + 1
            endif    
        endif
    endfor

    ; return the struct containing the virtual columns
    if virtual_count eq 0 then begin
                                ; create a nearly empty structure with
                                ; a value that won't be used but will
                                ; make the downstream code happy that
                                ; it's a stuct.
        virtuals = create_struct("__DUMMY__","__DUMMY__")
    endif
    return, virtuals
    
END

;+
; Deprecated.
; @private
;-
FUNCTION SDFITS::string_in_list, str, list
    compile_opt idl2

    in_list = 0
    for i=0, n_elements(list)-1 do begin
        if (strpos(str,list[i]) ne -1) then in_list = 1
    endfor
    return, in_list

END 

;+ 
; Retrieves rows from an sdfits file, and finds what columsn are missing, and what the
; important keywords are in the header
; @param row_nums {in}{optionsal}{type=array} row numbers to read
; @param missing {out}{type=array} string array of columns found to be missing
; @param virtuals {out}{type=struct} keyword-value pairs in header that dont describe columns
; @keyword ext {in}{optional}{type=long} extension number to read from
; @keyword all_rows {in}{optional}{type=boolean} read all rows from extension?
; @uses mredfits
; @uses SDFITS::get_virtual_columns
; @uses SDFITS::get_missing_columns
; @returns array of structures representing the rows read in from sdfits extension
;-
FUNCTION SDFITS::get_and_eval_rows, missing, virtuals, row_nums, ext=ext, all_rows=all_rows, no_data=no_data
    compile_opt idl2
    
    if (keyword_set(ext) eq 0) then ext = 1

    ; get all the rows specified
    if keyword_set(no_data) then begin
        ; getting the rows without the data is exclusive of row_nums: always get all
        if self.debug then print, "retrieving sdfits rows without DATA column"
        rows = self->mrdfits_exclude_data(self.file_name,ext,hdr)
    endif else begin
        if self.debug then print, "retrieving sdfits rows with DATA column"
        if keyword_set(all_rows) then begin
            rows = mrdfits(self.file_name,ext,hdr,/silent)
        endif else begin 
            rows = mrdfits(self.file_name,ext,hdr,rows=row_nums,/silent)
        endelse    
    endelse    

    if size(rows,/type) ne 8 then return, -1

    self->create_extension_header_struct, hdr
    
    ; get the keywords from binary table that are 'virtual' cols
    list = ["TTYPE","TFORM","TUNIT","XTENSION","BITPIX","NAXIS","PCOUNT",$
            "GCOUNT","TFIELDS","COMMENT","EXTNAME","EXTLEVEL",$
            "EXTVER","HISTORY","REFERENC","DATAMIN","DATAMAX","TDISP",$
            "THEAP","TNULL","TSCAL","TZERO"]

    ; put all the keywords of interest in ext hdr in a struct
    virtuals = self->get_virtual_columns(hdr, list)

    missing = self->get_missing_columns(tag_names(rows[0]))

    return, rows

END

;+
; Finds what the missing columns are in a list of columns found in an sdfits file
; @param present {in}{type=array} list of columns present in sdfits extension
; @uses SDFITS::get_expected_col_names
; @returns those columns that were expected but not found
;-
FUNCTION SDFITS::get_missing_columns, present 
    compile_opt idl2

    expecteds = self->get_expected_col_names()
    if size(expecteds,/type) ne 7 then return, -1

    missing_count = 0
    ; look for each expected col in the cols that are present
    for i=0,n_elements(expecteds)-1 do begin
        expected = expecteds[i]
        r = where(expected eq present)
        if (r eq -1) then begin
            missing_count = missing_count + 1
            if (missing_count eq 1) then missing=[expected] else missing=[missing,expected]
        endif
    endfor
    
    if (missing_count eq 0) then return, -1 else return, missing
        
    
END

;+
; Retrives the names of columns expected to be found in an sdfits file
; @uses SDFITS::define_sdfits_row
; @returns expected column names
;-
FUNCTION SDFITS::get_expected_col_names
    compile_opt idl2

    expected = tag_names(self->define_sdfits_row())
    return, expected

END
;+
; Checks sdfits file of this object (or of keyword) to see if it meets certain criteria:
; does it exist? does it have more then one extension? Is the last extension binary and of
; type 'SINGLE DISH'?
; keyword file_name {in}{optional}{type=string} file to check
; keword verbose {in}{optional}{type=boolean} print details when error found?
; @returns 0,1
;-
FUNCTION SDFITS::check_sdfits_properties, file_name=file_name, verbose=verbose
    compile_opt idl2

    ; see if we need to print out problems
    if keyword_set(verbose) then loud=1 else loud=0
    
    ; see if file even exists
    if keyword_set(file_name) then begin 
        self->set_file_name, file_name 
        self.properties_known = 0
    endif    
        
    if (self->file_exists() eq 0) then begin
        if loud then print, "file does not exist"
        return, 0
    endif
      
    ; see if we need to update file properties
    if (self.properties_known eq 0) then self->update_properties
    
    ; does it have more then one extension?
    if (self.num_extensions lt 1) then begin
        if loud then print, 'file not valid: less then 1 extensions'+string(self.num_extensions) 
        return, 0
    endif    
    
    ; is the last extension a binary extension?
    type = self->get_extension_type(self.num_extensions)
    if (type ne "BINTABLE") then begin
        if loud then print, "last extension not a binary extension: "+type
    endif
    
    ; is the last extension an sdfits extension?
    name = self->get_extension_name(self.num_extensions)
    if (name ne "SINGLE DISH") then begin
        if loud then print, "last extension not an sdfits binary extension: "+name
    endif

    ; passes all tests
    return, 1
    
END

;+
; Takes in a structure representing an sdfits row, and returns the same 
; structure, minus the DATA field
; @returns identical sturcture to that passed in, minus the DATA field
;-
FUNCTION SDFITS::exclude_data, rowStruct
    compile_opt idl2

    names = tag_names(rowStruct)
    firstRow = rowStruct[0]
    outCount = 0
    for i=0,(n_elements(names)-1) do begin
        if names[i] eq 'DATA' then continue
 
        if outCount eq 0 then result=create_struct(names[i],firstRow.(i)) $
        else result=create_struct(result,names[i],firstRow.(i))
        outCount += 1
    endfor
    result = replicate(result,n_elements(rowStruct))
    struct_assign,rowStruct,result
    return,result
    
END

;+
; Reads in sdfits file in chunks, and avoids the column excluded by exclude_data() thus saving
; memory and increasing performance.  For use when reading in entire sdfits 
; file just for header information (i.e. index file creation).
; @param file_name {in}{required}{type=string} full path name to the sdfits file to read
; @param ext {in}{required}{type=long} extension to be read (0-based)
; @param hdr {out}{required}{type=array} string array represnting the header of the extension read
; @returns array of structures represnting the rows of the sdfits extension read, minus the DATA column
;-
FUNCTION SDFITS::mrdfits_exclude_data,file_name,ext,hdr
    compile_opt idl2

    if n_elements(ext) eq 0 then ext=1
    ; get the header for given extension
    h = headfits(file_name,exten=ext)
    ; parse the info in this header
    ;mrd_fxpar,h,xten,nfld,nrow,row_size,fname,fforms,scales,offsets
    nrow = fxpar(h,'NAXIS2')
    if nrow le 0 then return, -1
    row_size = fxpar(h,'NAXIS1')
    ; limit to 100 Mb max - will actually use 2x this as it copies
    maxRows = long(100e6/row_size)
    if maxRows lt 1 then maxRows = 1
    if nrow lt maxRows then begin
        if self.debug then print,'single read'
        result = self->exclude_data(mrdfits(file_name,ext,hdr,/silent))
        progress_bar = 0
    endif else begin
        if self.debug then print,'many reads'
        if maxRows gt nrow/2 then maxRows = nrow/2
        nLeft = nrow
        thisRow = 0
        total_reads = nrow/maxRows
        if self.debug then print,'rows per read = ',maxRows
        if self.debug then print,'total rows to read = ', total_reads
        if self.debug then print,'total reads = ',long(nrow/maxRows)
        if self.debug then print,'rows left','start row','read size',format='(a9,2x,a9,2x,a9)'
        if not self.debug then progress_bar = 1 else progress_bar = 0
        ; set up the progress bar
        if progress_bar then begin
            top_bar = ""
            for i=0,total_reads-1 do begin
                top_bar += '_'
            endfor
            print, "Reading sdfits file:"
            print, top_bar
        endif
        while nLeft gt 0 do begin
            thisChunk = (nLeft gt maxRows) ? maxRows : nLeft
            if self.debug then print,nLeft,thisRow,thisChunk,format='(i9,2x,i9,2x,i9)'
            if thisRow eq 0 then begin
                result = self->exclude_data(mrdfits(file_name,ext,hdr,range=[thisRow,(thisRow+thisChunk-1)],/silent))
            endif else begin
                thisResult = replicate(result[0],thisChunk)
                struct_assign,mrdfits(file_name,ext,hdr,range=[thisRow,(thisRow+thisChunk-1)],/silent),thisResult
                ; append result - we couldn't do this efficiently if the giant data column 
                ; wasn't excluded
                result = [result,thisResult]
            endelse
            ; advance progress bar
            if progress_bar then print, format='("X",$)'
            ; advance to next chunk
            thisRow += thisChunk
            nLeft -= thisChunk
        endwhile
    endelse
    ; terminate progress bar
    if progress_bar then print, format='(/)' 
    return, result
    
END

;+
; Returns sizes needed for ASCII columns in sdfits.
; Problems: this exists here AND in IO_SDFITS_WRITER.
; @returns structure with sizes for ASCII columsn in sdfits
; @private
;-
FUNCTION SDFITS::get_sdfits_row_sizes
   compile_opt idl2

   sizes = { sdfits_row_sizes, $
   object: 32, $ 
   date_obs: 22, $ 
   timestamp: 22, $ 
   tdim7: 16, $
   tunit7: 6, $
   ctype1: 8, $
   ctype2: 4, $
   ctype3: 4, $
   radesys: 8, $
   observer: 32, $
   obsid: 32, $
   procscan: 16, $
   proctype: 16, $
   obsmode: 32, $
   frontend: 16, $
   veldef: 8, $
   sampler: 8, $
   sideband: 1, $
   qd_method: 1, $
   sig: 1, $
   cal: 1, $
   caltype: 8, $
   calposition: 16, $
   backend: 32, $
   projid: 32, $
   telescop: 32 $
   }

   return, sizes

END   

;+
; Defines an anonymous structure that mirrors a row in an sdfits file, version 1.7.  Must be anonymos so that the 
; DATA columns length can be defined at run-time.
; Problems: this exists here AND in IO_SDFITS_WRITER
; @param data_points {in}{type=array} length of DATA column
; @uses SDFITS::get_sdfits_row_sizes
; @returns structure mirroring row of an sdfits file
;-
FUNCTION SDFITS::define_sdfits_row, data_points
   compile_opt idl2
;tdim6 = '('+string(data_points)+',1,1,1)'

   if (n_params() eq 0) then data_points = 1

   sizes = self->get_sdfits_row_sizes()   

   ; has to be an anonymous structure if length of data array varies
   row = { $
   OBJECT:STRING(replicate(32B,sizes.object)), $ ;    'U4305o          '
   BANDWID:double(0.0), $
   DATE_OBS:STRING(replicate(32B,sizes.date_obs)), $ ;        STRING    '2004-06-20T01:25:15.00'
   DURATION:double(0.0), $  ;      DOUBLE           20.000000
   EXPOSURE:double(0.0), $  ;      DOUBLE           15.015000
   TSYS:DOUBLE(0.0), $ ;          1.0000000
   DATA:FLTARR(data_points), $
   TDIM7:STRING(replicate(32B,sizes.tdim7)), $ ; STRING    '(16384,1,1,1)   '
   TUNIT7:STRING(replicate(32B,sizes.tunit7)), $ ; STRING    'Counts'
   CTYPE1:STRING(replicate(32B,sizes.ctype1)), $
   CRVAL1:DOUBLE(0.0), $ ;       1.4196290e+09
   CRPIX1:DOUBLE(0.0), $ ;          DOUBLE           8193.0000
   CDELT1:DOUBLE(0.0), $ ;          DOUBLE           762.93945
   CTYPE2:STRING(replicate(32B,sizes.ctype2)), $ ;          STRING    'RA  '
   CRVAL2:DOUBLE(0.0), $ ;          DOUBLE           123.06735
   CTYPE3:STRING(replicate(32B,sizes.ctype3)), $ ;          STRING    'DEC '
   CRVAL3:DOUBLE(0.0), $ ;          DOUBLE           70.870293
   CRVAL4:0S, $ ;          INT             -5
   OBSERVER:STRING(replicate(32B,sizes.observer)), $ ;        STRING    'Paul et al                      '
   OBSID:STRING(replicate(32B,sizes.obsid)), $ ;           STRING    'test                            '
   SCAN:0L, $ ;            INT             12
   OBSMODE:STRING(replicate(32B,sizes.obsmode)), $ ;         STRING    'OffOn:PSWITCHOFF:TPWCAL         '
   FRONTEND:STRING(replicate(32B,sizes.frontend)), $ ;        STRING    'Rcvr1_2         '
   TCAL:DOUBLE(0.0), $ ;            DOUBLE           1.6141294
   ;TSYSREF:DOUBLE(0.0), $;          1.000000000
   VELDEF:STRING(replicate(32B,sizes.veldef)), $ ;          STRING    'OPTI-BAR'
   VFRAME:DOUBLE(0.0), $ ;          DOUBLE           6022.8417
   RVSYS:DOUBLE(0.0), $ ;           DOUBLE           163981.20
   OBSFREQ:DOUBLE(0.0), $ ;         DOUBLE       1.4196290e+09
   LST:DOUBLE(0.0), $ ;             DOUBLE           50416.963
   AZIMUTH:DOUBLE(0.0), $ ;         DOUBLE           335.51521
   ELEVATIO:DOUBLE(0.0), $ ;        DOUBLE           37.431882
   TAMBIENT:DOUBLE(0.0), $ ;        DOUBLE              275.71
   PRESSURE:DOUBLE(0.0), $ ;        DOUBLE          690.977295
   HUMIDITY:DOUBLE(0.0), $ ;        DOUBLE               0.396
   RESTFREQ:DOUBLE(0.0), $ ;        DOUBLE       1.4204050e+09
   DOPFREQ:DOUBLE(0.0), $ ;         DOUBLE       1.4204050e+09
   FREQRES:DOUBLE(0.0), $ ;         DOUBLE       1.4204050e+09
   EQUINOX:DOUBLE(0.0), $ ;         DOUBLE            2.000000
   RADESYS:STRING(replicate(32B,sizes.radesys)), $ ;           STRING "FK5"
   TRGTLONG:DOUBLE(0.0), $ ;        DOUBLE 
   TRGTLAT:DOUBLE(0.0), $ ;         DOUBLE
   SAMPLER:STRING(replicate(32B,sizes.sampler)), $ ;         STRING    'A12     '
   FEED:1S, $ ;            INT              1
   SRFEED:0S, $ ;          INT              0
   FEEDXOFF:DOUBLE(0.0), $ ;        DOUBLE           0.0000000
   FEEDEOFF:DOUBLE(0.0), $ ;        DOUBLE           0.0000000
   SUBREF_STATE:1S, $ ;    INT              1
   SIDEBAND:STRING(replicate(32B,sizes.sideband)), $ ;        STRING    'U'
   PROCSEQN:0S, $ ;        INT              1
   PROCSIZE:0S, $ ;        INT              2
   PROCSCAN:STRING(replicate(32B,sizes.procscan)), $    STRING 'ON'
   PROCTYPE:STRING(replicate(32B,sizes.procscan)), $    STRING 'SIMPLE'
   LASTON:0L, $ ;          INT              0
   LASTOFF:0L, $ ;         INT             12
   TIMESTAMP:STRING(replicate(32B,sizes.timestamp)), $ 
   QD_XEL:!values.d_nan, $ ;
   QD_EL:!values.d_nan, $ ;
   QD_BAD:-1S, $ ;
   QD_METHOD:STRING(replicate(32B,sizes.qd_method)), $
   VELOCITY:DOUBLE(0.0), $ ;        DOUBLE           158000.00
   FOFFREF1:DOUBLE(0.0), $ ;        1.00000000000
   ZEROCHAN:FLOAT(0.0), $ ;  FLOAT   0.0 - ACS data only
   ADCSAMPF:DOUBLE(0.0), $ ; VEGAS ADC sampler frequency
   VSPDELT:DOUBLE(0.0), $ ; VEGAS SPUR channel increment
   VSPRVAL:DOUBLE(0.0), $ ; VEGAS spur number at VSPRPIX
   VSPRPIX:DOUBLE(0.0), $ ; channel number of VEGAS spur VSPRVAL
   SIG:STRING(replicate(32B,sizes.sig)), $
   CAL:STRING(replicate(32B,sizes.cal)), $
   CALTYPE:STRING(replicate(32B,sizes.caltype)), $ ;         STRING   "LOW"    
   TWARM:FLOAT(0.0), $ ; Rcvr68_92 data only
   TCOLD:FLOAT(0.0), $ ; Rcvr68_92 data only
   CALPOSITION:STRING(replicate(32B,sizes.calposition)), $ ; Rcvr68_92 only
   ; the below columns are keywords in an sdfits-filled file, but in gbtild, they
   ; could have different values per row
   backend:STRING(replicate(32B,sizes.backend)), $
   projid:STRING(replicate(32B,sizes.projid)), $
   telescop:STRING(replicate(32B,sizes.telescop)), $ ; 'NRAO_GBT'
   sitelong:DOUBLE(0.0), $ 
   sitelat:DOUBLE(0.0), $ 
   siteelev:DOUBLE(0.0), $ 
   ; the below are columns not found as either col or keyword in sdfits-filled file, 
   ; they are added by gbtidl
   ifnum:0S, $
   plnum:0S, $
   fdnum:0S, $
   int:0L, $
   nsave:0L $
   }

   return, row
END

