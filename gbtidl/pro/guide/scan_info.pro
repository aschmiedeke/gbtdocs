;+
; Get scan information structure from the appropriate I/O object.
;
; <p>This uses !g.line to determine which I/O object to get the
; information from, unless keep is set, in which case it gets it from
; the keep file.
;
; <p>Note that this may return more than one structure (an array of
; structures would be returned).  This can happen if the same scan
; number appears in the data with more than one timestamp.  The
; instance and timestamp keywords of the various data retrieval
; procedures (getscan, get, getnod, getps, etc) can be used to
; differentiate between these duplicate scans.  The instance keyword
; in those cases corresponds to the element number of the array
; returned by scan_info.  The timestamp keyword corresponds to the
; timestamp field in the scan_info structure.
;
; <p>The data corresponding to a given instance are always found in
; consecutive records.  The index_start and nrecords fields can be
; used to get just the data associated with a specific instance.  See
; the examples.
;
; The fields in the returned structure are:
; <UL>
; <LI> SCAN, the scan number, long integer
; <LI> PROCSEQN, the procedure sequence number, long integer
; <LI> PROCEDURE, the procedure name, string
; <LI> TIMESTAMP, the timestamp associated with this scan, string
; <LI> FILE, the name of the file where this scan was found
; <LI> N_INTEGRATION, the number of integrations, long integer.  Note
; that different samplers may have different numbers of integrations.
; This value is the number of unique times (MJD) found for this scan.
; Use N_SAMPINTS for the number of integrations from a given sampler.
; <LI> N_FEEDS, the number of feeds, long integer
; <LI> FDNUMS, the specific FDNUM values for this scan.
; <LI> N_IFS, the number of IFs, long integer
; <LI> IFNUMS, the specific IFNUM values for this scan.
; <LI> IFTABLE, a 3-axis array indicating which combinations of ifnum,
; fdnum and plnum are present in the data.  The first axis is ifnum,
; the second axis is fdnum and the 3rd is plnum.  Combinations with
; data have 1 in this array.  Combinations without data have a 0.
; Note: IDL removes any trailing axis of length 1 (degenerate) so care
; must be taken when using the shape of this array.  E.g. if there is
; no third axis, then there is only one plnum, plnum=0.
; <LI> N_SWITCHING_STATES, the number of switching states, long integer
; <LI> N_CAL_STATES, the number of cal switching states, long integer
; <LI> N_SIG_STATES, the number of sig switching states, long integer
; <LI> N_WCALPOS, the total number of unique WCALPOS values in this
;    scan. (spectral line data only)
; <LI> WCALPOS, a vector giving the list of unique WCALPOS
;    (WBand receiver calposition) values for this scan. (spectral line
;    data only)
; <LI> N_POLARIZATIONS, the number of unique polarizations, long
;    integer, will always be less then or equal to 4.
; <LI> POLARIZATIONS, a vector containing the actual
;    polarizations, string (unused elements are the null string).
; <LI> PLNUMS, vector containing the PLNUM values
;    corresponding to each POLARIZATION, long integer (unused elements
;    are -1)
; <LI> FEEDS, a vector containing the unique feed ids, long
;    integer (unused elements are -1)
; <LI> BANDWIDTH, a vector containing the unique bandwidths, one for each IF
;    (Hz)
; <LI> INDEX_START, the starting index number for this scan.
; <LI> NRECORDS, the total number of records in this scan.
; <LI> N_SAMPLERS, the total number of unique sampler names in this scan.
; <LI> SAMPLERS, the list of unique sampler names.
; <LI> N_SAMPINTS, the number of integrations for each sampler.
; <LI> N_CHANNELS, the number of channels in each spectrum for each sampler.
; </UL>
;
; @param scan {in}{required}{type=integer} Scan number to get
; information on.
;
; @param file {in}{optional}{type=string} Limit the search for
; matching scans to a specific file.  If omitted, scans are found in
; all files currently opened through filein (a single file) or dirin
; (possibly multiple files).
;
; @keyword keep {in}{optional}{type=boolean} If set, the scan
; information comes from the keep file.
;
; @keyword quiet {in}{optional}{type=boolean} When set, suppress most
; error messages.  Useful when being used within another procedure.
;
; @keyword count {in}{optional}{type=integer} Returns the number of
; elements of the returned array of scan_info structures.
;
; @returns Scan information structure.  Returns -1 on error.
;
; @examples
; Get all of the data associated with one scan.
; <pre>
;    a = scan_info(65)
;    indx = lindgen(a.nrecords) + a.index_start
;    d65 = getchunk(index=indx)
;    ... do stuff with d65, but don't forget to free it when done
;    data_free, d65
; </pre>
; <p>
; Find paired scan's and their info structure (e.g. position switched)
; <pre>
;    a = scan_info(65)
;    b = find_paired_info(a)
; </pre>
;
; @version $Id$
;-
FUNCTION scan_info, scan, file, keep=keep, quiet=quiet, count=count
    compile_opt idl2

    count = 0
    if (n_elements(scan) eq 0) then begin
        usage,'scan_info'
        return, -1
    endif

    result = -1
    count = 0
    if (keyword_set(keep)) then begin
        if (!g.lineoutio->is_data_loaded()) then begin
            result = !g.lineoutio->get_scan_info(scan,file,count=count,quiet=quiet)
        endif else begin
            if not keyword_set(quiet) then message, 'There is no data in the keep file',/info
        endelse
    endif else begin
        if (!g.line) then begin
            if (!g.lineio->is_data_loaded()) then begin
                result = !g.lineio->get_scan_info(scan,file,count=count,quiet=quiet)
            endif else begin
                if not keyword_set(quiet) then message, 'There is no data in the line file', /info
            endelse
        endif else begin
            if (!g.contio->is_data_loaded()) then begin
                result = !g.contio->get_scan_info(scan,file,count=count,quiet=quiet)
            endif else begin
                if not keyword_set(quiet) then message, 'There is no data in the continuum file', /info
            endelse
        endelse
    endelse

    if count le 0 and not keyword_set(quiet) then message,'That scan was not found',/info

    return, result
END
