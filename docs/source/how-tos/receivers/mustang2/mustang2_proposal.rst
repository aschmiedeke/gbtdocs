.. _mustang2_proposal:

##############################
How to Propose with MUSTANG-2
##############################

General properties (such as FOV, resolution, bandpass information) can be found on :ref:`the MUSTANG-2 overview page<MUSTANG-2 Overview>`.

If you have general questions about feasibility or initial questions feel free to reach to the members listed under the Contact section on :ref:`MUSTANG-2 instrument team <MUSTANG-2 Instrument Team>` webpage. However, we ask that you please do this in a reasonable amount of time before a proposal deadline as the team will be busy with many proposals right before the deadline. 


Proposal Requirements
=====================

Team Approval
-------------
All MUSTANG-2 proposals are shared-risk and must be approved by the :ref:`MUSTANG-2 instrument team <MUSTANG-2 Instrument Team>`. Furthermore, the entire MUSTANG-2 instrument team **must** be included as **co-investigators on the proposal**. 

In order to get your proposal approved by the MUSTANG-2 team, contact one or all of the instrument team member listed under :ref:`the Contact section <MUSTANG-2 Contact Details>` of the MUSTANG-2 Instrument Team webpage and send a draft of your proposal **at least one week in advance** of the proposal deadline. The MUSTANG-2 team will principally focus on the technical feasibility of a proposal and make suggestions accordingly. 

Technical Justification
-----------------------
The technical justification on a proposal should reference publicly available mapping speeds (e.g. from the MUSTANG-2 mapping :ref:`webpage <MUSTANG-2 Mapping Information>` and/or the :download:`MUSTANG-2 mapping speeds memo </_static/mustang2_documents/MUSTANG_2_Mapping_Speeds_Public.pdf>`). The GBT sensitivity calculator does not currently incorporate MUSTANG-2 mapping speeds.

If you are targeting a specific S/N for your proposal and you have an extended object, you must account for/explore the effect of filtering and include this in your technical justification. You can run simulations using `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_, run your own simulations, or consult the instrument team.

Overhead observing constraints
-------------------------------
The overhead for MUSTANG-2 is dominated by initial setup and calibration. We generally recommend a minimum session length of 2 hours. Allowing for weather and calibration and observing overheads, observers should conservatively allow an observing efficiency of 50% (or 100% overheads relative to on-target time). Thus in the end to account for setup and calibration time to get thier final time request the user should multiply thier on-target time by a factor of 2. 

Source visibility considerations
--------------------------------
Daytime observing at 90 GHz is currently not advised. The changing solar illumination gives rise to thermal distortions in the telescope structure which make calibrating 90 GHz data extremely difficult. Useful 3mm observations are currently only possible between 3h after sunset and a half hour past sunrise. Further cooler temperatures are required for observing at 90 GHz thus the high-frequency observing season for MUSTANG-2 is typically ~October - May. Thus your target must be visibile to the GBT 3h after sunset and a half hour past sunrise in ~October - May. 

Other things of note
====================
Proposal Tools
--------------
`M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ is a Python library for simulating MUSTANG-2 observations. A specific application of this library is that a proposer can simulate the effect of filtering on the S/N acquired.

Data and Observing
------------------
Though the entire MUSTANG-2 instrument team will be involved in the proposal process, conversely, the MUSTANG-2 team will reduce the data and provide appropriate data products (principally a calibrated map, transfer function, and beam characterization) to the proposal team (see :ref:`the list of possible data products<MUSTANG-2 Deliverables>`. End-to-end data reduction is currently fairly involved. We will work to provide documentation on data processing and hope to eventually allow proposers to process their own data. 

MUSTANG-2 instrument team also asks that the PI and team get trained to observe with MUSTANG-2 and observe for their project whenever possible.

Calculating sensitivities
-------------------------
MUSTANG-2 is NOT included in the GBT sensitivity calculator thus sensitivities are typically calculated using simulations or previous observations.

For galaxy clusters, one can run simulations or use the tables in this :download:`Observing Galaxy Clusters with M2 memo </_static/mustang2_documents/Observing_Galaxy_Clusters_With_M2.pdf>` to compute the expected compton Y or peak and corresponding required sensitivity. Then reference the table on the :ref:`mapping webpage <MUSTANG-2 Mapping Information>` and use the following relation to compute required integration time. 

As a general rule one can use the relationship between integration time (t) and sensitivity (:math:`\sigma`) where t :math:`\propto` 1/:math:`\sigma ^2` and the values in the table above to calculate the required integration time or desired sensitivity. For example, if one would like to calculate the required integration time corresponding to a desired sensitivity:
	* From the radiometer equation :math:`t \propto` 1/:math:`\sigma ^2`
	* set up in a proportional relationship :math:`t_2`/:math:`t_1` :math:`\propto` (:math:`\sigma_1`/:math:`\sigma_2`) :math:`^2` where :math:`t_2` is the required integration time that you are solving for, :math:`t_1` is 1 hour, :math:`\sigma_1` is the sensitivity corresponding to the map size from the table on the mapping :ref:`webpage <MUSTANG-2 Mapping Information>`, and :math:`\sigma_2` is the desired sensitivity that you have calculated
	* :math:`t_2` :math:`\propto` (:math:`\sigma_1`/:math:`\sigma_2`) :math:`^2` :math:`\times` :math:`t_1` and thus :math:`t_2` is your integration time
