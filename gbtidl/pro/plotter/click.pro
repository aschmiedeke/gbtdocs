;+
; Get cursor position when the user presses a mouse button.  Positions
; are translated to include channels, frequency, and velocity in the
; requested reference frame and velocity definition.
;
; The return value is a named structure (<B>cvfstruct</B>) containing the
; following fields:
; <UL>
; <LI> <B>x</B>       The x value in the data coordinates.
; <LI> <B>y</B>       The y value in the data coordinates.
; <LI> <B>xdevice</B> The x value in device coordinates.
; <LI> <B>ydevice</B> The y value in device coordinates.
; <LI> <B>button</B>  The button pressed (1=left,2=middle,4=right).
; <LI> <B>chan</B>    The channel number corresponding to <B>x</B>.
;          <B>frame</B> with the <B>voffset</B>.
; <LI> <B>velo</B>    The velocity (m/s) corresponding to <B>x</B> in 
;          <B>frame</B> using <B>veldef</B> and <B>voffset</B>.
; <LI> <B>frame</B>   The supplied frame argument, defaults to the current
;          frame in the plotter.
; <LI> <B>veldef</B>  The veldef argument (velocity definition),
;          defaults to the current velocity definition in the plotter.
; <LI> <B>voffset</B> The velocity offset (in <B>frame</B> and <B>veldef</B>) 
;          as found in the plotter.
; <LI> <B>ok</B>      If everything went fine, this is 1, otherwise it's 0.
; </UL>
;
; @keyword frame {in}{optional}{type=string} The desired reference
; frame for the velocity and frequency values.  The list of possible
; choices can be found in the documentation for <a
; href="../toolbox/frame_velocity.html">frame_velocity</a>.  This
; defaults to the frame currently in use in the plotter.
;
; @keyword veldef {in}{optional}{type=string} The velocity definition
; to use in converting the cursor x position.  This must be one of
; OPTICAL, RADIO or TRUE.  This defaults to the veldef currently in
; use in the plotter.
;
; @keyword nocrosshair {in}{optional}{type=boolean} When set, this
; function will ensure that the plotter's crosshair is on until the
; click is received.  At that point, the plotter's crosshair will be
; returned to its state before click was invoked.  If not set, the
; plotters crosshair state will not be changed.
;
; @keyword noshow {in}{optional}{type=boolean} If set, then the plotter
; will not be brought to the foreground (shown).
;
; @keyword label {in}{optional}{type=string} A label to use in the
; "Left Click:" field of the plotter.  Defaults to "Click a Mouse
; Button".
;
; @returns cfvstruct structure as described above.
;
; @examples
; <pre>
; print,click()
; ; or
; c = click()
; v = c.velo ; velocity at frame and velocity definition in header
; </pre>
;
; @uses <a href="../toolbox/chantofreq.html">chantofreq</a>
; @uses <a href="../toolbox/chantovel.html">chantovel</a>
; @uses <a href="../toolbox/freqtochan.html">freqtochan</a>
; @uses <a href="../../devel/plotter/gbtcursor.html">gbtcursor</a>
;
; @version $Id$
;-
function click, frame=frame, veldef=veldef, nocrosshair=nocrosshair, $
                noshow=noshow, label=label
    compile_opt idl2

    common gbtplot_common, mystate, xarray

    cvf = {cvfstruct, x:0D, y:0D, xdevice:0D, ydevice:0D, button:0, chan:0D, freq:0D, velo:0D, $
           fsky:0D, frame:'TOPO', veldef:'OPTICAL', voffset:0D, ok:0}

                                ; is there anything in the plotter, apparently.
    if (n_elements(xarray) eq 0) then begin
        message, 'There is nothing in the plotter',/info
        return, cvf
    endif

    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return, cvf
    endif

    if (n_elements(frame) eq 0) then frame = mystate.frame
    if (n_elements(veldef) eq 0) then veldef = mystate.veldef

    a = gbtcursor(nocrosshair=nocrosshair, noshow=noshow, label=label)
    cvf.xdevice = a.x
    cvf.ydevice = a.y
    oldwin = !d.window
    wset, mystate.win_id
    data_coord = convert_coord(a.x,a.y,/to_data,/device)
    wset,oldwin
    
    cvf.x = data_coord[0]
    cvf.y = data_coord[1]
    cvf.button = a.press
    cvf.ok = 1
    
    catch, error_status
    if (error_status ne 0) then begin
        cvf.ok = 0
        return, cvf
    endif

    ; get the channel number from the x value
    cvf.chan = xtochan(cvf.x)

    if mystate.line then begin
        cvf.freq = chantofreq(*mystate.dc_ptr, cvf.chan, frame=frame)

        if (frame ne 'TOPO') then begin
            cvf.fsky = chantofreq(*mystate.dc_ptr, cvf.chan, frame='TOPO')
        endif else begin
            cvf.fsky = cvf.freq
        endelse
        
        cvf.freq = shiftfreq(cvf.freq, mystate.voffset, veldef='TRUE')
        cvf.velo = freqtovel(cvf.freq, (*mystate.dc_ptr).line_rest_frequency, veldef=veldef)

        cvf.frame = frame
        cvf.veldef = veldef
        cvf.voffset = veltovel(mystate.voffset, cvf.veldef, 'TRUE')
    endif else begin
        cvf.freq = (*mystate.dc_ptr).observed_frequency
        cvf.fsky = cvf.freq
        cvf.velo = 0.0
        cvf.frame = 'TOPO'
        cvf.veldef = ''
        cvf.voffset = 0.0
    endelse
  
    return, cvf
end
