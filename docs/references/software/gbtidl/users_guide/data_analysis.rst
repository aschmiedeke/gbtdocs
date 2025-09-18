#############
Data Analysis
#############

Using the Stack
===============

The stack is a list of indices that can be used to gather scan numbers or record 
numbers to be used in a later operation, such as averaging. The stack system is 
modeled closely after the UNIPOPS commands.

To add entries to the stack, use the :idl:pro:`addstack` command or the :idl:pro:`appendstack`
command. The :idl:pro:`addstack` command adds a sequence of entries using parameters that 
describe the first entry, last entry, and increment. The appendstack command appends an array 
of indices to the stack. For example:

.. code-block:: IDL

    emptystack                  ; clears the contents of the stack
    addstack, 15                ; Add only index 15
    addstack, 18, 21            ; Add indices 18 through 21
    addstack, 22, 26, 2         ; Add indices 22 through 26 with an increment of 2. (22, 24, 26)
    appendstack, [29, 35]       ; Adds indices 29 and 35 to the stack

The :idl:pro:`tellstack` command lists the indices currently contained in the stack. The GBTIDL
global variable ``!g.acount`` contains the total number of entries in the stack. The power of the
stack will become more evident in the discussion on averaging data. For now, here is a simple 
example of using the stack to show spectrum headers for scans 6, 8, 10 and 12:

.. code-block:: IDL

    emptystack
    addstack, 6, 12, 2
    for i=0,!g.acount-1 do getnod, astack(i) & header & end

The following procedure gives an example of one way the stack could be put to use. The procedure
averages Nod data identified by scan numbers listed in the stack. To use a procedure like this
one, first populate the stack with the appropriate scan numbers then call the procedure.

.. code-block:: IDL

    pro myavg,_extra=extra
    freeze
    for i=0,!g.acount-1 do begin
        getnod,astack(i),plnum=0,units=’Jy’,_extra=extra
        accum
        getnod,astack(i),plnum=1,units=’Jy’,_extra=extra
        accum
    endfor
    ave
    unfreeze
    show
    end

The following stack commands are available.

.. list-table:: Availbale stack commands
    :widths: 10 20
    :header-rows: 1

    * - Command 
      - Purpose
    * - :idl:pro:`addstack`
      - Adds a sequential list of indices to the stack, using addstack,begin,end,increment syntax
    * - :idl:pro:`appendstack`
      - Adds a single index or array of indices to the stack
    * - :idl:pro:`astack`
      - Returns the value of a specific stack entry, given an index,
    * - :idl:pro:`avgstack`
      - Averages the records associated with the stack entries
    * - :idl:pro:`delete`
      - Removes a stack entry from the list
    * - :idl:pro:`deselect`
      - Removes indices from stack based on criteria such as source, polarization, and integration number.
    * - :idl:pro:`emptystack`
      - Clears the stack
    * - :idl:pro:`liststack`
      - Runs a list on records identified by the stack.
    * - :idl:pro:`select`
      - Adds indices to stack based on criteria such as source, polarization, and integration number.
    * - :idl:pro:`tellstack`
      - Shows the indices in the stack or returns all of the stack entries if no index is specified


Removing Baselines
==================

GBTIDL uses “general orthogonal polynomials” in a least squares fit to determine baseline models.
GBTIDL does not support sinusoid or Fourier component models.

To remove a spectral baseline, you must first identify a line-free region of the spectrum to be fit. The
region can be specified with either the :idl:pro:`nregion` command, which allows you to specify the range by
typing the beginning and ending channels for each range, or with the :idl:pro:`setregion` command, which allows
you to select the baseline region on the plotter, using the mouse cursor.

You can specify the order of the polynomial with the :idl:pro:`nfit` procedure, or provide
it as a parameter in the baseline fitting routines. In either case, the value is stored and
becomes the default for later baseline fits. You can view the baseline without subtracting
it via the :idl:pro:`bshape` procedure. When the baseline appears satisfactory, the 
:idl:pro:`baseline` procedure can be used to subtract it. A typical baseline fitting session 
might then look like this:

.. code-block:: IDL

    nfit, 5         ; Specifies that a 5th order polynomial baseline will be fit
    setregion       ; Specify baseline regions using the mouse
    bshape          ; View the fitted baseline, but don’t subtract it yet
    nfit, 4         ; Specifies that a 4th order polynomial baseline will be used
    bshape          ; View the new baseline fit, but don’t subtract it
    baseline        ; Subtract the most recent baseline fit

When a baseline is fit with either :idl:pro:`bshape` or :idl:pro:`baseline`, the baseline model
itself can be stored in a global data container by setting the ``modelbuffer`` keyword. You can
view the baseline model separate from the data as follows:

.. code-block:: IDL

    baseline, modelbuffer=5     ; Subtract the baseline and store the model in buffer # 5
    show, 5                     ; Show the baseline model in buffer # 5

and the data could be restored to its original form by:

.. code-block:: IDL

    add, 5, 0                   ; Add baseline back to original spectrum to undo subtraction

    
After a baseline region is specified using the :idl:pro:`setregion` procedure, a box is displayed
indicating the region to be used in a baseline fit. The height of the box is twice the RMS of the
data within the box, centered at the mean of the data within the box. These boxes can be removed
using the :code:`showregion, /off` command (the regions remain set, but are not displayed).

If you wish to subtract from spectrum B a baseline model derived from spectrum A, use this method:

.. code-block:: IDL

    getfs, 1                            ; Get spectrum A
    baseline, modelbuffer=5             ; Fit and subract the baseline
    getfs, 2                            ; Get spectrum B
    subtract, 0, 5                      ; Subtract the old model

Here is a more sophisticated example of using various baseline features and commands.

.. code-block:: IDL

    getnod, 32                          ; Get some data
    setregion                           ; Set a region to be fit
    bshape, nfit=10                     ; Fit a 10th order polynomial
    bmodel, nfit=2, modelbuffer=5       ; Use 2 coefficients to generate a new model
    bmodel, nfit=5, modelbuffer=6       ; Use 5 coefficients
    bmodel, nfit=10, modelbuffer=7      ; Use all 10
    oshow,5, color=!yellow
    oshow,6, color=!cyan
    oshow,7, color=!green               ; Plot all three for comparison
    subtract, 0, 6                      ; Subtract the 5th order fit


Averaging Data
==============

GBTIDL uses an accumulator to average data. For example:

.. code-block:: IDL

    sclear                  ; Clears the default global accumulator
    get, index=1            ; Get record # 1
    accum                   ; Put the data in the accumulator
    get, index=2            ; Get record # 2
    accum                   ; Adds the data to the accumulator
    ave                     ; Averages data in the accumulator and places result in PDC

The :idl:pro:`sclear` command clears the ``accum`` buffer to ensure it starts empty.
The result of the average is then stored in the PDC unless otherwise stated.

The above example uses the default accumulator buffer. There are 4 accumulator buffers numbered 0,
1, 2, and 3 so you can perform up to 4 different averages simultaneously. These are useful, for example,
when accumulating data from two polarizations simultaneously, as shown in the following script:

.. code-block:: IDL

    sclear, 1                   ; Clear the 1st accum buffer
    sclear, 2                   ; Clear the 2nd accum buffer
    for i=10,15 do begin
        getfs, i, plnum=0
        accum, 1                ; Put data in 1st buffer
        getfs, i, plnum=1
        accum, 2                ; Put data in 2nd buffer
    end
    ave, 1                      ; Average data in 1st buffer
    copy, 0, 10
    ave, 2                      ; Average data in 2nd buffer
    copy, 0, 11
    show, 10
    oshow, 11

Note that the IDL code in the above example works only if it is stored as a script, not interactively,
because the for loop is split over several lines without the IDL line continuation characters & and $.

When the ave command is issued, the contents of the accum buffer are cleared unless the ``noclear``
keyword is set. So, if you wish to view intermediate results in an ongoing average, you must specify that
the buffer should not be cleared:

.. code-block:: IDL

    sclear
    get, index=1
    accum
    get, index=2
    accum
    ave, /noclear           ; The accum buffer is NOT cleared here
    get, index=3
    accum
    ave                     ; The accum buffer IS cleared here

It is also possible to use the stack when averaging data by using the :idl:pro:`avgstack` command.
In the following example, the stack is used to identify records in the data file, and these are averaged.

.. code-block:: IDL

    addstack, 25            ; Add index 25 to stack
    addstack, 30, 39        ; Add indices 30 through 39 to stack
    avgstack                ; Average the stack (data in records 25, 30-39)

In the following example, we select some data associated with the “LL” polarization and average them.

.. code-block:: IDL

    emptystack                                                  ; Start with an empty list
    select,source=’W3OH’,scan=[177,178],pol=’LL’,cal=’F’
    tellstack
    liststack
    delete,4                                                    ; Remove record 4 from the list
    avgstack                                                    ; Average the three scans in the stack
    show


Averaging Data not Aligned in Frequency
=======================================

Suppose you wish to average spectra that overlap in frequency but are not exactly aligned. You must
use :idl:pro:`fshift` to determine the shift needed to align the spectra, apply that shift using 
:idl:pro:`gshift`, and then add the spectra to the accumulator and average. 

For example:

.. code-block:: IDL

    getps, 30
    accum                       ; Accumulate first spectrum, no alignment needed yet
    getps, 32
    fs = fshift()               ; Determine the shift to align scan 32 with the spectrum in
                                ; the accumulator
    gshift,fs                   ; Apply the shift to scan 32 in the PDC
    accum                       ; Add the result to the accumulator
    getps, 34
    gshift, fshift()            ; All in one line, shift 34 to align with the accumulator
    accum
    ave

It is also possible to align spectra on the basis of velocity using :idl:pro:`vshift`, or using
the current x-axis units using :idl:pro:`xshift`.


Smoothing Data
==============

GBTIDL provides users with 3 different smoothing options: boxcar, Gaussian, and hanning. In each
case it is possible to use ”decimation”, which means that every n-th channel will appear in the 
smoothed spectrum, n being determined by the smoothing parameters. Boxcar smoothing requires a 
parameter to specify the width of the boxcar. The :idl:pro:`gsmooth` feature convolves the data 
with a Gaussian of width :math:`\sqrt{newres^2 − origres^2}`, where newres is the new resolution
given by the user in units of channels. The hanning smooth uses a 3-channel hanning filter. 

Examples:

.. code-block:: IDL

    getps, 25                   ; Get some data into the PDC
    boxcar, 4                   ; 4-channel boxcar smooth, no decimation
    getps, 25                   ; Get some data into the PDC
    boxcar, 2, /decimate        ; 2-channel boxcar with decimation (keeps every other channel)
    getps, 25                   ; Get some data into the PDC
    gsmooth, 4, /decimate       ; Smooth to 4 channels & decimates (keeps every 4th channel)
    getrec, 1                   ; Get some data
    hanning                     ; Apply hanning smooth and show the result



Fitting Gaussian Profiles
=========================

The procedure :idl:pro:`fitgauss` is used to fit Gaussian profiles to spectral line data.
Since a Gaussian function approaches zero away from the line center, you get the best
results by subtracting a baseline from the data prior to using :idl:pro:`fitgauss`. In 
general the procedure for Gaussian fitting is as follows:

* Subtract a baseline from the spectrum of interest.
* Using the plotter, zoom in to a region near the lines to be fit.
* Run the fitgauss procedure
    * Mark the line to be fit using the left mouse button. Only the channels selected will 
      be included in the fitting algorithm. By selecting carefully, it is possible to have 
      the procedure ignore any nearby lines or even fit one among blended lines.
    * Using the middle mouse button, click first on the peak of the line to be fit, and 
      then middle-click again on the half-power point. These two clicks specify the initial
      guesses for line height, width, and center used by the Gaussian fitter. To fit multiple
      profiles simultaneously, continue to click the middle mouse button to mark additional
      lines.
    * When all lines have been marked, click the right mouse button to do the fit.

To retain the continuum level in a fit of absorption lines, the following recipe can be applied:
* Determine the continuum level of the source.
* Fit and subtract a baseline.
* Fit the absorption line with a Gaussian and save the model using the modelbuffer parameter.
* Add the continuum as a bias to both the data and the model.

For example, suppose we wish to fit an absorption line on a 1.5 Jy continuum source, and display the
fit as an overlay.

.. code-block:: IDL

    setregion                       ; Set the baseline region
    nfit, 3                         ; Plan to fit a 3rd order polynomial baseline
    baseline, modelbuffer=3         ; Fit and subtract the baseline. Continuum is also subtracted.
    fitgauss, modelbuffer=10        ; Fit the Gaussian and store the model in buffer 10
    bias, 1.5                       ; Add the continuum level back to the data
    copy, 0, 5                      ; Store the data in buffer 5
    copy, 10, 0                     ; Copy the model to buffer 0
    bias, 1.5                       ; Add the continuum level to the model
    copy, 0, 10                     ; Return the model to buffer 10
    copy, 5, 0                      ; Return the data to buffer 0
    oshow, 10, color=!orange        ; Overlay the model on the data


Flagging and Blanking Data
==========================

RFI and other faults that cause intermittent or frequency-dependent bad data make it necessary to be
selective when operating on a data set. Bad data can be addressed with a combination of flagging and
blanking. Flagging is the process of assigning a set of rules for marking bad data. Blanking is the
process of applying these rules to the data, and replacing the flagged data with a special blanking 
value. See :ref:`references/software/gbtidl/users_guide/data_analysis:More About Flagging Data` for more information.

The most common purpose of flagging and blanking is to identify data to be excluded from a calibration
or averaging operation. As such, flagging is usually applied to raw data and data that have not yet been
averaged.

In GBTIDL, the special value for blanked data is the IEEE not-a-number (NaN). Many native IDL
procedures already recognize that value and treat it appropriately. So, operations such as fitting and
averaging will ignore NaN values. As an example of the special handling of blanked values, consider
the :idl:pro:`show` command. It handles the special values by putting gaps in the plotted spectrum at the
locations of blanked data. The :idl:pro:`stats` procedure simply ignores any blanked channels in computing
the statistics. The :idl:pro:`hanning` procedure blanks channels in the smoothed spectrum whose constituent
channels are themselves blanked. In general, procedures know how to take the appropriate action when
they encounter blanked data, and this action varies depending on the procedure.

Blanking is automatically applied to data when it is read into memory using the calibration or I/O
procedures such as :idl:pro:`get`, :idl:pro:`getfs`, :idl:pro:`getps`, etc. Blanking can also be
applied by using the :idl:pro:`replace` command.

As an example, suppose you have a spectrum displayed in the plotter and you would like to blank bad
data in channels 500 to 525. The following command will perform the task.

.. code-block:: IDL

    replace, 500, 525, /blank ; Blanks the range of channels from 500 to 525

Flagging is different from blanking in that flagging does not change the data in a data container. Instead,
flagging commands are associated with data on disk, and describe which of those data should be blanked
when it is read with the GBTIDL I/O routines. The flagging commands are stored in a separate file
from the data file, so you can unflag data or selectively ignore or apply certain flagging rules without
changing the data on the disk or in memory.

Examples of setting flag rules, changing flag rules, and blanking data:

You know your data are bad in channels 500 to 525 and 1000 to 1100 for scan 11 but just in
plnum=1 and ifnum=2. However, the data in the two channel ranges are bad for different
reasons. The flags would be set and the data blanked like this:

.. code-block:: IDL

    flag, 11, plnum=1, ifnum=2, chans="500:525", idstring="rfi"             ; Flag and label "rfi"
    flag, 11, plnum=1, ifnum=2, chans="1000:1100", idstring="acs_glitch"    ; Flag and label "acs_glitch"

    getfs, 11, plnum=1, ifnum=2                                             ; Flagged data are now blanked in the PDC

Notice the use of ``idstring`` to document the reason a particular flag is being used.

If you have set up flagging rules but wish to ignore them when reading the data, the following
command will retrieve the data without blanking:

.. code-block:: IDL

    getfs, 11, plnum=1, ifnum=2, /skipflag                      ; No flags are applied

If you want to flag the first integration of a range of scans because you suspect the telescope
was still settling and not on target:

.. code-block:: IDL

    flag, scanrange=[6,10], intnum=0, idstring="first int"      ; Flags integration 0 of scans 6-10

To view all the flag rules that have been set, use the :idl:pro:`listflags` command:

.. code-block:: IDL

    listflags               ; Produces a list of all the flag rules established

To remove a flag rule, use the :idl:pro:`unflag` command. This works by either providing the ``idstring``
attached to a flag or an integer matching an ID number as shown by :idl:pro:`listflags`:

.. code-block:: IDL

    unflag, "first int"     ; Unflags the rule with the id string "first int"



More about Flagging Data
------------------------

This section provides more information and examples about flagging.
When data requires flagging, an iterative approach to reduction is often useful. 
Here is one approach:

1. Calibrate the raw data.
2. Examine the calibrated data and determine whether any flagging is required to
   improve calibration.
3. If necessary, flag the offending data and return to step 1.
4. Write a new SDFITS file with calibrated data. In general, the new SDFITS file
   should contain an entry for each integration that will be considered as a 
   candidate for the average.
5. When all data are calibrated and written to disk, specify the calibrated data
   file as the new source of input.
6. Again examine the data and use the flagging procedures to mark residual bad
   data to exclude from the average.
7. Average the data.
8. Examine the average and, if necessary, return to step 1 or step 5 and modify 
   the flagging commands as necessary.
9. Proceed with analysis of the averaged spectrum.

Because of the iterative nature of the process, it is common to set and then unset 
flagging commands for a given data set. It is important to emphasize that *blanked
data are not recoverable* without going back to data retrieval, but *flagged data 
are recoverable*. Flagging (setting flag rules) allows you to iteratively decide
which data should be blanked during processing.

Data can be flagged either by specifying scan number, integration number, 
polarization number, IF number, feed number, and channel number, or by specifying 
the record number (location within a file) and channel number. It is permissible to
mix these two methods in a single flag file, if desired. The data I/O system in
GBTIDL applies the flags, blanking data as appropriate (some control over which 
flags are applied is possible, as described later in this document). Averaging, 
analysis, and display procedures in GBTIDL take the appropriate action when blanked
data are encountered.

Flagging is intended mainly for uncalibrated and pre-averaged data. However, it is 
not forbidden to flag calibrated, averaged data. Use caution in such cases because
the header parameters used in the parametrization of flags can be changed during 
averaging operations. For this reason, when flagging averaged data it is generally
best to flag by record number. Flagging by record number also offers a finer level 
of detail. The select procedure can be useful in conjunction with flagging by record 
number when the normal flag procedure isn’t sufficient (this is described in more 
detail later in this section). In the iterative flagging scheme outlined earlier in
this section, flagging in Step 3 should be parametrized by scan, polarization, etc. 
while flagging in step 6 should be parametrized by record number.

Using Flags in GBTIDL
^^^^^^^^^^^^^^^^^^^^^

Flag rules (flags) can be set from the command line with the procedures :idl:pro:`flag`
and :idl:pro:`flagrec`. These procedures generate entries in the flag file associated 
with the current SDFITS file. The flag procedure has the following syntax:

.. code-block:: IDL

    flag, scan, intnum=intnum, plnum=plnum, ifnum=ifnum, fdnum=fdnum,
        sampler=sampler, bchan=bchan, echan=echan, chans=chans,
        chanwidth=chanwidth, idstring=idstring, scanrange=scanrange, /keep

and the flagrec procedure has the following syntax:

.. code-block:: IDL

    flagrec, record, bchan=bchan, echan=echan, chans=chans, chanwidth=chanwidth,
        idstring=idstring, /keep

One uses ``idstring`` to associate with a rule an identifying string that is typically
a reminder of the reason for the flag.

Examples:

The following example shows how to flag a channel range for a small number of scans and
integrations. Note that either the scan parameter or scanrange keyword is required but
both can not be used at the same time. For the other parameters, if they are not specified,
“all” is assumed. So in the first example, all polarizations are flagged. Also, notice that
the integration numbers specified are 1 AND 3, not 1 through 3. To select a range, use
intnum=[1,2,3] or intnum=seq(1,3) (the first example specifies all of the integrations to be
flagged as integers, the second generates that sequence of integers using the ”seq” function).

.. code-block:: IDL

    flag, [18,19,20], intnum=[1,3], bchan=512, echan=514, idstring="RFI"

Equivalently, using the scanrange keyword:

.. code-block:: IDL

    flag, scanrange=[18,20], intnum=[1,3], bchan=512, echan=514, idstring="RFI"

To flag all channels for a given integration in one scan:

.. code-block:: IDL

    flag, 15, intnum=3, idstring="spectrometer glitch"

To flag all data for the given three scans:

.. code-block:: IDL

    flag, [101,105,107]

To flag a record in a processed data file (a keep file):

.. code-block:: IDL

    flagrec, 15, idstring="Glitch", /keep

To flag two channel ranges in a given scan you could do this:

.. code-block:: IDL

    flagrec, 16, bchan=0, echan=10, idstring="Two RFI Spikes"
    flagrec, 16, bchan=100, echan=110, idstring="Two RFI Spikes"

or abbrieviate it like this:

.. code-block:: IDL

    flagrec, 16, bchan=[0,100], echan=[10,110], idstring="Two RFI Spikes"

The next example flags uses chans and chanwidth to flag the same channels:

.. code-block:: IDL

    flagrec, 16, chans=[5,105], chanwidth=11, idstring="Two RFI Spikes"

The select procedure can be used along with flagrec to provide even more flexible flagging.
In this example, the “RR” polarization of IF number 3 for all data with the source name
“Orion” is flagged in channels 500 to 520:

.. code-block:: IDL

    emptystack                                                          ; Clear the stack first
    select, source=’Orion’, polarization=’RR’, ifnum=3                  ; Populate the stack
    flagrec, astack(), bchan=500, echan=520, idstring=’RFI-Orion’

.. note:: 

   There may be more than one flag associated with a given ``idstring``. If ``idstring``
   is not specified in the :idl:pro:`flag` or :idl:pro:`flagrec` calls, it defaults to the
   string “unspecified”.



Using Flags in Data Retrieval and Averaging Procedures
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Flags are applied by the data I/O subsystem when data are retrieved from disk. All of the data retrieval
procedures in GBTIDL (including calibration procedures such as :idl:pro:`getnod` and :idl:pro:`getfs`
that do data retrieval as part of their operation) use the I/O subsystem, so flags are applied whenever 
you get data from disk. 

All of these procedures allow you to fine tune which flag rules are actually applied via the ``useflag``
and ``skipflag`` keywords. The default is to use ``/useflag``, meaning that all flag rules are applied.
You can turn off all flagging by using ``/skipflag``. In that case, no data will be blanked by the data 
retrieval process. You can also apply or not apply some of the flags by referring to them by their 
``idstring``. You can not use both the ``useflag`` and ``skipflag`` keywords in the same call. Unlike 
:idl:pro:`unflag`, the data retrieval commands do not allow you to skip or use flags based on their ID
number - only the ``idstring`` can be used as an argument to these keywords.

Examples:

.. code-block:: IDL

    getnod, 15                                  ; Apply all flags
    getnod, 15, /skipflag                       ; Do not use any flags
    getnod, 15, useflag="RFI"                   ; Only use the "RFI" flag
    getnod, 15, useflag=["RFI","wind"]          ; Use "RFI" and "wind" flags only
    getnod, 15, skipflag="RFI"                  ; Use all flags EXCEPT "RFI"

All of the standard procedures in GBTIDL that in turn use these procedures also have the ``useflag``
and ``skipflag`` keywords.

Listing Flags
^^^^^^^^^^^^^

Use :idl:pro:`listflags` to list all of the flags for the current data file, or only those 
flags having a specific ``idstring``. The default :idl:pro:`listflags` output shows all flags
in their entirety, but the format sometimes is difficult to read. Appending the ``/summary``
keyword to :idl:pro:`listflags` aligns the columns but in order to do that, it may truncate
the information in a particular column and so not all information may be shown.

Examples:

.. code-block:: IDL

   listflags, ’RFI’            ; Shows the flag information associated with the ’RFI’ idstring
   listflags, /summary         ; Shows all flags with the information aligned by column

To list all of the unique idstring values in the flag file use the listids command.
Example flag lists:

If one executes the flagging command:

.. code-block:: IDL

    flag, [35,36,37], intnum=[1,3], bchan=512, echan=514, idstring="RFI"

the listflags output will look like this:

.. code-block:: text

    #ID, RECNUM, SCAN, INTNUM, PLNUM, IFNUM, FDNUM, BCHAN, ECHAN, IDSTRING
    0 * 35:37 1,3 * * * 512 514 RFI

The first line of the output identifies the contents of each column. Most of these fields are
self-explanatory. The first field is an ID number that is assigned dynamically and is simply
the location of that flag rule in this list. The ID number can be used in the ::idl:pro:`unflag`
procedure to remove a flag rule. 

Flagging a few more scans, not in a nice sequence:

.. code-block:: IDL

    flag, [40,42,44,47,48,50,56], intnum=[1,3], bchan=512, echan=514, idstring="More RFI"

adds one new line to the listflags output:

.. code-block:: text

    #ID, RECNUM, SCAN, INTNUM, PLNUM, IFNUM, FDNUM, BCHAN, ECHAN, IDSTRING
    0 * 35:37 1,3 * * * 512 514 RFI
    1 * 40,42,44,47,48,50,56 1,3 * * * 512 514 More RFI

And :code:`listflags, /summary` truncates the output and produces the following:

.. code-block:: text

    #ID, RECNUM, SCAN, INTNUM, PLNUM, IFNUM, FDNUM, BCHAN, ECHAN, IDSTRING
    0 * 35:37 1,3 * * * 512 514 RFI
    1 * 40,42,44,+ 1,3 * * * 512 514 More RFI

Notice how the scan information is truncated. Fields that contain more information than
shown end in a plus sign, while asterisks indicate all values for that parameter are flagged
(as in the unformatted :idl:pro:`listflags` output).

The second column, RECNUM, is set when :idl:pro:`flagrec` is used. For example:

.. code-block:: IDL

    flagrec, 15, bchan=0, echan=8, idstring="bad channels"
    listflags

    #ID, RECNUM, SCAN, INTNUM, PLNUM, IFNUM, FDNUM, BCHAN, ECHAN, IDSTRING
    0 * 35:37 1,3 * * * 512 514 RFI
    1 * 40,42,44,47,48,50,56 1,3 * * * 512 514 More RFI
    2 15 * * * * * 0 8 bad channels


Undoing Flags
^^^^^^^^^^^^^

If you would like to remove all the flags associated with a given SDFITS file, you can simply remove the
associated flag file and restart GBTIDL. Alternatively, flags can be unset using the :idl:pro:`unflag`
procedure. The :idl:pro:`unflag` procedure takes a single parameter, ``id``, and it removes all flagging
commands that have that ``id``, where ``id`` can either be a string matching an ``idstring`` value or an
integer matching an ID number as shown by :idl:pro:`listflags`.

.. code-block:: IDL

    unflag, id

If you want to re-flag that same data, you have to reissue the :idl:pro:`flag` or :idl:pro:`flagrec`
commands. The ``id`` parameter can be either a scalar or an array, to unflag multiple entries at once.

Unflagging by ID number is simple and appealing but users should be familiar with the following very
important feature. Since the ID number is generated dynamically, it changes after each flagging-related
command, including the :idl:pro:`unflag` command. Users should always use :idl:pro:`listflags` before
each use of :idl:pro:`unflag` to be sure that they are using the appropriate ID value. Consider this
example:

.. code-block:: IDL

    listflags

    #ID, RECNUM, SCAN, INTNUM, PLNUM, IFNUM, FDNUM, BCHAN, ECHAN, IDSTRING
    0 * 35:37 1,3 * * * 512 514 RFI
    1 * 40,42,44,47,48,50,56 1,3 * * * 512 514 More RFI
    2 15 * * * * * 0 8 bad channels

If you want to unflag the last 2 IDs, so you might (mistakenly) try the following:

.. code-block:: IDL

    unflag, 1
    unflag, 2
    % FLAGS::UNFLAG_ID: ID could not be found to unflag: 2

The error happens because the first unflag causes the remaining two flag rules to be renumbered to 0
and 1, and so there is no ID 2 to unflag any more. This would have been a more dangerous, silent error
had there been more than 3 rules to begin with.
The correct way to unflag the entries:

.. code-block:: IDL

    listflags
    unflag, 1
    listflags
    unflag, 1

or:

.. code-block:: IDL

    listflags
    unflag, [1,2]


Weighting Issues not Addressed by this Flagging Scheme
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You should be aware of some potential issues with the weights when averaging flagged data.

Consider two reduced spectra, A and B, which resulted from an average of flagged data. In each of the
two spectra, the individual channels have been flagged to different extents, so the final noise in each
channel differs depending on how much of the raw data were flagged going into the average. For example,
channels 0-10 in A may have been heavily flagged prior to averaging, and so they contain a higher noise
than the other channels in A. If the observer then wishes to average A and B, the weighting in the average
will be wrong because relative weights have not been stored for these spectra on a channel-per-channel
basis.    


Statistics
==========

Statistics are available from the :idl:pro:`stats` procedure. If :idl:pro:`stats` is given
no parameters, you must specify the range over which statistics are calculated using the
mouse cursor. Otherwise, :idl:pro:`stats` can take two parameters, indicating the begin
and end values for the range, in units currently displayed on the plotter. The ``/chan``
keyword can be used if you want to give the range in channels regardless of the current plotter
units. For example:

.. code-block:: IDL

    getrec, 1 ; Get some data
    stats ; Prompt user for the range using the mouse
    stats, 1420.0,1420.1 ; Show stats over the specified range
    stats, /full ; Show stats over the full spectrum
    stats, /full, ret=mystats ; Return statistics to the IDL data structure called mystats
    print, mystats.mean ; Prints the mean value stored in the mystats data structure
    print, mystats.rms ; Prints the rms value stored in the mystats data structure
    stats, 0, 99, /chan ; Show stats for the first 100 channels

Here is an example of the output of the stats command:

.. code-block:: IDL

    GBTIDL -> stats
    Click twice to define stats region
        Chans   bchan   echan        Xmin      Xmax         Ymin           Ymax
        13661   10692   24352      1.6103    1.6155      -4.0177         14.259

                         Mean      Median       RMS     Variance           Area
                     -0.14350   -0.051825   0.55484      0.30785    -0.00074783


Using the Select and Find Features
==================================

Select
------

The :idl:pro:`select` procedure in GBTIDL is used to search and select records from
the input data set and add indices of the matching entries to the stack. To locate
the relevant records, :idl:pro:`select` uses the contents of the GBTIDL index file.
The parameters for the :idl:pro:`search` procedure are the same as those for the 
:idl:pro:`get` procedure (see :ref:`references/software/gbtidl/users_guide/data_calibration:Retrieving Individual Records`). The procedure 
:idl:pro:`listcols` can be used to list all parameters available for searching. Note
that in this procedure, like all IDL procedures, the parameter names do not need to be
typed in their entirety, only enough characters to uniquely identify the parameter 
are necessary.

To select all records associated with a given source name:

.. code-block:: IDL

    select, source=’3C286’

Multiple parameters are combined with a logical AND, so the following command selects
all 3C286 records between scans 100 and 119:

.. code-block:: IDL

    select, source=’3C286’, scan=seq(100:119)

To select specific integer values, use an array as follows:

.. code-block:: IDL

    select, source=’3C286’, scan=[100,102,104,106]

The syntax for selections depends on the data type that is being selected, as shown
in the following examples.

Integer Searches

.. code-block:: IDL

    select, index=10                        ; Selects one index
    select, index=[10,14,17,18]             ; Selects a list of indices
    select, index=’10:15,20:23’             ; Selects the given ranges
    select, index=’:30’                     ; Selects indices less than 30
    
Float Searches

.. code-block:: IDL

    select, tsys=’33.26’                    ; Selects values between 33.255 and 33.265
    select, tsys=’33.0:38.0’                ; Selects the range 33-38 K
    select, tsys=’:45.0’                    ; Selects based on Tsys < 45.0K
    select, tsys=33.26                      ; Selects values that are exactly 33.26, rarely useful

String Searches

.. code-block:: IDL

    select, source=’NGC1068’                ; Select based on single string value
    select, source=[’NGC1068’, ’NGC1069’]   ; Select from a list of strings
    select, source=’NGC*’                   ; Wildcards allowed at beginning and end of string


Find
----

The :idl:pro:`find` procedure and the related procedures :idl:pro:`setfind`, :idl:pro:`clearfind`,
and :idl:pro:`listfind` (each described below) use :idl:pro:`select` in a way that has been designed
to mimic some of the features of the CLASS :idl:pro:`find` command. The :idl:pro:`find` command is
particularly useful if you want to repeat the same or slightly modified selection. Each use of 
:idl:pro:`find` first clears the stack (unlike select) unless the ``/append`` keyword is used.

* :idl:pro:`setfind`: Used to set specific selection criteria. Once set, they remain set until cleared
  using clearfind.
* :idl:pro:`find`: Used to place the entries specified by the :idl:pro:`setfind` command into the stack.
* :idl:pro:`clearfind`: Used to clear the current setfind selection criteria.
* :idl:pro:`listfind`: Used to list a specified selection parameter or all selection parameter values 
  used by :idl:pro:`find`. This allows you to tell the value of one or all of the selection parameters 
  used by :idl:pro:`find`.

Examples:

First define the initial selection criteria:

.. code-block:: IDL

    GBTIDL -> setfind, ’scan’, 80, 82           ; Select scans 80 through 82
    GBTIDL -> find                              ; Add the selection to the stack (See 8.1)
        Indices added to stack : 288
    GBTIDL -> listfind                          ; Show current selection parameters
        All set FIND parameters for LINE mode
        SCAN 80:82

Then refine them:

.. code-block:: IDL

    GBTIDL -> setfind, ’polarization’, ’XX’     ; Select only the XX polarization
    GBTIDL -> find                              ; Update the stack so it only contains scans 80-82 with
        Indices added to stack : 144
    GBTIDL -> listfind ; Show current selection parameters
        All set FIND parameters for LINE mode
        SCAN 80:82
        POLARIZATION XX

Refine them again:

.. code-block:: IDL

    GBTIDL -> setfind, ’int’, 3                 ; Select only integration 3
    GBTIDL -> find                              ; Update stack to only contain indices that satisfy all
        Indices added to stack : 24
    GBTIDL -> listfind                          ; Show current selection parameters
        All set FIND parameters for LINE mode
        SCAN 80:82
        POLARIZATION XX
        INT 3

Change your mind and decide to include integration 4 also:

.. code-block:: IDL

    GBTIDL -> setfind, ’int’, 4, /append        ; Use the /append keyword to add data
    GBTIDL -> find                              ; Add the 4th integration indices to stack
        Indices added to stack : 48
    GBTIDL -> listfind                          ; Show new selection parameters
        All set FIND parameters for LINE mode
        SCAN 80:82
        POLARIZATION XX
        INT 3,4


Mapping
=======

GBTIDL does not support mapping. There is a mechanism for exporting SDFITS data into
classic AIPS. Contact your GBT support person for details.


Other Analysis Procedures
=========================

The following table lists additional analysis commands that may be useful. 

.. list-table:: Additional analysis commands
    :widths: 10 20
    :header-rows: 1

    * - Procedure
      - Action
    * - :idl:pro:`clip`, :idl:pro:`datamin`, :idl:pro:`datamax` 
      - Truncate spectrum to a min and max data value
    * - :idl:pro:`decimate`
      - Decimate the spectrum by paring channels
    * - :idl:pro:`gconvol` 
      - Convolve the spectrum in the PDC with an array
    * - :idl:pro:`gfft` 
      - FFT or inverse FFT the spectrum
    * - :idl:pro:`ginterp`
      - Interpolate across blanked channels
    * - :idl:pro:`gmeasure`
      - HI profile fitting procedure
    * - :idl:pro:`gmoment`
      - Caclulate first 3 moments
    * - :idl:pro:`invert`
      - Flip the data end-to-end
    * - :idl:pro:`molecule`
      - Show molecular transition frequencies on the plotter
    * - :idl:pro:`powspec`
      - Compute power spectrum
    * - :idl:pro:`recomball` 
      - Plot the H alpha, beta, gamma; He alpha, beta, and C alpha recombination lines
    * - :idl:pro:`recombc`
      - Compute and plot frequencies of Carbon recombination lines
    * - :idl:pro:`recombhe`
      - Compute and plot frequencies of Helium recombination lines
    * - :idl:pro:`recombh` 
      - Compute and plot frequencies of Hydrogen recombination lines
    * - :idl:pro:`recombn`
      - Compute and plot frequencies of Nitrogen recombination lines
    * - :idl:pro:`recombo`
      - Compute and plot frequencies of Oxygen recombination lines
    * - :idl:pro:`replace`
      - Replace bad data values
    * - :idl:pro:`resample`
      - Resample the spectrum in the PDC at the new interval
