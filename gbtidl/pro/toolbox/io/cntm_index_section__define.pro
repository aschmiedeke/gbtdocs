;+
; This class extends the rows_index_section class to properly manage the rows section 
; for a continuum index file; that is, an index file where each row line represents
; a continuum.
;
; @file_comments
; This class extends the rows_index_section class to properly manage the rows section 
; for a continuum index file; that is, an index file where each row line represents
; a continuum.
;
; @inherits rows_index_section
; @private_file
;
;-
PRO cntm_index_section__define

    ifile = { CNTM_INDEX_SECTION, inherits ROWS_INDEX_SECTION, $
              scanStart:0, $
              scanLen:0 $
            }

END
;+
; Class Constructor
; Here the formats for the rows are determined: how to list them verbosly and
; quietly.
; @private
;-
FUNCTION CNTM_INDEX_SECTION::init, filename

    r = self->ROWS_INDEX_SECTION::init(filename)

    ; array that contains all info needed for printing out info + header
    ; ***NOTE: this order must follow the order of {cntm_row_info_strct}
    *self.frmt = [ $
    ['i6','i6',  '#INDEX',      'a6','a6', 'integer,string'], $
    ['a16','a16','PROJECT',     'a16','a16', 'string'], $ 
    ['a64','file_name','FILE',  'a64','a32', 'string'], $
    ['i3','i3',  'EXTENSION',   'a3','a3', 'integer,string'], $
    ['i8','i8',  'FIRSTROW',    'a8','a8', 'integer,string'], $
    ['i7','i7',  'NUMROWS',     'a7','a7', 'integer,string'], $
    ['i6','i6',  'STRIDE',      'a6','a6', 'integer,string'], $
    ['a32','source_name','SOURCE', 'a32','a16', 'string'], $
    ['a9','a9',  'PROCEDURE',   'a9','a9', 'string'], $
    ['a32','a32','OBSID',       'a32','a32','string'], $
    ['i5','i5',  'E2ESCAN',     'a5','a5', 'integer,string'], $
    ['i5','i5',  'PROCSEQN',    'a5','a5', 'integer,string'], $
    ['i10','i10','SCAN',        'a10','a10', 'integer,string'], $
    ['a3','a3',  'POLARIZATION','a3','a3', 'string'], $
    ['i5','i5',  'IFNUM',       'a5','a5', 'integer,string'], $
    ['e16.9','sexigesimal','TRGTLONG','a16','a12','float,string'], $
    ['e16.9','sexigesimal','TRGTLAT','a16','a12','float,string'], $
    ['a3','a3',  'SIG',         'a3','a3', 'string'], $
    ['a3','a3',  'CAL',         'a3','a3', 'string'], $
    ['i10','i10','NSAVE',       'a10','a10', 'integer,string'], $
    ['a16','a16','PROCSCAN',    'a16','a16','string'], $
    ['a16','a16','PROCTYPE',    'a16','a16','string'] $
    ]
    
    ; indicies into above array showing what to print when NOT in verbose mode
    *self.frmt_quiet = [0,7,11,8,12]
    
    ; all floats and doubles have the same format
    self.float_format = 'e16.9'

    ; use the above arrays to construct format and header strings
    self->create_formats, 'SCAN', scanStart, scanLen
    self.scanStart = scanStart
    self.scanLen = scanLen

    return, r

END

;+
; Returns the specail structure needed for spectral cntm data
; @returns cntm_row_info_strct structure
; @private
; -
FUNCTION CNTM_INDEX_SECTION::get_row_info_strct

    @cntm_row_info
    return, {cntm_row_info_strct}

END

;+
; Trims whitespace from structure string fields that represent columns in an
; index file
; @param rows {in}{required}{type=array} string array of index column values
;-
PRO CNTM_INDEX_SECTION::trim_row_whitespace, rows
    compile_opt idl2, hidden

    rows.project = strtrim(rows.project,2)
    rows.file = strtrim(rows.file,2)
    rows.source = strtrim(rows.source,2)
    rows.procedure = strtrim(rows.procedure,2)
    rows.polarization = strtrim(rows.polarization,2)
    rows.cal_state = strtrim(rows.cal_state,2)
    rows.sig_state = strtrim(rows.sig_state,2)  
    rows.obsid = strtrim(rows.obsid,2)
    rows.procscan = strtrim(rows.procscan,2)
    rows.proctype = strtrim(rows.proctype,2)

END

;+
; The ID is the index field used by index_iterator for this type
; of index to know how many rows to group in at each next call.
; For cntm_index it is the SCAN field.  This function returns the
; starting location, in each index line, of that field.
;
; @returns integer specifying the start of the ID field.
; @private
;-
FUNCTION CNTM_INDEX_SECTION::get_id_start
  compile_opt idl2, hidden

  return,self.scanStart
END

;+
; The ID is the index field used by index_iterator for this type
; of index to know how many rows to group in at each next call.
; For cntm_index it is the SCAN field.  This function returns the
; length of that field.
;
; @returns integer specifying the length of the ID field.
; @private
;-
FUNCTION CNTM_INDEX_SECTION::get_id_len
  compile_opt idl2, hidden

  return, self.scanLen
END
