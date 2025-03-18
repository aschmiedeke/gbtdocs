;+
; Replace spectral channels by interpolation, or with zero values or
; blanks.  If neither zero or blank are set, the data between bchan
; and echan are replaced with a straight line connecting the two end
; points.  If neither bchan or echan are given the user is prompted
; select the region to be replaced on the plotter.
;
; @param bchan {in}{optional}{type=float} Starting channel.  If this is
; a floating point value it is first rounded (using the IDL round function)
; before being used.  
; @param echan {in}{optional}{type=float} Ending channel.  If this is
; a floating point value it is first rounded (using the IDL round function)
; before being used.
; @keyword zero {in}{optional}{type=boolean} If this keyword is set,
; the data are replaced with zero values.  Otherwise, the replacement
; data values are interpolated from the endpoints.
; @keyword blank {in}{optional}{type=boolean} If this keyword is set,
; the data are replaced by IEEE NaN (not a number).  Such values are
; treated as missing data (not used in operations, not shown on the
; plotter, etc).  If both blank and zero are set, zero takes
; precedence and the data will not be blanked.
;
; @examples
; <pre>
;    getrec,1
;    chan               ; set the X-axis to channels
;    replace,1023,1025  ; replace the channel range 1023-1025
;    freq               ; set the X-axis to GHz
;    replace            ; prompt user for ranges and replace the values
;    replace,15,/zero   ; set the data value at channel 15 to 0.0
;    replace,2014,/blank; set the data value at channel 2014 to NaN
; </pre>
;
; @version $Id$
;-

pro replace,bchan,echan,zero=zero,blank=blank

    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if not !g.line then begin
      print,'replace is not yet supported for Continuum mode.'
      return
    end
    if n_elements(bchan) eq 0 and n_elements(echan) eq 0 then begin
        if (data_valid(getplotterdc()) le 0) then begin
            message,'The plotter is empty',/info
            return
        endif
        done = 0
        print,'Select regions for data replacement.'
        print,''
        print,'  Left click to mark a region boundary.'
        print,'  Right click when finished.'
        print,'  Middle click to abort and replace nothing.' 
        print,''
        count = 0
        chanlist = make_array(100,/long)
        while not done do begin
            a = click()
            if a.button eq 4 then done = 1 $
            else if a.button eq 2 then begin
                print,'replace aborted.'
                show
                return
            end else begin
                gbtoplot,[a.x,a.x],mystate.yrange,color=!white
                chanlist[count] = round(a.chan)
                count += 1
            end
        endwhile
        sortlist = chanlist[sort(chanlist[0:(count-1)])]
        if (count mod 2) eq 1 then begin
            print,'Error: an odd number of endpoints was entered.  Try again.'
            show
            return
        end
        for i=0,count-1,2 do begin
            replace_chans,sortlist[i],sortlist[i+1],zero=zero,blank=blank
        endfor
    endif else if n_elements(echan) eq 0 then $
      replace_chans,bchan,bchan,zero=zero,blank=blank $
    else replace_chans,bchan,echan,zero=zero,blank=blank
    if not !g.frozen then show 
end

;+
; Used internally in replace
;
; @param bchan {in}{required}{type=integer} Beginning channel number.  Value is rounded (using IDL round function) to accomodate floating point values.
; @param echan {in}{required}{type=integer} End channel number.  Value is rounded (using IDL round function) to accomodate floating point values.
; @keyword zero {in}{optional}{type=boolean} When set, set the data to
; 0 in the channel range.
; @keyword blank {in}{optional}{type=boolean} When set, set the data to
; NaN in the channel range.  Has no effect if zero is also set.
;
; @private
;-
pro replace_chans,bchan,echan,zero=zero,blank=blank
    compile_opt idl2

    data = getdata()
    numchans = n_elements(data)
    thisEchan = round(echan)
    thisBchan = round(bchan)
    if thisBchan gt thisEchan then begin
       tmp = thisBchan & thisBchan = thisEchan & thisEchan = tmp
    endif

    if thisBchan gt (numchans-1) or thisEchan lt 0 then begin
        message,"Nothing to flag.",/info
        return
    endif
    if thisBchan lt 0 then thisBchan = 0
    if thisEchan gt (numchans-1) then thisEchan = numchans-1
    if keyword_set(zero) then begin
       data[thisBchan:thisEchan] = 0.0 
       *!g.s[0].data_ptr = data
       return
    endif
    if keyword_set(blank) then begin
	data[thisBchan:thisEchan] = !values.f_nan
        *!g.s[0].data_ptr = data
	return
    endif
    if thisBchan eq thisEchan then begin
       if thisBchan eq 0 then data[0] = data[1] $
       else if thisBchan eq numchans-1 then data[numchans-1] = data[numchans-2] $
       else data[thisBchan] = (data[thisBchan-1] + data[thisBchan+1])/2.0
       *!g.s[0].data_ptr = data
       return
    endif
    if thisBchan le 0 then begin
       thisBchan = 1
       data[0] = data[thisEchan+1]
    endif
    if thisEchan ge (numchans-1) then begin
       thisEchan = numchans-2
       data[numchans-1] = data[thisBchan-1]
    endif

    data[(thisBchan-1):(thisEchan+1)] = interpol([data[thisBchan-1],data[thisEchan+1]],thisEchan-thisBchan+3)
    *!g.s[0].data_ptr = data
end
