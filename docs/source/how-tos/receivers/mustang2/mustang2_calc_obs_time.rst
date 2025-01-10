.. _mustang2_calc_obs_time:

#######################################################
How to Calculate Observing Time Required for MUSTANG-2
#######################################################

MUSTANG-2 is NOT included in the GBT sensitivity calculator thus sensitivities are typically calculated using simulations or previous observations. 

If your observations require recovery of extended signal, it is necessary to account for signal filtering (e.g. a transfer function). The technical justification must state some measure of filtered signal to be observed and a corresponding required sensitivity. 

In order that those parameters may be validated, we suggest the following options, in order of preference:
 a. run observing simulations using `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ (strongly preferred), 
 b. use existing MUSTANG-2 data in conjunction with the :ref:`radiometer equation <2. Using the Radiometer Equation>`, or
 c. reach out to the MUSTANG-2 team to find another option (e.g. running your own simulations).

Note that previously MUSTANG-2 observations required stating an expected signal and required sensitivity. The observing time could be calculated from the :ref:`mapping speeds <MUSTANG-2 Mapping Information>` and required sensitivity. This approach should be considered deprecated for targets with extended signal, as M2_ProposalTools accounts for signal filtering and provides methods to create a map of the expected noise (as RMS). For singular point sources (< 1 mJy) this approach is still valid.

Always feel free to contact the MUSTANG-2 instrument team with questions.

Below we list common scientific cases for MUSTANG-2 and how we recommend you calculate the required exposure time for that scientific use case.

1. Galaxy Clusters
==================
Galaxy clusters are expected to be nearly self-similar and observations tend to support that they can be described by a universal pressure profile (UPP). Specifically, it's common practice to use an A10
`A10 <https://ui.adsabs.harvard.edu/abs/2010A%26A...517A..92A/abstract>`_ , from Arnaud et al. (2010), pressure profile which is a function of solely mass and redshift. For many MUSTANG-2 observations of galaxy clusters, we find that it is sufficient to assume the parameters in A10 for the morphologically disturbed subset (see Table C.2 in Arnaud et al. (2010)).

1.1 Running Simulations
-----------------------
All cases below require that you have installed `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ on your computer. Note that this tool adopts a default assumption of an Arnaud+ 2010 UPP profile for clusters (as a function of M,z) and has a keyword to assume the parameters for the pressure profile of the disturbed clusters used in A10.

1.1.1 Cluster Core Detection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In the case in which the proposer wants to detect the cluster of a given mass and redshift, they can use this :download:`Cluster Detection Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_t_cluster_detection.ipynb>` which will a simulation that includes the effects of filtering. This notebook will run a simulation for a single cluster or a list of clusters and output the total time required to reach a given signal-to-noise ratio (including a factor of 2 for overheads).

1.1.2 Constraining pressure profiles out to X radius.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For the case that a proposer would like to constrain a pressure profile of a cluster out to X radius (and very closely related, constraining the mass, especially if X is R_500), the general process will be to simulate the observations of a cluster given a certain integration time, mass, and redshift, then fit the pressure profile of the simulated data and determine if the product (pressure profile and/or mass) meets the scientific goals of the proposer.

To do this calculation, the proposer will need to do the following steps:
	1. Determine the amount of assumed integration time (integration time not total telescope time which has overheads included) either by using the output from :ref:`1.1.1 <1.1.1 Cluster Core Detection>`, an estimation from previous observations, or a guess. 
	2. Use a Jupyter Notebook to simulate the observation and produce FITS files that will be input for the next step. If you have an estimated integration time and cluster mass and redshift, you can use this :download:`Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_SimObs_A10.ipynb>` to simulate your observations. If you have made your own input FITS file that contains the expected Compton-y map of your object, then use this :download:`User Input Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_SimObs_A10_user_defined_fits.ipynb>` to simulate your observations.
	3. Use the FITS file from step 3 as input into this :download:`Pressure Profile Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_FitPressureProfile.ipynb>`, to simulate the product (pressure profile and/or estimated mass).
	4. Iterate as needed. If the product does not meet the scientific goals of the proposer (for example say the error bars are too large), play around with the integration time in ``M2_SimObs_A10.ipynb`` until you achieve the desired resul. When you achieve a product that you are happy with, the total time contained in the ``times``  variable in the ``SimObs.ipynb`` will be your integration time request (don't forget to add a factor of two for overheads). 

Note, if the proposer is tyring to constrain the mass of a cluster, we suggest that the proposer try to think through what if the mass is the worst case scenario (e.g., mass - error bar). Can a paper still be written?

1.1.3 Detect a shock in a cluster
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For the case in which a user wants to detect a shock in a cluster, we expect that the proposer will create a simulated compton-y image of the cluster shock and convolve it with the M2 beam (10" gaussian). Then we expect the proposer to use use the simulated image and RMS image (you can make an RMS image using this `example <https://m2-tj.readthedocs.io/en/latest/Example_RMSmaps.html>`_ as a guide or `download the notebook directly <https://github.com/CharlesERomero/M2_TJ/blob/master/docs/source/Example_RMSmaps.ipynb>`_) to determine if given an integration time can the proposer detect the shock (can you detect the difference between the shock region and non-shocked region?).

1.1.4 Detect a cluster bridge
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In the case that the proposer wants to detect a cluster bridge, the proposer should know that this is on the cutting edge of the science possible with MUSTANG-2 and is difficult to do, but is possible. In this case, we expect that the proposer will create a simulated compton-y image of the cluster(s) and bridge and convolve it with the M2 beam (10" gaussian). Then use this :download:`User Input Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_SimObs_A10_user_defined_fits.ipynb>` to simulate your observations. Then iterate through and find an integration time that will produce the detection that the proposer desires. Additionally, the proposer could consider using the :download:`Pressure Profile Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_FitPressureProfile.ipynb>`, to simulate the pressure profile and investigate this further.

1.2 Calculate new time based on an estimate
-------------------------------------------
If you have a :math:`t`, :math:`\sigma`, or SNR goal based on previous observations you can use variations of the :ref:`radiometer equation <2. Using the Radiometer Equation>` listed below.

Besides using previous observations, one can use the tables in this :download:`Observing Galaxy Clusters with M2 memo </_static/mustang2_documents/Observing_Galaxy_Clusters_With_M2.pdf>` to estimate the expected compton Y or peak, or estimate the targeted peak or sensitivity given previous data (perhaps M2 data or ACT data). Then reference the table on the :ref:`mapping webpage <MUSTANG-2 Mapping Information>` to get the appropriate mapping speed and use radiometer equation below the following proportion to compute required integration time. 

2. Using the Radiometer Equation
================================
The radiometer equation provides a relationship between integration time (t) and sensitivity (:math:`\sigma`): t :math:`\propto` 1/:math:`\sigma ^2`. 

When put into a proportion with itself, a relationship between two times and two sensitivities/RMSs emerges: :math:`t_2/t_1 \propto (\sigma_1/\sigma_2)^2`.

There are then various cases in which you have various values that you can use to calculate the expected exposure time.

2.1 You have an expected peak value
-----------------------------------
Let's say that you have an expected peak value of your source within the M2 beam of 9". Examples of this could be a point source that is smaller than the beam, the peak of a galaxy cluster SZ, or the emission expected within one M2 beam (all of these can be in any of the units listed on the :ref:`mapping webpage <MUSTANG-2 Mapping Information>`). We note that your expected peak value **MUST** include some account of filtering which can be accounted for using `M2_ProposalTools`.
_
Once you have your expected peak value, you then must decide on a desired SNR. Then you can use the following logic using the proportion of the radiometer equation from above. 

:math:`t_2 = (\sigma_1^2 \cdot t_1) / \sigma_2^2` where :math:`t_2` is the required integration time that you are solving for and :math:`\sigma_2` is your desired sensitivity.

Rewrite this as :math:`t_2 = (\sigma_1 \cdot \sqrt{t_1})^2 / \sigma_2^2`

The MUSTANG-2 team has defined mapping speed as :math:`ms = \sigma \cdot \sqrt{t}`, thus ms can be substituted above and get :math:`t_2 = (ms_1^2 / \sigma_2^2)` or :math:`t_2 = (ms_1 / \sigma_2)^2`

Finally to calculate your :math:`t_2` is the required integration time that you are solving for, use the :ref:`mapping webpage <MUSTANG-2 Mapping Information>` to find the mapping speed that you plan to use :math:`(ms_1)` and plug in your desired sensitivity :math:`(\sigma_2)` where :math:`\sigma_2` = peak/SNR.

2.2 You have existing MUSTANG-2 data
------------------------------------
Let's say that you have a previous observation of the same source or a similar source. You will have :math:`t_1` which is the number of hours the source was observed and the RMS achieved in that observation, :math:`\sigma_1`.

2.2.1 Check mapping speed of existing data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you have existing MUSTANG-2 data, you will have been furnished with MIDAS maps of three kinds: data, noise realization, and an SNR map. Using the noise realization map (extension=0 of the fits file), you can smooth the image by a 9" FWHM Gaussian and calculate the RMS (:math:`\sigma_1`) within the central 2 arcminutes (radially). Here, it is sufficient to pick the center manually.

In the fits header, a card `INTGTIME` reports the time used in the map, in seconds. Equate :math:`t_1` to this `INTGTIME`, converted to hours. The effective mapping speed is then your calculated RMS * :math:`\sqrt{t_1}`.

Compare your effective mapping speed to the reported (average) `mapping speeds <https://gbtdocs.readthedocs.io/en/latest/references/receivers/mustang2/mustang2_mapping.html#mustang-2-mapping-information>`_ . If your mapping speed is faster (lower in value) than the reported average, you should not use this.

2.2.2 Use equations
^^^^^^^^^^^^^^^^^^^
Now that you have :math:`t_1` and :math:`\sigma_1`, you can then simply solve for :math:`t_2` using :math:`t_2 = (\sigma_1^2 \cdot t_1) / \sigma_2^2` where :math:`\sigma_2` is your desired sensitivity.

2.3 You require an SNR increase
-------------------------------
Let's say that you require an SNR increase where :math:`\sigma_2 = \sigma_1/N` , where N is the improvement that you want to achieve in your SNR/sensitivity. From some algebra with the radiometer equation we get :math:`t_2 = t_1 \cdot N^2`.



