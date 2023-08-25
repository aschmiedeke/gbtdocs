Scheduling Block Commands
----------------------------

:func:`DecLatMap() <astrid_commands.DecLatMap>`


.. automodule:: astrid_commands
    :members:

.. autofunction:: astrid_commands.Peak



.. There are more procedures in the directory:
   CalSeq()
   CalSeqTrack()
   CircleTrack()
   DaisyWithDither()
   LSFS()
   DefineProcedure()
   OOFAnalysisProcedure()
   Procedure()
   ProcessScript()
   RosePetal()
   RuntimeScan()
   RunVLBI()
   Scheduler()
   Spider()
   TrajectoryFromFile()
   TrajectoryMap()
   TurtleState()
   Validator()
   VaneCal()
   VaneCalTrack()
   Z17()




.. _Annotation():

Annotation()
^^^^^^^^^^^^^




.. _AutoFocus():

AutoFocus()
^^^^^^^^^^^^^




.. _AutoOOF():


AutoOOF()
^^^^^^^^^^^^^




.. _AutoPeak():


AutoPeak()
^^^^^^^^^^^^^


Same as `AutoPeakFocus()`_ except that is does not perform a focus scan.

DO NOT USE WITH PRIME FOCUS RECEIVERS!


::

    AutoPeak(
        source=None, 
        location,
        frequency=<see description below>,
        flux,
        radius=10,
        balance=True,
        configure=True,
        beamName,
        refBeam,
        elAzOrder=False,
        calSeq=True
        gold
        ):

* Parameter descriptions and examples: See `AutoPeakFocus()`_.



.. _AutoPeakFocus():


AutoPeakFocus()
^^^^^^^^^^^^^^^^

Automatically point and focus the antenna for the current location on the sky with the current receiver. It should not require any user input. However, by setting any of the optional arguments, the user may partially or fully override the search and/or procedural steps as described below.

DO NOT USE WITH PRIME FOCUS RECEIVERS!

::

    AutoPeakFocus(
        source=None, 
        location,
        frequency=<see description below>,
        flux,
        radius=10,
        balance=True,
        configure=True,
        beamName,
        refBeam,
        elAzOrder=False,
        calSeq=True
        gold
        ):

All parameters are optional!

``source``: str
    specifies the name of a particular source in the pointing catalog or in a user-defined catalog. Specifying a source bypasses the search process. Please note that NVSS source names are used in the pointing catalog. If the name is not located in the pointing catalog then all the user-specified catalogs previously defined in the Scheduling Block are searched. If the name is not in the pointing catalog or in the user defined catalog(s) then the procedure fails.

``location``
    Catalog source name or Location object. Specified the center of the search radius. The default is the antenna's current beam location on the sky. Planets and other moving objects may not be used.

``frequency``: float
    specifies the observing frequency in MHz. Default is the rest frequency used by the standard continuum configurations, or the current configuration value, if ``configure=False``.
    
    
``flux``: float
    specifies the minimum acceptable calibration flux in Jy at the observing frequency. Default is 20 times the continuum point-source sensitivity.

``radius``: float
    selects the closest calibrator within the radius (in degrees) having the minimum acceptable flux. If no calibrator is found within the radius, the search is continued out to 180 degrees and if a qualified calibrator is found, the user is given the option to using it (default), aborting the scan, or continuing the scheduling block without running this procedure.

``balance``: boolean
    controls whether after slewing to the calibrator the routine balances the power along teh IF path and gain to set the power levels just before collecting data.

``configure``: boolean
    causes the telescope to configure for continuum observing for the specified receiver. 

``beamName``: string
    specifies which receiver beam will be center of the cross-scan. BeamName can be 'C', '1', '2', '3', '4', etc. up to '7' for KFPA. This keyword should not be specified unless there is an issue with the default beams used for pointing.

``refBeam``: string
    specifies which beam will be the reference beam for subtracting the sky contribution for the pointing observations. The name strings are the same as for the ``beamName`` argument. This keyword should not be specified unless there is an issue with the default beams used for pointing.
 
``elAzOrder``: boolean
    if True, the elevation peak scans will be done first before the azimuth peak scans. 

``calSeq``: boolean
    this keyword is only applicable for receivers operating above 66 GHz and the associated calibration observations depend on the receiver and the particular Auto utility procedure (see the individual receiver chapters for specifics). If True, then for Rcvr68_92 the observations will be proceeded by calibration calSeq observations or for RcvrArray75_115 the calibration vanecal observations. If False, then the calibration calSeq or vanecal observations will be skipped. 

``gold``: boolean
    if True, then only "Gold standard sources", i.e. sources suitable for pointing at high frequencies will be used. This parameter is ignored if the source parameter is specified.


.. caution::

    Since ``AutoPeakFocus()`` is by default self-configuring (``configure=True``), one must re-configure the GBT IF path for science observations after the pointing and focus observations are done.


.. todo:: 

    **[Move this information to the appropriate place]** 
    
    KFPA and Argus have backup beam pairs, that can be used for pointing and focus if there is an issue with one of the default beams. The valid beam pairs for the KFPA are ``beamName='4'``, ``refBeam='6'`` (default beam pair) or  ``beamName='3'``, ``refBeam='7'`` (backup beam pair), while the vaid beam pairs for Argus are  ``beamName='10'``, ``refBeam='11'`` (default beam pair) or  ``beamName='14'``, ``refBeam='15'`` (backup beam pair).


Sequence of Events
"""""""""""""""""""""

    #. Determine the appropriate receiver based on the selection in the scan coordinator.
    #. Determine the recommended beam, antenna/subreflector motions, and duration for peak and focus scans.
    #. Get current antenna beam location form the control system.
    #. Configure for continuum onsberations with the current receiver.
    #. Run a balance to place the IF power levels appropriately.
    #. Determine the source as specified by the user or as chosen by software using the minimum flux, observing frequency, location, and search radius. If not pointing source is found within the specified radius, then provide the observer the option to use a more distant source (default), and if none is found either aborting (second default) or continuing the scheduling block.
    #. Slew to source.
    #. Run another balance to set the power levels at the location of the source.
    #. Run a set of four pointing scans using the Peak command.
    #. Run a scan usign the Focus command.



Examples
""""""""""

.. code-block:: python

    # default --> fully automatic
    AutoPeakFocus()

    # point and focus on 3C286
    AutoPeakFocus('3C286')

    # find a pointing source near RA=16:30:00, Dec=47:30:00
    AutoPeakFocus(location=Location('J2000', '16:30:00', '47:23:00')




    

.. _Balance():

Balance()
^^^^^^^^^^^

Utility function.


.. _BalanceOnOff():


BalanceOnOff()
^^^^^^^^^^^^^^^

Utility function.


.. _Break():

Break()
^^^^^^^^^^^^^

Utility function.



.. _Catalog():

Catalog()
^^^^^^^^^^^^^




.. _ChangeAttenuation():

ChangeAttenuation()
^^^^^^^^^^^^^^^^^^^^

Utility function.




.. _Comment():

Comment()
^^^^^^^^^^^^^

Utility function.



.. _Configure():

Configure()
^^^^^^^^^^^^^



.. _Daisy():

Daisy()
^^^^^^^^^^^^^

Observing scan.




.. _DecLatMap():

DecLatMap()
^^^^^^^^^^^^^

.. autofunction:: astrid_commands.DecLatMap




.. _DecLatMapWithReference():

DecLatMapWithReference()
^^^^^^^^^^^^^^^^^^^^^^^^

Mapping scan. 




.. _execfile():

execfile()
^^^^^^^^^^^^^



.. _Focus():

Focus()
^^^^^^^^^^^^^

Focus scan type moves the subreflector or prime focus receiver (depending on the receiver in use) through the axis aligned with the beam. Its primary use is to determine focus positions for use in subsequent scans.

::

    Focus(
        source,
        start=None,
        focusLength=None,
        scanDuration=None,
        beamName,
        refBeam,
        ):

All parameters are optional!

``location``: 
    Catalog source name or Location object. It specifies the source upon which to do the scan


.. _GetLST():

GetLST():
^^^^^^^^^^^^^

Utility function. 



.. _GetUTC():

GetUTC()
^^^^^^^^^^^^^

Utility function. 





.. _Horizon():

Horizon()
^^^^^^^^^^^^^

Scheduling block object.



.. _Location():

Location()
^^^^^^^^^^^^^

Scheduling block object.



.. _Nod():

Nod()
^^^^^^^^^^^^^



.. _Now():

Now()
^^^^^^

Utility function.





.. _OffOn():


OffOn()
^^^^^^^^^^^^^




.. _OffOnSameHA():

OffOnSameHA()
^^^^^^^^^^^^^


.. _Offset():

Offset()
^^^^^^^^^^^^^

Scheduling block object.




.. _OnOff():

OnOff()
^^^^^^^^^^^^^



.. _OnOffSameHA():

OnOffSameHA()
^^^^^^^^^^^^^



.. _Peak():

Peak()
^^^^^^^^^



.. _PointMap():

PointMap()
^^^^^^^^^^^^^

Mapping scan. 



.. _PointMapWithReference():

PointMapWithReference()
^^^^^^^^^^^^^^^^^^^^^^^^^^

Mapping scan. 



.. _RALongMap():

RALongMap()
^^^^^^^^^^^^^

Mapping scan. 



.. _RALongMapWithReference():

RALongMapWithReference()
^^^^^^^^^^^^^^^^^^^^^^^^^^

Mapping scan. 


.. _Tip():

Tip()
^^^^^^




.. _Track():

Track()
^^^^^^^^

Observing scan. 



.. _Slew():

Slew()
^^^^^^^






.. _SubBeamNod():

SubBeamNod()
^^^^^^^^^^^^^


.. The time object is unclear for me from the Observer Guide documentation...

.. _Time():

Time()
^^^^^^^


.. _WaitFor():

WaitFor()
^^^^^^^^^^^^^

Utility function.






