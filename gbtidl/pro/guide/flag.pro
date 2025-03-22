; docformat = 'rst' 

;+
; Flag some data in the currently opened spectral line data file or
; output (keep) data file.
;
; A scan number or array of scan numbers is required and can be
; entered either in the parameter "scan" or the parameter "scanrange".
; The other keywords allow for additional refinements in the scope of
; the flag. When a keyword is not supplied, it defaults to all values
; of that keyword in the data for the given scans.  In some cases,
; when you know which specific record needs some or all of its data
; flagged, :idl:pro:`flagrec` may be more appropriate.
;
; Flags are applied when the data is actually read into a data
; container (e.g. using get, getrec, getps, getnod, etc).  At that
; point, any flagged data is replaced with the special value for
; blanked data (NaN, or  "not a number").  GBTIDL ignores blanked
; data.  If that data is saved back to a data file, it will be saved
; as blanked values and no further flagging is necessary.  Flags are
; associated with the data in the file, not with the data in a data
; container.  Once the data is in GBTIDL in a data container, it can
; have additional blanking applied (e.g. :idl:pro:`replace`) but not flagged.
;
; The sampler argument can be used to specify a specific sampler
; name to flag.  The :idl:pro:`samplerinfo` function is used to translate 
; that name into a single plnum, ifnum, -and fdnum combination which
; is then used to set this flag.  The listing of data flagged by
; sampler name will only show these integer values, not the original
; sampler name.  When sampler is used, it is an error to also use
; plnum, ifnum or fdnum in the same call to flag.  A single scan (not
; a scan range) must be used if sampler is supplied.
;
; Continuum flagging is not supported.
;
; See also the "Introduction to Flagging and Blanking Data" in the `GBTIDL manual <https://www.gb.nrao.edu/GBT/DA/gbtidl/users_guide.pdf#page=28>`_
;
; :Params:
;   scan : in, optional, type=integer
;       M&C scan numbers to flag. This is required if scanrange is not used.
; 
; :Keywords:
;   intnum : in, optional, type=integer
;       Integration number (default=all)
;   plnum : in, optional, type=integer
;       polarization number (default=all)
;   ifnum : in, optional, type=integer
;       IF number (default=all)
;   fdnum : in, optional, type=integer
;       Feed number (default=all)
;   sampler : in, optional, type=string
;       Sampler name, used only as a short-hand for a specific plnum, 
;       ifnum, fdnum combination. When sampler is supplied it is an 
;       error to also supply ifnum, plnum, or fdnum.  Sampler must be 
;       single-valued (no arrays).
;   bchan : in, optional, type=integer
;       Starting channel number(s) (default=0)
;   echan : in, optional, type=integer
;       Ending channel number(s) (default=last channel)
;   chans : in, optional, type=integer
;       Channel to flag. Mutually exclusive to bchan and echan keywords.
;   chanwidth : in, optional, type=integer
;       Buffer of channels surrounding the channels specified in 
;       chans keyword. (default=1)
;   idstring : in, optional, type=string, default="unspecified"
;       A short string describing the flag.
;   scanrange : in, optional, type=integer array
;       A 2-element array giving the first and last scan numbers that 
;       describe the range of scans to flag.  This is ignored if the 
;       scan parameter is used. If only one integer is supplied then 
;       this is equivalent to giving that integer as the "scan" 
;       parameter argument.
;   keep : in, optional, type=boolean
;       Flag the keep (output) data source.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; flags all the channels in scan number one
;       flag, 1 
;
;       ; flags just the first ten channels in scan two
;       flag, 2, echan=10, idstring="flag first 10 channels"
;
;       ; flags the first ten channels, and channels 50 to 60
;       flag, 3, bchan=[0,50], echan=[10,60]
;
;       ; flags the same channels as the above example in scan four
;       flag, 4, chans=[5,55], width=5
;
;       ; flag all channels in scan 5, integrations 1 through 4
;       flag, 5, intnum=[1,2,3,4], idstring="RFI"
;
;       ; flag just this one channel for scan 6, for just the first polarization
;       flag, 6, plnum=0, chans=2999
;
;       ; flag first polarization, second feed, third IF, all channels
;       flag, 7, plnum=0, fdnum=1, ifnum=2, idstring="Bad Lags"
;
;       ; If the previous example corresponded to sampler "B17" then
;       ; this example would produce the same flag rule
;       flag, 7, sampler="B17", idstring="Bad Lags"
;
;-
pro flag, scan, intnum=intnum, plnum=plnum, ifnum=ifnum, fdnum=fdnum, sampler=sampler, $
          bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=idstring, scanrange=scanrange, $
          keep=keep
    compile_opt idl2

    if n_elements(scan) eq 0 and n_elements(scanrange) eq 0 then begin
        print,'Either scan or scanrange is required.'
        usage,'flag'
        return
    endif

    if not !g.line then begin
        message,'Flagging is not available for continuum data',/info
        return
    endif

    thisio = keyword_set(keep) ? !g.lineoutio : !g.lineio
    if not thisio->is_data_loaded() then begin
        if keyword_set(keep) then begin
            message, 'No keep (output) data is attached yet, use fileout.',/info
        endif else begin
            message, 'No line data is attached yet, use filein or dirin.', /info
        endelse
        return
    endif

    lidstring = "unspecified"
    if n_elements(idstring) gt 0 then lidstring = idstring

    if n_elements(scan) eq 0 and n_elements(scanrange) ne 0 then begin
        thisScanRange = scanrange
        if n_elements(sampler) ne 0 then begin
            message,'sampler can not be used with scanrange, only with a single scan', /info
            return
        endif
        if n_elements(thisScanRange) ne 2 then begin
            if n_elements(thisScanRange) eq 1 then begin
                thisScanRange = [thisScanRange,thisScanRange]
            endif else begin
                message,'scanrange must have 1 or 2 elements',/info
                return
            endelse
        endif
        stype = size(thisScanRange,/type)
        if stype lt 2 or (stype gt 3 and stype lt 12) then begin
            message,'scanrange must be an integer',/info
            return
        endif
        if thisScanRange[0] gt thisScanRange[1] then begin
            tmp = thisScanRange[0]
            thisScanRange[0] = thisScanRange[1]
            thisScanRange[1] = tmp
        endif
        lscan = lindgen(thisScanRange[1]-thisScanRange[0]+1) + thisScanRange[0]
        thisio->set_flag, lscan, intnum=intnum, plnum=plnum, ifnum=ifnum, $
          fdnum=fdnum, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=lidstring
    endif else begin
        if n_elements(sampler) gt 0 then begin
            if n_elements(sampler) gt 1 then begin
                message,'Can not flag more than one sampler at a time',/info
                return
            endif
            if n_elements(plnum) gt 0 or n_elements(ifnum) gt 0 or n_elements(fdnum) gt 0 then begin
                message,'Can not use sampler with ifnum, plnum, or fdnum',/info
                return
            endif
            if n_elements(scan) gt 1 then begin
                message,'Only one scan can be used with sampler',/info
                return
            endif
            sampInfo = samplerinfo(scan,sampler)
            if sampInfo[0] eq -1 then begin
                message,'Sampler not found in scan',/info
                return
            endif
            thisio->set_flag, scan, intnum=intnum, plnum=sampInfo[1], ifnum=sampInfo[0], $
                              fdnum=sampInfo[2], bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=lidstring
        endif else begin
            thisio->set_flag, scan, intnum=intnum, plnum=plnum, ifnum=ifnum, $
                              fdnum=fdnum, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=lidstring
        endelse
    endelse
    

end
