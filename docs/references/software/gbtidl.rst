.. _gbtidl:

######
GBTIDL
######


GBTIDL is an interactive package for reduction and analysis of spectral line data taken with the GBT.
GBTIDL is entirely written in IDL. There is limited support in GBTIDL for GBT continuum data, but it is mainly intended for spectral line data from the spectrometer or spectral processor. 


-----------------


User's Guide
------------

.. grid:: 1 2 2 2

   
    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Introduction** 

        Main Features of GBTIDL, Where to run GBTIDL, Obtaining GBTIDL

        .. button-link:: gbtidl/gbtidl_intro.html
            :color: primary
            :tooltip: GBTIDL Introduction
            :outline:
            :click-parent:

            Introduction

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Getting Started** 

        How to begin a GBTIDL session

        .. button-link:: gbtidl/gbtidl_getting_started.html
            :color: primary
            :tooltip: GBTIDL getting started
            :outline:
            :click-parent:

            Getting Started


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Accessing Data Files** 

        How to access observing data.

        .. button-link:: gbtidl/gbtidl_access_data_files.html
            :color: primary
            :tooltip: GBTIDL accessing data files
            :outline:
            :click-parent:

            Accessing Data Files


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Data Containers** 

        Description of data containers and how they are used by GBTIDL procedures

        .. button-link:: gbtidl/gbtidl_data_containers.html
            :color: primary
            :tooltip: GBTIDL data containers
            :outline:
            :click-parent:

            Data Containers


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Data Calibration** 

        Calibrate SDFITS files.

        .. button-link:: gbtidl/gbtidl_data_calibration.html
            :color: primary
            :tooltip: GBTIDL data calibration
            :outline:
            :click-parent:

            Data Calibration


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Data Plotting** 

        Plotting data with GBTIDL

        .. button-link:: gbtidl/gbtidl_data_plotting.html
            :color: primary
            :tooltip: GBTIDL data plotting
            :outline:
            :click-parent:

            Data PLotting


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Data Analysis** 

        Analyzing data with GBTIDL

        .. button-link:: gbtidl/gbtidl_data_analysis.html
            :color: primary
            :tooltip: GBTIDL data analysis
            :outline:
            :click-parent:

            Data Analysis


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Saving Data** 

        Analyzing data with GBTIDL

        .. button-link:: gbtidl/gbtidl_data_saving.html
            :color: primary
            :tooltip: GBTIDL data saving
            :outline:
            :click-parent:

            Data Saving




.. toctree::
    :maxdepth: 3
    :hidden:

    gbtidl/gbtidl_intro
    gbtidl/gbtidl_getting_started
    gbtidl/gbtidl_access_data_files
    gbtidl/gbtidl_data_containers
    gbtidl/gbtidl_data_retrieval
    gbtidl/gbtidl_data_plotting
    gbtidl/gbtidl_data_analysis
    gbtidl/gbtidl_data_saving



Tables
------

.. grid:: 1 2 2 2

   
    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **!g structure** 

        Content of the global structure ``!g`` used by many GBTIDL routines

        .. button-link:: gbtidl/gbtidl_g_structure.html
            :color: primary
            :tooltip: GBTIDL !g structure
            :outline:
            :click-parent:

            ``!g`` structure


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Spectrum data container Content** 

        Functions and procedures from the plotter folder

        .. button-link:: gbtidl/gbtidl_spectrum_dc_content.html
            :color: primary
            :tooltip: GBTIDL spectrum dc content
            :outline:
            :click-parent:

            Spectrum dc content 

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Continuum data container Content** 

        Functions and procedures from the toolbox folder

        .. button-link:: gbtidl/gbtidl_continuum_dc_content.html
            :color: primary
            :tooltip: GBTIDL continuum dc content
            :outline:
            :click-parent:

            Continuum dc content



.. toctree::
    :maxdepth: 3
    :hidden:

    gbtidl/gbtidl_g_structure
    gbtidl/gbtidl_spectrum_dc_content
    gbtidl/gbtidl_continuum_dc_content

    
Procedures and Functions
------------------------

The package consists of a set of straightforward yet flexible calibration, averaging, and analysis
procedures (the "GUIDE" layer) modeled after the UniPOPS and CLASS data reduction philosophies,
a customized plotter with many built-in visualization features, and Data I/O and toolbox functionality 
that can be used for more advanced tasks. GBTIDL makes use of data structures which can also be used
to store intermediate results. 


.. grid:: 1 2 2 2

   
    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Guide** 

        Functions and procedures from the guide folder

        .. button-link:: gbtidl/gbtidl_guide.html
            :color: primary
            :tooltip: Guide
            :outline:
            :click-parent:

            Guide


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Plotter** 

        Functions and procedures from the plotter folder

        .. button-link:: gbtidl/gbtidl_plotter.html
            :color: primary
            :tooltip: Plotter
            :outline:
            :click-parent:

            Plotter


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Toolbox** 

        Functions and procedures from the toolbox folder

        .. button-link:: gbtidl/gbtidl_toolbox.html
            :color: primary
            :tooltip: Toolbox
            :outline:
            :click-parent:

            Toolbox



.. toctree::
    :maxdepth: 3
    :hidden:

    gbtidl/gbtidl_guide
    gbtidl/gbtidl_plotter
    gbtidl/gbtidl_toolbox
