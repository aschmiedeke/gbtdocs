; docformat = 'rst'

;+
; A function to get several data containers from an input file in one call. 
;
; It is more efficient to retrieve multiple data containers in one 
; call.  Because the global data buffers all contain a single data 
; container, this function does not interact directly with the global 
; buffers, as other data retrieval procedures do.  Instead, it returns
; an array of data containers that must then be handled appropriately
; by the user. 
;
; Note that it is the responsibility of the caller to explicitly
; free the pointers used in this array of data containers.  Simply use
; :idl:pro:`data_free` as shown in the examples below.
;
; The usual data selection operations can be specified in this
; function. 
;
; **There is no protection against running out of memory.** If
; one does not carefully select the data to be fetched or even avoids
; specifying any arguments to getchunk, all of the data that matches
; that selection (which might be all of the data in the file) will be
; read from disk into memory.  That might be more memory than you have
; and this procedure does not protect you against that.  Use this
; function carefully.
;
; Flags (set via :idl:pro:`flag`) can be selectively applied or ignored using the useflag 
; and skipflag keywords.  Only one of those two keywords can be used
; at a time (it is an error to use both at the same time).  Both can
; be either a boolean (/useflag or /skipflag) or an array of strings.
; The default is /useflag, meaning that all flag rules that have been
; previously set are applied when the data is fetched from disk,
; blanking any data as described by each rule.  If /skipflag is set,
; then all of the flag rules associated with this data are ignored and
; no data will be blanked when fetched from disk (it may still contain
; blanked values if the actual values in the disk file have already
; been blanked by some other process).  If useflag is a string or
; array of strings, then only those flag rules having the same
; idstring value are used to blank the data.  If skipflag is a string
; or array of strings, then all flag rules except those with the same
; idstring value are used to blank the data. 
;
; :Keywords:
;   count : out, optional, type=integer
;       An output value giving the number of data containers actually returned.
;   keep : in, optional, type=boolean
;       When set, the data are fetched from the output file.
;   useflag : in, optional, type=boolean or string, default=true
;       Apply all or just some of the flag rules?
;   skipflag : in, optional, type=boolean or string
;       Do not apply any or do not apply a few of the flag rules?
;   indicies : out, optional, type=long
;       Array of index numbers, one for each spectrum retrieved. 
;       Returns -1 when no spectra were returned.
;   _EXTRA : in, optional, type=extra keywords
;       These are selection parameters to specify which data to retrieve.
;       See :idl:pro:`listcols` for a complete list of the columns available.
;       Also see the discussion on "Select" in the `GBTIDL manual <https://www.gb.nrao.edu/GBT/DA/gbtidl/users_guide.pdf#page=29>`_
;       for a summary of selection syntax.
;
; :Returns:
;   An array of data containers.  If no data satisfy the selection criteria, 
;   count will be 0 and the returned value will be -1.
;
; :Examples:
;   In the first example, we copy the input file to the keep file (currently 
;   only possible in line mode), one scan at a time.  This would be done in a
;   procedure, not at the command line, because of the loop.
;
;   .. code-block:: IDL
; 
;       scans=get_scan_numbers(/unique)
;       for i=0,(n_elements(scan)-1) do begin
;           a = getchunk(scan=scans[i])
;           putchunk, a
;           data_free, a
;       endfor
;
;   In the next example, we average all of the data for a given scan.
;   This example also shows that we have choosen to ignore any
;   flags with idstring='wind'.  This could be done at the command line
;   because the loop is contained on a single line.
;
;   .. code-block:: IDL
; 
;       sclear
;       a = getchunk(scan=6000,count=count,skipflag='wind')
;       accum,dc=a[0]
;       for i=1,(count-1) do accum,dc=a[i]
;       ave
;       data_free,a
;
;-
function getchunk,count=count,keep=keep,useflag=useflag, skipflag=skipflag, indicies=indicies,_EXTRA=ex
    compile_opt idl2

    count = 0
    res = -1

    if n_elements(useflag) gt 0 and n_elements(skipflag) gt 0 then begin
        message,'Flag and skipflag can not be used at the same time',/info
        return, res
    endif
    
    if keyword_set(keep) then begin
        if !g.lineoutio->is_data_loaded() then begin
            res = !g.lineoutio->get_spectra(count,indicies,useflag=useflag,skipflag=skipflag,$
                                            _EXTRA=ex)
        endif else begin
            message,'No keep file is attached yet, use fileout',/info
        endelse
    endif else begin
        if !g.line then begin
            if !g.lineio->is_data_loaded() then begin
                res = !g.lineio->get_spectra(count,indicies,useflag=useflag,skipflag=skipflag,$
                                             _EXTRA=ex)
            endif else begin
                message,'No line data is attached yet, use filein or dirin',/info
            endelse
        endif else begin
            if n_elements(useflag) gt 0 or n_elements(skipflag) gt 0 then $
              message,'Flagging is not yet available for continuum data, ignoring flag-related keywords',/info

            if !g.contio->is_data_loaded() then begin
                res = !g.contio->get_continua(count,indicies,_EXTRA=ex)
            endif else begin
                message,'No continuum data is attached yet, use filein or dirin',/info
            endelse
        endelse
    endelse
    return, res
end
