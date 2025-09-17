
.. astrid::

Astronomer's Integrated Desktop (AstrID)
----------------------------------------

What is Astrid?
^^^^^^^^^^^^^^^

Astrid is the primary graphical interface and control workspace for the
Green Bank Telescope (GBT). It consolidates multiple applications into
a single environment for the creation, editing, execution, and monitoring
of scheduling blocks (SBs).


* **Core Functions**
    * Execute Scheduling Blocks (SBs) to control astronomical observations.
    * Monitor real-time GBT status.
    * Display live data streams from the GBT.
    * Edit SBs offline or online, with validation and save functions.
    * Allow secondary observers to monitor active sessions.


* **System Integration**
    * Interfaces directly with GBT Monitor & Control (M&C) software.
    * Interprets Python code in SBs to coordinate device-specific M&C programs
      and the Scan Coordinator.
    * Applications appear in tabbed windows within the Astrid GUI.


* **Applications**
    * Observation Management
        * Integrates with the Observing Management Application.
        * *Edit* Subtab: text editor with Python syntax highlighting, enables SB
          editing, validation, duplication, and saving.
        * *Run* Subtab: supports SB queuing and execution.
    * Data Display
        * Connects to the GBT Fits Monitor (GFM) for real-time processing of 
          pointing and focus scans.
        * Automatically updates M&C system with derived corrections.
        * Displays raw, uncalibrated continuum data as a funciton of time.
    * GBT Status
        * Provides real-time operational data, including:
            * Local Sidereal Time (LST) and UTC
            * Observer and project ID
            * Antenna position
            * Scan and IF configuration


How to start AstrID?
^^^^^^^^^^^^^^^^^^^^

Type ``astrid`` from the command line on any Linux computer in Green Bank. The first thing you will see is
the AstrID "splash screen". 

.. image:: images/AstridSplash.jpg


The AstrID GUI should appear on screen after 10-20s.

.. image:: images/AstridGUI.png


Astrid Modes 
''''''''''''

On startup AstrID will automatically ask what mode to operate in via a pop-up window. 
You can reopen the selection window any time by clicking ``File`` :math:`\rightarrow`
``Real time mode...`` in the AstrID GUI.

.. important:: 

    You should use ``File`` :math:`\rightarrow` ``Real time mode...`` to relinquish 
    control  of the telescope immediately after your scheduled observing session.

.. image:: images/AstridMode.jpg


You should select the most appropriate mode for your purpose:

* **Work offline**: Primarily used to create, edit and validate SBs. It is alo the 
  preferred method to look at previously obtained data in the Data Display since online
  modes will continually refresh the display window with near-real time data.

* **Work online, but only monitor observations**: May be used to view what is happening
  in the AstrID observing logs and Data Display for the current observations. You will
  not be able to submit SBs or affect observing in any manner.

* **Work online with control of the telescope**: Use to perform observations with the
  GBT by allowing you to submit SBs. Log information and real-time data displays are
  also available in this mode.

  .. note:: 
    
    Working online requires the GBT operator to "put you in the gateway", i.e. give you security access.

.. _tab-astrid-mode-features:
.. list-table:: AstrID mode features
    :widths: 25, 15, 15, 15, 15, 15
    :header-rows: 1


    * - Mode
      - Edit & Validate Syntax 
      - Validate Configuration
      - Submit SBs
      - Observing Logs
      - Data Display
    * - **Offline**
      - :octicon:`check`
      - Simulated
      - :octicon:`x`
      - :octicon:`x`
      - Historical [#]_
    * - **Online** (monitor)
      - :octicon:`check`
      - Simulated
      - :octicon:`x`
      - :octicon:`check`
      - Real-time
    * - **Online** (control)
      - :octicon:`check`
      - Real [#]_
      - :octicon:`check` [#]_ 
      - :octicon:`check`
      - Real-time

.. rubric:: Table Footnotes

.. [#] Previously acquired data should always be viewed in ``offline`` mode.
.. [#] Requested configurations are validated with respect to the actual 
   ``dev_health.conf`` rather than the simulated "ideal" universal cabling file.
.. [#] Only permitted when you are "in the gateway", i.e. the GBT operator has 
   given you security access

AstrID GUI Composition
^^^^^^^^^^^^^^^^^^^^^^

The AstrID GUI layout consists of several components:

.. image:: images/AstridGUIcomposition.png


Resizing AstrID Display Areas
'''''''''''''''''''''''''''''

It is possible to resize some of the display areas within AstrID. If you hover the mouse
over the bar separating two display areas you will get a double-arrowed resize cursor. 
If you then hold down the left mouse button you can use the mouse to move the border and
resize the display areas.

Application
'''''''''''
This comprises the majority of the space within the AStrID GUI and shows the contents of
the Application selected by the application selection tabs.


Application Selection Tabs
''''''''''''''''''''''''''

The application selection tabs are located under the Drop-down menus and the Toolbar The
top level of tabs allow users to switch between the three main Astrid applications: 
* Observation Management, 
* Data Display
* GBT Status. 
 
Each application has its own set of subtabs.


Drop-Down Menus
'''''''''''''''

In the top, left hand side of the AstrID GUI you will find the drop-down menus. The 
contents of the drop-down menus change according to which Application is currently 
being displayed on the AstrID GUI. We will not discuss all of the options under the
drop-down menus in this document but we will provide some highlights.

* ``File``
    * ``New Window`` - Launch applications within the AstrID GUI or in an independent GUI.
    * ``Close Window`` - Close the currently displayed application in the AstrID GUI.
    * ``Real time mode...`` - Change between the :ref:`operational modes of AStrID <Astrid Modes>`.

* ``Edit`` - Standard "Windows" undo, redo, cut and paste options.

* ``View`` - Display or hide the Toolbar or view AstrID in Full Screen mode.

* ``Tools`` - Only active for the Data Display Application. You may use checkboxes to 
  select various tooltips such as *info*, *pan*, and *zoom*. You can also change the 
  "Heuristics"used during the reduction of pointing and focus observations by selecting
  ``Options...``.

* ``Help`` - Bring up documentation for some, but not all applications.

  .. note:: 
    
    The links in the documentation are outdated.
 

Toolbar
''''''''
The Toolbar is located just under the Drop-down Menus near the top of the AstrID GUI. The 
contents of the Toolbar change depending on which application is being displayed in the
AstrID GUI.  The Toolbar options are a subset of commonly used options from the Drop-down
Menus.  When you leave the mouse situated over one of the Toolbar buttons for a few seconds
a pop-up will appear that tells you what action the Toolbar button will invoke.


Logs
''''
The Log Window is located in the lower portion of the AstrID GUI underneath the Application
display area.  Clicking on the log tabs at the very bottom of the GUI will display log
information for the Observation Managament, Data Display, or GBT Status applications. 
Viewing a specific log will also change the application window to display the matching
application.

The contents of the Observation Management application Log may be saved to an external file 
via the ``Export Log`` button.  Note that closing or restarting AstrID will clear the
Observation Management Log.  If you wish to retrieve an unsaved observating log, please 
contact your GBT project friend.


Command Console
'''''''''''''''
The Command Console is a Python shell that imports the Configuration Tool and Balance APIs.
Both APIs will only interact with the Monitor & Control (M&C) systems if the user has been 
granted security access and is operating AstrID from the ``Work online with control of the telescope``
mode (see :ref:`Astrid Modes`).


State
'''''

There are three indications of state located in the upper right corner of the AstrID GUI.

* **Observation State** indicates AStrID's state.
    * ``Not Connected``: AstrID is not communicating with the M&C system (such as in its
      offline mode).
    * ``Idle``: AStrID is communicating with the M&C system and no SB is currently being
      executed 
    * ``SB Executing`` AStrID is communicating with the M&C system and an SB is running 
    * ``SB Paused``: AstrID is communicating with the M&C sstem and an SB has been paused 

* **GBT State** indicates the M&C system state.
    * ``Not In Service``: the M&C system is not working properly
    * ``Not Connected``: the M&C system is not working properly
    * ``Unknown``: the M&C system is working but does not know the state of any of the
      hardware devices
    * ``Ready``: the GBT is not doing anything
    * ``Activating`` or ``Committed``: the GBT is preparing to perform an observation
    * ``Running``: the GBT is taking data during a scan 
    * ``Stopping``: the scan is ending
    * ``Aborting``: the scan is ended for any abnormal reason

* **GBT Status** indicates the error state of the M&C system.
    * ``Unknown`` or ``Not Connected``: the \gls{MC} system is not communicating properly
      with the hardware
    * ``Clear``, ``Info`` or ``Notice``: there are no significant problems with the GBT
    * ``Warning``: it is worth asking the Operator what the problem is, but it may not
      affect observation quality.
    * ``Error``: there is potentially something wrong that may need attention
    * ``Fault`` or ``Fatal`` then something has definitely gone wrong with the observations


Queue Control Button
''''''''''''''''''''
The Queue Control Button is located between the Observation State Section and the
Observation Control Section on the right of the AstrID GUI. These buttons gives
you control of the SB queue.

* ``Halt Queue``: If this button is not activated then the SB in the Run queue will continue
  to be executed in order. If this button is activated it will finish the currently running
  SB but will not allow the next SB in the Run Queue to execute until the button is returned
  to its default off state.


Observation Control Button
''''''''''''''''''''''''''
The Observation Control Buttons are located in the lower-right of the AstrID GUI. These buttons
give you control of the GBT during the execution of an SB and have the following functions:

* ``Pause``: Pause the SB after the completion of the current sub-scan (if in progress).
* ``Stop``: Stop the current sub-scan (if in progress) and unterrupts current SB, offering 
  you a chance to exit the SB. This is a nice, gentle way to stop a scan.
* ``Abort``: Abort current sub-scan (if in progress) and interrupt current SB, offering you a 
  chance to exit the SB.  This may lead to corrupted data.
* ``Interactive``: When selected, will cause AstrID to automatically answer any pop--up query.
  AstrID will always choose what it deems to be the safest answer.  This is useful when you have
  to leave the  control for an extended period of time (such as when you go to the cafeteria to
  eat, etc.). 


Observation Management Tab
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Observation Management Application consists of two sub-GUIS: the Edit Subtab and the Run Subtab.
In the Edit Subtab you can create, load, save, and edit SBs.  You can also validate that the syntax
is correct. The Run Subtab is where you will execute GBT observations.

The Edit Subtab
'''''''''''''''

The Edit Subtab has five major areas: a list of Project Names, SBs that have been saved into the
AstrID database for that project, an editor, a validation area, and a log summarizing the observations.

.. image:: images/AstridEditSubtab.jpg

.. todo:: Add reference to contents and creation of SBs here.



Project Name and List of SBs
""""""""""""""""""""""""""""

To access scheduling blocks associated with your project, you will need to enter your
Project Name in the ``Project`` window located in the upper left part if the Edit Subtab.
Your Project Name is the code that your GBT proposal was given with the prefix ``AGBT``,
e.g., ``AGBT16A_001``. To enter a Project Name you may either type it in directly, or use
the drop-down arrows to navigate to your project through a project hierarchy as shown here:

.. image:: images/Astrid_projectHierarchy.jpg

After doing this you will see in the window labeled ``Scheduling Blocks`` a list of SBs, 
if any, that have been previously saved into the AstrID database. If an SB has been validated
(i.e. it is syntactically correct) then it will appear in bold-face type. This means that it
can be executed. If a script has been saved but is syntactically incorrect it will appear in
lighter-faced type and cannot be executed.


Editor
""""""

You can use the Editor to create or modify an SB within AstrID. Standard Windows functions
like Ctrl-X (to cut selected text), Ctrl-C (to copy selected text), and Crtl-V (to paste 
selected text) can be used within the editor. The editor lists the line number on the left
hand side of the window and marks Python code as follows:

* **Green highlighted text** - Commented characters
* **Black highlighted text** - Standard Python commands/syntax
* **Purple highlighted text** - Strings
* **Magenta highlighted text** - Triple quoted strings (used in Python to enclose 
  strings that span multiple lines)
* **Dark blue highlighted text** - Python functions
* :math:`\boldsymbol{\ominus}`, :math:`\boldsymbol{\oplus}` - Marks the start of an 
  indented block of Python code such as an ``if`` statement or ``for`` loop.  Clicking
  on :math:`\ominus` will collapse the indented code block and change the symbol to 
  :math:`\oplus`.  Likewise, clicking on :math:`\oplus` will expand a previously
  collapsed code block.


The editor also has four operational buttons:

* ``Save to Database`` - This button will check the validation of the current SB and then
  save it to the AstrID database.  A pop-up window will notify you if the SB did not pass
  validation.  A second pop-up window will allow you to set the name that the SB will be
  saved under in the AstrID database.

* ``Delete from Database`` - This button will delete the currently selected SB from the
  AstrID database.
   
* ``Import from File`` - This button will allow you to load an SB from a file on disk.
    
* ``Export to File`` - This button will allow you to save the edited SB displayed in the
  editor to a file on a disk. This does not save the SB into the AstrID database.


The first time you select either of the ``Import from File`` or ``Export to File`` buttons
you will have a pop-up window that lets you select the default directory to use. After 
selecting the default directory you will get a second pop-up window that shows the contents
of the default directory so that you can select or set the disk file name to load from or
export to.




Adding and Editing SBs in the Database
""""""""""""""""""""""""""""""""""""""

* **Saving a Scheduling Block to the Database**
    If you have already created an SB outside of AstrID, you should go to the Edit Subtab in
    AstrID and then use the ``Import from File`` button to load your SB into the Editor. 
    Alternatively you can just create your SB in the Editor. To save the SB into the AstrID
    database you just need to hit the ``Save to Database`` button. This will trigger a 
    validation check on your SB and then a pop-up window will appear which allows you to 
    specify the name which you would like to use in the list for your SB.

* **Selecting a Scheduling Block** 
    If you perform a single click on any SB in the Scheduling Block list, the contents of
    the selected SB will appear in the Editor. The selected SB will be highlighted with a 
    blue background.

* **Mouse-button Actions on the selected Scheduling Block**
    If you perform a right mouse button click on the selected SB a pop-up window will appear
    that will let you rename, create a copy or save the SB to the AstrID database. You can
    also delete the SB from the AstrID database. You may also rename the SB if you perform
    a left mouse button double click on the script name in the list.




Validator
"""""""""

The validation area is where you can check that the currently selected SB is syntactically
correct.  This does not check for run-time errors and thus, does not guarantee that the script
will do exactly what you want it to do. For example, it cannot check that you have the correct 
coordinates for your source. You will also see error messages, notices and warnings from the
validation in this area.

The validator will attempt to verify that you are using a legal configuration. When run in 
AstrID's offline mode, the validator can only compare your requested configuration with a 
simulated "ideal" model of the telescope hardware. To perform a full configuration check 
against the true hardware state of the telescope (modelled by the ``dev_health.conf`` file),
you must be running AstrID from the ``Work online with control of the telescope`` mode.

Before an SB can be run within AstrID it first must pass validation. To validate a script without
saving it you can just hit the ``Validate`` button. An SB automatically undergoes a validation 
check when you hit the ``Save to Database`` button in the editor.  Any messages, etc. from the
validation will appear in the "Validation Output" test area. You can export these messages to a 
file on disk by hitting the ``Export`` button in the validation area.

The state of an SB's validation is shown by the stop-light left of the ``Validate`` button.
If the script has never been validated or has been changed since the last validation the 
stop-light will have the yellow light on. If the SB fails validation the stop-light will 
turn red, while it will turn green if the SB passes validation.

.. note::

    ``for``-loops with many repeats can take an extended amount of time to validate since 
    the Validator will go through each step in the loop. Also be careful of infinite loops 
    in the validation process.  Use of time functions such as :func:`Now() <astrid_commands.Now>`
    always return ``None`` in the validation.


The Observing Log
""""""""""""""""
The observing log is always visible at the bottom of the Observation Management Tab. It shows 
information from the execution of SBs in either of the AstrID online modes. The observing log
can be saved to a disk file by hitting the ``Export`` button that is just above the top right
corner of the log display area.  Note that closing AstrID will clear the observing log. If you 
wish to retrieve unsaved observing log information, please contact your GBT project friend.


The Run Subtab
''''''''''''''

In the Run Subtab you can queue up SBs to perform the various observations that you desire to
make. The Run Subtab has five components. Across the top of the Run Subtab you enter information
that will be put into the headers associated with the observations. On the left is a list of SBs
that you can execute. On the right are the "Run Queue" which holds SBs that are to be executed 
in the future, and the "Session History" which shows which SBs have previously been executed.  
At the bottom is the "Observing Log".

.. image:: images/AstridRunSubtab.jpg


Header Information Area
"""""""""""""""""""""""

The following fields must have entries before an SB can be executed:

* **Project**: 
    Just as in the Edit Subtab you use the drop-down menu to select your Project Name.
    If your project is not listed, ask your GBT project friend or the telescope Operator to add it
    to the database.

* **Session**: 
    A session is a contiguous amount of time (a block of time) for which the project
    is scheduled to be on the telescope. Each time a project begins observing for a new block of
    time it should have a new session number. The session number is usually determined by AstrID
    and automatically entered. However, there are cases (such as AstrID crashing) where the session
    number could become incorrect. You can type in the correct session number if needed.
 
    .. note:: 

        A "session" in AstrID is equivalent to an "observing period" in the lingo of the DSS.
        The word "Session" has a different meaning in the DSS.

* **Observer's Name**:
    This is a drop-down list where you choose the observer's name.  Only the PI on a project are 
    guaranteed to have their name in this list. If your name is not listed, ask your GBT project
    friend or the telescope operator to add it.
    
* **Operator's Name**: 
    This is a drop-down list from which you pick the current operator's name at the beginning of 
    your observations.


Submitting an SB to the Run Queue
"""""""""""""""""""""""""""""""""

In order to execute an SB you must:

#. Be in the ``Work online with control of the telescope`` mode.
#. Be in the gateway (contact the operator).
#. Select the Observation Management Tab. 
#. Select the Run Subtab.  
#. Make sure that the header information fields all have entries.  
#. Select the SB you wish to execute from the list of available SBs.  
#. Hit the ``Submit`` button below the list of SBs.


Your SB is then automatically then sent to the Run Queue.  

.. note::

    Double-clicking on an SB is the same as selecting the SB and then hitting 
    the ``Submit`` button. 


The Run Queue and Session History
"""""""""""""""""""""""""""""""""

When an SB is submitted for execution it is first sent to the Run Queue. This
contains a list of submitted SBs that will be sequentially executed in the future.

When an SB begins execution it is moved to the Session History list.  So the Session
History list contains the currently executing SB on the first line and all previously 
executed SBs that have been run while the current instance of AstrID has been running
on subsequent lines.

If there are not any SB in the Run Queue when a new SB is submitted for execution it
may appear that the SB just shows up in the Session History. However it has indeed 
gone through the Run Queue - albeit very quickly.

The Observing Log
"""""""""""""""""

The observing log is always visible at the bottom of the Observation Management Tab. 
It shows information from the execution of SBs.  The observing log can be saved to a
disk file by hitting the ``Export`` button that is just above the top right corner of
the log display area.  Note that closing AstrID will clear the observing log. If you 
wish to retrieve unsaved observing log information, please contact your GBT project
friend.


Data Display Tab
^^^^^^^^^^^^^^^^

The Data Display Tab provides a near-real time display of your GBT data and is discussed
in Chapter 4.

.. todo:: 

    The description from GBT Observer Guide chapter 4 should move here. 


GbtStatus Tab
^^^^^^^^^^^^^

The GbtStatus Tab displays various GBT specific parameters, sampled values and computed
values. Special care was taken to promote its use for remote observing. An Example of
how the GBT Status Display appears in AstrID is shown in Figure~\ref{fig:astridstatusone} and~\ref{fig:astridstatustwo}.

.. _astrid_gbtstatus1:
.. figure:: images/Astrid_GBTstatus1.jpg

    The top portion of the AstrID GbtStatus Tab. To see the rest of the status screen you
    will need to use the scroll bar.

.. _astrid_gbtstatus2:
.. figure:: images/Astrid_GBTstatus2.jpg

    The bottom portion of the AstrID GbtStatus Tab. To see the rest of the status screen 
    you will need to use the scroll bar.



General Status
''''''''''''''

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - Observer
      - The observer name
    * - Project ID
      - The data directory of the FITS files. This is your Project Name with the session as a suffix.  
        For example, the Project ID for session 02 of AGBT16A_001 would be ``AGBT16A_001_02``
        
        .. todo:: Add reference to GBT-OG 3.4.1.1.
        
    * - Status
      - The status of the GBT.  
        
        .. todo:: Add reference to GBT-OG 3.3.8

    * - LST
      - The Local Sideral Time of the last update
    * - Last Update
      - The local time when the database was last updated
    * - UTC Date
      - The Coordinated Universal Time date of the last update 
    * - UTC Time
      - The Coordinated Universal Time time of the last update
    * - MJD
      - The Modified Julian Date of the last update


Telescope Status
''''''''''''''''

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - Az commanded
      - The commanded azimuth position of the telescope in degrees.
    * - Az actual
      -  The actual azimuth position of the telescope in degrees.
    * - Az error
      - The difference between the commanded and the actual azimuth 
        position of the telescope in arc-seconds. This value does not
        contain a :math:`\cos\left({\text{el}}\right)` correction
    * - El commanded
      - The commanded elevation position of the telescope in degrees.
    * - El actual
      - The actual elevation position of the telescope in degrees.
    * - El error
      - The difference between the commanded and the actual elevation
        position of the telescope in arc-seconds.
    * - Coordinate Mode
      - The coordinate mode used to represent a particular location 
        on the sky.
        
        .. todo:: Add reference to GBT-OG Section location_objects

    * - Major and Minor Coord
      - The telescope position in the current Coordinate Mode.
    * - Major and Minor Cmd Coord
      - The telescope position in the current commanded Coordinate Mode.
    * - Antenna State
      - * ``Disconnected`` - antenna software is not running
        * ``Dormant`` - antenna software is running but with its control of
          the antenna turned off 
        * ``Stopped``- antenna is not moving
        * ``Guiding``- antenna is moving and data are being taken
        * ``Tracking``- data are not being taken
        * ``Slewing`` - antenna is moving to a new commanded position
    * - LPCs Az/XEl/El
      - The Local Pointing Correction (LPC) offsets in arc-seconds.
    * - DC Az/XEl/El
      - The DC values in arc-seconds. The GBT has temperature sensors 
        attached at various points on the backup structure and the 
        feed-arm.  These are used in a dynamic model for how the GBT
        flexes with changing temperatures. This model is used to correct
        for pointing and focus changes that occur from this flexing.
    * - LFCs (XYZ mm)
      - The Local Focus Correction (LFC) for the offset focus position
        in millimeters.  This value is determined from a Focus observation
        
        .. todo:: Add reference to GBT-OG chap:scripts

    * - LFCs (XYZ deg)
      - The subreflector tilt offset in degrees.
    * - DC Focus Y (mm)
      - The DC Y subreflector offset in millimeters.
    * - AS FEM Model
      - The  state of the Finite-Element Model (FEM) correction for the 
        Active Surface (AS). The FEM predicts how the surface changes due
        to gravitional flexure versus the elevation angle.
    * - AS Zernike Model
      - The  state of the AS Zernike model correction model. The Zernike
        model is a set of Zernike polynomial coefficients determined from
        Out-Of-Focus (OOF) holography that improve the shape of the AS
        versus the elevation angle.
    * - AS Zernike Thrm Model
      - The  state of the FEM correction for the AS. The FEM predicts how
        the surface changes due to thermal flexure.
    * - AS Offsets
      - The  state of the AS zero offsets. The zero offsets are the default 
        positions for the AS.  This should always be ``On`` if the AS is 
        being used.
    * - Quad. det. rms
      - The quadrant detector is used to detect and correct for wind-induced
        pointing errors.  rms values in arc-seconds are reported in elevation
        and cross-elevation.  Total rms is also given as a fraction of the beam.

Scan and Source Status
''''''''''''''''''''''

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - Scan
      - A scan is a command within an SB used to collect observational data.
        The field here is derived from the scan number and ``PROCNAME``, 
        ``PROCSIZE and ``PROCSEQN`` keywords from the GO FITS file. 
    * - Duration
      - The scan length in seconds.
    * - Scan Start Time
      - If scan has started it is the UTC scan start time - if the scan has 
        not started, then it is the countdown until the start of scan. 
    * - On Source
      - ``Yes`` or displays a countdown until the antenna is on source.
    * - Remaining
      - The time remaining in the scan.
    * - Source
      - The source name.
    * - Vel  Def
      - The velocity definition specifies which mathematical equation is used
        to convert between frequency and velocity. 
        
        .. todo:: Add reference to Explanation section (TBW) 

    * - Vel Frame
      - The velocity frame or inertial reference frame.  
        
        .. todo:: Add reference to GBT-OG \dq{vframe} keyword in sec:keywords. 

    * - Source Vel
      - The source velocity (km :math:`{\text{s}}^{-1}`).
    * - Time To Set
      - The time till the current source sets. 

Configuration Status
''''''''''''''''''''

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - Receiver
      - The receiver being used.
    * - Polarity
      - The receiver polarity.
    * - Cal State
      - ``ON`` if the noise diode is firing during the scan 
    * - Sw Period
      - The period in seconds over which the full switching cycle occurs. 
        This is determined by the user in their configuration 
        
        .. todo:: Add reference to GBT-OG sec:config
        
    * - Obs Freq
      - The observed spectral line frequency in the local frame (MHz).
    * - Rest Freq
      - The spectral line frequency in the rest frame (MHz).
    * - Center Freq
      - The center IF frequency set by the LO in MHz. 
        
        .. todo:: Add reference to GBT-OG appendix:spectralwindows for further details

    * - Frequency State
      - The switching type.  Either "total power" or "frequency-switching".

Weather Status
''''''''''''''

A real--time readout from one of the \gls{GBT} weather stations providing information
on temperature, pressure, humidity, dew point, wind direction and velocity. In addition,
the pyrgeometer measures the net near-IR irradiance of the sky to give an approximate 
indication of cloud cover.

.. note:: The pyrgeometer is currently not active.


Time Delay Status
'''''''''''''''''

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - RT phase delay
      - This is the time delay between the timing center in the GBT 
        equipment room and the GBT receiver room, in picoseconds,
        modulo 2000 ps.  It is measured by comparing the phase of the
        500 MHz reference signal sent to the receiver room with a copy 
        of the signal returned to the  timing center.
    * - Site1Hz-GPS dt
      - Time difference between the Site1Hz (a one pulse per second 
        signal that is locked to the hydrogen maser time standard) and 
        a pulse from the GPS receiver.
    * - GPS-GBT_VLBA dt
      - Time difference between the GPS receiver and the VLBA backend 
        timing module.
    * - Site1Hz-GBTRtn dt
      - Time delay between the Site 1Hz and a copy of the 1 Hz returned
        from GBT receiver room.  It is twice the delay of the fiber cables.
        The value is about 28933 ns which means the time delay between the
        equipment room the the receiver room is about 14466 ns.


VEGAS Status
''''''''''''

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - VEGAS
      - The VEGAS Bank (spectrometer with letter designation A 
        :math:`\rightarrow` H) selected in the scan coordinator.
    * - Power Levels
      - The power levels at the inputs to the VEGAS ADC cards. There
        are two ADCs per bank, one for each polarization. The VEGAS
        balance API sets these values to approximately -20dBm by default.
    * - Mode Name
      - Each VEGAS Bank can be configured in one of 29 Spectral Modes or
        1 of 24 Pulsar Modes.

        .. todo:: Add reference to VEGAS spectral mode table and VPM table.

    * - FilterBW
      - The bandwidth (MHz) of the digital filter implemented in the 
        FPGA.
      
        .. note:: 
            
            These values do not correspond to the bandwidths listed in 
            Table XXX.
            
            .. todo:: Add reference to VEGAS spectral mode table.

    * - Noise
      - The state of the noise source which can be either ``On`` or ``Off``.
    * - Polarization
      - Users may specify which spectral product to record (See the ``vegas.vpol``
        keyword in XYZ). 
        
        * ``vegas.vpol="self"`` records "Total Intensity" products
        * ``vegas.vpol="cross"`` records "Full Stokes" parameters
        * ``vegas.vpol="self1"`` records the polarization inputs from the first ADC only
        * ``vegas.vpol="self2"`` records the polarization inputs from the second ADC only.        

        .. todo:: Add reference to vegas.vpol keyword       

    * - Subbands
      - Each VEGAS bank can select between single (subbands=1) and multiple
        (subbands=8) spectral windows when using VEGAS modes with a 23.44 MHz bandwidth.  
    * - IntTime
      - The VEGAS integration (dump) time in seconds.
    * - Switching
      - Determines whether switching is controlled by VEGAS ("Internal")
        or another source ("External").

IF Status
'''''''''

The IF path in use is always displayed in the last section of the GBT status screen.
An example screen is shown in Figure :ref:`astrid_gbtstatus2`; the content displayed
depends on the exact configuration. In this example, each line represents the IF path
for a single polarization path from the IF rack to the backend.  Each line contains
only the devices in use for the listed path. A path may include a subset of the
devices and values listed below.

.. list-table:: 
    :header-rows: 0
    :widths: 20 80

    * - IF#
      - The # displayed is the number corresponding to the IF rack switch in use.
        The value displayed is the RF power in Volts detected by the IF rack. 
    * - CM#
      - The # displayed is the number corresponding to the Converter Module in use. 
        The value displayed is the RF power in Volts coming out of the Converter
        Module after the LO2 and LO3 mixers and before the Converter Module filters. 
    * - CF#
      - The # displayed is the number corresponding to the Analog Filter in use. 
        The value displayed is the RF power in Volts coming out of the AF rack
        after all filters have been applied (used with 100 MHz converters).
    * - SG#
      - The # displayed is the number corresponding to the Analog Filter in use.
        The value displayed is the RF power in Volts coming out of the AF rack
        after all filters have been applied (used with 1.6 GHz samplers).
    * - VEGAS-J#
      - The # displayed is the number corresponding to the port of VEGAS0 in use.
        The value displayed is the power level in dBFS. For best performance, it 
        should be approximately -20 dBFS.
    * - Radar-Port#
      - The # displayed is the number corresponding to the port of the Radar in 
        use.
    * - DCR:A_#
      - The # displayed is the bank and number corresponding to the port of the 
        DCR in use. The value displayed is the total power in raw counts. 
    * - TSys#
      - The # displayed is the number corresponding DCR port in use. The value
        displayed is the system temperature as reported by the DCR (should be
        considered a loose approximation).
    * - backendIF
      - The value displayed is the frequency of the Doppler track rest frequency
        as seen by the backend, in GHz.

