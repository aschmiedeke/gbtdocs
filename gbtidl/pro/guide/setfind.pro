; docformat = 'rst'

;+
; Set a selection parameter to be used later by :idl:pro:`find`.
;
; This sets one of the fields in the structure used by FIND.  There
; is one field for each of the possible selection parameters (use
; :idl:pro:`listcols` to see a list of the available search parameters).  
; A single value can be entered as can a range of values.  Or, a
; single string can be used here in which case that string is saved as
; is to be used by SELECT inside of FIND.  See the discussion on
; "Find" in the `GBTIDL manual <https://www.gb.nrao.edu/GBT/DA/gbtidl/users_guide.pdf#page=30>`_
; for selection syntax examples. This
; routine can be used to either replace the current selection
; parameter value with another (the default behavior) or it can be
; used to append more information to the current selection parameter
; value.
;
; See :idl:pro:`listfind` to show the current value of any of the possible 
; selection parameters used by FIND.
;
; :idl:pro:`clearfind` can be used to unset selection parameters used by FIND.
;
; :Params:
;   param : in, optional, type=string
;       The selection parameter to set. If this parameter is omitted, the user
;       is asked to choose from the list of available parameters and all other
;       parameters (val1 and val2) are ignored.  Min-match is used to find the
;       parameter to set.  If more than one parameter matches, a warning is 
;       printed and the procedure ends without setting any values. Case is not
;       important.
;   val1 : in, optional, type=appropriate to param
;       The value that param is set to. Any valid selection syntax (strings,
;       integers or floating point values) is allowed here.  If val2 is also
;       used, then these two values define  a range and that range is the value
;       that the selection parameter is set to.  In that case, val1 and val2 must
;       not be strings since string selection parameters (e.g. source) do not 
;       allow ranges.  If val1 is a string then val2 is ignored if supplied
;       and val1 is used "as is" for the selection parameter. There is no syntax
;       checking of string values at this step so an impromperly formed selection
;       string may generate an error later when FIND is used. If not supplied,
;       the user is asked for a value.
;   val2 : in, optional, type=floating or integer
;       This is used with val1 to define a selection range.  If not supplied, 
;       only val1 is used and the user is not prompted for val2.
;
; :Keywords:
;   append : in, optional, type=boolean
;       When set, the selection parameter value is appended to the existing 
;       parameter value for this parameter. Otherwise, the existing value is
;       replaced with the new value.
;
; :Examples:
;   See also :idl:pro:`find`
;
;   .. code-block:: IDL
; 
;       setfind                         ; a list of parameters is shown, you type one
;                                       ;  then you are asked for a value, no quotes necessary
;       setfind,'scan'                  ; you are asked for one value, the SCAN
;                                       ; selection criteria is set to that value
;       setfind,'samp','A1'             ; sets SAMPLER (min-match) to 'A1'
;       setfind,'int',1,3               ; integrations 1 through 3
;       setfind,'int',4,/append         ; oops, forgot about 4
;       setfind,'int','1:3,4'           ; equivalent to the previous 2
;       setfind,'restfreq',1420.4e9     ; single precision floating point
;       setfind,'restfreq',1420.4058d9  ; double precision
;
;   Note that nothing happens until you use :idl:pro:`find`.
;
;-
pro setfind, param, val1, val2, append=append
    compile_opt idl2
    npars = n_params()
    if n_params() eq 0 then begin
        print,'Chose a parameter from this list ...'
        print,tag_names(!g.find)
        itsparam = ''
        read, itsparam, prompt='Parameter ? '
        ; ignore all other parameters
        npars = 1
    endif else begin
        itsparam = param
    endelse
    if strlen(itsparam) eq 0 then begin
        print,'No param specified, nothing set'
        return
    endif
    index = getfindindex(itsparam,mode=mode,count=count)
    if count eq 0 then begin
        print,itsparam + ' is not a valid selection parameter'
        return
    endif
    if count gt 1 then begin
        print,itsparam + ' matches more than one selection parameter, nothing set'
        print,(tag_names(!g.find))[index]
        return
    endif
    if npars eq 1 then begin
        print,'Enter a value or a selection string, no quotes are necessary'
        itsval = ''
        read,itsval,prompt='Parameter value ? '
    endif else begin
        if size(val1,/type) eq 7 then begin
            ; string value, ignore any val2
            npars = 2
        endif
        itsval = strtrim(string(val1),2)
    endelse
    if npars eq 3 then begin
        if size(val2,/type) eq 7 then begin
            message,'val2 can not be a string type - ranges not allowed for string values',/info
            return
        endif
        itsval = itsval + ":" + strtrim(string(val2),2)
    endif
    fullParamName = (tag_names(!g.find))[index]
    if strlen(itsval) eq 0 then begin
        print,'empty value, no changes made to ',fullParamName
        return
    endif 
    if not !g.lineio->check_search_param_syntax(_EXTRA=create_struct(fullParamName,itsval)) then begin
        print,'No changes made to ',fullParamName
        return
    endif
    if keyword_set(append) then begin
        newValue = itsval
        if strlen(!g.find.(index)) ne 0  then begin
            newValue = !g.find.(index) + ',' + newValue
        endif
        if not !g.lineio->check_search_param_syntax(_EXTRA=create_struct(fullParamName,newValue)) then begin
            print,'Problems appending value, no changes made to ',fullParamName
        endif
        !g.find.(index) = newValue
    endif else begin
        !g.find.(index) = itsval
    endelse
end
