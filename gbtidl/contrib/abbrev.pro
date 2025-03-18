;+
; Abbreviation for 'emptystack'.  See <a href="../../user/guide/emptystack.html">emptystack</a> for help.
;
; @file_comments Collection of abbreviations.  Use <a href="abbrev.html#_abbrev">abbrev</a> for a
; complete list of all abbreviations.  Note that not all arguments to
; the abbreviated commands are always available through the abbreviations.
; <p><B>Contributed By: Jim Braatz, NRAO-CV</B>
;
; @version $Id$
;-
pro es

    emptystack
end

;+
; Abbreviation for 'tellstack'.  See <a href="../../user/guide/tellstack.html">tellstack</a> for help.
;-
pro ts

    tellstack
end

;+
; Abbreviation for 'appendstack'.  See <a href="../../user/guide/appendstack.html">appendstack</a> for help.
;-
pro ap,index
    appendstack,index
end

;+
; Abbreviation for 'addstack'.  See <a href="../../user/guide/addstack.html">addstack</a> for help.
;-
pro as,first,last,step
    if n_elements(last) eq 0 then begin
      addstack,first
    endif else if n_elements(step) eq 0 then begin
      addstack,first,last
    endif else begin
      addstack,first,last,step
    endelse
end

;+
; Abbreviation for 'getnod'.  See <a href="../../user/guide/getnod.html">getnod</a> for help.
;-
pro gn,scan,_extra=extras
    getnod,scan,_extra=extras
end

;+
; Abbreviation for 'getfs'.  See <a href="../../user/guide/getfs.html">getfs</a> for help.
;-
pro gfs,scan,_extra=extras
    getfs,scan,_extra=extras
end

;+
; Abbreviation for 'getps'.  See <a href="../../user/guide/getps.html">getps</a> for help.
;-
pro gps,scan,_extra=extras
    getps,scan,_extra=extras
end

;+
; Abbreviation for 'gettp'.  See <a href="../../user/guide/gettp.html">gettp</a> for help.
;-
pro gtp,scan,_extra=extras
    gettp,scan,_extra=extras
end

;+
; Abbreviation for 'getbs'.  See <a href="../../user/guide/getbs.html">getbs</a> for help.
;-
pro gbs,scan,_extra=extras
    getbs,scan,_extra=extras
end

;+
; Abbreviation for 'getsigref'.  See <a href="../../user/guide/getsigref.html">getsigref</a> for help.
;-
pro gsr,sigscan,refscan,_extra=extras
    getsigref,sigscan,refscan,_extra=extras
end

;+
; Abbreviation for 'setregion'.  See <a href="../../user/guide/setregion.html">setregion</a> for help.
;-
pro sr
    setregion
end

;+
; Abbreviation for 'summary'.  See <a href="../../user/guide/summary.html">summary</a> for help.
;-
pro sm
    summary
end

;+
; Abbreviation for 'unzoom'.  See <a href="../../user/plotter/unzoom.html">unzoom</a> for help.
;-
pro uz
    unzoom
end

;+
; Abbreviation for 'hanning'.  See <a href="../../user/guide/hanning.html">hanning</a> for help.
;-
pro ha
    hanning
end

;+
; Abbreviation for 'hanning with decimation'.  See <a href="../../user/guide/hanning.html">hanning, /decimate</a> for help.
;-
pro hd
    hanning, /decimate
end

;+
; Abbreviation for 'boxcar with decimation'.  See <a href="../../user/guide/boxcar.html">boxcar, /decimate</a> for help.
;-
pro bx, width
    boxcar, width, /decimate
end

;+
; List the available abbreviations.
;
; <p>
; This has to go last so that running "abbrev" will compile all the
; procs.
;-
pro abbrev
    print
    print,'Abbreviations:'
    print
    print,' es   : emptystack'
    print,' ts   : tellstack'
    print,' ap   : appendstack'
    print,' as   : addstack'
    print,' gn   : getnod'
    print,' gfs  : getfs'
    print,' gtp  : gettp'
    print,' gbs  : getbs'
    print,' gps  : getps'
    print,' gsr  : getsigref'
    print,' sr   : setregion'
    print,' sm   : summary'
    print,' uz   : unzoom'
    print,' ha   : hanning'
    print,' hd   : hanning with decimation'
    print,' bx   : boxcar with decimation'
    print,''
    print,' abbrev : list these abbreviations.'
end


