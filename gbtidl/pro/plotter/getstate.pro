;+
; Get the current x-array.  Useful so that the caller doesn't have to
; know how the plotter has stored this quantity.
;
; @keyword count {out}{optional}{type=integer} The number of values.  If
; there is nothing in the plotter, this will be 0 and the returned
; value will be -1.
; @returns the current array of x-axis values.
;
; @file_comments This is a collection of routines that return
; information found in the gbtplot_common common block.  They exist so
; that users don't need to include that common block in their code and
; so that they don't need to know specifically where that information
; is in the common block.  Developers of the plotter can then feel
; free to move that information around so long as these functions
; still return it correctly.
;
; @version $Id$
;-
function getxarray, count=count
    common gbtplot_common,mystate,xarray
    count = data_valid(*mystate.dc_ptr)
    if count lt 0 then count = 0
    if count le 0 then return, -1
    return, xarray
end

;+
; Get the current x-axis units.  Useful so that the caller doesn't have to
; know how the plotter has stored this quantity.
;
; @returns the current units of the x-axis.
;-
function getxunits
    common gbtplot_common,mystate,xarray
    return, mystate.xunit
end

;+
; Get the current x-axis velocity definition.  Useful so that the
; caller doesn't have to know how the plotter has stored this quantity.
;
; @returns the current x-axis velocity definition (RADIO, OPTICAL, or TRUE).
;-
function getxveldef
    common gbtplot_common,mystate,xarray
    return, mystate.veldef
end

;+
; Get the current x-axis velocity offset.  Useful so that the caller
; doesn't have to know how the plotter has stored this quantity.  The
; x-axis velocity offset is a true frame shift, not a simple linear offset.
;
; @returns the current x-axis velocity offset in m/s, using the TRUE
; velocity definition.
;-
function getxvoffset
    common gbtplot_common,mystate,xarray
    return, mystate.voffset
end

;+
; Get the current x-axis offset.  Useful so that the caller doesn't have to
; know how the plotter has stored this quantity.  The x-axis offset is
; a simple offset so that the real, physical x-axis value is xarray + xoffset.
;
; @returns the current x-axis offset in the current plotter x-axis units.
; velocity definition.
;-
function getxoffset
    common gbtplot_common,mystate,xarray
    return, mystate.xoffset
end

;+
; Get the current x-axis reference frame.  Useful so that the caller
; doesn't have to know how the plotter has stored this quantity.
;
; @returns the current x-axis reference frame (LSR, LSD, TOPO, GEO,
; HEL, BAR, GAL).
;-
function getxframe
    common gbtplot_common,mystate,xarray
    return, mystate.frame
end

;+
; Get the current array of y values.  Useful so that the caller
; doesn't have to know how the plotter has stored this quantity.
;
; @keyword count {out}{optional}{type=integer} The number of values.  If
; there is nothing in the plotter, this will be 0 and the returned
; value will be -1.
; @returns the current array of y values.
;-
function getyarray,count=count
    common gbtplot_common,mystate,xarray
    count = data_valid(*mystate.dc_ptr)
    if count lt 0 then count = 0
    if count le 0 then return, -1
    return, *((*mystate.dc_ptr).data_ptr)
end

;+
; Get the current data container.  If copy is true, make this a true
; copy.  
;
; <p>If you do not request a true copy then you should not free
; this data container or change the data values since that will
; confuse the plotter.  If a true copy is returned, you are
; responsible for calling data_free to free up its pointer when no
; longer needed.  
;
; <p>Useful so that the caller doesn't have to
; know how the plotter has stored this quantity.
;
; @keyword copy {in}{optional}{type=boolean} When set, return a true
; copy, which must be freed using free_data when you are finished with
; it.  If not set, do not free.
;
; @returns the current data container.
;-
function getplotterdc,copy=copy
    common gbtplot_common,mystate,xarray

    if not keyword_set(copy) then return, *mystate.dc_ptr
    
    data_copy, *mystate.dc_ptr, acopy
    return, acopy
end

;+
; Get the current x-range
;
; @keyword empty {out}{optional}{type=boolean} Set to 1 (true) if the
; plotter is empty.
; @returns the current x-range
;-
function getxrange, empty=empty
    common gbtplot_common,mystate,xarray

    empty = data_valid(*mystate.dc_ptr) le 0
    
    return, mystate.xrange
end

;+
; Get the current y-range
;
; @keyword empty {out}{optional}{type=boolean} Set to 1 (true) if the
; plotter is empty.
; @returns the current y-range
;-
function getyrange, empty=empty
    common gbtplot_common,mystate,xarray

    empty = data_valid(*mystate.dc_ptr) le 0
    
    return, mystate.yrange
end
