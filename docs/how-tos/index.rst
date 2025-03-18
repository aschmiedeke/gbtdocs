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
    :hidden:
    :maxdepth: 3

    infrastructure/remote-connection


General Guides
==============

These guides provide information on how to perform general and common tasks with the GBT.


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`telescope;3em;green` **Observing Instructions** 

        Most basic steps to observe with the GBT

        .. button-link:: general_guides/gbt_observing.html
            :color: primary
            :tooltip: Most basic steps to observe with the GBT.
            :outline:
            :click-parent:

            GBT observing


.. toctree::
    :hidden:
    :maxdepth: 3

    general_guides/gbt_observing

Observing Mode Guides
======================

These guides contain end-to-end instructions, i.e. how to set up specific observations and how to calibrate and post-process the obtained data.


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Polarization** 

        How to derive a Mueller matrix?

        .. button-link:: observing_modes/C-band_Mueller_matrix.html
            :color: primary
            :tooltip: Practical steps to obtain a Mueller matric using spider scans.
            :outline:
            :click-parent:

            Mueller matrix


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Pulsars** 

        How to observe Pulsars?

        .. button-link:: observing_modes/pulsars.html
            :color: primary
            :tooltip: Practical steps to execute Pulsar observations.
            :outline:
            :click-parent:

            Pulsar observations

..  .. button-link:: quick_guides/HI_single-pointing.html
..        :color: primary
..        :tooltip: Practical steps to obtain a single-pointing HI spectrum using either position-switching or frequency-switching.
..
..        How to observe an HI spectrum and process it?


.. toctree::
    :hidden:
    :maxdepth: 3

    observing_modes/C-band_Mueller_matrix
    observing_modes/pulsars

----------------



Receiver specific Guides
========================

These guides provide receiver specific information on how to achieve a specific goal.


.. grid:: 1 2 3 3

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Argus** 

        How-to observe with Argus (75-115 GHz)

        .. button-link:: receivers/argus/argus_obs.html
            :color: primary
            :tooltip: How-to use Argus (75-115 GHz receiver).
            :outline:
            :click-parent:

            Argus

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0

        **MUSTANG-2**

        Guides for MUSTANG-2 (bolometer camera)

        .. button-link:: receivers/mustang2.html
            :color: primary
            :tooltip: How-to use MUSTANG-2 (bolometer camera).
            :outline:
            :click-parent:

            MUSTANG-2


.. toctree::
    :hidden:
    :maxdepth: 3

    receivers/argus/argus_obs
    receivers/mustang2


----------------


Data Reduction
==============

.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`device-desktop;3em;green` **GBTIDL** 

        How-to process spectra using GBTIDL (examples)

        .. button-link:: data_reduction/gbtidl.html
            :color: primary
            :tooltip: Shows practical steps to calibrate and process gbt data using gbtidl
            :outline:
            :click-parent:

            GBTIDL

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`sun;3em;green` **Calcuate the Opacity** 

        How-to calculate the opacity for your observations.

        .. button-link:: data_reduction/gbtidl.html
            :color: primary
            :tooltip: Shows practical steps on how to calculate the opacity for your observations.
            :outline:
            :click-parent:

            Calculate opacity
.. toctree::
    :hidden:
    :maxdepth: 3

    data_reduction/gbtidl
    data_reduction/calculate_opacity

