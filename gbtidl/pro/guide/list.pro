;+
; Lists columns from the index of the input file (or
; optionally the keep file) for the indicated range of rows.
; Selection can also be done in the same call so that only those rows
; that match the selection criteria will be listed.
; <p>
; The default columns that are listed are: INDEX, SOURCE, SCAN,
; PROCEDURE, POLARIZATION, IFNUM, FDNUM, INT, SIG, and CAL. Users can
; list other columns by specifying the columns argument.  Users can
; alternatively set the list of columns to be show in
; !g.user_list_cols and then use the /user flag here.
; <p>
; columns can be specified as either an array of strings or as a comma
; separated list.  The value of !g.user_list_cols is always a comma
; separated list.
; <p> 
; For a complete list of available column names, use <a href="listcols.html">listcols</a>.
; <p>
; Additional selection on the index can be done to limit the index
; rows that are listed.  The syntax is the same as in select.
; The "Select" section in the <a href="http://wwwlocal.gb.nrao.edu/GBT/DA/gbtidl/users_guide/node50.html" TARGET="_top">User's Guide</a> gives examples of the 
; types of selections possible with list.
; <p>
; The rows are usually listed in order of increasing index number
; (even if index is not listed).  This can be overridden by specifying
; another column name to sort on through the sortcol keyword (passed
; in through the _EXTRA keyword).
; <p>
; Use the FILE keyword to send the listing to a file instead of to the
; current screen.
;
; @param start {in}{optional}{type=long}{default=0} If set, the beginning of range to list
; @param finish {in}{optional}{type=long}{default=last index} If set, the end of range to list
;
; @keyword keep {in}{optional}{type=boolean} If set, the list comes from
; the keep file and !g.line is irrelevant.
;
; @keyword columns {in}{optional}{type=string} If present, only list the
; values from these columns instead of the default columns.  Can be
; either a comma-separated list in a single string or an array of
; strings.  columns trumps the user flag, if set.
;
; @keyword user {in}{optional}{type=boolean} If set and columns is not
; used, then the columns to list come from the !g.user_list_cols
; value.  If that value is empty then this the default list is used.
; !g.user_list_cols is a comma-separated list of column names.
; 
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;
; @keyword _EXTRA {in}{optional}{type=keywords} In addition to the
; selection keywords the <b>sortcol</b> keyword is also available here.  Set
; that equal to a column name and the list order will be sorted in
; increasing values of that column.
;
; @examples
; <pre>
;    ; list first 11 records in the input file
;    list,0,10
;
;    ; list source and polarization for first 11 entries
;    list,0,10,columns=['source','polarization']
;
;    ; Set the user preferences to index, source, longitude, latitude
;    !g.user_list_cols = "source,longitude,latitude"
;    ; and list using the user preferences
;    list,0,10,/user
;
;    ; this illustrates additional selection
;    ; list index, source and tsys for all data in ifnum=1
;    list,ifnum=1,columns='index,source,polarization'
;
;    ; list, sorting by increasing integration number
;    list,sortcol='int'
;
;    ; Send the previous list to a file named mylisting
;    list,sortcol='int',file='mylisting'
; </pre>
;
; @version $Id$
;-
pro list, start, finish, keep=keep, columns=columns, user=user, $
          file=file, _EXTRA=ex
    compile_opt idl2
    
    on_error,2

    if n_elements(start) eq 0 then start = 0
    if start lt 0 then start = 0
    useColumns = 0
    if n_elements(columns) gt 0 then begin
        ; columns takes precedence over user
        theseColumns = columns
        useColumns = 1
    endif else begin
        if keyword_set(user) and (strlen(!g.user_list_cols) gt 0) then begin
            theseColumns = !g.user_list_cols
            useColumns = 1
        endif
    endelse

    if n_elements(theseColumns) eq 1 then begin
        ; it might be a comma separated list
        useColumns = 0
        theseColumns = strsplit(theseColumns,',',/extract)
        count=0
        for i=0,(n_elements(theseColumns)-1) do begin
            thisCol = strtrim(theseColumns[i],2)
            if strlen(thisCol) gt 0 then begin
                theseColumns[count] = thisCol
                count += 1
            endif
        endfor
        if count gt 0 then begin
            useColumns = 1
            theseColumns = theseColumns[0:(count-1)]
        endif
    endif

    if (keyword_set(keep)) then begin
        if !g.lineoutio->is_data_loaded() eq 0 then begin
            message,'No keep file has been set or the keep file is empty',/info
            return
        endif
        nmax = n_elements(!g.lineoutio->get_index())
        if (n_elements(finish) eq 0) then finish = nmax
        endat = finish ge nmax ? (nmax-1) : finish
        if useColumns then begin
            !g.lineoutio->list,start,endat,columns=theseColumns,file=file,_EXTRA=ex
        endif else begin
            !g.lineoutio->list,start,endat,file=file,_EXTRA=ex
        endelse
    endif else begin
        if (!g.line) then begin
            if !g.lineio->is_data_loaded() eq 0 then begin
                message,'No line input file has been set or the file is empty',/info
                return
            endif
            nmax = n_elements(!g.lineio->get_index())
            if (n_elements(finish) eq 0) then finish = nmax
            endat = finish ge nmax ? (nmax-1) : finish
            if useColumns then begin
                !g.lineio->list,start,endat,columns=theseColumns,file=file,_EXTRA=ex 
            endif else begin
                !g.lineio->list,start,endat,file=file,_EXTRA=ex
            endelse
        endif else begin
            if !g.contio->is_data_loaded() eq 0 then begin
                message,'No continuum input file has been set or the file is empty',/info
                return
            endif
            nmax = n_elements(!g.contio->get_index())
            if (n_elements(finish) eq 0) then finish = nmax
            endat = finish ge nmax ? (nmax-1) : finish
            if useColumns then begin
                !g.contio->list,start,endat,columns=theseColumns,file=file,_EXTRA=ex
            endif else begin
                !g.contio->list,start,endat,file=file,_EXTRA=ex
            endelse
        endelse
    endelse
return 
end

