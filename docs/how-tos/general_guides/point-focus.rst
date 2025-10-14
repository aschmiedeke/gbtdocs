
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

.. _tab-peak-focus:
.. table:: Observing wind limits using DSS default parameters and suggested time periods 
   between pointing and focus observations

   +----------------+-------------------+-------------------+---------------------------------------------------+
   |                |                   | Wind limit (m/s)  | .. centered:: Recommended Pointing/Focus spacing  |
   +                +                   +---------+---------+---------------------------+-----------------------+
   | Receiver       | :math:`\nu` [GHz] | Day     | Night   | .. centered:: Day         | .. centered:: Night   |
   +================+===================+=========+=========+===========================+=======================+
   | Rcvr_342       | 0.340             | 73.4    | 73.4    | .. centered:: -- Initial Peak only --             | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr_450       | 0.415             | 66.5    | 66.5    | .. centered:: -- Initial Peak only --             | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr_600       | 0.680             | 52.0    | 52.0    | .. centered:: -- Initial Peak only --             | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr_800       | 0.770             | 48.8    | 48.8    | .. centered:: -- Initial Peak only --             | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr_1070      | 0.970             | 43.5    | 43.5    | .. centered:: -- Initial Peak only --             | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr1_2        | 1.4               | 36.2    | 36.2    | .. centered:: -- Initial Peak and Focus only --   | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr2_3        | 1.8               | 30.3    | 30.3    | .. centered:: -- Initial Peak and Focus only --   | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr4_6        | 5.0               | 19.1    | 19.1    | Hourly on hot afternoons  | Every 2-3 hours       |
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr8_10       | 10.0              | 13.5    | 13.5    | Hourly on hot afternoons  | Every 2-3 hours       | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr12_18      | 15.0              | 11.0    | 11.0    | Hourly                    | Every 1-2 hours       | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | RcvrArray18_26 | 25.0              | 8.3     | 8.5     | Hourly                    | Every 1-2 hours       | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr26_40      | 32.0              | 7.1     | 7.4     | Hourly                    | Hourly                | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr40_52      | 43.0              | 5.5     | 6.1     | Every 30-60 minutes       | Hourly                | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr68_92      | 80.0              |         | 4.4     | Every 30-60 minutes       | Every 30-60 minutes   | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr_PAR       | 90.0              | 5.5     | 6.1     | Every 30-60 minutes       | Every 30-60 minutes   | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   | Rcvr75_115     | 95.0              |         |         | [#]_                      | Every 30-45 minutes   | 
   +----------------+-------------------+---------+---------+---------------------------+-----------------------+
   
.. rubric:: Table Footnotes
.. [#] It is not recommended to observe with Argus during the day.


:numref:`tab-peak-focus` lists wind limits using default DSS parameters. You may wish to alter some parameters 
in the DSS to better suit your observing requirements. For example, pointing may be relaxed for extended sources 
(i.e. set :math:`\theta_{src}>0` in the DSS), or more tightly constrained (a value of :math:`f_{max}=0.14` in the
DSS assures no more than 5% flux uncertainty due to tracking errors). You may request changes to DSS control
parameters by contacting your GBT project friend and emailing the :email:`DSS helpdesk <helpdesk-dss@nrao.edu>`.

For further information on DSS control parameters see :ref:`references/dss:Other DSS Control Parameters`. 
See DSS Project Note 18.1 :cite:p:`Maddalena2014` for tracking performance and parameters used in Equation :eq:`eq-wind`.

