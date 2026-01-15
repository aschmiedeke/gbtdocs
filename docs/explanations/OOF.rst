.. _OOF_explanation:

#####################
An Explanation of OOF
#####################

Context
=======
For successful high-frequency observing with the GBT, the dish must be a nearly perfect parabola. To correct for these factors the GBT uses an active surface: actuators at panel intersections adjust the dish shape. Most intersections have four corner actuators; on the dish edges, there are two actuators per intersection. Each actuator has one degree of freedom, pushing its corner up or down to correct the surface.

Several forces cause deviations from a perfect parabola, producing surface deformations that distort the beam from its theoretical shape. These deviations have the greatest impact on high-frequency observing (greater than 8 GHz) because the scale of the surface errors becomes comparable to or larger than the observed wavelength, thereby strongly affecting the collected signal. The two main factors driving these deformations are gravitational and thermal effects.

.. _fig-deformations-oof:
.. figure:: images/OOF/Moravec_forces_of_deformation_v3.png

	a: Illustration of how changes in elevation will cause deformations in the dish. b: Illustration of how differential heating of the dish due to thermic activity will cause deformations in the dish. Illustration credit: Emily Moravec.

(A) **Gravity.** As you move the telescope to different elevations in the sky, the structure of the dish changes due to gravity (and thus deviates from a perfect parabola) - see panel (a) of :numref:`fig-deformations-oof`. We can predict the expected amount of deformation due to gravity as a function of elevation based on the engineering design of the telescope. This prediction or model is referred to as the “gravity model.” 

(B) **Differential heating of the dish due to thermic activity.** During the day the sun will heat up the dish (indicated by the sun in panel (b) of :numref:`fig-deformations-oof`) in a potentially non-uniform way. Thus the sun causes differential heating of the dish. During the night, the ground having been warmed during the day is warmer than the dish (illustrated in panel (b) of :numref:`fig-deformations-oof`), and the same situation occurs where one or more portions of the dish is heated up more than another. The differential heating due to the sun during the day and the ground at night cause deformations in the dish which in turn causes deviations from a perfect parabola.

Zernike Polynomials
===================
Gravitational and thermal effects deform the dish surface, introducing large-scale deviations from the ideal parabolic shape. These deformations are modeled using `Zernike polynomials <https://en.wikipedia.org/wiki/Zernike_polynomials>`_, a complete set of orthogonal functions defined over a circular aperture. Originally formulated by Frits Zernike in 1934, these polynomials are fundamental in optical analysis because each term isolates an independent, physically meaningful mode of surface or wavefront variation. The radial order n (or degree) determines the spatial complexity of the shape variations: low orders (n≤2) represent basic forms such as tilt, focus, and astigmatism, while higher orders (n≥3) correspond to more intricate distortions like coma and trefoil. Increasing the order increases the number of polynomials used (e.g., 3rd order = 10 terms, 4th = 15, 5th = 21) and thus expands the model’s descriptive power. For the Green Bank Telescope (GBT), we typically fit the surface using the third, fourth, and fifth orders to capture the large-scale errors in the surface.

So how do we use the Zernike polynomials to describe the surface of the GBT? As listed above there are two major contributors to the shape of the dish, gravity and thermal activity. We correct the dish for the large-scale errors introduced by gravity and thermal activity by measuring the shape of the dish at a given point in time and then fitting the surface with Zernike polynomials. And in the end we measure the magnitude of each polynomial's contribution to the shape of the surface through (Zernike) coefficients.


Modeling and Correcting for Gravity
===================================
There are two ways that the user can correct the dish for the deformations in the dish caused by gravity.

The first is the **Finite Element Model** (`FEM <https://gbtdocs.readthedocs.io/en/latest/glossary.html#term-FEM>`_). This theoretical model estimates the effect of gravity on the dish at a given elevation based solely on the telescope’s engineering design. This model is almost always turned on by default(but it is good to check that it is on). 

It was found that the FEM did not fully account for the effect of gravity on the dish. Therefore on top of the FEM, GBO staff have put a lot of time and effort into calculating empirical deltas that are a function of elevation to fully correct for the effect of gravity on the dish. We will call these additional gravity corrections to the dish the **gravity-Zernike model** ("gravity model" for short)

The gravity model is described by a combination of the Zernike polynomials as a function of elevation. The amplitude of the contribution to the model of each Zernike polynomial at a given elevation is determined by coefficients A, B, and C according to:

:math:`Z_n = A_n \sin(el) + B_n \cos(el) + C_n` 
where :math:`el` is the elevation. 

To create the gravity-Zernike model, the surface is measured at a large range of elevations with a process called Out Of Focus holography (OOF, defined and explained below in :ref:`explanations/OOF:OOF`). The user can then fit for the coefficients (:math:`A_n`, :math:`B_n`, :math:`C_n`) to determine the amplitude of the contribution of each of the Zernike polynomials to the gravity-Zernike model at each elevation. For the gravity-Zernike model, Zernike polynomials through the 5th order (in total 21 Zernike polynomials). For more details, see PTCS Project Note #76 - Maddalena et al., 2014.

With the gravity–Zernike model in hand, the active surface (recommended for observing at frequencies :math:`\geq` 5 GHz/C-band and above) can be enabled so that the effects of gravity on the dish shape at a given elevation are corrected by the software. If the active surface is turned on, these corrections are made automatically (the user does not need to do anything).

Reference and further reading: Frayer et al. 2019 - `GBT Memo 301 <https://library.nrao.edu/public/memos/gbt/GBT_301.pdf>`_


OOF
===
Despite the corrections for the effects of gravity on the dish, there are still large-scale errors that remain (e.g., from differential heating or small errors in the gravity model). In order to correct for these, we use use Out Of Focus (OOF implemented as :func:`AutoOOF() <astrid_commands.AutoOOF>`) mapping (holography) observations of bright point sources to derive the shape of the surface using Zernike polynomials and correct for all other deviations away from perfect parabola in the surface.

How this works is that the :func:`AutoOOF() <astrid_commands.AutoOOF>` procedure takes scans of a bright, compact point source (bright and point source are important!). Specifically, ssing the subreflector, :func:`AutoOOF() <astrid_commands.AutoOOF>` makes 3 maps of the bright point source, in order: a map in focus (shown in left of the image below), a map out of focus in the positive direction (typically 10 mm, shown in middle of the image below), and a map out of focus in the minus direction (typically -10 mm, shown in right of the image below). 

.. image:: images/OOF/OOF_scans.png

Normally, we use the dish to map an astronomical source but with OOF we invert that calculation where we use a source to map the dish. This is possible because we know what a bright point source convolved with the beam *should* look like and use that as a reference. Then we simply invert the calculation and thus determine what the shape of the dish is. Making three maps by going in and out of focus is crucial for getting 3D information.

Resources for Further Reading:
	* GBT Memo #271: `Schwab and Hunter 2010 <https://library.nrao.edu/public/memos/gbt/GBT_271.pdf>`_  
	* `Nikolic et al 2007a <https://ui.adsabs.harvard.edu/abs/2007A%26A...465..685N/abstract>`_
	* `Nikolic et al 2007b <https://ui.adsabs.harvard.edu/abs/2007A%26A...465..679N/abstract>`_
	* `Hunter et al 2011 <https://ui.adsabs.harvard.edu/abs/2011PASP..123.1087H/abstract>`_

AutoOOF Procedure
=================
According to the recommended :ref:`AutoOOF_guide`, AutoOOF is recommended for observing at frequencies of 40 GHz and higher and only available for use with Rcvr26_40 (Ka–band), Rcvr40_52 (Q–band), Rcvr68_92 (W-band), RcvrArray75_115 (Argus), and Rcvr_MBA1_5 (MUSTANG-2).

:func:`AutoOOF() <astrid_commands.AutoOOF>` is currently only executed for observing projects at night time. In general, it will take 20-25 minutes to do an :func:`AutoOOF() <astrid_commands.AutoOOF>`. The :func:`AutoOOF() <astrid_commands.AutoOOF>` procedure takes three 5-6 minute on-the-fly maps at different focus positions (typically at focus, +10 mm, and -10mm). For details on how long OOF solutions remain valid in varying conditions see :ref:`how-tos/general_guides/autooof:How long does an OOF solution remain valid?`.

:func:`AutoOOF() <astrid_commands.AutoOOF>` not only determines the thermal corrections for the dish but it also derives pointing and focus offsets. The processing of the 3 maps of the source is launched automatically upon completion of the third map, and the result is displayed in the OOF plug-in tab of AstrID. To see when the OOF has been processed and view the results, go to AstrID -> *DataDisplay* -> *OOF*. 

When :func:`AutoOOF() <astrid_commands.AutoOOF>` has finished processing, it will look like the following:

.. _fig-oof-surface-delta-map:
.. figure:: images/OOF/example_OOF_AGBT23B_005_01_s2.png

	An example of a processed OOF from a MUSTANG-2 project. 

The image that is displayed in the left of the OOF tab is the effective shape of the dish and it displays the measured differences (referred to as :math:`\Delta`'s or "deltas") from the current surface to the computed optimal surface. Let’s call this image the "surface delta map". The algorithm takes the raw data of the surface of the dish, fits the 3rd, 4th, and 5th orders of Zernike polynomials to that data, and produces the surface delta map shown in the *OOF* tab. 

For illustration, we express the measured large-scale errors on the dish at a given time and elevation as 

:math:`z_{tot} = z_{grav} + z_{thermal}` 

where :math:`z_{tot}` is the measured surface of the dish (what is actually measured by :func:`AutoOOF() <astrid_commands.AutoOOF>`) expressed by a combination of Zernike polynomials, :math:`z_{grav}` is the contribution to the large-scale errors from the effects of gravity (calculated from the gravity model), and :math:`z_{thermal}` is simply the difference between :math:`z_{tot}` and :math:`z_{grav}`. AutoOOF calculates :math:`z_{thermal}` by subtracting known values of the gravity model at that elevation (:math:`z_{grav}`) from the measured surface (:math:`z_{tot}`), thus :math:`z_{thermal} = z_{tot} - z_{grav}`. Therefore, the solutions (shown in the surface delta map) that are calculated via OOF are often called "Zernike Thermal Solutions" or "Thermal Coefficients" for short. 

Once the OOF has been processed, it is incumbent upon the user to examine the solutions, including inspecting the various orders of Zernike thermal solutions (denoted by :math:`z_{n}` where n is the nth order of Zernike thermal solutions). For directions and advice on selecting solutions, see the :ref:`AutoOOF_guide` and in particular the :ref:`how-tos/general_guides/autooof:Inspecting AutoOOF Solutions` section. 

CLEO Active Surface Coefficients
================================
The user can view the various versions of Zernike coefficients via CLEO’s Active Surface window. To open the Active Surface window, CLEO -> ``Launch`` -> ``Active Surface…`` which will produce a window like the following:

.. image:: images/OOF/cleo_active_surface/cleo_active_surface.png

.. note::

	On the startup screen of the Active Surface, there is a box that says ``FEM model``. This was described in :ref:`Modeling and Correcting for Gravity <explanations/OOF:Modeling and Correcting for Gravity>`. Typically this is on by default, but it is good to check that this is on via this CLEO window.

There are many different tabs in Active Surface window and we describe the ones that are pertinent to OOF below.

Zernike Thermal Coef
--------------------
This tab contains the amplitude of the contributions (coefficients) of the first 21 zernike polynomials for the thermal contributions to the shape of the dish. This is what is calculated from AutoOOF. When the corrections are sent via AutoOOF, these values should update.

.. image:: images/OOF/cleo_active_surface/cleo_as_thermal.png

.. note::

	``Zero All Thermal Coefficients`` - this sets all Zernike thermal coefficient values to 0. When the thermals are zeroed out and a new OOF is performed, the resulting solution is compared directly to the gravity model, which is useful if an incorrect OOF solution was recently applied; zeroing the Zernike thermal coefficients effectively provides a clean starting point.

OOF Coef
--------
The OOF coefficients are the coefficients of the gravity-Zernike model (see explanation in :ref:`Modeling and Correcting for Gravity <explanations/OOF:Modeling and Correcting for Gravity>`). This tab shows the values of the coefficients (A, B, and C) that determine the amplitude of the contribution of the first 21 zernike polynomials to the gravity-Zernike model.

.. image:: images/OOF/cleo_active_surface/cleo_as_OOF.png

Zernike Coef
------------
The amplitude of the contributions of the first 21 Zernike polynomials to the shape of the dish. These are the "total Zernikes" that OOF measures.

.. image:: images/OOF/cleo_active_surface/cleo_as_zernike.png
