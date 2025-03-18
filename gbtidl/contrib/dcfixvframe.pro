;+
; Adjust the frame_velocity value in a data container using the
; external CASA library.
;
; <p>
; The examples shows how this routine can be used to adjust the
; frame velocity in all scans in an existing sdfits file.  This
; requires copying the data to a keep file and adjusting the
; frame velocity associated with each scan while doing that
; copy.  Once copied, the new fits file can be used as a
; filein in GBTIDL (you should exit GBTIDL first and restart
; it - or open a different fileout before trying to open this
; file as filein).  The frame_velocity values there should
; be accurate to < 5 m/s at the mid-point in time of all 
; spectra in the file.  These frame_velocities can then be
; used in conversion to classic AIPS for imaging or the
; vshift and shift procedures in GBTIDL can be use to accurately
; align and average these spectra.
;
; <p>This uses casaframevel with in turn uses a shared library
; built on a linux operating system. This is an interrum solution
; available only in Green Bank and Charlottesville GBTIDL
; installations while we develop a pure-IDL solution that can
; more easily be distributed.
;
; <p>Note that the first time this function is 
; called there will be a small delay while the shared library is
; loaded.  Subsequent calls will be substantially faster.
;
; <p><B>Contributed By: Bob Garwood, NRAO-CV</B>
;
; @param dc {in}{out}{required}{type=data container} The data
; container to use.  The value of dc.frame_velocity is changed by
; calling this procedure.  This may be a vector of data containers.
; @keyword newframe {in}{optional}{type=string} The new reference
; frame to use.  If not supplied, the frame implied by
; dc.velocity_definition will be used.  This string must be one of
; TOPO, GEO, HEL, BAR, LSR, LSD, and GAL.  If this is set, then
; dc.velocity_definition will be changed to match this keyword.
;
; @examples
; <pre>
; ; dc already exists, adjust the frame_velocity
; dcfixvframe,dc
; ; adjust it to the GAL (galactic) frame
; dcfixvframe,dc,newframe='GAL'
; ; get and adjust several data containers
; dcs = getchunk(scan=12)
; dcfixvframe,dcs
; ; and save them back to the keep file
; putchunk,dcs
; ; remember to free up the memory used in dcs
; data_free, dcs
; </pre>
; This example shows how to re-set the velocity in all of
; the data in a given sdfits file.  It does it by getting
; the data for each scan and re-setting it in turn and
; then saving that data to a keep file.  This assumes that
; all of the data for each scan can safely fit into memory.
; This would have to be done in a procedure because the
; for loop in this example spans more than one line.
; <pre>
; filein,'original_raw_data.fits'
; fileout,'vfixed_raw_data.fits'
; allscans = get_scan_numbers(/unique)
; for i=0,(n_elements(allscans)-1) do begin
;    sdata = getchunk(scan=allscans[i])
;    dcfixvframe, sdata
;    putchunk, sdata
;    data_free, sdata
; endfor
; </pre>
;
; @uses casaframevel, getradec, decode_veldef
;
; @version $Id$
;-
pro dcfixvframe, dc, newframe=newframe
    compile_opt idl2

    if n_elements(dc) eq 0 then begin
        usage,'dcfixvframe'
        return
    endif

    ok = data_valid(dc,name=name)
    if ok le 0 then begin
        message,'dc is not a valid data container',/info
        return
    endif
    if name ne 'SPECTRUM_STRUCT' then begin
        message,'dc must be a spectrum data container',/info
        return
    endif
    
    donew = n_elements(newframe) eq 1

    for i=0,(n_elements(dc)-1) do begin
        radec = getradec(dc[i],2000.0,/quiet)
        ok = decode_veldef(dc[i].velocity_definition, veldef, velframe)
        if donew then velframe = newframe
        vframe = casaframevel(radec[0],radec[1],dc[i].mjd,dc[i].site_location[0], $
                              dc[i].site_location[1], dc[i].site_location[2], $
                              dc[i].frequency_type, velframe)
        dc[i].frame_velocity = vframe
        if donew then begin
            if velframe eq 'TOPO' then velframe = 'OBS'
            vd = dc[i].velocity_definition
            strput,vd,velframe,5
            dc[i].velocity_definition = vd
        endif            
    endfor

end
