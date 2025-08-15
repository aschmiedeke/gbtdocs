
VLBI
----

The GBT supports Very Long Baseline (VLB) observations with a Mark6 VLBA recorder. 
This recorder can also be used in a "single-dish" mode to make high time-resolution 
observations. 

Proposals
^^^^^^^^^

The GBT has a VLBA-compatible data acquisition system. Proposals requesting GBT 
participation in VLBA or global VLBI observations should be submitted to the VLBA
only, not to the GBT.

Proposals requesting the GBT participation in a VLB experiment that includes no
other NRAO telescopes should be submitted to the VLBA as well as to the GBT and 
other agencies as appropriate, such as the EVN.

References for VLBA proposals: https://science.nrao.edu/facilities/vlba/proposing

General information about the VLBA: https://science.nrao.edu/facilities/vlba/


VLBA-compatible recording
^^^^^^^^^^^^^^^^^^^^^^^^^

The data acquisition system is similar to those at the VLBA stations: two RDBE units 
and a Mark6 recorder are in use, allowing wide-band recording up to 4 Gbits/sec. 
Two modes are available, 

#. **PFB mode** provides 16, 32-MHz channels and a total  recording rate of 2 Gbits/sec
#. **DDC mode** each RDBE allows up to 4 channels  of bandwidth 1 to 128 MHz. With two
   RDBE available, up to 8 DDC channels may be used.

The SCHED default frequency setups should be correct for writing schedules for the 
new system.

.. note::

    The old data acquisition system with the DAR rack and Mark5A recorder have been 
    retired. The Mark5C recorder is also not in use anymore. Consequently, no proposals
    should request those hardware systems.


Schedule Preparation
^^^^^^^^^^^^^^^^^^^^

Scheduling is done through the VLBA analysts in Socorro.  

* Schedules are prepared with the SCHED program. (refer to: http://www.aoc.nrao.edu/software/sched/index.html)

* The GBT uses the standard VLBA schedule files (``*.key`` and ``*.vex`` files).

* You need to prepare a ``.key`` file for SCHED and send it to the VLBA analysts.
    
* Use ``GBT_VLBA`` as the station name, except for cold weather in which case you should
  use ``GBT_COLD``. Refer to pointing and weather sections, below. 

* In general, use ``GBT\_COLD`` during the months of December, January, and February.


The schedules, either ``.vex`` or ``.key`` files, are processed by the VLBA analysts to 
produce schedule scripts for each VLBA telescope, including one for the GBT. These 
scripts are interpreted at the GBT by a process called ``RunVLBI`` which generates
the configuration and pointing commands for the GBT. The same script runs in the VLBA
backend to drive the recording and backend frequency setup. The GBT telescope operator
runs these experiments. As a user you do not need to know anything about GBT-specific
script details, i.e, the AstrID configurations, catalogs, and scheduling blocks.

There are, however, several GBT-specific details which you need to take into consideration
when designing the observing schedule. These are described in the next few sections.


Special considerations when using the GBT
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Allow about 15-30 minutes setup time at the beginning of a session before VLBI recording
  begins. For the 3mm and 7mm VLBA bands (W-band and Q-band, respectively), allow for 
  45 minutes to one hour of setup time.

* Changing between Gregorian receivers requires rotating the turret. The telescope operator 
  initiates this rotation. At least 5 minutes should be allowed in the schedule to change 
  from one Gregorian receiver to another.
      
* Changing between Gregorian and prime focus requires about 10 minutes; that is the time 
  required to extend or retract the prime focus boom. Changing from one prime focus receiver 
  to another requires about 4 hours on a maintenance day, because one feed must be physically
  removed and replaced with another.

* The prime focus receivers include 50 cm and 90 cm bands; whereas L-band and all higher 
  frequencies (:math:`\nu > $ 1.2 {\text{GHz}`) use the Gregorian focus (with the exception 
  of the upcoming Ultrawideband Receiver (UWBR), which is a prime focus receiver and will 
  cover a frequency range of 0.7 - 4.0 GHz).
  
* Include enough pointing/focus updates -- see below.
    
* There are some weather-related restrictions -- see below.



Available Receivers and Bands
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The receivers and frequency bands are listed in Table below

.. note:: 

    * Some bands are available on the GBT but not on the VLBA. 
    * It takes time to change receivers, as described above. For more information, consult 
        
      * The GBT proposers guide, chapter 4, for antenna and receiver performance.

        .. todo:: Move that content over here.

      * Gain curves, see https://safe.nrao.edu/wiki/bin/view/GB/Observing/GainPerformance

        .. todo:: 

            Move that content over here if possible. Wiki pages are not accessible 
            to the public (anymore)

    
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| VLBA     | VLBA        | GBT         | GBT             | GBT      | Net   | Primary | Est.  | Typical |
| Band     | Frequency   | Frequency   | Receiver        | Receiver | Side- | Beam    | SEFD  | Tsys    |
|          | Range       | Range       | AstrID          | Common   | band  | FWHM    | (Jy)  | (K)     |
|          | (GHz)       | (GHz)       | Name            | Name     |       |         |       |         |
+==========+=============+=============+=================+==========+=======+=========+=======+=========+
| 90 cm    | 0.312-0.342 | 0.290-0.395 | Rcvr_342 (PF1)  | P-band   | lower | 36'     | 25    | 20-70   |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| ---      | ---         | 0.385-0.520 | Rcvr_450 (PF1)  | 400-MHz  | lower | 27'     | 22    | 20-50   |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 50 cm    | 0.596-0.626 | 0.510-0.690 | Rcvr_600 (PF1)  | 600-MHz  | lower | 21'     | 12    | 20-35   |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| ---      | ---         | 0.680-0.920 | Rcvr_800 (PF1)  | 800-MHz  | lower | 15'     | 15    | 18-25   |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| ---      | ---         | 0.910-1.230 | Rcvr_1070 (PF2) | PF2      | lower | 12'     | 10    | 18-22   |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 18/21 cm | 1.35-1.75   | 1.1-1.8     | Rcvr1_2         | L-band   | lower | 9'      | 10    | 15-18   |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 13 cm    | 2.15-2.35   | 1.68-2.60   | Rcvr2_3         | S-band   | lower | 5.8'    | 12    | 18      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 6 cm     | 3.9-7.9     | 3.95-8.0    | Rcvr4_6         | C-band   | lower | 2.5'    | 10    | 23      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 4 cm     | 8.0-8.8     | 7.8-12.0    | Rcvr8_10        | X-band   | lower | 1.4'    | 15    | 27      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 2 cm     | 12.0-15.4   | 11.8-18.0   | Rcvr12_18       | Ku-band  | upper | 54"     | 20    | 27      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
| 1 cm     | 21.7-24.1   | 18.0-27.5   | RcvrArray18_26  | KFPA     | lower | 32"     | 25    | 40      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+        
| ---      | ---         | 26.0-40.0   | Rcvr26_40       | Ka-band  | upper | 22"     | 20-40 | 40      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+        
| 7 mm     | 41.0-45.0   | 40.0-50.0   | Rcvr40_52       | Q-band   | upper | 16"     | 60    | 80      |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+        
| 3 mm     | 80.0-90.0   | 68-92       | Rcvr68_92       | W-band   | upper | 10"     | 100   | 110     |
+----------+-------------+-------------+-----------------+----------+-------+---------+-------+---------+
.. todo:: Add table notes here.


.. tablenotes    
.. Please note that this receiver name no longer correlates exactly with the actual frequency range of the receiver.
.. Receivers with \dq{PF1} or \dq{PF2} are at the prime focus; the others are at the Gregorian focus.
.. Rcvr26\_40 has linear polarization only; 2 beams but one polarization state per beam; all other receivers can receive dual circular polarizations.
.. Pulse Cal (or phase cal) is injected in receivers of 2 cm wavelength and longer; pulse cal is injected in the 7mm receiver after the first mix; other receivers have no pulse cal injection.
.. The 4 mm receiver (Rcvr68\_92) has no noise cal or pulse cal injection. See the section below for how calibration is done.



Include Pointing and Focus Checks
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is recommended to allow for pointing and focus touch-ups when observing 
at the higher frequencies. Recommendations are listed below:

.. list-table:: GBT pointing and focus checks with VLBA observations
    :widths: 25, 75
    :header-rows: 1

    * - Frequency Band
      - Interval between pointing scans 
    * - 4-10 GHz
      - 4-5 hours
    * - 12-18 GHz
      - 3-4 hours
    * - 18-26 GHz
      - 1.5-2 hours
    * - 40-90 GHz
      - 30-60 minutes


* Select a strong continuum source (flux density >0.5 Jy, or > 1.0 Jy for :math:`\nu` > 20 GHz).

* Allow about 6 minutes for the pointing/focus check, except for the 3mm VLBA band (W-band receiver) 
  for which you should allow 8 minutes in order to include the temperature calibration.

* For observing at frequencies below 5 GHz, include one pointing scan at the beginning of the session.

* The telescope operator will usually do a point/focus scan at the beginning of an observing session,
  during the startup time.


To include a point/focus scan in your schedule, put commands into your ``.key`` file similar 
to the following:

.. code-block:: 

    comment='GBT pointing scan'
    peak=1
    stations=gbt_vlba
    source= 'J0920+4441' dwell=06:00  vlbmode='VA' norecord /
    nopeak 

It is important to specify only the GBT (``stations=gbt_vlba`` or ``stations=gbt_cold``) when putting 
in ``peak=1``.  Otherwise it may do a reference pointing for the whole VLBA, and if the pointing source
is under about 5 Jy, it can produce bad results. Refer to the SCHED manual for details of schedule 
preparation at http://www.aoc.nrao.edu/software/sched/index.html.


4 mm Receiver (68-92 GHz) calibration
'''''''''''''''''''''''''''''''''''''

System Temperature (:math:`T_{sys}`) calibration with this receiver uses a calibration wheel that
can place hot and cold loads in front of the feed. There is no noise injection as happens with the other
receivers. A cal sequence procedure is done before and after each peak/focus to provide a :math:`T_{sys}`
measurement. A cal sequence is inserted automatically with the peak/focus; the user does not have to 
specify it explicitly. A cal sequence takes about one minute, and will happen before and after a peak/focus.
You should use a dwell time of 8 minutes for the pointing scan, and that will include the cal sequences.
Pointing aources for high frequency observing should be strong, i.e., stronger than 3 Jy if possible.



Weather Considerations
^^^^^^^^^^^^^^^^^^^^^^

At the higher frequencies, windy conditions can degrade the pointing. Refer to recommended wind limits 
for observing at https://safe.nrao.edu/wiki/bin/view/GB/PTCS/PointingFocusGeneralStrategy.

.. todo:: Move the content of the wiki page here if possible.


* For sustained winds of >35 MPH or gusts >40 MPH, the telescope is stowed for safety.
* Ambient temperature <17 F (-8.3 C) : the maximum azimuth slew rate is reduced to 18 deg/min.
* Ambient temperature <-10 F (-23 C) : the antenna is shut down.


If your project will run in December, January, or February you should use the lower azimuth slew 
rate of 18 deg/min when making the schedule. This is accomplished by using ``stations=gbt_cold``
in your ``.key`` file, instead of ``stations=gbt_vlba``.


Telescope Move times and limits
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* **Move Limits:**
    
  * Elevation: :math:`5^{\circ} \rightarrow 90^{\circ}`
  * Azimuth: :math:`-90^{\circ} \rightarrow +450^{\circ}`, i.e, :math:`180^{\circ} \pm 270^{\circ}`
  
  
* **Calculating time to change sources:**

  * Maximum Azimuth slew rate: :math:`36^{\circ}` / min (:math:`18^{\circ}`/ min at low temperature)
  * Maximum Elevation slew rate: :math:`18^{\circ}` / min
  * Acceleration: :math:`0.05^{\circ} {\text{sec}}^{-2}`
  * Overhead: 20 seconds to settle
  * Allow a minimum of 30 seconds for a source change, even for short moves.
   


High Frequency (40-90 GHz) active surface considerations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When using the 40-50 or 68-92 GHz receivers, one should tune up the active surface by doing an AutoOOF
procedure. This is so-called Out of focus holography in which a strong point source is observed both in
and out of focus, and large-scale deviations of the surface can be derived. The surface corrections are 
applied to the active surface model. This improves the aperture efficiency by a factor of 2 at 86 GHz. 
One should do an AutoOOF, which takes about 30 minutes, at the beginning of any high-frequency observing. 
You do not have to specify this in the observing file; the operator or telescope friend will do an
AutoOOF calibration prior to starting the observing, during the setup.

When observing with the 68-92 GHz receiver, you should repeat the AutoOOF about every 3-4 hours. This 
means that you should allow a 30 minute gap in the schedule about every 3-4 hours. You do not have to 
specify anything about an AutoOOF in the schedule; just allow the 30 minute gap. The operator or telescope 
friend will do the calibration. 


GBT Coordinates
^^^^^^^^^^^^^^^

The geodetic position for the GBT (as of Jan 2000), based on a local survey referred to a standard NGS 
survey marker on the Green Bank site in the NAD83 system is

* longitude = :math:`79^{\circ}` 50' 23.406" W
* latitude = :math:`38^{\circ}` 25' 59.236" N
* Height of Track: NAVD88 height: 807.43 m (wrt ellipsoid: 776.34 m)
* Height of elevation axle: NAVD88 height: 855.65 m (wrt ellipsoid: 824.55 m) 

The surveyed height refers to the top of the azimuth track. The phase center (intersection of azimuth 
and elevation axes) is 48.22m above the top of the azimuth track. The average geoid height = -31.10m
with respect to the ellipsoid. The estimate uncertainty is 0.04".

The Earth-centered ITRF coordinates for the phase center of the GBT were derived from a TIES run with
the GBT and 20-meter telescopes in December 2002.  

.. AS: Commenting this as the webpage is not loading, 2022-10
.. Geodetic solution for the \gls{ITRF} coordinates may be found through the web site: 
.. \url{http://gemini.gsfc.nasa.gov/solutions/}


The solution as of Oct 2007 is:

* x =   882589.638 meters
* y = -4924872.319 meters
* z =  3943729.355 meters


Based on the ITRF solution, the best NAD83 geodetic position is:

* Latitude = :math:`38^{\circ}` 25' 59.266" N (:math:`38.433129^{\circ}` N) 
* Longitude = :math:`79^{\circ}` 50' 23.423" W (:math:`79.839840^{\circ}` W) 
* Height above the ellipsoid = 824.36 m 
* Height above the geoid = 855.46 m 


Further Information
^^^^^^^^^^^^^^^^^^^

More information about running VLBI observations at the GBT is available at https://www.gb.nrao.edu/~gbvlbi/vlbinfo.html.

.. todo:: Move the content of this page over to GBTdocs.

