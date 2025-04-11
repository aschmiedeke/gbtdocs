; docformat = 'rst'

;+
; Clear any over plots.  This removes them from the plotters state and
; does a reshow. 
;
; Under normal use, this will not clear region box overlays if 
; the value of !g.regionboxes is true (1).  That behavior can be
; overridden by specifying the idstring of the region boxes (see
; showregion), but that is intended for internal use only and is not
; recommended for general users.  Instead, use showregion,/off or
; set !g.regionboxes to false (0) before calling clearoplots.
; 
; :Keywords:
;   index : in, optional, type=integer
;       The index numbers to clear.  This is the index number set by 
;       gbtoplot.  Note that once an index has been cleared, subsequent
;       index numbers are renumbered appropriately so that index numbers
;       are always 0:(n_indexes-1).
;
;   idstring : in, optional, type=string
;       A string that can be used to identify which oplots should be 
;       cleared.  This is a string that is set by the user when gbtoplot
;       was called.  Withing GBTIDL, all internal id strings begin with
;       two underscores so that they are less likely to conflict with
;       user-defined idstrings. When not specified (the default) no 
;       checks on idstring are done prior to clearing it from the list.
;
;-
pro clearoplots, index=index, idstring=idstring
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    clearoplotslist, index=index, idstring=idstring, count=count
    if count gt 0 then begin
        if n_elements(idstring) eq 0 then begin
            ; reshow any rms boxes if appropriate
            if !g.regionboxes and mystate.showRegions then showregion
        endif
        reshow
    endif
end
