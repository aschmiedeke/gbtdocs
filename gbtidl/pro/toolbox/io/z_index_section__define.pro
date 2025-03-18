;+
; This class extends the rows_index_section class to properly manage the rows section 
; for a zpectrometer index file; that is, an index file where each row line represents
; one row of the raw data from the zpectrometer.
;
; @file_comments
; This class extends the rows_index_section class to properly manage the rows section 
; for a zpectrometer index file; that is, an index file where each row line represents
; one row of the raw data fromt he zpectrometer
;
; @inherits rows_index_section
;
; @private_file
;-

;+
; Class Constructor
; Here the formats for the rows are determined: how to list them verbosly and
; quietly.
; @private
;-
FUNCTION Z_INDEX_SECTION::init, filename

    r = self->ROWS_INDEX_SECTION::init(filename)

    ; all floats and doubles have the same format
    self.float_format = 'e16.9'
    flt = self.float_format
    
    ; array that contains all info needed for printing out info + header
    ; ***NOTE: this order must follow the order of {row_line_info_strct}
    ;i val, l val, column name, i head, l head
    *self.frmt = [ $
    ['i6', 'i6',            '#INDEX',   'a6', 'a6', 'integer,string'], $
    ['a16','a16',           'PROJECT',  'a16','a16','string'], $ 
    ['a64','file_name',     'FILE',     'a64','a32','string'], $
    ['i3', 'i3',            'EXTENSION','a3', 'a3', 'integer,string'], $
    ['i6', 'i6',            'ROW',      'a6', 'a6', 'integer,string'], $

    ['a32','source_name',   'SOURCE',   'a32','a16','string'], $
    ['a9', 'a9',            'PROCEDURE','a9', 'a9', 'string'], $
    ['i10','i10',           'MC_SCAN',  'a10','a10','integer,string'],$ 
    ['i7', 'i7',            'SUBSCAN', 'a7', 'a7', 'integer,string'], $
    ['i5', 'i5',            'SCAN',     'a5', 'a5', 'integer,string'], $

    ['i7', 'i7',            'BEINDEX',  'a7', 'a7', 'integer,string'], $ 
    [flt,  'F5.1',          'AZIMUTH',  'a16','a5', 'float,string'], $
    [flt,  'F4.1',          'ELEVATION','a16','a4', 'float,string'],$ 
    [flt,  'sexigesimal_ra','LONGITUDE','a16','a12','float,string'],$ 
    [flt,  'sexigesimal',   'LATITUDE', 'a16','a12','float,string'],$ 
    
    ['a22','a22',           'TIMESTAMP','a22','a22','string'],$ 
    [flt,  flt,             'EXPOSURE', 'a16','a16','float,string'],$ 
    ['a8', 'a8',            'TRCKBEAM', 'a8', 'a8', 'string'],$ 
    [flt,  flt,             'OBSFREQ',  'a16','a16','float,string'],$ 
    ['i5', 'i5',            'DIODE',    'a5', 'a5', 'integer,string'],$ 
    ['i3', 'i3',            'SUBREF',   'a3', 'a3', 'integer,string'] $
    ]
    
    ; indicies into above array showing what to print when 
    ; NOT in verbose mode
    ; These should match up to the following:
    ; INDEX
    ; SOURCE
    ; SCAN
    ; MC_SCAN
    ; BEINDEX
    ; DIODE
    *self.frmt_quiet = [0,5,9,7,10,19]
    
    ; uese the above arrays to create format strings
    self->create_formats, 'TIMESTAMP', tsStart, tsLen
    self.tsStart = tsStart
    self.tsLen = tsLen
    
    return,1
    
END

;+
; Returns the special structure needed for zpectrometer data
; @returns z_row_info_strct structure
; @private
; -
FUNCTION Z_INDEX_SECTION::get_row_info_strct

    @z_row_info
    return, {z_row_info_strct}

END

;+
; Trims whitespace from structure string fields that represent columns in an
; index file
; @param rows {in}{required}{type=array} string array of index column values
;-
PRO Z_INDEX_SECTION::trim_row_whitespace, rows
    compile_opt idl2, hidden
    
    ; get rid of annoying white space from file for 
    rows.project = strtrim(rows.project,2)
    rows.file = strtrim(rows.file,2)
    rows.source = strtrim(rows.source,2)
    rows.procedure = strtrim(rows.procedure,2)
    rows.trckbeam = strtrim(rows.trckbeam,2)
    rows.timestamp = strtrim(rows.timestamp,2)

END

;+
; Defines class structure
; @private
;-
PRO z_index_section__define
  ris = { Z_INDEX_SECTION, $
          inherits rows_index_section, $
          tsStart:0, $
          tsLen:0 $
        }
END

;+
; The ID is the index field used by index_iterator for this type
; of index to know how many rows to group in at each next call.
; For z_index it is the TIMESTAMP field.  This function returns the
; starting location, in each index line, of that field.
;
; @returns integer specifying the start of the ID field.
; @private
;-
FUNCTION Z_INDEX_SECTION::get_id_start
  compile_opt idl2, hidden

  return,self.tsStart
END

;+
; The ID is the index field used by index_iterator for this type
; of index to know how many rows to group in at each next call.
; For z_index it is the TIMESTAMP field.  This function returns the
; length of that field.
;
; @returns integer specifying the length of the ID field.
; @private
;-
FUNCTION Z_INDEX_SECTION::get_id_len
  compile_opt idl2, hidden

  return, self.tsLen
END
