

RADAR
-----

Planetary radar observations are supported by the JPL radar backend. 


Introduction
^^^^^^^^^^^^

The GBT participates in radar observations of near-Earth asteroids and comets,
as well as Lunar and planetary mapping and rotation studies. These are done in 
collaboration with JPL/Goldstone at X-band or C-band}, and formerly with the 
Arecibo Telescope, which could transmit at 2380 MHz (S-band) or 430 MHz 
(P-band) before its unfortunate collapse in 2020.

If you wish to do radar studies you should collaborate with scientists at NASA/JPL
to plan the experiment. Observing time with a transmitting antenna should be 
secured independently from a proposal to receive with the GBT. Opportunities for
radar observations can arise on short notice, in which case you can make use of 
DDT proposals if the normal proposal process is not timely enough. Use the NRAO
proposal submission tool to submit all proposals, and indicate the proposal is 
for DDT; these proposals will be reviewed and responded to within a few working days. 


Data Acquisition Backends
^^^^^^^^^^^^^^^^^^^^^^^^^

.. _tab-radar-backends:
.. table:: Radar data acquisition backends

    +-----------------------+---------------+---------------+
    |  Backend              | Sample rates  | Bandwidths    |
    +=======================+===============+===============+
    | JPL                   | 6.25-400 MHz  | 0.31-73 MHz   |
    +-----------------------+---------------+---------------+
    | VEGAS baseband modes  | 100-800 MHz   | 100-800 MHz   |
    +-----------------------+---------------+---------------+

At present, the best choice is the JPL system which can be configured flexibly
under computer control for a wide choice of bandwidths and sampling rates. Sample
rates and bandwidths are listed in :numref:`tab-radar-backends`. For the rest of
this chapter, we will explain the usage of the JPL Radar backend. The VEGAS baseband
modes will function similarly to the incoherent pulsar modes described in :ref:`VPM`,
but consult with your project friend to ensure correct and efficient usage.


GBT Scheduling Blocks
^^^^^^^^^^^^^^^^^^^^^

The following configuration works for the JPL backend. It should be noted that the 
data recording is not controlled through the GBT user interface AstrID. The SB tracks 
the object, but you have to run the data acquisition process independently. Consult
with your project friend for specific instructions about using the JPL backend data 
acquisition process.

Here is an example script for 8560 MHz observations.

.. literalinclude:: radar_sb.py
    :language: python

The ephemeris file referred to in the ``Catalog()`` command, above, gives the
coordinates for the object, as described in the next section. The object name,
in this case ``1999JV6`` is defined in the file referred to in the ``Catalog()``
command. 

The bandwidth is applied before the optical driver step in the signal path, and 
can take on the values listed in Table 9.2, with the caveat that the final filter
going into the JPL backend is 500 MHz wide. The JPL backend itself has an output 
filter that can be configured to be between 0.31 and 73 MHz wide. The integration
time does not have any affect on data acquisition, and can be kept at 0.2. The 
velocity frame should be kept as topocentric, as doppler shifting is typically
done by the transmitting telescope.

.. todo:: Reference table 9.2 in the observer guide.

Refer to chapter 5 for more information on GBT configurations and SBs.

.. todo:: Reference section 5 in observer guide.


Tracking moving objects
^^^^^^^^^^^^^^^^^^^^^^^

Here is an example of an ephemeris file for an asteroid. Refer to 5.3.5 for a 
description of the Ephemeris format.

.. todo:: Add reference to 5.3.5 section in observer guide.


.. literalinclude:: material/radar_asteroid_ephem_example.astrid
    :language: python

Consult section 5.3.5.2 for a description of obtaining ephemeris data from the 
NASA/JPL Horizons website and converting it for use with AstrID. Here is a brief 
description of the process:

* Access the JPL Horizons web interface: \url{http://ssd.jpl.nasa.gov/horizons.cgi}

* Set up Horizons web-interface as follows:

  * ephemeris type: Observer Table
  
  * target body: [select the object]

  * Observer Location: Green Bank (GBT) -- click ``Edit``, then type -9 in the 
    search bar and press ``Enter``.

  * Time Specifications: [put in desired values]

  * Table Settings: QUANTITIES=1,3,20\newline (1) Astrometric RA\&Dec, (3)rates
    in RA&Dec, and (20) Range and range rate
  
* Click ``Generate Ephemeris``

* Use the web browser file menu to save the output file as (for example) ``cometfilename.txt``

* Run the program ``jpl2astrid cometfilename.txt``. A new file with an ``.astrid``
  extension will be created. An example of such a file is shown in the script above.

The resulting ``.astrid`` file is used as an argument to the AstrID ``Catalog()`` command.


If you wish to track the velocity, use:

* ``jpl2astrid cometfilename.txt vel``
  
  This will put the velocity in the ``.astrid`` file. This option is usually not necessary
  because the relative velocity of the object is compensated by the transmitter, i.e., the
  transmitted frequency at Arecibo or Goldstone is programmed to result in a constant
  frequency received at Green Bank.

.. note:: 
   
   the coordinate rates, columns 5 and 6 in the above example, as given by the Horizons listing, are:
   
   * :math:`dRA*\cos{D}`
   * :math:`d(DEC)/dt`

In converting to the ``.astrid`` result, ``jpl2astrid`` divides the RA rate by 
cosine(Declination) so that it is the rate in the RA, rather than in :math:`RA*\cos(Dec)`.
The units in both coordinates are arcseconds per hour.

The ``jpl2astrid`` program often does not fill in the object's name correctly. 
One should edit the ``NAME`` in the ``.astrid`` file to be something meaningful,
and one should make sure the object name in the SB matches that in the ephemeris table.

