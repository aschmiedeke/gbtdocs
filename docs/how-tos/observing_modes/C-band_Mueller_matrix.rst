##############################
How to derive a Mueller matrix
##############################


The instructions below will run you through the steps required to setup your scheduling blocks to execute the observations required to measure the Mueller matrix for the C-band receiver.


Observing Script
================

At the GBT we use AstrID to prepare and execute scheduling blocks.


Catalog
-------
Before you start writing your scheduling block it is helpful to prepare a source catalog. We will write the catalog in our scheduling block. For measuring a Mueller matrix it is important to select a polarized source. 3C286 and 3C138 are good choices.

.. code-block:: python

    source_catalog = """
    format = spherical 
    coordmode = J2000
    HEAD = NAME    RA              DEC        
    3C286          13:31:08.28     +30:30:32.9
    3C138          05:21:09.88     +16:38:22.0
    """


Configuration
-------------
Next we will define the configuration for the observations.


.. code-block:: python

    config = """
    receiver           = 'Rcvr4_6'                       # C-band receiver
    obstype            = 'Spectroscopy'                  # Specifies spectral line observations
    backend            = 'VEGAS'                         # Specifies spectral line backend
    restfreq           = 4500, 5100, 5800, 6700, 7400    # Specifies rest frequencies (MHz)
    bandwidth          = 1080                            # Specifies spectral window width (MHz)
    nchan              = 16384                           # Specifies number of channels in spectral window
    vegas.subband      = 1                               # Specifies single or multiple spectral windows (1 or 8)
    swmode             = 'tp_nocal'                      # Specifies switching mode, switching power with no noise diode
    swtype             = 'none'                          # Specifies type of switching, no switching
    tint               = 3                               # Specifies integration time (seconds; integer multiple of swper)
    swper              = 3                               # Specifies length of full switching cycle (seconds)
    vframe             = 'topo'                          # Specifies velocity reference frame
    vdef               = 'Radio'                         # Specifies velocity definition
    noisecal           = 'hi'                            # Specifies level of the noise diode, use ‘hi’ for measuring a Mueller matrix
    pol                = 'Linear'                        # Specifies ‘Linear’ or ‘Circular’ polarization
    vegas.vpol         = 'cross'                         # Specifies recording of the full Stokes polarization products
    dopplertrackfreq   = 5800                            # Specifies the frequency used for Doppler tracking (MHz)
    """

For measuring a Mueller matrix all four Stokes products have to be recorded (`vegas.vpol='cross'`) using the high power noise diode (`noisecal='hi'`) to have a higher signal-to-noise when fitting for the phase slope between polarizations. As will be discussed later, the integration time should be choosen so that enough samples are recorded over the beam with an appropriate signal-to-noise.


Scheduling Block
----------------

Now we have the ingredients required to build a scheduling block. We will use the catalog and configuration we defined previously and also incorporate the observing procedures. For this observation we will use the polarized source as our calibrator.

For observations using the `Spider` scan the default behavior is that the telescope will cross over the specified `location` four times (`slices=4`), creating eight spider legs over the source. 
The time it takes to complete a leg is set in seconds by the `scanDuration` argument. 
The length of each leg is specified by the `startOffset` argument, and it defines half of the length of the leg.
That is, if we use `startOffset=Offset('AzEl', '00:40:00', '00:00:00', cosv=True)`, the leg will be 80' long.
Between each leg the noise diode will be fired for 10 seconds (`calDuration=10`).
From these parameters we can estimate how long each `Spider` procedure will last, including the 20 s overheads between scans

.. math::
    
    \mbox{spiderDuration}=(\mbox{scanDuration}+20\times2+10\times2)\times4


To determine the values for `startOffset`, `scanDuration` and `tint` you should think about your science goals, and remember that these parameters are related via

.. math::

    \mbox{tint}=\frac{\mbox{HPBW}}{(2\times\mbox{startOffset})/(\mbox{scanDuration})}\frac{1}{\mbox{# samples}}


with HPBW the half power beam width at the lowest observing frequency, and `# samples` the number of data points over the beam.
If you want to observe a point source, the full beam response might not be important, but if your source is extended you will want to map your beam. 
In this example we will assume you are interested in the full beam response, so we will set `# samples=5`.
For the lenght of the spider legs you want to make sure that there will be enough blank sky to calibrate the observations.
Here we will use a size of five time the HPBW (3.1' at 3960 MHz), so `startOffset=Offset("AzEl", "00:15:30", "00:00:00", cosv=True)`.
Then, the integration time is `tint=0.02scanDuration`, so if we use 150 s for scanDuration, then `tint=3`.

.. code-block:: python

    # Example scheduling block for carrying out Mueller matrix observations.

    # Reset configuration from prior observation.
    ResetConfig()

    # Define a source catalog and tell the system about it.
    source_catalog = """
    format = spherical 
    coordmode = J2000
    HEAD = NAME    RA              DEC        
    3C286          13:31:08.28     +30:30:32.9
    3C138          05:21:09.88     +16:38:22.0
    """
    Catalog(source_catalog)

    # Define the configuration we will use.
    config = """
    receiver           = 'Rcvr4_6'                       
    obstype            = 'Spectroscopy'                  
    backend            = 'VEGAS'                         
    restfreq           = 4500, 5100, 5800, 6700, 7400    
    bandwidth          = 1080                            
    nchan              = 16384                           
    vegas.subband      = 1                               
    swmode             = 'tp_nocal'                      
    swtype             = 'none'                          
    tint               = 3                               
    swper              = 3                               
    vframe             = 'topo'                          
    vdef               = 'Radio'                         
    noisecal           = 'hi'                            
    pol                = 'Linear'                        
    vegas.vpol         = 'cross'                         
    dopplertrackfreq   = 5800                            
    """

    # Perform position and focus correction on the calibrator.
    AutoPeakFocus("3C286")

    # Reconfigure after position and focus corrections.
    Configure(config)

    # Slew to your calibrator.
    Slew("3C286")

    # Balance the IF system.
    Balance()

    # Define the parameters for the Spider procedure.
    scanDuration  = 150 # seconds
    startOffset   = Offset('AzEl', '00:15:30', '00:00:00', cosv=True)

    # Estimate how many complete Spiders we can fit into
    # our observing session.
    # How much time do we have?
    # Assume 3 hours for this example.
    totalTime     = 3 * 60 * 60.
    spiderTime    = 4*(scanDuration + 20*2 + 10*2)
    numberSpiders = int(totalTime/spiderTime)
    print("Will observe {0} Spiders".format(numberSpiders))

    for i in range(numberSpiders):
        Spider("3C286", startOffset, scanDuration)


Data Reduction
==============

To be done
