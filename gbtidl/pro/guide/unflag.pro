; docformat = 'rst' 

;+
; Remove all flags with the same idstring value, or id number,
; from the flag file associated with the current input spectral 
; line data file or output (keep) data file.
;
; The flag is completely removed from the flag file using this
; command. Use :idl:pro:`flag` or :idl:pro:`flagrec` to re-flag the data.
;
; If ID is an integer, then that is the first value given in the :idl:pro:`listflags`
; output.  Note that this ID reflects the state of the flags at that
; particular moment.  A particular rule's ID number will change if a
; rule appearing earlier in the flags (having a lower ID number) is
; unflagged.  ID numbers always run from 0 to one less than the total
; number of flag rules.  IDs given in a single call to unflag (i.e. as
; a vector of IDs) are valid  for that use of unflag - renumbering
; effectively does not happen until unflag returns. Note that this
; behavior of ID has a practical consequence that may not be obvious,
; see the examples.
;
; Continuum flagging is not supported.
;
; If /all is set then all flags are unflagged and ID is ignored if
; set.
;
; :Params:
;   id : in, required, type=string,long
;       The idstring to match, or a unique id integer. If this parameter
;       is of type string, all flags that match this string will be
;       removed from the flag file.  If it is an integer type, only that
;       particular id will be removed.  An array of IDs can be used here.
;       All of those IDs will be unflagged. 
; 
; :Keywords:
;   keep : in, optional, type=boolean
;       Unflag the keep (output) data source.
;   all : in, optional, type=boolean
;       Unflag all IDs (ignoring id) when set.
;
; :Examples:
; 
;   You use list flags and see that there are 5 flags, numbered from 0
;   to 4.  For this example, assume that you did not specify an idstring 
;   when the current 1, 2, and 4 rules were made using :idl:pro:`flag`
;   and so the idstring for those 3 rules is "unspecified".
;
;   Unflag all of these rules in one use of unflag.
;
;   .. code-block:: IDL
; 
;       unflag,'unspecified'
;
;   Flags are now numbered just 0 and 1.
;
;   Alternatively, starting from the same place as the previous
;   example, suppose you just want to unflag one of those "unspecified"
;   ID rules.  This example does that for ID number 2.
;
;   ..code-block:: IDL
; 
;       unflag, 2
;
;   Flags are now numbered 0 through 3 and the "unspecified" rules are
;   now 1 and 3. 
; 
;   Finally, again starting from the same starting place, suppose
;   you want to unflag IDs 2 and 4 but leave ID from the set of
;   "unspecified" rules.  There are two ways you can do this.
;
;   .. code-block:: IDL
; 
;       unflag, [2,4]
;
;   That is the easiest way.  Flags are now numbered from 0 to 2 and ID
;   1 is still "unspecified". 
;
;   This is the other way to achieve the same result.
;
;   .. code-block:: IDL
; 
;       unflag, 4
;       unflag, 2
;
;   Note here that doing it one ID at a time, you must make sure that
;   you remove the IDs in  reverse order or re-check the IDs using
;   listflags prior to each use of unflag.  That is because the IDs are
;   renumbered as a consequence of each use of unflag.  
;
;   This generates an error:
;
;   .. code-block:: IDL
; 
;       unflag, 2
;       unflag, 4
;
;   because after the first call, IDs run from 0 to 3 and ID 4 no longer
;   exists.  If there were more than 5 IDs to start with, this last call
;   would not generate any error and would also not be what you thought
;   you were doing.  
;
;   Always make sure that you use <a href="listflags.html">listflag</a> 
;   before each use of unflag and when you want to unflag several IDs,
;   use the array syntax and remove them all with a single use of unflag
;   to avoid confusion. 
;
;-
pro unflag, id, keep=keep, all=all
    compile_opt idl2

    if not keyword_set(all) then begin
        if n_elements(id) eq 0 then begin
            usage,'unflag'
            return
        endif

        type = size(id,/type)
        if type ne 7 and type ne 2 and type ne 3 then begin
            message,'parmeter must be a string or integer.',/info
            return
        endif
    endif

    if not !g.line then begin
        message,'Flagging is not available for continuum data',/info
        return
    endif

    thisio = keyword_set(keep) ? !g.lineoutio : !g.lineio
    if not thisio->is_data_loaded() then begin
        if keyword_set(keep) then begin
            message, 'No keep (output) data is attached yet, use fileout.',/info
        endif else begin
            message, 'No line data is attached yet, use filein or dirin.', /info
        endelse
        return
    endif

    if keyword_set(all) then begin
        thisio->unflag,/all
    endif else begin
        ; make this work for a vector of IDs, IDs must first be sorted
        ; and unique.
        lid = id[sort(id)]
        lid = lid[uniq(lid)]
        ; unflag them in reverse order, this should work for strings and ints
        ; it's only really important for ints
        for i=(n_elements(lid)-1),0,-1 do begin
            thisio->unflag,lid[i]
        endfor
    endelse

end
