.. _mustang2_proposal:

##############################
How to Propose with MUSTANG-2
##############################

General properties (such as FOV, resolution, bandpass information) can be found on :ref:`the MUSTANG-2 overview page <references/receivers/mustang2/mustang2_overview:MUSTANG-2 Overview>`.

If you have general questions about feasibility or initial questions feel free to reach to the members listed under the Contact section on :ref:`MUSTANG-2 instrument team <references/receivers/mustang2/mustang2_instrument_team:MUSTANG-2 Instrument Team>` webpage. However, we ask that you please do this in a reasonable amount of time before a proposal deadline as the team will be busy with many proposals right before the deadline. 


Proposal Requirements
=====================

Team Approval
-------------
All MUSTANG-2 proposals are shared-risk and must be approved by the :ref:`MUSTANG-2 instrument team <references/receivers/mustang2/mustang2_instrument_team:MUSTANG-2 Instrument Team>`. Furthermore, the entire MUSTANG-2 instrument team **must** be included as **co-investigators on the proposal**. 

In order to get your proposal approved by the MUSTANG-2 team, contact one or all of the instrument team member listed under :ref:`the Contact section <references/receivers/mustang2/mustang2_instrument_team:MUSTANG-2 Contact Details>` of the MUSTANG-2 Instrument Team webpage and send a draft of your proposal **at least one week in advance** of the proposal deadline. The MUSTANG-2 team will principally focus on validating the technical feasibility of a proposal and make suggestions accordingly. Because the main objective of the MUSTANG-2 team reviewing your proposal is to evaluate technical justification, when you send the draft of your proposal needs to include technical justification. To do this you can either: a) send us a PDF of both your draft science justification and a PDF of your technical justification, or b) fill in your technical justification in the NRAO Proposal Submission Tool and your draft science justification, and have the NRAO Proposal Submission Tool output a PDF of your proposal. If you are unsure about the feasibility of your idea and/or would like help with the technical aspects of your MUSTANG-2 proposal, please contact the MUSTANG-2 instrument team. This initial contact must be done more than a week in advance of the proposal deadline. 

Technical Justification
-----------------------
The technical justification on a proposal should reference publicly available mapping speeds (e.g. from the MUSTANG-2 mapping :ref:`webpage <references/receivers/mustang2/mustang2_mapping:MUSTANG-2 Mapping Information>` and/or the :download:`MUSTANG-2 mapping speeds memo </_static/mustang2_documents/MUSTANG_2_Mapping_Speeds_Public.pdf>`). The GBT sensitivity calculator does not currently incorporate MUSTANG-2 mapping speeds.

.. admonition:: Guides for Calculating MUSTANG-2 Integration Times

    For instructions on calculating the time you will need to request using MUSTANG-2 to reach your science goals, see the resources provided in this :ref:`Guide <how-tos/receivers/mustang2/mustang2_calc_obs_time:How to Calculate Observing Time Required for MUSTANG-2>`.

.. note:: 

	If you are targeting a specific S/N for your proposal and you have an extended object, you must account for/explore the effect of filtering and include the results of your exploration in your technical justification. You can run simulations using `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_, run your own simulations, or consult the instrument team.

Requirements for MUSTANG-2 technical justification:
	1. You must explain in detail how you arrived at the total observing time. If you used equations, please include those and the progression of how you used any equations in how you arrived at your final time request. 
	2. You must consider the effect of filtering (this is used in MUSTANG-2 data reduction pipelines Minkasi or MIDAS) on your data. Please include discussion of these effects in your technical justification. If you run simulations using `M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ then filtering is taken into account and you can simply say this.
	3. You must account for overheads - see :ref:`Overhead observing constraints <how-tos/receivers/mustang2/mustang2_proposal:Overhead observing constraints>` below.
	4. You must have a MUSTANG-2 instrument team member read through the technical justification and sign off on it **before you submit your proposal** as this is the only technical review a MUSTANG-2 proposal will get. 

Overhead observing constraints
-------------------------------
The overhead for MUSTANG-2 is dominated by initial setup and calibration. We generally recommend a minimum session length of 2 hours. Allowing for weather and calibration and observing overheads, observers should conservatively allow an observing efficiency of 50% (or 100% overheads relative to on-target time). Thus in the end to account for setup and calibration time to get thier final time request the user should multiply thier on-target time by a factor of 2. 

Source visibility considerations
--------------------------------
Daytime observing at 90 GHz is currently not advised. The changing solar illumination gives rise to thermal distortions in the telescope structure which make calibrating 90 GHz data extremely difficult. Useful 3mm observations are currently only possible between 3h after sunset and a half hour past sunrise. Further cooler temperatures are required for observing at 90 GHz thus the high-frequency observing season for MUSTANG-2 is typically ~October - May. Thus your target must be visibile to the GBT 3h after sunset and a half hour past sunrise in ~October - May. 

`M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ has the capability to create `visibility curves <https://m2-tj.readthedocs.io/en/latest/Visibility_From_GB.html>`_ for targets of interest. 

We note that when observing with MUSTANG-2 on the GBT, the preferred maximum elevation limit of a target if 75 degrees. It is possible to observe targets up to 80 degrees elevation but this is not preferable. The hard limit is around 84 degrees. At these higher elevations, the MUSTNAG-2 beam becomes large because the GBT cannot keep up with the slewing speeds required to map and track the source. Conversely, the preferred minimum elevation is 30 degrees. However, it is possible to but can go lower, but lower than 30 is hard on the hardware.

Other things of note
====================
Proposal Tools
--------------
`M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ is a Python library for simulating MUSTANG-2 observations. A specific application of this library is that a proposer can simulate the effect of filtering on the S/N acquired.

Observing Responsibilities
--------------------------
The PI of a MUSTANG-2 proposal (if accepted) is responsible for the following things:
	- creating the astrid observing scripts (i.e., “SBs”) at the beginning of the semester
	- enabling their projects at the beginning of the semester only once their SBs have been written and an M2 team member has verified that the SBs are valid and ready to go
	- observing when their project is scheduled and if they cannot observe, they are then responsible for finding someone to cover observing
	- filling out their black out dates in the DSS
	
The PI can request MUSTANG-2 instrument team observing support when scheduled but this is not guaranteed. Thus it is suggested that the PI become a GBT and MUSTANG-2 remote certified observer, and that the PI request others on the proposal co-author list become a GBT remote certified observer. The MUSTANG-2 team will however guarantee that a MUSTANG-2 member will get the instrument ready for observations. 

Data
----
Though the entire MUSTANG-2 instrument team will be involved in the proposal process, conversely, the MUSTANG-2 team will reduce the data and provide appropriate data products (principally a calibrated map, transfer function, and beam characterization) to the proposal team (see :ref:`the list of possible data products<how-tos/receivers/mustang2/data/mustang2_deliverables:MUSTANG-2 Deliverables>`). End-to-end data reduction is currently fairly involved. We will work to provide documentation on data processing and hope to eventually allow proposers to process their own data. 
