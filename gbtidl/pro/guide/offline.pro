;+ Used internally in offline
; If a data (fits) file or data directory containing at least one 
; fits file exists in directory for the given project and type then
; this routine returns the path to either the fits file or the data
; directory found in directory.  If it does not exist, this returns
; an empty string.
;
; @param directory {in}{required}{type=string} Directory to search
; in.  Typically this is the the root directory where the online
; sdfits files are written for each project.  Project directories are
; assumed to be a subdirectory of directory.
; @param project {in}{required}{type=string} The project name to
; search for.  The directory <directory>/<project> must exist for this
; function to return any non-empty string.
; @param type {in}{required}{type=string} The backend short-hand to
; use in constructing the filename to search for in the project
; directory.  This searches for <project>.raw.<type>.fits or a
; directory named <project>.raw.<type> that also contains at least one
; *.fits file.
; @returns The found file or directory name or an empty string if
; nothing was found.
;
; @private
;-
function project_exists, directory, project, type
    compile_opt idl2

    result = ""
    projectDir = directory + "/" + project
    if file_test(projectDir,/directory) then begin
        ; project directory exists
        fitsName = projectDir + '/' + project + '.raw.' + type + '.fits'
        if file_test(fitsName) eq 1 then begin
            ; found
            result = fitsName
        endif else begin
            ; try a directory instead
            fitsDir = projectDir + '/' + project + '.raw.' + type
            if file_test(fitsDir,/directory) then begin
                ; and is there at least one fits file there
                tmp = file_search(fitsDir,'*.fits',count=count)
                if count gt 0 then begin
                    ; found
                    result = fitsDir
                endif
            endif
        endelse
    endif
    return,result
end

;+
; This is a convenient way to find the previously auto-filled data
; for the indicated project and backend in the standard online data
; location when used in Green Bank.
; <p>
; Provide a project name and optionally the backend type (acs, vegas,
; or sp) to connect to file or directory in the online data directory
; (/home/sdfits) for that project and backend.
; Note that this file will not be treated as online, and will not be
; updated, just as filein does not do automatic updates.  Continuum is
; not supported. 
; <p>In addition to being less typing, using offline ensures that
; should the location of the automatically generated sdfits files move
; at any point, you don't have to know where they were moved to - the
; Green Bank installation of GBTIDL will always know where to find
; them. 
;
; @param project {in}{required}{type=string} The project name to use
; in constructing the filename'.
; @keyword acs {in}{optional}{type=boolean} the most recent
; spectrometer sdfits file will be connected. This is the default.
; @keyword sp {in}{optional}{type=boolean} the most recent spectral
; processor sdfits file will be connected to.
; @keyword vegas {in}{optional}{type=boolean} the most recent vegas
; sdfits directory will be connected.
;
; @examples
; <pre>
;    offline,'AGBT02A_028_05'  ; opens ACS data for this project
; </pre>
;
; @version $Id$
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
