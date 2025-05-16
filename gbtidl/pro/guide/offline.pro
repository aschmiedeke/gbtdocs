; docformat = 'rst'

;+
; This is a convenient way to find the previously auto-filled data
; for the indicated project and backend in the standard online data
; location when used in Green Bank.
; 
; Provide a project name and optionally the backend type (acs, vegas,
; or sp) to connect to file or directory in the online data directory
; (``/home/sdfits``) for that project and backend.
; Note that this file will not be treated as online, and will not be
; updated, just as filein does not do automatic updates.  Continuum is
; not supported. 
; In addition to being less typing, using offline ensures that
; should the location of the automatically generated sdfits files move
; at any point, you don't have to know where they were moved to - the
; Green Bank installation of GBTIDL will always know where to find
; them. 
;
; :Params:
;   project : in, required, type=string
;       The project name to use in constructing the filename'.
;   acs : in, optional, type=boolean
;       the most recent spectrometer sdfits file will be connected. 
;       This is the default.
; 
; :Keywords:
;   sp : in, optional, type=boolean
;       the most recent spectral processor sdfits file will be connected to.
;   vegas : in, optional, type=boolean
;       the most recent vegas sdfits directory will be connected.
;
; :Examples:
; 
;   .. code-block:: IDL
;
;       offline,'AGBT02A_028_05'  ; opens ACS data for this project
;
;-
pro offline, project, acs=acs, sp=sp, vegas=vegas
    compile_opt idl2

    if n_elements(project) eq 0 then begin
        message, "Must supply a project name", /info
        return
    endif

    if !g.line eq 0 then begin
        message, "Contnuum mode not supported for this command", /info
        return
    endif

    ; is the online dir visible from here?
    dir = getConfigValue("SDFITS_DATA",defaultValue="/home/sdfits")
    if file_test(dir) eq 0 then begin
        message, "online directory not visible: "+dir, /info
        return
    endif

    ; what type of backend should we connect to?
    use_acs = 0
    use_sp  = 0
    use_vegas = 0
    use_acs = keyword_set(acs)
    use_sp = keyword_set(sp)
    use_vegas = keyword_set(vegas)
    key_used = use_acs + use_sp + use_vegas
    if (key_used gt 1) then begin
        message, "Only one of /acs, /sp, and /vegas can be used at a time", /info
        return
    endif

    if key_used eq 0 then begin
        use_acs = 1
    endif

    if use_acs then begin
        type = 'acs' 
    endif else begin
        if use_vegas then begin
            type = 'vegas'
        endif else begin
            type = 'sp'
        endelse
    endelse

    filename = project_exists(dir,project,type)
    if strlen(filename) eq 0 then begin
        if key_used eq 0 then begin
            if strlen(filename) eq 0 and use_acs eq 0 then begin
                type = 'acs'
                filename = project_exists(dir,project,type)
            endif

            if strlen(filename) eq 0 and use_vegas eq 0 then begin
                type = 'vegas'
                filename = project_exists(dir,project,type)
            endif

            if strlen(filename) eq 0 and use_sp eq 0 then begin
                type = 'sp'
                filename = project_exists(dir,project,type)
            endif

            if strlen(filename) eq 0 then begin
                message,"No spectral-line data found for that project in the online directory (project correct?): "+ project,/info
            endif
        endif else begin
            message,"No spectral line data for type="+type+" found for that project in the online directory (project and type correct?): "+ project,/info
        endelse
    endif

    if strlen(filename) gt 0 then begin
        print, "Connecting to file: "+filename
        ; finally, connect to the file
        ; directories will be properly handled by filein
        filein, filename
    endif
end


