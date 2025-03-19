; docformat = 'rst'

;+
; Used by the calibration routines (getfs,getps,getnod,etc) to
; summarize things at the end, just before they return.
;
; End users should never use this directly although user's
; modifying the calibration routines may need to modify this routine
; or at least understand the arguments involved in this routine.
;
; There is no argument checking here for the required parameters.
;
; :Params:
;   scan : in, required, type=integer
;       The scan number (in the case of a refScan keyword being supplied,
;       this is the signal scan's keyword - used by getsigref).
;   tsys : in, required, type=float
;       The system temperature (K) of the result.
;   units : in, required, type=string
;       The units of the result. Recognized units are "Ta","Ta*", and "Jy".
;       A summary line without any units will be printed for any other value 
;       of this parameter.
; 
; :Keywords:
;   tsysints : in, optional, type=float
;       An array of system temperatures from each integration to be output 
;       at the end of the other summary information.  The second dimension
;       is the number of independent Tsys's to be summarized.  So, if Tsys 
;       has dimensions of [11,2] then 2 summary Tsys values will be printed
;       and the Tsys values will be averaged according to the eqweight keyword.
;       If this is omitted, no extra Tsys information is printed.  This is 
;       typically used to summarize the system temperature in the signal 
;       scan or in each of the beam combinations (e.g. Nod). Formatting is
;       such that for up to 4 Tsys values the result should be less than 80
;       characters.
;   tauInts : in, optional, type=float
;       The tau (opacity) used in each integration when unit conversion was
;       done, if any. Only used if units are 'Jy' or 'Ta*'. The printed value
;       is a simple average of this keyword.
;   apEffInts : in, optional, type=float
;       The aperture efficiency used in each integration when unit conversion 
;       was done, if any.  Only used if units are 'Jy'. The printed value is
;       a simple average of this keyword.
;   missingInts : in, optional, type=integer
;       The number of missing integrations to be reported (if missingRefInts 
;       is set then this is assumed to be the missing integrations from the
;       signal beam - used by getbs only).
;   missingBeams : in, optional, type=integer
;       The number of integrations that were processed with only one beam 
;       (used by getnod and getbs).
;   missingRefInts : in, optional, type=integer
;       The number of missing integrations from the reference beam to be 
;       reported (used by getbs only).
;   eqweight : in, optional, type=boolean
;       When set, then the tsysInts are averaged with equal weight, otherwise
;       they are averaged similarly to the way accum does it (assuming equal 
;       exposure) so that the resulting tsys is as if the spectra having those 
;       tsys values had been averaged - so that these values can be more directly
;       compared with the result's tsys value.
;   bswitch : in, optional, type=integer
;       Same meaning as in getbs. In the bswitch=0 case, then the tsysInts will
;       have 8 as the second dimension and the tsys values from each beam are 
;       first averaged before the tsys values from integration are averaged.
;   refScan : in, optional, type=integer
;       The scan number of the reference scan. Used by getsigref.
;
; @private_file
;-
pro calsummary, scan, tsys, units, $
                tsysInts=tsysInts, tauInts=tauInts, $
                apEffInts=apEffInts, missingInts=missingInts, $
                missingBeams=missingBeams, missingRefInts=missingRefInts, $
                eqweight=eqweight, bswitch=bswitch, refScan=refScan, $
                ifnum=ifnum, plnum=plnum, fdnum=fdnum
    compile_opt idl2

    if n_elements(missingInts) gt 0 then begin
        if n_elements(missingRefInts) eq 0 then begin
            if missingInts gt 0 then begin
                print,string(strtrim(missingInts,2), $
                             format='("Blanked spectra: ignored ",a," integrations")')
            endif
        endif else begin
            ; only used in the GETBS case
            if missingRefInts gt 0 then begin
                print,string(strtrim(missingRefInts,2), $
                             format='("Blanked spectra: ignored ",a," integrations from ref beam")')
            endif
            if missingInts gt 0 then begin
                print,string(strtrim(missingInts,2), $
                             format='("Blanked spectra: ignored ",a," integrations from sig beam")')
            endif 
        endelse
    endif

    if n_elements(missingBeams) gt 0 then begin
        if missingBeams gt 0 then begin
            print,string(strtrim(missingBeams,2), $
                         format='("Blanked spectra: ignored 1 feed in ", a, " integrations")')
        endif
    endif

    dobswitch = 0
    if n_elements(bswitch) eq 1 then begin
        dobswitch = bswitch eq 0
    endif

    dorefscan = n_elements(refScan) eq 1

    sz = size(tsysInts)
    if sz[0] gt 0 then begin
        nTsys = 1
        if sz[0] eq 2 then nTsys = sz[2]
        if dobswitch then nTsys = nTsys / 2
        extraTsys = fltarr(nTsys)
        if keyword_set(eqweight) then begin
                                ; simple average
            for i=0,(nTsys-1) do begin
                if dobswitch then begin
                    extraTsys[i] = mean(tsysInts[*,[i,(i+4)]],/nan)
                endif else begin
                    extraTsys[i] = mean(tsysInts[*,i],/nan)
                endelse
            endfor
        endif else begin
                                ; nearly equivalent to what accum does
                                ; same if exposure is the same in all integrations
            for i=0,(nTsys-1) do begin
                if dobswitch then begin
                    theseTsys = tsysInts[*,[i,(i+4)]]
                endif else begin
                    theseTsys = tsysInts[*,i]
                endelse
                finiteLoc = where(finite(theseTsys),finiteCount)
                if finiteCount gt 0 then begin
                    invTsysSq = 1.0/(theseTsys[finiteLoc])^2
                    extraTsys[i] = sqrt(float(finiteCount)/total(invTsysSq))
                endif else begin
                    extraTsys[i] = theseTsys[0]
                endelse
            endfor
        endelse
    endif

    ; construct the output string
    ; SCAN number(s)
    if dorefscan then begin
        if units eq 'Jy' and n_elements(extraTsys) gt 1 then begin
            fmt = '(i5,x,i5)'
        endif else begin
            fmt = '("SigScan: ",i5,"  RefScan: ",i5)'
        endelse
        msg = string(scan,refscan,format=fmt)
    endif else begin
        if units eq 'Jy' and n_elements(extraTsys) gt 1 then begin
            fmt = '(i5)'
        endif else begin
            fmt = '("Scan: ",i5)'
        endelse
        msg = string(scan,format=fmt)
     endelse

    ; ifnum, fdnum, plnum
    tupleStr = ""             ; rarely ifnum, fdnum, and plnum are not supplied here
    if n_elements(ifnum) gt 0 or n_elements(fdnum) gt 0 or n_elements(plnum) gt 0 then begin
       tupleStr = " ("
       needsSpace = 0
       if n_elements(ifnum) gt 0 then begin
          sifnum = strtrim(string(ifnum),2)
          tupleStr = tupleStr + "IF:"+sifnum
          needsSpace = 1
       endif
       if n_elements(fdnum) gt 0 then begin
          if needsSpace then tupleStr = tupleStr + " "
          sfdnum = strtrim(string(fdnum),2)
          tupleStr = tupleStr + "FD:"+sfdnum
          needsSpace = 1
       endif
       if n_elements(plnum) gt 0 then begin
          if needsSpace then tupleStr = tupleStr + " "
          splnum = strtrim(string(plnum),2)
          tupleStr = tupleStr + "PL:"+splnum
       endif
       tupleStr = tupleStr + ") "
    endif

    ; Tsys formatting
    if (units eq 'Jy' or units eq 'Ta*') and n_elements(extraTsys) gt 1 then begin
        tsysFmt = '(f6.1)'
        tsysTrail = ' :'
    endif else begin
        tsysFmt = '(f7.2)'
        tsysTrail = '  '
    endelse
    tsysAsString = string(tsys,format=tsysFmt)  

    if units eq 'Jy' then begin
        meanTau = mean(tauInts,/nan)
        meanApEff = mean(apEffInts,/nan)
        if n_elements(extraTsys) gt 1 or dorefscan then begin
            midFmt = '("  units: Jy  tau:",f5.3," ap_eff:",f5.3,"  Tsys:")'
        endif else begin
            midFmt = '("  units: Jy  tau:",f5.3,"  ap_eff:",f5.3,"   Tsys:")'
        endelse
        midMsg = string(meanTau,meanApEff,format=midFmt)
    endif else begin
        if units eq 'Ta*' then begin
            meanTau = mean(tauInts,/nan)
            midFmt = '("  units: Ta* (K)  tau: ",f5.3,"  Tsys:")'
            midMsg = string(meanTau,format=midFmt)
        endif else begin
            if units eq 'Ta' then begin
                midMsg = "  units: Ta (K)  Tsys:"
            endif else begin
                ; leave units field off
                midMsg = "   Tsys:"
            endelse
        endelse
    endelse
        
    msg = msg + tupleStr + midMsg + tsysAsString
    if n_elements(extraTsys) gt 0 then begin
        msg = msg + tsysTrail
        for i=0,(n_elements(extraTsys)-1) do msg = msg + string(extraTsys[i],format=tsysFmt)
    endif
    print,msg         
end
