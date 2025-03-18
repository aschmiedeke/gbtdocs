;+
; FLAGS_SECTION_ONE_ZERO is a child class of FLAG_FILE_FLAGS_SECTION and extends
; that abstract class in order to impliment the flagging file format 1.0.
; Here can be found the actual values for the columns in the flag file, and 
; how the lines for the flag files are converted to structures and vice versa.
;-
PRO flags_section_one_zero__define

    ris = { FLAGS_SECTION_ONE_ZERO, $ 
        inherits flag_file_flags_section }

END

;+
; Class Constructor: here the actual format of the flag section is spelled out.
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::init, filename

    if n_elements(filename) ne 0 then begin
        r = self->FLAG_FILE_FLAGS_SECTION::init( filename)
    endif else begin    
        r = self->FLAG_FILE_FLAGS_SECTION::init()
    endelse
  
    self.deliminator = '|'
    self.not_applicable_symbol = '*'

    ; format  - name, header list format, value list format, in flag file
    *self.frmt = [ $
    ['#RECNUM',      'a7','a7','integer','1'], $
    ['SCAN',         'a11','a11','integer','1'], $ 
    ['INTNUM',       'a9','a9','integer','1'], $ 
    ['PLNUM',       'a5','a5','integer','1'], $ 
    ['IFNUM',       'a7','a7','integer','1'], $ 
    ['FDNUM',       'a5','a5','integer','1'], $ 
    ['BCHAN',       'a6','a6','integer','1'], $ 
    ['ECHAN',       'a6','a6','integer','1'], $ 
    ['IDSTRING',    'a12','a12','string','1'] , $
    ['CHANS',       'x','x','integer','0'], $
    ['CHANWIDTH',       'x','x','scalar_integer','0'] ]

    ; use the above arrays to create format strings for lists
    self->create_formats

    return, 1

END

;+
; Here the actual structure that represents a line in the flag file is
; spelled out. 
; @returns a structure representing a line in the flag section
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::get_row_info_strct
    compile_opt idl2, hidden

    x = {recnum:string(replicate(32B,256)), $
         scan:string(replicate(32B,256)), $
         intnum:string(replicate(32B,256)), $ 
         plnum:string(replicate(32B,256)), $ 
         ifnum:string(replicate(32B,256)), $ 
         fdnum:string(replicate(32B,256)), $ 
         bchan:string(replicate(32B,7)), $ 
         echan:string(replicate(32B,7)), $ 
         idstring:string(replicate(32B,256)) }
    return, x

END

;+
; Spells out how a line in a flag file is converted from a string
; to a structure
; @param lines {in}{required}{type=string} lines in flag file
; @returns array of flag structures
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::convert_lines_to_strcts, lines
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
        rows[i].plnum = strtrim(line_parts[3],2)
        rows[i].ifnum = strtrim(line_parts[4],2)
        rows[i].fdnum = strtrim(line_parts[5],2)
        rows[i].bchan = strtrim(line_parts[6],2)
        rows[i].echan = strtrim(line_parts[7],2)
        rows[i].idstring = strtrim(line_parts[8],2)
    endfor
    
    return, rows 

END

;+
; Spells out how to convert the set_flag_rec command options into an acutal string
; to be written to the flag file.
; @returns string to be written to flag file
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::create_flag_rec_string, recnum, _EXTRA=ex
    compile_opt idl2, hidden

    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()    
    recnum_str = self->convert_set_flag_input_array(recnum)    
    flagging_options_str = self->get_flag_rec_options_string(_EXTRA=ex)
    flag_str = ' '+recnum_str+dlm+na+dlm+flagging_options_str
    return, flag_str

END

;+
; Spells out how to convert the set_flag command options into an acutal string
; to be written to the flag file.
; @returns string to be written to flag file
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::create_flag_scan_string, scan, _EXTRA=ex 
    compile_opt idl2, hidden

    dlm = self.deliminator
    na = self.not_applicable_symbol
    scan_str = self->convert_set_flag_input_array(scan)
    options_string = self->get_flag_scan_options_string(_EXTRA=ex)
    flag_string = " "+na+dlm+scan_str+dlm+options_string
    return, flag_string

END

;+
; Spells out the actuall keywords ultimately accepted by the set_flag command. Here 
; each keyword is converted to its string equivalent, and concated togethor with 
; the deliminator character to create a bulk of the line representing the flagging
; rule found in the flag file. CHANS and CHANWIDTH are mutually exclusive to BCHAN
; and ECHAN, but all these keywords should have validated higher up the chain.
; @keyword intnum {in}{optional}{type=long} integration number(s)
; @keyword plnum {in}{optional}{type=long} polarization number(s)
; @keyword fdnum {in}{optional}{type=long} feed number(s)
; @keyword ifnum {in}{optional}{type=long} IF number(s)
; @keyword bchan {in}{optional}{type=long} channel(s) to start flagging
; @keyword echan {in}{optional}{type=long} channel(s) to stop flagging
; @keyword chans {in}{optional}{type=long} channel(s) to flag
; @keyword chanwidth {in}{optional}{type=long} buffer to use with CHANS (default=1)
; @keyword idstring {in}{optional}{type=string} IDSTRING
; @returns a string representing the bulk of this flagging rule, to be put in flag file.
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::get_flag_scan_options_string, intnum=intnum, plnum=plnum, fdnum=fdnum, ifnum=ifnum, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=idstring
    compile_opt idl2, hidden

    chan = self->check_channels(bchan, echan, chans, chanwidth, status)
    b = chan[0]
    e = chan[1]
    
    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()
    intnum_str = self->convert_set_flag_input_array(intnum)
    plnum_str = self->convert_set_flag_input_array(plnum)
    fdnum_str = self->convert_set_flag_input_array(fdnum)
    ifnum_str = self->convert_set_flag_input_array(ifnum)
    id = self->convert_set_flag_input_scalar(idstring)

    options_string = intnum_str+dlm+plnum_str+dlm+ifnum_str+dlm+fdnum_str+dlm+b+dlm+e+dlm+id

    return, options_string

END

;+
; Spells out the actuall keywords ultimately accepted by the set_flag_rec command. 
; Here each keyword is converted to its string equivalent, and concated togethor with 
; the deliminator character to create a bulk of the line representing the flagging
; rule found in the flag file. CHANS and CHANWIDTH are mutually exclusive to BCHAN
; and ECHAN, but all these keywords should have validated higher up the chain.
; @keyword bchan {in}{optional}{type=long} channel(s) to start flagging
; @keyword echan {in}{optional}{type=long} channel(s) to stop flagging
; @keyword chans {in}{optional}{type=long} channel(s) to flag
; @keyword chanwidth {in}{optional}{type=long} buffer to use with CHANS (default=1)
; @keyword idstring {in}{optional}{type=string} IDSTRING
; @returns a string representing the bulk of this flagging rule, to be put in flag file.
;-
FUNCTION FLAGS_SECTION_ONE_ZERO::get_flag_rec_options_string, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=idstring
    compile_opt idl2, hidden

    chan = self->check_channels(bchan, echan, chans, chanwidth, status)
    b = chan[0]
    e = chan[1]

    dlm = self->get_deliminator()
    na = self->get_not_applicable_symbol()
    id = self->convert_set_flag_input_scalar(idstring)

    options_string = na+dlm+na+dlm+na+dlm+na+dlm+b+dlm+e+dlm+id

    return, options_string

END

