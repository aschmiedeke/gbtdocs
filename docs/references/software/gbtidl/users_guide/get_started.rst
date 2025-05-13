###############
Getting Started
###############

This section describes how to begin a GBTIDL session and what to do if you need help understanding
a command.

Starting GBTIDL
---------------

To start GBTIDL simply type the following command at the unix prompt from any NRAO computer
running Linux in Green Bank or Charlottesville.

.. code-block:: bash
   
    gbtidl


Getting Help with Commands
--------------------------

In addition to the GBTIDL User Reference, you can get help within GBTIDL via the ``usage`` command.
For example, to get a list of the optional arguments of the ``show`` command:

.. code-block:: IDL

    usage, ’show’   
    
.. code-block:: text

    GBTIDL -> usage, ‘show’

    Usage: show[, dc ] [, color=color ] [, /defaultx ] [, /smallheader ] [, /noheader ]

To get a complete description of what the command does, what keywords can be used, examples, and the path for the source code use

.. code-block:: IDL

    usage, 'show', /verbose

To see the source code behind the command use

.. code-block:: IDL

    usage, 'show', /source 
    
