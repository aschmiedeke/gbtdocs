Scan Types and other functions - Overview
-----------------------------------------



A scan is a pattern of antenna motions that when used together yield a useful scientific dataset. This section describes the various scan types that are available for use within GBT SBs. Each scan type consists of one or more scan, which are the individual components of the antenna's motion on the sky. The scan types listed below are the functions within your SB where data will be obtained with the GBT.

Please note that the syntax for all scan types is case-sensitive.




Utility Scan Types
^^^^^^^^^^^^^^^^^^

Utility Scans generally describe procedures that are used to calibrate some aspect of the system such as pointing, focus, or power levels. Nearly every observing session will require the use of one or more of the utility scans. 

.. note:: 

   AutoPeakFocus, AutoPeak, AutoFocus, and AutoOOF automatically execute their own default continuum configurations unless ``configure=False`` has been supplied as an optional argument (only recommended for expert users). After running one of these **Auto\*** procedures, you will need to reconfigure for your science observations.

.. list-table:: GBT Utility Scans
    :widths: 25 25 50
    :header-rows: 1

    * - Scan Type
      - Observing Type
      - Description
    * - :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>`
      - Continuum
      - Selects and observes a nearby calibration source and updates the pointing and focus corrections.
    * - :func:`AutoPeak() <astrid_commands.AutoPeak>`
      - Continuum
      - Selects and observes a nearby calibration source and updates the pointing corrections. 
    * - :func:`AutoFocus() <astrid_commands.AutoFocus>`
      - Continuum
      - Selects and observes a nearby calibration source and updates the focus corrections.
    * - :func:`AutoOOF() <astrid_commands.AutoOOF>`
      - Continuum
      - Selects and observes a nearby calibration source with different focus settings to create an out-of-focus holography map to update the surface corrections.
    * - :func:`Focus() <astrid_commands.Focus>`
      - Continuum
      - Performs a focus observation.
    * - :func:`Peak() <astrid_commands.Peak>`
      - Continuum, Line
      - Performs a pointing observation.
    * - :func:`Tip() <astrid_commands.Tip>`
      - Continuum, Line
      - Performs an observation to derive :math:`T_{sys}` vs. elevation.
    * - :func:`Slew() <astrid_commands.Slew>`
      - Continuum, Line, Pulsar
      - Slews the telescope to the specified source or location.
    * - :func:`Balance() <astrid_commands.Balance>`
      - Continuum, Line, Pulsar
      - Balances the IF system so that each device is operating in its linear response regime.
    * - :func:`BalanceOnOff() <astrid_commands.BalanceOnOff>`
      - Continuum, Line, Pulsar
      - Move from a source to a reference position and balance the IF system at the mid-point of the two power levels. 




Observing Scan Types
^^^^^^^^^^^^^^^^^^^^
Observing scan types will aquire scientific datasets by performing one or more scans at specific locations on the sky. 

.. list-table:: GBT Observing Scans
    :widths: 25 25 50
    :header-rows: 1

    * - Scan Type
      - Observing Type
      - Description
    * - :func:`Track() <astrid_commands.Track>`
      - Continuum, Line, Pulsar
      - Takes data at a single position or while moving with constant velocity
    * - :func:`OnOff() <astrid_commands.OnOff>`
      - Continuum, Line
      - Observe a source and then a reference position
    * - :func:`OffOn() <astrid_commands.OffOn>`
      - Continuum, Line
      - Observe a reference position and then a source
    * - :func:`OnOffSameHA() <astrid_commands.OnOffSameHA>`
      - Continuum, Line
      - Observe a source and then a reference position using the same hour angle as the sourcec in the observation.
    * - :func:`Nod() <astrid_commands.Nod>`
      - Continnum, Line
      - Observe a source with one beam and then with another beam
    * - :func:`SubBeamNod() <astrid_commands.SubBeamNod>`
      - Continuum, Line
      - Moves the subreflector alternately between two beams    



Mapping Scan Types
^^^^^^^^^^^^^^^^^^

Mapping scan types will record data over specified areas of the sky. 

Most GBT mapping procedures have versions that allow for periodic reference observations. 
These may be used to correct for the instrumental bandpass shape in total power observations
during data reduction. For OTF mapping, some observers may prefer to use the edge pixels of 
the map as a reference position if they are suitably "off-source".

.. note:: 

   The `GBT mapping calculator <https://www.gb.nrao.edu/~rmaddale/GBT/GBTMappingCalculator.html>`__
   is a useful tool for planning mapping observations It may be used to provide AstrID commands
   and parameters for many of the mapping scan types. 

.. important:: 

   An important restriction on mapping with the GBT is that the raster scan legs or petal lengths
   should be at least 30 s so that the telescope only turns around a maximum of twice per minute.
   This helps to minimize stresses on the telescope.


.. list-table:: GBT mapping scans
    :widths: 25 25 50
    :header-rows: 1

    * - Scan Type
      - Observing Type
      - Description
    * - :func:`RALongMap() <astrid_commands.RALongMap>`
      - Continuum, Line
      - Make an OTF raster map by moving along the major axis of the coordinate system.
    * - :func:`RALongMapWithReference() <astrid_commands.RALongMapWithReference>`
      - Continuum, Line
      - Make an OTF raster map by moving along the major axis of the coordinate system and making periodic reference observations.
    * - :func:`DecLatMap() <astrid_commands.DecLatMap>`
      - Continuum, Line
      - Make an OTF raster map by moving along the minor axis of the coordinate system. 
    * - :func:`DecLatMapWithReference() <astrid_commands.DecLatMapWithReference>`
      - Continuum, Line
      - Make an OTF raster map by moving along the minor axis of the coordinate system and making periodic reference observations. 
    * - :func:`PointMap() <astrid_commands.PointMap>`
      - Continuum, Line, Pulsar
      - Make a map using individual pointings.
    * - :func:`PointMapWithReference() <astrid_commands.PointMapWithReference>`
      - Continuum, Line, Pulsar
      - Make a map using individual pointings with periodic reference observations.
    * - :func:`Daisy() <astrid_commands.Daisy>`
      - Continuum, Line
      - Make an OTF map in the form of daisy petals.



Utility functions
^^^^^^^^^^^^^^^^^

Utility functions are used in SBs to control various aspects of the GBT other than data-taking scans. This includes such things as changing power levels, pausing the SB or waiting for a source to rise. 

.. list-table:: GBT utility functions
    :widths: 25 75
    :header-rows: 1

    * - Utility Function
      - Description
    * - :func:`Annotation() <astrid_commands.Annotation>`
      - 
    * - :func:`Break() <astrid_commands.Break>`
      - 
    * - :func:`Comment() <astrid_commands.Comment>`
      - 
    * - :func:`GetLST() <astrid_commands.GetLST>`
      - 
    * - :func:`GetUTC() <astrid_commands.GetUTC>`
      - 
    * - :func:`Now() <astrid_commands.Now>`
      - 
    * - :func:`WaitFor() <astrid_commands.WaitFor>`
      - 
    * - :func:`ChangeAttenuation() <astrid_commands.ChangeAttenuation>`
      - 


Scheduling Block Objects
^^^^^^^^^^^^^^^^^^^^^^^^

Scheduling Block Objects are python objects that are used to contain multiple pieces of information within a single variable. These are used with positions, times, and for defining a horizon for the minimum elevation below which you would not want to observe.

.. list-table:: GBT Scheduling Block Objects
    :widths: 25 75
    :header-rows: 1

    * - SB object
      - Description
    * - :func:`Location Object <astrid_commands.Location>`
      - 
    * - :func:`Offset Object <astrid_commands.Offset>`
      - 
    * - :func:`Horizon Object <astrid_commands.Horizon>`
      - 
    * - :func:`Time Object <astrid_commands.Time>`
      - 

