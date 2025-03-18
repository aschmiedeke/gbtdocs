;+
; This is a class for reading data from a unipops SDD file and turning
; that into a gbtidl data container.  See Appendix G of the UniPOPS
; cookbook for a detailed description of the data format of an SDD
; file.
;
; @field isnew This is true for the new-type of SDD index.
; @field file_name The file name used at construction.
; @field lun The currently open LUN
; @field bs The boostrap record.
; @field index An array of index records.
;
; @file_comments
; This is a class for reading data from a unipops SDD file
; and turning that into a gbtidl data container.  It is
; probably not ideal for end users who will most likely find the
; conversion script, uni2sdfits, more useful.  That script uses this
; class to convert a unipops data file into an sdfits file that gbtidl
; can read directly.
;
; <p> The SCAN field in the original unipops data is converted to
; SCAN_NUMBER and PROCSEQN in the data container.
;
; <p> Unipops data doesn't have any polarization information in it.
; All data containers are set to have polarization="I".
;
; <p> if_number, polarization_num and feed_num are al set to 0 in the
; converted data container.
;
; <p> This only works for spectral line data.  It will likely not work
; for 12-m OTF data.
;
; <p> This works for recent 12m data, which reverses the byte ordering
; from the original big-endian SDD format.
;
; <p><B>Contributed By: Bob Garwood, NRAO-CV</B>
;
; @version $Id$
;-
;+
; Class constructor
; 
; @param file_name {in}{required}{type=string} Path to the SDD file
; name.
;-
FUNCTION SDD::init, file_name
    compile_opt idl2, hidden

    self.lun = -1
    self.bs.nindxrec = 0

    if n_elements(file_name) eq 0 then begin
        message,'a file_name must be supplied', /info
        return, 0
    endif

    on_ioerror, bad_open
    error = 1

    ; open the file for reading
    openr, lun, file_name, /get_lun, /swap_endian ; open the file
    self.swap_endian = 1
    ; openr, lun, file_name, /get_lun ; open the file
    error = 0

    bad_open:
    if error then begin
        message,'There was a problem opening the file',/info
        print,!error_state.msg
        self.lun = -1
        return, 0
    endif

    self.lun = lun
    self.file_name = file_name

    ok = self->read_bs()
    if not ok then return, 0

    ok = self->read_index()
    if not ok then return, 0

    return, 1
END

;+
; Class Destructor
; @private
;-
PRO SDD::cleanup
    compile_opt idl2, hidden

    if ptr_valid(self.index) then ptr_free, self.index
    self.bs.nindxrec = 0
    if self.lun ge 0 then close, self.lun
    self.lun = -1
    self.file_name = ''
END

;+
; Digest the index record
; @private
;-
FUNCTION SDD::read_bs
    compile_opt idl2, hidden

    if self.lun lt 0 then return, 0

    point_lun, self.lun, 0L

    bs = self.bs
    readu, self.lun, bs
    self.bs = bs

    ; if bs.version is not 1, then this must be the old type, try again
    if self.bs.version ne 1 then begin
        point_lun, self.lun, 0L
        oldbs = {nindxrec:0s, ndatarec:0s, byteperrec:0s, byteperindx:0s, nindxused:0s, $
                 counter:0s}
        readu, self.lun, oldbs
        self.bs.nindxrec = oldbs.nindxrec
        self.bs.ndatarec = oldbs.ndatarec
        self.bs.byteperrec = oldbs.byteperrec
        self.bs.byteperindx = oldbs.byteperindx
        self.bs.nindxused = oldbs.nindxused
        self.bs.counter = oldbs.counter
        self.bs.type = 1L
        self.bs.version = 0L
    endif
    
    ; final sanity check - we always wrote 512 byte records
    if self.bs.byteperrec ne 512 then begin
        ; one last test, the new 12m writes out data on linux in native endian format, try that.
        close, self.lun
        openr, lun, self.file_name, /get_lun ; no swap_endian this time
        self.lun = lun
        self.swap_endian = 0
        point_lun, self.lun, 0L

        bs = self.bs
        readu, self.lun, bs
        self.bs = bs
        if self.bs.version ne 1 and self.bs.byteperrec ne 512 then begin
            message,'This does not appear to be Unipops SDD data, can not continue',/info
            return, 0
        endif
    endif

    return, 1
END

;+
; Read in the index
; @private
;-
FUNCTION SDD::read_index
    compile_opt idl2, hidden

    if self.lun lt 0 then return, 0
    if self.bs.nindxrec eq 0 then return, 0

    point_lun, self.lun, self.bs.byteperrec

    indxrec = {startbyte:0L, nbytes:0L, hcoord:0.0, vcoord:0.0, source:'                ', $
               scan:0.0, fresol:0.0, frest:0.0D, lst:0.0, ut:0.0, obsmode:0s, rphcode:0s, $
               poscode:0s, pad:intarr((self.bs.byteperindx-62)/2)}

    nindex = (self.bs.nindxrec-1)*self.bs.byteperrec/self.bs.byteperindx 

    index = replicate(indxrec, nindex)

    if (self.bs.version eq 1L) then begin
        ; - new type
        readu, self.lun, index
    endif else begin
        ; - old type
        oldindxrec = {startbyte:0s, nbytes:0s, magic:0s, poscode:0s, hcoord:0.0, vcoord:0.0, $
                      source:'                ', scan:0.0, fresol:0.0, frest:0.0D, $
                      lst:0.0, ut:0.0, obsmode:0s, rphcode:0s, pad:intarr((self.bs.byteperindx-60)/2)}
        oldindex = replicate(oldindxrec, nindex)
        readu, self.lun, oldindex
        ; transfer it one at a time to self.index
        for i = 0, (self.bs.nindxused-1) do begin
            thisindx = index[i]
            oldindx = oldindex[i]
            thisindx.startbyte = oldindx.startbyte
            thisindx.nbytes = oldindx.nbytes
            thisindx.hcoord = oldindx.hcoord
            thisindx.vcoord = oldindx.vcoord
            thisindx.source = oldindx.source
            thisindx.scan = oldindx.scan
            thisindx.fresol = oldindx.fresol
            thisindx.frest = oldindx.frest
            thisindx.lst = oldindx.lst
            thisindx.ut = oldindx.ut
            thisindx.obsmode = oldindx.obsmode
            thisindx.rphcode = oldindx.rphcode
            thisindx.poscode = oldindx.poscode
            index[i] = thisindx
        endfor
    endelse

    ; - calculate true startbyte and nbytes, values are now startrec and
    ;   lastrec

    for i = 0, (self.bs.nindxused-1) do begin
        index[i].nbytes = (index[i].nbytes - index[i].startbyte + 1) * self.bs.byteperrec
        index[i].startbyte = (index[i].startbyte - 1L) * self.bs.byteperrec
    endfor

    self.index = ptr_new(index)

    return, 1
END

;+
; Decode the preamble from a given head+data block as read from disk
;
; @param hdu {in}{required}{type=bytarr} The block of header+data as
; read from disk.
;
; @private
;-
FUNCTION SDD::GET_PREAMBLE, HDU
    compile_opt idl2

    preamble = lonarr(16)
    for i = 0L, 15L do begin
        preamble[i] = self.swap_endian ? swap_endian(fix(hdu,i*2L)) : fix(hdu,i*2L)
    endfor

    return, preamble
END

;+
; Get a double value from a location, in bytes, in a block of data
; from disk
;
; @param block {in}{required}{type=bytarr} The block of bytes
; @param loc {in}{required}{type=long int} The location in block.
; @private
;-
FUNCTION SDD::GET_DOUBLE, block, loc
    compile_opt idl2

    thisloc = loc
    loc = loc + 8
    b = self.swap_endian ? swap_endian(double(block,thisloc)) : double(block,thisloc)
    return, b
END

;+
; Get a string value from a location, in bytes, in a block of data
; from disk
; @param block {in}{required}{type=bytarr} The block of bytes
; @param loc {in}{required}{type=long int} The location in block.
; @param len {in}{required}{type=long int} The number of characters to
; extract.
; @private
;-
FUNCTION SDD::GET_STRING, block, loc, len
    compile_opt idl2

    thisloc = loc
    loc = loc + len
    return, string(block[thisloc:(thisloc+len-1)])
END

;+
; Get a float value from a location, in bytes, in a block of data
; from disk
; @param block {in}{required}{type=bytarr} The block of bytes
; @param loc {in}{required}{type=long int} The location in block.
; @param size {in}{required}{type=long int} The number of floats to
; extract.
; @private
;-
FUNCTION SDD::GET_FLOAT, block, loc, size
    compile_opt idl2

    thisloc = loc
    loc = loc + size*4
    return, self.swap_endian ? swap_endian(float(block, thisloc, size)) : float(block,thisloc,size)
END

;+
; Get the CLASS_1 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_1, hdu, offset, nextclass
    compile_opt idl2

    class1 = {headlen:0L, datalen:0L, scan:0.0D, obsid:'',$
              observer:'', telescop:'', projid:'', object:'', $
              obsmode:'', frontend:'', backend:'', precis:'', $
              savenum:0L, norecord:0L, recordid:0L}
    loc = offset
    class1.headlen = self->get_double(hdu, loc)
    if loc ge nextclass then return,class1
    class1.datalen = self->get_double(hdu, loc)
    if loc ge nextclass then return,class1
    class1.scan = self->get_double(hdu, loc)
    if loc ge nextclass then return,class1
    class1.obsid = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    class1.observer = self->get_string(hdu, loc, 16)
    if loc ge nextclass then return,class1
    class1.telescop = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    class1.projid = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    class1.object = self->get_string(hdu, loc, 16)
    if loc ge nextclass then return,class1
    class1.obsmode = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    class1.frontend = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    class1.backend = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    class1.precis = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class1
    dsavenum = self->get_double(hdu,loc)
    class1.savenum = finite(dsavenum) ? dsavenum : -1
    if loc ge nextclass then return,class1
    dnorecord = self->get_double(hdu,loc)
    class1.norecord = finite(dnorecord) ? dnorecord : -1
    if loc ge nextclass then return,class1
    drecordid = self->get_double(hdu,loc)
    class1.recordid = finite(drecordid) ? drecordid : -1

    return, class1
END

;+
; Get the CLASS_2 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_2, hdu, offset, nextclass
    compile_opt idl2

    class2 = {xpoint:0.0D, ypoint:0.0D, uxpnt:0.0D, uypnt:0.0D, $
              ptcon:dindgen(4), orient:0.0D, focusr:0.0D, focusv:0.0D, $
              focush:0.0D, pt_model:''}
    loc = offset
    class2.xpoint = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.ypoint = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.uxpnt = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.uypnt = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    for i=0,3 do class2.ptcon[i] = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.orient = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.focusr = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.focusv = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.focush = self->get_double(hdu, loc)
    if loc ge nextclass then return,class2
    class2.pt_model = self->get_string(hdu, loc, 8)

    return, class2
END

;+
; Get the CLASS_3 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_3, hdu, offset, nextclass
    compile_opt idl2

    class3 = {utdate:0.0D, ut:0.0D, lst:0.0D, norchan:0.0D, noswvar:0.0D, $
              nophase:0.0D, cycllen:0.0D, samprat:0.0D, cl11type:'', $
              phaseid:0.0D}

    loc = offset
    class3.utdate = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.ut = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.lst = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.norchan = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.noswvar = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.nophase = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.cycllen = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.samprat = self->get_double(hdu, loc)
    if loc ge nextclass then return,class3
    class3.cl11type = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class3
    class3.phaseid = self->get_double(hdu, loc)

    return, class3
END

;+
; Get the CLASS_4 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_4, hdu, offset, nextclass
    compile_opt idl2

    class4 = {epoch:0.0D, xsource:0.0D, ysource:0.0D, xref:0.0D, yref:0.0D, $
              epochra:0.0D, epochdec:0.0D, gallong:0.0D, gallat:0.0D, $
              az:0.0D, el:0.0D, indx:0.0D, indy:0.0D, desorg:dindgen(3), $
              coordcd:''}

    loc = offset
    class4.epoch = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.xsource = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.ysource = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.xref = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.yref = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.epochra = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.epochdec = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.gallong = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.gallat = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.az = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.el = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.indx = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    class4.indy = self->get_double(hdu, loc)
    if loc ge nextclass then return,class4
    for i=0,2 do begin
        class4.desorg[i] = self->get_double(hdu, loc)
        if loc ge nextclass then return,class4
    endfor
    class4.coordcd = self->get_string(hdu, loc, 8)

    return, class4
END

;+
; Get the CLASS_5 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_5, hdu, offset, nextclass
    compile_opt idl2

    class5 = {tamb:0.0D, pressure:0.0D, humidity:0.0D, refrac:0.0D, dewpt:0.0D, mmh2o:0.0D}

    loc = offset
    class5.tamb = self->get_double(hdu, loc)
    if loc ge nextclass then return,class5
    class5.pressure = self->get_double(hdu, loc)
    if loc ge nextclass then return,class5
    class5.humidity = self->get_double(hdu, loc)
    if loc ge nextclass then return,class5
    class5.refrac = self->get_double(hdu, loc)
    if loc ge nextclass then return,class5
    class5.dewpt = self->get_double(hdu, loc)
    if loc ge nextclass then return,class5
    class5.mmh2o = self->get_double(hdu, loc)

    return, class5
END

;+
; Self->Get the CLASS_6 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_6, hdu, offset, nextclass
    compile_opt idl2

    class6 = {scanang:0.0D, xzero:0.0D, yzero:0.0D, deltaxr:0.0D, deltayr:0.0D, $
              nopts:0.0D, noxpts:0.0D, noypts:0.0D, xcell0:0.0D, ycell0:0.0D, $
              frame:''}

    loc = offset
    class6.scanang = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.xzero = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.yzero = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.deltaxr = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.deltayr = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.nopts = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.noxpts = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.noypts = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.xcell0 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.ycell0 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class6
    class6.frame = self->get_string(hdu, loc, 8)

    return, class6
END

;+
; Get the CLASS_7 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_7, hdu, offset, nextclass
    compile_opt idl2

    class7 = {bfwhm:0.0D, offscan:0.0D, badchv:0.0D, rvsys:0.0D, velocity:00D, $
              veldef:'', typecal:''}

    loc = offset
    class7.bfwhm = self->get_double(hdu, loc)
    if loc ge nextclass then return,class7
    class7.offscan = self->get_double(hdu, loc)
    if loc ge nextclass then return,class7
    class7.badchv = self->get_double(hdu, loc)
    if loc ge nextclass then return,class7
    class7.rvsys = self->get_double(hdu, loc)
    if loc ge nextclass then return,class7
    class7.velocity = self->get_double(hdu, loc)
    if loc ge nextclass then return,class7
    class7.veldef = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class7
    class7.typecal = self->get_string(hdu, loc, 8)

    return, class7
END

;+
; Get the CLASS_8 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_8, hdu, offset, nextclass
    compile_opt idl2

    class8 = {appeff:0.0D, beameff:0.0D, antgain:0.0D, etal:0.0D, etafss:0.0D}
    
    loc = offset
    class8.appeff = self->get_double(hdu, loc)
    if loc ge nextclass then return,class8
    class8.beameff = self->get_double(hdu, loc)
    if loc ge nextclass then return,class8
    class8.antgain = self->get_double(hdu, loc)
    if loc ge nextclass then return,class8
    class8.etal = self->get_double(hdu, loc)
    if loc ge nextclass then return,class8
    class8.etafss = self->get_double(hdu, loc)

    return, class8
END

;+
; Get the CLASS_9, 12M specific values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_12M_CLASS_9, hdu, offset, nextclass
    compile_opt idl2

    class9_12m = {synfreq:0.0D, lofact:0.0D, harmonic:0.0D, loif:0.0D, firstif:0.0D, $
                  razoff:0.0D, reloff:0.0D, bmthrow:0.0D, bmorent:0.0D, baseoff:0.0D, $
                  obstol:0.0D, sideband:0.0D, wl:0.0D, gains:0.0D, pbeam:dindgen(2), $
                  mbeam:dindgen(2), sroff:dindgen(4), foffsig:dindgen(3)}

    loc=offset
    class9_12m.synfreq = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.lofact = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.harmonic = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.loif = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.firstif = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.razoff = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.reloff = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.bmthrow = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.bmorent = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.baseoff = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.obstol = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.sideband = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.wl = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    class9_12m.gains = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    for i=0,1 do class9_12m.pbeam[i] = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    for i=0,1 do class9_12m.mbeam[i] = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    for i=0,3 do class9_12m.sroff[i] = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_12m
    for i=0,2 do class9_12m.foffsig[i] = self->get_double(hdu, loc)

    return, class9_12m
END

;+
; Get the CLASS_9, 140FT specific values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_140FT_CLASS_9, hdu, offset, nextclass
    compile_opt idl2

    class9_140ft = {l1:0.0D, l1f1:0.0D, l1f2:0.0D, l2:0.0D, l2f1:0.0D, l2f2:0.0D, $
                    la:0.0D, lb:0.0D, lc:0.0D, ld:0.0D, levcorr:0.0D, $ 
                    ptfudge:dindgen(2), rho:0.0D, theta:0.0D, cfform:''}

    loc = offset
    class9_140ft.l1 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.l1f1 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.l1f2 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.l2 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.l2f1 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.l2f2 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.la = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.lb = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.lc = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.ld = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.levcorr = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    for i=0,1 do class9_140ft.ptfudge[i] = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.rho = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.theta = self->get_double(hdu, loc)
    if loc ge nextclass then return,class9_140ft
    class9_140ft.cfform = self->get_string(hdu, loc, 24)

    return, class9_140ft
END

;+
; Get the CLASS_9 values appropriate for telescope
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param telescope {in}{required}{type=string} The name of the
; telescope.  Used to determine which class_9 to use.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_9, hdu, offset, telescope, nextclass
    compile_opt idl2

    if (telescope eq 'NRAO 12M') then begin
        class9=self->get_12m_class_9(hdu, offset, nextclass)
    endif else begin 
        class9 = self->get_140ft_class_9(hdu, offset, nextclass)
    endelse
    
    return, class9
END

;+
; Get the CLASS_10 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_10, hdu, offset, nextclass
    compile_opt idl2

    class10 = {openpar:strarr(10)}
    
    loc = offset
    for i=0,9 do class10.openpar[i] = self->get_string(hdu, loc, 8)
    
    return, class10
END

;+
; Get the proto CLASS_11 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param noswvar {in}{required}{type=long int} The number of switching
; variables to get.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_11_PROTO, hdu, offset, noswvar, nextclass
    compile_opt idl2

    class11 = {noswvarf:0.0D, numcyc:0.0D, numcyf:0.0D, nophasef:0.0D, $
               cyclenf:0.0D, samptimf:0.0D, varval:dindgen(10), $
               vardes:strarr(10), phastb:strarr(10)}

    loc = offset

    class11.noswvarf = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    class11.numcyc = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    class11.numcyf = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    class11.nophasef = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    class11.cyclenf = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    class11.samptimf = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    nvarval = fix(class11.noswvarf+0.001) + fix(noswvar+0.001)
    for i=0,(nvarval-1) do begin
        class11.varval = self->get_double(hdu, loc)
        class11.vardes = self->get_string(hdu, loc, 8)
        class11.phastb = self->get_string(hdu, loc, 32)
        if loc ge nextclass then return,class11
    endfor

    return, class11
END

;+
; Get the original CLASS_11 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_11_ORIG, hdu, offset, nextclass
    compile_opt idl2

    class11 = {varval:0.0D, vardes:'', phasetb:''}

    loc = offset

    class11.varval = self->get_double(hdu, loc)
    if loc ge nextclass then return,class11
    class11.vardes = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class11
    class11.phasetb = self->get_string(hdu, loc, 8)
    
    return, class11
END

;+
; get the approproate class 11 values based on cl11type
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param cl11type {in}{required}{type=string} The type of class 11 to get.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_11, hdu, offset, noswvar, cl11type, nextclass
    compile_opt idl2

    if (cl11type eq 'PROTO12M') then begin
        class11 = self->get_class_11_proto(hdu, offset, noswvar, nextclass)
    endif else begin
        class11 = self->get_class_11_orig(hdu, offset, nextclass)
    endelse

    return, class11
END

;+
; get the class 12 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_12, hdu, offset, nextclass
    compile_opt idl2

    class12 = {obsfreq:0.0D, restfreq:0.0D, freqres:0.0D, bw:0.0D, trx:0.0D, $
               tcal:0.0D, stsys:0.0D, rtsys:0.0D, tsource:0.0D, trms:0.0D, $
               refpt:0.0D, x0:0.0D, deltax:0.0D, inttime:0.0D, noint:0.0D, $
               spn:0.0D, tauh2o:0.0D, th2o:0.0D, tauo2:0.0D, to2:0.0D, $
               polariz:'', effint:0.0D, rx_info:''}

    loc = offset
    class12.obsfreq = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.restfreq = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.freqres = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.bw = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.trx = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.tcal = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.stsys = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.rtsys = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.tsource = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.trms = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.refpt = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.x0 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.deltax = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.inttime = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.noint = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.spn = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.tauh2o = self->get_double(hdu, loc)
    class12.th2o = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.tauo2 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.to2 = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.polariz = self->get_string(hdu, loc, 8)
    if loc ge nextclass then return,class12
    class12.effint = self->get_double(hdu, loc)
    if loc ge nextclass then return,class12
    class12.rx_info = self->get_string(hdu, loc, 16)

    return, class12
END

;+
; get the class 13 values into a structure
;
; @param hdu {in}{required}{type=bytarr} the block of header+data
; @param offset {in}{required}{type=long int} The offset into block to
; the start of this section of header values.
; @param nextclass {in}{required}{type=long int} The offset into block
; to the start of the next section of header values.
; @private
;-
FUNCTION SDD::GET_CLASS_13, hdu, offset, nextclass
    compile_opt idl2

    class13 = {nostac:0.0D, fscan:0.0D, lscan:0.0D, lamp:0.0D, lwid:0.0D, ili:0.0D, rms:0.0D}

    loc = offset
    class13.nostac = self->get_double(hdu,loc)
    if loc ge nextclass then return,class13
    class13.fscan = self->get_double(hdu,loc)
    if loc ge nextclass then return,class13
    class13.lscan = self->get_double(hdu,loc)
    if loc ge nextclass then return,class13
    class13.lamp = self->get_double(hdu,loc)
    if loc ge nextclass then return,class13
    class13.lwid = self->get_double(hdu,loc)
    if loc ge nextclass then return,class13
    class13.ili = self->get_double(hdu,loc)
    if loc ge nextclass then return,class13
    class13.rms = self->get_double(hdu,loc)
    
    return, class13
END

;+
; Get the data values into an array
; @param hdu {in}{required}{type=bytarr} The block of header+data.
; @param offset {in}{required}{type=bytarr} The offset into block to
; the start of the data values.
; @param noint {in}{required}{type=long int} The number of data
; elements to extract from hdu at offset.
; @private
;-
FUNCTION SDD::GET_DATA, hdu, offset, noint
    compile_opt idl2
    return, self->get_float(hdu, offset, fix(noint+0.001))
END


;+ 
; Get a scan into a structure, preserves all information in the original.
;
; @param loc {in}{required}{type=long integer} The index location to fetch.
;-
FUNCTION SDD::GET_UNISCAN, loc
    compile_opt idl2
    
    if self.lun lt 0 or not ptr_valid(self.index) then begin
        message,'No file has been opened yet',/info
        return, -1
    endif

    if (n_elements(loc) eq 0) then begin
        message,'Usage: sdd->get_scan(loc)',/info
        return, -1
    endif

    if (loc ge n_elements(*self.index)) then begin
        message, 'There is no scan at location LOC - past end of index',/info
        return, -1
    endif

    if (loc lt 0) then begin
        message, 'LOC must be >= 0', /info
        return, -1
    endif

    thisindx = (*self.index)[loc]

    if (thisindx.startbyte eq 0) then begin
        message, 'Index location at LOC is unused',/info
        return, -1
    endif

    point_lun, self.lun, thisindx.startbyte

    hdu = bytarr(thisindx.nbytes)

    readu, self.lun, hdu

    preamble = self->get_preamble(hdu)

    if ((preamble[0] gt 15) or (preamble[0] lt 13)) then begin
        message, 'Invalid number of classes in preamble - can not continue, bad file',/info
        return,-1
    endif
    
    preamble[1:15] = (preamble[1:15]-1L)*8L

    class_1 = SELF->GET_CLASS_1(hdu, preamble[1], preamble[2])
    class_2 = SELF->GET_CLASS_2(hdu, preamble[2], preamble[3])
    class_3 = SELF->GET_CLASS_3(hdu, preamble[3], preamble[4])
    class_4 = SELF->GET_CLASS_4(hdu, preamble[4], preamble[5])
    class_5 = SELF->GET_CLASS_5(hdu, preamble[5], preamble[6])
    class_6 = SELF->GET_CLASS_6(hdu, preamble[6], preamble[7])
    class_7 = SELF->GET_CLASS_7(hdu, preamble[7], preamble[8])
    class_8 = SELF->GET_CLASS_8(hdu, preamble[8], preamble[9])
    class_9 = SELF->GET_CLASS_9(hdu, preamble[9], class_1.telescop, preamble[10])
    class_10 = SELF->GET_CLASS_10(hdu, preamble[10], preamble[11])
    class_11 = self->get_class_11(hdu, preamble[11], class_3.noswvar, class_3.cl11type, preamble[12])
    class_12 = self->get_class_12(hdu, preamble[12], preamble[13])
    class_13 = self->get_class_13(hdu, preamble[13], class_1.headlen)
    data = self->get_data(hdu, class_1.headlen, class_12.noint)

    scan = {class_1:class_1, class_2:class_2, class_3:class_3, class_4:class_4, $
            class_5:class_5, class_6:class_6, class_7:class_7, class_8:class_8, $
            class_9:class_9, class_10:class_10, class_11:class_11, class_12:class_12, $
            class_13:class_13, data:data}

    return, scan

END

;+
; The LUN for the currently opened file
; @returns LUN
; @private
;-
FUNCTION SDD::lun
   return, self.lun
END

;+
; Get the scan at location into a gbtidl data container.
;
; @param loc {in}{required}{type=long integer} The index location to fetch.
;
;-
FUNCTION SDD::getdc, loc
    u = self->get_uniscan(loc)
    return, self->sdd_to_dc(u)
END

;+
; Get the bootstrap record.
; @private;
;-
FUNCTION SDD::getbs
    compile_opt idl2
    return, self.bs
END

;+
; Get the index record at the given location
;
; @param loc {in}{required}{type=long integer} The index location to fetch.
;
;-
FUNCTION SDD::getindx, loc
    compile_opt idl2

    return, (*self.index)[loc]
END

;+
; Convert a unipops SDD structure to a spectrum data container.
;
; @param sdd_scan {in}{required}{type=sdd structure} The structure to
; convert.
; @returns spectrum data container
; @private
;-
FUNCTION SDD::sdd_to_dc, sdd_scan
    compile_opt idl2

    if strmid(sdd_scan.class_1.obsmode,0,4) ne 'LINE' then begin
        message,'Only LINE data can be handled at this time, sorry.',/info
        return, 0
    endif

    dc = data_new(sdd_scan.data)

    dc.units = 'Counts' ; unknown from SDD
    dc.source = sdd_scan.class_1.object
    dc.observer = sdd_scan.class_1.observer
    dc.projid = sdd_scan.class_1.projid
    iscan = fix(sdd_scan.class_1.scan)
    procseqn = round((sdd_scan.class_1.scan - iscan)*100.0)
    dc.scan_number = iscan
    dc.procseqn = procseqn
    dc.nsave = sdd_scan.class_1.savenum
    ; nsave sometimes shows problems, watch for them
    if dc.nsave lt -1 then dc.nsave = -1
    if dc.nsave gt 32767 then dc.nsave = -1
    dc.procedure = strmid(sdd_scan.class_1.obsmode,4,4) ; close enough
    dc.procsize = 1 
    dc.switch_state = ''
    dc.switch_sig = ''
    dc.sig_state = 1
    dc.cal_state = 0
    dc.integration = 0
    dc.if_number = 0
    dc.obsid = sdd_scan.class_1.obsid
    dc.backend = sdd_scan.class_1.backend
    dc.frontend = sdd_scan.class_1.frontend
    dc.exposure = sdd_scan.class_12.effint
    dc.duration = sdd_scan.class_12.inttime
    dc.tsys = sdd_scan.class_12.stsys
    dc.mean_tcal = sdd_scan.class_12.tcal
    dc.tsysref = sdd_scan.class_12.rtsys
    dc.telescope = sdd_scan.class_1.telescop
    dc.site_location = [0.,0.,0.]  ; need to fill this in based on telescope
    case sdd_scan.class_4.coordcd of
        '1950RADC': begin
            dc.coordinate_mode = 'RADEC'
            dc.equinox = 1950.0
            dc.radesys = 'FK4'
        end
        '2000RADC': begin
            dc.coordinate_mode = 'RADEC'
            dc.equinox = 2000.0
            dc.radesys = 'FK5'
        end
        'EPOCRADC': begin
            dc.coordinate_mode = 'RADEC'
            dc.equinox = sdd_scan.class_4.epoch
            ; should this try and guess based on
            ; how close equinox is to 1950 or 2000?
            dc.radesys = ''
        end
        'APPRADC': begin
            ; not quite the same as RADEC at epoch, but close enough?
            dc.coordinate_mode = 'RADEC'
            dc.equinox = sdd_scan.class_4.epoch
            ; should this try and guess based on
            ; how close equinox is to 1950 or 2000?
            dc.radesys = ''
        end
        'MEANRADC': begin
            ; not quite the same as RADEC at epoch, but close enough?
            dc.coordinate_mode = 'RADEC'
            dc.equinox = sdd_scan.class_4.epoch
            ; should this try and guess based on
            ; how close equinox is to 1950 or 2000?
            dc.radesys = ''
        end
        'APPHADC': begin
            dc.coordinate_mode = 'HADEC'
            dc.equinox = sdd_scan.class_4.epoch
            dc.radesys = ''
        end
        'AZEL': begin
            dc.coordinate_mode = 'AZEL'
            ; this doesn't matter, but set it here anyway
            dc.equinox = sdd_scan.class_4.epoch 
            dc.radesys = ''
        end
        'GALACTIC': begin
            dc.coordinate_mode = 'GALACTIC'
            ; this doesn't matter, but set it here anyway
            dc.equinox = sdd_scan.class_4.epoch 
            dc.radesys = ''
        end
        else: begin
            ; 1950ECL, EPOCECL, MEANECL, APPECL, USERDEF, INDRADEC
            dc.coordinate_mode = 'OTHER'
            dc.equinox = sdd_scan.class_4.epoch
            dc.radesys = ''
        end
    endcase
    dc.polarization = 'I'
    dc.polarization_num = 0
    dc.feed = 0
    dc.srfeed = 0
    dc.feed_num = 0
    dc.feedxoff = 0.0
    dc.feedeoff =0.0
    dc.sampler_name = ''
    dc.bandwidth = sdd_scan.class_12.bw*1.d6
    dc.observed_frequency = sdd_scan.class_12.obsfreq*1.d6
    if (dc.telescope eq 'NRAO 12M') then begin
        dc.sideband = sdd_scan.class_9.sideband eq 2 ? 'U':'L'
        dc.freq_switch_offset = sdd_scan.class_9.foffsig[0]
        ; fill in best guess at site location
        dc.site_location = [-111.61485,31.95333,1914.0]
    endif else begin
        dc.sideband = 'U'
        dc.freq_switch_offset = 0.0d
        ; fill in best guess at site location
        dc.site_location = [-79.83625,38.43806,823.0]
    endelse
    iyear = fix(sdd_scan.class_3.utdate + 0.5)
    imonth = fix((sdd_scan.class_3.utdate - iyear)*100.d + 0.5)
    iday = round(((sdd_scan.class_3.utdate - iyear)*100.d - imonth)*100.d)
    if iyear lt 100 then iyear = 1900 + iyear
    dc.date = string(iyear,imonth,iday,format='(i4.4,"-",i2.2,"-",i2.2)')
    dc.utc = sdd_scan.class_3.ut * 3600.d
    ihour = fix(sdd_scan.class_3.ut)
    imin = fix((sdd_scan.class_3.ut-ihour)*60.d)
    sec = ((sdd_scan.class_3.ut-ihour)*60.d - imin)*60.d
    if (imonth lt 0) or (iday lt 0) or (iyear lt 0) or (ihour lt 0) or (imin lt 0) or sec lt 0 then begin
        ; problems with the date
        message,'The date appears to be suspect - using current date and time.',/info
        dc.mjd = systime(/jul) - 2400000.5d
    endif else begin
        dc.mjd = julday(imonth,iday,iyear,ihour,imin,sec) - 2400000.5d
    endelse
    dc.frequency_type = 'TOPO'
    dc.reference_frequency = sdd_scan.class_12.obsfreq*1.d6
    dc.reference_channel = sdd_scan.class_12.refpt - 1.0d 
    dc.frequency_interval = sdd_scan.class_12.freqres*1.d6
    dc.frequency_resolution = dc.frequency_interval
    ; some recent data from the 12m has 0.0 bandwidth
    if dc.bandwidth eq 0.0 then dc.bandwidth = abs(dc.frequency_interval)*n_elements(*dc.data_ptr)
    dc.center_frequency = sdd_scan.class_12.obsfreq*1.d6
    dc.longitude_axis = sdd_scan.class_4.xsource
    dc.latitude_axis = sdd_scan.class_4.ysource
    vdef = strmid(sdd_scan.class_7.veldef,0,4)
    vframe = strmid(sdd_scan.class_7.veldef,4,3)
    ; convert from unipops codes to gbtidl codes, RADI is the same
    if vdef eq 'OPTL' then vdef = "OPTI"
    if vdef eq 'RELV' then vdef = "RELA"
    dc.velocity_definition = string(vdef,vframe,format='(a4,"-",a3)')
    dc.frame_velocity = sdd_scan.class_7.rvsys*1.d3
    dc.lst = sdd_scan.class_3.lst*3600.d
    dc.azimuth = sdd_scan.class_4.az
    dc.elevation = sdd_scan.class_4.el
    dc.line_rest_frequency = sdd_scan.class_12.restfreq*1.d6
    dc.source_velocity = sdd_scan.class_7.velocity*1.d3
    dc.tambient = sdd_scan.class_5.tamb + 273.15 ; C to K
    dc.pressure = sdd_scan.class_5.pressure / (7.5006e-4) ; cm-hg to Pa
    dc.humidity = sdd_scan.class_5.humidity / 100.0 ; % to fraction

    ; construct a TIMESTAMP from the mjd (utdate and ut)
    dc.timestamp = makefitsdate(dc.mjd)

    ; could probably also try and extract target position from map
    ; parameters but it's poorly documented and I can't find any
    ; mapping examples

    ; make sure these are not set to anything useful
    dc.caltype = ''
    dc.zero_channel = !values.f_nan

    return, dc
END

;+
; How many indicies are used
; @returns number of indicies in use (maximum loc for other SDD calls)
;-
FUNCTION SDD::nscans
    compile_opt idl2
    return, self.bs.nindxused 
END
    
    
;+
; Is a particular index in use (nbytes > 0)
; @param loc {in}{required}{type=integer} The index location to check.
; @returns true (1) if the indicated location is in use.
;-
FUNCTION SDD::indexUsed, loc
    compile_opt idl2
    if loc lt 0 or loc ge self->nscans() then return, 0

    thisIndx = self->getindx(loc)
    result = thisIndx.nbytes gt 0
    return, result
END

;+
; Define the class structure
; @private
;-
PRO sdd__define
    compile_opt idl2, hidden

    p = {sdd, $
         isnew:1, $
         file_name:string(replicate(32B,256)), $
         lun:0L, $   ; currently opened LUN
         swap_endian:1L, $  ; default is to swap_endian
         bs:{bsrec,nindxrec:0L, ndatarec:0L, byteperrec:0L, byteperindx:0L, nindxused:0L, counter:0L, type:0L, version:0L}, $
         index:ptr_new() $ ; ptr to array of index records
         }
    
END
