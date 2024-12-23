.. _mustang2_calc_obs_time:

#######################################################
How to Calculate Observing Time Required for MUSTANG-2
#######################################################

Calculating sensitivities
-------------------------
MUSTANG-2 is NOT included in the GBT sensitivity calculator thus sensitivities are typically calculated using simulations or previous observations.

For galaxy clusters, one can run simulations or use the tables in this :download:`Observing Galaxy Clusters with M2 memo </_static/mustang2_documents/Observing_Galaxy_Clusters_With_M2.pdf>` to compute the expected compton Y or peak and corresponding required sensitivity. Then reference the table on the :ref:`mapping webpage <MUSTANG-2 Mapping Information>` and use the following relation to compute required integration time. 

As a general rule one can use the relationship between integration time (t) and sensitivity (:math:`\sigma`) where t :math:`\propto` 1/:math:`\sigma ^2` and the values in the table above to calculate the required integration time or desired sensitivity. For example, if one would like to calculate the required integration time corresponding to a desired sensitivity:
	* From the radiometer equation :math:`t \propto` 1/:math:`\sigma ^2`
	* set up in a proportional relationship :math:`t_2`/:math:`t_1` :math:`\propto` (:math:`\sigma_1`/:math:`\sigma_2`) :math:`^2` where :math:`t_2` is the required integration time that you are solving for, :math:`t_1` is 1 hour, :math:`\sigma_1` is the sensitivity corresponding to the map size from the table on the mapping :ref:`webpage <MUSTANG-2 Mapping Information>`, and :math:`\sigma_2` is the desired sensitivity that you have calculated
	* :math:`t_2` :math:`\propto` (:math:`\sigma_1`/:math:`\sigma_2`) :math:`^2` :math:`\times` :math:`t_1` and thus :math:`t_2` is your integration time
