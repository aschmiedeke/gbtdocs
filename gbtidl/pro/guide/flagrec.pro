;+
; Flag a specific record or records in the currently open spectral
; line data file.
;
; <p>A record number or array of record numbers must be supplied.
; This routine will flag the indicated channels (or all channels, if
; bchan and echan are not used) in those record numbers.  This is
; appropriate if you know exactly which specific records need to be
; flagged.  It is usually easier to use  <a href="flag.html">flag</a> and let flag work out which 
; records should be flagged.  A record number is simply the index
; number for that spectrum in the input data set.
;
; <p>Flags are applied when the data is actually read into a data
; container (e.g. get, getrec, getps, getnod, etc).  At that point,
; any flagged data is replaced with the blanked value (not a number,
; NaN).  GBTIDL ignores blanked data.  If that data is saved back to a
; data file, it will be saved as blanked values and no further
; flagging is necessary.  Flags are associated with the data in the
; file, not with the data in a data container.  Once the data is in
; GBTIDL in a data container, it can be blanked (e.g.
; <a href="replace.html">replace</a>) but not flagged.
;
; <p>Continuum flagging is not supported.
;
; <p><b>See Also:</b> <a href="http://wwwlocal.gb.nrao.edu/GBT/DA/gbtidl/users_guide/node47.html" TARGET="_top">Introduction to Blanking and Flagging</a> 
; in the GBTIDL user's guide
;
; @param record {in}{required}{type=integer} The record numbers to be flagged.
; @keyword bchan {in}{optional}{type=integer} Starting channel number
; (default=0)
; @keyword echan {in}{optional}{type=integer} Ending channel number
; (default=last channel)
; @keyword chans {in}{optional}{type=integer} Channels to flag. Mutually exclusive to 
; bchan and echan keywords.
; @keyword chanwidth {in}{optional}{type=integer} Buffer of channels surrounding the 
; channels specified in chans keyword. (default=1)
; @keyword idstring {in}{optional}{type=string}{default="unspecified"}
; A short string describing the flag.
; @keyword keep {in}{optional}{type=boolean} Flag the keep (output)
; data source.
;
; @examples
; <pre>
;  ; flags all the channels in record number one
;  flagrec, 1
;
;  ; flags just the first ten channels in record two
;  flagrec, 2, echan=10, idstring="flag first 10 channels"
;
;  ; flags the first ten channels, and channels 50 to 60
;  flagrec, 3, bchan=[0,50], echan=[10,60]
;
;  ; flags the same channels as the above example in record four
;  flagrec, 4, chans=[5,55], width=5
; </pre>
;
; @version $Id$
;-
pro flagrec, record, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=idstring,keep=keep
    compile_opt idl2

    if n_elements(record) eq 0 then begin
        usage,'flagrec'
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

    thisio->set_flag_rec, record, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth, idstring=lidstring

end
