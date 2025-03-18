;+
; Show all of the Tsys values associated with a scan.
;
; <p>
; This uses gettp to retrieve the system temperature for each sampler
; in a scan.  If the bysampler keyword is set then they are displayed
; under each sampler name with at most 8 samplers per row.  If that
; keyword is not set then they are displayed by feed and polarization
; with one row for each spectral window (ifnum).  Any triad of
; spectral window, feed, and polarization that doesn't have any data
; associated with is left blank in the output.
;
; <p>
; For the default display by feed and polarization the frequency,
; scan, az, and el values are added to the line.  These avalues are
; useful when investigating changes in tsys with el, for example.  
;
; <p>
; Because this must retrieve the raw data to calculated Tsys it often
; takes time to finish.
;
; <p><B>Note:</B> This only works for the auto-correlation case.
; Cross-correlation data will be both incompletely labelled in the
; output and the Tsys determined from gettp is not appropriate.
;
; <p><B>Contributions from Glen Langston, Bob Garwood - NRAO-CV</B>
;
; @param scan {in}{required}{type=integer} The scan number of
; interest.
; @keyword bysampler {in}{optional}{type=boolean} When set the system
; temperature values will be identified by sampler name.
;
; @version $Id$
;- 
pro showtsys, scan, bysampler=bysampler
    compile_opt idl2
    if n_elements(scan) eq 0 then begin
        print,'A scan number is required'
        return
    endif

    si = scan_info(scan,/quiet)

    if size(si,/type) ne 8 then begin
        print,'Scan not found'
        return
    endif

    if si.n_cal_states ne 2 then begin
        print,'Requires 2 cal states to determine Tsys'
        return
    endif

    nfeed = si.n_feeds
    npol = si.n_polarizations
    nif = si.n_ifs
    nsamp = si.n_samplers

    isFrozen = !g.frozen
    freeze

    if keyword_set(bysampler) then begin
                                ; awkward, may be badly sorted due to
                                ; things like A9 sorting after A10
        ; sort on ports only
        ports = fix(strmid(si.samplers,1))
        sortedSamplers = si.samplers[sort(ports)]
        lines = ceil(nsamp/8.0)
        for i=0,lines-1 do begin
            first = i*8
            last = min([first+7,nsamp-1])
            for k=first,last do begin
                print,sortedSamplers[k],format='($,"  ",A3," ")'
            endfor
            print
            for k=first,last do begin
                gettp,scan,sampler=sortedSamplers[k],/q
                print,!g.s[0].tsys,format='($,f5.1," ")'
            endfor
            print
            print
        endfor
    endif else begin
        ; label line first
        print,format='($,"#IF")'
        for j=0,(nfeed-1) do begin
            for k=0,(npol-1) do begin
                print,si.feeds[j],strmid(si.polarizations[k],0,1),format='($,i2,a1,"   ")'
            endfor
        endfor
        ; print label once
        print,"     MHz     Az(d)  El(d) Scan"

        for i=0,(nif-1) do begin
            print,i,format='($,i2," ")'
            for j=0,(nfeed-1) do begin
                for k=0,(npol-1) do begin
                    select,count,scan=scan,ifnum=i,fdnum=j,plnum=k,/quiet
                    if count ne 0 then begin
                        gettp,scan,ifnum=i,fdnum=j,plnum=k,/q
                        print,!g.s[0].tsys,format='($,f5.1," ")'
                    endif else begin
                        print,format='($,"      ")'
                    endelse
                endfor
            endfor
            print,!g.s[0].center_frequency*1.E-6,format='($,f11.3)'
            print,!g.s[0].azimuth, !g.s[0].elevation,scan,$\
                  format='($,f7.1," ",f6.1,i5)'
            print
        endfor
    endelse
    if not isFrozen then unfreeze
end
 
