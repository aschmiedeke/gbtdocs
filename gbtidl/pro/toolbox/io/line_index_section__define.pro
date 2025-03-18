;+
; This class extends the rows_index_section class to properly manage the rows section 
; for a spectral line index file; that is, an index file where each row line represents
; a spectrum.
;
; @file_comments
; This class extends the rows_index_section class to properly manage the rows section 
; for a spectral line index file; that is, an index file where each row line represents
; a spectrum.
;
; @inherits rows_index_section
;
; @private_file
;-
PRO line_index_section__define

    ris = { LINE_INDEX_SECTION, $ 
            inherits rows_index_section, $
            old_format_string:string(replicate(32B,1028)), $
            long_index_format_string:string(replicate(32B,1028)), $
            long_row_format_string:string(replicate(32B,1028)), $
            tsStart:0, $
            tsLen:0 $
    }

END

;+
; Class Constructor
; Here the formats for the rows are determined: how to list them verbosly and
; quietly.
; @private
;-
FUNCTION LINE_INDEX_SECTION::init, filename

    r = self->ROWS_INDEX_SECTION::init(filename)

    ; all floats and doubles have the same format
    self.float_format = 'e16.9'
    flt = self.float_format
    
    ; array that contains all info needed for printing out info + header
    ; ***NOTE: this order must follow the order of {line_row_info_strct}
    ;i val, l val, column name, i head, l head
    ; i=index, l=listing
    *self.frmt = [ $
    ['i7','i7',  '#INDEX#',     'a7','a7', 'integer,string'], $
    ['a16','a16','PROJECT',     'a16','a16', 'string'], $ 
    ['a64','file_name','FILE',  'a64','a32', 'string'], $
    ['i3','i3',  'EXTENSION',   'a3','a3', 'integer,string'], $
    ['i7','i7',  'ROW',         'a7','a7', 'integer,string'], $
    ['a32','source_name','SOURCE','a32','a16', 'string'], $
    ['a9','a9',  'PROCEDURE',   'a9','a9', 'string'], $
    ['a32','a32','OBSID',       'a32','a32', 'string'], $
    ['i5','i5',  'E2ESCAN',     'a5','a5', 'integer,string'], $
    ['i5','i5',  'PROCSEQN',    'a5','a5', 'integer,string'], $
    ['i10','i10','SCAN',        'a10','a10', 'integer,string'], $
    ['a3','a3',  'POLARIZATION','a3','a3', 'string'], $
    ['i5','i5',  'PLNUM',       'a5','a5', 'integer,string'], $
    ['i5','i5',  'IFNUM',       'a5','a5', 'integer,string'], $
    ['i5','i5',  'FEED',        'a5','a5', 'integer,string'], $
    ['i5','i5',  'FDNUM',       'a5','a5', 'integer,string'], $
    ['i10','i10','INT',         'a10','a10', 'integer,string'], $
    ['i6','i6',  'NUMCHN',      'a6','a6', 'integer,string'], $
    ['a3','a3',  'SIG',         'a3','a3', 'string'], $
    ['a3','a3',  'CAL',         'a3','a3', 'string'], $
    ['a12','a12',  'SAMPLER',     'a12','a12', 'string'], $
    [flt,'F5.1',    'AZIMUTH',     'a16','a5', 'float,string'], $
    [flt,'F4.1',    'ELEVATION',   'a16','a4', 'float,string'], $
    [flt,'sexigesimal_ra','LONGITUDE',   'a16','a12', 'float,string'], $
    [flt,'sexigesimal','LATITUDE',    'a16','a12', 'float,string'], $
    [flt,'sexigesimal','TRGTLONG',    'a16','a12', 'float,string'], $
    [flt,'sexigesimal','TRGTLAT' ,    'a16','a12', 'float,string'], $
    ['i3','i3',  'SUBREF',      'a3', 'a3', 'integer,string'], $
    [flt,'sex_degrees','LST',         'a16','a12', 'float,string'], $
    [flt,flt,    'CENTFREQ',    'a16','a16', 'float,string'], $
    [flt,flt,    'RESTFREQ',    'a16','a16', 'float,string'], $
    [flt,flt,    'VELOCITY',    'a16','a16', 'float,string'], $
    [flt,flt,    'FREQINT',     'a16','a16', 'float,string'], $
    [flt,flt,    'FREQRES',     'a16','a16', 'float,string'], $
    ['a22','dateobs','DATEOBS',     'a22','a23', 'string'], $
    ['a22','a22','TIMESTAMP',     'a22','a22', 'string'], $
    [flt,flt,    'BANDWIDTH',   'a16','a16', 'float,string'], $
    [flt,'F8.1',    'EXPOSURE',    'a16','a8', 'float,string'], $
    [flt,flt,    'TSYS',        'a16','a16', 'float,string'], $
    ['i10','i10','NSAVE',       'a10','a10', 'integer,string'], $
    ['a16','a16','PROCSCAN',    'a16','a16', 'string'], $
    ['a16','a16','PROCTYPE',    'a16','a16', 'string'], $
    ['a16','a16','WCALPOS',     'a16','a16', 'string'] $
    ]
    
    ; indicies into above array showing what to print when NOT in verbose mode
    ; These should match up to the following:
    ; INDEX
    ; SOURCE
    ; SCAN
    ; PROCEDURE
    ; POLARIZATION
    ; IFNUM
    ; FDNUM
    ; INT
    ; SIG
    ; CAL
    *self.frmt_quiet = [0,5,10,6,11,13,15,16,18,19]
    
    ; use the above arrays to create format strings
    self->create_formats

    ; remove the '1x' format separators after INDEX and ROW
    ; this allows up to 1 more digit to be used for those fields
    ; without forcing a new INDEX version.
    ; this is VERY ad-hoc
    

    return,1
    
END

;+
; Uses format array to create format strings for printing/reading index file.
; Results get stored in object fields: format_string, format_header 
; @private
;-
PRO LINE_INDEX_SECTION::create_formats
    compile_opt idl2

    ; this specialization exists to remove the '1x' spacing that would
    ; otherwise appear between INDEX/PROJECT and ROW/SOURCE
    frmt = *self.frmt
    frmt_quiet = *self.frmt_quiet
    
    ; how many keywords?
    sz = size(frmt)
    frmt_len = sz[2]
    
    ; build the format strings used for reading/writing index file
    param_types = strarr(2,frmt_len)
    header_keywords = strarr(frmt_len)
    data_format='('
    header_format='('
    ; the need for these additional forms of data_format is to allow
    ; IDL to follow the same behavior that python follows when the 
    ; index and row fields get long.
    ; This is a kludge only relevent until the next version change
    ; of the index.  At which point all rows should be written 
    ; with data_format and the local implementations of write_rows
    ; and overwrite_row can be eliminated.
    old_data_format='('  ; both index and row are i6 with 1x between
    data_format_long_index = '(' ; only index is i7 with no 1x following
    data_format_long_row = '(' ; only row is i7 with no 1x following
    self.tsStart = 0
    self.tsLen = -1
    for i=0,frmt_len-1 do begin
        thisFrmt= frmt[*,i]
        name = frmt[self.column_name,i]
        ; remove leading #
        if strmid(name,0,1) eq "#" then name=strmid(name,1,strlen(name)-1)
        ; and trailing #
        if strmid(name,0,1,/reverse_offset) eq "#" then name=strmid(name,0,strlen(name)-1)
        if (i ne 0) then begin 
           ; add spaces except befor PROJECT and SOURCE as appropriate.
           ; i.e. after #INDEX# and ROW
           ; the old format always gets the 1x
           old_data_format += ',1x,'
           if self.tsLen lt 0 then self.tsStart += 1
           if name eq 'PROJECT' then begin
              ; the long INDEX forms do not get the 1x
              data_format += ','
              data_format_long_index += ','
              ; the short one does
              data_format_long_row += ',1x,'
              ; the header never does - single format for the header
              header_format += ','
           endif else begin
              if name eq 'SOURCE' then begin
                 ; the long ROW forms do not get the 1x
                 data_format += ','
                 data_format_long_row += ','
                 ; the short one does
                 data_format_long_index += ',1x,'
                 ; the header never does - single format for the header
                 header_format += ','
              endif else begin
                 data_format += ',1x,'
                 data_format_long_row += ',1x,'
                 data_format_long_index += ',1x,'
                 header_format += ',1x,'
              endelse
           endelse
        endif 
        ; set the format field for INDEX and ROW in the short
        ; long cases explicitly, i7 for the long, i6 for the short
        ; ignoring what's in self.index_value 
        if name eq 'INDEX' then begin
           data_format += 'i7'
           data_format_long_index += 'i7'
           old_data_format += 'i6'
           data_format_long_row += 'i6'
           if self.tsLen lt 0 then self.tsStart += 6
        endif else begin
           if name eq 'ROW' then begin
              data_format += 'i7'
              data_format_long_row += 'i7'
              old_data_format += 'i6'
              data_format_long_index += 'i6'
              if self.tsLen lt 0 then self.tsStart += 6
           endif else begin
              data_format += frmt[self.index_value,i]
              old_data_format += frmt[self.index_value,i]
              data_format_long_row += frmt[self.index_value,i]
              data_format_long_index += frmt[self.index_value,i]
              if self.tsLen lt 0 then begin
                 frmtLen = long(strmid(frmt[self.index_value,i],1))
                 if name eq 'TIMESTAMP' then begin
                    self.tsLen = frmtLen
                 endif else begin
                    self.tsStart += frmtLen
                 endelse
              endif
           endelse
        endelse
        header_format += frmt[self.index_header,i]
        header_keywords[i] = frmt[self.column_name,i]
        param_types[0,i] = name
        param_types[1,i] = frmt[self.column_type,i] 
    endfor    

    data_format+=')'
    old_data_format += ')'
    data_format_long_index += ')'
    data_format_long_row += ')'
    header_format+=')'
    
    header = string(header_keywords,format=header_format)

    ; save off the format strings used for print/reading index file
    self.format_string = data_format
    self.old_format_string = old_data_format
    self.long_index_format_string = data_format_long_index
    self.long_row_format_string = data_format_long_row
    self.format_header = header
    *self.param_types = param_types

END

;+
; Returns the specail structure needed for spectal line data
; @returns line_row_info_strct structure
; @private
; -
FUNCTION LINE_INDEX_SECTION::get_row_info_strct

    @line_row_info
    return, {line_row_info_strct}

END

;+
; Trims whitespace from structure string fields that represent columns in an
; index file
; @param rows {in}{required}{type=array} string array of index column values
;-
PRO LINE_INDEX_SECTION::trim_row_whitespace, rows
    compile_opt idl2, hidden
    
    rows.project = strtrim(rows.project,2)
    rows.file = strtrim(rows.file,2)
    rows.source = strtrim(rows.source,2)
    rows.procedure = strtrim(rows.procedure,2)
    rows.polarization = strtrim(rows.polarization,2)
    rows.cal_state = strtrim(rows.cal_state,2)
    rows.sig_state = strtrim(rows.sig_state,2)
    rows.sampler = strtrim(rows.sampler,2)
    rows.timestamp = strtrim(rows.timestamp,2)
    rows.obsid = strtrim(rows.obsid,2)
    rows.procscan = strtrim(rows.procscan,2)
    rows.proctype = strtrim(rows.proctype,2)
    rows.wcalpos = strtrim(rows.wcalpos,2)

 END

;+
; Given a row structure, return the appropriate format for it
; based on the index and row value.  This is necessary only
; until the next version change to make sure the patch/hack necessary
; to read long index and long row values is backwards compatible 
; with this release of GBTIDL and this index version.
; @param row_struct {in}{required}{type=struct} The line index
; structure to use in determining which format string to return
; @returns format string
; @private
;-
FUNCTION LINE_INDEX_SECTION::get_format, row_struct
  compile_opt idl2, hidden

  frmt = self.format_string
  if row_struct.index lt 1e6 then begin
     ; short index options
     frmt = self.old_format_string
     if row_struct.row_num ge 1e6 then begin
        ; but row is still long
        frmt = self.long_row_format_string
     endif
  endif else begin
     ; long index options - OK as is unless
     if row_struct.row_num lt 1e6 then begin
        ; row is still short
        frmt = self.long_index_format_string
     endif
  endelse
  return, frmt
END
     
;+
; Writes the information in rows_structs to the index file using the
; current self.format_string.  Only needed here until next index
; version number change.
; @param row_strcts {in}{required}{type=struct array} the index values to
; write, in the same order as expected by the format string, one
; row_strcts element for each line to be written.
; @private
;-
PRO LINE_INDEX_SECTION::write_rows, row_strcts
    compile_opt idl2, hidden

    lines = strarr(n_elements(row_strcts))
    
    ; translate the structs to string lines
    for i=0,n_elements(lines)-1 do begin
        fmt = self->get_format(row_strcts[i])
        lines[i] = string(row_strcts[i],format=fmt) 
    endfor

    ; write the string lines to file
    self->append_lines, lines

    ; update the structures in memory
    if (n_elements(*self.rows) eq 0) then begin
        *self.rows = row_strcts
    endif else begin
        *self.rows = [*self.rows,row_strcts]
    endelse
END    

;+
; Overwrites a row in the index with a new one. Only needed here until
; next index version number change.
; 
; @param index_num {in}{required}{type=long} index number of row which is to be overwritten
; @param row {in}{required}{type=struct} new row to write in index file at index_num
;
; @uses get_line_number
;-
PRO LINE_INDEX_SECTION::overwrite_row, index_num, row
    compile_opt idl2, hidden

    line_number = self->get_line_number(index_num,row_index)

    if line_number eq -1 then message, "cannot overwrite row, index not found: "+string(index_num)

    fmt = self->get_format(row)
    new_line = string(row,format=fmt)

    ; write the new line to file and keep memory in sync
    self->set_line, line_number, new_line
    (*self.rows)[row_index] = row
    
 END

;+
; The ID is the index field used by index_iterator for this type
; of index to know how many rows to group in at each next call.
; For line_index it is the TIMESTAMP field.  This function returns the
; starting location, in each index line, of that field.
;
; @returns integer specifying the start of the ID field.
; @private
;-
FUNCTION LINE_INDEX_SECTION::get_id_start
  compile_opt idl2, hidden

  return,self.tsStart
END

;+
; The ID is the index field used by index_iterator for this type
; of index to know how many rows to group in at each next call.
; For line_index it is the TIMESTAMP field.  This function returns the
; length of that field.
;
; @returns integer specifying the length of the ID field.
; @private
;-
FUNCTION LINE_INDEX_SECTION::get_id_len
  compile_opt idl2, hidden

  return, self.tsLen
END
