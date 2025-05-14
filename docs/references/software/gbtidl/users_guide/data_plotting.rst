###########
The Plotter
###########

GUI Features
------------

When GBTIDL is first started it does not show the plotter screen, but the first time a command is
issued that uses the plotter, it will appear. The figure below identifies the parts of the plotter GUI.



You can manipulate the view using either command line procedures or the buttons on the plotter screen.
Control buttons are positioned along the top menu bar, and status indicators are along the bottom.


**Buttons for manipulating the plotter view and their equivalent commands:**

* **File**: The file menu is used to print the plot or to write the data to an ASCII file. The available options are:
    * **Print...**: Print the screen (this allows you to choose your printer and print options)
    * **Write PS**: Save the plot to a postscript file
    * **Write ASCII**: Write the data to an ASCII file
    * **Exit**: Exit the plotter
* **Options**: The Options menu includes the following capabilities:
    * **Crosshair**: Toggles the cursor between a crosshair style and a pointer style. 
      The crosshair is useful for reading x and y values off the plot.
    * **Zeroline**: Toggles a horizontal line at y=0 on the plot.
    * **Toggle Histogram**: Switches between histogram-style and connected-points style plots.
    * **Toggle Region Boxes**: Affects region boxes that were created using the setregion command.
    * **Clear Marks**: Clears all the markers you have made on the plotter.
    * **Clear Vertical Lines**: Clears lines you have added to the plotter.
    * **Clear Overlays**: Clears spectra overlaid on the original.
    * **Toggle Overlays**: Toggles the display of any overlays without affecting the scaling of the
      axes.
    * **Clear Annotations**: Clears all textual annotations on the plotter, including the results of
      Gaussian fits shown on the plot.
    * **Set Voffset=Vsource**: Sets the offset velocity equal to the source velocity obtained from
      the header.
    * **Set Voffset=0**: Sets the offset velocity to zero.
    * **Set Voffset**: Prompts the users for a new offset velocity.
* **LeftClick**: This menu lets you choose the behavior of the left mouse button. The options are:
    * **Null**: A left click does nothing.
    * **Position**: A left click will print the x and y coordinates of the cursor on the terminal screen.
    * **Marker**: A left click places a marker on the plot and displays the x and y coordinates of
      that marker.
    * **Vline**: A left click places a vertical line on the plot and displays the x and y coordinates of
      the click point.
* **X-axis units**: This button can be used to specify the desired x-axis units. The button’s label is the current x-axis units. The options are:
    * **Channels**, **Hz**, **kHz**, **MHz**, **GHz**, **m/s**, or **km/s**
* **Reference Frame**: This button provides options for changing the velocity frame of reference. The button’s label is the current velocity frame of reference. You can choose:
    * **TOPO**: Topocentric - the observed (sky) frame
    * **LSR**: Local standard of rest (kinematic)
    * **LSD**: Local standard of rest (dynamic)
    * **GEO**: Geocentric
    * **HEL**: Heliocentric
    * **BAR**: Barycentric
    * **GAL**: Galactocentric
* **Velocity Definition**: This button can be used to set the velocity definition. The button’s label is the current velocity definition. Options are:
    * **Radio**, **Optical**, or **True** (Relativistic)
* **Abs**: This button allows you to choose whether to display the x axis in absolute units or relative
  to the center of the band.
* **Unzoom**: This button unzooms the plotter one step at a time. That is, if you have zoomed the
  plot three times successively, clicking this button once will return you to the zoom parameters
  applied after the second zoom. Clicking it twice more will return you to the full unzoomed scale.
  This button is grayed out when fully unzoomed. For more information on zooming methods, see
  the section on zooming below.
* **Auto Update**: This setting controls whether or not the plotter automatically responds to commands.
  The feature is described in the next section.
* **Print**: The print button sends the plot, as displayed in the plotter, immediately to the default
  printer as set in the !g.printer variable. If you want to specify a printer, use the print option
  under the File button.

Auto Update (Freeze/Unfreeze)
-----------------------------

The Auto Update feature determines how the plotter responds to data processing commands. With
Auto Update on, a command that changes the PDC will trigger the plotter to update with the new
result. With Auto Update off, the plotter is only updated in response to a :idl:pro:`show` command.
In most cases, you will want the auto update turned on (unfreeze) so the :idl:pro:`show` command is
not required at each step. However, setting it off can be useful for faster processing of data in
scripts because plotting the spectra during intermediate steps can be time consuming. From the
command line, use :idl:pro:`freeze` or :idl:pro:`unfreeze` to turn the auto-update off or on,
respectively. For example:

.. code-block:: IDL

    unfreeze                        ; Turn on auto updates
    getrec,1                        ; Get some data - note the plot updates
    hanning                         ; The plot updates after the smooth operation
    freeze                          ; Turn off auto-updates
    for i=101,200 do begin & $      ; This loop will be faster
        getrec,i & $                ; since the plots are not updating
        accum & $
    end
    ave
    show                            ; Now the plot updates
    unfreeze                        ; back to the usual setting


Zooming
-------

Zooming in on a plot can be accomplished in several ways. One is to use the middle mouse button on
the plotter, clicking twice to specify the corners of the new zoom box. To unzoom, click the Unzoom
button at the top of the plotter, or simply type :idl:pro:`unzoom`. The Unzoom button takes you back to the
previous zoom settings, so several clicks may be necessary to return to the full scale. However, typing
:idl:pro:`unzoom` in the terminal window will bring you back to the original unzoomed spectra, no matter how
many times you zoomed. If you wish to cancel a zoom after the first middle mouse click, click the right
mouse button.

Zooming may also be accomplished with the :idl:pro:`setxy` procedure. When used with no parameters, this
procedure places a stretchable box on the plot and allows it to be positioned before executing the zoom.
Instructions for its use are printed to the screen when the procedure is invoked. Alternatively, you can
specify the desired zoom range from the command line using:

.. code-block:: IDL

    setxy, x1, x2, y1, y2.

A third zooming method is to specify minimum and maximum x- or y-axis values using the commands
:idl:pro:`setx` or :idl:pro:`sety`. You can then either specify the minimum and maximum x- or y-range
using parameters, or omit the parameters and use the cursor to set the range. The commands :idl:pro:`freex`
and :idl:pro:`freey` can be used to autoscale the x- or y-axis without unzooming the other axis. For
example, :idl:pro:`freey` will show the full y-range of the data without changing the current x-range.


Printing Spectra and Creating Postscript Plots
----------------------------------------------

Generating postscript plots can be difficult in IDL. In GBTIDL, we have simplified the process with the
:idl:pro:`write_ps` procedure. This procedure will generate a postscript file that reproduces the plot
as shown on the plotter. The postscript rendition will include overlays, show the zero line if it is
turned on, show any annotations created with the :idl:pro:`annotate` procedure, display any markers or
vlines placed on the plot, and the axis ranges are accurately reproduced. However, the :idl:pro:`write_ps`
procedure cannot know about any other IDL primitives that may have been used to draw on the GBTIDL 
plotter, so any IDL primitive plot commands will not be reproduced.

Generating ASCII Data
---------------------

The command :idl:pro:`write_ascii` can be used to write data to an ASCII file. The command 
takes a single parameter, the name of the ASCII file to be generated.

The :idl:pro:`table` command is useful for printing the x and y coordinates of a few specific
points to the terminal screen. For example

.. code-block:: IDL

    GBTIDL -> table, brange=1.66, erange=1.67

will list the data values for points between x = 1.66 GHz and x = 1.67 GHz for the PDC:

.. code-block:: text

    Scan:     79             W3OH 2005-06-28 +04 10 20.0
                             Ta
            GHz-LSR          YY
           1.6699992   -0.14701117
           1.6699962   -0.10967928
           1.6699931   -0.13311513
           1.669990    -0.10884448
               . .
               . .
               . .
           1.6600114   -0.013062999
           1.6600084    0.023651161
           1.6600053    0.011518455
           1.6600022   -0.013523553


Annotating the Display
----------------------

You can place text on the plot using the :idl:pro:`annotate` procedure. This command takes three parameters:
the x and y coordinates, and the text. You can also choose to include a color specifier and font size, as
well as specify normalized coordinates (/normal). Example:

.. code-block:: IDL

    annotate, 6, 9, ’This is an annotation’, color=!orange, charsize=2.0


Other Plotter Procedures
------------------------

The following table lists some of the command line procedures relevant to the plotter. Full descriptions
of these procedures are available in the GBTIDL User Reference or via the usage command.

.. list-table::
    :widths: 10 20
    :header-rows: 1

    * - Procedure
      - Action
    * - :idl:pro:`show`
      - Displays the spectrum
    * - :idl:pro:`oshow`
      - Display a spectrum as an overlay
    * - :idl:pro:`gbtoplot`
      - Used to plot arbitrary (x,y) values on the GBTIDL plotter.
    * - :idl:pro:`chan`, :idl:pro:`freq`, :idl:pro:`velo`, :idl:pro:`setxunit`
      - Sets the X-axis units
    * - :idl:pro:`setx`, :idl:pro:`sety`, :idl:pro:`setxy`
      - Sets the X- and/or Y-axis scale
    * - :idl:pro:`unzoom`
      - Retrieve previous zoom settings
    * - :idl:pro:`freex`, :idl:pro:`freey`
      - Auto scale one axis without affecting the range of the other.
    * - :idl:pro:`freexy`
      - Auto scale both axes
    * - :idl:pro:`histogram`
      - Toggle between histogram-style and connected-points
    * - :idl:pro:`annotate`
      - Place some text on the plot
    * - :idl:pro:`crosshair`
      - Toggle the crosshair cursor on/off
    * - :idl:pro:`write_ascii`
      - Write the data to an ASCII file
    * - :idl:pro:`write_ps`
      - Write the plot to a postscript file
    * - :idl:pro:`zline`
      - Toggle the zero-line on/off
    * - :idl:pro:`bdrop`, :idl:pro:`edrop`
      - Hide channels at beginning/end of the spectrum
    * - :idl:pro:`showregion`
      - Turn on or off the display of baseline region boxes
    * - :idl:pro:`click`
      - Prompt user to click on the plot, and return info on the click location
    * - :idl:pro:`clearannotations`, :idl:pro:`clearvlines`, :idl:pro:`clearoplots`, :idl:pro:`clearoshows`, :idl:pro:`clearovers`, :idl:pro:`clearmarks`, :idl:pro:`toggleovers`
      - Clear various types of overlays
    * - :idl:pro:`clear`
      - Clear everything from the plotter
    * - :idl:pro:`setabsrel`, :idl:pro:`setframe`, :idl:pro:`setveldef`, :idl:pro:`setvoffset`
      - Set the velocity definition and rest frame, and offsets
    * - :idl:pro:`setmarker`, :idl:pro:`vline`
      - Place markers and lines on the plot
    * - :idl:pro:`chantox`, :idl:pro:`xtochan`
      - Convert between X-axis units and channel number
    * - :idl:pro:`freeze`, :idl:pro:`unfreeze`
      - Turn Auto Update off or on
    * - :idl:pro:`reshow`
      - Re-draw everything known to the plotter

Colors
------

GBTIDL has built-in color definitions in global variables called ``!black``, ``!red``,
``!orange``, ``!green``, ``!forest``, ``!yellow``, ``!cyan``, ``!blue``, ``!magenta``,
``!purple``, ``!gray``, and ``!white``. Many of the plotter commands take a color
as an optional parameter. For example, the color of the spectral line can be changed 
like this:

.. code-block:: IDL
        
   show, color=!blue
