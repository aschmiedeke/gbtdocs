;+
; Parses comment lines like this one to create a sensible usage statement.
; Remember that more then one method can reside in a single .pro file, so
; the method keyword may be needed.
; 
; @param filename {in}{required}{type=string} full path name to the .pro file whose comments are to be parsed
;
; @keyword method {in}{optional}{type=string} the name of the method whose comments are to be parsed.
;
; @keyword verbose {in}{optional}{type=boolean} if not set, just the one line usage statement is returned, 
; if set, full comments, parameter descriptions and other methods used
; list are also returned.
;
; @returns the usage as a vector of strings.  See <a href="usage.html">usage</a>
; for an example where this function is used.
;
; @version $Id$
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

FUNCTION get_usage_lines, filename, method_line, method=method

    ; open and read the comments section of the file
    get_lun, lun
    openr, lun, filename

    lines = strarr(10000L)
    line = ''
    done = 0
    reading_section = 0
    section_read = 0
    method_line = ""
    linenum = 0L
    
    ; read the file until the end of file, or the first comment section + method name is read
    while (eof(lun) ne 1) and (done eq 0) do begin
        readf, lun, line
        first_chars = strmid(line,0,2)
        parts = strsplit(line, " ", /extract)
        first_word = parts[0]
        if first_chars eq ';+' then begin
            ; we've hit the beginning of the comment section
            reading_section = 1
        endif
        if first_chars eq ';-' then begin
            ; we've hit the end of the comment section
            section_read = 1
        endif
        if reading_section then begin
            ; make sure this begins with the comment tag
            if strmid(line,0,1) ne ';' then begin 
                print, "Malformed comment section with line: "+line
                if linenum gt 0 then begin
                    print,"Previous valid lines was : ", lines[linenum-1]
                    print,"At linenum = ", linenum
                endif
            endif else begin    
                lines[linenum] = line
                linenum += 1
                if section_read then reading_section = 0
            endelse    
        endif
        ; have we just read the declariation of a method?
        first_word = strupcase(first_word)
        if first_word eq "PRO" or first_word eq "FUNCTION" then begin
            parts = strsplit(line," ",/extract)
            if n_elements(parts) lt 2 then message, "malformed method line: "+line
            current_method = parts[1]
            ; rid the method name of any trailing commas
            comma_pos = strpos(current_method,",")
            if comma_pos ne -1 then current_method = strmid(current_method,0,comma_pos)
            if n_elements(method) eq 0 then begin
                ;if a method wasn't specified, use the first one found
                method_line = line
                done = 1
            endif else begin
                if strupcase(strtrim(method,2)) eq strupcase(strtrim(current_method,2)) then begin
                    ; this is the method we're looking for
                    method_line = line
                    done = 1
                endif else begin
                    ; this isn't the method we're looking for - keep searching
                    done = 0
                    lines = strarr(10000L)
                    reading_section = 0
                    section_read = 0
                    linenum = 0L
                endelse
            endelse    
        endif
    endwhile
   
    close, lun
    free_lun, lun


    ; free unused portions of arrays
    if (linenum gt 0) then begin
        lines = lines[0:(linenum-1)]
    endif    

    ; check if we found a comment section
    if linenum eq 0 then begin
       message, "No comment section found in file, try 'doc' instead of 'usage' for: "+filename, /info
       lines = ''
    endif

    ; check if we found the method name
    if method_line eq "" then begin
       message, "Method name not found in file: "+filename, /info
       lines = ''
    endif
    
    return, lines

end

FUNCTION construct_usage_from_lines, lines, method_line, verbose=verbose
    common examples_text,examples_lines

    usage = ""
    if n_elements(lines) eq 1 then begin
       if strlen(lines) eq 0 then return, usage
    endif
    
    ; now, parse the lines we read
    ; first, get the method name and type
    parts = strsplit(method_line, " ", /extract)
    if n_elements(parts) lt 2 then message, "Found malformed method in file: "+method_line
    method_type = strtrim(parts[0],2)
    method_name = strtrim(parts[1],2)
    ; rid the method name of any trailing commas
    comma_pos = strpos(method_name,",")
    if comma_pos ne -1 then method_name = strtrim(strmid(method_name,0,comma_pos),2)
    
    ; now, parse the comments section, skipping the first and last lines
    ; go through each line, and divide them between comments and tags
    in_tag = 0
    new_tag = 0
    tag_lines = ""
    for i=1,n_elements(lines)-2 do begin
        line = lines[i]
        tag_pos = strpos(line,"@")
        if tag_pos ne -1 then begin
            new_tag = 1
            in_tag = 1
        endif    
        if not in_tag then begin
            ; regular comment - get rid of the leading ';'
            line = strmid(line,1)
            line = strip_line_of_html(line)
            if n_elements(comments) eq 0 then comments=[line] else comments=[comments,line]
        endif else begin
            ; gather all lines for a tag until the next tag or blank line
            if new_tag then begin
                if tag_lines ne "" then begin
                    ; process the tag lines gathered up from the previous tag
                    tag_strct = parse_tag_line(tag_lines)
                    if n_elements(tag_strcts) eq 0 then tag_strcts=[tag_strct] else tag_strcts=[tag_strcts,tag_strct]
                    tag_lines = ""
                endif
                new_tag = 0
            endif
            ; append the lines, getting rid of the leading ';'
            tag_lines += ' '+strmid(line,1)
        endelse
    endfor
    
    ; we must process the last set of tag lines
    if tag_lines ne "" then begin
        tag_strct = parse_tag_line(tag_lines)
        if n_elements(tag_strcts) eq 0 then tag_strcts=[tag_strct] else tag_strcts=[tag_strcts,tag_strct]    
    endif
    
    ; construct the main usage line
    main_usage = "Usage: "
    if method_type eq "function" or method_type eq "FUNCTION" then method_fnc=1 else method_fnc=0
    if method_fnc then main_usage += " result = "
    main_usage += method_name
    if method_fnc then main_usage += "( "
    num_paramkeys = 0
    for i=0,n_elements(tag_strcts)-1 do begin
        tag = tag_strcts[i]
        if tag.tag_type eq "param" or  tag.tag_type eq "keyword" then begin
            if method_fnc eq 0 then begin
                if tag.optional then tagword = "[, " else tagword = ", "
            endif else begin
                if i eq 0 then begin
                    if tag.optional then tagword = "[ " else tagword = ""
                endif else begin
                    if tag.optional then tagword = "[, " else tagword = ", "
                endelse
            endelse
            if tag.tag_type eq "param" then begin
                tagword += tag.name
            endif else begin
                if strtrim(tag.type,2) eq "boolean" and tag.in eq 1 then begin
                    tagword += "/"+tag.name
                endif else begin
                    tagword += tag.name+"="+tag.name
                endelse
            endelse
            if tag.optional then tagword += " ] " else tagword += " "
            main_usage += tagword
        endif
    endfor
    if method_fnc then main_usage += " )"
    
    if not keyword_set(verbose) then begin
        return, main_usage
    endif

    usage = [main_usage,""]

    ; append comments
    usage = [usage,"Description:"]
    usage = [usage,""]
    for i=0,n_elements(comments)-1 do begin
        usage = [usage,comments[i]]
    endfor

    usage = [usage,"Parameters and Keywords: "]
    
    ; append param/keywords
    addExamples = 0
    for i=0,n_elements(tag_strcts)-1 do begin
        tag = tag_strcts[i]
        if tag.tag_type eq "param" or  tag.tag_type eq "keyword" then begin
            tag_line = ' '+tag.name
            for j=strlen(tag_line),12 do tag_line += ' '
            if tag.tag_type eq 'param' then addstring = 'parameter ('$
            else addstring = 'keyword   ('
            tag_line += " "+addstring
            ; characteristics to print?
            if tag.in ne -1 or tag.optional ne -1 or tag.type ne "" then begin
                tag_line += " "
                if tag.optional then tag_line+="optional, " else tag_line+="required, "
                if tag.in then tag_line+="input,  " else tag_line+="output, "
                if tag.type ne "" then tag_line+=tag.type+")"
            endif
            usage = [usage,""]
            usage = [usage,tag_line]
            ; comment to print?
            if strlen(tag.comment) lt 64 then $
               usage=[usage,'             '+tag.comment] $
            else begin
              description = tag.comment
              while strlen(description) gt 63 do begin
                for k=63,0,-1 do begin
                  if strmid(description,k,1) eq ' ' then begin
                     usage=[usage,'             '+strmid(description,0,k)]
                     description = strmid(description,k)
                     break
                  endif
                endfor
              endwhile
              usage = [usage,'             '+description]
            end
        endif else if tag_strcts[i].tag_type eq "examples" then begin
           ; Add the examples text exactly as it is in the code
            ; defer this so that @returns can come first
            addExamples = 1
        end
    endfor    

    ; append return value if this is a function
    if method_type eq "function" or method_type eq "FUNCTION" then begin
        for i=0,n_elements(tag_strcts)-1 do begin
            if tag_strcts[i].tag_type eq "returns" then begin 
                usage = [usage,""]
                thisComment = tag_strcts[i].comment
                if strlen(thisComment) lt 68 then begin
                    usage = [usage,"Returns: " + tag_strcts[i].comment]
                endif else begin
                    description = tag_strcts[i].comment
                    first = 1
                    while strlen(description) gt 68 do begin
                        for k=68,0,-1 do begin
                            if strmid(description,k,1) eq ' ' then begin
                                if first then begin
                                    usage=[usage,"Returns: "+strmid(description,0,k)]
                                    first = 0
                                endif else begin
                                    usage=[usage,"         "+strmid(description,0,k)]
                                endelse
                                description = strmid(description,k+1)
                                break
                            endif
                        endfor
                    endwhile
                    usage=[usage,"         "+description]
                endelse
            endif
        endfor
    endif    

    if addExamples then begin
        usage = [usage,""]
        usage = [usage,"Examples:"]
        for jj = 0,n_elements(examples_lines)-1 do usage = [usage,examples_lines[jj]]
        usage = [usage,""]
    endif

; The "uses" stuff is really for programmers more than users, so it is not included
; in the user docs prepared here.
;
;    uses_line = ""
;    for i=0,n_elements(tag_strcts)-1 do begin
;        tag = tag_strcts[i]
;        if tag.tag_type eq "uses" then begin
;            if uses_line eq "" then uses_line=tag.comment else uses_line+=","+tag.comment
;        endif
;    endfor
;    if uses_line ne "" then begin
;        uses_line = " uses : "+uses_line
;        usage = [usage, "" ]
;        usage = [usage,uses_line]
;    endif

    return, usage 

END   


FUNCTION parse_tag_line, tag_line

    tg = {tag_type:"",name:"",in:-1,optional:-1,type:"",default:"",comment:""}
    
    ; what kind is it? strip the tag type from @tag_type
    tag_pos = strpos(tag_line,"@")
    tag_line = strmid(tag_line,tag_pos)
    tag_line = strtrim(tag_line, 2)
    parts = strsplit(tag_line," ",/extract)
    tag_type = parts[0]
    tag_type = strmid(tag_type,1)
    tg.tag_type = strtrim(tag_type,2)
    
    case tag_type of
        "param" : begin
            tg = parse_param_line(tag_line,0) 
        end
        "keyword" : begin
            tg = parse_param_line(tag_line,1) 
        end
        "returns" : begin
            tg.comment = strip_line_of_html(strjoin(parts[1:n_elements(parts)-1], " "))
        end
        ;"private" : print, tag_type
        ;"private_file" : print, tag_type
        "uses" : begin
            tg.comment = strip_line_of_html(strjoin(parts[1:n_elements(parts)-1], " "))
        end
        ;"examples" : print, tag_type
        ;"version" :print, tag_type
        else: x = 1 ; do nothing 
    endcase    
    
    return, tg
END

FUNCTION parse_param_line, tag_line, key

    tg = {tag_type:"",name:"",in:-1,optional:-1,type:"",default:"",comment:""}

    if key eq 1 then tg.tag_type = "keyword" else tg.tag_type = "param"

    parts = strsplit(tag_line, " ", /extract)
    if n_elements(parts) lt 2 then message, "malformed param/keyword tag: "+tag_line
    tg.name = parts[1]

    ; parse any remaining info
    if n_elements(parts) gt 2 then begin
        remainder = strjoin(parts[2:n_elements(parts)-1], " ")
        ; parse any {}'s (I call them keys)
        more_keys = 1
        line_pos = 0
        while more_keys do begin
            start_key_pos = strpos(remainder,"{",line_pos)
            if start_key_pos ne -1 then begin
                ; where does this key end?
                end_key_pos = strpos(remainder,"}",line_pos)
                if end_key_pos eq -1 then message, "malformed tag line: "+tag_line
                ; extract the string between the {}'s
                key_value = strtrim(strmid(remainder,start_key_pos+1,end_key_pos-start_key_pos-1),2)
                ; parse the info in the {}'s
                equals_pos = strpos(key_value,"=")
                if equals_pos eq -1 then begin
                    case key_value of
                        "in":tg.in=1
                        "out":tg.in=0
                        "optional":tg.optional=1
                        "required":tg.optional=0
                        else: message, "malformed tag line: "+tag_line
                    endcase
                endif else begin
                    parts = strsplit(key_value,"=",/extract)
                    if strtrim(parts[0],2) ne "type" and strtrim(parts[0],2) ne "default" then message, "malformed tag line: "+tag_line
                    if strtrim(parts[0],2) eq "type" then begin
                        tg.type = strtrim(parts[1],2)
                    endif else begin
                        tg.default = strtrim(parts[1],2)
                    endelse    
                endelse
                ; prepare to look for the next set of {}'s
                line_pos = end_key_pos+1
            endif else begin
                more_keys = 0
            endelse
        endwhile
        ; any remaing stuff is the comment
        tg.comment = strip_line_of_html(strmid(remainder,line_pos))
    endif

    return, tg
END

FUNCTION strip_line_of_html, line
    ; find all the hypertext bracket (called keys) positions
    more_keys = 1
    line_pos = 0
    keys = lonarr(2,100)
    numkeys = 0
    while more_keys do begin
        start_key_pos = strpos(line,"<",line_pos)
        if start_key_pos ne -1 then begin
            ; where does this hypertext end?
            end_key_pos = strpos(line,">",line_pos)
            ; if end_key_pos eq -1 then message,"malformed tag line: "+line
            if end_key_pos eq -1 then begin
               ; assume no error, actual < sign used in comments
               more_keys = 0
            endif else begin
               keys[0,numkeys] = start_key_pos
               keys[1,numkeys] = end_key_pos
               numkeys += 1
               line_pos = end_key_pos + 1
            endelse
        endif else begin
            more_keys = 0
        endelse    
    endwhile
    ; if no html, return the original string
    if numkeys eq 0 then return, line
    ; now that we know where the brackets are, remove them
    ; construct an array of the positions of the substrings
    substrings = lonarr(2,100)
    start_sub = 0
    numsubs = numkeys
    for i=0,numsubs do begin
        substrings[0,i] = start_sub
        if i lt numsubs then begin
            ; this substring ends where the tag begins
            substrings[1,i] = keys[0,i] 
            ; the next substring begins where the tag ends
            start_sub = keys[1,i] + 1
        endif else begin
            substrings[1,i] = strlen(line)
        endelse    
    endfor
    ; construct the striped line
    striped_line = ""
    for i=0,numsubs do begin
        start = substrings[0,i]
        len = substrings[1,i] - substrings[0,i]
        striped_line += strmid(line,start,len)
    endfor
    return, striped_line
END

