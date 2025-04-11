GBTIDL commands
---------------


GBTIDL is an interactive package for reduction and analysis of spectral line data taken with the GBT.
The package consists of a set of straightforward yet flexible calibration, averaging, and analysis
procedures (the "GUIDE" layer) modeled after the UniPOPS and CLASS data reduction philosophies,
a customized plotter with many built-in visualization features, and Data I/O and toolbox functionality 
that can be used for more advanced tasks. GBTIDL makes use of data structures which can also be used
to store intermediate results. 



.. 
   (Temporary?) grid structure since multiple calls to autopath doesn't work

.. grid:: 1 2 2 2

   
    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Guide** 

        Functions and procedures from the guide folder

        .. button-link:: gbtidl_guide.html
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

        .. button-link:: gbtidl_plotter.html
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

        .. button-link:: gbtidl_toolbox.html
            :color: primary
            :tooltip: Toolbox
            :outline:
            :click-parent:

            Toolbox


.. toctree::
    :maxdepth: 3
    :hidden:

    gbtidl_guide
    gbtidl_plotter
    gbtidl_toolbox
