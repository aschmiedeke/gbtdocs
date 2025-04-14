; docformat = 'rst' 

;+
; Parses comment lines like this one to create a sensible usage statement.
; Remember that more then one method can reside in a single .pro file, so
; the method keyword may be needed.
; 
; :Params:
;   filename : in, required, type=string
;       full path name to the .pro file whose comments are to be parsed
;
; :Keywords:
;   method : in, optional, type=string
;       the name of the method whose comments are to be parsed.
;
;   verbose : in, optional, type=boolean
;       if not set, just the one line usage statement is returned, if set,
;       full comments, parameter descriptions and other methods used list 
;       are also returned.
;
; :Returns:
;   the usage as a vector of strings. See :idl:pro:`usage` for an example 
;   where this function is used.
;
;-
FUNCTION get_usage, filename, method=method, verbose=verbose
    compile_opt idl2
    common examples_text,examples_lines

    ; we must make these calls so that these methods get compiled
    tg = parse_tag_line(" @keyword test {in}{optional}{type=boolean} a test keyword")
    tg = parse_param_line(" @keyword test {in}{optional}{type=boolean} a test keyword",1)
    l =  strip_line_of_html(" no html here ")


    if n_elements(filename) eq 0 then message, "must provide filename"
    if file_exists(filename) eq 0 then message, "cannot find file: "+filename

    lines = get_usage_lines(filename, method_line, method=method)

    ; extract and save the examples text for later use
    ; Doing it here preserved the line breaks as they exist in the code docs
    tmp_lines = [" "]
    for i=0,n_elements(lines)-1 do begin
        if strmatch(lines[i],'*@example*') eq 1 then begin
           for j=i+1,n_elements(lines)-2 do begin
               if strmatch(lines[j+1],'*@*') eq 1 then begin
                   break
               endif else begin
                   tmp_lines = [tmp_lines,lines[j]] 
               endelse
           endfor
           tmp_lines = tmp_lines[0:n_elements(tmp_lines)-1]
        endif
    endfor
    examples_lines = [" "]
    preIsOff = 1
    for i=0,n_elements(tmp_lines)-1 do begin
        result = strmatch(tmp_lines[i],'*pre>*')
        if result eq 1 then begin
            ; toggle state of preIsOff
            ; in IDL, odd integers are true
            preIsOff += 1
        endif else begin
            thisLine = strmid(tmp_lines[i],1)
            if preIsOff then thisLine = strip_line_of_html(thisLine)
            examples_lines = [examples_lines,thisLine]
        endelse
    endfor
    examples_lines = examples_lines[1:n_elements(examples_lines)-1]

    usage = construct_usage_from_lines(lines, method_line, verbose=verbose)

    return , usage
END
