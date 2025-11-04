
Pointing and Focusing Strategies
--------------------------------

How often you need to point and focus the GBT depends on the frequency of your observations,
the weather conditions, whether or not it is day or night-time, and the amount of flux error
that your experiment can tolerate from pointing and focus errors. See Table~\ref{table:wind} 
for guidelines on how often to Point/Focus. Note that spacings between Point/Focus observations
may be increased if results appear stable, especially during the night. 

Within the DSS, the tracking error :math:`\sigma_{tr}` (in arcseconds) as a function of wind
speed :math:`s` (in m s\ :math:`^{-1}`) is given by


.. math::
    :label: eq-wind

    \sigma_{tr}^2 = \sigma_0^2 + \left(\dfrac{s}{3.5}\right)^4,
    
where :math:`\sigma_0=1.32^{\prime\prime}` at night and :math:`\sigma_0=2.19^{\prime\prime}`
during the day, and is the tracking and pointing error with no winds. 

.. todo:: Check what is the trakcing and pointing error with no winds.


The DSS will only schedule observations if the tracking error is smaller than a specified
fraction (:math:`f<f_{max}`) of the beam FWHM (:math:`\sigma_{beam}`) given by

.. math:: 

    f = \frac{\sigma_{tr}}{\sigma_{beam}} = \frac{\sigma_{tr}\nu}{748},
    
where :math:`\nu` is the observing frequency in GHz.  Values for :math:`f_{max}` in the DSS 
are currently set at 0.2 for receivers below 50 GHz, 0.22 for receivers above 50 GHz and 0.4 
for filled arrays.  An :math:`f_{max}` value of 0.2 assures observers that their flux 
uncertainty due to tracking errors is no more than 10%, assuming they are observing a point
source.


:numref:`tab-peak-focus-recommendations` lists wind limits using default DSS parameters. You may wish to alter some parameters 
in the DSS to better suit your observing requirements. For example, pointing may be relaxed for extended sources 
(i.e. set :math:`\theta_{src}>0` in the DSS), or more tightly constrained (a value of :math:`f_{max}=0.14` in the
DSS assures no more than 5% flux uncertainty due to tracking errors). You may request changes to DSS control
parameters by contacting your GBT project friend and emailing the :email:`DSS helpdesk <helpdesk-dss@nrao.edu>`.

For further information on DSS control parameters see :ref:`references/dss:Other DSS Control Parameters`. 
See DSS Project Note 18.1 :cite:p:`Maddalena2014` for tracking performance and parameters used in Equation :eq:`eq-wind`.


.. include:: /material/tables/peak-focus-recommendations.tab


:numref:`tab-peak-focus-default-vals`  lists the default scanning rates and lengths for all receivers.

.. include:: /material/tables/peak-focus-default-vals.tab


.. todo:: Move this table to an appropriate place in the reference section.

