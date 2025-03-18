;+
; This function is used by the standard calibration routines to handle
; some argument checking and to assign default values to keywords
; when not provided by the user.
;
; <p>Encapsulating these here should make it easier for users to
; adapt a calibration routine to do what they want it to do.
;
; <p>Since the calibration routines all only work for line data,
; GBTIDL must currently be in line mode when this routine is called.
; If it is in continuum mode, that is an error and this function will
; return -1.  In addition, there must already be line data opened
; using either filein or dirin.
;
; <p>The argument descriptions here refer to what this routine checks
; for, not what the argument means.  For the meaning of a specific
; argument, see the calibration routine in question.  Type checking is
; only done for string keywords.
;
; <p>Because this routine is designed to be called by another routine,
; errors are reported such that the message prefix is the name of the
; calling routine.  Users are least likely to be confused by those
; messages.
; 
; <p>A warning is printed if tau or ap_eff are specified and the units
; value (explicit or implied) means tau or ap_eff are not used
; (e.g. the default units 'Ta' do not need tau or ap_eff and so if
; they are provided, a warning to that effect is printd).  This not
; considered a severe problem and processing continues.  This can be
; turned off if the quiet keyword is set.
;
; <p>If there was a severe problem, the return value is 0 (false) and
; the calling routine should exit at that point.  If the arguments are
; all okay then the return value is 1 and any defaults are returned in
; a structure in the defaults keyword value.
;
; <p>If sampler is supplied then all 3 of ifnum, plnum, and fdnum must
; not be supplied.  The returned values for these 3 are all -1,
; implying that sampler should be used.
;
; <p>If ifnum, fdnum, or plnum are not supplied, the lowest valid
; value with data is chosen.  This value is picked by first setting,
; ifnum, then fdnum, and finally plnum (using any user-supplied values
; first).  If there is no valid data using the user-supplied values
; then <a href="showiftab.html">showiftab</a> is used to display the set of valid values and the
; return value is -1.
;
; @param scan {in}{optional}{type=integer} If scan is not supplied,
; then a valid timestamp keyword must be supplied. No default supplied.
; @param refscan {in}{optional}{type=integer} Ignored unless checkref
; is true.  If refscan is not supplied, then a valid reftimestamp
; keyword must be supplied.  No default supplied.
; @keyword intnum {in}{optional}{type=integer} Must be >= 0.
; @keyword ifnum {in}{optional}{type=integer} Must be >= 0. Defaults
; as described above.
; @keyword plnum {in}{optional}{type=integer} Kust be >= 0. Defaults
; as described above.
; @keyword fdnum {in}{optional}{type=integer} Must be >= 0. Defaults
; 
; @keyword sampler {in}{optional}{type=string} Must be non-empty.
; Defaults to '' (empty, unspecified).  When set, the returned ifnum,
; plnum, and fdnum values are all -1.
; @keyword eqweight {in}{optional}{type=boolean}
; @keyword units {in}{optional}{type=string} Must be one of
; "Ta","Ta*", or "Jy".
; @keyword bswitch {in}{optional}{type=integer} Must be 0, 1 or 2.
; Defaults to 0.
; @keyword quiet {in}{optional}{type=boolean}
; @keyword keepints {in}{optional}{type=boolean}
; @keyword useflag {in}{optional}{type=boolean} Only one of useflag
; and skipflag can be set.
; @keyword skipflag {in}{optional}{type=boolean} Only one of useflag
; and skipflag can be set.
; @keyword instance {in}{optional}{type=integer} Must be >=
; 0. Defaults to 0.
; @keyword file {in}{optional}{type=string}
; @keyword timestamp {in}{optional}{type=string} If scan is not
; supplied, then a valid timestamp keyword must be supplied.
; @keyword refinstance {in}{optional}{type=integer} Ignored unless
; checkref is true.  Must be >= 0.  Defaults to 0.
; @keyword reffile {in}{optional}{type=string} Ignored unless checkref
; is true.
; @keyword reftimestamp {in}{optional}{type=string} Ignored unelss
; checkref is true.  If refscan is not supplied, then a valid
; reftimestamp keyword must be supplied.
; @keyword checkref {in}{optional}{type=boolean} Check refscan and the
; ref* keywords?
; @keyword tau {in}{optional}{type=float} Warning if tau is set and
; units is 'Ta' or unset.
; @keyword ap_eff {in}{optional}{type=float} Warning if units is not
; 'Jy'.
; @keyword twofeeds {in}{optional}{type=boolean} When set, fdnum is
; assumed to be a tracking feed number and it is not influenced by any
; value that sampler might have.
; @keyword sig_state {in}{optional}{type=integer} Used for sig_state
; selection.  When set it must be 0 or 1.  Returned value is -1 if
; unset or out of bounds.
; @keyword ret {out}{required}{type=structure} The values to use for
; ifnum, plnum, fdnum, instance, and bswitch taking into account the defaults
; as described here.  This is done so that the values of the calling
; arguments are not altered by this function.
; @keyword info {out}{required}{type=structure} The scan info structure
; associated with the scan, timestamp, instance and file arguments as
; given.  This will not be a structure if there was a problem.
;
; @private_file
;
; @version $Id$
;-
function check_calib_args, scan,refscan,intnum=intnum,ifnum=ifnum,plnum=plnum,$
  fdnum=fdnum,sampler=sampler,eqweight=eqweight,units=units,bswitch=bswitch,quiet=quiet,keepints=keepints,$
  useflag=useflag,skipflag=skipflag,instance=instance,file=file,$
  timestamp=timestamp,refinstance=refinstance,reffile=reffile,$
  reftimestamp=reftimestamp,checkref=checkref,tau=tau,ap_eff=ap_eff,twofeeds=twofeeds,sig_state=sig_state,$
  ret=ret,info=info
    compile_opt idl2

    result = 0

    ; basic checks
    if not !g.line then begin
        message,'This does not work in continuum mode, sorry.',level=-1,/info
        return,result
    endif

    if n_elements(useflag) gt 0 and n_elements(skipflag) gt 0 then begin
        message,'Useflag and skipflag can not be used at the same time',level=-1,/info
        return,result
    endif
    
    if not !g.lineio->is_data_loaded() then begin
        message,'No line data is attached yet, use filein, dirin, online or offline',level=-1,/info
        return,result
    endif

    if n_elements(scan) eq 0 and n_elements(timestamp) eq 0 then begin
        message,'The scan number is required unless a timestamp is provided.',level=-1,/info
        return,result
    endif

    ; string argument type checks
    if n_elements(file) gt 0 then begin
        if size(file,/type) ne 7 then begin
            message,'File must be a string',level=-1,/info
            return,result
        endif
    endif

    if n_elements(timestamp) gt 0 then begin
        if size(timestamp,/type) ne 7 then begin
            message,'Timestamp must be a string',level=-1,/info
            return,result
        endif
    endif

    if n_elements(units) gt 0 then begin
        if size(units,/type) ne 7 then begin
            message,'units must be a string',level=-1,/info
            return,result
        endif
        if units ne 'Jy' and units ne 'Ta*' and units ne 'Ta' then begin
            message,'units must be one of "Jy", "Ta*", or "Ta" - defaults to "Ta" if not specified',level=-1,/info
            return,result
        endif
    endif

    if not keyword_set(quiet) then begin
        doTauWarning = 0
        if n_elements(tau) gt 0 then begin
            doTauWarning = n_elements(units) eq 0
            if n_elements(units) gt 0 then doTauWarning = units eq 'Ta'
        endif
        
        doApEffWarning = 0
        if n_elements(ap_eff) gt 0 then begin
            doApEffWarning = n_elements(units) eq 0
            if n_elements(units) gt 0 then doApEffWarning = units ne 'Jy'
        endif
        
        if doTauWarning and doApEffWarning then begin
            message,'tau and ap_eff have been supplied but are not used by units="Ta"',level=-1,/info
        endif else begin
            if doTauWarning then begin
                message,'tau has been supplied but is not used by units="Ta"',level=-1,/info
            endif else begin
                if doApEffWarning then begin
                    message,'ap_eff has been supplied but is not used by the requested units',level=-1,/info
                endif
            endelse
        endelse
    endif

    if n_elements(bswitch) gt 0 then begin
        if bswitch ne 0 and bswitch ne 1 and bswitch ne 2 then begin
            message,'bswitch must be 0, 1 or 2',level=-1,/info
            return,result
        endif
        ret_bswitch = bswitch
    endif else begin
        ret_bswitch = 0
    endelse

    if n_elements(sig_state) gt 0 then begin
        if sig_state ne 0 and sig_state ne 1 then begin
            message,'sig_state must be 0 or 1',level=-1,/info
            return,result
        endif
        ret_sig_state = sig_state
    endif else begin
        ret_sig_state = -1
    endelse

    if keyword_set(checkref) then begin
        if n_elements(refscan) eq 0 and n_elements(reftimestamp) eq 0 then begin
            message,'The reference scan number is required unless a reftimestamp is provided.',level=-1,/info
            return,result
        endif

        ; string argument type checks
        if n_elements(reffile) gt 0 then begin
            if size(reffile,/type) ne 7 then begin
                message,'Reffile must be a string',level=-1,/info
                return,result
            endif
        endif

        if n_elements(reftimestamp) gt 0 then begin
            if size(reftimestamp,/type) ne 7 then begin
                message,'Reftimestamp must be a string',level=-1,/info
                return,result
            endif
        endif
    endif

    ; other checks and defaults
    retIfnum = 0
    retPlnum = 0
    retFdnum = 0
    retSampler = ''
    retInstance = 0
    retRefinstance = 0

    ; indicate what defaults needs to be set
    ; don't double check them if the user has explicitly set them
    checkIfnum = 1
    checkPlnum = 1
    checkFdnum = 1

    ; need the instance set appropriate first so that we can set the scan_info
    if n_elements(instance) gt 0 then begin
        if n_elements(instance) gt 1 then begin
            message,'Only one INSTANCE can be calibrated at a time',level=-1,/info
            return,result
        endif
        if instance lt 0 then begin
            message,'INSTANCE must be >= 0',level=-1,/info
            return,result
        endif
        retInstance = instance
     endif

    ; need the scan info so that we can set the defaults as necessary/appropriate
    info = find_scan_info(scan, timestamp=timestamp,instance=retInstance,file=file)
    infoOK = size(info,/type) eq 8

    nfd = 0
    nif = 0
    npl = 0

    if infoOK then begin
       iftabDim = size(info.iftable,/dim)
       ; IDL always removes any trailing degenerate axes here
       ; so care must be taken when using the shape
       nif = iftabDim[0]
       nfd = 1
       if n_elements(iftabDim) gt 1 then begin
          nfd = iftabDim[1]
       endif
       npl = 1
       if n_elements(iftabDim) gt 2 then begin
          npl = iftabDim[2]
       endif
    endif

    ; checking default tuple in order: ifnum, fdnum, plnum
    ; order matters - defaults when unset depend on previously
    ;   set defaults in that order

    if n_elements(ifnum) gt 0 then begin
        if ifnum lt 0 then begin
            message,'IFNUM must be >= 0',level=-1,/info
            return,result
         endif
        if infoOK then begin
           if ifnum ge nif then begin
              s_nif = strtrim(string(nif),2)
              message,'IFNUM must be < '+s_nif, level=-1, /info
              return,result
           endif
        endif
        retIfnum = ifnum
        checkIfnum = 0
    endif 


    if n_elements(fdnum) gt 0 then begin
        if fdnum lt 0 then begin
            message,'FDNUM must be >= 0',level=-1,/info
            return,result
         endif
        if infoOK then begin
           if fdnum ge nfd then begin
              s_nfd = strtrim(string(nfd),2)
              message,'FDNUM must be < '+s_nfd, level=-1,/info
              return,result
           endif
        endif
        retFdnum = fdnum
        checkFdnum = 0
     endif
    
    if n_elements(plnum) gt 0 then begin
        if plnum lt 0 then begin
            message,'PLNUM must be >= 0',level=-1,/info
            return,result
         endif
        if infoOK then begin
           if plnum ge npl then begin
              s_npl = strtrim(string(npl),2)
              message,'PLNUM must be < '+s_npl, level=-1,/info
              return,result
           endif
        endif
        retPlnum = plnum
        checkPlnum = 0
     endif

    if checkIfnum then begin
       ; ifnum not set by user, set from info.iftable if possible
       if infoOK then begin
          ; lowest ifnum with any data, given other user choices
          count = 0
          ; array indices are unset when count=0
          ai = 0
          if checkFdnum then begin
             if checkPlnum then begin
                ; nothing already specified
                loc = where(info.iftable,count)
                if count gt 0 then ai = getIftabIndices(loc,nif,nfd,npl)
             endif else begin
                ; plnum specified
                loc = where(info.iftable[*,*,retPlnum],count)
                if count gt 0 then ai = getIftabIndices(loc,nif,nfd,1)
             endelse
          endif else begin
             if checkPlnum then begin
                ; fdnum specified, plnum is not
                loc = where(info.iftable[*,retFdnum,*],count)
                if count gt 0 then ai = getIftabIndices(loc,nif,1,npl)
             endif else begin
                ; both fdnum and plnum are specified
                loc = where(info.iftable[*,retFdnum,retPlnum],count)
                if count gt 0 then ai = getIftabIndices(loc,nif,1,1)
             endelse
          endelse
          if count gt 0 then begin
             ; ai has dimensions [3,count] unless count=1
             ; in either case, this form of indexing is OK
             ; find whatever the minimum value is along the fdnum axis
             retIfnum = min(ai[0,*])
          endif
          ; otherwise the default of 0 stands, there is no data
          ; the final check at the end will display the set of 
          ; possible choices using showiftab
       endif
    endif

    if checkFdnum then begin
       ; fdnum not set by user, retIfnum is now reliable either way
       ; so use it
       if infoOK then begin
          count = 0
          ai = 0
          if checkPlnum then begin
             loc = where(info.iftable[retIfnum,*,*],count)
             if count gt 0 then begin
                ai = getIftabIndices(loc,1,nfd,npl)
             endif
          endif else begin
             ; plnum already specified
             loc = where(info.iftable[retIfnum,*,retPlnum],count)
             if count gt 0 then begin
                ai = getIftabIndices(loc,1,nfd,1)
             endif
          endelse
          if count gt 0 then begin
             retFdnum = min(ai[1,*])
          endif
          ; otherwise the default of 0 stands, there is no data
          ; the final check at the end will display the set of 
          ; possible choices using showiftab
       endif
    endif

    if checkPlnum then begin
       if infoOK then begin
          ; only thing left to check, if count is positive then
          ; the first found value is the appropriate plnum as is
          loc = where(info.iftable[retIfnum,retFdnum,*],count)
          if count gt 0 then begin
             retPlnum=loc[0]
          endif
          ; otherwise the default of 0 stands, there is no data
          ; the final check at the end will display the set of 
          ; possible choices using showiftab
       endif
    endif

    if n_elements(intnum) gt 0 then begin
        if intnum lt 0 then begin
            message,'INTNUM must be >= 0', level=-1,/info
            return,result
        endif
    endif
 
    if n_elements(sampler) gt 0 then begin
        if strlen(sampler) gt 0 then begin
            if n_elements(fdnum) gt 0 or n_elements(ifnum) gt 0 or n_elements(plnum) gt 0 then begin
                message,'IFNUM, PLNUM, and FDNUM can not be supplied when SAMPLER is supplied',level=-1,/info
                return,result
            endif
            retSampler = sampler
            if not keyword_set(twofeeds) then begin
                retFdnum = -1
            endif
            retIfnum = -1
            retPlnum = -1
        endif
    endif else begin
       ; ifnum, plnum, fdnum have been set either by the user or by
       ; the default finding mechanism.  Check that they are valid
       ; if info is valid
       if infoOK then begin
          if not info.iftable[retIfnum,retFdnum,retPlnum] then begin
             ifstr = 'IFNUM:'+strtrim(string(retIfnum),2)+' '
             fdstr = 'FDNUM:'+strtrim(string(retFdnum),2)+' '
             plstr = 'PLNUM:'+strtrim(string(retPlnum),2)+' '
             print,"No data found at ", ifstr, fdstr, plstr
             showiftab,scan
             return,result
          endif
       endif
    endelse

    if keyword_set(checkref) then begin
        if n_elements(refinstance) gt 0 then begin
            if n_elements(refinstance) gt 1 then begin
                message,'Only one REFINSTANCE can be calibrated at a time',level=-1,/info
                return,result
            endif
            if refinstance lt 0 then begin
                message,'REFINSTANCE must be >= 0',level=-1,/info
                return,result
            endif
            retRefInstance = refinstance
        endif
        ; everything is okay
        ret = {ifnum:retIfnum,plnum:retPlnum,fdnum:retFdnum,sampler:retSampler,instance:retInstance,refinstance:retRefinstance,bswitch:ret_bswitch,sig_state:ret_sig_state}
    endif else begin
        ; everything is okay
        ret = {ifnum:retIfnum,plnum:retPlnum,fdnum:retFdnum,sampler:retSampler,instance:retInstance,bswitch:ret_bswitch,sig_state:ret_sig_state}
    endelse

    return,1
end

;+
; Private function to return the array indices in a 3D iftable array
; given the array dimensions.
;
; Used instead of array_indices because of the way IDL tosses out
; single-element arrays whenever possible, making it damn difficult to
; write general purpose code.  This routine always returns 3 values.
;
; The length of the 3rd axis is not important here.  There is no
; checking loc for validity (the only reason this might care about
; that value).
;
; IDL arrays are stored in fortran order.
;
; @param loc {in}{required}{type=integer} Vector of locations into a
; 3D array described by the other parmeters.
; @param nif {in}{required}{type=integer} Length of first axis.
; @param nfd {in}{required}{type=integer} Length of second axis.
;
; @returns (3,n_elements(loc)) array, one 3-D vector giving the
; coordinates into a 3D array described by nif, nfd, npl for each
; element of loc.
; 
; @private
;-
function getIftabIndices, loc, nif, nfd, npl
  compile_opt idl2

  nloc = n_elements(loc)
  result = lonarr(3,nloc)

  for i=0,nloc-1 do begin
     thisLoc = loc[i]
     
     ifnum = thisLoc mod nif
     fdnum = ((thisLoc-ifnum)/nif) mod nfd
     plnum = (thisLoc - ifnum - fdnum*nfd)/(nif*nfd)

     result[*,i] = [ifnum,fdnum,plnum]
  endfor
  return,result
end
     
