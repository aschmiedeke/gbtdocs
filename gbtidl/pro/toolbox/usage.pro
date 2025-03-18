;+
; Print out the usage for a given procedure or function.
;
; <p>
; If the procedure or function is found in the gbtidl pro tree then 
; <a href="get_usage.html">get_usage</a> is used to produce the
; output, otherwise the argument is passed to doc_library.
;
; <p>
; GBTIDL uses idldoc to create our reference manual.  The format used
; there does not lead to very useful output from doc_library (which
; simply shows the comment block in the file).  get_usage knows what
; idldoc tags to look for and it formats things accordingly.  It can
; also generate just a single "Usage:" line to remind the user what
; the syntax of a particular procedure or function is.
;
; @param proname {in}{required}{type=string} 
; The name of the procedure or function.  
; @keyword verbose {in}{optional}{type=boolean}{default=0} When set,
; a verbose usage is printed.
; @keyword source {in}{optional}{type=boolean}{default=0} When set, the
; entire contents of the relevent .pro file is sent to the terminal
; through "more".  This keyword trumps verbose and no usage
; information is printed.
;
; @uses <a href="get_usage.html">get_usage</a>
; @uses <a href="which_routine.html">which_routine</a>
;
; @version $Id$
;-
pro usage, proname, verbose=verbose, source=source
    compile_opt idl2

    if n_elements(proname) eq 0 then begin
        usage,'usage',verbose=verbose
        return
    endif

    gbtidl_root = getenv('GBT_IDL_DIR')

    if strlen(gbtidl_root) eq 0 then begin
        message,'Not in GBTIDL, can not continue',/info
        return
    endif

    routine = which_routine(proname,unresolved=unresolved)

    if strlen(routine[0]) eq 0 then begin
        if n_elements(unresolved) eq 1 then begin
            if strlen(unresolved) eq 0 then begin
                message,proname + ' not found',/info
                return
            endif else begin
                routine = unresolved[0]
            endelse
        endif else begin
            message,'More than one match found, using the first one',/info
            routine = unresolved[0]
        endelse
    endif

    ntodo = n_elements(routine)
    for i=0,(ntodo-1) do begin

        if ntodo gt 1 then begin
            if i gt 0 then begin
                read,format="(a)",prompt='Hit Enter to see usage for next routine ...'
            endif
            print,'Usage for ',routine[i]
        endif
        if keyword_set(source) then begin
            ; source trumps everything
            cmd = 'more ' + routine[i]
            spawn,cmd
        endif else begin

            gbtidl_pro = gbtidl_root + "/pro"

            gbtidl_contrib = gbtidl_root + "/contrib"
            
            if strpos(routine[i],gbtidl_pro) eq 0 or $
              strpos(routine[i],gbtidl_contrib) eq 0 then begin
              ; its in the GBTIDL pro tree

                itsUsage = get_usage(routine[i],method=proname,verbose=verbose)
                if not keyword_set(verbose) then begin
                    print
                    print, itsUsage
                    print
                endif else begin
                    defsysv,'!g',exists=hasg
                    usemore = hasg ? !g.interactive : hastty()
                    if usemore then begin
                        openw, out, '/dev/tty', /get_lun, /more
                    endif else begin
                        out = -1
                    endelse
                    printf,out
                    printf,out,itsUsage[0]
                    for j=1,(n_elements(itsUsage)-1) do begin
;                       print,'here is ',j
                        printf, out, itsUsage[j]
                    end
                    printf,out
                    printf,out,'Source code: ', routine[i]
                    printf,out
                    if out ne -1 then free_lun, out
                endelse
            endif else begin
                ; necessary so that resolve_all doesn't do doc_library
                ; which will lead to an unresolved thing : trnlog
                ok=execute(string("'",proname,"'",format='("doc_library,",a1,a,a1)'))
            endelse
        endelse
    endfor
end
