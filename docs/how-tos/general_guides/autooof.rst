.. _AutoOOF_strategy:

################
AutoOOF Strategy
################

AutoOOF is recommended for observing at frequencies of 40 GHz and higher and only available 
for use with ``Rcvr26_40`` (Ka-Band), ``Rcvr40_52`` (Q-Band), ``Rcvr68_92`` (W-Band), 
``RcvrArray75_115`` (Argus), and ``Rcvr_MBA1_5`` (MUSTANG-2). For the associated data display, see
:ref:`references/astrid:OOF Data Display`. For an explanation of what OOF is and the theory behind OOF see :ref:`OOF_explanation`.

.. note:: 

    AutoOOF is not necessary for extended sources. Extended sources may be observed without the AutoOOF corrections if the science is not impacted by the primary beam variations.

Finding a Good OOF Source
=========================

**What is a good source to OOF on?**

You want to chose a source that is bright, compact, and in the elevation range of 30 < el < 80 (e.g., a bright calibrator). It should be preferably at least 7 K in the observed band, which is about 4 Jy at Q-band (see :numref:`tab-receivers-7K-equivalent` below which uses the aperture efficiency values for each receiver from :numref:`tab-receivers-gregorian`). 

.. _tab-receivers-7K-equivalent:
.. table:: : 7 K equivalent flux for each receiver.

    +-----------+-----------+
    | Receiver  | Flux (Jy) |
    +===========+===========+
    | Ka        | 3.5       |
    +-----------+-----------+
    | Q         | 3.8       |
    +-----------+-----------+
    | W         | 4.1       |
    +-----------+-----------+
    | Argus     | 9.1       |
    +-----------+-----------+
    | MUSTANG-2 | 7         |
    +-----------+-----------+


.. todo:: is the lower range of elevation for OOFing 25 or 30 degrees?

.. todo:: confirm calculations at other bands besides Q-band.

**How do I find a good OOF source?**

You can use the default CLEO catalogs to get ideas for bright calibrators. However, you should **NOT** rely on the catalog flux to be accurate as it is often many years out of date. It is prefereable to instead use the the `ALMA Calibrator Source Catalogue <https://almascience.eso.org/sc/>` finding good OOF sources as these sources are well understood and observed often. The ALMA Calibrator Source Catalogue has an extensive record of the flux densities for many of the bright 3 mm sources. Go to the ALMA Calibrator Source Catalogue and search for bright sources in your observing band that have recently been observed. Additionally, you can find a source using a CLEO catalog but you should verify its flux density via the ALMA Calibrator Source Catalogue. 

If you are not sure about the brightness of your source then run a point/focus scan on the calibrator first in order to confirm its strength. Remember, to obtain good OOF results, you need to be able to detect the source when the subreflector is out of focus which reduces its peak intensity significantly.

.. note:: 

    In the past it was true that you would want to OOF at an elevation that is similar to your source. However that was before the new gravity model implemented in 2010. Now the gravity model is good enough that you do not need to OOF at an elevation that is similar to your source.

.. warning::
   
   Do not OOF on a source in the keyhole (> 85 degrees). Find a source to OOF on that has an elevation of 30-80 deg.

Receiver Specific OOF Guidance
==============================
Since the Ka-band receiver with the default CCB backend provides the most accurate measurements of the surface parameters, users should consider using this whenever possible (except for MUSTANG-2 users who use the MUSTANG system for OOFing). The benefit of using the Ka+CCB system when possible is two-fold. First, due to the high sensitivity provided by the CCB, the S/N ratios observed with the Ka+CCB system are much higher than what is possible at higher frequencies. Second, and the winds affect the Ka-band data to a lesser degree due to the larger beam-size which in turn makes the surface solutions less affected by winds.

W-Band
------
See guidance in W-band :ref:`references/receivers/w-band:Observing`, but in summary if the Ka-band receiver is available, run :func:`AutoOOF() <astrid_commands.AutoOOF>` at Ka-band (or if Ka is not available and Q-band is available, use Q-band) instead of W-band for more accurate surface corrections.

Argus
-----
See guidance in Argus :ref:`references/receivers/argus:Observing`, but in summary, again, if the Ka-band receiver is available, run the AutoOOF at Ka-band instead of Argus for more accurate surface corrections. Then after the AutoOOF solutions are applied, run a point and focus with Argus to confirm the telescope collimation offsets after the application of the OOF solutions.

MUSTANG-2
---------
Use MUSTANG-2 to OOF and obtain pointing and focus corrections. For choosing your OOF sources for MUSTANG-2, see guide on picking :ref:`OOF sources <how-tos/receivers/mustang2/mustang2_obs_scripts:3.2 OOF sources>`. In the :func:`AutoOOF() <astrid_commands.AutoOOF>`, if it is the first OOF for the MUSTANG-2 project set ``calseq=True`` so ``AutoOOF(source,calseq=True)``. When you set ``calseq=True``, this initiates a skydip scan before the OOF scans (skydip is needed for calibration of the data). If you are doing an OOF later in the night then set ``calseq=False`` so that you do not run another skydip. 

The AutoOOF Procedure
=====================
For a more in-depth explanation of what OOF is doing see this :ref:`this section of the OOF explanation<explanations/OOF:AutoOOF Procedure>`.

Below we provide some general information about the OOF process:

* **Allow approximately 25 minutes for an AutoOOF**.
    * The AutoOOF procedure obtains three consecutive OTF maps (each map takes 5-6 minutes) at a different focus position (typically at focus, 10 mm, and -10mm).
* **Use AutoOOF to derive pointing and focus offsets**
    * The oof-processing is launched automatically upon completion of the third map, and the result is displayed in the OOF plug-in tab of Astrid. It is incumbent upon you, as the user, to examine the solutions (see guidance below), and click the button (in the Astrid DataDisplay tab) to send the selected solution to the active surface. It is recommended that when sending the solutions, you use the button in the OOF display tab labeled ``After selecting the Zernike solution above, click this button to send the solutions to the telescope``.

.. note:: 

    :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>` may be run as a sanity check on the AutoOOF solution. If Peak/Focus scans were performed before AutoOOF, then source amplitude should be greater after the AutoOOF than what was seen before the surface correction was sent.  Additionally, :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>` pointing and focus corrections should agree with values derived by :func:`AutoOOF() <astrid_commands.AutoOOF>`.

How long does an OOF solution remain valid?
============================================
:func:`AutoOOF() <astrid_commands.AutoOOF>` is currently only executed for observing projects at night time. 

Nighttime
----------
A general rule of thumb is if the corrections are measured at least two hours after sunset, then the solutions should be good for about 4 hours. This depends on how rapidly the backup structure cools off after sunset and how sunny the day was. If the OOF is taken after midnight, the structure has typically stabilized by then, and the solutions may be good until after sunrise. But in general, OOF solutions are good for 2-6 hours at night time depending on the conditions of any particular night. It is not recommended that you OOF until ~2 hours after sunset because prior to this the telescope is still “settling” (aka changing thermally) from the thermal effects during the day. 

.. todo:: confirm two hours. 

Daytime
--------
During the daytime, it is a difficult to answer the question of "How long does the OOF solution remain valid?" as it depends on the position of the telescope with respect to the Sun and cloud cover. The answer can be anything from less than 30 min to 4 hours. Daytime surface changes are on time scales on the order of <1 hour. Due to these rapidly changing conditions, the :func:`AutoOOF() <astrid_commands.AutoOOF>` solutions (which are on a similar timescale) can cause more harm (efficiency damage) than good. So it is typically not useful to use the OOF derived corrections during the day.

.. todo:: figure out how to deal with a bit of repetition in Nighttime and Daytime section here and in the :ref:`this section of the OOF explanation<explanations/OOF:AutoOOF Procedure>`. 

When do I need to OOF again?
----------------------------
No matter what receiver you are using you should **periodically examine peak scans**. 

A new AutoOOF may be necessary if the following characteristics are seen:
    * Significant sidelobes begin to appear.
    * The beam size increases by more than 10%.
    * Source amplitude decreases systematically by 15% or more.
   
For how often to do a peak scan for Ka-Argus receivers see :ref:`See Table 1 in Pointing and Focus Strategies <how-tos/general_guides/point-focus:Pointing and Focusing Strategies>`. MUSTANG-2 observers should observe a pointing calibrator and use it check the peak and beam approximately every 30 minutes.

.. todo::

    Using the Ruze and radiometer equations, calculate at what point the surface degrades enough that it will be more efficient use of time to OOF as opposed to keep observing

Inspecting AutoOOF Solutions
============================

Surface Delta Map Characteristics
---------------------------------
Good solutions have the following characteristics:
    * Broad features of less than :math:`\pm 1.5` radians of phase in early to mid-morning to a few radians 
      in the afternoon.  Note that you may uncheck ``Show Fixed Scale Image`` to view the full data 
      range in the color bar.
    * Surface rms residuals <400\ :math:`\mu m`  (less than 500 :math:`\mu\mathrm{m}` if starting withe the default
      gravity-zernike model).


Here is an example of an acceptable OOF solution: 

.. _fig-good-oof-solution:
.. figure:: images/autoOOF/OOFgoodExample.jpg
    
    This solution shows broad features (:math:`\pm` 1.5 radians of phase) with a surface rms of 197\ :math:`\mu m`.


Here is an example of an unacceptable OOF solution:

.. _fig-bad-oof-solution:
.. figure:: images/autoOOF/OOFbadExample.jpg

    This solution shows steep contour lines (:math:`\pm` 15 radians of phaee) and a surface rms of 626\ :math:`\mu m`. This is likely the result of poor quality raw data and the solution should not be used.


Selecting the Zernike order
---------------------------

By default, AutoOOF will halt processing after the fifth-order Zernike (z5) solution has been computed. The z5 solution is suitable for most conditions and is generally what observers should expect to use. A more agressive sixth-order (z6) fit may also be derived at the cost of a few additional minutes of 
processing time. This is usually unnecessary and should only be done on bright calibrators under favorable weather conditions. See :ref:`how-tos/general_guides/autooof:OOF z6 Processing Options` for information on how to change the maximum order of fit to process.

Occasionally, it may be necessary to drop to a lower order of fit if the following features are seen:

* **Large excursions** over a significant area of the dish edge in the OOF solution.
* **Regularly spaced features** around the circumference of the dish at higher order fits in the OOF solution.
* **Anomalous values in the pointing/focus LPC/LFC** for one particular solution, or a significant jump in LPC above a certain Zernike fit order. For example, if the focus (LFCy) values for the z3-z4 solutions are around -3mm, then abruptly jump to +10mm for the z5 solution, then it would be prudent to assume that some or all of the solutions may be invalid. It may be possible to determine which solutions are valid by examining the fitted beam maps for obvious artifacts or deviations from the observed beams.
  
  .. _fig-oof-beammap:
  .. figure:: images/autoOOF/OOF_fittedbeammap.jpg
        
         The AutoOOF fitted beam maps. The observed beams are plotted on the top row with the z3, z4 and z5 fits
         to the observed beams plotted below. The z3 solution (:math:`2^{\text{nd}}` row down) shows an obvious
         artifact and should not be used.

  .. _fig-oof-beammap-solutions:
  .. figure:: images/autoOOF/OOF_fittedbeammap_solutions.jpg
         
          Zernike Solutions. Note the significant jump in LPC and the LFC between the z3 and z4 solutions.

OOF z6 Processing Options
^^^^^^^^^^^^^^^^^^^^^^^^^

Deriving the sixth-order Zernike (z6) solution will require a few additional minutes of processing time and for the user to manually change the maximum order of fit to process in the following way:

#. Select the OOF Subtab of the AstrID Data Display.
#. Select ``Tools`` :math:`\rightarrow` ``Options...`` from the drop--down menu.
#. Select the maximum order of fit to process from the ``Processing Options`` tab of the pop--up window.

   .. image:: images/autoOOF/OOFprocessing_options.jpg


.. important:: 

    All changes must be made **before submitting the SB** containing the :func:`AutoOOF() <astrid_commands.AutoOOF>` 
    function in order to take effect.  You may also repeat processing after making any changes by pressing 
    ``Reanalyze OOF (Online Only)``.


.. admonition:: Internal Access Only

    More information on AutoOOF can be found `here <https://safe.nrao.edu/wiki/bin/view/GB/PTCS/AutoOOFInstructions>`__.

    .. todo:: Transfer the relevant content from that wiki page here.


AutoOOF Raw Data
----------------

Although an OOF solution may appear to be reasonable (e.g., :numref:`fig-good-oof-solution`) it may be invalid if it was derived from a bad set of raw data. Sending such a solution to the active surface could degrade performance. Therefore, observers should always check the quality of the raw AutoOOF data in order to determine whether their derived solutions are valid. 

For a set of raw data to be considered valid, it should show the following characteristics:
* Clear detections of the source in the raw data timestream at all focus positions.
* Symmetrical left/right positive/negative pattern in all three raw data images.
* Smooth features in all three raw data images. Sharp edges or stripes indicate hardware/software glitches or excessive winds.

The AutoOOF raw data can be viewed by selecting the ``raw data`` radio button in the upper-right section of the OOF Subtab of the Data Display. Each column represents one focus position. The top row is the raw timestream data from the receiver, the second row has the baselines removed, and the bottom row shows the corresponding beam maps. See :numref:`fig-good-oof-raw-data` and :numref:`fig-bad-oof-raw-data` for a comparison of acceptable and unacceptable raw AutoOOF data.


.. _fig-good-oof-raw-data:
.. figure:: images/autoOOF/OOFrawData_goodExample.png

    A plot of the raw OOF data on a fairly clean Ka-Band+CCB dataset.

.. _fig-bad-oof-raw-data:
.. figure:: images/autoOOF/OOFrawData_badExample.png

    A plot of the raw OOF data on a source which is too faint.

Raw Data: What am I looking at?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For all receivers besides MUSTANG-2, each OOF is an RALongMap so each of the spikes in the raw data is the beam going over the source; and the relative strength of the spike is how much of the source is in the beam. The the closer you are to the correct focus, the less fuzzy and wide the source is, and thus then the less spikes there are. Said another way, when you are close to the focus correction values, there are fewer, stronger peaks. Further, where you are getting the spikes in time tells you about the elevation offset. For example if you see spikes early in time that means there will be a minus elevation offset.

How do I know if I have a good SNR for the OOF? Ask yourself, do you see peaks? If yes, you have high SNR. If you just see noise, you don't have high SNR. 

.. admonition:: Tip for determining if you have enough SNR for OOFing.

    Change to the "DataDisplay" -> "Continuum" tab for the first OOF scan and see if you see signal from a source or not. If you don't see spikes, then you might want to abort and change to a stronger source.

.. note::

    The y-axis in the raw data plots are NOT scaled between the three focus values.

.. todo:: how to phrase three focus values. Three foci? Three focal points?


AutoOOF Fitted Beam Map
-----------------------
It is good to quickly check the fitted beam map. 

.. _fig-example-fitted-beam-map:
.. figure:: images/autoOOF/Argus/AGBT21B_024_40_s3_fitted_beam_map.png

    A plot of the fitted beam map for an OOF taken with Argus. 

The top row shows the observed beams at the various focus values. Each subsequent row presents the fitted beam maps for the 3rd to 5th Zernike orders. These maps represent the implied corrections needed to achieve an ideal point source after applying focus adjustments. In general, higher Zernike orders yield a more accurate beam solution. Moreover, the beam appearance should become more circular near the correct focus; for example, when LFC_Y is −9 mm, the −10 mm fitted beam maps should appear more circular. Note, however, that these maps depict how point sources would look at each focus position, so the maps corresponding to two of the three focus positions are likely to deviate from the actual focus position and may appear non-circular.

.. todo:: Need to check on wording about what these maps are. 

.. note::

    There are always two beams in the fitted beam maps for all receivers that you can OOF with besides MUSTANG-2. 

Summary for checking your OOF solutions
----------------------------------------

Go through the various Zernike order fits (z5-z3) and check the following:

* surface delta map.  If the structure of surface delta map has:
    * smooth features = good
    * sharp features = bad

* surface RMS.
    * RMS < 400 um = good
    * RMS > 400 um = bad

* local point corrections (LPCs) & local focus correction (LFC)
    * smaller numbers = good
    * large numbers (LFC > 10mm) = bad

Also check the:

* the raw data
    * high SNR = good
    * low SNR = bad

* the fitted beam maps
    * streaks and/or very non-gaussian = bad

Tips and Tricks
===============

Uncheck Fixed Scale
-------------------
You'll notice that the z-axis values of the surface delta map are by default from -2.5 to 2.5 (see scale bar to the right of the surface delta map). This is because the box to the right of the surface image map labeled ``Show Fixed-Scale Image`` is checked. It can be useful to see the full range of z-axis values. To do this uncheck the box next to ``Show Fixed-Scale Image`` and it will then display the full range of values. This can be helpful in the case that the OOF is clearly bad or you are uncertain.

.. note::

    It is unknown what the units are for the z-axis of the surface delta map (the scale bar).

Scaling for a Bad OOF
^^^^^^^^^^^^^^^^^^^^^
.. admonition:: Example 1: The effect of scaling for a bad OOF

    .. tab:: Fixed z5

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_z5_fixedScale.png

    .. tab:: Scaled z5

        .. image:: images/autoOOF/scaled/AGMV24B_376_01_OOF1_bad_z5_scaled.png

    .. tab:: Fixed z4

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_z4_fixedScale.png

    .. tab:: Scaled z4

        .. image:: images/autoOOF/scaled/AGMV24B_376_01_OOF1_bad_z4_scaled.png

    .. tab:: Fixed z3

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_z3_fixedScale.png

    .. tab:: Scaled z3

        .. image:: images/autoOOF/scaled/AGMV24B_376_01_OOF1_bad_z3_scaled.png

For more details about this OOF see the :ref:`how-tos/general_guides/autooof:Q-band` section -> Bad.

.. admonition:: Example 1: The effect of scaling for a bad OOF

    .. tab:: Fixed z5

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z5_fixedScale.png

    .. tab:: Scaled z5

        .. image:: images/autoOOF/scaled/AGBT21B_206_06_s46_z5_scaled.png

    .. tab:: Fixed z4

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z4_fixedScale.png

    .. tab:: Scaled z4

        .. image:: images/autoOOF/scaled/AGBT21B_206_06_s46_z4_scaled.png

    .. tab:: Fixed z3

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z3_fixedScale.png

    .. tab:: Scaled z3

        .. image:: images/autoOOF/scaled/AGBT21B_206_06_s46_z3_scaled.png

For more details about this OOF see the :ref:`how-tos/general_guides/autooof:MUSTANG-2` section -> Bad -> Example 2. 

Scaling for an Uncertain OOF
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: The effect of scaling for an OOF you are uncertain about

    .. tab:: Fixed z5

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z5_fixedScale.png

    .. tab:: Scaled z5

        .. image:: images/autoOOF/scaled/AGMV24B_376_01_OOF2_iffy_z5_scaled.png

    .. tab:: Fixed z4

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z4_fixedScale.png

    .. tab:: Scaled z4

        .. image:: images/autoOOF/scaled/AGMV24B_376_01_OOF2_iffy_z4_scaled.png

    .. tab:: Fixed z3

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z3_fixedScale.png

    .. tab:: Scaled z3

        .. image:: images/autoOOF/scaled/AGMV24B_376_01_OOF2_iffy_z3_scaled.png

For more details about this OOF see the :ref:`how-tos/general_guides/autooof:Q-band` section -> Uncertain.

Scaling for a Good OOF
^^^^^^^^^^^^^^^^^^^^^^

.. admonition:: The effect of scaling for a good OOF

    .. tab:: Fixed z5

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z5_fixedScale.png

    .. tab:: Scaled z5

        .. image:: images/autoOOF/scaled/AGBT21A_376_01_s5_z5_scaled.png

    .. tab:: Fixed z4

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z4_fixedScale.png

    .. tab:: Scaled z4

        .. image:: images/autoOOF/scaled/AGBT21A_376_01_s5_z4_scaled.png

    .. tab:: Fixed z3

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z3_fixedScale.png

    .. tab:: Scaled z3

        .. image:: images/autoOOF/scaled/AGBT21A_376_01_s5_z3_scaled.png

For more details about this OOF see the :ref:`how-tos/general_guides/autooof:MUSTANG-2` section -> Good -> Example 1. 

Show Solutions with Focus Removed
---------------------------------
When you are inspecting the surface delta map, there is an option on the right hand side to "Show Solutions with Focus Removed". OOF solves for the pointing and focus corrections in addtion to the surface corrections. "Show Solutions with Focus Removed" allows you to look at the surface corrections with the focus removed. This is particularly useful to do when you have a large focus correction (:math:`|` LFC_Y :math:`| \gtrsim` 10 mm). It is also useful to check when you are unsure if you have good surface corrections (typically when you have indications that the OOF is bad or marginal) as this allows you check the surface delta map with the focus removed to see if the underlying surface corrections are good. 

For an example, see the following surface delta maps of a project that OOFed with Ka+CCB.

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/misc_examples/AGBT20A_322_16_s1_z5_fixedScale.png

    .. tab:: z4

        .. image:: images/autoOOF/misc_examples/AGBT20A_322_16_s1_z4_fixedScale.png

    .. tab:: z3

        .. image:: images/autoOOF/misc_examples/AGBT20A_322_16_s1_z3_fixedScale.png

One will notice that with all of those the surface delta map looks ok (no sharp edges really), but the surface RMS for z5 is a bit on the high side. The main thing of concern is that the focus offsets are quite high (:math:`\gtrsim|10mm|`). This is a good case in which it is good to inspect the surface corrections with the focus removed. To do this, check the box that says ``Show Solutions with Focus Removed``. Once you have done that you can inspect all three orders of Zernike surface delta maps. For this case they look like the following:

.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/misc_examples/AGBT20A_322_16_s1_z5_focusRemoved.png

    .. tab:: z4

        .. image:: images/autoOOF/misc_examples/AGBT20A_322_16_s1_z4_focusRemoved.png

    .. tab:: z3

        .. image:: images/autoOOF/misc_examples/AGBT20A_322_16_s1_z3_focusRemoved.png

.. note:: 

    ``Show Solutions with Focus Removed`` shows three different surface delta maps: relative solution, absolute solution, and absolute solution with focus removed. Note that the relative solution is the one that most looks like the surface delta map that is initially displayed. The "absolute solution with focus removed" is the map that you want to look at. 

For this example, in the main z5 surface delta map you see (a) a spherically symmetric shape that is indicative of being out of focus, and (b) a higher surface RMS. Then when you look at the solution with the focus removed ("absolute solution with focus removed") there is a decent surface with the spherically symmetric shape gone and the RMS is more reasonable. This example demonstrates the use of looking at the surface corrections with the focus removed. And in this case, we would say that the z5 solutions are good (we saw that the surface solutions look good via removing the focus) and would apply those.

.. note:: 

    Looking at the surface corrections with the focus removed is particularly useful when you are uncertain if an OOF is good or not - as in a marginal or bad case. In a good case the solutions with the focus removed will not look different from the initial solution that you see.

.. todo:: confirm and workshop wording of above note. 

.. todo:: any other advice to add?

OOF Examples
============

Bad: Keyhole
------------
OOF done with Argus in the keyhole at >85° which resulted in an OOF "rms"=438 :math:`\mu\mathrm{m}` with a large implied focus and elevation (el) pointing offset. 

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/bad/AGBT17B_044_01_s3_bad_keyhole_z5_fixedScale.png

    .. tab:: z4

        .. image:: images/autoOOF/bad/AGBT17B_044_01_s3_bad_keyhole_z4_fixedScale.png

    .. tab:: z3

        .. image:: images/autoOOF/bad/AGBT17B_044_01_s3_bad_keyhole_z3_fixedScale.png

Notice that they all have sharp features and the higher orders have RMS :math:`\gtrsim` 400 :math:`\mu\mathrm{m}` and large implied foci and elevation pointing offsets. 

Fitted beam map:

.. figure:: images/autoOOF/bad/AGBT17B_044_01_s3_bad_keyhole_fitted_beam_map.png

.. todo:: what to note for the fitted beam maps?

Bad: High Winds
---------------
OOF done with Argus in windy conditions.

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/bad/AGBT19A_326_07_s20_z5_fixedScale.png

    .. tab:: z4

        .. image:: images/autoOOF/bad/AGBT19A_326_07_s20_z4_fixedScale.png

    .. tab:: z3

        .. image:: images/autoOOF/bad/AGBT19A_326_07_s20_z3_fixedScale.png

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/bad/AGBT19A_326_07_s20_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/bad/AGBT19A_326_07_s20_fitted_beam_map.png

        We see that the middle observed beam is elongated and that the Zernike fits to the beam are streaky.

.. todo:: What to say about SNR? What should we be noting for the fitted beam map?

Bad: Low SNR
------------
You should always check the SNR of your OOF sources. To do this go to the ``DataDisplay`` tab and then click ``raw data``. See :numref:`fig-good-oof-raw-data` (look particularly at the row that is marked "After baseline removal") for an example of what good raw data SNR plots look like and see :numref:`fig-bad-oof-raw-data` for an example of what bad raw data SNR plots look like (as in you do not see the source at all).

But here is an example of an OOF done with Argus that is categorized as a "marginal OOF" with borderline SNR.

.. admonition:: Argus Marginal OOF Example 

    .. tab:: z5 Surface Delta Map

        .. image:: images/autoOOF/bad/AGBT17B_151_68_s3_z5_fixedScale.png

    .. tab:: Raw data

        .. image:: images/autoOOF/bad/AGBT17B_151_68_s3_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/bad/AGBT17B_151_68_s3_fitted_beam_map.png

Notice that though the RMS of the surface delta map is 244 :math:`\mu\mathrm{m}` (which is reasonable and categorized as good), the SNR of the data is overall low (especially the +12mm focus "After baseline removal"). If you have low RMS from an OOF with Argus, you might not be detecting the source. And if you aren't detecting a source, your "signal" is just noise and RMS of noise is likely low so you would expect a low surface RMS. So for all receivers that you can OOF with besides MUSTANG-2, you need to make sure you have a high SNR source for OOFing. 

**Advice for this situation:** Find a different source to OOF on with higher SNR.

.. todo:: Middle focus has elongated beam that looks like what you get from high winds. So is elongation the effect from not having enough SNR? 

.. todo:: Is one focus scan not having enough SNR enough to say find another source? 

Comparing Ka and Argus OOF on Same Source
-----------------------------------------
Here is a comparison of the raw data from an OOF taken on the same source (3C84 - 0319+4130) with Ka+CCB and Argus. 

.. admonition:: Comparison of OOF on 3C84 with Ka+CCB and Argus

    .. tab:: Ka+CCB

        .. image:: images/autoOOF/Argus/TGBT19B_506_01_s3_Ka_raw_data.png

    .. tab:: Argus

        .. image:: images/autoOOF/Argus/Argus_3C84_resized.png

The takeaway here is that if you can do your OOF with Ka (unless you are a MUSTANG-2 observer) do it with Ka as the larger beam size allows for better SNR of a source and thus a better OOF solution.

.. todo:: confirm this is what the takeaway should be.

Q-band
------
Both of the following OOFs were taken during a VLBI run where the observer used Q-band to OOF and then observed with W-band.

Bad
^^^
Right at the start of the observing session, the observer started with an OOF with Q-band.

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_z5_fixedScale.png

    .. tab:: z4

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_z4_fixedScale.png

    .. tab:: z3

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_z3_fixedScale.png

All of the above surface delta maps have a) sharp features, b) a high surface RMS, and c) high focus corrections. The observer chose not to apply the solutions. You can look at the scaled surface delta maps in :ref:`how-tos/general_guides/autooof:Scaling for a Bad OOF` -> Example 1.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF1_bad_fitted_beam_map.png

        We see that the +- focal positions do not look good.

**Advice for this situation:** not to apply the solutions and carry on.

.. todo:: confirm this is the advice to give in this situation.

Uncertain
^^^^^^^^^
Then later in the session, the observer decided to OOF again.

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z5_fixedScale.png

        Notice the sharp features, very high surface RMS, and large focus correction. 

    .. tab:: z4

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z4_fixedScale.png

        Notice the sharp features, high surface RMS, and large focus correction. 

    .. tab:: z3

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z3_fixedScale.png

        Notice the sharp features have been minimized, the surface RMS is still high but not as high as before, and the focus correction is much smaller. 

You can look at the scaled surface delta maps in :ref:`how-tos/general_guides/autooof:Scaling for an Uncertain OOF`.

This is a good example in which to see if the surface corrections look ok with the focus removed.

.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z5_focus_removed.png

        Notice the sharp features are still there and there is still a very high surface RMS.

    .. tab:: z4

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z4_focus_removed.png

        Notice the sharp features are still there (though more muted) but now the surface RMS has dropped to a reasonable regime. 

    .. tab:: z3

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_z3_focus_removed.png

        Notice that there are no longer sharp features (though those had resolved in the initial surface delta map) and that the spherical feature that is indicative of being out of focus has disappeared. But the main thing to note is that the surface RMS has dropped to a good regime.

Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/Q-band/AGMV24B_376_01_OOF2_iffy_fitted_beam_map.png

**Advice for this situation:** Based on all of this data, the advice in this case is to appy the z3 solutions. This is a good example that sometimes the z5 solutions aren't a great fit and going to a lower order gets you getter solutions.

.. todo:: are Q-band focus scans always at +- 35mm?


Argus
-----
.. note:: 

    When the weather is good, OOFing with Argus is ok (in that you can get the SNR needed to fit the surface), but when the weather is marginal getting a useable Argus OOF is challenging. Thus, the general guidance is to OOF with Ka if its available.

Good
^^^^
.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/Argus/AGBT21B_024_40_s3_z5_fixedScale.png

    .. tab:: z4

        .. image:: images/autoOOF/Argus/AGBT21B_024_40_s3_z4_fixedScale.png

    .. tab:: z3

        .. image:: images/autoOOF/Argus/AGBT21B_024_40_s3_z3_fixedScale.png


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/Argus/AGBT21B_024_40_s3_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/Argus/AGBT21B_024_40_s3_fitted_beam_map.png

.. todo:: Replace this example or add another one.

Bad
^^^
See the many examples above (see the first three bad examples of :ref:`how-tos/general_guides/autooof:OOF examples` section).

MUSTANG-2
---------
MUSTANG-2 observers use OOF not only for correcting the surface but also for their pointing and focus corrections (as opposed to using an AutoPeakFocus as other receivers do). Below are examples of good, bad, and uncertain OOFs. Additionally, MUSTANG-2 observers use an IDL GUI to check the beam and keep an eye on the data (see :ref:`how-tos/receivers/mustang2/mustang2_obs:4. Checking data with the m2gui`). Thus the "raw data" view in the "DataDisplay" -> "OOF" tab are not of particular use to MUSTANG-2 observers. 

.. note::

    The order of the focus values for a MUSTANG-2 OOF is typically -10mm, 0 mm, then 10 mm. However, when you look at the "fitted beam map" in AstrID, the order will be +10mm, 0, -10mm (so inverted from the order of the scans).

Good
^^^^

Example 1
~~~~~~~~~

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z5_fixedScale.png

        Notice the relatively smooth features, good surface RMS, and small focus correction. 

    .. tab:: z4

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z4_fixedScale.png


    .. tab:: z3

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z3_fixedScale.png

You can look at the scaled surface delta maps in :ref:`how-tos/general_guides/autooof:Scaling for a Good OOF`.

.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z5_focus_removed.png

        Notice the relatively smooth features, good surface RMS, and small focus correction. 

    .. tab:: z4

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z4_focus_removed.png


    .. tab:: z3

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_z3_focus_removed.png


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/good/AGBT21A_376_01_s5_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.


Example 2
~~~~~~~~~

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/good/AGBT21B_206_06_s8_z5_fixedScale.png

        Notice the relatively smooth features, good surface RMS, and small focus correction. 

    .. tab:: z4

        .. image:: images/autoOOF/M2/good/AGBT21B_206_06_s8_z4_fixedScale.png


    .. tab:: z3

        .. image:: images/autoOOF/M2/good/AGBT21B_206_06_s8_z3_fixedScale.png

Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/good/AGBT21B_206_06_s8_raw_data2.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/good/AGBT21B_206_06_s8_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/good/AGBT21B_206_06_s8_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.

Example 3
~~~~~~~~~

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/good/AGBT21B_298_08_s42_z5_fixedScale.png

        Notice the relatively smooth features, good surface RMS, and small focus correction. 

    .. tab:: z4

        .. image:: images/autoOOF/M2/good/AGBT21B_298_08_s42_z4_fixedScale.png


    .. tab:: z3

        .. image:: images/autoOOF/M2/good/AGBT21B_298_08_s42_z3_fixedScale.png

Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/good/AGBT21B_298_08_s42_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/good/AGBT21B_298_08_s42_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/good/AGBT21B_298_08_s42_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.


Bad
^^^

Example 1
~~~~~~~~~
.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_z5_fixedScale.png

        Notice the sharp features, very high surface RMS, and very large focus correction.  

    .. tab:: z4

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_z4_fixedScale.png

        Notice the sharp features, very high surface RMS, and very large focus correction.

    .. tab:: z3

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_z3_fixedScale.png

        Notice the sharp features, very high surface RMS, and very large focus correction.


.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_z5_focus_removed.png

        Notice that even though the spherical shape indicative of a large focus correction the sharp features are still there. There is a more reasonable but still high surface RMS.

    .. tab:: z4

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_z4_focus_removed.png

        Notice that even though the spherical shape indicative of a large focus correction the sharp features are still there. There is a more reasonable but still high surface RMS.

    .. tab:: z3

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_z3_focus_removed.png

        Notice that even though the spherical shape indicative of a large focus correction the sharp features are still there. There is a more reasonable surface RMS.


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s41_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.

.. todo:: advice for what to do in this case.

Example 2
~~~~~~~~~

.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z5_fixedScale.png

        Notice the sharp features, very high surface RMS, but small focus correction.  

    .. tab:: z4

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z4_fixedScale.png

        Notice the sharp features, high surface RMS, and large focus correction.

    .. tab:: z3

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z3_fixedScale.png

        Notice that the sharp features have gotten better and reasonable surface RMS, but a very large focus correction.

You can look at the scaled surface delta maps in :ref:`how-tos/general_guides/autooof:Scaling for a Bad OOF` -> Example 2.

.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z5_focus_removed.png

        Notice that the sharp features are still there, very high surface RMS, and large focus correction.

    .. tab:: z4

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z4_focus_removed.png

        Notice that the sharp features are still there, very high surface RMS, and large focus correction.

    .. tab:: z3

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_z3_focus_removed.png

        Notice that removing the focus correction has not changed the shape of the surface delta map.


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/bad/AGBT21B_206_06_s46_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.

.. todo:: advice for what to do in this case.

Uncertain
^^^^^^^^^

Example 1
~~~~~~~~~
.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_z5_fixedScale.png

        Notice the sharp features, high surface RMS, and very large focus correction.  

    .. tab:: z4

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_z4_fixedScale.png

        Notice that the sharp features have become more muted (though still a bit there on the right of the surface delta map), high surface RMS, and large focus correction.

    .. tab:: z3

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_z3_fixedScale.png

        Notice that the sharp features have disappeared and there is now a reasonable surface RMS, but still a large focus correction.


.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_z5_focus_removed.png

        Notice that the sharp features are still there and a high surface RMS.

    .. tab:: z4

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_z4_focus_removed.png

        Notice that removing the focus correction has created some more features in the surface delta map but that the surface RMS is still in the reasonable regime. 

    .. tab:: z3

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_z3_focus_removed.png

        Notice that removing the focus correction has created some sharper features in the lower portion of the surface delta map and there is still a reasonable surface RMS.


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s3_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.

**Advice for this situation:** apply z3.

Example 2
~~~~~~~~~
.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_z5_fixedScale.png

        Notice the sharp feature in the upper portion of the surface delta map and high surface RMS, but a relatively reasonable focus correction.  

    .. tab:: z4

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_z4_fixedScale.png

        Notice that the sharp feature has become more muted though still exists but now there is a reasonable surface RMS. however the focus correction has doubled.

    .. tab:: z3

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_z3_fixedScale.png

        Notice that the sharp feature has mostly disappeared and there is now a low surface RMS, but now there is a large focus correction.


.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_z5_focus_removed.png

        Notice that removing the focus corretion has muted the sharp features are still and there is now a reasonable surface RMS.

    .. tab:: z4

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_z4_focus_removed.png

        Notice that removing the focus correction has created sharper features in the surface delta map and now there is a higher surface RMS.

    .. tab:: z3

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_z3_focus_removed.png

        Notice that removing the focus correction has created sharper features in the surface delta map and now there is a higher surface RMS.


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/uncertain/AGBT21B_298_08_s20_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.

**Advice for this situation:** apply z5.


Example 3
~~~~~~~~~
.. admonition:: Different Zernike order surface delta maps

    .. tab:: z5

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_z5_fixedScale.png

        Notice the sharp features in the upper, lower, left, and right portions of the surface delta map and just generally looks a little wonky. Notice that though the RMS is in the reasonable range it is on this high end. The focus correction is reasonable.   

    .. tab:: z4

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_z4_fixedScale.png

        Notice that previously shapr feature has disappeared and the typical structure of a MUSTANG-2 OOF is now seen. Surface RMS and focus corrections are in the reasonable range. 

    .. tab:: z3

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_z3_fixedScale.png

        Not much different from z4.


.. admonition:: Solutions with Focus Removed

    .. tab:: z5

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_z5_focus_removed.png

        Notice that removing the focus corretion has not changed the surface delta map nor the surface RMS.

    .. tab:: z4

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_z4_focus_removed.png

        Notice that removing the focus corretion has not changed the surface delta map nor the surface RMS.

    .. tab:: z3

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_z3_focus_removed.png

        Notice that removing the focus corretion has not changed the surface delta map nor the surface RMS.


Check the raw data and fitted beam maps.

.. admonition:: Raw data and fitted beam maps

    .. tab:: Raw data

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_raw_data.png

    .. tab:: Fitted beam map

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_fitted_beam_map.png

    .. tab:: Beam maps from M2 GUI

        .. image:: images/autoOOF/M2/uncertain/AGBT22A_459_04_s3_m2_gui_beam_maps.png

        Lower left hand corner has the scan number (s#) then the focus value.

**Advice for this situation:** apply z4.


Sending a Solution to the Active Surface
========================================

When you are ready to accept the solution being displayed it will need to be manually sent to the active surface. It is recommended that when sending the solutions, you use the yellow button labeled ``Send Selected Solution with Point and Focus Corrections``. If you use this option, you do not have to perform a Peak or Focus after an AutoOOF. It is still good practice to run a Peak and Focus at the beginning of your observing session unless you are using the :ref:`W-band (68-92 GHz) <references/receivers/w-band:W-Band receiver>`. Subsequent pointing and focus corrections may be computed via AutoOOF.

Many high frequency observers will perform Peak scans immediately following an AutoOOF to verify the surface solution. If the solution is satisfactory the LPCs and LFC from Peak/Focus scans should agree with values from the OOF solution, there should be no significant sidelobes visible in the peak scans, and Peak scans should also yield the expected beam FWHM. If in doubt, you may disable OOF corrections by pressing ``Zero and Turn Off Thernal Zernike Solution`` in order to compare Peak scans with and without OOF corrections.


FAQ
===

I have a low RMS. What should I do?
-----------------------------------
Nothing! It is not bad to have a low RMS. It just means it is a stable night and the difference in the surface between when the surface was last set and now is small. Technically, there isn’t a lower limit for OOF surface RMS solutions; though GBO staff haven't seen one below 40 :math:`\mu\mathrm{m}`. See below for an example of a "low" RMS of 66 :math:`\mu\mathrm{m}` from an Argus observing run:

.. image:: images/autoOOF/misc_examples/AGBT21B_065_03_z5_fixedScale.png

What if OOF fails?
------------------
Sometimes OOF may time out and you will get a red screen like this. 

.. image:: images/autoOOF/OOF_failure_to_process.png

If you get this red screen, this means that for some reason the OOF processing failed. This type of red screen has only been seen during MUSTANG-2 observations. OOF processing for M2 can take a while. GFM checks the directory where the processing script puts the solutions for the files and if in a certain amount of time, GFM doesn’t find the solutions, it puts up that red screen.

If you get this, start another OOF and diagnose the underlying problem.


How do I view the results of a previous OOF?
--------------------------------------------
In AstrID, select the ``DataDisplay`` tab, then go to ``File`` -> ``Open``. Load the project folder of interest via the ``Location`` field, by entering the path and hit enter. Select the ``ScanLog.fits`` file, and press ``Open``. As you wait for the scan details to load, go to ``DataDislay`` -> ``OOF``. Once the scan information has loaded, find the set of OOF scans (3 RALongMaps together), and select the third scan and you should see the OOF results.
