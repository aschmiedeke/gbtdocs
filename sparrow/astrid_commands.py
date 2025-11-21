def AutoPeakFocus(source=None, location=None, frequency=None, flux=None,
                  radius=10., balance=True, configure=True, beamName=None, refBeam=None,
                  elAzOrder=False, calSeq=True, gold=False):

    """
    An utility scan. The intent of this scan type is to automatically peak and focus the antenna
    for the current location on the sky and with the current receiver. Therefore it should not
    require any user input. However, by setting any of the optional arguments the user may partially
    or fully override the search and/or procedural steps as described below.

    Warning
    -------
        :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>` should not be used with Prime Focus 
        receivers. The prime focus receivers have pre-determined focus positions and there is not 
        enough travel in the feed to move them significantly out of focus.

    AutoPeakFocus() will execute its own default continuum configuration unless “configure=False”
    is supplied as an optional argument, which is not recommended in general unless one knows the
    system well.


    Parameters
    ----------
    
    source: str
        It specifies the name of a particular source in the pointing catalog or in a user-defined
        Catalog. Specifying a source bypasses the search process. Please note that NVSS source names
        are used in the pointing catalog. If the name is not located in the pointing catalog then all
        the user-specified catalogs previously defined in the Scheduling Block are searched. If the
        name is not in the pointing catalog or in the user defined catalog(s) then the procedure fails.

    location:
        A Catalog source name or Location object. It specifies the center of the search radius. The 
        default is the antenna’s current beam location on the sky. Planets and other moving objects
        may **not** be used.

    frequency: float
        It specifies the observing frequency in MHz. The default is the rest frequency used by the
        standard continuum configurations, or the current configuration value if ``configure=False``.

    flux: float
        It specifies the minimum acceptable calibration flux in Jy at the observing frequency. The
        default is 20 times the continuum point-source sensitivity.

    radius: float
        The routine selects the closest calibrator within the radius (in degrees) having the minimum
        acceptable flux. The default radius is 10 degrees. If no calibrator is found within the radius,
        the search is continued out to 180 degrees and if a qualified calibrator is found the user is
        given the option of using it [default], aborting the scan, or continuing the scheduling block
        without running this procedure.

    balance: bool
        Controls whether after slewing to the calibrator the routine balances the power along the IF path
        and again to set the power levels just before collecting data. Allowed values are True or False.

    configure: bool
        This argument causes the telescope to configure for continuum observing for the specified receiver.
        
        .. note::
            
            Because AutoPeakFocus() is self-configuring when set to True, you must re-configure the GBT IF
            path for your science observations after the pointing and focus observations are done. If set to
            False, then no configuration is done, and the observer must ensure that the system is properly
            configured first before running the command.

    beamName: str
        It specifies which receiver beam will be the center of the cross-scan. beamName can be ‘C’, ‘1’, ‘2’,
        ‘3’, ‘4’, etc, up to ‘7’ for the KFPA receiver. This keyword should not be specified unless there is
        an issue with the default beams used for pointing. 

    refBeam: str
        It specifies which beam will be the reference beam for subtracting the sky contribution for the pointing
        observations. The name strings are the same as for the ``beamName`` argument. This keyword should not be
        specified unless there is an issue with the default beams used for pointing. The KFPA and Argus
        have backup beam pairs that can be used for pointing and focus if there is an issue with one of the
        default beams. The valid beam pairs for the KFPA are ``beamName='4'``, ``refBeam='6'`` (default beam pair) 
        or ``beamName='3'``, ``refBeam='7'`` (backup beam pair), while the valid beam pairs for Argus are 
        ``beamName='10'``, ``refBeam='11'`` (default beam pair) or ``beamName='14'``, ``refBeam='15'`` (backup
        beam pair). 

    elAzOrder: bool
        If True, the elevation peak scans will be done first before the azimuth peak scans. This can be helpful
        for high-frequency observations (> 40GHz) to provide more successful initial pointing solutions, since
        the elevation pointing offsets are typically larger than the azimuth offsets. The default is False, 
        for which the azimuth pointing scans will be done before the elevation scans.

    calSeq: bool
        This keyword is only applicable for receivers operating above 66 GHz, and the associated calibration
        observations depend on the receiver (``'Rcvr68_92'``, ``'RcvrArray75_115'``, ``'Rcvr_MBA1_5'``) and the 
        particular Auto utilty procedure (see the individual receiver chapters for specifics).

        If True, then for ``'Rcvr68_92'`` (:ref:`W-Band <references/receivers/w-band:W-Band receiver>`) the 
        observations will be preceeded by calibration calSeq observations, for ``'RcvrArray75_115'`` 
        (:ref:`references/receivers/argus:Argus`) the calibration “vanecal” observations, and for 
        ``'Rcvr_MBA1_5'`` (:ref:`references/receivers/mustang2:MUSTANG-2`) by a calibration skydip. If False,
        then the calibration calSeq, vanecal or skydip observations will be skipped. The default value is True.

    gold: bool
        If True then only “Gold standard sources” (.i.e. sources suitable for pointing at high frequencies) will be
        used by :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>`. This parameter is ignored if the ``source``
        parameter is specified.


    AutoPeakFocus will use the default scanning rates and lengths listed in :numref:`tab-peak-focus-default-vals`.
   
    .. admonition:: Sequence of events done by AutoPeakFocus() in full automatic mode, i.e. with no arguments
        :class: note

        1. Determine the appropriate receiver based on the selection in the scan coordinator.
        2. Determine the recommended beam, antenna/subreflector motions, and duration for peak and focus scans.
        3. Get current antenna beam location from the control system.
        4. Configure for continuum observations with the current receiver.
        5. Run a balance to place the IF power levels appropriately.
        6. Determine the source as specified by the user or as chosen by software using the minimum flux, observing frequency, location, and search radius. If no pointing source is found within the specified radius, then provide the observer the option to use a more distant source (default), and if none found either aborting (second default) or continuing the scheduling block.
        7. Slew to source.
        8. Run another balance to set the power levels at the location of the source.
        9. Run a set of four pointing scans using the Peak command.
        10. Run a scan using the Focus command.


    Examples
    --------
    The script below gives examples demonstrating the expected use of AutoPeakFocus.

    .. code-block:: python

        #Configure for correct receiver at start of session...
        execfile('/home/astro-util/projects/GBTog/configs/tp_config.py')
        Configure(tp_config)
        
        #Default (fully automatic)
        AutoPeakFocus()

        #point and focus on 3C286
        AutoPeakFocus('3C286')

        # find a pointing source near ra=16:30:00 dec=47:23:00
        AutoPeakFocus(location=Location('J2000','16:30:00','47:23:00'))

        # Since AutoPeakFocus has executed its own configuration reconfigure for science observations
        Configure(tp_config)

    """


def AutoPeak(source=None, location=None, frequency=None, flux=None,
             radius=10., balance=True, configure=True, beamName=None, refBeam=None,
             elAzOrder=False, calSeq=True, gold=False):

    """
    An utility scan. AutoPeak() is the same as AutoPeakFocus() except that it does not perform a focus scan.
    The intent of this scan type is to automatically peak the antenna for the current location on the sky and
    with the current receiver. Therefore it should not require any user input. However, by setting any of the
    optional arguments the user may partially or fully override the search and/or procedural steps as described
    below.

    AutoPeak() will execute its own default continuum configuration unless “configure=False”
    is supplied as an optional argument, which is not recommended in general unless one knows the
    system well.


    Parameters
    ----------
    
    source: str
        It specifies the name of a particular source in the pointing catalog or in a user-defined
        Catalog. Specifying a source bypasses the search process. Please note that NVSS source names
        are used in the pointing catalog. If the name is not located in the pointing catalog then all
        the user-specified catalogs previously defined in the Scheduling Block are searched. If the
        name is not in the pointing catalog or in the user defined catalog(s) then the procedure fails.

    location:
        A Catalog source name or Location object. It specifies the center of the search radius. The 
        default is the antenna’s current beam location on the sky. Planets and other moving objects
        may not be used.

    frequency: float
        It specifies the observing frequency in MHz. The default is the rest frequency used by the
        standard continuum configurations, or the current configuration value if ``configure=False``.

    flux: float
        It specifies the minimum acceptable calibration flux in Jy at the observing frequency. The
        default is 20 times the continuum point-source sensitivity.

    radius: float
        The routine selects the closest calibrator within the radius (in degrees) having the minimum
        acceptable flux. The default radius is 10 degrees. If no calibrator is found within the radius,
        the search is continued out to 180 degrees and if a qualified calibrator is found the user is
        given the option of using it [default], aborting the scan, or continuing the scheduling block
        without running this procedure.

    balance: bool
        Controls whether after slewing to the calibrator the routine balances the power along the IF path
        and again to set the power levels just before collecting data. Allowed values are True or False.

    configure: bool
        This argument causes the telescope to configure for continuum observing for the specified receiver.
        
        .. note::
            
            Because AutoPeak() is self-configuring when set to True, you must re-configure the GBT IF
            path for your science observations after the pointing and focus observations are done. If set to
            False, then no configuration is done, and the observer must ensure that the system is properly
            configured first before running the command.

    beamName: str
        It specifies which receiver beam will be the center of the cross-scan. ``beamName`` can be 'C', '1', '2',
        '3', '4', etc, up to '7' for the KFPA receiver. This keyword should not be specified unless there is
        an issue with the default beams used for pointing. 

    refBeam: str
        It specifies which beam will be the reference beam for subtracting the sky contribution for the pointing
        observations. The name strings are the same as for the beamName argument. This keyword should not be
        specified unless there is an issue with the default beams used for pointing (7.6). The KFPA and Argus
        have backup beam pairs that can be used for pointing and focus if there is an issue with one of the
        default beams. The valid beam pairs for the KFPA are ``beamName='4'``, ``refBeam='6'`` (default beam pair) 
        or ``beamName='3'``, ``refBeam='7'`` (backup beam pair), while the valid beam pairs for Argus are 
        ``beamName='10'``, ``refBeam='11'`` (default beam pair) or ``beamName='14'``, ``refBeam='15'`` 
        (backup beam pair). 

    elAzOrder: bool
        If True, the elevation peak scans will be done first before the azimuth peak scans. This can be helpful
        for high-frequency observations (> 40GHz) to provide more successful initial pointing solutions, since
        the elevation pointing offsets are typically larger than the azimuth offsets. The default is False, 
        for which the azimuth pointing scans will be done before the elevation scans.

    calSeq: bool
        This keyword is only applicable for receivers operating above 66 GHz, and the associated calibration
        observations depend on the receiver (``'Rcvr68_92'``, ``'RcvrArray75_115'``, ``'Rcvr_MBA1_5'``) and the 
        particular Auto utilty procedure (see the individual receiver chapters for specifics).

        If True, then for ``'Rcvr68_92'`` (:ref:`W-Band <references/receivers/w-band:W-Band receiver>`) the 
        observations will be preceeded by calibration calSeq observations, for ``'RcvrArray75_115'`` 
        (:ref:`references/receivers/argus:Argus`) the calibration “vanecal” observations, and for 
        ``'Rcvr_MBA1_5'`` (:ref:`references/receivers/mustang2:MUSTANG-2`) by a calibration skydip. If False,
        then the calibration calSeq, vanecal or skydip observations will be skipped. The default value is True.

    gold: bool
        If True then only “Gold standard sources” (.i.e. sources suitable for pointing at high frequencies) will be
        used by AutoPeak(). This parameter is ignored if the ``source`` parameter is specified.


    AutoPeak will use the default scanning rates and lengths listed in :numref:`tab-peak-focus-default-vals`.
    
    .. admonition:: Sequence of events done by AutoPeak() in full automatic mode, i.e. with no arguments
        :class: note

        1. Determine the appropriate receiver based on the selection in the scan coordinator.
        2. Determine the recommended beam, antenna/subreflector motions, and duration for peak and focus scans.
        3. Get current antenna beam location from the control system.
        4. Configure for continuum observations with the current receiver.
        5. Run a balance to place the IF power levels appropriately.
        6. Determine the source as specified by the user or as chosen by software using the minimum flux, observing frequency, location, and search radius. If no pointing source is found within the specified radius, then provide the observer the option to use a more distant source (default), and if none found either aborting (second default) or continuing the scheduling block.
        7. Slew to source.
        8. Run another balance to set the power levels at the location of the source.
        9. Run a set of four pointing scans using the Peak command.


    Examples
    --------
    The script below gives examples demonstrating the expected use of AutoPeak.

    .. code-block:: python

        #Configure for correct receiver at start of session...
        execfile('/home/astro-util/projects/GBTog/configs/tp_config.py')
        Configure(tp_config)
        
        #Default (fully automatic)
        AutoPeak()

        #point and focus on 3C286
        AutoPeak('3C286')

        # find a pointing source near ra=16:30:00 dec=47:23:00
        AutoPeak(location=Location('J2000','16:30:00','47:23:00'))

        # Since AutoPeak has executed its own configuration Reconfigure for science observations
        Configure(tp_config)


    """


def AutoFocus(source=None, location=None, frequency=None, flux=None,
              radius=10., balance=True, configure=True, 
              beamName=None, refBeam=None, calSeq=True, gold=False):

    """
    An utility scan. AutoFocus() is the same as AutoPeakFocus() except that it does not perform pointing scans.
    The intent of this scan type is to automatically focus the antenna for the current location on the sky and
    with the current receiver. Therefore it should not require any user input. However, by setting any of the
    optional arguments the user may partially or fully override the search and/or procedural steps as described
    below.

    Warning
    -------
        AutoFocus() should not be used with Prime Focus receivers. The prime focus receivers have pre-determined
        focus positions and there is not enough travel in the feed to move them significantly out of focus.

    AutoFocus() will execute its own default continuum configuration unless “configure=False”
    is supplied as an optional argument, which is not recommended in general unless one knows the
    system well.


    Parameters
    ----------
    
    source: str
        It specifies the name of a particular source in the pointing catalog or in a user-defined
        Catalog. Specifying a source bypasses the search process. Please note that NVSS source names
        are used in the pointing catalog. If the name is not located in the pointing catalog then all
        the user-specified catalogs previously defined in the Scheduling Block are searched. If the
        name is not in the pointing catalog or in the user defined catalog(s) then the procedure fails.

    location:
        A Catalog source name or Location object. It specifies the center of the search radius. The 
        default is the antenna’s current beam location on the sky. Planets and other moving objects
        may not be used.

    frequency: float
        It specifies the observing frequency in MHz. The default is the rest frequency used by the
        standard continuum configurations, or the current configuration value if “configure=False”.

    flux: float
        It specifies the minimum acceptable calibration flux in Jy at the observing frequency. The
        default is 20 times the continuum point-source sensitivity.

    radius: float
        The routine selects the closest calibrator within the radius (in degrees) having the minimum
        acceptable flux. The default radius is 10 degrees. If no calibrator is found within the radius,
        the search is continued out to 180 degrees and if a qualified calibrator is found the user is
        given the option of using it [default], aborting the scan, or continuing the scheduling block
        without running this procedure.

    balance: bool
        Controls whether after slewing to the calibrator the routine balances the power along the IF path
        and again to set the power levels just before collecting data. Allowed values are True or False.

    configure: bool
        This argument causes the telescope to configure for continuum observing for the specified receiver.
        
        .. note::
            
            Because AutoFocus() is self-configuring when set to True, you must re-configure the GBT IF
            path for your science observations after the pointing and focus observations are done. If set to
            False, then no configuration is done, and the observer must ensure that the system is properly
            configured first before running the command.

    beamName: str
        It specifies which receiver beam will be the center of the cross-scan. ``beamName`` can be 'C', '1', '2',
        '3', '4', etc, up to '7' for the KFPA receiver. This keyword should not be specified unless there is
        an issue with the default beams used for pointing. 

    refBeam: str
        It specifies which beam will be the reference beam for subtracting the sky contribution for the pointing
        observations. The name strings are the same as for the beamName argument. This keyword should not be
        specified unless there is an issue with the default beams used for pointing (7.6). The KFPA and Argus
        have backup beam pairs that can be used for pointing and focus if there is an issue with one of the
        default beams. The valid beam pairs for the KFPA are ``beamName='4'``, ``refBeam='6'`` (default beam pair) 
        or ``beamName='3'``, ``refBeam='7'`` (backup beam pair), while the valid beam pairs for Argus are 
        ``beamName='10'``, ``refBeam='11'`` (default beam pair) or ``beamName='14'``, ``refBeam='15'`` 
        (backup beam pair). 


    calSeq: bool
        This keyword is only applicable for receivers operating above 66 GHz, and the associated calibration
        observations depend on the receiver (``'Rcvr68_92'``, ``'RcvrArray75_115'``, ``'Rcvr_MBA1_5'``) and the 
        particular Auto utilty procedure (see the individual receiver chapters for specifics).

        If True, then for ``'Rcvr68_92'`` (:ref:`W-Band <references/receivers/w-band:W-Band receiver>`) the 
        observations will be preceeded by calibration calSeq observations, for ``'RcvrArray75_115'`` 
        (:ref:`references/receivers/argus:Argus`) the calibration “vanecal” observations, and for 
        ``'Rcvr_MBA1_5'`` (:ref:`references/receivers/mustang2:MUSTANG-2`) by a calibration skydip. If False,
        then the calibration calSeq, vanecal or skydip observations will be skipped. The default value is True.

    gold: bool
        If True then only “Gold standard sources” (.i.e. sources suitable for pointing at high frequencies) will be
        used by AutoFocus(). This parameter is ignored if the ``source`` parameter is specified.


    AutoFocus will use the default scanning rates and lengths listed in :numref:`tab-peak-focus-default-vals`.
    
    .. admonition:: Sequence of events done by AutoFocus() in full automatic mode, i.e. with no arguments
        :class: note

        1. Determine the appropriate receiver based on the selection in the scan coordinator.
        2. Determine the recommended beam, antenna/subreflector motions, and duration for peak and focus scans.
        3. Get current antenna beam location from the control system.
        4. Configure for continuum observations with the current receiver.
        5. Run a balance to place the IF power levels appropriately.
        6. Determine the source as specified by the user or as chosen by software using the minimum flux, observing frequency, location, and search radius. If no pointing source is found within the specified radius, then provide the observer the option to use a more distant source (default), and if none found either aborting (second default) or continuing the scheduling block.
        7. Slew to source.
        8. Run another balance to set the power levels at the location of the source.
        9. Run a scan using the Focus command.



    Examples
    --------
    The script below gives examples demonstrating the expected use of AutoFocus.

    .. code-block:: python

        #Configure for correct receiver at start of session...
        execfile('/home/astro-util/projects/GBTog/configs/tp_config.py')
        Configure(tp_config)
        
        #Default (fully automatic)
        AutoFocus()

        #point and focus on 3C286
        AutoFocus('3C286')

        # find a pointing source near ra=16:30:00 dec=47:23:00
        AutoFocus(location=Location('J2000','16:30:00','47:23:00'))

        # Since AutoFocus() has executed its own configuration reconfigure for science observations
        Configure(tp_config)

    
    """


def AutoOOF(source, location, frequency, flux, radius, balance, configure, beamName, refBeam,
calSeq, gold, nseq="optional"):

    """
    An utility scan. Out-Of-Focus (OOF) holography is a technique for measuring large-scale errors in the shape
    of the reflecting surface by mapping a strong point source both in and out of focus. The procedure derives
    surface corrections which can be sent to the active surface controller to correct surface errors. The 
    procedure is recommended when observing at frequencies of 40 GHz and higher. 

    AutoOOF() can only be used for observations above 26 GHz. Receiver choices are limited
        - 'Rcvr26_40' (Ka-Band)
        - 'Rcvr40_52' (Q-Band)
        - 'Rcvr68_92' (W-Band)
        - 'RcvrArray75_115' (Argus)
        - 'Rcvr_PAR'(MUSTANG-2)

    Note
    ----

        AutoOOF is used in a similar manner to :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>`.
        The command should normally be run without any arguments, since the default options are handled
        best by the OOF processing software. It is important to only OOF on bright sources (at least 3-4 Jy). 

    Parameters
    ----------

    nseq:
        Is an optional parameter for use with 'Rcvr_PAR'. It is used to specify the number of OTF maps made
        with AutoOOF and may take values of 3 or 5.
        
    calSeq: bool
        This keyword is only applicable for receivers operating above 66 GHz, and the associated calibration
        observations depend on the receiver (``'Rcvr68_92'``, ``'RcvrArray75_115'``, ``'Rcvr_MBA1_5'``) and the 
        particular Auto utilty procedure (see the individual receiver chapters for specifics).

        If True, then for ``'Rcvr68_92'`` (:ref:`W-Band <references/receivers/w-band:W-Band receiver>`) the 
        observations will be preceeded by calibration calSeq observations, for ``'RcvrArray75_115'`` 
        (:ref:`references/receivers/argus:Argus`) the calibration “vanecal” observations, and for 
        ``'Rcvr_MBA1_5'`` (:ref:`references/receivers/mustang2:MUSTANG-2`) by a calibration skydip. If False,
        then the calibration calSeq, vanecal or skydip observations will be skipped. The default value is True.

    Examples
    --------
    
    .. code-block:: python
        
        # Specifying a source for AutoOOF
        AutoOOF('2253+1608')


    Note
    ----
        The example OOF command above is applicable for all receivers, and users should refer to the individual
        receiver chapters to understand the specifics on how the OOF data are calibrated via the calSeq keyword.
        For Ka-band, the default backend for the AutoOOF procedure is the CCB. Besides the much higher sensitivity
        provided by the CCB (a fast beam-switching backend designed for continuum measurements), the larger beam at
        lower frequency makes the surface solutions less affected by winds. Since the Ka+CCB system provides the most
        accurate measurements of the surface parameters, it should be used whenever possible.

        Users should refrain from using non-standard defaults for the AutoOOF measurements since the processing
        software is customized per receiver based on the default parameters (e.g., avoid running an AutoOOF at
        a non-default frequency or pre-configuring and running with the configuration=False keyword).

    
    .. todo:: Add receiver specific instructions in the Hardware segment of the reference guides.
    
    """



def Peak(location, hLength=None, vLength=None, scanDuration=None, 
         beamName=None, refBeam=None, elAzOrder=False):



    """
    An utility scan. Peak scan type sweeps through the specified sky location in the four cardinal directions.
    Its primary use is to determine pointing corrections for use in subsequent scans.

    
    Parameters
    ----------
    location : str
        Catalog source name or Location object. It specifies the source upon which to do the scan.

    hLength : Offset object
        Specifies the horitzontal distance used for the Peak. ``hLength`` values may be negative.
        The default value is the recommended value for the receiver.

    vLength : Offset object
        Specifies the vertical distance used for the Peak. ``vLength`` values may be negative. 
        The default value is the recommended value for the receiver.

    scanDuration : float
        Specifies the length of each scan in seconds. The default value is the recommended 
        value for the receiver.

    beamName : str
        Specifies the receiver beam to use for the scan. Make sure that you configure with
        the same beam with which you Peak.

    refBeam : str
        Specifies the reference receiver beam to use for the receivers with more than one beam.

    elAzOrder : bool
        If True, the elevation peak scans will be done first before the azimuth peak scans.
        This can be helpful for high-frequency observations (>40 GHz) since the elevation
        pointing offsets are typically larger than the azimuth offsets.


    Caution
    -------
        ``hLength``, ``vLength`` and ``scanDuration`` should be overridden as an unit since
        together they determine the rate.

    

    Examples
    _________

    
    .. code-block:: python

        # Peak using default settings and calibrator 0137+3309
        Peak('0137+3309')

        # Peak using encoder coordinates with scans of 90' length in 30s
        Peak('0137+3309', Offset('Encoder', '00:90:00', 0), Offset('Encoder', 0, '00:90:00'), 30, '1')

    """


def Focus(location, start=None, focusLength=None, scanDuration=None, 
         beamName=None, refBeam=None):

    """
    An utility scan. Focus scan type moves the subreflector or prime focus receiver (depending on the receiver in use)
    through the axis aligned with the beam. Its primary use is to determine focus positions for use in 
    subsequent scans.

    
    Parameters
    ----------
    location :
        Catalog source name or Location object. It specifies the source upon which to do the scan.

    start : float
        Specifies the starting position of the subreflector (in mm) for the focus scan. 

    focusLength : float
        Specifies the ending position of the subreflector relative to the starting location (in mm).

    scanDuration : float
        Specifies the length of the scan in seconds. The default value is the recommended 
        value for the receiver.

    beamName : str
        Specifies the receiver beam to use for measuring the focus. Make sure that you configure with
        the same beam with which you focus.

    refBeam : str
        Specifies the reference receiver beam to use for the receivers with more than one beam.

    

    Examples
    _________

    
    .. code-block:: python

        # Focus using default settings and calibrator 0137+3309
        Focus('0137+3309')

        # Focus from -200 to 200mm at 400mm/min with beam 1
        Focus('0137+3309', -200.0, 400.0, 60.0, '1')

    """




def Tip(location, endOffset, beamName='1', scanDuration=None, 
        startTime=None, stopTime=None):

    """
    An utility scan. Tip scan moves the beam on the sky from one elevation to another
    elevation while taking data and maintaining a constant azimuth. It is recommended
    to tip from 6 deg to 45 deg as the atmosphere will not change significantly above
    45 deg.


    
    Parameters
    ----------
    location :
        Catalog source name or Location object. It specifies the source upon which to do the scan.

    endOffset : Offset object
        Specifies the beam's final position for the scan, relative to the location specified
        in the first parameter. The offset also must be in AzEl or encoder coordinates. 

    beamName : str
        Specifies the receiver beam to use for the Tip. beamName can be 'C' (center),
        '1', '2', '3', '4' or any valid combination for the receiver you are using such
        as 'MR12' (i.e. track halfway between beams 1 and 2). 

    scanDuration : float
        Specifies the length of the scan in seconds. 

    startTime : time str 'hh:mm:ss'
        Allows the observer to specify a start time for the Tip. 

    stopTime : time str 'hh:mm:ss'
        Allows the observer to specify a stop time for the Tip.

    
    Note
    _________

    The scan time may be specified by either a scanDuration, a stopTime, 
    a startTime plus stopTime or a startTime plus scanDuration.



    Examples
    _________

    
    .. code-block:: python

        # Tip the GBT from 6 deg in elevation to 45 deg over a period of 5 min using beam 1
        Tip(Location('AzEl', 1.6, 6.0), Offset('AzEl', 0.0, 39.0), 300.0, '1')

    """




def Slew(location=None, offset=None, beamName='1', submotion=None):

    """
    An utility scan. Slew moves the telescope beam to point to a specified locaiton on 
    the sky without collecting any data.

    
    Parameters
    ----------
    location :
        Catalog source name or Location object. It specifies the source to which the
        telescope should slew. The default is the current location in "J2000" coordinate
        mode.

    offset : Offset object
        Moves the beam to an optional offset position that is specified relative to the
        location specified in the location parameter value. 

    beamName : str
        Specifies the receiver beam to use for the scan. beamName can be 'C' (center),
        '1', '2', '3', '4' or any valid combination for the receiver you are using such
        as 'MR12' (i.e. track halfway between beams 1 and 2). 

    
    Note
    _________

     Once Slew() is complete, the location will continue to be tracked at a sidereal
     rate until a new command is issued.


    Examples
    _________

    
    .. code-block:: python

        # Antenna slews to 3C48 with beam 1
        Slew('3C48', beamName='1') 

        # Slew to 3C48 plus offset
        Slew('3C48', ADD OFFSET)

        # Slew to offset from current location
        Slew(ADD OFFSET)


    """


def Balance():

    """
    An utility scan. The Balance() command is used to balance the electronic signal 
    throughout the GBT IF system so that each device is operating in its linear response
    regime. Balance() will work for any device with attenuators and for a particular
    backend. Individual devices can be balanced such as Prime Focus receivers, the
    IF system, the DCR, and VEGAS. The Gregorian receivers, except Argus, lack attenuators and do
    not need to be balanced. If the argument to Balance() is blank (recommended usage), 
    then all devices for the current state of the IF system will be balanced using the
    last executed configuration to decide what hardware will be balanced.

    If the balance command is blank (Balance()), and if the system fails to balance, the user will be presented
    with a pop-up window asking if the user would like to abort the observation script, continue without balancing, 
    or re-run the balance command.  In addition, a message will appear in teh Astrid messages window 
    noting which piece of hardware failed in balancing.

    Example
    ________

    
    .. code-block:: python

        # example showing the expected use of Balance()

        # load configuration
        execfile('/home/astro-util/projects/GBTog/configs/tp_config.py') 
        Configure(tp_config)

        # Slew to target so that you may balance "on source"
        Slew('3C286')

        # Balance IF and devices for specified configuration
        Balance()



    Advanced Syntax
    ---------------

    :code:`Balance(device, {option:value})`

    
    .. warning:: 

        Use only if you really know what you're doing!

    **Parameters**
    
    *device: str*
        A string that may take the following values: ``'IFRack'``, ``'DCR_AF'``, ``'GUPPI'``,
        ``'vlbi'``, ``'VEGAS'``, ``'RcvrPF_1'``, ``'RcvrPF_2'``.

    *{option: value}:*
        An optional parameter to the Balance() function. Can be a Python dictionary containing
        one or more of the balancing options listed below. Items which are not in the dictionary
        are assigned their default values and non-applicable options are ignored.

        **option** is a string used to control the balancing. The allowed **value** types depend
        on the option:

        * ``'target_level'``: The target balancing level for the specified device. 
            * value is a float. 
            * Default values vary by device.

        * ``'port'``: Used to specify which ports to balance.
            * value is an integer list (e.g. [1,2,9,10]). VEGAS ports are in the range of 1-16.
            * The default is to balance all ports.

        * ``'sample_time'``: Only applicable when balancing the prime focus receivers. 
            The prime focus balance API will try and balance the receiver over a period of ``sample_time``
            seconds. This will be repeated a maximum of 6 times or until the power level is within 20% of
            the target_level.

            * value is an integer between 1 and 41 seconds. 
            * The default is 2.

        * ``'cal'``: Turns the noise diodes on or off when balancing the prime focus receivers.
            * value can be either ``'on'`` or ``'off'``. 
            * The default is ``'on'``.

    **Usage**

    .. code-block:: 

        Balance('RcvrPF_1', {'sample_time': 5, 'cal': 'on'})
        Balance('VEGAS', {'target_level': -20})

    """



def BalanceOnOff(location, offset=None, beamName='1'):

    """
    An utility scan. When there is a large difference in power received by the GBT between two positions
    on the sky, it is advantageous to balance the IF system power levels to be at the mid-point of the
    two power levels. Typically this is needed when the "source position" is a strong continuum source.
    This scan type has been created to handle this scenario; one chouls consider using it when the system 
    temperature on and off source differ by a factor of two or more.

    The BalanceOnOff() slews to the source position and then balances the IF system. It then determines
    the power levels that are observed in the IF Rack. Then the telescope is slewed to the off position
    and the power levels are determined again. The change in the power levels is then used to determine
    attenuator settings that put the balance near the mid-point of the observed power range. Note that 
    the balance is determined only to within +/-0.5 dB owing to the integer settings of the IF Rack
    attenuators.

    
    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source of which the telescope should
        slew. The default is the current location in "J2000" coordinate mode.

    offset: Offset object
        It moves the beam to an optional offset position that is specified relative to 
        the location specified in the location parameter value. 

    beamName: str
        It specifies the receiver beam to use for the scan. beamName can be 'C', '1', '2', '3', '4', or 
        any valid combination for the receiver you are using such as 'MR12'.
        

    Examples
    _________

    
    .. code-block:: python

        # example showing the expected use of Balance()

        # load configuration
        execfile('/home/astro-util/projects/GBTog/configs/tp_config.py') 
        Configure(tp_config)

        # Balance IF and devices for specified configuration
        BalanceOnOff('3C48', Offset('J2000', 1.0, 0.0))


    """



def Track(location, endOffset, scanDuration=None, beamName='1',
          submotion=None, startTime=None, stopTime=None, fixedOffset=None):

    """
    An observing scan. The Track scan type follows a sky location while taking data.
    
    
    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source which is to be tracked.

    endOffset: Offset object
        Supplying an endOffset object with a value other than None will track the telescope across
        the sky at constant velocity. The scan will start at the specified location and end at
        (location+endOffset) after scanDuration seconds. If you wish to only track a single location
        rather than slew the telescope between two points, use None for this parameter.

    beamName: str
        It specifies the receiver beam to use for the scan. beamName can be 'C', '1', '2', '3', '4', or 
        any valid combination for the receiver you are using such as 'MR12'.

    startTime: Time object
        This specifies when the scan begins in the Universal Time (UT). If startTime is in the past
        then the scan starts as soon as possible with a message sent to the scan log. If (startTime +
        scanDuration) is in the past, then the scan is skipped with a message to the observation log. 
        The value may be

        - **A time object:** Note, if ``startTime`` is more than ten minutes in the future then a 
          message is sent to the observation log. 
        - **A Horizon object:** The following script implicitely calculates the startTime using Horizon():

          .. code-block:: python

            Track('VirgoA', None, 120.0, startTime=horizon, startTime=Horizon())

          If the source never rises then the scan is skipped and if the source never sets then the scan
          is started immediately. In either case a message is sent to the observation log. 

    stopTime: Time object
        This specifies when the scan completes. If stopTime is in the past then the scan is skipped with
        a message to the observation log.

        - **A Horizon Object:** When a Horizon object is used, the stop time is implicitely computed. 
          The following lines in an SB would track VirgoA from rise to set using a horizon of 20 degree:

          .. code-block:: python

            horizon = Horizon(20.0)
            Track('VirgoA', None, 120.0, startTime=horizon, stopTime=horizon)
        
          If the source never sets, then the scan stop time is set to 12 hours from the current time. 
 
    fixedOffset: Offset object
        Track follows the sky location plus this fixed Offset. The ``fixedOffset`` may be in a different
        coordinate mode than the ``location``. If an ``endOffset`` is also specified, Track starts at 
        (location+fixedOffset), and ends at (location+fixedOffset+endOffset). The ``fixedOffset`` and
        ``endOffset`` must be both of the same coordinate mode, but may be of a different mode than the
        ``location``. The ``fixedOffset`` parameter may be omitted.
        

    Note
    -------

        Scan timing must be specified by either 
            * a ``scanDuration``, 
            * a ``stopTime``,
            * a ``startTime`` plus ``stopTime``, or
            * a ``startTime`` plus ``scanDuration``. 
        

    Examples
    _________

    
    .. code-block:: python

        # Track 3C48 for 60 seconds using the center beam
        Track('3C48', None, 60.0)

        # Track a position offset by 1 degree in elevation
        Track('3C48', None, 60.0, fixedOffset=Offset('AzEl', 0.0, 1.0))

        # Scan across the source from -1 to +1 degrees in azimuth
        Track('3C48', Offset('AzEl', 2.0, 0.0), 60.0, fixedOffset=Offset('AzEl', -1.0, 0.0))

    """






def OnOff(location, referenceOffset, scanDuration=None, beamName='1'):


    """
    An observing scan. The OnOff scan type performs two scans. The first scan is on source, and the second scan is
    at an offset from the source location used in the first scan.
    
    
    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source upon which
        to do the "On" scan.

    referenceOffset: Offset object
        Is specifies the location of the "Off" scan relative to the location specified by the first
        parameter.

    scanDuration: float
        It specifies the length of each scan in seconds.

    beamName: str
        It specifies the receiver beam to use for the scan.



    Examples
    _________

    
    .. code-block:: python

        # OnOff scan with reference offsets of 1 degree in RA and 1 deg in Dec
        # with a 60 s scan duration using beam 1.
        
        OnOff('0137+3309', Offset('J2000', 1.0, 1.0, cosv=False), 60, '1')

    """



def OffOn(location, referenceOffset, scanDuration=None, beamName='1'):
    
    """
    An observing scan. The OffOn scan type is the same as the OnOff scan except that the first scan is offset
    from the source location. 
    
    
    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source upon which
        to do the "On" scan.

    referenceOffset: Offset object
        Is specifies the location of the "Off" scan relative to the location specified by the first
        parameter.

    scanDuration: float
        It specifies the length of each scan in seconds.

    beamName: str
        It specifies the receiver beam to use for the scan.



    Examples
    _________

    
    .. code-block:: python

        # OffOn scan with reference offsets of 1 degree in RA and 1 deg in Dec
        # with a 60 s scan duration using beam 1.
        
        OffOn('0137+3309', Offset('J2000', 1.0, 1.0, cosv=False), 60, '1')

    """


def OnOffSameHA(location, scanDuration, beamName='1'):
    
    """
    An observing scan. The OnOffSameHA scan type performs two scans. The first scan is on the source and the
    second scan follows the same HA track used in the first scan. 
    
    
    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source upon which
        to do the "On" scan.

    scanDuration: float
        It specifies the length of each scan in seconds.

    beamName: str
        It specifies the receiver beam to use for both scan.



    Examples
    _________

    
    .. code-block:: python

        # OnOffSameHA scan with 60s scan duration using beam 1.

        OnOffSameHA('0137+3309', 60, '1')

    """


def Nod(location, beamName1, beamName2, scanDuration):
    
    """
    An observing scan. The Nod procedure does two scans on the same sky location with different beams.

    

    Caution
    ________

        Nod should only be used with multi-beam receivers.



    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source upon which
        to do the Nod.

    
    beamName1: str
        It specifies the receiver beam to use for the first scan. beamName1 can be '1'
        or '2'or any valid beam for the receiver you are using.


    beamName2: str
        It specifies the receiver beam to use for the second scan. beamName2 can be
        'C', '1', '2' or any valid beam for the receiver you are using.


    scanDuration: float
        It specifies the length of each scan in seconds.





    Examples
    _________

    
    .. code-block:: python

        # Nod between beams 3 and 7 with a 60s scan duration

        Nod('1011-2610', '3', '7', 60.)

    """


def SubBeamNod(location, scanDuration, beamName, nodLength, nodUnit='seconds'):
    
    """
    An observing scan. For multi-beam receivers SubBeamNod causes the subreflector to tilt
    about its axis between two feeds at the given periodicity. The primary mirror is 
    centered on the midpoint between the two beams. The beam selections are extracted from
    the scan's beamName, i.e. 'MR12'. The "first" beam ('1') performs the first integration.
    The periodicity is specified in seconds per nod (half-cycle). A subBeamNod is limited
    to a minimum of 4.483 s for a half cycle.
    
    
    Parameters
    ----------

    location: 
        A Catalog source name or Location object. It specifies the source upon which
        to do the Nod.


    scanDuration: float
        It specifies the length of each scan in seconds.   

    beamName: str
        It specifies the receiver beam pair to use for nodding. beamName can be 'MR12'.

    nodLength: depends on unit of ``nodUnit`` (int for 'integrations', float or int for 'seconds')
        It specifies the half-cycle time which is the time spent in one position plus move
        time to the second position.

    nodUnit: str
        Either 'integrations' or 'seconds' (default). 


    Examples
    _________

    
    .. code-block:: python

        # nodLength units in second
        SubBeamNod('3C84', scanDuration=60.0, beamName='MR12', nodLength=4.4826624)

        # nodLength units are 'tint' as set in the configuration
        SubBeamNod('3C84', scanDuration=60.0, beamName='MR12', nodLength=3, nodUnit='integrations')

        #Example for Argus for 2 minute scan and 6 sec cycle for a 0.5 sec integration time using beams 10 and 11
        SubBeamNod('3C84',scanDuration=120,beamName=None,receiver='RcvrArray75_115',nodLength=12,nodUnit='integrations',beam1='10',beam2='11')
    


    Hint
    _____
    

        The scan will end at the end of the scanDuration (once the current integration is complete)
        regardless of the phase of the nod cycle. When the subreflector is moving the entire
        integration during which this occurs is flagged. It takes about 0.5 seconds for the 
        subreflector to move between beams plus additional time to settle on source (total time 
        is about ~1.5 second).
            
        For example, if we had previously configured for Rcvr26 40 and an integration time of
        1.5 sec- onds (``tint=1.5`` in the configuration), example 2 above would blank roughly
        one out of every three integrations in a half-cycle (``nodLength=3``) while the subreflector was
        moving between beams. If ``nodLength=5``, then only one in five integrations would be blanked.
        A resonable compromise in terms of performance and to minimize the amount of data blanked
        is to use subBeamNod with an integration time of 0.2s and a ``nodLength=30`` (6 sec nodding 
        between beams). It is important to use a small tint value to avoid blanking too much data
        (e.g., 0.5 sec or less).

        The subBeamNod mode is useful to produce good baselines for the measurement of broad
        extra-galactic lines. For Ka-band, Q-band, and Argus, the performance of subBeamNod is
        signficantly better than Nod observations. For W-band and the KFPA, the beams are farther
        apart and the subBeamNod technique does not work as well, and users are recommended to use 
        Nod observations.

        The antenna uses the average position of the two beams for tracking the target, and SDFITS
        reports the positions of the beams relative to the tracking position. Although the SDFITS
        header postion will not match the target position, SubBeamNod successfully nods between the
        two beams during the scan. Control of the subreflector may be done with any scan type using
        the submotion class. This should only be done by expert observers. Those observers interested
        in using this class should contact their GBT “Friend”.

    """

    





def RALongMap(location, hLength, vLength, vDelta, scanDuration,
              beamName="1", unidirectional=False, start=1, stop=None):

    """
    A mapping scan. A Right Ascension/Longitude (RALong) map performs an on-the-fly (OTF) raster scan centered
    on a sky location. Scans are performed along the major axis of the selected coordinate system.
    One can map in a variety of corrdinate systems, including J2000, Galactic, and AzEl. The
    selected coordinate system is defined by the coordinateMode keyword for the Offset object.
    The starting point of the map is defined as (-``hLength``/2, -``vLength``/2) from the specified center
    location.

    Parameters
    ----------

    location:
        A Catalog source name or Location object. It specifies the center of the map.

    hLength:
        An Offset object. It specifies the horizontal width of the map (i.e., the extent in the
        longitude-like direction). hLength values may be negative.

    vLength:
        An Offset object. It specifies the vertical height of the map (i.e., the extent in the
        latitude-like direction). vLength values may be negative.

    vDelta: 
        An Offset object. It specifies the distance between map rows. ``vDelta`` values must be
        positive. 

    scanDuration: float
        It specifies the length of each scan in seconds.

    beamName: str
        It specifies the receiver beam to use for the scan. ``beamName`` can be 'C', '1', '2', '3', '4'
        or any valid combination for the receiver you are using such as 'MR12'.

    unidirectional: bool
        It specifies whether the map is unidirectional (True) or boustrophedonic (False;
        from the Greek meaning "as the ox plows", i.e. back and forth).

    start: int
        It specifies the starting row for the map. This is useful for doing parts of a map at
        different times. For example, if map has 42 rows, one can do rows 1-12 by setting 
        ``start=1, stop=12``, and later finishing the map using ``start=13, stop=42``.

    stop: int
        It specifies the stopping row for the map. The default is ``None``, meaning "go to the end".


    Note
    ----
    Observers should limit scanDuration so that no more than 2 scans (or accelerations)
    are performed per minute. Overhead is ∼20 seconds per scan.


    Example
    --------
    The following script produces a map with 41 rows each 120 arcmin long, using a row spacing
    of 3 arcmin and scan rate of 20 arcmin/min with beam 1 (default). 

    .. code-block:: python

        RALongMap('NGC4258',                                    # center of the map
                  Offset('J2000', 2.0, 0.0, cosv=True),         # 120 arcmin width
                  Offset('J2000', 0.0, 2.0, cosv=True),         # 120 arcmin height
                  Offset('J2000', 0.0, 0.05, cosv=True),        # 3 arcmin row spacing
                  360.0)                                        # 6 minutes per row


    Caution
    -------
    Observers should ensure that they are sampling sufficiently in the scanning direction when using
    OTF mapping. In this example data were recorded every 5 seconds (``tint=5.0`` in the configuration).
    This results in one sample every 1.67arcmin in the scanning direction using the above scan rate 
    of 20arcmin/min. This is suitable for observations at 1420 MHz, where the FWHM of the beam is 
    8.8 arcmin. as the beam will be sampled at least 5 times.

    """


def RALongMapWithReference(location, hLength, vLength, vDelta,
                           referenceOffset, referenceInterval, scanDuration, referenceScanDuration=None,
                           beamName="1", unidirectional=False, start=1, stop=None):


    """
    A mapping scan. A right ascension/longitude (RALong) map performs an on-the-fly (OTF) raster scan centered on a sky
    location.  Scans are performed in the right ascension, longitude, or azimuth coordinate depending
    on the desired coordinate system. This procedure allows the user to periodically move to a reference
    location on the sky. If no reference location is needed, please use RALongMap instead.

    Parameters
    ----------

    location:
        A Catalog source name or Location object. It specifies the center of the map.

    hLength:
        An Offset object. It specifies the horizontal width of the map (i.e., the extent in the
        longitude-like direction). hLength values may be negative.

    vLength:
        An Offset object. It specifies the vertical height of the map (i.e., the extent in the
        latitude-like direction). vLength values may be negative.

    vDelta: 
        An Offset object. It specifies the distance between map rows. vDelta values must be
        positive. 

    referenceOffset:
        An Offset object. It specifies the position of the reference source on the sky relative to the
        Location specified by the first input parameter.
        
    referenceInterval: int
        It specifies when to do a reference scan in terms of map rows. For example, setting 
        referenceInterval=4 will periodically perform one scan on the reference source followed by
        4 mapping scans.

    scanDuration: float
        It specifies the length of each scan in seconds.

    referenceScanDuration: float
        It specifies the length of each reference scan in seconds. If not set, it will default to `scanDuration`.

    beamName: str
        It specifies the receiver beam to use for the scan. beamName can be 'C', '1', '2', '3', '4' 
        or any valid combination for the receiver you are using such as 'MR12'.

    unidirectional: bool
        It specifies whether the map is unidirectional (True) or boustrophedonic (False;
        from the Greek meaning 'as the ox plows, i.e. back and forth).

    start: int
        It specifies the starting row for the map. This is useful for doing parts of a map at
        different times. For example, if map has 42 rows, one can do rows 1-12 by setting 
        ``start=1, stop=12``, and later finishing the map using ``start=13, stop=42``.

    stop: int
        It specifies the stopping row for the map. The default is None, meaning "go to the end".


    Example
    --------
    The following script a map that is 120 arcmin long and 60 arcmin wide, using a row spacing of 3’ and
    scan rate of 4 arcmin/s. A reference position will be observed once before every 3 rows. The sequence
    of scans will be: reference → rows 1-3 → reference → rows 4-6 ...

    .. code-block:: python

        RALongMapWithReference('CygA',                                      # center of map
                               Offset('J2000', 2.0, 0.0, cosv=True),        # 120 arcmin length
                               Offset('J2000', 0.0, 1.0, cosv=True),        # 60 arcmin height
                               Offset('J2000', 0.0, 0.05, cosv=True),       # 3 arcmin row spacing
                               Offset('J2000', 2.0, 0.0, cosv=True),        # 2 degree ref offset in RA
                               3,                                           # reference before every 3 rows
                               30.0)                                        # 30 second scan duration

    """



def DecLatMap(location, hLength, vLength, hDelta, scanDuration,
              beamName="1", unidirectional=False, start=1, stop=None):

    """
    A mapping scan. A Declination/Latitude (DecLat) map, performs an on-the-fly (OTF) raster scan centered on
    a specific location on the sky. Scans are performed in declination, latitude, or elevation
    coordinates depending on the desired coordinate system. This procedure does **not** allow the user
    to periodically move to a reference location on the sky, please see DecLatMapWithReference for
    such a map. The starting point of the map is at (-``hLength``/2, -``vLength``/2).


    Parameters
    ----------

    location:
        A Catalog source name or Location object. It specifies the center of the map.

    hLength:
        An Offset object. It specifies the horizontal width of the map, i.e., the extent in the 
        longitude-like direction. hLength values may be negative.

    vLength:
        An Offset object. It specifies the vertical height of the map, i.e., the extent in the 
        latitude-like direction. cLength values may be negative.

    hDelta:
        An Offset object. Similar to ``vDelta`` in RALongMap. It specifies the horizontal distance
        between map columns. ``hDelta`` values must be positive.

    scanDuration: float
        It specifies the length of each scan in seconds.
        
    beamName: str
        It specifies the receiver beam to use for the scan. beamName can be 'C', '1', '2', '3', '4'
        or any valid combination for the receiver you are using such as 'MR12'.

    unidirectional: bool
        It specifies whether the map is unidirectional (True) or boustrophedonic (False;
        from the Greek meaning "as the ox plows", i.e. back and forth). 

    start: int
        It specifies the starting row for the map. This is useful for doing parts of a map at 
        different times. For example, if map has 42 rows, one can do rows 1-12 by setting
        ``start=1, stop=12``, and later finish the map using ``start=13, stop=42``.

    stop: int
        It specifies the stopping row for the map. The default is ``None``, meaning "go to the end".


    Note
    ----
    Observers should limit scanDuration, so that no more than 2 scans (or accelerations) are
    performed per minute. Overhead is ~20 seconds per scan.'


    Example
    --------
    The following script produces a map with 41 rows each 120’ long, using a row spacing of 3’
    and scan rate of 20’/min with beam 1 (default). 


    .. code-block:: python

        DecLatMap('NGC4258',                                # center of the map
                  Offset('J2000', 2.0, 0.0,cosv=True),      # 120' width
                  Offset('J2000', 0.0, 2.0,cosv=True),      # 120' height
                  Offset('J2000', 0.05,0.0,cosv=True),      # 3' column spacing
                  360.0)                                    # 6 minutes per column


    .. todo:: Add a plot showing the actual trajectory of the antenna on the sky. Figure 7.4 in the Observer's Guide unfortunately shows the inverted RA axis, providing the impression the scan is obtained in negative RA direction.

    """


def DecLatMapWithReference(location, hLength, vLength, hDelta,
                        referenceOffset, referenceInterval, scanDuration, referenceScanDuration=None,
                        beamName="1", unidirectional=False, start=1, stop=None):

    """
    A mapping scan. A Declination/Latitude (DecLat) map performs an On-the-fly (OTF) raster scan centered on
    a specific location on the sky.  Scanning is done in the declination, latitude, or elevation 
    coordinate depending on the desired coordinate mode. This procedure allows the user to periodically
    move to a reference location on the sky. Please see DecLatMap if no reference point is required.
    The starting point of the map is at (-``hLength``/2, -``vLength``/2).


    Parameters
    ----------

    location:
        A Catalog source name or Location object. It specifies the center of the map.

    hLength:
        An Offset object. It specifies the horizontal width of the map, i.e., the extent in the 
        longitude-like direction. hLength values may be negative.

    vLength:
        An Offset object. It specifies the vertical height of the map, i.e., the extent in the 
        latitude-like direction. cLength values may be negative.

    hDelta:
        An Offset object. Similar to ``vDelta`` in RALongMap. It specifies the horizontal distance
        between map columns. ``hDelta`` values must be positive.

    referenceOffset:
        An Offset object. It specifies the position of the reference source on the sky relative 
        to the Location specified by the first input parameter.
        
    referenceInterval: int
        It specifies when to do a reference scan in terms of map columns. For example, setting
        referenceInterval=4 will periodically perform one scan on the reference source followed
        by 4 mapping scans.

    scanDuration: float
        It specifies the length of each scan in seconds.
        
    referenceScanDuration: float
        It specifies the length of each reference scan in seconds. If not set, it will default to `scanDuration`.

    beamName: str
        It specifies the receiver beam to use for the scan. beamName can be 'C', '1', '2', '3', '4'
        or any valid combination for the receiver you are using such as 'MR12'.

    unidirectional: bool
        It specifies whether the map is unidirectional (True) or boustrophedonic (False;
        from the Greek meaning "as the ox plows", i.e. back and forth). 

    start: int
        It specifies the starting row for the map. This is useful for doing parts of a map at 
        different times. For example, if map has 42 rows, one can do rows 1-12 by setting
        ``start=1, stop=12``, and later finish the map using ``start=13, stop=42``.

    stop: int
        It specifies the stopping row for the map. The default is ``None``, meaning "go to the end".

    
    Example
    --------
    The following script produces a map 120 arcmin long and 60 arcmin wide using a column spacing of
    3 arcmin and scan rate of 4 arcmin/min. A reference position will be observed once before every
    3 columns. The sequence of scans will be: reference → columns 1-3 → reference → columns 4-6 ...

    .. code-block:: python

        DecLatMapWithReference('CygA',                                  # center of map
                               Offset('J2000', 1.0, 0.0, cosv=True),    # 60 arcmin width
                               Offset('J2000', 0.0, 2.0, cosv=True),    # 120 arcmin length
                               Offset('J2000', 0.05, 0., cosv=True),    # 3 arcmin column spacing
                               Offset('J2000', 2.0, 0.0, cosv=True),    # 2 degree ref offset in RA
                               3,                                       # reference before every 3 columns
                               30.0)                                    # 30 second scan duration

    """

def PointMap(location, hLength, vLength, hDelta, vDelta, 
             scanDuration, beamName="1", start=1, stop=None):


    """
    A mapping scan. A PointMap constructs a map by tracking fixed positions laid out on a grid. 
    This procedure does not allow the user to periodically move to a reference location on the sky,
    please see PointMapWithReference for such a map. The starting point of the map is defined as
    (-``hlength``/2, -``vLength``/2).

    Parameters
    ----------

    location:
        A Catalog source name or Location object. It specifies the center of the map.

    hLength:
        An Offset object. It specifies the horizontal width of the map. hLength values may be negative.

    vLength:
        An Offset object. It specifies the vertical height of the map. vLength values may be negative.

    hDelta:
        An Offset object. It specifies the horizontal distance between points in the map. ``hDelta`` values
        must be positive.

    vDelta:
        An Offset object. It specifies the vertical distance between points in the map. ``vDelta`` values 
        must be positive.

    scanDuration: float
        It specifies the length of each scan in seconds.

    beamName: str
        It specifies the receiver beam to use for the scan. ``beamName`` can be 'C', '1', '2', '3', '4' or
        any valid combination for the receiver you are using such as 'MR12'.

    start: int
        It specifies the starting point for the map. Note in PointMap this counts points, not stripes.

    stop: int
        It specifies the stopping point for the map. The default is ``None``, meaning "go to the end".



    Example
    -------
    The script below produces a 9 point map using a 3x3 grid. Points are separated by 10 arcsec in RA
    and 10 arcsec in Dec. Each point will be observed for 30 seconds using beam 1 (default).

    .. code-block::
    
        PointMap('W75N',                                                # center of map
                 Offset('J2000', 20.0 / 3600.0, 0.00, cosv=True),       # 20 arcsec width
                 Offset('J2000', 0.00, 20.0 / 3600.0, cosv=True),       # 20 arcsec height
                 Offset('J2000', 10.0 / 3600.0, 0.00, cosv=True),       # 10 arcsec horizontal spacing
                 Offset('J2000', 0.00, 10.0 / 3600.0, cosv=True),       # 10 arcsec vertical spacing
                 30.0)                                                  # 30 second scan length

    .. todo:: Add a plot showing the actual trajectory of the antenna on the sky. Figure 5.5 in the Observer's Guide unfortunately shows the inverted RA axis, providing the impression the scan is obtained in negative RA direction. The figure itself it correct, but I think it can be misleading to observers who may not pay attention to the x-axis.

    """


def PointMapWithReference(location, hLength, vLength, hDelta, vDelta,
                          referenceOffset, referenceInterval, scanDuration, referenceScanDuration=None,
                          beamName="1", start=1, stop=None):


    """
    A mapping scan. A PointMap constructs a map by tracking on fixed positions layed out on a grid. This procedure
    allows the user to periodically move to a reference location on the sky. Please see PointMap if
    no reference location is required.


    Parameters
    ----------
    location:
        A Catalog source name or Location object. It specifies the center of the map.

    hLength:
        An Offset object. It specifies the horizontal width of the map. ``hLength`` values may be negative.

    vLength:
        An Offset object. It specifies the vertical height of the map. ``vLength`` values may be negative.

    hDelta:
        An Offset object. It specifies the horizontal distance between points in the map. ``hDelta`` values
        must be positive.

    vDelta:
        An Offset object. It specifies the vertical distance between points in the map. ``vDelta`` values 
        must be positive.

    referenceOffset: 
        An Offset object. It specifies the position of the reference source on the sky relative to the
        Location specified by the first input parameter.

    referenceInterval: int
        It specifies when to do a reference scan in terms of map points. For example, setting 
        referenceInterval=4 will periodically perform one scan on the reference source followed by
        4 pointed scans.

    scanDuration: float
        It specifies the length of each scan in seconds.

    referenceScanDuration: float
        It specifies the length of each reference scan in seconds. If not set, it will default to `scanDuration`.

    beamName: str
        It specifies the receiver beam to use for the scan. ``beamName`` can be 'C', '1', '2', '3', '4' or
        any valid combination for the receiver you are using such as 'MR12'.

    start: int
        It specifies the starting point for the map. Note in PointMap this counts points, not stripes.

    stop: int
        It specifies the stopping point for the map. The default is ``None``, meaning "go to the end".


    Example
    -------
    The script below produces a 4×4 point map using beam 1 (default). A reference position will be observed
    before every 2 points. The sequence of scans will be: 
    reference (r) → points 1 and 2 (P1,2)→ r → P3,4 → r → P5,6 → r → P7,8 → r → P9,10 → r → P11,12 → r → P13,14 → r → P15,16.

    .. code-block:: python

        PointMapWithReference('2023+2223',                                      # center of map
                              Offset('J2000', 90. / 60., 0.0, cosv=True),       # 90 arcmin width
                              Offset('J2000', 0.0, 90. / 60., cosv=True),       # 90 arcmin height
                              Offset('J2000', 30. / 60., 0.0, cosv=True),       # 30 arcmin horizontal step spacing
                              Offset('J2000', 0.0, 30. / 60., cosv=True),       # 30 arcmin vertical step spacing
                              Offset('J2000', 3.0, 0.0, cosv=True),             # 3 degree ref offset in RA
                              2,                                                # reference before every 2 points
                              2.0)                                              # 2 second scan duration

    """

def Daisy(location, map_radius, radial_osc_period, radial_phase, rotation_phase, scanDuration,
          beamName="1", cos_v=True, coordMode="AzEl", calc_dt=0.1, scantype="MAP",
          nseq=1, annons={}, procseq=1):


    """
    A mapping scan. The Daisy scan type performs an OTF scan around a central point in the form of daisy petals. It is a 
    useful observing mode for focal plane arrays, allowing more integration time in the central field of
    view. The Daisy scan will produce an approximately closed circular pattern on the sky after 22 radial
    oscillation periods.

    .. todo:: Add figure 5.6 from the Observer's Guide above. Same issue with the x-axis here as in the figures for RALongMap, DecLatMap etc.


    
    For beamsizes of 20 arcsec FWHM or so, the circular area mapped will be fully sampled if the map radius
    is less than 6 arcmin. It is not an especially useful observing mode for general-purpose single-beam mapping,
    since the largest “hole” in the map is ~0.3× the map radius.

    Trajectories are generated according to 


    :math:`\Delta \hat{x}(t) = \\frac{r_0 sin(2\pi t/\\tau + \phi_1) cos(2t/\\tau + \phi_2)}{cos(\hat{y}_0)}`

    and

    :math:`\Delta \hat{y}(t) = r_0 sin(2\pi t/\\tau + \phi_1) sin(2t/\\tau + \phi_2),`    

    where 
    :math:`\hat{x}` and :math:`\hat{y}` are the major and minor coordinates of a sperical coordinate system,
    :math:`t` is the time, 
    :math:`r_0` is the map radius, 
    :math:`\\tau` is the radial oscillation period,
    :math:`\phi_1` and :math:`\phi_2` are the radial and rotational phases, and
    :math:`\hat{y}_0` is the minor coordinate of the map center.
    

    Parameters
    ----------

    location:
        A Catalog source name or Location object. It specifies the center of the map.

    map_radius: float
        :math:`r_0` in equation above. It specifies the radius of the map’s “daisy petals” in arcmin.

    radial_osc_period: float
        :math:`\\tau` in the equations above. It specifies the period of the radial oscillation in seconds.

        .. caution::

            Not to be less than 15 sec x :math:`\sqrt{r_0/1.5 arcmin}` for radii > 1.5 arcmin and in no
            case under 15 seconds.

    radial_phase: float
        :math:`\phi_1` in equations above. It specifies the radial phase in radians.

    rotation_phase: float
        :math:`\phi_2` in equations above. It specifies the rotational phase in radians.

    scanDuration: float
        It specifies the length of the scan in seconds.

    beamName: str. 
        It specifies the receiver beam to use for both scans. ``beamName`` can be 'C', '1', '2', '3', '4'
        or any valid combination for the receiver you are using such as 'MR12'. 

    cos_v: bool
        It specifies whether secant minor corrections (the :math:`cos(\hat{y}_0)` term in the first equation
        above should be used for the major axis of the coordinate system. 

    coordMode: str
        It specifies the coordinate mode for the radius that generates the map.

    calc_dt: float
        It specifies time sampling used by the control system to calculate a path. Values should be between
        0.1 and 0.5. Calculating many points for a long daisy scan can significantly increase overhead at
        scan startup.
    

    Note
    -------
    It takes approximately 22 radial oscillation periods to complete a closed Daisy pattern. However,
    ``radial_osc_period`` is typically set to be in the range of 15–60 seconds depending on the
    radius being used. As an example, 22 oscillations of 20 seconds would take 440 seconds. If a long
    trajectory such as this is sent to the antenna manager, intrinsic inefficiencies in the array handling
    mechanism can significantly increase overhead at the start of a scan. Therefore one should try to
    keep individual scans to 5 minutes or less.


    Example
    -------
    The script below will do 22 radial periods over 5 scans lasting 110 seconds each. The ``rotation_phase``
    and ``radial_phase`` arguments are used so that each scan starts where the previous scan finished. This
    will produce the closed Daisy pattern. The entire SB should take approximately
    10 minutes to complete.


    .. code-block:: python

        nosc = 22.0                                         # 22 radial oscillations for closed Daisy pattern
        map_radius = 2.8                                    # in arcmin
        radial_osc_period = 25.0                            # in seconds
        n_scans = 5                                         # split 22 oscillations over 5 scans
        scanDuration = nosc * radial_osc_period / n_scans
        phi2 = 2.0 * nosc / n_scans
        phi1 = 3.14159265 * phi2

        
        # NOTE:
        #       - increment rotation_phase by phi2 each scan
        #       - increment radial_phase by phi1 each scan

        for i in range(n_scans):
            Daisy('3C123', map_radius, radial_osc_period, i * phi1, i * phi2, scanDuration,
                  beamName='1', coordMode='J2000', cos_v=True, calc_dt=0.2)


    .. todo:: Add figure 5.7 from Observer's Guide here. Same issue with the x-axis here as in the figures for RALongMap, DecLatMap etc.

    """


def Annotation(key, value=None, comment=None):

    """

    An utility function. It allows you to add any keyword and value to the GO FITS file. This could be
    useful if there is any information you would like to record about your observation for later data
    processing, or for record keeping.

    Note
    ----
    The information in a FITS KEYWORD created via the Annotation() function will be ignored by the standard
    GBT data reduction package GBTIDL.


    Parameters
    ----------

    key: str
        A completely uppercase string of eight characters or less. **Do not use any standard FITS keywords!**

    value: str
        A value for the key.

    comment: str
        A comment to be added.


    Example
    -------
    An example use of the Annotation() function is if you wish to specify what type of source you are observing.
    Your sources might include HII regions and Planetary Nebulae for example. You could specify each type with

    .. code-block:: python

        Annotation('SRCTYPE', value='HII', comment='Type of source observed.')
        Annotation('SRCTYPE', value='PNe', comment='Type of source observed.')


    .. todo:: The Observer's Guide does not mention comment as a parameter and does not explicitely state value in the command. Exact code usage needs to be checked.

    """


def Break(message="Observation paused.", timeout=300.0):

    """
    An utility function. It inserts a breakpoint into your SB and gives you the choice of continuing 
    or terminating the SB. When a breakpoint is encountered during execution, your SB is paused and a
    pop-up window is created. The SB remains paused for a set amount of time or until you acknowledge
    the pop-up window and tell Astrid to continue running your script.

    The Break() function can take two optional arguments, a message string and a timeout length.

    Parameters
    ----------

    message: str
        Displayed in the pop-up dialog with a default of “Observation paused”.

    timeout: float
        The number of seconds to get user-input before continuing the SB. If you wish for the timeout to
        last forever then use ``None``. The default is 300 seconds, or 5 minutes.

        .. note::
            
            Why have a timeout? If an observer walks away from the control room during his or her observing
            session (e.g. to go to lunch or the bathroom) and a breakpoint is reached, it would be 
            counterproductive to pause the observation indefinitely. This will help save valuable 
            telescope time.


    Example
    -------

    .. code-block:: python

        Break('This will time out in 5 minutes, the default.')
        Break('This will time out after 10 minutes.', 600)
        Break('This will never time out.', None)

    """

def Comment(message):

    """
    An utility function. It allows you to add a comment into the Astrid observing process which will be
    echoed to the observation log during the observation. What’s the difference between this, and just
    writing comments with the pound (#) sign in your SB? When you use the pound sign to write your
    comments, they will not appear in the observation log when your SB is run. Using the Comment()
    function directs your comment to the output in the observation log.

    Parameters
    ----------

    message: str
        Text to display during the observation.


    Example
    -------

    .. code-block:: python

        # now slew to the source
        Comment('Now slewing to 3C 286')
        Slew('3C286')

    """


def GetUTC():

    """
    An utility function. 

    
    Parameters
    ----------

    Return value: float
        The current UTC time in decimal hours since midnight.

    
    Warning
    -------
    If Astrid is in "offline" mode, then GetUTC() will return a value of None. Attempting to validate the 
    script below without checking the return value is not equal to None while "offline" will result in an 
    infinite loop.


    Example
    -------
    
    .. code-block:: python

        while GetUTC() < 12.0 and GetUTC() != None:
            Track('0353+2234', None, 600.)

    """


def GetLST():

    """
    An utility function.

    Parameters
    ----------

    Return value: float
        The current Local Sidereal Time in decimal hours.

    
    Warning
    -------
    If Astrid is in "offline" mode, then GetLST() will return a value of None. Attempting to validate the 
    script below without checking the return value is not equal to None while "offline" will result in an
    infinite loop.

    
    Example
    -------
    The following example will repeatedly perform Track scans on the source “1153+1107” until the LST is
    past 13.5 hours when the source “1712+035” will be observed once.

    .. code-block:: python

        while GetLST() < 13.5 and GetLST() != None:
            Track('1153+1107', None, 600.)

        Track('1712+036', None, 600.)

    """


def Now():

    """
    An utility function.

    Parameters
    ----------

    Return value: 
        A UTC time object containing the UTC time and date.


    Warning
    -------
    If Astrid is in "offline" mode, then Now() will return a value of None. Attempting to validate the
    script below without checking the return value is not equal to None while "offline" will result in an
    infinite loop.

    Example
    -------
    The following example will repeatedly perform Track scans on the source “1153+1107” until
    09:54:12 UTC on 12 June 2016.

    .. code-block:: python

        while Now() < '2016-06-12 09:54:12' and Now() != None:
            Track('1153+1107', None, 600.)

    """


def WaitFor(time):

    """
    An utility function. It pauses the SB until the specified time is reached. The expected wait time is
    printed in the observation log including a warning if the wait is longer than 10 minutes. WaitFor()
    will immediately return if the specified time has already passed and is within the last 30 minutes.
    While WaitFor() has the SB paused, it does not prevent the user from aborting. However if the user
    chooses to continue once the abort is detected, then the WaitFor() abandons the wait and returns
    immediately.

    Parameters
    ----------

    time:
        A valid time object.

        .. note::

            If a value of None is used as an argument to WaitFor(), the SB will abort with a message
            to the observation log. This can occur when passing a value from Horizon().GetRise() or 
            Horizon().GetSet() when such an event may never occur, such as the rise time for a 
            circumpolar source.


    Examples
    --------
    The following example will pause the SB until a Local Sidereal Time of 15:13, then wait for the
    source “1532 3421” to rise above 10 deg elevation, and finally wait for the Sun to set below 5 deg
    elevation.

    .. code-block:: python

        #Wait for 15:13 LST
        WaitFor('15:13:00 LST')

        #Wait until source is above 10 deg elevation
        WaitFor(Horizon(10.0).GetRise('1532+3421'))

        #Wait for the Sun to set below 5 deg elevation
        WaitFor(Horizon(5.0).GetSet('Sun'))


    """

def ChangeAttenuation(devicename, attnchange):

    """
    An utility function. It allows the observer to change all the attenuators in the IF Rack or the
    Converter Rack by the same amount.

    Parameters
    ----------

    devicename: str
        Can be either 'IFRack' or 'ConverterRack'. This specifies the device in which the attenuators
        will be changed.

    attnchange: float. 
        This specifies how much the attenuators should be changed. This value can be either positive or negative.

        .. note::

            If any new attenuator setting is less than zero or exceeds the maximum value, 31 for the IF Rack
            and 31.875 for the Converter Rack, then the attenuator setting is made to be the appropriate
            limiting value.

    Examples
    --------
    The following examples adds 1 to the attenuation value in the IF rack and subtracts 0.5 from the attenuation
    value in the converter rack.

    .. code-block:: python
        
        ChangeAttenuation('IFRack', 1.0)
        ChangeAttenuation('ConverterRack', -0.5)


    """


def Location(coordinateMode, value1, value2):

    """
    A scheduling block object. It is used to represent a particular location on the sky.

    Parameters
    ----------

    coordinateMode: str
        The following modes are allowed: 
            - 'J2000'
            - 'B1950'
            - 'RaDecOfDate'
            - 'HaDec'
            - 'ApparentRaDec'
            - 'Galactic'
            - 'AzEl'
            - 'Encoder'

    value1: float or str
        A location must be specified by this value, the meaning depends on both the chosen coordinate mode
        and value type of the unit:
        
        - float value: 
            Will always denote units in degrees of arc, regardless of the coordinate mode.
            This should not be confused with decimal use in Catalogs which denote decimal hours for RA 
            and HA, and degrees of arc for all other angles.
        - sexagesimal string:
            Represents units of time for J2000, B1950, ApparentRaDec, and RaDecOfDate (i.e. 'hh:mm:ss.s')
            and degrees of arc for HaDec, Galactic, AzEl and Encoder (i.e. 'dd:mm:ss.s') 

    value2: float or str
        A location must be specified by this value, the meaning depends on both the chosen coordinate mode
        and value type of the unit:

        - float value:
            Will always denote units in degrees of arc, regardless of the coordinate mode.
            This should not be confused with decimal use in Catalogs which denote decimal hours for RA 
            and HA, and degrees of arc for all other angles.
        - sexagesimal string:
            Represents degrees of arc (i.e. 'dd:mm:ss.s')


    Examples
    --------

    .. code-block:: python

        # RA is in units of *time*, Dec is in degrees
        location = Location('J2000', '16:30:00', '47:15:00')

        # Same location - RA is in degrees, Dec is in degrees
        location = Location('J2000', 247.5, 47.25)

        # Az is in degrees, El is in degrees
        location = Location('AzEl', '45:00:00', '72:30:00')

    """


def Offset(coordinateMode, value1, value2, cosv=True):

    """
    A scheduling block object. An Offset is a displacement from the position of a source or from the
    center position of a map. Offset objects may be added to other offset objects with the same coordinate
    mode and cosv correction. Offset objects may be added to Location objects with the same coordinate 
    mode. 

    .. note:: 

        The addition is not commutative and must be of the form (Location+Offset). 
        Offset+Location will produce a validation error.

    Parameters
    ----------

    coordinateMode: str
        The following modes are allowed: 
            - 'J2000'
            - 'B1950'
            - 'RaDecOfDate'
            - 'HaDec'
            - 'ApparentRaDec'
            - 'Galactic'
            - 'AzEl' 
            - 'Encoder'

    value1: float or str
        A location must be specified by this value, the meaning depends on both the chosen coordinate mode
        and value type of the unit:
        
        - float value: 
            Will always denote units in degrees of arc, regardless of the coordinate mode.
            This should not be confused with decimal use in Catalogs which denote decimal hours for RA 
            and HA, and degrees of arc for all other angles.
        - sexagesimal string:
            Represents units of time for J2000, B1950, ApparentRaDec, and RaDecOfDate (i.e. 'hh:mm:ss.s')
            and degrees of arc for HaDec, Galactic, AzEl and Encoder (i.e. 'dd:mm:ss.s')

    value2: float or str
        A location must be specified by this value, the meaning depends on both the chosen coordinate mode
        and value type of the unit:

        - float value:
            Will always denote units in degrees of arc, regardless of the coordinate mode.
            This should not be confused with decimal use in Catalogs which denote decimal hours for RA 
            and HA, and degrees of arc for all other angles.
        - sexagesimal string:
            Represents degrees of arc (i.e. 'dd:mm:ss.s')

    cosv: bool
        It specifies whether secant minor corrections in equation the equation below should be used for the
        major axis of the coordinate system (i.e. :math:`h/cos(v)` is the offset value in the direction of h).
        Since coordinate distances and angular separations are not equivalent for spherical coordinate systems,
        the following approximations may be used for small separations:

        :math:`\Delta v = v_1 − v_2`

        and

        :math:`\Delta h = (h_1 − h_2) \\times cos(v)`, 
        
        where
        :math:`h` is the value of the major coordinate axis and
        :math:`v` is the value of the minor coordinate axis.

        For example, setting cosv=True with J2000 coordinate offsets will apply a cos(Dec) term from the second
        equation above to make maps appear rectangular if plotted with :math:`\Delta RA` vs. :math:`\Delta Dec`
        relative to a central location.

    Examples
    --------
    The script below gives examples of adding Offset objects to Location and other Offset objects. The resulting
    coordinates are printed to screen.

    .. code-block:: python

        start_location = Location('J2000','12:00:00','45:00:00')

        offset1 = Offset('J2000','00:04:00','01:00:00',cosv=False)
        offset2 = Offset('J2000', 2.0 , 2.0 ,cosv=False)
        offset3 = offset1 + offset2

        loc1 = start_location + offset1         # loc1 (RA,Dec) = (12:04:00, 45:00:00)
        loc2 = start_location - offset2         # loc2 (RA,Dec) = (11:52:00, 43:00:00)
        loc3 = start_location + offset3         # loc3 (RA,Dec) = (12:12:00, 48:00:00)

        print 'RA,Dec of loc3 = (%s,%s)'%(loc3.GetH(),loc3.GetV())

    """


def Horizon(elevation=5.25):

    """
    A scheduling block object. Observing Scripts allow an observer to specify a definition of the horizon. 
    The user defined horizon can be used to begin an observation when an object "rises" and/or end the
    observation when it "sets" relative to the specified elevation of the “horizon”. The Horizon object
    may be used to obtain the initial time that a given source is above the specified horizon (including 
    an approximate atmospheric refraction correction).

    
    Parameters
    ----------

    location:
        A Catalog source name or Location object using a spherical coordinate mode. Horizon() will not work
        with planets and ephemeris tables.

    elevation: float. 
        The Horizon elevation in degrees. The default is 5.25 (the nominal GBT horizon limit).

        
    Return Value: 
        A UTC time object containing the UTC time and date.

        .. admonition:: Horizon(elevation).GetRise(location)

            Will return the most recent rise time if the source is currently above the horizon, or the next
            rise time if the source has not yet risen. GetRise(source) will return None if the source never
            rises and the current time if the source never sets.


        .. admonition:: Horizon(elevation).GetSet(location)

            Will return the next set time of the source. GetSet(source) will return None if the
            source never sets and the current time if the source never rises.


    Examples
    --------
    Any Horizon object may be substituted as a start or stop time in scan types, such as Track(). The script
    below will display the time when VirgoA rises above 20◦ elevation. Depending on the position of the source
    at the time of execution, the SB would then either begin a Track() scan immediately or wait for VirgoA
    to rise above 5.25◦ elevation before beginning the scan. In both cases, the SB would terminate the next 
    time VirgoA sets below 5.25◦ elevation.

    .. code-block:: python

        print Horizon(20.0).GetRise('VirgoA')

        h = Horizon()                           #default horizon of 5.25 degrees elevation  
        Track('VirgoA', None, startTime=h, stopTime=h)

    """


def TimeObject():

    """
    The Time Object is primarily used for defining scan start or stop times. The time may be represented as
    either a sexegesimal string or in a python mxDateTime object. You can learn more about mxDateTime at
    http://www.egenix.com/files/python/mxDateTime.html.

    .. note::

        One must access the python DateTime module directly from an observation script to generate
        time objects, i.e., using from mx import DateTime.

    The Time Object can be expressed in either UTC or LST. The time can be either absolute or relative.
    An absolute or dated time specifies both the time of day and the date. An absolute time may be
    represented by either a sexagesimal string, i.e., "yyyy-mm-dd hh:mm:ss" or by a DateTime object. 
    Relative or dateless times are specified by the time of day for "today". "WaitFor" will treat a dateless 
    time that is more than 30 minutes in the past as being in the future, i.e., the next day. Relative times 
    may be represented by either a sexagesimal string, i.e., "hh:mm:ss" or a DateTimeDelta object. For UTC
    times, the sexagesimal representation may include a “UTC" suffix. Note that mxDate-Time objects are always
    UTC. LST time may only be used with relative times and the sexagesimal representation must include a "LST"
    suffix. Time Objects can have slightly varying formats and can be created in a few different ways.

    Some examples are
        - Absolute time in UTC represented by a string: 
            **"2006-03-22 15:34:10"**
        - Relative time in UTC as a mxDateTime object: 
            **DateTime.TimeDelta(12, 0, 0)**
        - Absolute time in UTC represented by a string: 
            **"2006/03/22 15:34:10 UTC"**
        - Relative time in LST as a string: 
            **"22:15:48 LST"**
        - Absolute time in UTC as a mxDateTime object: 
            **DateTime.DateTime(2006, 1, 21, 3, 45, 0)**
        
    Examples
    --------
    In this example we will continue to do one minute observations of srcA until Feb 12, 2016 at 13:15 UTC when
    we will then do a ten minute observations of srcB. 

    .. code-block:: python

        from mx import DateTime

        switchTime=DateTime.DateTime(2016,2,12,13,15,0) # Feb 12, 2016, 13:15 UTC

        while Now() < switchTime and Now() != None:
            Track(srcA, None, 60)

        Track(srcB, None, 600)

    """


def CalSeq(type, scanDuration, location=None, beamName=None, fixedOffset=None, 
           tablePositionList=None, dwellFractonList=None):

    """
    The CalSeq procedure is used to calibrate W-band data. This procedure should be
    run after every configuration and balance. This is needed to convert instrumental 
    counts into antenna temperatures.

    Parameters
    ----------

    type: 
        string keyword to indicate type of calibration scan: manual, auto, autocirc

        - "manual" -- A separate scan will be done for each table position. The user can
          input a list of calibration table wheel positions with the tablePositionList argument.
        - "auto" -- default dwell fraction =(0.33, 0.33, 0.34) and default three
          positions = (Observing, Cold1, Cold2). The user can specify a list of positions and 
          dwell times with the tablePostionList and dwellFractionList arguments.
        - "autocirc" -- dwell fraction =(0.25, 0.25, 0.25, 0.25) and four positions = 
          (Observing, [Position2 for beamName='1' or Position5 for beamName='2' for use 
          with circular VLBI observations], Cold1, Cold2).
    
    scanDuration:
        scan exposure time, in seconds. For manual mode, each specified position will be
        observed for the scan exposure time (i.e., separate scans for each position). For 
        auto modes, the total scan exposure time will be divided between positions based
        on the dwell fractions (i.e., one scan for all positions).

    location:
        a Catalog source name or Location object; default is None (use current location).
    
    beamName: 
        Beam name associated with pointing location. This argument is a string.
        Default beam is '1'.
    
    fixedOffset: 
        offset sky position (used in cases when observing a bright source and want to measure
        the system temperature of the sky off-source). This argument should be an Offset 
        object. Default sky offset is 0.
    
    tablePositionList: 
        user-specified, variable-length ordered list of cal table positions for the manual
        or auto modes.  The default sequence is ['Observing', 'Cold1', 'Cold2'].
    
    dwellFractionList:
        user-specified, ordered list of dwell fractions associated with the tablePositionList 
        for use only with the auto mode. By using auto mode with tablePositionList and 
        dwellFractionList, expert users can control the wheel in any order of positions
        and dwell fractions. This input is not needed for autocirc or manual modes and is
        ignored in these modes if given.


    Examples
    --------


    .. code-block:: python
        
        # This command can be used for most observations, which uses
        # the default tablePositionList=['Observing', 'Cold1', 'Cold2'].

        CalSeq("auto", 45.0)           

        # This command can be used for bright objects where one wants a 
        # system temperature measurement on blank sky.  In this example, 
        # the offset is $2^{\prime}$ to the north.  If observing a 
        # large object, one can increase the offset size to move off-source 
        # for the blank-sky measurement.

        CalSeq("auto", 45.0, fixedOffset=Offset("J2000", "00:00:00", "00:02:00"))

        # This is an example command for calibration of VLBI observations with beam-1 
        # circular polarization. We can only observe the cold and ambient loads with 
        # linear  polarization.  The calibration from linear to circular requires 
        # observations of the same sky with both linear and circular polarization 
        # (Observing and Position2, respectively, in this example).

        CalSeq("manual", 10.0, tablePositionList=['Position2', 'Observing', 'Cold1', 'Cold2'])
    """

def ResetConfig():

    """

    """



def Configure(action):

    """


    Parameters
    ----------

    action: str
        For each configuration, all keywords and values exist as line separated
        keyword=value pairs, all enclosed within a single set of triple-quotes.

        For a list of all keywords see :ref:`here <references/observing/configure:Configuration keywords>`.

    Example
    -------

    .. code-block:: python

        # An SB to configure only 

        myconfiguration = '''
        #This is a comment (ignored by software)
        primarykeyword1 =  your primarykeyword value
        primarykeyword2 = your primarykeyword value
        ...
        ...
        primarykeywordN = your primarykeyword value
        '''

        Configure(myconfiguration)
    """


def execfile():

    """
    Built-in function in python 2 that allows the execution of a python script from a file
    within the current program's namespace. 

    Example
    -------

    .. code-block:: python

        execfile('my_script.py') 
        execfile('my_configurations.config')    # file ending does not need to be .py
    """


def GetValue(manager, parameter):

    """ 
    Function for advanced GBT users. GetValue can be used to retrieve any parameter or sampler value 
    within the Monitor and Control (M&C) system.

    Parameters
    ----------

    manager: str
        The manager in the M&C system such as 'scanCoordinator'.

    parameter: str
        The name of the parameter or sampler value to retrieve. This may be a composite 
        string in the form of 'parameter,parameter_field'.

    Returns
    -------

    value: str
        If you need the return value to be another data type such as an integer or float, 
        please consult your favorite Python manual to find out how to use conversion 
        operators.

    Examples
    --------

    Please consult with your project friend.

    .. code-block:: python

        current_source = GetValue('ScanCoordinator','source')
        current_El_lpc = GetValue('Antenna','localPointingOffsets,elOffset')

    """


def SetValue(manager, parameter):

    """
    Function for advanced GBT users. SetValue can be used to directly set any of the parameters within the
    Monitor & Control (M&C) system. As a result, it is used to support complex configurations
    and expert observations. Please note that SetValues() does not always issue a "prepare" on
    the M&C manager containing the parameter. If you with to do a "prepare", you can also use 
    SetValue() to do that as well, but it needs to be a separate command.

    Parameters
    ----------

    manager: str
        The manager containing the parameter in the M&C system.

    paramDict:  dict
        A dictionary containing the parameter string as a key (can be of the form 'parameter,parameter_field')
        and the actual value to set. Data types depend on the parameter.

    Examples
    -----

    Please consult with your project friend! 

    .. code-block:: python

        lfcValues = {
            'local_focus_correction,Y': -7.469,             # in mm
            'localPointingOffsets,azOffset2': 9.8902e-06,   # in radians
            'localPointingOffsets,elOffset': 7.27221e-05}   # in radians

        SetValues('Antenna', lfcValues)
        SetValues('Antenna', {'state': 'prepare'})

    """


def DefineScan(scanName, filepath):

    """
    Function for advanced GBT users. If you have written your own scan type
    using the Python language, the DefineScan() function is used to load your 
    new scan type into the current SB. Once loaded, it can be referred to by 
    name, just like any other scan type.

    Parameters
    ----------

    scanName: str
        Specifies a name for the scan.

    filepath: str
        Specifies the full filepath to the scan. 


    Examples
    --------

    .. code-block:: python

        # The following example defines and then executes a scan used primarily
        # with MUSTANG-2 observations.

        DefineScan('boxtraj', '/users/bmason/gbt-dev/scanning/ptcsTraj/boxtraj.py')

        boxtraj(mySrc, x0=x0, y0=y0, taux=taux, tauy=tauy, scanDuration=scandur, 
                dx=dx, dy=dy)

    """ 


def GetCurrentLocation(coordinateMode):

    """ 
    Function for advanced GBT users. Given a coordinate mode, GetCurrentLocation() 
    returns a Location object.

    Parameters
    ----------

    coordinateMode: str
        Specifies the coordinate mode of the Location object in the return value.
        Available coordinate modes are

        * ``'J2000'``
        * ``'B1950'``
        * ``'RaDecOfDate'``
        * ``'HaDec'``
        * ``'ApparentRaDec'``
        * ``'Galactic'``
        * ``'AzEl'``
        * ``'Encoder'``
        

    Returns
    -------
        
        Location object: obj 
            contains the coordinates of the currently selected receiver
            beam's position on the sky (as selected in the most recent scan type).


    Example
    -------

    .. code-block:: python

        # print the current coordinates in azimuth and elevation.
        # Note that GetH() and GetV() return float values for the major and minor
        # axis coordinate of Location and Offset objects.

        location = GetCurrentLocation('AzEl')
        print 'Az = %s, El = %s' % (location.GetH(), location.GetV())
    
    """ 


def SetSourceVelocity(velocity):

    """
    Function for advanced GBT users. The SetSourceVelocity() function sets the 
    LO1 source velocity directly, in units of km/s. If you include the source 
    velocities in your catalog, then you do not need to use this function. 

    Parameters
    ----------

    velocity: float
        Source velocity in km/s.

    Examples
    --------

    .. code-block:: python

        SetSourceVelocity(10.5)


    """


def Spider(location, startOffset, scanDuration, slices=4, beamName='1', 
           unidirectional=True, cals='both', calDuration=10.):

    """
    Specialty Scan Type. Spider() executes the specified number of slices of duration 
    ``scanDuration`` through the specified location. each slice is of length 2* 
    ``startOffset``. The argument startOffset also specifies the angle of the initial 
    slice. The use may specify unidirectional or bidirectional subscans of length
    ``calDuration`` and when to run calibration subscans relative to each slice, i.e. 
    at ``'begin'``, ``'end'``, or ``'both'``.

    Parameters
    ----------

    location: str or obj
        Catalog source name or Location object. Is specifies the source which is to be 
        tracked.

    startOffset: Offset obj
        It specifies the 1/2 length of the subscans and the angle from location of the
        initial subscan. For example, if ``startOffset = Offset('AzEl', '00:40:00', '00:00:00', cosv=True)``
        then the first leg of the scan would start at +40' in azimuth (from the location)
        and would complete t -40' in Az. If instead you used 
        ``startOffset = Offset('AzEl', '00:40:00', '00:40:00', cosv=True)`` the first 
        leg would start at Az=+40', El=+40', and would go to the opposite (Az=-40', El=-40')

    scanDuration: float
        Specifies the length of the subscans in seconds.

    slices: int
        Specifies the number of subscans through location. the default is 4 (making a 
        spider shape - i.e. eight legs).

    beamName: str
        Specifies the receiver beam to use for the scan. ``beamName`` can be ``'C'``,
        ``'1'``, ``'2'``, ``'3'``, ``'4'`` or any valid combination for the receiver
        you are using such as ``'MR12'``. The default is ``'1'``.

    unidirectional: bool
        Specifies whether each slice is scanned once in one direction or twice in both 
        directions. The default is True (one direction).

    cals: str
        Specifies the order of calibration subscans, i.e. at the beginning of the slice
        subscan (``'begin'``), at the end of the slice subscan (``'end'``) or both (``'both'``).
        The default is ``'both'``.

    calDuration: float
        Specifies the length of the calibration subscan in seconds. The default is 10.

    
    Example
    -------

    .. code-block:: python

        # Subscans through 3C 286 starting the first leg 40' from the source's "right".

        Spider('3C286', Offset('AzEl', '00:40:00', 0.0, cosv=True), 80)


    This is the source's trajectory on the sky. Black crosses mark timestamps, of data sampled
    along the red trajectory.

    .. image:: /../sparrow/images/spider.jpg

    """


def Z17(location, startOffset, scanDuration, beamName='1', calDuration=10.0):

    """
    Specialty Scan Type. Z17() executes two circles of point subscans around location at 
    :math:`45^\circ` intervals. The first circle with a radius of ``startOffset`` and the 
    second circle at a radius of :math:`\sqrt{2}` * ``startOffset``. The initial subscan
    is at the angle specified bu the ``startOffset``. After circling twice, the procedure
    executes a subscan on location. The entire set of 17 subscans each of length 
    ``scanDuration``, is sandwiched between two cal subscans of length ``calDuration``
    which consist of equal parts calibration noise signal on and off.


    Parameters
    ----------

    location: str or obj
        A Catalog source name or Location object. Specifies the source which is to be tracked.

    startOffset: obj
        An Offset object. Specifies the angle from location of the initial subscan as well as
        the radius of the inner circle.

    scanDuration: float
        Specifies the length of the subscans in seconds.

    beamName: str
        Specifies the receiver beam to use for the scan. ``beamName`` can be ``'C'``, ``'1'``, 
        ``'2'``, ``'3'``, ``'4'`` or any valid combination for the receiver you are using such
        as ``'MR12'``. The default is ``'1'``.

    calDuration: float
        Specifies the length of the calibration subscan in second. The default is 10.0.


    Example
    -------

    .. code-block:: 

        # subscan points around G135.1+54.4 starting the first circle at the source's "right". 

        Z17('G135.1+54.4', Offset('AzEl', '00:04:30', '00:00:00', cosv=True), 10)


    This is the actual trajectory on the sky. Black crosses mark timestamps of data sampled
    along the red trajectory.

    .. image:: /../sparrow/images/z17.jpg

    """



