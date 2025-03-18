;+
; Child of sdfits_row_group, contiains fields specific only to spectral line data.  Used for communicating groups of rows between methods.
; @field rows pointer to list of row numbers for this group
; @field integrations pointer to list of integration numbers for this group.
; @file_comments
; Child of sdfits_row_group, contiains fields specific only to spectral line data.  Used for communicating groups of rows between methods.
; @inherits sdfits_row_group
; @private_file
;-
PRO line_sdfits_row_group__define
   compile_opt idl2, hidden

    lrg = { line_sdfits_row_group, $
    inherits sdfits_row_group, $
    rows:ptr_new(), $
    integrations:ptr_new(), $
    feed_nums:ptr_new(), $
    pol_nums:ptr_new(), $
    nsaves:ptr_new(), $
    index:ptr_new() $
    }
    
END

