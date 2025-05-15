##################################
Other GBTIDL Features and Examples
##################################


Customizing the output of the list procedure
============================================

The :idl:pro:`list` command can be used to view detailed information on records in the active input file.
Because this file contains a great deal of information, it is possible to request that the :idl:pro:`list`
command show only that information of interest.

The following command shows how to create the sample data used in these examples:

.. code-block:: bash

    sdfits -mode=raw -scans=177:180 -backends=acs /home/archive/test-data/tape-0002/TREG_040922

Then to access this data in GBTIDL use this command:

.. code-block:: IDL
   
    filein, ’TREG_040922.raw.acs.fits’

In the first example, we use :idl:pro:`list`

.. code-block:: IDL

    list                    ; Show a brief description of everything

to show all the records, or spectra, currently found in the index file    

.. code-block:: text

    #INDEX SOURCE SCAN PROCEDURE POL IFNUM FDNUM INT SIG CAL
       0    W3OH  177    OffOn   XX    0     0    0   T   T
       1    W3OH  177    OffOn   XX    0     0    0   T   F
       2    W3OH  177    OffOn   XX    0     0    1   T   T
       3    W3OH  177    OffOn   XX    0     0    1   T   F
       4    W3OH  177    OffOn   YY    0     0    0   T   T
       .
       .
       .
       30   W3OH  180    OffOn   YY    0     0    1   T   T
       31   W3OH  180    OffOn   YY    0     0    1   T   F

Next, we use a simple search parameter:

.. code-block:: IDL

    list, index=[0,1,2]     ; Show a description of the first three records

.. code-block:: text

    #INDEX SOURCE SCAN PROCEDURE POL IFNUM FDNUM INT SIG CAL
       0    W3OH  177    OffOn   XX    0     0    0   T   T
       1    W3OH  177    OffOn   XX    0     0    0   T   F
       2    W3OH  177    OffOn   XX    0     0    1   T   T

To see all of information associated with these records, use the verbose keyword.

.. code-block::  IDL

    list, index=[0,1,2], /verbose

This will return the parameters:

.. code-block:: text

    # INDEX, PROJECT, FILE, EXT, ROW, SOURCE, PROCEDURE, OBSID, E2ESC, PROCS, SCAN, POL,
    PLNUM, IFNUM, FEED, FDNUM, INT, NUMCHN, SIG, CAL, SAMPLER, AZIMU, ELEV, LONGITUDE,
    LATITUDE, TRGTLONG, TRGTLAT, LST, CENTFREQ, RESTFREQ, VELOCITY, FREQINT, FREQRES,
    DATEOBS, TIMESTAMP, BANDWIDTH, EXPOSURE, TSYS, NSAVE

Obviously, the above example is not best if you are only interested in the values of a few specific columns.
You can narrow the output like so:

.. code-block:: IDL

    list, index=[0,1,2], columns=["INDEX","INT","POLARIZATION"]

.. code-block:: text

    #INDEX INT POL
       0    0  XX
       1    0  XX
       2    1  XX

The list command prints records in the order of the index number by default. This can be changed
using the sortcol keyword. Note that the full name of the column must be used.

.. code-block:: IDL

    list, scan=177, sortcol="INT" ; Sort by integration number

returns

.. code-block:: text

    #INDEX SOURCE SCAN PROCEDURE POL IFNUM FDNUM INT SIG CAL
       0    W3OH   177   OffOn   XX    0     0    0   T   T
       1    W3OH   177   OffOn   XX    0     0    0   T   F
       4    W3OH   177   OffOn   YY    0     0    0   T   T
       5    W3OH   177   OffOn   YY    0     0    0   T   F
       2    W3OH   177   OffOn   XX    0     0    1   T   T
       3    W3OH   177   OffOn   XX    0     0    1   T   F
       6    W3OH   177   OffOn   YY    0     0    1   T   T
       7    W3OH   177   OffOn   YY    0     0    1   T   F

The liststack command is identical to the list command except that it selects from records identified
by the stack.

.. code-block:: IDL

    select, scan=177 ; Place scan 177’s records on the stack
    liststack, col=["INDEX","INT","CAL"], sortcol="CAL"

returns

.. code-block:: text

    #INDEX INT CAL
       1    0   F
       3    1   F
       5    0   F
       7    1   F
       0    0   T
       2    1   T
       4    0   T
       6    1   T


Making postage stamp plots
==========================

In displaying PointMap data, or just for displaying multiple spectra, it can be convenient to display
spectra as postage stamp plots. GBTIDL currently does not have any inherent support for postage
stamp plots, but it is easy to use the IDL plotter to duplicate plots as one might see from CLASS, for
example.

For instance, a 3x3 PointMap might be stored as calibrated, reduced spectra in an SDFITS file, with
the first 9 records representing the map. These can be displayed in a postage stamp plot as follows:

.. code-block:: IDL

    filein, ’postage.fits’
    freeze
    !p.multi = [0,3,3]
    for i=0,8 do begin & $
        getrec, i & $
        x = getxarray() & $
        y = getdata() & $
        plot, x, y, xstyle=1 & $
    endfor
    unfreeze


For more flexibility in plot placement, the position parameter can be used, as in the following procedure:

.. code-block:: IDL

    pro plotpos, x, y, xpos, ypos, xsize, ysize
        if (n_elements(xsize)) eq 0 then xsize = 0.1
        if (n_elements(ysize)) eq 0 then ysize = 0.1
        freeze
        plot,x,y,position=[xpos-xsize/2,ypos-ysize/2,xpos+xsize/2,ypos+ysize/2], /noerase, xstyle=1
        unfreeze
    end

The procedure might be used as follows:

.. code-block:: IDL

    erase
    getrec,0
    plotpos, getxarray(), getdata(), 0.5, 0.5, 0.25, 0.25
    getrec,1
    plotpos, getxarray(), getdata(), 0.2, 0.5, 0.25, 0.25
    getrec,2
    plotpos, getxarray(), getdata(), 0.8, 0.5, 0.25, 0.25
    getrec,3
    plotpos, getxarray(), getdata(), 0.5, 0.2, 0.25, 0.25
    getrec,4
    plotpos, getxarray(), getdata(), 0.5, 0.8, 0.25, 0.25


Example reduction sessions with sample data sets
================================================

This section describes a few sample data sets for users who may wish to experiment with GBTIDL but
who do not yet have any data to play with. You may wish to experiment with GBTIDL before you
have an appropriate data set of your own. With each data set is an example of how the data might be
reduced and analyzed in GBTIDL. The examples are simply guides, and there are many ways to reduce
the data in each case.

HI Position Switched Data
^^^^^^^^^^^^^^^^^^^^^^^^^

This is a strightforward observation of HI in a galaxy, observed using position switching. The data set
is “clean”, so all the data can be included in the averaging. The example data reduction is terse in this
case, and aims just to produce an HI spectrum calibrated as antenna temperature (K). The RMS noise
and integrated flux density of the HI source are measured.

* Retrieve the data: ngc5291.fits (http://safe.nrao.edu/wiki/pub/GB/Data/GBTIDLExampleAndSampleData/ngc5291.fits)

* Example data reduction:
    Get the data into GBTIDL and show a summary of the scans:

    .. code-block:: IDL

        filein, ’ngc5291.fits’
summary

    Calibrate and accumulate the data for each scan, and for each polarization:

    .. code-block:: IDL

        for i=51,57,2 do begin getps, i, plnum=0 & accum & end
        for i=51,57,2 do begin getps, i, plnum=1 & accum & end
        ave

    Set a baseline region and subtract the baseline:

    .. code-block:: IDL

        chan
        nregion,[3300,14800,17900,31000]
        nfit,3
        sety, 0.2, 0.5
        bshape
        baseline
        unzoom

    Apply some smoothing, then measure statistics:

    .. code-block:: IDL

        hanning,/decimate
        bdrop, 2500
        edrop, 2500
        velo
        stats, 2000, 3000 ; this gives the RMS: 13.5 mJy
        stats, 3900, 4800 ; this gives the integrated area: 60.439 K km/s
        boxcar, 8 ; more smoothing


OH/HI Frequency Switched Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is a slightly more involved data set than the previous one. In this case, there are 2 spectral windows,
or “IFs”. One records the 1665/1667 MHz OH masers and the other records the HI emission toward
W3(OH). The data are frequency switched. This data includes some integrations in which there are bad
data, and so the observer must be careful to inspect and average the data selectively.

* Retrieve the data: W3OH.fits (http://safe.nrao.edu/wiki/pub/GB/Data/GBTIDLExampleAndSampleData/W3OH.fits)

  .. todo:: 
    
    Make the file available for download here.

  
* Example data reduction:
    Get the data into GBTIDL and show a summary of the scans:

    .. code-block:: IDL

        filein, ’W3OH.fits’
        summary

    Begin by visually inspecting the data. Note not all the data is “good” so we will need to be
    selective in the averaging. The “wait” command simply pauses to give the observer a chance
    to look at the data.

    .. code-block:: IDL

        for i=79, 83 do begin getfs, i, plnum=1, ifnum=0 & wait, 2 & end

    Zoom in to the baseline and repeat:

    .. code-block:: IDL

        sety, -2, 2
        for i=79, 83 do begin getfs, i, plnum=1, ifnum=0 & wait, 2 & end

    
    Inspect individual integrations within scan 83. Note that within a scan some integrations
    are good and some bad.

    .. code-block:: IDL

        for i=0,5 do begin getfs, 83,intnum=i, plnum=1, ifnum=0 & wait, 2 & end


    We must average only the good integrations. There are many ways to approach this problem.
    It would be natural to use the flagging commands, but here we use a different method which
    is terse but efficient. We loop through each integration of each scan, test the RMS in the
    data, and accumulate only the good integrations. The use of freeze before the loop and
    unfreeze after the loop speeds up the processing by turning off the automatic update of the
    plotter after each getfs call.

    .. code-block:: IDL

        velo
        freeze
        for i=79,83 do begin & $
            for j=0,5 do begin & $
                for k=0,1 do begin & $
                    getfs, i, units=’Jy’, intnum=j, plnum=k, ifnum=0 & $
                    stats,-3000,-2000,ret=a,/quiet & $
                    if a.rms lt 0.5 then accum else print, ’Skipping’ ,i, j, k & $
                end
            end
        end
        unfreeze
        ave

    The next example illustrates the flagging approach. The bad integrations are first flagged
    and then the scans for ifnum=0 are averaged, using both polarizations. Note that the loop
    over integrations can now be eliminated. The getfs command averages all integrations and
    since the bad integrations are now flagged, they do not contribute to the average.

    .. code-block:: IDL

        flag,[80,82], intnum=[1,3], plnum=1, ifnum=0, idstring=’corrupt’
        flag, 83, intnum=[2,4], plnum=1, ifnum=0, idstring=’corrupt’
        listflags,/summary
        freeze
        for i=79,83 do begin & $
            for k=0,1 do begin & $
                getfs,i,units=’Jy’, plnum=k, ifnum=0 & $
                accum & $
            end
        end
        unfreeze
        ave

    Extract a region of interest:

    .. code-block:: IDL    
    
        chan
        my_spec = dcextract(!g.s[0],7500,9500)
        bdrop, 0
        edrop, 0
        show,my_spec
        !g.s[0] = my_spec
        show

    Set the baseline regions using the mouse cursor and subtract a baseline.

    .. code-block:: IDL

        sety, -0.2,0.4 ; Zoom in a bit
        setregion
        nfit, 7
        bshape
        baseline


    Fit Gaussians to one of the maser complexes. Use fitgauss to specify a 3-component fit.

    .. code-block:: IDL

        velo
        setx, -60, -30
        freey
        fitgauss

    Follow the instructions for fitgauss.

H2O Total Power Nod Data
^^^^^^^^^^^^^^^^^^^^^^^^

This data set contains an observation of a maser line, observed in total power nod mode. In the first
example below we show the simplest (but verbose) method to average and reduce the data. The second
example is more involved. We use the stack to gather the scans for averaging. We store the individual
scans in internal buffers, and display them all overlaid. Finally we average the data and write the final
spectrum to disk.


* Retrieve the data: IC1481.fits (http://safe.nrao.edu/wiki/pub/GB/Data/GBTIDLExampleAndSampleData/IC1481.fits)
  
  .. todo:: 
    
    Make the file available for download here.

* Simple reduction of this data set:
    Get the data into GBTIDL and accumulate some of the data:

    .. code-block:: IDL

        filein, ’IC1481.fits’
        getnod, 182, plnum=0
        accum
        getnod, 182, plnum=1
        accum
        getnod, 184, plnum=0
        accum
        getnod, 184, plnum=1
        accum

    The other scans can be accumulated similarly. Now, average the accumulated data and
    fit a baseline.

    .. code-block:: IDL

        ave
    setregion
    nfit, 3
    baseline

* Alternative reduction:
    Get the data into GBTIDL and show a summary of the scans:

    .. code-block:: IDL

        filein, ’IC1481.fits’
        summary

    
    Clear the stack, then fill it with even scan numbers in the range 182-188.

    .. code-block:: IDL

        emptystack
        sclear
        addstack, 182, 188, 2
        tellstack

        
    Now loop through each scan pair, retrieve the calibrated spectrum, accumulate it and
    also store it in a memory buffer. The use of freeze and unfreeze before and after the
    loop speeds up the processing by disabling the automatic update of the plotter after each
    getnod.

    .. code-block:: IDL

        freeze
        for i = 0, !g.acount-1 do begin & $
            getnod, astack(i), plnum=0, units=’Jy’, tsys=60 & accum & $
            copy, 0, i*2+2 & $
            getnod, astack(i), plnum=1, units=’Jy’, tsys=60 & accum & $
            copy, 0, i*2+3 & $
        end
        unfreeze
        ave

    Fit a baseline:

    .. code-block:: IDL

        setregion
        nfit, 3
        bshape
        baseline

    
    Smooth the spectrum, then save it to disk.

    .. code-block:: IDL

        hanning, /decimate
        fileout, ’saved.fits’
        keep


    Create a plot showing each individual spectrum (2 polarizations per scan pair) on a
    single plot, with offsets to make it easier to see the spectra:

    .. code-block:: IDL

        copy, 2, 0
        baseline
        show
        copy, 0, 2
        freeze
        for i=3,9 do begin copy, i, 0 & baseline & bias, float(i-2)*0.2 & copy, 0, i & end
        show, 2
        unfreeze
        for i=3,9 do oshow, i, color=!red
