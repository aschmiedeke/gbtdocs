;+
; Child of sdfits_row_group, contiains fields specific only to continuum data.  Used for communicating groups of rows between methods.  Special fields here reflect that data for continuum is interwoven and spread across rows in sdfits files.
; @field start_rows pointer to list of row numbers where data starts for this group
; @field num_rows pointer to list of how many rows for each continua
; @field strides pointer to list of step sizes to use when reading in continua
; @file_comments
; Child of sdfits_row_group, contiains fields specific only to continuum data.  Used for communicating groups of rows between methods.  Special fields here reflect that data for continuum is interwoven and spread across rows in sdfits files.
; @inherits sdfits_row_group
; @private_file
;-
PRO cntm_sdfits_row_group__define
   compile_opt idl2, hidden

    rgc = { cntm_sdfits_row_group, $
    inherits sdfits_row_group, $
    start_rows:ptr_new(), $
    num_rows:ptr_new(), $
    strides:ptr_new(), $
    index:ptr_new() $
    }
    
END

