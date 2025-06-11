; docformat = 'rst'

;+
; Get the current x-array.  Useful so that the caller doesn't have to
; know how the plotter has stored this quantity.
;
; :Keywords:
;   count : out, optional, type=integer
;       The number of values. If there is nothing in the plotter, this
;       will be 0 and the returned value will be -1.
; 
; :Returns:
;   the current array of x-axis values.
;
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;
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
; :Returns:
;   the current units of the x-axis.
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;-
function getxunits
    common gbtplot_common,mystate,xarray
    return, mystate.xunit
end

;+
; Get the current x-axis velocity definition.  Useful so that the
; caller doesn't have to know how the plotter has stored this quantity.
;
; :Returns:
;   the current x-axis velocity definition (RADIO, OPTICAL, or TRUE).
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;-
function getxveldef
    common gbtplot_common,mystate,xarray
    return, mystate.veldef
end

;+
; Get the current x-axis velocity offset.  Useful so that the caller
; doesn't have to know how the plotter has stored this quantity. The
; x-axis velocity offset is a true frame shift, not a simple linear offset.
;
; :Returns:
;   the current x-axis velocity offset in m/s, using the TRUE velocity definition.
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
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
; :Returns:
;   the current x-axis offset in the current plotter x-axis units. 
;   velocity definition.
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;-
function getxoffset
    common gbtplot_common,mystate,xarray
    return, mystate.xoffset
end

;+
; Get the current x-axis reference frame.  Useful so that the caller
; doesn't have to know how the plotter has stored this quantity.
;
; :Returns:
;   the current x-axis reference frame (LSR, LSD, TOPO, GEO, HEL, BAR, GAL).
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;-
function getxframe
    common gbtplot_common,mystate,xarray
    return, mystate.frame
end

;+
; Get the current array of y values.  Useful so that the caller
; doesn't have to know how the plotter has stored this quantity.
;
; :Keywords:
;   count : out, optional, type=integer
;       The number of values.  If there is nothing in the plotter, this will
;       be 0 and the returned  value will be -1.
; 
; :Returns:
;   the current array of y values.
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
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
; If you do not request a true copy then you should not free
; this data container or change the data values since that will
; confuse the plotter.  If a true copy is returned, you are
; responsible for calling data_free to free up its pointer when no
; longer needed.  
;
; Useful so that the caller doesn't have to
; know how the plotter has stored this quantity.
;
; :Keywords:
;   copy : in, optional, type=boolean
;       When set, return a true copy, which must be freed using free_data
;       when you are finished with it. If not set, do not free.
;
; :Returns:
;   the current data container.
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
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
; :Keyword:
;   empty : out, optional, type=boolean
;       Set to 1 (true) if the plotter is empty.
; 
; :Returns:
;   the current x-range
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;-
function getxrange, empty=empty
    common gbtplot_common,mystate,xarray

    empty = data_valid(*mystate.dc_ptr) le 0
    
    return, mystate.xrange
end

;+
; Get the current y-range
;
; :Keywords:
;   empty : out, optional, type=boolean
;       Set to 1 (true) if the plotter is empty.
; 
; :Returns:
;   the current y-range
; 
; :Note:
;   This is part of a collection of routines that return information found
;   in the gbtplot_common common block. It exists so that users don't need
;   to include that common block in their code and so that they don't need 
;   to know specifically where that information is in the common block. 
;   Developers of the plotter can then feel free to move that information
;   around so long as these functions still return it correctly.
;-
function getyrange, empty=empty
    common gbtplot_common,mystate,xarray

    empty = data_valid(*mystate.dc_ptr) le 0
    
    return, mystate.yrange
end
