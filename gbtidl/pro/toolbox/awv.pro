; docformat = 'rst'

;+
; Function to find the area, width, and velocity of a galaxy profile.
;
; There are four ways in which the left and right (low channel number and 
; high channel number) edges of the galaxy profile can be determined. The
; mode parameter selects one of these methods:
; 
; 1. As a fraction of the mean within the region of interest. The mean
;    of data from brange through erange is calculated. The edges are 
;    then those locations where the data values are greater than fract*mean
;    for 3 consecutive channels starting from the end points of the 
;    region of interest and searching towards the center.
; 2. As a fraction of the maximum value within the region of interest. 
;    The peak of data from brange to erange is found. The edges are 
;    then those locations where the data values are greater than 
;    fract*(peak-rms) for 3 consecutive channels starting from the end
;    points of the region of interest and searching towards the center.
; 3. As a fraction of each of two peaks - identified by the user. The
;    user uses the cursor to mark two peaks in the region of interest 
;    or those peaks are identified through the lefthorn and righthorn 
;    parameters.  The maximum value within 10 channels of each user-supplied
;    peak location is found.  The left edge is where the data value 
;    falls below fract*(peak-rms) for 3 consecutive channels searched
;    from the location of the peak.  The right-channel peak is similarly
;    used to find the right edge.
; 4. A polynomial is fit to either side of the profile between 15-85% of
;    (peak-rms) (where the peak is from the relevent side of the profile - 
;    the two peaks are identified by the user). The velocity of the 
;    polynomical fit at fract*(peak-rms) is then found for both sides of 
;    the profile. The difference between the two is the width, the mean is
;    the central velocity. The order of the polynomial is chosen by the user
;    (linear fits are usually sufficient). This scheme (further described in 
;    Springob etal 2006) has the advatange of averaging out noise effects
;    from either side of the profile.
;
; In the first 3 modes, the final left and right edge are linear
; interpolations to get the fractional channel where data value crossed
; the threshold given by fract for that particular mode.
;
; If an edge is not found, a warning is issued and the appropiate
; end-point of the region of interest is used.  Only the data values
; within the region of interest are used here.
;
; The returned value is a 6-element array with these values, in
; this order.
;
; .. list-table::
;   :widths: 30, 70
;   :header-rows: 0
; 
;   * - **Area**      
;     - The sum of data[i]*abs(vel[i+1]-vel[i-1])/2.0 for all i
;       from brange to erange (modes 1 and 2) or between the channels where
;       the data values first become negative moving out from the two peaks
;       found in mode 3 (not including that transition channel).
;   * - **Width**     
;     - The absolute value of the difference between the left and right edges
;       as determined for that mode.
;   * - **Velocity**  
;     - The mean of the left and right edges as determined for that mode.
;   * - **Error on Area**
;     - Error estimate on the Area. The error on Area is only set for the 
;       fract=0.5 and fract=0.2 cases. Unset error estimates have a value of 0.0
;   * - **Error on Width** 
;     - Error estimate on the Width. The Width error is only set by mode 4. 
;       For mode 4, the Width error is always set at 2x the Velocity error. 
;       Unset error estimates have a value of 0.0
;   * - **Error on Velocity**
;     - Error estimate on the Velocity. The Velocity error is only set by mode 4. 
;       Unset error estimates have a value of 0.0
;
; Blanked data is ignored by this routine.  Since the velocities
; used to calculate widths and centers come from the centers of the
; valid channels, ignoring the blanked data is equivalent to replacing
; the blanked data by it's nearest non-blanked neighbor in the
; direction of the edge searches.  If the data is all blanked in the
; region of interest, the returned values are all 0.
;
; This code adapted from code in use at Arecibo.  This particular
; version was originally from Karen O'Neil. Option 4 added by Karen Masters
; as part of work for GBT06A-027, GBT06B-021, GBT06C-049, GBT08B-003: 
; "Mapping Mass in the Nearby Universe with 2MASS".
;
; Contributed By: Karen O'Neil, Bob Garwood, and Karen Masters.
;
; :Params:
;   data : in, required, type=float array
;       The data values.
;   vel : in, required, type=float array
;       The velocities at each data point, in km/s.
;   brange : in, required, type=integer
;       The first channel to use.
;   erange : in, required, type=integer
;       The last channel to use.
;   mode : in, required, type=integer
;       The method to use in finding the returned values.
;   fract : in, required, type=float
;       Used in locating the edges of the galaxy profile. 
;       See the documentation for more details.
; 
; :Keywords:
;   lefthorn : in, optional, type=float
;       The location (in channels) of the left (low channel number) peak
;       in the profile. Used only in mode 3.  If this or righthorn are
;       not provided, the user is asked to use the cursor to mark these 
;       locations.
;   righthorn : in, optional, type=float
;       The location (in channels) of the right (high channel number) peak 
;       in the profile. Used only in mode 3.  If this or lefthorn are not 
;       provided, the user is asked to use the cursor to mark these locations.
;   rms : in, optional, type=float
;       Used in modes 2 and 3 as described above. If this is not supplied,
;       defaults to the stddev of data within the region of interest.
;   quiet : in, optional, type=boolean
;       When set, the results are not printed to the terminal (they are 
;       still returned).
;
; :Returns:
;   the values in a 3 element array: [0] is the area, [1] is the width
;   and [2] is the velocity.  Returns 0.0 for all 3 values on error.
;
;-
function awv, data,vel,brange,erange,mode,fract,lefthorn=lefthorn,$
              righthorn=righthorn,rms=rms,quiet=quiet
    compile_opt idl2

    res=fltarr(6)

    ; argument checks
    if n_params() ne 6 then begin
        usage,'awv'
        return, res
    endif

    if n_elements(data) ne n_elements(vel) then begin
        message,'data and vel must have the same number of elements',/info
        return, res
    endif

    ; in case the user entered the channel numbers in the wrong order
    if brange gt erange then begin
        thisfirst = erange
        thiserange = brange
    endif else begin
        thisfirst = brange
        thiserange = erange
    endelse

    nptsTot = n_elements(data)

    ; watch for out of bounds values
    if thisfirst lt 0 then thisfirst = 0
    if thiserange lt 0 then thiserange = 0
    if thisfirst ge nptsTot then thisfirst = (nptsTot-1)
    if thiserange ge nptsTot then thiserange = (nptsTot-1)

    if brange eq erange then message,'Warning: brange and erange are the same point',/info

    data1=data[thisfirst:thiserange]
    vel1 = vel[thisfirst:thiserange]

    finiteDataLoc = where(finite(data1),finiteCount)
    if finiteCount eq 0 then begin
        message,'No non-blanked data found in this region',/info
        return,res
    endif
    finiteData = data1[finiteDataLoc]
    finiteVel = vel1[finiteDataLoc]
    finiteFirst = thisfirst + finiteDataLoc[0]
    finiteRange = thisfirst + finiteDataLoc[finiteCount-1]

    switch mode of 
        1:
        2: begin
            ; determination of flevel differs between 1 and 2
            if mode eq 1 then begin
                ; the flevel is fract * the mean over the region of interest.
                AVE = mean(finiteData) 
                if FRACT GT 1 then message ," Fraction > 1; do not necessarily  expect the correct answer",/info
                FLEVEL =fract*AVE
            endif else begin
                ; the flevel is fract * the (peak-rms) over the region of interest.
                peak = max(finiteData)
                if n_elements(rms) eq 0 then rms=stddev(finiteData)
                peak =peak - rms
                FLEVEL = FRACT*peak
            endelse

            if finiteCount lt 4 then begin
                ; pathological case
                jl = 0
                jr = (finiteCount-1)
            endif else begin
                ; find the channels that actually define the edges of the profile
                ; only use data1
                ; find the left edge
                jl = -1
                repeat begin
                    jl=jl+1 
                    if jl gt (finiteCount-3) then break
                endrep until ((data1[jl] ge flevel) and (data1[jl+1] ge flevel) and (data1[jl+2] ge flevel))
                if (jl gt (finiteCount-3)) then begin
                    message,'Could not find left edge, using '+strtrim(finiteFirst,2),/info
                    jl = 0
                endif
                jr=finiteCount
                ; find the right edge - stop looking when it gets to jl
                repeat begin
                    jr=jr-1 
                    if jr lt jl or jr lt 2 then break
                endrep until ((data1[jr] ge flevel) and (data1[jr-1] ge flevel) and (data1[jr-2] ge flevel))
                if (jr lt jl) or (jr lt 2) then begin
                    message,'Could not find right edge, using '+strtrim(finiteRange,2),/info
                    jr = (finiteCount-1)
                endif
                ; area comes from entire region of interest
            endelse
            jj1 = 0
            jj2 = (finiteCount-1)
            fpeak1=flevel
            fpeak2=flevel
            break
        end
        3: begin
            if n_elements(rms) eq 0 then rms=stddev(finiteData)
            if n_elements(righthorn) eq 0 or n_elements(lefthorn) eq 0 then begin
                print, 'click on the positions for the two peaks'
                clk1 = click()
                if not clk1.ok then begin
                    message,'There was a problem with plotter, can not continue',/info
                    return, res
                endif
                clk2 = click()
                if not clk2.ok then begin
                    message,'There was a problem with plotter, can not continue',/info
                    return, res
                endif
                ; get clicked channels relative to thisfirst - in region of interest
                il=round(clk1.chan) - thisfirst
                ir=round(clk2.chan) - thisfirst
            endif else begin
                ; convert lefthorn and righthorn to channels relative to thisfirst
                il=round(lefthorn) - thisfirst
                ir=round(righthorn) - thisfirst
            endelse
            if (il gt ir) then begin
                tmp = il
                il = ir
                ir = tmp
            endif
            ; translate il and ir into elements in finiteDataLoc
            ilLocBigger = where(finiteDataLoc ge il,ilbiggerCount)
            ilLocSmaller = where(finiteDataLoc le il,ilsmallerCount)
            if ilbiggerCount eq 0 then begin
                if ilsmallerCount eq 0 then begin
                    ilFinite = 0
                endif else begin
                    ilFinite = ilLocSmaller[ilsmallerCount-1]
                endelse
            endif else begin
                if ilsmallerCount eq 0 then begin
                    ilFinite = ilLocBigger[0]
                endif else begin
                    ilTestBigger = finiteDataLoc[ilLocBigger[0]]
                    ilTestSmaller = finiteDataLoc[ilLocSmaller[ilsmallerCount-1]]
                    if ilTestBigger eq ilTestSmaller then begin
                        ilFinite = ilLocBigger[0]
                    endif else begin
                        if (ilTestBigger-il) lt (il-ilTtestSmaller) then begin
                            ilFinite = ilLocSmaller[ilsmallerCount-1]
                        endif else begin
                            ilFinite = ilLocBigger[0]
                        endelse
                    endelse
                endelse
            endelse
            ;
            irLocBigger = where(finiteDataLoc ge ir,irbiggerCount)
            irLocSmaller = where(finiteDataLoc le ir,irsmallerCount)
            if irbiggerCount eq 0 then begin
                if irsmallerCount eq 0 then begin
                    irFinite = (finiteCount-1)
                endif else begin
                    irFinite = irLocSmaller[irsmallerCount-1]
                endelse
            endif else begin
                if irsmallerCount eq 0 then begin
                    irFinite = irLocBigger[0]
                endif else begin
                    irTestBigger = finiteDataLoc[irLocBigger[0]]
                    irTestSmaller = finiteDataLoc[irLocSmaller[irsmallerCount-1]]
                    if irTestBigger eq irTestSmaller then begin
                        irFinite = irLocBigger[0]
                    endif else begin
                        if (irTestBigger-ir) lt (ir-irTtestSmaller) then begin
                            irFinite = irLocSmaller[irsmallerCount-1]
                        endif else begin
                            irFinite = irLocBigger[0]
                        endelse
                    endelse
                endelse
            endelse

            

            ; find nearest maximum within 10 channels of selected value, watch out for the edges
            lmin = ilFinite-10 & lmax = ilFinite+10
            rmin = irFinite-10 & rmax = irFinite+10
            if lmin lt 0 then lmin = 0
            if lmin ge finiteCount then lmin = finiteCount-1
            if lmax lt 0 then lmax = 0
            if lmax ge finiteCount then lmax = finiteCount-1
            if rmin lt 0 then rmin = 0
            if rmin ge finiteCount then rmin = finiteCount-1
            if rmax lt 0 then rmax = 0
            if rmax ge finiteCount then rmax = finiteCount-1

            fpeakl=max(finiteData[lmin:lmax],lh)
            fpeakr=max(finiteData[rmin:rmax],rh)

            jl = lh+lmin
            jr = rh+rmin

            jj1= jl
            jj2 = jr

            ; Find channels at fract level of horns and at 1st null

            ; subtract the rms from the peak value
            FPEAK1 = FRACT*(fpeakl-RMS)
            ; find left edge where value goes below fpeak1 for 3 consecutive finite channels
            if jl ge 2 then begin
                repeat begin
                    jl=jl-1 
                    if (jl lt 2) then break
                endrep until ((finiteData[jl] le fpeak1) and (finiteData[jl-1] le fpeak1) and (finiteData[jl-2] le fpeak1))
            endif
            if (jl lt 2) then begin
                message,'Left edge was not found, using left maximum location.',/info
                jl=jj1-1
            endif

            ; look for place where data values get negative
            if jj1 gt 0 then begin
                repeat begin
                    jj1=jj1-1 
                    if jj1 lt 0 then break
                endrep until (finiteData[jj1] le 0.0)
            endif

            if (jj1 lt 0) then begin
                message,string(finiteFirst,format='("left start of profile was not found, using ",i6)'),/info
                jj1 = -1
            endif
            ; move right one channel
            jl=jl+1
            jj1=jj1+1

            ; repeat for the right edge
            ; subtract the rms from the peak value
            FPEAK2 = FRACT*(fpeakr-RMS)
            ; find right edge where value goes below fpeak2 for 3 consecutive channels
            if (jr lt (finiteCount-2)) then begin
                repeat begin
                    jr=jr+1 
                    if (jr gt (finiteCount-3)) then break
                endrep until ((finiteData[jr] le fpeak2) and (finiteData[jr+1] le fpeak2) and (finiteData[jr+2] le fpeak2))
            endif
            if (jr gt (finiteCount-3)) then begin 
                message,'Right edge was not found, using right maximum location.',/info
                jr=jj2+1
            endif

            ; look for place where data values get negative
            if jj2 lt (finiteCount-1) then begin
                repeat begin
                    jj2=jj2+1 
                    if (jj2 ge finiteCount) then break
                endrep until (finiteData[jj2] le 0.0)
            endif
            if (jj2 ge finiteCount) then begin
                message,string(finiteRange+finiteCount-1,format='("right start of profile was not found, using ",i6)'),/info
                jj2 = finiteCount
            endif
            ; move left one channel
            jr=jr-1
            jj2=jj2-1
            break
        end
        4: begin
            if n_elements(rms) eq 0 then rms=stddev(data1)
            if n_elements(righthorn) eq 0 or n_elements(lefthorn) eq 0 then begin
               print, 'click on the positions for the two peaks'
               clk1 = click()
               if not clk1.ok then begin
                  message,'There was a problem with plotter, can not continue',/info
                  return, res
               endif
               clk2 = click()
               if not clk2.ok then begin
                  message,'There was a problem with plotter, can not continue',/info
                  return, res
               endif
               ; get clicked channels relative to thisfirst - in region of interest
               il=round(clk1.chan) - thisfirst
               ir=round(clk2.chan) - thisfirst
            endif else begin
               ; convert lefthorn and righthorn to channels relative to thisfirst
               il=round(lefthorn) - thisfirst
               ir=round(righthorn) - thisfirst
            endelse
            if (il gt ir) then begin
                tmp = il
                il = ir
                ir = tmp
            endif

            ; translate il and ir into elements in finiteDataLoc
            ilLocBigger = where(finiteDataLoc ge il,ilbiggerCount)
            ilLocSmaller = where(finiteDataLoc le il,ilsmallerCount)
            if ilbiggerCount eq 0 then begin
                if ilsmallerCount eq 0 then begin
                    ilFinite = 0
                endif else begin
                    ilFinite = ilLocSmaller[ilsmallerCount-1]
                endelse
            endif else begin
                if ilsmallerCount eq 0 then begin
                    ilFinite = ilLocBigger[0]
                endif else begin
                    ilTestBigger = finiteDataLoc[ilLocBigger[0]]
                    ilTestSmaller = finiteDataLoc[ilLocSmaller[ilsmallerCount-1]]
                    if ilTestBigger eq ilTestSmaller then begin
                        ilFinite = ilLocBigger[0]
                    endif else begin
                        if (ilTestBigger-il) lt (il-ilTtestSmaller) then begin
                            ilFinite = ilLocSmaller[ilsmallerCount-1]
                        endif else begin
                            ilFinite = ilLocBigger[0]
                        endelse
                    endelse
                endelse
            endelse
            ;
            irLocBigger = where(finiteDataLoc ge ir,irbiggerCount)
            irLocSmaller = where(finiteDataLoc le ir,irsmallerCount)
            if irbiggerCount eq 0 then begin
                if irsmallerCount eq 0 then begin
                    irFinite = (finiteCount-1)
                endif else begin
                    irFinite = irLocSmaller[irsmallerCount-1]
                endelse
            endif else begin
                if irsmallerCount eq 0 then begin
                    irFinite = irLocBigger[0]
                endif else begin
                    irTestBigger = finiteDataLoc[irLocBigger[0]]
                    irTestSmaller = finiteDataLoc[irLocSmaller[irsmallerCount-1]]
                    if irTestBigger eq irTestSmaller then begin
                        irFinite = irLocBigger[0]
                    endif else begin
                        if (irTestBigger-ir) lt (ir-irTtestSmaller) then begin
                            irFinite = irLocSmaller[irsmallerCount-1]
                        endif else begin
                            irFinite = irLocBigger[0]
                        endelse
                    endelse
                endelse
            endelse

            ; find nearest maximum within 10 channels of selected value, watch out for the edges
            lmin = ilFinite-10 & lmax = ilFinite+10
            rmin = irFinite-10 & rmax = irFinite+10
            if lmin lt 0 then lmin = 0
            if lmin ge finiteCount then lmin = finiteCount-1
            if lmax lt 0 then lmax = 0
            if lmax ge finiteCount then lmax = finiteCount-1
            if rmin lt 0 then rmin = 0
            if rmin ge finiteCount then rmin = finiteCount-1
            if rmax lt 0 then rmax = 0
            if rmax ge finiteCount then rmax = finiteCount-1

            fpeakl=max(finiteData[lmin:lmax],lh)
            fpeakr=max(finiteData[rmin:rmax],rh)

            jl = lh+lmin
            jr = rh+rmin

            jj1 = jl
            jj2 = jr

            ; Fit polynomial between 0.15(fpeak-rms) and 0.85(fpeak-rms)

            ; subtract the rms from the peak value
            FPEAK1 = (fpeakl-RMS)
	    pminl = 0.15*FPEAK1
	    pmaxl = 0.85*FPEAK1

            ; find left edge where value goes below pminl and pmaxl for 3 consecutive channels
	    ; first pmaxl
            if jl ge 2 then begin
                repeat begin
                    jl=jl-1 
                    if (jl lt 2) then break
                endrep until ((finiteData[jl] le pmaxl) and (finiteData[jl-1] le pmaxl) and (finiteData[jl-2] le pmaxl))
            endif
            if (jl lt 2) then begin
                message,'Left edge was not found, using left maximum location.',/info
                jl=jj1-1
            endif

	    ; now pminl
            if jj1 ge 2 then begin
                repeat begin
                    jj1=jj1-1 
                    if (jj1 lt 2) then break
                endrep until ((finiteData[jj1] le pminl) and (finiteData[jj1-1] le pminl) and (finiteData[jj1-2] le pminl))
            endif
            if (jj1 lt 2) then begin
                message,'Left edge was not found, using left maximum location.',/info
                jj1=-1
            endif

            ; move right one channel

            jl=jl+1
            jj1=jj1+1

	    ;print,jl,jj1

            ; repeat for the right edge
            ; subtract the rms from the peak value
            FPEAK2 = (fpeakr-RMS)
	    pminr = 0.15*FPEAK2
	    pmaxr = 0.85*FPEAK2

            ; find right edge where value goes below pminr and pmaxr for 3 consecutive channels
	    ; first pmaxr
            if (jr lt (finiteCount-2)) then begin
                repeat begin
                    jr=jr+1 
                    if (jr gt (finiteCount-3)) then break
                endrep until ((finiteData[jr] le pmaxr) and (finiteData[jr+1] le pmaxr) and (finiteData[jr+2] le pmaxr))
            endif
            if (jr gt (finiteCount-3)) then begin 
                message,'Right edge was not found, using right maximum location.',/info
                jr=jj2+1
            endif

	    ; now pminr
            if (jj2 lt (finiteCount-2)) then begin
                repeat begin
                    jj2=jj2+1 
                    if (jj2 gt (finiteCount-3)) then break
                endrep until ((finiteData[jj2] le pminr) and (finiteData[jj2+1] le pminr) and (finiteData[jj2+2] le pminr))
            endif
            if (jj2 gt (finiteCount-3)) then begin 
                message,'Right edge was not found, using right maximum location.',/info
                jj2=finiteCount
            endif

            ; move left one channel
            jr=jr-1
            jj2=jj2-1

	     ;Fits sides of profile - fit is done in velocities
	     resultl = poly_fit(finiteVel[jj1:jl],finiteData[jj1:jl],1,sigma=sigmal,yerror=yerrorl,status=status)
	     if (status ne 0) then print,'fit to left side fails on status=',status
	     resultr = poly_fit(finiteVel[jr:jj2],finiteData[jr:jj2],1,sigma=sigmar,yerror=yerrorr,status=status)
	     if (status ne 0) then print,'fit to right side fails on status=',status

                                ; Plot fits over data. - x array may
                                ;                        not be in velocities
             if !g.has_display then begin
                x=getxarray()
                ; convert x to chan first - this will be a noop if already chans
                xchan = xtochan(x)
                ; then to V, this always gets v in m/s
                xvel = chantovel(getplotterdc(),xchan)
                ; scale that to km/s to get x as v in units of fit
                xvel /= 1.e3
                yl = resultl[0]+resultl[1]*xvel
                yr = resultr[0]+resultr[1]*xvel
                ; but plot these against the original x
                gbtoplot,x,yl,color=2551
                gbtoplot,x,yr,color=2551
             endif
	
	     ;Get widths
	      vl = (fract*FPEAK1 - resultl[0])/resultl[1]
	      vr = (fract*FPEAK2 - resultr[0])/resultr[1]

	      W = abs(vr - vl)
	      V = (vr + vl)/2.
	      verr=0.5*sqrt((rms/resultl[1])^2+(rms/resultr[1])^2)
              werr=2.*verr

	      al=1000*(resultl[0]+V*resultl[1])
	      ar=1000*(resultr[0]+V*resultr[1])
	      bl=resultl[1]*1000
	      br=resultr[1]*1000	
	      p1=(FPEAK1+RMS)*1000
	      p2=(FPEAK2+RMS)*1000
    	      if not keyword_set(quiet) then print, 'Right side fit (a + bx) =',al,bl, format='(a60,2f7.2)'	
    	      if not keyword_set(quiet) then print, 'Left side fit (a + bx) =',ar,br, format='(a60,2f7.2)'	
    	      if not keyword_set(quiet) then print, 'Peaks (right then left) =', p1, p2, format='(a60,2f7.2)'

 	    ;Reset jj1 and jj2 to limits of user defined profile to measure flux.
            jj1 = 0
            jj2 = (finiteCount-1)

            break
        end
        else: begin
            message,'Unrecognized mode, must be 1,2,3 or 4',/info
            return, -1
        end
    endswitch

    if mode eq 1 or mode eq 2 or mode eq 3 then begin
        ; true left break point between jl and jl-1 at fpeak1
        if jl le 0 then begin
            vl = finiteVel[0]
        endif else begin
            bl = (fpeak1-finiteData[jl-1])/(finiteData[jl]-finiteData[jl-1])
            VL = finiteVEL[JL-1]+BL*(finiteVEL[JL]-finiteVEL[JL-1])
        endelse

       ; true right break point between jr and jr+1 at fpeak2
       if jr ge (finiteCount-1) then begin
           vr = finiteVel[finiteCount-1]
       endif else begin
           br = (fpeak2-finiteData[jr])/(finiteData[jr+1]-finiteData[jr])
           VR = finiteVEL[JR]+BR*(finiteVEL[JR+1]-finiteVEL[JR])
       endelse

       W = abs(VR-VL)
       V = (VR+VL)/2.0
       verr=0
       werr=0
    endif

    ; compute area accurately, i.e. using the
    ; fact that the channels may not be evenly 
    ; spaced in velocity

    SDV = 0.0
    for I=jj1,jj2 do begin
        if i eq 0 then begin
            delv = abs(finiteVel[i+1]-finiteVel[i])
        endif else begin
            if i eq (finiteCount-1) then begin
                delv = abs(finiteVel[i]-finiteVel[i-1])
            endif else begin
                delv = abs(finiteVel[i+1]-finiteVel[i-1])/2.0
            endelse
        endelse
        SDV = SDV + finiteDATA[I]*delv
        SDVERR=0
        if fract eq 0.5 then begin
            sdverr = 2.*rms*sqrt(1.4*w*delv)
        endif
        if fract eq 0.2 then begin
            sdverr = 2.*rms*sqrt(1.2*w*delv)
        endif 
    endfor
    res[0]=sdv
    res[1]=w
    res[2]=v 
    res[3]=sdverr
    res[4]=werr
    res[5]=verr
    if not keyword_set(quiet) then print, 'Area, Width, Velocity (followed by errors in same order) =',res, format='(a60,6f8.2)'
    RETURN,res
END

