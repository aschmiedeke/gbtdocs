;+
; ONLINE_STATUS_FILE is for internal use to support interactions with
; the status file produced by the online sdfits daemon in Green Bank.
;
; @file_comments
; ONLINE_STATUS_FILE is for internal use to support interactions with
; the status file produced by the online sdfits daemon in Green Bank.
;
; @uses online_status_info which declares the structure used to hold
; the information - online_status_info_strct
;
; @version $Id$
;
; @private_file
;-

;+
; defines class structure
; @private
;-
PRO online_status_file__define
    compile_opt idl2, hidden

    @online_status_info

    osf = { online_status_file, $
            status:0, $
            file:'', $
            onlinedir:'', $
            mtime:long64(0), $
            acs_info:{online_status_info_strct}, $
            dcr_info:{online_status_info_strct}, $
            sp_info:{online_status_info_strct}, $
            zpec_info:{online_status_info_strct}, $
            vegas_info:{online_status_info_strct} $
          }
END

;+
; Called at instantiation of this class.
; @param onlinedir {in}{required}{type=string} the location of the
; root of the file system where the online sdfits files are written,
; typically /home/sdfits.
; @returns 1 on success, 0 on failure (missing or bad status file).
; @uses online_sdfits_file::read
; @private
;-
FUNCTION ONLINE_STATUS_FILE::init, onlinedir
    compile_opt idl2, hidden

    self.onlinedir = onlinedir
    self.file = self.onlinedir + '/sdfitsStatus.txt'

    self->init_info, self.acs_info, 'acs'
    self->init_info, self.dcr_info, 'dcr'
    self->init_info,self.sp_info, 'sp'
    self->init_info, self.zpec_info, 'zpec'
    self->init_info, self.vegas_info, 'vegas'

    self.status = self->read()

    return, 1
END

;+
; Initialize an online_status_info_strct structure with the given
; backend name
; @private
;-
PRO ONLINE_STATUS_FILE::init_info, strct, backend
    compile_opt idl2, hidden
    strct.backend = backend
END

;+
; Read the status file and update in the info structures
; @returns 1 on success, 0 on failure (missing or bad status file).
; @private
FUNCTION ONLINE_STATUS_FILE::read
    compile_opt idl2, hidden

    if not file_test(self.file, /regular, /read) then begin
        ; error message goes here
        message,'The online status file is not available.  No online data can be found.',/info
        return, 0
    endif

    fi = file_info(self.file)
    self.mtime = fi.mtime

    statusInfo = {online_status_info_strct}

    line = ''
    
    openr, sfu, self.file, /get_lun
    ; read each line and decode
    while ~ EOF(sfu) do begin
        readf, sfu, line
        if strmid(line,0,1) ne "#" then begin
            fields = strsplit(line,',',/extract,/preserve_null,count=count)
            if count ne 7 then begin
                ; error message and give up
                message,'There was a problem reading the online status file.  Please report this error.',/info
                ; free_lun also closes it
                free_lun, sfu
                return, 0
            endif
            statusInfo.backend = fields[0]
            statusInfo.project = fields[1]
            statusInfo.scan = fields[2]
            statusInfo.timestamp = fields[3]
            timetag = long(bin_date(fields[4]))
            statusInfo.timetag_jul = julday(timetag[1],timetag[2],timetag[0],timetag[3],timetag[4],timetag[5])
            statusInfo.file = fields[5]
            if strlen(statusInfo.file) gt 0 then begin
                statusInfo.file = self.onlinedir + '/' + statusInfo.project + '/' + statusInfo.file
            endif
            statusInfo.index = fields[6]
            ; age field is set when the structure is requested from this object
            ; and assign this as appropriate
            case statusInfo.backend of
                'acs': self.acs_info = statusInfo
                'sp': self.sp_info = statusInfo
                'zpec': self.zpec_info = statusInfo
                'dcr': self.dcr_info = statusInfo
                'vegas': self.vegas_info = statusInfo
                ELSE: begin
                    ; error message and go on
                    ; print,"unrecognized backend, going on : ", statusInfo.backend
                    break
                end
            endcase
        endif
    endwhile
    ; free_lun also closes it
    free_lun, sfu
    return, 1
END

;+
; The current status of this object.  1 is OK, 0 means there was a
; problem reading the status info file.
;-
FUNCTION ONLINE_STATUS_FILE::get_status
    return, self.status
END

;+
; Update the info.  Only invokes read when the file's mtime has changed.
; @private
;-
FUNCTION ONLINE_STATUS_FILE::update
    compile_opt idl2, hidden
    
    ; if the status is currently 0, try and read it again
    if self.status eq 0 then begin
        self.status = self->read()
    endif else begin
        fi = file_info(self.file)
        if fi.mtime ne self.mtime then begin
            self.status = self->read()
        endif
    endelse

    return, self.status
END

;+
; Sets the age field.
; @private
;-
PRO ONLINE_STATUS_FILE::set_age_field, strct
    compile_opt idl2, hidden
    if strlen(strct.file) gt 0 then begin
        strct.age = (systime(/jul) - strct.timetag_jul)*24.0*60.0
    endif
END

;+
; Returns the status info structure for the desired backend.
; @private
;-
FUNCTION ONLINE_STATUS_FILE::get_status_info, backend
    compile_opt idl2, hidden

    if self->update() ne 1 then begin
        return, 0
    endif
    info = 0
    case backend of
        'acs': info = self.acs_info
        'sp': info = self.sp_info
        'zpec': info = self.zpec_info
        'dcr': info = self.dcr_info
        'vegas': info = self.vegas_info
        ELSE: begin
            ; error message
            print,'Unrecognized backend'
        end
    endcase
    if size(info,/type) eq 8 then begin
        self->set_age_field, info
    endif
    return, info
END

;+
; Get all the status records in one call.
; @param acs {out}{type=online_status_info_strct structure} ACS info.
; @param dcr {out}{type=online_status_info_strct structure} DCR info.
; @param sp {out}{type=online_status_info_strct structure} SP info.
; @param zpec {out}{type=online_status_info_strct structure} ZPEC info.
; @param vegas {out}{type=online_status_info_strc structure} VEGAS info.
; @param status {out}{type=int} 1 is ok, 0 there is a problem reading
; the online status text file.
; @returns the status of the most recent spectral line file (vegas, acs or sp)
; @private
;-
FUNCTION ONLINE_STATUS_FILE::get_all_infos, acs, dcr, sp, zpec, vegas, status
    compile_opt idl2, hidden

    status = self->update()

    acs = self.acs_info
    sp = self.sp_info
    dcr = self.dcr_info
    zpec = self.zpec_info
    vegas = self.vegas_info
    status = self.status
    mostRecent = self.acs_info

    if (status eq 1) then begin
        self->set_age_field, acs
        self->set_age_field, sp
        self->set_age_field, dcr
        self->set_age_field, zpec
        self->set_age_field, vegas
        self->set_age_field, mostRecent

        ; find most recent of sp, acs, vegas
        ; acs set as mostRecent above

        ; check against sp
        if strlen(sp.file) gt 0 then begin
            ; it isn't empty
            if strlen(mostRecent.file) eq 0 then begin
                ; mostRecent is empty
                mostRecent = sp
            endif else begin
                if mostRecent.age gt sp.age then begin
                    ; tie goes to mostRecent
                    mostRecent = sp
                endif
            endelse
        endif

        ; check whatever is mostRecent from above against vegas
        if strlen(vegas.file) gt 0 then begin
            ; vegas isn't empty
            if strlen(mostRecent.file) eq 0 then begin
                ; mostRecent is empty
                mostRecent = vegas
            endif else begin
                if mostRecent.age gt vegas.age then begin
                    ; tie goes to mostRecent
                    mostRecent = vegas
                endif
            endelse
        endif

    endif
    return, mostRecent
END

;+
; For use with old style inquiry.  Just return the file name for each
; backend.  Also return the most recently modified spectral line (acs
; or sp) file as the return argument.  Status is the status of this
; object.  1 is OK, 0 there is a problem reading the online status file.
; @private
;-
FUNCTION ONLINE_STATUS_FILE::get_filenames, acsf, dcrf, spf, zpecf, vegasf, status
    compile_opt idl2, hidden

    mostRecent = self->get_all_infos(acs,dcr,sp,zpec,vegas, status)
    mostRecentFile = ''

    if status eq 1 then begin

        acsf = acs.file
        spf = sp.file
        dcrf = dcr.file
        zpecf = zpec.file
        vegasf = zpec.file
        mostRecentFile = mostRecent.file
        
    endif 

    return, mostRecentFile
END
