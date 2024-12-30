.. _mustang2_calc_obs_time:

#######################################################
How to Calculate Observing Time Required for MUSTANG-2
#######################################################

MUSTANG-2 is NOT included in the GBT sensitivity calculator thus sensitivities are typically calculated using simulations or previous observations. 

Thus you will need to do one of the following to calculate the exposure time required for your observation: 
	a) run simulations using `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_, 
	b) run your own simulations, 
	c) you have previous data and/or target sensitivity that you can use in conjunction with the radiometer equation, or 
	d) some combination of the above or another option. 

Always feel free to contact the MUSTANG-2 instrument team with questions.

Note that the radiometer equation provides a relationship between integration time (t) and sensitivity (:math:`\sigma`): t :math:`\propto` 1/:math:`\sigma ^2`. 

When put into a proportion with itself, this relationship between time and sensitivity becomes: :math:`t_2/t_1 \propto (\sigma_1/\sigma_2)^2`

Below we list common scientific cases for MUSTANG-2 and how we recommend you calculate the required exposure time for that scientific use case.

1. Galaxy Clusters
==================

1.1 Running Simulations
-----------------------

1.1.1 Cluster Core Detection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In the case in which the proposer wants to detect the cluster of a given mass and redshift, they will have to install `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ and then they can use this :download:`Cluster Detection Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_t_cluster_detection.ipynb>` which will a simulation that includes the effects of filtering. This notebook will run a simulation for a single cluster or a list of clusters and output the total time required to reach a given signal-to-noise ratio (including a factor of 2 for overheads).

1.1.2 Constraining pressure profiles out to X radius.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For the case that a proposer would like to constrain a pressure profile of a cluster out to X radius (and very closely related, constraining the mass, especially if X is R_500), the general process will be to simulate the observations of a cluster given a certain integration time, mass, and redshift, then fit the pressure profile of the simulated data and determine if the product (pressure profile and/or mass) meets the scientific goals of the proposer.

To do this calculation, the proposer will need to do the following steps:
	1. Install `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_
	2. Determine the amount of assumed integration time (integration time not total telescope time which has overheads included) either by using the output from :ref:`1.1.1 <1.1.1 Cluster Core Detection>`, an estimation from previous observations, or a guess. 
	3. Use a Jupyter Notebook to simulate the observation and produce FITS files that will be input for the next step. If you have an estimated integration time and cluster mass and redshift, you can use this :download:`Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_SimObs_A10.ipynb>` to simulate your observations. If you have made your own input FITS file that contains the expected Compton-y map of your object, then use this :download:`User Input Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_SimObs_A10_user_defined_fits.ipynb>` to simulate your observations.
	4. Use the FITS file from step 3 as input into this :download:`Pressure Profile Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_FitPressureProfile.ipynb>`, to simulate the product (pressure profile and/or estimated mass).
	5. Iterate as needed. If the product does not meet the scientific goals of the proposer (for example say the error bars are too large), play around with the integration time in ``M2_SimObs_A10.ipynb`` until you achieve the desired resul. When you achieve a product that you are happy with, the total time contained in the ``times``  variable in the ``SimObs.ipynb`` will be your integration time request (don't forget to add a factor of two for overheads). 

Note, if the proposer is tyring to constrain the mass of a cluster, we suggest that the proposer try to think through what if the mass is the worst case scenario (e.g., mass - error bar). Can a paper still be written?

1.1.3 Detect a shock in a cluster
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
For the case in which a user wants to detect a shock in a cluster, we expect that the proposer will create a simulated compton-y image of the cluster shock and convolve it with the M2 beam (10" gaussian). Then we expect the proposer to use use the simulated image and RMS image (you can make an RMS image using this `example <https://m2-tj.readthedocs.io/en/latest/Example_RMSmaps.html>`_ as a guide or `download the notebook directly <https://github.com/CharlesERomero/M2_TJ/blob/master/docs/source/Example_RMSmaps.ipynb>`_) to determine if given an integration time can the proposer detect the shock (can you detect the difference between the shock region and non-shocked region?).

1.1.4 Detect a cluster bridge
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In the case that the proposer wants to detect a cluster bridge, the proposer should know that this is on the cutting edge of the science possible with MUSTANG-2 and is difficult to do, but is possible. In this case, we expect that the proposer will create a simulated compton-y image of the cluster(s) and bridge and convolve it with the M2 beam (10" gaussian). Then use this :download:`User Input Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_SimObs_A10_user_defined_fits.ipynb>` to simulate your observations. Then iterate through and find an integration time that will produce the detection that the proposer desires. Additionally, the proposer could consider using the :download:`Pressure Profile Simulation Notebook </_static/mustang2_documents/ipynb/sensitivity_calculations/M2_FitPressureProfile.ipynb>`, to simulate the pressure profile and investigate this further.

1.2 Using the Radiometer Equation
----------------------------------
One can either the tables in this :download:`Observing Galaxy Clusters with M2 memo </_static/mustang2_documents/Observing_Galaxy_Clusters_With_M2.pdf>` to estimate the expected compton Y or peak, or estimate the targeted peak or sensitivity given previous data (perhaps M2 data or ACT data). Then reference the table on the :ref:`mapping webpage <MUSTANG-2 Mapping Information>` to get the appropriate mapping speed and use radiometer equation the following proportion to compute required integration time. 



For example, if one would like to calculate the required integration time corresponding to a desired sensitivity:
	* From the radiometer equation :math:`t \propto` 1/:math:`\sigma ^2`
	* set up in a proportional relationship :math:`t_2`/:math:`t_1` :math:`\propto` (:math:`\sigma_1`/:math:`\sigma_2`) :math:`^2` where :math:`t_2` is the required integration time that you are solving for, :math:`t_1` is 1 hour, :math:`\sigma_1` is the sensitivity corresponding to the map size from the table on the mapping :ref:`webpage <MUSTANG-2 Mapping Information>`, and :math:`\sigma_2` is the desired sensitivity that you have calculated
	* :math:`t_2` :math:`\propto` (:math:`\sigma_1`/:math:`\sigma_2`) :math:`^2` :math:`\times` :math:`t_1` and thus :math:`t_2` is your integration time
