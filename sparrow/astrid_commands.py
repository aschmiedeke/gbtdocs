def Peak(location, hLength=None, vLength=None, scanDuration=None, 
         beamName=None, refBeam=None, elAzOrder=False):



    """
    A utility scan. Peak scan type sweeps through the specified sky location in the four cardinal directions.
    Its primary use is to determine pointing corrections for use in subsequent scans.

    
    Parameters
    ----------
    location : str
        Catalog source name or Location object. It specifies the source upon which to do the scan.

    hLength : Offset object
        Specifies the horitzontal distance used for the Peak. hLength values may be negative.
        The default value is the recommended value for the receiver.

    vLength : Offset object
        Specifies the vertical distance used for the Peak. vLength calues may be negative. 
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
        hLength, vLength and scanDuration should be overridden as a unit since together they determine the rate.

    

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
    A Utility Scan. Focus scan type moves the subreflector or prime focus receiver (depending on the receiver in use)
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
    A utility scan. Tip scan moves the beam on the sky from one elevation to another
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
        '1', '2', '3', '4' or any valid combination for the receiver you are using such as 'MR12' (i.e. track halfway between beams 1 and 2). 

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
    A utility scan. Slew moves the telescope beam to point to a specified locaiton on 
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
    A utility scan. The Balance() command is used to balance the electronic signal 
    throughout the GBT IF system so that each devise is operating in its linear response
    regime. Balance() will work for any device with attenuators and for a particular
    backend. Individual devices can be balanced such as Prime Focus receivers, the
    IF system, the DCR, and VEGAS. The Gregorian receivers lack attenuators and do
    not need to be balanced. If the argument to Balance() is blank (recommended usage),, 
    then all devices for the current state of the IF system will be balanced using the
    last executed configuration to decide what hardware will be balanced.


    **Advanced Syntax**

    Use only if you really know what you're doing.

    .. code-block:: python

        Balance('DeviceName', {'DeviceKeyword': Value})



    Examples
    _________

    
    .. code-block:: python

        # example showing the expected use of Balance()

        # load configuration
        execfile('/home/astro-util/projects/GBTog/configs/tp_config.py') 
        Configure(tp_config)

        # Slew to target so that you may balance "on source"
        Slew('3C286')

        # Balance IF and devices for specified configuration
        Balance()


    """



def BalanceOnOff(location, offset=None, beamName='1'):

    """
    A utility scan. When there is a large difference in power received by the GBT between two positions
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
    The Track scan type follows a sky location while taking data.
    
    
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
        The value may be.

    stopTime: Time object
        This specifies when the scan completes. If stopTime is in the past then the scan is skipped with
        a message to the observation log.

    fixedOffset: Offset object
        Track follows the sky location plus this fixed Offset. The fixedOffset may be in a different
        coordinate mode than the location. If an endOffset is also specified, Track starts at 
        (location+fixedOffset), and ends at (location+fixedOffset+endOffset). The fixedOffset and
        endOffset must be both of the same coordinate mode, buyt may be of a different mode than the
        location. The fixedOffset parameter may be omitted.
        

    Note
    -------

        Scan timing must be specified by either a scanDuration, a stopTime, a startTime plus stopTime,
        or a startTime plus scanDuration. 
        

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
    The OnOff scan type performs two scans. The first scan is on source, and the second scan is
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

        # OnOff scan with reference offsets of 1 degree in RA and 1 deg in Dec with a 60 s scan duration using beam 1.
        OnOff('0137+3309', Offset('J2000', 1.0, 1.0, cosv=False), 60, '1')

    """



def OffOn(location, referenceOffset, scanDuration=None, beamName='1'):
    
    """
    The OffOn scan type is the same as the OnOff scan except that the first scan is offset from the source location. 
    
    
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

        # OffOn scan with reference offsets of 1 degree in RA and 1 deg in Dec with a 60 s scan duration using beam 1.
        OffOn('0137+3309', Offset('J2000', 1.0, 1.0, cosv=False), 60, '1')

    """


def OnOffSameHA(location, scanDuration, beamName='1'):
    
    """
    The OnOffSameHA scan type performs two scans. The first scan is on the source and the
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
    The Nod procedure does two scans on the same sky location with different beams.

    

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
    For multi-beam receivers SubBeamNod causes the subreflector to tilt about its axis
    between two feeds at the given periodicity. The primary mirror is centered on the
    midpoint between the two beams. The beam selections are extracted from the scan's 
    beamName, i.e. 'MR12'. The "first" beam ('1') performs the first integration. The
    periodicity is specified in seconds per nod (half-cycle). A subBeamNod is limited
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

    nodLengt: depends on unit of nodUnit (int for 'integrations', float or int for 'seconds')
        It specifies the half-cycle time which is the time spent in one position plus move
        time to the second position.

    nodUnit: str
        Either 'integrations' or 'seconds'. 


    Examples
    _________

    
    .. code-block:: python

        # nodLength units in second
        SubBeamNod('3C48', scanDuration=60.0, beamName='MR12', nodLength=4.4826624)

        # nodLength units are 'tint' as set in the configuration
        SubBeamNod('3C48', scanDuration=60.0, beamName='MR12', nodLength=3, nodUnit='integrations')


    Hint
    _____
    

        The scan will end at the end of the scanDuration (once the current integration is complete)
        regardless of the phase of the nod cycle. When the subreflector is moving the entire
        integration during which this occurs is flagged. It takes about 0.5 seconds for the 
        subreflector to move between beams plus additional time to settle on source (total time 
        is about ~1.5 second).
            
        For example, if we had previously configured for Rcvr26 40 and an integration time of
        1.5 sec- onds (tint=1.5 in the configuration), example 2 in script 7.49 would blank roughly
        one out of every three integrations in a half-cycle (nodLength=3) while the subreflector was
        moving between beams. If nodLength=5, then only one in five integrations would be blanked.
        A resonable compromise in terms of performance and to minimize the amount of data blanked
        is to use subBeamNod with an integration time of 0.2s and a nodLength=30 (6 sec nodding 
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

    





def DecLatMap(location, hLength, vLength, hDelta, scanDuration,
              beamName = "1", unidirectional = False, start = 1,
              stop = None):

    """
    A Declination/Latitude map, or DecLatMap, does a raster scan centered on
    a specific location on the sky.  Scanning is done in the declination, 
    latitude, or elevation coordinate depending on the desired coordinate mode.
    This procedure does not allow the user to periodically move to a reference
    location on the sky, please see DecLatMapWithReference for such a map.
    The starting point of the map is at (-hLength/2, -vLength/2).
    """

    """
    A really simple class.

    Args:
        foo (str): We all know what foo does.

    Kwargs:
        bar (str): Really, same as foo.

    """

