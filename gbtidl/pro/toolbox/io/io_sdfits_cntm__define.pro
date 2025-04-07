;+
; IO_SDFITS_CNTM is intended for end users wishing to work with continuum data. It's the child class of IO_SDFITS used for reading, writing, 
; navigating sdfits continuum files, and for
; translating their info to continuum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
;
; @file_comments
; IO_SDFITS_LINE is intended for end users wishing to work with continuum data. It's the child class of IO_SDFITS used for reading, writing, 
; navigating sdfits continuum line files, and for
; translating their info to continuum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
; @uses <a href="cntm_index__define.html">LINE_INDEX</a>
; @uses <a href="cntm_sdfits__define.html">SDFITS</a>
;
; @inherits io_sdfits 
;
; @version $Id$
;-
PRO io_sdfits_cntm__define
    compile_opt idl2, hidden

    ioc = { io_sdfits_cntm, inherits io_sdfits }

END    


;+
; This function searches the index file using the keyword parameters passed
; into it, reads the appropriate parts of the sdfits files, and tranlates this
; data into continuum structures, which are returned.
; 
; @keyword _EXTRA {in}{optional} see <a href="cntm_index__define.html">search_for_row_info</a> for more info 
; @param count {out}{optional}{type=long} number of continua returned
;
; @returns Array of spectrum structures 
;
; @examples
; <pre>
; </pre>
;
; @uses CNTM_INDEX::search_for_row_info
; @uses IO_SDFITS_CNTM::get_continua_from_group
;
; @version $Id$
;-
FUNCTION IO_SDFITS_CNTM::get_continua, _EXTRA=ex, count, indicies

    if self.index->validate_search_keywords(ex) eq 0 then begin
        count = 0
        return, -1
    endif   

    if self->check_search_param_syntax(_EXTRA=ex) eq 0 then begin
        count = 0
        return, -1
    endif

    row_info = self.index->search_for_row_info(_EXTRA=ex, indicies) ;pol='XX')

    if (size(row_info,/dimension) eq 0) then begin
        count = 0
        return, -1
    endif   

    ; set this here, the continua may not be returned in the order in which
    ; there were discovered via row_info, use that one to know
    ; what was last, indicies then is reset to reflect the returned order
    self.last_record = indicies[n_elements(indicies)-1]

    groups = self->group_row_info(row_info)

    for i=0,n_elements(groups)-1 do begin
       group = groups[i]
       continua = self->get_continua_from_group(group)
       if (i eq 0) then begin
          all_cntm=[continua] 
          indicies = [*groups[i].index]
       endif else begin
          all_cntm=[all_cntm,continua]
          indicies = [temporary(indicies),*groups[i].index]
       endelse
    endfor

    self->free_group_row_info, groups
    
    count = n_elements(continua)

    return, continua

END

;+
; Stub method for updating the index file. TBD.
;-
PRO IO_SDFITS_CNTM::load_new_sdfits_rows
    compile_opt idl2

    message, "load_new_sdfits_rows not implemented yet for continuum", /info

END    

;+
; Stub method for updating the index file. TBD.
;-
PRO IO_SDFITS_CNTM::update
    compile_opt idl2

    message, "update not implemented yet for continuum", /info

END    

;+
; Stub method for updating the index file. TBD.
;-
PRO IO_SDFITS_CNTM::set_online, file_name
    compile_opt idl2

    message, "online mode not implemented yet for continuum", /info

END    

FUNCTION IO_SDFITS_CNTM::get_index_class_name
    compile_opt idl2

    return, "cntm_index"
END

FUNCTION IO_SDFITS_CNTM::get_index_section_class_name
  compile_opt idl2

  return, "cntm_index_section"
END
