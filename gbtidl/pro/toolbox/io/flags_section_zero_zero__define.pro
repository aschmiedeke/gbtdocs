PRO flags_section_zero_zero__define

    ris = { FLAGS_SECTION_ZERO_ZERO, $ 
        inherits flag_file_flags_section }

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::init, filename

    if n_elements(filename) ne 0 then begin
        r = self->FLAG_FILE_FLAGS_SECTION::init(filename)
    endif else begin    
        r = self->FLAG_FILE_FLAGS_SECTION::init()
    endelse
  
    self.deliminator = '|'
    self.not_applicable_symbol = '*'

    ; format  - name, header list format, value list format
    *self.frmt = [ $
    ['#RECNUM',      'a7','a7','integer','1'], $
    ['SCAN',         'a8','a8','integer','1'], $ 
    ['INTNUM',       'a8','a8','integer','1'], $ 
    ['BCHAN',       'a6','a6','scalar_integer','1'], $ 
    ['ECHAN',       'a6','a6','scalar_integer','1'], $ 
    ['IDSTRING',     'a36','a36','string','1'] ] 

    ; use the above arrays to create format strings for lists
    self->create_formats

    return, 1

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::get_row_info_strct
    compile_opt idl2, hidden

    x = {recnum:string(replicate(32B,256)), $
             scan:string(replicate(32B,256)), $
             intnum:string(replicate(32B,256)), $ 
             bchan:string(replicate(32B,7)), $ 
             echan:string(replicate(32B,7)), $ 
             idstring:string(replicate(32B,256)) }
    return, x

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::convert_lines_to_strcts, lines
    compile_opt idl2, hidden

    dlm = self->get_deliminator()

    ; convert each line to a structure
    row_info = self->get_row_info_strct() 
    rows = replicate(row_info, n_elements(lines))
    for i=0,n_elements(lines)-1 do begin
        line = lines[i]
        line_parts = strsplit(line,dlm,/extract)
        rows[i].recnum = strtrim(line_parts[0],2)
        rows[i].scan   = strtrim(line_parts[1],2)
        rows[i].intnum = strtrim(line_parts[2],2)
        rows[i].bchan = strtrim(line_parts[3],2)
        rows[i].echan = strtrim(line_parts[4],2)
        rows[i].idstring = strtrim(line_parts[5],2)
    endfor
    
    return, rows 

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::get_flag_scan_options_string, intnum=intnum, bchan=bchan, echan=echan, idstring=idstring

    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()
    intnum_str = self->convert_set_flag_input_array(intnum)
    b = self->convert_set_flag_input_scalar(bchan)
    e = self->convert_set_flag_input_scalar(echan)
    id = self->convert_set_flag_input_scalar(idstring)

    options_string = intnum_str+dlm+b+dlm+e+dlm+id

    return, options_string

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::get_flag_rec_options_string, bchan=bchan, echan=echan, idstring=idstring

    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()
    b = self->convert_set_flag_input_scalar(bchan)
    e = self->convert_set_flag_input_scalar(echan)
    id = self->convert_set_flag_input_scalar(idstring)

    options_string = na+dlm+b+dlm+e+dlm+id

    return, options_string

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::create_flag_rec_string, recnum, _EXTRA=ex

    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()    
    recnum_str = self->convert_set_flag_input_array(recnum)    
    flagging_options_str = self->get_flag_rec_options_string(_EXTRA=ex)
    flag_str = ' '+recnum_str+dlm+na+dlm+flagging_options_str
    return, flag_str

END

FUNCTION FLAGS_SECTION_ZERO_ZERO::create_flag_scan_string, scan, _EXTRA=ex 

    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()
    scan_str = self->convert_set_flag_input_array(scan)
    options_string = self->get_flag_scan_options_string(_EXTRA=ex)
    flag_string = " "+na+dlm+scan_str+dlm+options_string
    return, flag_string

END
