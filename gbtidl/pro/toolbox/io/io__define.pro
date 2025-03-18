;+
;  All io objects inherit from this 'abstract' base class. 
;  See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes
;  @field version string to hold version number for I/O
;  @file_comments
;  All io objects inherit from this 'abstract' base class.
;  See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes
;  @private_file
;-
PRO io__define
   compile_opt idl2, hidden

   i = { io, version:string(replicate(32B,3)) }

END

;+
; Class Constructor - version number set here
; @private
;-
FUNCTION IO::init
    compile_opt idl2, hidden

    ; versions string is hardcoded, and updated when sig. changes occur

    ; this is the index version, the sdfits version is 
    ; found in sdfits__define.pro and set in the
    ; create_sdfits_file function
    self.version = '1.7'
    
    return, 1

END    

;+
; Checks if file exists
; @returns 0,1
; @uses file_info
;-
FUNCTION IO::file_exists, file_name
    compile_opt idl2

    file_info = file_info(file_name)
    return, file_info.exists

END 

;+
; Retrieves this objects version number
; @returns version number
;-
FUNCTION IO::get_version
    compile_opt idl2

    return, self.version

END    
 
