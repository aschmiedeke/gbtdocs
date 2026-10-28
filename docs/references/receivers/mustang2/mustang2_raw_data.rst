.. _mustang2_raw_data:

##############################
Overview of MUSTANG-2 Raw Data
##############################

MUSTANG-2 employs transition edge sensors (TESs). These detectors are in RLC circuits (but not the basic RLC circuits in textbooks). The readout of these detectors ultimately produces a phase. This phase is the raw MUSTANG-2 data that gets written to disk. The phase (with some care) will have a proportionality with incident flux on the detector.

Correspondence with incident flux
=================================
While phase is restricted to values [0, 2 :math:`\pi`], we know that our data passes over many factors of 2 :math:`\pi`. That is, we must "unwrap" the data to get a continuous timestream. While algorithms exist to "unwrap"  the data and generate such a continuous timestream, we have another problem in that we don’t know to which incident flux a phase=0 corresponds. You might consider that an omniscient being may know which "wrap count" a detector is at. However, in practice, we never have access to this information. As such, we can never know the absolute value of the incident flux on detectors. What we can do is accurately construct the change in phase (and eventually the change in incident flux) across a timestream.

Enter the skydip
================
What is a skydip? A skydip is both a flat field and an initial calibration. With a fair guess of the opacity, we can infer the surface brightness of the atmosphere (i.e. thermal emission from the atmosphere). Once again, the absolute value (at a given point) isn’t relevant for us. Rather, calculating the change in surface brightness across the scan (skydip) allows us to relate the **change in (unwrapped) phase** of detectors to the **change in surface brightness (from the atmosphere)**.

This serves as a flat field because the detectors should all see the same atmosphere, i.e. they should all see the same change in surface brightness (incident flux) from the atmosphere. While the raw data (phases) may show that each detector saw a different total change in phase across the scan (i.e. the detectors have different gains), we can "flat field" them so that their calibrated data show they all saw the same ("flat") surface brightness (incident flux) from the atmosphere.

It’s worth noting that we calculate a surface brightness in units of temperature. In particular, radio astronomy calls this a brightness temperature (see Equation 2.33 in `Essential Radio Astronomy Ch 2 <https://www.cv.nrao.edu/~sransom/web/Ch2.html#S1>`_), especially when invoking the Rayleigh-Jeans approximation. In the M2 documentation here, we adopt this convention and will often subscript T with "RJ", giving :math:`\mathrm{T}_{\mathrm{RJ}}`.

.. attention::

	We have one more distinction to make with units of MUSTANG-2 data. When considering :math:`\mathrm{T}_{\mathrm{RJ}}`, we still have to consider from where the relevant flux originates. In particular, our skydip accounts for everything the detector can see. We often call this the forward beam temperature. The implication is that this is the brightness temperature seen by the telescope beam **in front of the primary dish**. Of salience here is that the forward beam can be very broad compared to the **main beam** (which is the "in-focus" response near the pointing axis). 
