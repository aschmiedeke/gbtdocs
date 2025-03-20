; docformat = 'rst'

;+
; Procedure to display some simple statistics.
;
; Statistics are done on the contents of buffer 0.  One
; can specify the range over which statistics will be computed in
; any of several ways.  To specify a begin and end x-value in the
; currently displayed x-axis units, use the parameters brange and erange.
; If no x-axis range is given, the user is prompted to specify the 
; region of interest using the mouse.
;
; If there is no plot displayed, then brange and erange are assumed to be 
; in units of channel number.  If either is not supplied and
; there is no plot displayed then the full range is used.
;
; Use /chan if brange and range are in channels instead of the
; currently displayed x-axis units.
;
; :Params:
;   brange : in, optional, type=float
;       Starting value in x-axis units
;   erange : in, optional, type=float
;       Ending value in x-axis units
; 
; :Keywords:
;   full : in, optional, type=boolean
;       Compute stats for full spectrum?
;   chan : in, optional, type=boolean
;       Range specified in channels?
;   quiet : in, optional, type=boolean
;       Suppress the printing of the moments.
;   ret : out, optional, type=structure
;       Structure containing results
; 
; :Examples:
; 
;   .. code-block:: IDL
;       getrec,1
;       show               ; Use the plotter to set the X-axis to channels
;       stats,0,99         ; Gets stats for first 100 channels
;       show               ; Use the plotter to set the X-axis to GHz
;       stats,1.420,1.421  ; Gets stats
;       stats              ; User clicks plot to determine stats region
;       stats,ret=mystats  ; Return stats in a structure
;
;-
pro stats,brange,erange,full=full,chan=chan,ret=ret,quiet=quiet

    compile_opt idl2

    if not !g.line then begin
        message,'Statistics not yet supported for continuum mode.',/info
        return
    endif

    nels = data_valid(!g.s[0])
    if nels le 0 then begin
        message,'No data in primary data container',/info
        return
    endif
    chanRange = getstatsrange('stats', nels, brange, erange, full=full,chan=chan)
    if n_elements(chanRange) eq 1 then begin
        message,'range is out of bounds for this data',/info
        return
    endif
    bchan = chanRange[0]
    echan = chanRange[1]
    if bchan eq echan then begin
        print,'Stats are not supported for a single channel.'
        print,'Data value at index ',bchan,' = ',(*!g.s[0].data_ptr)[bchan]
        return
    end

    data = (*!g.s[0].data_ptr)[bchan:echan]
    
    mom = moment(data,mdev=mad,/nan)
    len = n_elements(data)
    hasXaxis = not (n_elements(getxarray()) eq 1 and (getxarray())[0] eq -1)
    if hasXaxis then begin
        chansize = abs(chantox(bchan)-chantox(bchan+1))
        xmin = chantox(bchan)
        xmax = chantox(echan)
    endif else begin
        chansize = 1
        xmin = bchan
        xmax = echan
    endelse
    if xmin gt xmax then begin
        tmp = xmin & xmin = xmax & xmax = tmp
    end
    area = total(data,/nan)*chansize
    mindata = min(data,max=maxdata,/nan)
    indx = where(finite(data))
    nokchans = (indx[0] ge 0) ? n_elements(indx): 0
    if not keyword_set(quiet) then begin
        print,'    Chans    bchan    echan        Xmin        Xmax        Ymin        Ymax'
        print,nokchans,bchan,echan,xmin,xmax,mindata,maxdata, $
              format='(1x,I8,1x,I8,1x,I8,1x,G11.5,1x,G11.5,1x,G11.5,1x,G11.5)'
        print
        print,'                       Mean      Median         RMS    Variance        Area'   
        print,mom[0],median(data),stddev(data,/nan),mom[1],area, $
              format='(16x,G11.5,1x,G11.5,1x,G11.5,1x,G11.5,1x,G11.5)'
    endif

    ret = {bchan:bchan,echan:echan,nchan:nokchans, $
           xmin:xmin,xmax:xmax,min:mindata, $
           max:maxdata,mean:mom[0],median:median(data),rms:stddev(data,/nan), $
           variance:mom[1],area:area}
end
