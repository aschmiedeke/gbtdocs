.. _glossary:

#############################################
:octicon:`rocket;2em;sd-color-muted` Glossary
#############################################

.. |airmass| replace:: :math:`A`
.. |degree| unicode:: U+00B0 .. degree
.. |tau| replace:: :math:`\tau`
.. |Trec| replace:: :math:`T_{rec}`
.. |Tsrc| replace:: :math:`T_{src}`
.. |Tsys| replace:: :math:`T_{sys}`


.. glossary :: 


    |airmass|
        The number of air masses along the line of sight. One air mass is defined 
        as the total astmospheric column when looking at the zenith.

    ADC
        Analog to Digital Converter. A card used to convert an analog signal into 
        a quantized digital signal. Each VEGAS bank contains two ADC cards, one 
        for each polarization. 

    Analog Filter Rack
        A rack in the GBT IF system that contains filters to provide the DCR with
        signals of the proper bandwidth.

    API
        Application Programming Interface. A set of routines, protocols and tools
        that can be used when building software and applications for a specific
        system.

    Argus
        (**not** an acronym) is a high-frequency receiver covering 74 - 116 GHz.

    AS
        Active Surface. The surface panels on the GBT whose corner heights can be
        adjusted to form the best possible paraboloidal surface. 

    AstrID
        Astronomer's Integrated Desktop The software tool used for executing
        observations with the GBT.

    baseline
        Baseline is a generic term usually taken to mean the instrumental plus continuum
        bandpass shape in an observed spectrum, or changes in the background level in a 
        continuum observation.

    beam switching
        The Ka-band (26-40 GHz) receiver is the only receiver that can perform beam 
        switching. The switching can route the inputs of each feed to one of two "first
        amplifiers" which allows

    beam-width
        The :term:`FWHM` of the Gaussian response to the sky, the beam, of the GBT.

    C-band
        A region of the electromagnetic spectrum covering 4-8 GHz.

    CCB
        Caltech Continuum Backend. A wideband continuum backend designed for use with the GBT
        Ka-band receiver.

    CLEO
        Control Library for Engineers and Operators. A suite of utilities for monitoring and 
        controlling the GBT hardware systems.

    Converter Rack
        A rack in the GBT :term:`IF system` that receives the signal from the optical fibers
        (sent from the :term:`IF rack`), mixes the IF signal with :term:`LO2` and :term:`LO3`
        references, and then distributes teh IF signal to the various backends.

    DCR
        The Digital Continuum Receiver. A continuum backend designed for use with any of
        the GBT receiver.

    DDC
        Digital Down Converter. Converts a digitized real IF signal to a complex baseband
        signal.

    DDT
        Director's Discretionary Time.

    DSS
        Dynamic Scheduling System. The Dss examines the weather forecast, equipment availability,
        observer availability, and other factors in order to generate an observing schedule.

    Dynamic Corrections
        A system that uses temperature sensors located on the backup structure of the GBT 
        to correct for deformations in the surface, and deformations that change the pointing
        and focus of the GBT.

    EVN
        Eurpean VLBI Network. A collaboration of the major radio astronomical institutes 
        in Europe, Asia, and South Africa.

    FAA
        Federal Aviation Administration. The U.S. Governtment agency that oversees and regulates
        the airline industry in the U.S. 

    FEM
        Finite Element Model. This is a model for how the GBT support structure changes shape
        due to gravitational forces at different elevation angles. 

    FET
        Field Effect Transistor. A type of amplifier used in the receivers.

    FPGA
        Field-Programmable Gate Array. An integrated circuit designed to be programmed in 
        the field after manufacture.

    frequency switching
        A calibration method that obtains blank sky information while keeping the telescope
        pointed at the object of interest. The central frequency is shifted such that the 
        desired spectral lines appear at different locations within the bandpass shape.

    FRM
        Focus Rotation Mount. A mount that holds the Prime Focus Receivers which allows the
        receivers to be moved and rotated relative to the focal point. the FRM has three degrees
        of freedom, Z-axis radial focus, Y-axis translation (in the direction of the dish plane 
        of symmetry) and rotation.

    FWHM
        Full Width at Half Maximum. Used as a measure for the width of a Gaussian.

    GBT
        Green Bank Telescope.

    GBTIDL
        Green Bank Telescope Interactive Data Language. The GBT data reduction package written in 
        :term:`IDL` for analyzing GBT spectral line data.

    GFM
        GBT Fits Monitor. The software program that provides a real time display for GBT data.

    GO
        GBT Observing.

    GUI
        Graphical User Interface.

    GUPPI
        The Green Bank Ultimate Pulsar Processing Instrument. A now-retired :term:`FPGA` + GPU 
        backend previously used for GBT pulsar observations.

    IDL
        The Interactive Data Language program of ITT Visual Information Solutions.

    IF
        Intermediate Frequency. A frequency to which the Radio Frequency (:term:`RF`) is shifted
        as an intermediate step before detection in the backend. Obtained from mixing the RF signal
        with the :term:`LO` signal.

    IF system
        Intermediate Frequency system. A general name for all the electronics between the receiver
        and the backend. These electronics typically operate using an Intermediate Frequency (:term:`IF`).

    IF rack
        A rack in the GBT :term:`IF system` where the IF signal is distributed onto optical fibers
        and sent from the GBT receiver room to the GBT equipment room where the backends are located. 
        A signal may also be sent directly to the :term:`DCR`.

    IF path
        Intermediate Frequency path. The actual signal path between the receiver and the backend 
        through the IF system.

    ITRF
        International Terrestrial Reference Frame. A world spatial reference system co-rotating with
        the Earth in its diurnal motion in space.

    JD
        Julian Date. A continuous count of days since the beginning of the Julian period
        (12h Jan 1, 4713 BC).

    K-band
        A region of the electromagnetic spectrum covering 18-26 GHz.

    Ka-band
        A region of the electromagnetic spectrum covering 26-40 GHz.

    KFPA
        The K-band Focal Plane Array receiver covering 18-26.5 GHz.
       
    Ku-band
        A region of the electromagnetic spectrum from 12-18 GHz.

    L-band
        A region of the electromagnetic spectrum covering 1-2 GHz.
    
    LFC
        Local Focus Correction. Corrections for the general telescope focus model that are measured
        by the observer.

    LO
        Local Oscillator. A generator of a stable, constant-frequency radio signal used as a
        reference for determining which radio frequency to observe.

    LO1
        The first :term:`LO` in the GBT :term:`IF system`. This LO is used to convert the :term:`RF`
        signal detected by the receiver into the :term:`IF` sent through the electronics to the backend.
        This is also the LO used for Doppler Tracking.

    LO2
        Second :term:`LO`. The second LO in the GBT :term:`IF system`. This is actually a set 
        of eight different LOs that can be used to observe up to eight different spectral windows 
        at the same time.

    LO3
        Third :term:`LO`. The third LO in the GBT :term:`IF system` which operated at a fixed frequency
        of 10.5 MHz

    LPC
        Local Pointing Correction. Corrections for the general telescope pointing model that 
        are measured by the observer.

    LST
        Local Sidereal Time. A time scale based on the Earth's rate of rotation measured relative
        to the fixed stars rather than the Sun.

    M&C
        Monitor and Control. The suite of software programs which control the hardware devices 
        which comprise the GBT.

    MJD
        Modified Julian Date. MJD = Julian Date (JD) - 2,400,000.5

    MUSTANG-2
        The MUltiplexed SQUID TES Array at Ninety GHz bolometer receiver operatint at 75-105 GHz.

    NAD83
        North American Datum of 1983. An earth-centered model for the Earth's surface based on
        the Geodetic Reference System of 1980. The size and shape of the Earth was determined 
        through measurements made by satellites and other sophisticated electronic equipment; 
        the measurements accurately represent the Earth to within two meters.

    NAVD88
        The North American Vertical Datum of 1988.        
        
    noise diode
        A device with known effective temperature that is coupled to the telescope system to 
        give a measure of system temperature (:term:`Tsys`). When the telescope is pointed on
        blank sky, the noise diode is turned on and then off to determine the off-source system
        temperature. This device is alo refered to  as the "Cal".

    NRAO
        National Radio Astronomy Observatory. The organization that operates the VLA, VLBA and 
        the North American part of ALMA, and formerly operated the GBT until the Green Bank
        Observatory (GBO) became a separate entity in 2016. GBO and NRAO reunited in 2024.

    NRQZ
        National Radio Quiet Zone. An area (~34,000 km\ :math:`^2`) around the GBT set up by the
        U.S. government to provide protection from RFI.

    OMT
        Ortho-Mode Transducer. This is part of the receiver that takes the input from the
        wave-guide and separates the two polarizations to go to separate detectors.

    OOF
        Out-of-focus holography. A technique for measuring large-scale errors in the shape of the 
        reflecting surface by mapping a strong ppoint source both in and out of focus.

    OTF
        On-the-fly. On-the-fly mapping scans take data while the telescope pointing moves between 
        two points on the sky. This move is usually done in a linear fasion with constant slewing
        speed with respect to the sky.

    P-band
        A region of the elescromagnetic spectrum covering 300-1000 MHz. Also known as the Ultra
        High Frequency (UHF) band in the U.S. (Sometimes P-band is considered to be a narrow region
        around 408 MHz, while A-band is the region around 600 MHz).

    PF1
        The first of two prime focus receivers for the GBT. This receiver has four different
        bands: 290-395, 385-520, 510-690 and 680-920 MHz.

    PF2
        The second of two prime focus receivers for the GBT. This receiver covers 901-1230 MHz.

    PI
        Principal Investigator.

    polarization switching
        This is only available for the L and X-band receivers. During an observation and at a
        rate of about once per second, the polarization fo the observation is switched between 
        two orthogonal linear polarizations or the two circular polarizations. This switching 
        method is  used almost exclusively for Zeeman measurements. 

    position switching
        A calibration method that involves observing an object of interest for a period of time, 
        and then moving the telescope to a blank sky region to obtain the blank sky observations 
        necessary for baseline subtraction. Nodding is a form of position switching. Position
        switching is done via an observing routine and is not setup in hardware unlike other
        switching schemes.

    PROCNAME
        A GO FITS file keyword that contains the name of the Scan Type used in :term:`AstrID` to 
        obtain the data.

    PROCSEQN
        A GO FITS file keyword that contains the current number of scans done of the total scans
        given by :term:`PROCSIZE`in a givcen Scan Type.

    PROCSIZE
        A GO FITS file keyword that contains the number of scans that are to be run as part of
        the Scan Type given by :term:`PROCNAME`.

    Q-band
        A region of the electromagnetic spectrum from 40-50 GHz.

    RDBE
        A Roach Digital Backend, where ROACH is the core board containing a large :term:`FPGA`.

    RF
        Radio Frequency. The frequency of the incomin radiation detected by the GBT.

    RFI
        Radio Frequency Interference. Light pollution at radio wavelengths.

    S-band
        A region of the electromagnetic spectrum covering 2-4 GHz.

    SB
        Scheduling Block. A python script used to perform astronomical observations with the GBT.

    |tau|
        The opacity of the atmosphere.

    |Trec|
        The equivalent blackbody temperature birghtness that the GBT receiver contributes to the
        detected signal.

    |Tsrc|
        The equivalent blackbody temperature brightness from the astronomical source.

    |Tsys|
        The total equivalent blackbody temperature brigtness that the GBT sees. Depending on usage
        it may or may not include :math:`T_{src}`.

    TLE
        Two-Line Element.

    total power
        Spectral-line observing typically requires differencing "signal" and "reference"
        observations so as to remove the instrumental bandpass shape. In total power observing,
        the refrence observations are either separate scans (as aquired with, for example,
        :term:`AstrID`'s :func:`OnOff() <astrid_commands.OnOff>` or :func:`OffOn() <astrid_commands.OffOn>`
        observing directives), as separate integrations in an on-the-fly (:term:`OTF`)
        observation (for example as edge pixels in a map), or as separate integrations
        in some types of subreflector nodding observations. "Switched Power", the alternative to
        "Total Power", provides faster switching between signal and reference observations but,
        in some cases, worse baseline shapes.

    UTC
        Coordinated Universal Time. The mean solar time at 0\ |degree|  longitude.

    VEGAS
        The GBT spectral line backend.

    :math:`v_{relativistic}`
        The velocity of a source using the relativistic definition of the velocity-frequency
        relationship.

    :math:`v_{optical}`
        The velocity of a source using the optical definition of the velocity-frequency
        relationship.

    :math:`v_{radio}`
        The velocity of a source using the radio definition of the velocity-frequency
        relationship.

    VLB
        Very Long BaselineL A general acronym for VLBI or VLBA.

    VLBA
        Very Long Baseline Array: An interferometer run by the NRAO.
    
    VLBI
        Very Long Baseline Interferometer: The use of unconnected telescopes to form an
        effective telescope with the size of the separation between the elements of the
        interferometer.

    VNC
        Virtual Networt Computing. A GUI based system that is platform independent that
        allows you to view the screen of one computer on a second computer. THis is very
        useful for remote observing and an alternative to FastX.

    W-band
        A region of the electromagnetic spectrum covering 75-111 GHz.

    X-band
        A region of the electromagnetic spectrum covering 8-12 GHz.
