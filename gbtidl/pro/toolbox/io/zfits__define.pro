;+
; This class has all the same functionality as its superclass FITS, but contains special
; handling for known characteristics of sdfits files, for example what columns to expect
; in an extension.
; @file_comments
; This class has all the same functionality as its superclass FITS, but contains specail
; handling for known characteristics of sdfits files, for example what columns to expect
; in an extension.
; @inherits fits
; @private_file
;-

;+
; Retrives the names of columns expected to be found in an sdfits file
; @uses SDFITS::define_sdfits_row
; @returns expected column names
;-
FUNCTION ZFITS::get_expected_col_names
    compile_opt idl2

    return, -1

END

;+
; Takes in a structure representing an zpectrometer fits row, 
; and returns the same 
; structure, minus the DATA and LAGS field
; @returns identical sturcture to that passed in, minus the DATA field
;-
FUNCTION ZFITS::exclude_data, rowStruct
    compile_opt idl2

    names = tag_names(rowStruct)
    firstRow = rowStruct[0]
    outCount = 0
    for i=0,(n_elements(names)-1) do begin
        if names[i] eq 'DATA' or  names[i] eq 'LAGS' then continue
 
        if outCount eq 0 then result=create_struct(names[i],firstRow.(i)) $
        else result=create_struct(result,names[i],firstRow.(i))
        outCount += 1
    endfor
    result = replicate(result,n_elements(rowStruct))
    struct_assign,rowStruct,result
    return,result
    
END

;+
; Returns sizes needed for ASCII columns in sdfits.
; Make this a dummy to override the SDFITS:: version, which should not
; be used here.
; Problems: this exists here AND in IO_SDFITS_WRITER.
; @returns structure with sizes for ASCII columsn in sdfits
; @private
;-
FUNCTION ZFITS::get_sdfits_row_sizes
    return, -1
END

;+
; Defines an anonymous structure that mirrors a row in an sdfits file, version 1.2.  Must be anonymos so that the 
; DATA columns length can be defined at run-time.
; Problems: this exists here AND in IO_SDFITS_WRITER
; Make this a dummy to override the SDFITS:: version, which should not
; be used here.
; @param data_points {in}{type=array} length of DATA column
; @uses SDFITS::get_sdfits_row_sizes
; @returns structure mirroring row of an sdfits file
;-
FUNCTION ZDFITS::define_sdfits_row, data_points
    return, -1
END

;+
; Defines class structure
; @private
;-
PRO zfits__define
   compile_opt idl2, hidden

    f1 = { zfits, inherits sdfits }
    

END

