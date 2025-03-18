;+
; Stubbed version for use with IDL 6.2 and PREF_MIGRATE
; utility.  Without this, resolve_all fails on GBTIDL
; start-up the first time it is used because this symbol
; is not available in linux installations.
;-
pro wde_import_macros, arg1, RETAIN_CURRENT=retain_current
    message,'GBTIDL stubbed version of WDE_IMPORT_MACROS used - this should never happen.'
end
