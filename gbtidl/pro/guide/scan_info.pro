; docformat = 'rst'

;+
; Get scan information structure from the appropriate I/O object.
;
; This uses ``!g.line`` to determine which I/O object to get the
; information from, unless keep is set, in which case it gets it from
; the keep file.
;
; Note that this may return more than one structure (an array of
; structures would be returned).  This can happen if the same scan
; number appears in the data with more than one timestamp.  The
; instance and timestamp keywords of the various data retrieval
; procedures (:idl:pro:`getscan`, :idl:pro:`get`, :idl:pro:`getnod`, 
; :idl:pro:`getps`, etc) can be used to differentiate between these
; duplicate scans.  The instance keyword in those cases corresponds
; to the element number of the array returned by scan_info.  The
; timestamp keyword corresponds to the timestamp field in the ``scan_info``
; structure.
;
; The data corresponding to a given instance are always found in
; consecutive records.  The ``index_start`` and ``nrecords`` fields can be
; used to get just the data associated with a specific instance.  See
; the examples.
;
; The fields in the returned structure are:
; 
; .. list-table:: 
;     :widths: 20, 80
;     :header-rows:0
; 
;     * - SCAN
;       - the scan number, long integer
;     * - PROCSEQN
;       - the procedure sequence number, long integer
;     * - PROCEDURE
;       - the procedure name, string
;     * - TIMESTAMP
;       - the timestamp associated with this scan, string
;     * - FILE
;       - the name of the file where this scan was found
;     * - N_INTEGRATION
;       - the number of integrations, long integer.  Note that different
;         samplers may have different numbers of integrations. This value
;         is the number of unique times (MJD) found for this scan. Use 
;         ``N_SAMPINTS`` for the number of integrations from a given sampler.
;     * - N_FEEDS
;       - the number of feeds, long integer
;     * - FDNUMS
;       - the specific FDNUM values for this scan
;     * - N_IFS
;       - the number of IFs, long integer
;     * - IFNUMS
;       - the specific IFNUM values for this scan
;     * - IFTABLE
;       - a 3-axis array indicating which combinations of ``ifnum``, ``fdnum``
;         and ``plnum`` are present in the data.  The first axis is ``ifnum``,
;         the second axis is ``fdnum`` and the 3rd is ``plnum``.  Combinations with
;         data have 1 in this array.  Combinations without data have a 0.
;         *Note:* IDL removes any trailing axis of length 1 (degenerate) so care
;         must be taken when using the shape of this array.  E.g. if there is
;         no third axis, then there is only one plnum, ``plnum=0``.
;     * - N_SWITCHING_STATES
;       - the number of switching states, long integer
;     * - N_CAL_STATES
;       - the number of cal switching states, long integer
;     * - N_SIG_STATES
;       - the number of sig switching states, long integer
;     * - N_WCALPOS
;       - the total number of unique WCALPOS values in this scan. (spectral line
;         data only)
;     * - WCALPOS
;       - a vector giving the list of unique WCALPOS (WBand receiver calposition) 
;         values for this scan (spectral line data only)
;     * - N_POLARIZATIONS
;       - the number of unique polarizations, long integer, will always be less 
;         then or equal to 4
;     * - POLARIZATIONS
;       - a vector containing the actual polarizations, string (unused elements
;         are the null string)
;     * - PLNUMS
;       - vector containing the PLNUM values corresponding to each POLARIZATION,
;         long integer (unused elements are -1)
;     * - FEEDS
;       - a vector containing the unique feed ids, long integer (unused elements are -1)
;     * - BANDWIDTH
;       - a vector containing the unique bandwidths, one for each IF (Hz)
;     * - INDEX_START
;       - the starting index number for this scan
;     * - NRECORDS
;       - the total number of records in this scan
;     * - N_SAMPLERS
;       - the total number of unique sampler names in this scan
;     * - SAMPLERS
;       - the list of unique sampler names
;     * - N_SAMPINTS
;       - the number of integrations for each sampler
;     * - N_CHANNELS
;       - the number of channels in each spectrum for each sampler
; 
; :Params:
;   scan : in, required, type=integer
;       Scan number to get information on.
;   file : in, optional, type=string
;       Limit the search for matching scans to a specific file.  If omitted,
;       scans are found in all files currently opened through filein (a single
;       file) or dirin (possibly multiple files).
;
; :Keywords:
;   keep : in, optional, type=boolean
;       If set, the scan information comes from the keep file.
;   quiet : in, optional, type=boolean
;       When set, suppress most error messages.  Useful when being used
;       within another procedure.
;   count : in, optional, type=integer
;       Returns the number of elements of the returned array of
;       scan_info structures.
;
; :Returns:
;   Scan information structure.  Returns -1 on error.
;
; :Examples:
;   Get all of the data associated with one scan.
; 
;   .. code-block:: IDL
; 
;       a = scan_info(65)
;       indx = lindgen(a.nrecords) + a.index_start
;       d65 = getchunk(index=indx)
;       ... do stuff with d65, but don't forget to free it when done
;       data_free, d65
; 
;   Find paired scan's and their info structure (e.g. position switched)
; 
;   .. code-block:: IDL
; 
;       a = scan_info(65)
;       b = find_paired_info(a)
;
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
