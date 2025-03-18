;+
; Base class for specifing a group of sdfits rows, grouped by file-extension.
; Used for communicating groups of rows between methods.
; @field file full path location of sdfits file
; @field extension extension number
; @field if_numbers pointer to list of if numbers for these rows
; @file_comments
; Base class for specifing a group of sdfits rows, grouped by file-extension.
; Used for communicating groups of rows between methods.
; @private_file
;-
PRO sdfits_row_group__define
   compile_opt idl2, hidden

    rg = { sdfits_row_group, $
    file:string(replicate(32B,256)), $
    extension:0L, $
    if_numbers:ptr_new() $
    }
    
END

