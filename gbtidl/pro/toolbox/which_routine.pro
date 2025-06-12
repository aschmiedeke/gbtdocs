; docformat = 'rst'

;+
; Search for any file in the IDL !path that contains the
; user-supplied IDL routine (procedure or function) name. 
;
; If the returned string has non-zero length, the routine has 
; been compiled (resolved in IDL lingo) otherwise, it has not.  
; Any unresolved files that contain this routine are also returned 
; in the unresolved keyword value.  If both the returned string and
; the resolved keyword values have zero length, then the routine could
; not be found in the !path.
;
; This is the code behind <a href="which.html">which</a>.  It was
; originally all in which but was split so that other code could make
; use of this functionality (e.g. driving a browser to the appropriate
; reference manual location, finding and summarizing the help
; information for a routine).
;
; **Restrictions:**
; The IDL !path is searched for file names that are simply the
; module (in IDL documentation, "module" and "routine" are used
; interchangeably) name with a ".pro" suffix appended to them.
; A module stored inside a file whose name is different than the
; module name (followed by a ".pro") will not be found UNLESS
; that module happens to be the currently-resolved module!
; E.g., if the module "pro test_proc" lives in a file named
; "dumb_name.pro", then it will not be found:
;
; .. code-block:: IDL
; 
;   IDL> a=which_routine('test_proc',unresolved=unresolved)
;   IDL> print, strlen(a), strlen(unresolved)
;             0           0
;
; unless it happens to be resolved:
;
; .. code-block:: IDL
; 
;   IDL> .run dumb_name
;   % Compiled module: TEST_PROC.
;   IDL> print,which_routine('test_proc')
;   /hvc/robishaw/dumb_name.pro
; 
; However, this is terrible programming style and sooner or
; later, if you hide generically-named modules in
; inappropriately-named files, bad things will (deservedly)
; happen to you.
;
; The routine further assumes that a file named "dumb_name.pro"
; actually contains a module named "dumb_name"!  If it doesn't,
; then you are a bad programmer and should seek professional
; counseling.
;
; .. note::
; 
;   First, all currently-compiled procedures and functions are searched.
;   Then the remainder of the IDL !path is searched.
;
; :Modification History:
; 
; .. list-table:: 
;    :widths: 20, 80
;    :header-rows: 0
; 
;    * - 2003, May 30
;      - Written by Tim Robishaw, Berkeley
;    * - 2004, Feb 17
;      - Fixed oddity where user tries to call a function as
;        if it were a procedure, thus listing the module in both
;        the Compiled Functions and Compiled Procedures list.
;    * - 2005, Jun 14
;      - Split code into which_routine function for use
;        elsewhere in GBTIDL and which.  Reformatted
;        comments for use with idldoc.
;
; :Params: 
;   name : in, required, type=string
;       The procedure or function name to search for.
;
; :Keywords:
;   unresolved : out, type=string
;       The paths to files that likely contain this name but are not the 
;       currently compiled version containing name.
;
; :Examples:
; 
;   You haven't yet resolved (compiled) the routine (module)
;   DEFROI.  Let's look for it anyway:
;
;   .. code-block:: IDL
; 
;       IDL> a=which_routine('defroi',unresolved=unresolved)
;       IDL> print,strlen(a)
;             0
;       IDL> print, unresolved
;       /usr/local/rsi/idl/lib/defroi.pro
;
;   For some reason you have two modules with the same name.
;   (This can occur in libraries of IDL routines such as the
;   Goddard IDL Astronomy User's Library; an updated version of a
;   routine is stored in a special directory while the old version
;   is stored in its original directory.) Let's see which version
;   of the module ADSTRING we are currently using:
;
;   .. code-block:: IDL
; 
;       IDL> a=which_routine('adstring.pro',unresolved=unresolved)
;       IDL> print,a
;       /hvc/robishaw/idl/goddard/pro/v5.4+/adstring.pro
;       IDL> print,unresolved
;       /hvc/robishaw/idl/goddard/pro/astro/adstring.pro
; 
; :Returns:
;   String containing the file name from which the resolved
;   (compiled) version of name was found.  This is a zero-length
;   string if name has not been resolved (compiled) yet.
;
;-
function which_routine, name, unresolved=unresolved
    on_error, 2
    resolve_routine, 'strsplit', /IS_FUN, /NO_RECOMPILE

    proname = name

    ; WHAT IS THE PATH SEPARATOR ON THIS OS...
    psep = path_sep()

    ; IF .PRO SUFFIX INCLUDED, DROP IT...
    proname = strtrim(proname,2)
    if strmatch(proname,'*.pro', /FOLD_CASE) $
        then proname = strmid(proname,0,strlen(proname)-4)

    ; SEARCH THE CURRENTLY-COMPILED PROCEDURES AND FUNCTIONS FIRST...
    pindx = where(which_find_routine(proname),presolved)
    findx = where(which_find_routine(proname,/FUNCTIONS),fresolved)

    ; IF PROCEDURE OR FUNCTION WAS FOUND, IS IT UNRESOLVED...
    punresolved = total(which_find_routine(proname,/UNRESOLVED))
    funresolved = total(which_find_routine(proname,/UNRESOLVED,/FUNCTIONS))

    ; WE NEED TO HANDLE BIZARRO CASES OF HAVING A FUNCTION THAT THE USER TRIES
    ; TO CALL AS A PROCEDURE, THUS TRICKING IDL INTO THINKING IT HAS ON ITS 
    ; HANDS A RESOLVED FUNCTION, A RESOLVED PROCEDURE AND AN UNRESOLVED PROCEDURE...
    if (presolved AND punresolved AND fresolved) then begin
        presolved = 0 & punresolved = 0
    endif

    ; AND WHILE WE'RE AT IT, WE TAKE CARE OF THE CONVERSE... A PROCEDURE
    ; THAT HAS BEEN CALLED AS A FUNCTION BEFORE COMPILATION...
    if (fresolved AND funresolved AND presolved) then begin
        fresolved = 0 & funresolved = 0
    endif

    result = ''
    unresolved=''

    ; THE FULL PATH TO THE RESULTING RESOLVED ROUTINE...
    if (presolved and not punresolved) OR $
        (fresolved and not funresolved) then begin

        ; THE PROCEDURE OR FUNCTION WAS FOUND...
        result = (presolved AND fresolved) ? $
                 [(routine_info(/SOURCE))[pindx].PATH, $
                  (routine_info(/SOURCE,/FUNCTIONS))[findx].PATH] : $
                 (presolved ? (routine_info(/SOURCE))[pindx].PATH : $
                  (routine_info(/SOURCE,/FUNCTIONS))[findx].PATH)

        ; result has two elements if procedure AND function found
    endif 

    ; EXTRACT THE !PATH INTO A STRING ARRAY...
    path = strsplit(!path, path_sep(/SEARCH_PATH), /EXTRACT)

    ; GET RID OF "." IF USER INCLUDES THIS IN PATH...
    path = path[where(path ne '.')]


    ; WHAT IS THE CURRENT DIRECTORY
    cd, CURRENT=current

    ; GET TARGET OF ANY SYMBOLIC LINKS IN THE IDL !PATH...
    path_syml = path
    for i = 0, N_elements(path_syml)-1 do begin
        d = path_syml[i]
        if not file_test(d,/DIRECTORY) then continue
        cd, d & cd, CURRENT=dnew
        if not strmatch(d,dnew) then path_syml[i] = dnew
    endfor

    ; REMOVE ANY DUPLICATE PATH ELEMENTS, KEEPING ON THE ONE CLOSEST TO THE
    ; TOP...
    rev_path_syml = reverse(path_syml)
    rind = reverse(lindgen(N_elements(path_syml)))
    u = uniq(rev_path_syml,sort(rev_path_syml))
    path_syml = reverse(path_syml[rind[u[sort(u)]]])
    path = reverse(path[rind[u[sort(u)]]])
    
    ; IF THE CURRENT DIRECTORY IS ANYWHERE IN THE PATH, THEN MOVE IT TO THE
    ; FRONT OF THE PATH, SINCE THE CURRENT PATH WILL BE SEARCHED FIRST BY .RUN,
    ; .COMPILE, .RNEW, ETC...
    cpath = where(strmatch(path_syml,current) eq 1,n_cpath,COMPLEMENT=rpath)
    path_syml = [current,path_syml[rpath]]
    path = [(n_cpath gt 0) ? path[cpath] : current, path[rpath]]

    ; ADD THE FILENAME TO EACH PATH DIRECTORY...
    filenames = path + psep + proname + '.pro'

    ; DOES ANY SUCH FILE EXIST IN THE CURRENT PATH...
    ; THIS WAS WRITTEN BACK IN V5.4, BEFORE FILE_SEARCH, LEAVE IT ALONE...
    file_exists = where(file_test(filenames), N_exists)

    ; IF THERE IS NO SUCH FILE THEN SPLIT...
    if (N_exists eq 0) then begin
        cd, current
        return, result
    endif

    ; GET TARGET OF A SYMBOLIC LINK IN THE PATH OF THE RESOLVED ROUTINE...
    ; ALSO HANDLES INDIRECT MOUNT POINTS ON LINUX SYSTEMS...
    resolved_routine = result
    for i = 0, N_elements(resolved_routine)-1 do begin
        ; GET THE PATH TO THE RESOLVED ROUTINE...
        p = strsplit(resolved_routine[i],psep,COUNT=np,/EXTRACT)
        d = psep+((np gt 1) ? strjoin(p[0:np-2],psep,/SINGLE) : '')
        cd, d & cd, CURRENT=dnew
        if not strmatch(d,dnew) $
        then resolved_routine = [resolved_routine,dnew+psep+p[np-1]]
    endfor
    cd, current

    ; PULL OUT ALL THE FILES THAT EXIST...
    filenames = filenames[file_exists]
    filenames_syml = path_syml[file_exists] + psep + proname + '.pro'

    ; TAKE RESOLVED ROUTINE OUT OF THE LIST...
    if (n_elements(resolved_routine) gt 1 or strlen(resolved_routine[0]) gt 0) then begin
        ; GET THE INDICES OF THE UNRESOLVED ROUTINES...
        find_resolved = strmatch(filenames_syml,resolved_routine[0])
        for i = 1, N_elements(resolved_routine)-1 do $
          find_resolved = find_resolved OR $
          strmatch(filenames_syml,resolved_routine[i])
        file_exists = where(find_resolved eq 0, N_exists)

        ; WAS THE RESOLVED ROUTINE THE ONLY ONE...
        if (N_exists eq 0) then return, result

        filenames = filenames[file_exists]
    endif

    unresolved = filenames

    return, result
end
