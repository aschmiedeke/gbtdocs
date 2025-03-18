;+
; annotate a plot with gaussian fit values.
; <p> assumes data are in !g.gauss
; <p><B>Contributed By: Bob Garwood from Tom Bania's original GBT IDL package</B>
;-
pro pltg

    clearannotations

    ; annotate the gaussians
    lab='       P        C         W'

    off=-.03
    annotate,.13,.71,lab,/normal,charsize=1.4,color=!yellow,/noshow ; label
    for i=0,!g.gauss.ngauss-1 do begin
        left=!g.gauss.fit[1,i]-!g.gauss.fit[2,i]/2.0d
        right=left+!g.gauss.fit[2,i]
        xvals = chantox([!g.gauss.fit[1,i],left,right])

        sh=string(!g.gauss.fit[0,i],'(f10.3)')
        sc=string(xvals[0],'(f10.3)')
        sw=string(abs(xvals[2]-xvals[1]),'(f10.3)')

        ; convert those to x-axis coordinate values

        y = .67+i*off
        annotate,.13,y,sh,/normal,charsize=1.5,color=!yellow,/noshow ; peak
        annotate,.22,y,sc,/normal,charsize=1.5,color=!yellow,/noshow ; center
        annotate,.31,y,sw,/normal,charsize=1.5,color=!yellow,/noshow ; width
    endfor

    show,/reshow
return
end
