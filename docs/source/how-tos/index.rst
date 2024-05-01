.. _howtos:

###########################################
:octicon:`terminal;2em;green` How-To Guides
###########################################

Practical step-by-step guides to help you achieve a specific goal. Most useful when you're trying to get something done.


----------------


Infrastructure
==============

These guides provide information on how to use GBO infrastructure.


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`globe;3em;green` **Remote Connection** 

        How to connect remotely to the GBO network?

        .. button-link:: infrastructure/remote-connection.html
            :color: primary
            :tooltip: Practical steps on how to connect remotely to the GBO network.
            :outline:
            :click-parent:

            Remote connections



.. toctree::
    :maxdepth: 3
    :hidden:

    infrastructure/remote-connection


Quick Guides
============

These guides contain end-to-end instructions, i.e. how to set up specific observations and how to calibrate and post-process the obtained data.

.. button-link:: quick_guides/HI_single-pointing.html
    :color: primary
    :tooltip: Practical steps to obtain a single-pointing HI spectrum using either position-switching or frequency-switching.

    How to observe an HI spectrum and process it?

.. button-link:: quick_guides/C-band_Mueller_matrix.html
    :color: primary
    :tooltip: Practical steps to obtain a Mueller matrix using spider scans.

    How to derive a Mueller matrix?

.. toctree::
    :maxdepth: 3
    :hidden:

    quick_guides/HI_single-pointing
    quick_guides/C-band_Mueller_matrix

----------------



Receiver specific Guides
========================

These guides provide receiver specific information on how to achieve a specific goal.


Argus
-----


.. card-carousel:: 2

    .. card:: Argus Observations
        :link: argus_obs
        :link-type: ref

        How to observe using Argus?

    .. card:: Sensitivity Calculation

        How to calculate sensitivies for Argus



.. toctree::
    :maxdepth: 3
    :hidden:

    receivers/argus/argus_obs



MUSTANG-2
---------

.. card-carousel:: 3

    .. card:: Proposal Information
        :link: mustang2_proposal
        :link-type: ref

        Instructions and information for proposers.

    .. card:: Setup - Tuning and Biasing
        :link: mustang2_setup
        :link-type: ref

        How to setup MUSTANG-2 for observations.

    .. card:: Observing
        :link: mustang2_obs
        :link-type: ref

        How to observe with MUSTANG-2.

    .. card:: Data
        :link: mustang2_data
        :link-type: ref

        Information on data products and data processing.


.. toctree::
    :maxdepth: 4
    :hidden:

    receivers/mustang2/mustang2_proposal
    receivers/mustang2/mustang2_setup
    receivers/mustang2/mustang2_obs
    receivers/mustang2/mustang2_data

----------------


Data Processing
================



.. button-link:: data_reduction/gbtidl.html
    :color: primary
    :tooltip: Shows practical steps to calibrate and process GBT data using GBTIDL.

    How to process spectra using GBTIDL (examples)


.. toctree::
    :maxdepth: 3
    :hidden:

    data_reduction/gbtidl


