; docformat = 'rst'

;+
; Put entries in to the stack based on the given selection criteria in
; the global find structure.  This is an alternative to :idl:pro:`select`.
;
; Use :idl:pro:`setfind` to set specific selection criteria.  Once set, they 
; remain set until cleared using :idl:pro:`clearfind`.  FIND uses those selection 
; criteria and :idl:pro:`select` to add entries to the stack corresponding to items 
; in the data source that match the selection criteria.  The stack can
; then be iterated through to process just the most recently found
; data.
;
; *Note:* unlike :idl:pro:`select`, find clears the stack unless the /append 
; keyword is used.  This has been done to make the behavior of FIND
; more like the CLASS version of FIND. 
;
; :Keywords:
;   append : in, optional, type=boolean
;       When set, the stack is **not** first cleared before select is used
;       to add values to the stack.  Use this with some caution since this
;       may cause the same entries to appear more than once in the stack 
;       unless the selection criteria used by FIND are changed carefully.
;   keep : in, optional, type=boolean
;       Select entries from the currently attached output (keep) file.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; define the selection
;       setfind,'scan',100,200          ; scans 100 through 200
;       find
;       ; refine it
;       setfind,'polarization','LL'     ; only the LL polarization
;       find
;       ; refine it
;       setfind,'int','2:3'             ; only integrations 2 and 3
;       find
;       ; refine it
;       setfind,'int',4,/append         ; add integration 4 to the set
;       find
;       ; this is equivalent to the previous 2 setfind examples.
;       ; note that any valid selection string can be used
;       setfind,'int','2:3,4'
;       setfind,'polarization','RR'     ; the other polarization
;       find,/append                    ; the LL selection is still there due to /append
;       clearfind,'int'                 ; clear the integration parameter
;       find                            ; all integrations, RR polarization, scans 100 to 200.
;
;   If you often set the same parameter, you can write a procedure, as in
;   this example, to save yourself time.  You might add optional feedback
;   to the user that the parameter was set and you might add additional
;   parameter checks.
;
;   .. code-block:: IDL
; 
;       pro setsrc,src
;           setfind,'source',src
;       end
;
; :Uses:
;   :idl:pro:`emptystack`
;   :idl:pro:`select`
;
;-
pro find, keep=keep, append=append
    compile_opt idl2

    if not keyword_set(append) then emptystack

    ; construct the appropriate selection record
    count = 0
    fnames = tag_names(!g.find)
    ; through nsave common to both line and cont
    nsave = where(fnames eq 'NSAVE')
    nsave = nsave[0]
    for i=0,nsave do begin
        if strlen(!g.find.(i)) gt 0 then begin
            if count eq 0 then begin
                selStruct = create_struct(fnames[i],!g.find.(i))
            endif else begin
                selStruct = create_struct(selStruct, fnames[i],!g.find.(i))
            endelse
            count += 1
        endif
    end
    ; last 3 items are unique to cont
    if !g.line then begin
        ; on
        for i=(nsave+1),(n_elements(fnames)-4) do begin
            if strlen(!g.find.(i)) gt 0 then begin
                if count eq 0 then begin
                    selStruct = create_struct(fnames[i],!g.find.(i))
                endif else begin
                    selStruct = create_struct(selStruct, fnames[i],!g.find.(i))
                endelse
                count += 1
            endif
        end
    endif else begin
        nt = n_elements(fnames)
        for i=(nt-3),(nt-1) do begin
            if !g.find.(i) ge 0 then begin
                if count eq 0 then begin
                    selStruct = create_struct(fnames[i],!g.find.(i))
                endif else begin
                    selStruct = create_struct(selStruct, fnames[i],!g.find.(i))
                endelse
                count += 1
            endif
        end
    endelse
    if count gt 0 then begin
        select,keep=keep,_EXTRA=selStruct
    endif else begin
        select,keep=keep
    endelse
end
