.. _argus_n2hp_fsw_tutorial:

#################################################
Argus N\ :sub:`2` H\ :sup:`+`\ (1-0) Observations
#################################################

This tutorial walks you through the process of observing N2H+ with Argus on the GBT in frequency-switching mode. In this
tutorial we will walk through observational setup, observing strategy, and data reduction resulting in a dataset that is ready
for scientific analysis. 

.. admonition:: What you need and should already know
    :class: note

    - You need a GBO computing account.
    - You are familiar with the Linux command line.
    - You know how to start AstrID and GBTIDL.

    You can find general instructions for using AstrID, as well as starting CLEO, contacting
    the operator, etc. :ref:`here <how-tos/general_guides/gbt_observing:GBT observations 101>`.


.. admonition:: Data

   The data we will be working with in this tutorial was obtained during the Fall 2022 GBT Observer Training Workshop. 
   The raw sdfits files are accessible at ADD PATH HERE.



Observing Script Preparation
============================

Argus Startup Script
--------------------

Before we can start any observations using Argus, we have to check the instrument status, turn the instrument on if it
is currently off and re-configure Argus for the default 90 GHz parameters. This is done using a standard ``argus_startup``
script. 

.. literalinclude:: material/Argus_tutorial/00_argus_startup.py
    :language: python
    :linenos:



Calibration source selection
----------------------------

For most Argus observations you will need to choose a primary calibrator as well as a secondary calibrator. 

At the observing frequency range of Argus (74 - 115 GHz), there are not many calibrators available that are strong
enough for detection with Argus and the DCR. We recommend to pick the brightest available calibrator during your
observations as your primary calibrator. You will run your AutoOOF on that calibrator as well as a number of peak and
focus scans. We are providing more details on this in the next subsections. 

If your primary calibrator is nearby your science target, you are very lucky! 

In most cases, you will need to pick a secondary calibrator that is closer to your science target. This calibrator might
not be strong enough to be observed with Argus and you may have to switch to a lower-frequency receiver (e.g. X-Band, KFPA,
Ka-Band, Q-Band) to perform regular pointing and focus calibration measurements throughout your observations. 

In this tutorial we used the primary calibrator `2253+1608`


AutoOOF
-------

Prior to running science observations, we need to run the :func:`AutoOOF() <astrid_commands.AutoOOF()>` command to optimize
the surface, unless the exact beam shape is not important for your science goals.

.. literalinclude:: material/Argus_tutorial/01_autooof.py
    :language: python
    :linenos:


The same AstrID command :func:`AutoOOF(source) <astrid_commands.AutoOOF()>` can be used for any of the receivers that use AutoOOF, i.e.
Ka-Band, Q-Band, W-Band, Argus, and MUSTANG-2. The software will automatically adopt the appropriate defaults for each receiver. For
your Argus observations, you can choose any of those receivers except MUSTANG-2, which requires to complete dedicated 
biasing and tuning routine prior to it being usable. 

Please note, not all receivers are installed at all times. So when planning your observations it is worth checking in 
with your project friend to learn which receiver options for AutoOOF are available. The operator will also always be able to tell
you which of the AutoOOF capable receivers are currently installed. 

.. admonition:: Links to more information available on GBTdocs

   - an :ref:`Explanation of Out-of-focus (OOF) Holography <explanations/OOF:An Explanation of OOF>`
   - an :ref:`AutoOOF Guide <how-tos/general_guides/autooof:AutoOOF Guide>` 




Pointing and Focus
------------------

We strongly recommend to run a peak-focus-peak sequence on your primary calibrator using Argus. 

.. literalinclude:: material/Argus_tutorial/02_argus_pfp_primaryCalib.py
    :language: python
    :linenos:

This allows you to verify the pointing and focus solutions obtained from the AutoOOF and to measure the aperture efficiency.

We recommend using :func:`Break() <astrid_commands.Break()>` after the first set of peak and focus measurements,
respectively. This allows for time to check the pointing and focus solutions and adjust them in the system in case the
automatic determination has failed for some reason. 


If you are planning to observe your secondary calibrator with a different receiver than Argus, you will need to account
for the fact that there is a frequency-dependent focus offset between Argus and all other receivers. To measure this offset,
you will need to run an additional peak-focus sequence on your primary calibrator using your pointing receiver. 

.. admonition:: Focus offset measurement

   Information on how to calculate the focus offset between Argus and your pointing receiver is available 
   :ref:`here <how-tos/receivers/argus/argus_obs:2.3 Determine focus offset>`.


.. todo:: Add script for peak focus measurement with receivers X, Ka, KFPA, or Q on primary calibrator.


.. todo:: Add script for peak focus measurement with receivers X, Ka, KFPA or Q on secondary calibrator. 




Science Observations
--------------------


Configuration
_____________


Argus uses the standard config-tool software that automatically configures the system based on user input. Comprehensive
details on how to configure the GBT is available :ref:`here <references/observing/configure:Configure the GBT system>`.

For the frequency-switched observations of N2H+ presented in this tutorial we used the following configuration: 

.. literalinclude:: material/Argus_tutorial/argus_fsw_n2hp_vegas.config
    :language: python
    :linenos:


* Argus receiver is ``RcvrArray75_115``.
* Argus has no noise diode, so for the ``swmode`` one can either select ``tp_nocal`` for total power  
  observations or ``sp_nocal`` for switched-power observations as done here. 

  * Since we have selected ``sp_nocal``, we need to select a ``swmode``. Here we want frequency-switched observations so we need to select ``'fsw'``.
  * We also have to define the switching period (``swper``) and the switching frequencies (``swfreq``)

* VEGAS is setup for VEGAS mode 5, i.e. bandwidth of 187.5 MHz and 65536 channels. This provides a spectral resolution of
  2.9 kHz.

* Since we are observing below 100 GHz, we are using the recommended lower sideband (``'LSB'``). 
* Argus is a single polarization receiver. The only polarization option available is ``'Linear'``. 

.. todo:: Add reference to VEGAS spectral line mode table. 



Pointed Observations
____________________


.. literalinclude:: material/Argus_tutorial/05_argus_science_obs_fsw_track.py
    :language: python
    :linenos:

As an alternative you can replace lines 36-45 with the following one-liner

.. code-block:: python

    execfile('/home/astro-util/projects/Argus/OBS/balanceArgusAndCheckYIGpower')

This script will attempt to balance the IF system, check the Argus YIG power and if the YIG power is below a threshold it will
re-balance. In total the script will attempt to rebalance Argus twice, if all attempts fail, it will pop-up an alert. 



Mapped Observations
___________________


.. literalinclude:: material/Argus_tutorial/06_argus_science_obs_fsw_map.py
    :language: python
    :linenos:


As an alternative you can replace lines 38-47 with the following one-liner

.. code-block:: python

    execfile('/home/astro-util/projects/Argus/OBS/balanceArgusAndCheckYIGpower')

This script will attempt to balance the IF system, check the Argus YIG power and if the YIG power is below a threshold it will
re-balance. In total the script will attempt to rebalance Argus twice, if all attempts fail, it will pop-up an alert. 




Observing
=========

During the 2022 Fall Training Workshop observing session we were faced with bad weather conditions (normally Argus
observations wouldn't get scheduled in those conditions). We decided to try setting the surface using the Ka-Band 
receiver and then ran a peak-focus measurement using X-band. We did not measure the focus offset (this was discovered 
later on) and we did not measure the aperture efficiency with Argus. 

Here are some screenshots of what we saw in AstrID's DataDisplay tab during the observing run.


AutoOOF with Ka-Band
--------------------


Peak and focus with X-Band
--------------------------


Science observations with Argus
-------------------------------

AstrID (or actually GFM) is not able to handle science Argus observations. For those scans you will always see a message 
``"Scan XX (MAP, RALongMap) not handled by any plugin."``

This is normal and nothing to worry about. To check that the incoming data, we will be using GBTIDL. 



Science Data Quick Look Inspection
----------------------------------



Data Calibration
================






