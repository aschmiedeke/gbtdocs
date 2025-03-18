;+
; Special program for updating the index file for the most current sdfits file
; in /home/sdfits.  A temporary solution untill the sdfits filler can produce
; its own index files.
; @private_file
;-
pro index_daemon

    new_file = ""
    last_scan = -1
    io = obj_new("io_sdfits_line")

    while 1 do begin

        ;print, " "
        ;print, " "

        ; find the most recent file in the dir
        dir = '/home/sdfits'
        cnt = 0
        file_paths = file_search(dir+'/*.fits',count=cnt)
    
        ; dont do anything if there are no file
        if cnt gt 0 then begin
    
            max_time = 0.0D
            newest_file = ""
            for i=0,n_elements(file_paths)-1 do begin
                file = file_paths[i]
                fi = file_info(file)
                if fi.mtime gt max_time then begin
                    max_time = fi.mtime
                    newest_file = file
                endif
            endfor
        
            ; must obtain a lock on this file before we can update an index file
            ; first, create the lock file name: project.index
            parts = strsplit(newest_file, "/", /extract)
            filename = parts[n_elements(parts)-1]
            parts = strsplit(filename, ".", /extract)
            project = parts[0]
            backend = strtrim(strlowcase(parts[2]),2)
            lockfile = dir + '/' + project + ".lock"

            if backend eq 'acs' or backend eq 'sp' then begin

                ;print, "checking lockfile: ", lockfile
    
                ; if the file exists, we have to wait for the owner to delete it
                filelocked = file_test(lockfile)
                while filelocked do begin
                    print, "waiting on lockfile"
                    wait, 1.0
                    filelocked = file_test(lockfile)
                endwhile
                ;print, "creating lockfile"
                openw, lun, lockfile, /get_lun
                
                ; if we're switching files, create new io object
                if newest_file ne new_file then begin
                    new_file = newest_file
                    if obj_valid(io) then obj_destroy, io
                    io = obj_new("io_sdfits_line")
                    ; print, "io->set_file to file: ", new_file
                    io->set_file, new_file
                endif else begin
                    ; same newest file as it was last time = update it!
                    ; print, "updating file: ", new_file
                    io->load_new_sdfits_rows
                endelse
                
                ; release the lock
                ; print, "destroying lockfile"
                file_delete, lockfile
                free_lun, lun
            
            endif else begin

                print, "online continuum not supported: skipping latest file"

            endelse ; if acs/sp backend file

        
            ; get the last scan
            ;scans = io->get_index_values("MC_SCAN")
            ;new_last_scan = scans[n_elements(scans)-1]
        
            ; see if we've come across a new scan
            ;if last_scan ne new_last_scan then begin
                ; display the new spectra
            ;    last_scan = new_last_scan
            ;    spec = io->get_spectra(mc_scan=last_scan)
            ;    for i=0,n_elements(spec)-1 do begin
            ;        print, "displaying new spectra:"+string(i+1)+" of "+string(n_elements(spec))
            ;        show, spec[i]
            ;        wait, 1.0
            ;    endfor
            ;endif
            
                
        endif ; if no files
            
        wait, 5.0

    endwhile

    if obj_valid(io) then obj_destroy, io

end
