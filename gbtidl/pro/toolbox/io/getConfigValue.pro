;+
; Parse a GBT config file (typically system.conf). 
; <p>
; Adapted from the getConfigValue.py used in sparrow.  This is needed
; by gbtidl so that the SDFITS_DATA value that the online sdfits
; daemon uses to decide where to write the sdfits files is the same as
; that used by GBTIDL to find the online sdfits files.
; <p>
; Returns the value of the named parameter as found in an environment
; variable having the same name, the config file, or the supplied
; default value (in that order). 
; <p>
; <b>Note :</b> the name value is always converted to upper case
; before any comparisons are made.
; <p>
; <b>Note :</b> if the path in configFile starts with a / then it is
; assumed to be the full path.  If it starts with any other character
; than the full path to the config file is <YGOR_TELESCOPE> +
; "/etc/config/ + configFile where <YGOR_TELESCOPE> is the value of
; the YGOR_TELESCOPE environment variable.
; 
; @param name {in}{required}{type=string} The parameter name.
; @keyword defaultValue {in}{optional}{type=string} The default value
; to return if name is not found in an environment variable or the
; config file.
; @keyword configFile {in}{optional}{type=string} The config file to
; use.  Defaults to "system.conf".
; @returns The value associated with name from an environment variable
; of the same name, or the named parameter in the config file, or the
; default value.
;
; @version $Id$
;-
function getConfigValue, name, defaultValue = defaultValue, configFile = configFile
    compile_opt idl2

    if n_elements(name) eq 0 then begin
        usage,'getConfigValue'
        return,''
    endif

    ; comparisons are all uppercase, don't change input parameter
    thisName = strupcase(name)

    ; try to get the value from the environment first
    result = getenv(thisName)
    if strlen(result) ne 0 then return, result

    ; Now try the config file

    ; default configFile, don't change input keyword
    if n_elements(configFile) eq 0 then begin
        thisConfigFile= "system.conf"
    endif else begin
        thisConfigFile = configFile
    endelse

    ; get the installation definition
    ygorTelescope = getenv('YGOR_TELESCOPE')

    ; open the configuration file
    if strmid(thisConfigFile,0,1) eq '/' then begin
        filename = thisConfigFile
    endif else begin
        filename = ygorTelescope + "/etc/config/" + thisConfigFile
    endelse

    if file_exists(filename) then begin

        openr, config_file_lun, filename, /get_lun

        ; get the configuration values
        keywords = {YGOR_TELESCOPE:ygorTelescope}
        line = ''
        while (eof(config_file_lun) ne 1) do begin
            readf, config_file_lun, line
            line = strtrim(line,2)
            if strlen(line) eq 0 or strmid(line,0,1) eq '#' then continue
            tokens = strsplit(line,':=',/extract)
            if n_elements(tokens) eq 2 then begin
                ; remove quotes
                parse = strsplit(tokens[1],'"',/extract,/preserve_null)
                if n_elements(parse) eq 3 then begin
                    value = parse[1]
                endif else begin
                    value = tokens[1]
                endelse
                newKeyword = strtrim(tokens[0],2)
                newValue = strtrim(value,2)
                kwNum = where(tag_names(keywords) eq strupcase(newKeyword))
                ; there have been at least one case of duplicate keywords
                ; in the config file, don't argue here, just reset it
                ; when a duplicate is found - last one in the file wins.
                if kwNum ge 0 then begin
                    keywords.(kwNum) = newValue
                endif else begin
                    keywords = create_struct(keywords, newKeyword, newValue)
                endelse
            endif else begin
                print,"Bad syntax in file ", filename, " : ", line
            endelse
        endwhile

        free_lun, config_file_lun

        kwNum = where(tag_names(keywords) eq thisName,cnt)
        if cnt gt 0 then return, keywords.(kwNum[0])
    endif

    ; just return the default value here
    if n_elements(defaultValue) gt 0 then return, defaultValue

    ; oops
    message,"No defined or default value for " + thisName
    return,''
end
