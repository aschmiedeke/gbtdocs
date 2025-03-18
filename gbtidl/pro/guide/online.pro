; docformat = 'rst'

;+
; Set the line io object to look at the online file.
; 
; The online file is determined by finding the most recently 
; updated spectral line file (ACS, VEGAS, or SP) in the online directory
; (/home/sdfits).  Once a file is connected to, this command must be
; used again to connect to a more recent spectral line sdfits file
; (from switching projects or switching backends).  The default is to
; use the most recent file for either spectral line backend.  Use one
; of the two keywords to attach to the most recent file for a specific
; backend.  If both keywords are true, a message will be printed and
; this procedure will return without changing the attached file.
; 
; Note that any file previously attached using "filein" or
; "offline" will be closed as a result of using this procedure.  There
; can be only one input spectral line data file at a time.
;
; The online file may be a directory of FITS files if the vegas
; backend is the most recently updated file or is chosen as an option
; here.
;
; :Keywords:
;
;   acs : in, optional, type=boolean
;       the most recent spectrometer sdfits file will be connected to. 
;
;   sp: in, optional, type=boolean
;       the most recent spectral processor sdfits file will be connected to.
; 
;   vegas: in, optional, type=boolean
;       the most recent vegas sdfits directory will be connected to.
;
;-
pro online, acs=acs, sp=sp, vegas=vegas
    compile_opt idl2
    
    if !g.line eq 0 then begin
        message, "Online continuum mode not supported", /info
        return
    endif

    ; get the info structs for all the possible files
    latest_info = !g.lineio->get_online_infos(acsi,dcri,spi,zpeci,vegasi,status)
    if status eq 0 then begin
        message, "Cannot find or read the online status file.  No online data available.", /info
        return
    endif
 
    ; should we connect to acs or sp fits files?
    use_acs = 0
    use_sp  = 0
    use_vegas = 0
    use_acs = keyword_set(acs)
    use_sp = keyword_set(sp)
    use_vegas = keyword_set(vegas)
    if (use_acs and use_sp or use_acs and use_vegas or use_sp and use_vegas) then begin
        message, "Only one of /acs and /sp and /vegas can be used at a time",/info
        return
    endif
    
    ; latest_info will be set to something if status is not 0
    info = latest_info
    if use_acs then begin
        if acsi.file eq "" then begin 
            message, "No spectrometer online fits file is available.", /info
            return
        endif
        info = acsi
    endif
    if use_sp then begin
        if spi.file eq "" then begin 
            message, "No spectral processor online fits file is available.", /info
            return
        endif
        info = spi
    endif
    if use_vegas then begin
        if vegasi.file eq "" then begin 
            message, "No VEGAS online fits directory is available.", /info
            return
        endif
        info = vegasi
    endif
        
    ; inform the user what is being used    
    print, "Connecting to file: "+info.file
    print, "File has not been updated in ",info.age," minutes.",format='(a29,f16.2,a9)'
    if info.file ne latest_info.file then begin
        print, "Latest file in online directory: "+latest_info.file
        print,'  use: "online, /' + strtrim(latest_info.backend,2) + '" to attach to that file'
    endif    

    new_io = obj_new("io_sdfits_line")
    if (obj_valid(new_io)) then begin
        if (obj_valid(!g.lineio)) then obj_destroy, !g.lineio
        !g.lineio = new_io
    endif

    ; finally, load this file in online mode
    !g.lineio->set_online, info.file
    !g.line_filein_name = info.file

end    
