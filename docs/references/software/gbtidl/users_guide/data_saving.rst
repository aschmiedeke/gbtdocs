##########################
Saving and Retrieving Data
##########################

To save data to disk, first specify the name of the output data file using the 
:idl:pro:`fileout` command. The default file is called “GBTIDL keep.fits”. The
name of the data file must end in “.fits”. Spectra can be written to this file 
using either the :idl:pro:`keep` or :idl:pro:`nsave` command.

keep
====

The :idl:pro:`keep` command saves a spectrum to the output file, appending the data 
to the end of that file. For example:

.. code-block:: IDL

    getnod,30                   ; Get some data
    fileout,’mysave.fits’       ; Open an output file
    keep                        ; Writes the PDC to the file
    getnod,32                   ; Get some more data
    keep                        ; Write the PDC to file
    getfs,48,/nofold            ; Get some more data
    keep                        ; Writes the PDC to file
    keep,5                      ; Writes info in DC 5 to file


nsave
=====

The :idl:pro:`nsave` feature allows you to store data in a file and attach an identifing number
(the nsave value) to that entry so that the data can be overwritten or retrieved according to 
the nsave value. The utility essentially gives you access to an unlimited number of storage 
slots on disk, somewhat like the 16 global buffers kept in memory.

The following GBTIDL procedures are relevant to the nsave features.

.. list-table:: GBTIDL procedures relevant to the nsave features
    :widths: 10 20
    :header-rows: 1

    * - Command
      - Purpose
    * - fileout
      - Set the output file; note this can be used for both keep and nsave
    * - nget 
      - Retrieve a spectrum with a given nsave value
    * - nsave
      - Store a spectrum to disk with the given nsave value
    * - sprotect_off
      - Enable overwrite permission
    * - sprotect_on
      - Disable overwrite permission

The following sequence shows how to store and retrieve a spectrum using the nsave feature:

.. code-block:: IDL

    fileout, ’mynsave.fits’     ; Open a file for writing
    getrec, 10                  ; Get some data
    nsave, 101                  ; Store it to the keep file
    scale, 5                    ; Perform some operations
    nsave, 102                  ; Store it with a different nsave value
    nget, 101                   ; Retrieve the spectrum at nsave=101

The next example shows a more sophisticated ``nsave`` example. Here each nsave entry stores a calibrated
integration from a scan. The example demonstrates how the ``nsave`` values can be overwritten and each
``nsave`` entry has an attached meaning to the data, for example nsave=1002 is the data associated with
scan=100, int=2. As the calibration of this integration is refined, the spectra are simply stored back
into that ``nsave`` slot.

.. code-block:: IDL

    fileout, ’mynsave.fits’         ; Open a file for writing
    for i=0,5 do begin $            ; Store each integration
        getnod, 100, int=i & $
        nsave, 1000+i & $
    endfor

    nget, 1002                      ; Retrieve one of the entries
    bias, 0.1                       ; Do some work on it
    nsave, 1002                     ; And reinsert it into the file

    for i=0,5 do begin $            ; Now execute a loop to average all
        nget, 1000+i & $            ; the data including the processed
        accum & $                   ; integration. This loop could be
    endfor                          ; made into a separate procedure.
    ave


Retrieving Data from the Output File
====================================

To retrieve data saved using GBTIDL, it is possible to open the file as an input file and use 
the :idl:pro:`get` and :idl:pro:`getrec` commands. The following example illustrates.

.. code-block:: IDL

    getnod, 101                 ; Get a spectrum from a previously defined input file
    fileout, ’mydata.fits’      ; Set the output file name
    keep                        ; Store the spectrum in record 0 of the keep file
    getnod, 103                 ; Get more data
    keep                        ; Store the next spectrum in record 1
    fileout, ’KEEP.fits’        ; Close mydata.fits and open a new output file
    filein, ’mydata.fits’       ; Reopen mydata.fits it as an input file
    getrec, 0                   ; Retrieve the first entry

Alternatively, data can be retrieved directly from the output file using kgetrec or kget.

.. code-block:: IDL

    getnod, 101                 ; Get a spectrum from a previously defined input file
    fileout, ’mydata.fits’      ; Set the output file name
    keep                        ; Store the spectrum in record 0 of the keep file
    getnod, 103                 ; Get more data
    keep                        ; Store the next spectrum in record 1
    kget, scan=101              ; Retrieves scan 101 from the output data file and places it in the PDC

The :idl:pro:`kget` command uses the same selection parameters as the :idl:pro:`get` procedure.
