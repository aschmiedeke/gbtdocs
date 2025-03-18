;+
; Uses CASA library call to return the velocity of toframe relative to
; fromframe.
;
; <p>
; See dcfixvframe or fixvframe for the procedures intended for
; users to use.  This function is primarily for use internal to
; those procedures.  Note that the first time this function is 
; called there will be a small delay while the shared library is
; loaded.  Subsequent calls will be substantially faster.
;
; <p>
; This calls a function in a shared library that in turn invokes the
; necessary calls in the CASA library to calculate the relative frame
; velocities for the given pointing direction, site location, and
; modified Julian date (mjd).  This function is only available
; in Green Bank and Charlottesville on linux machines because of the
; nature of the CASA library calls (this does not use pure IDL).
; This is an interrum solution while a more permanent solution for
; use more transparently in GBTIDL is researched and implemented.
;
; <p><B>Contributed By: Bob Garwood, NRAO-CV</B>
;
; @param ra {in}{required}{type=double} The J2000 RA in degrees.
; @param dec {in}{required}{type=double} The J2000 Dec in degrees.
; @param mjd {in}{required}{type=double} The modified Julian date in days.
; @param sitelong {in}{required}{type=double} The site (telescope)
; longitude in degrees east.
; @param sitelat {in}{required}{type=double} The site (telescope)
; latitude in degrees.
; @param siteelev {in}{required}{type=double} The site (telescope)
; elevation in meters above sea level.
; @param fromframe {in}{required}{type=string} The "from" reference
; frame.  Must be one of LSRD, LSRK, BARY, GEO, TOPO, GALACTO,
; LGROUP, and CMB.  Usually this will be "TOPO"  The returned value is
; the velocity of toframe relative to this frame.
; @param toframe {in}{required}{type=string} The "to" reference
; frame.  Must be one of LSRD, LSRK, BARY, GEO, TOPO, GALACTO,
; LGROUP, and CMB.  The returned velocity is the velocity of this
; frame relative to fromframe.
; @returns The velocity in m/s of fromframe relative to toframe.
;
; @examples
; Given a data container, dc, this gets the casa-calculated frame
; velocity using the header values in that data container.
; <pre>
; radec = getradec(dc,2000.0,/quiet)
; ok = decode_veldef(dc.velocity_definition, veldef, velframe)
; vframe = casaframevel(radec[0],radec[1],dc.mjd,dc.site_location[0], $
;                       dc.site_location[1], dc.site_location[2], $
;                       dc.frequency_type, velframe)
; </pre>
;
; @uses casaframetrans
;
; @version $Id$
;-
function casaframevel, ra, dec, mjd, sitelong, sitelat, siteelev, $
  fromframe, toframe
compile_opt idl2

if n_params() ne 8 then begin
    usage,'casaframevel'
    return, junk
endif

frameVelLib = ''
aipspath = getenv('AIPSPATH')
if !version.arch eq 'x86' then begin
    if strlen(aipspath) eq 0 then begin
        setenv,'AIPSPATH=/usr/lib/aips++'
        aipspath = getenv('AIPSPATH')
    endif
    frameVelLib = getenv('GBT_IDL_DIR')+'/contrib/framevelwrap.so'
endif else begin
    if !version.arch eq 'x86_64' then begin
        if strlen(aipspath) eq 0 then begin
            setenv,'AIPSPATH=/usr/lib64/aips++'
            aipspath = getenv('AIPSPATH')
        endif
        ; 32 or 64 bit version
        if !version.memory_bits eq 32 then begin
            frameVelLib = getenv('GBT_IDL_DIR')+'/contrib/framevelwrap.so'
        endif else begin
            if !version.memory_bits eq 64 then begin
                frameVelLib = getenv('GBT_IDL_DIR')+'/contrib/framevelwrap_64.so'
            endif
        endelse
    endif
endelse
if strlen(frameVelLib) eq 0 then begin
    message,'The necessary shared library does not exist for this OS and IDL memory bits combination.'
endif
aipsroot = (strsplit(aipspath,/extract))[0]
if file_test(aipsroot,/dir) eq 0 then begin
    ; one last attempt, use old casa path
    if file_test('/usr/lib/casa',/dir) eq 1 then begin
        setenv,'AIPSPATH=/usr/lib/casa'
        aipsroot = '/usr/lib/casa'
    endif else begin
        message,'Unable to locate an aips++ installation, please set AIPSPATH first.'
    endelse
endif
; this is a punt, if aipsroot contains "casa" assume old, RH4, build
if strpos(aipsroot,'casa') ge 0 then begin
    frameVelLib = getenv('GBT_IDL_DIR')+'/contrib/framevelwrap_rh4.so'
endif

casafromframe = casaframetrans(fromframe)
casatoframe = casaframetrans(toframe)

return, call_external(frameVelLib,'framevelwrap', $
                      ra, dec, mjd, sitelong, sitelat, siteelev, $
                      casafromframe, casatoframe, /d_value)
end
