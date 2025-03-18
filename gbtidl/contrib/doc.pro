
pro doc, name, _REF_EXTRA=_extra
;+
; NAME:
;       DOC
;
; PURPOSE:
;       Wrapper for DOC_LIBRARY that forces it to return documentation for
;       the currently-compiled module.
;
; CALLING SEQUENCE:
;       DOC, name
;
; INPUTS:
;       name - A string containing the name of the IDL routine whose
;              documentation is to be returned.
;
; KEYWORD PARAMETERS:
;       Accepts any of the DOC_LIBRARY kewyords (DIRECTORY,MULTI,PRINT)
;       but if you pass DIRECTORY or MULTI, this can override the
;       behavior of this routine.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The documentation is printed to the terminal, unless the PRINT
;       keyword is set (see documentation for DOC_LIBRARY for details.)
;
; RESTRICTIONS:
;       Can only be used on a unix or linux system.
;
; EXAMPLE:
;       IDL> doc, 'strsplit'
;
; NOTES:
;       This routine was written for two reasons: (1) to prevent RSI...
;       typing DOC_LIBRARY is a pain since the author tends to use this
;       routine a lot; (2) the author got sick of having the wrong
;       documentation returned when there were duplicate module names
;       in his path and the currently-compiled version was not the
;       first instance in the path.
;
;       If the module has not been compiled yet, the documentation for the
;       first match in the IDL !path is printed.  Actually, first the
;       current directory is searched, as is the standard behavior for
;       .run, .compile, etc.  In the extremely strange case of having two
;       different modules with the same name compiled, one as a procedure
;       and the other as a function, there is no way to determine which is
;       the currently-compiled routine, so the best we can do is print out
;       the documentation for both modules and let the user figure out (a)
;       which is the correct routine and (b) how they got into this mess.
;       Similarly, we handle the even more peculiar case of having tried to
;       call a procedure as a function before the procedure was
;       compiled... this confuses IDL quite a bit leaving IDL thinking that
;       this module is a resolved procedure, a resolved function and an
;       unresolved procedure.  A similar problem occurs if you try to call
;       a function as a procedure before the intitial compilation of the
;       function.  So we guard against this crazy case, which the author
;       has actually encountered more than once.
;
;       This routine will handle the case of having the currently-compiled
;       routine living in a file whose name is not routine.pro.  This is
;       poor programming style, but the case is handled nonetheless.
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  03 May 2006
;-

on_error, 2

; MAKE SURE WE'RE USING SOME TYPE OF *N*X...
if not strmatch(!version.os_family,'unix',/FOLD_CASE) then $
   message, 'Routine will only work for unix/linux.'

; NEED V6.0+...
if (float(!version.release) lt 6.0) then $
   message, 'Routine requires IDL v6.0 or above.'

; IS THIS MODULE ALREADY COMPILED...
pindx = where(strmatch(routine_info(), name, /FOLD_CASE),presolved)
findx = where(strmatch(routine_info(/FUNCTIONS), name, /FOLD_CASE),fresolved)

; IF PROCEDURE OR FUNCTION WAS FOUND, IS IT UNRESOLVED...
punresolved = total(strmatch(routine_info(/UNRESOLVED),name,/FOLD_CASE))
funresolved = total(strmatch(routine_info(/UNRESOLVED,/FUNCTIONS),name,$
                             /FOLD_CASE))

; WE NEED TO HANDLE BIZARRO CASES OF HAVING A FUNCTION THAT THE USER TRIES
; TO CALL AS A PROCEDURE, THUS TRICKING IDL INTO THINKING IT HAS ON ITS
; HANDS A RESOLVED FUNCTION, A RESOLVED PROCEDURE AND AN UNRESOLVED
; PROCEDURE...
if (presolved AND punresolved AND fresolved) then begin
   presolved = 0 & punresolved = 0
endif

; AND WHILE WE'RE AT IT, WE TAKE CARE OF THE CONVERSE... A PROCEDURE
; THAT HAS BEEN CALLED AS A FUNCTION BEFORE COMPILATION...
if (fresolved AND funresolved AND presolved) then begin
   fresolved = 0 & funresolved = 0
endif

; GET THE PATH TO THE COMPILED ROUTINE AND THE FILE NAME IN WHICH THE
; MODULE IS STORED (NOT NECESSARILY THE NAME OF THE MODULE!)...
if presolved then begin
   ppath = (routine_info(name,/SOURCE)).path
   pdir = file_dirname(ppath)
   pfile = file_basename(ppath,'.pro',/FOLD_CASE)
endif
if fresolved then begin
   fpath = (routine_info(name,/FUNCTIONS,/SOURCE)).path
   fdir = file_dirname(fpath)
   ffile = file_basename(fpath,'.pro',/FOLD_CASE)
endif

; IF YOU'RE IN THE UNFORTUNATE SITUATION WHERE YOU'VE SOMEHOW COMPILED THIS
; MODULE NAME AS BOTH A FUNCTION AND A PROCEDURE, THE BEST WE CAN DO IS
; PRINT A WARNING FOLLOWED BY THE DOCUMENTATION FOR EACH OF THE COMPILED
; ROUTINES, BECAUSE WE HAVE NO WAY OF KNOWING...
if (presolved AND fresolved) then $
   message, 'The module '+strupcase(name)+' has somehow been '+$
            'compiled as both a procedure and a function!  There '+$
            'is no way to determine which is the currently-compiled '+$
            'version. So the documentation for each is output below.', /INFO

; IN WHICH DIRECTORY AND FILE SHOULD THE DOCUMENTATION BE SEARCHED FOR...
if (presolved OR fresolved) then begin
   dir = (presolved AND fresolved) ? [pdir,fdir] : $
         (presolved ? pdir : fdir)
   file = (presolved AND fresolved) ? [pfile,ffile] : $
          (presolved ? pfile : ffile)
endif else file = name

; GO AHEAD AND CALL DOC_LIBRARY...
doc_library, file[0], DIRECTORY=((presolved AND fresolved) ? dir[0] : dir), $
             _EXTRA=_extra

if (presolved AND fresolved) then $
   doc_library, file[1], DIRECTORY=dir[1], _EXTRA=_extra

end; doc
