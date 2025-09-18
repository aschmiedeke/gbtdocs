###############
Data Containers
###############

Overview
--------

To make effective use of GBTIDL, you must have an understanding of data containers and how they are
used by GBTIDL procedures. The following sections give an introduction to data containers. Advanced
users may wish to refer to the section :ref:`references/software/gbtidl/users_guide/data_containers:Tips on Using Data Containers for Experts`.
A data container (DC) is an IDL data structure used by GBTIDL to store a spectrum and its
associated header. A data container uses standard data types (e.g. integers, floats and strings) for
header values and an IDL pointer for the data itself. There are 16 global data containers, or buffers,
numbered 0 through 15 that are used like memory entries in a calculator. Buffer 0 contains the primary
data container (PDC). The PDC will be discussed in more detail in a later section.
GBTIDL includes a number of calibration, averaging, and analysis procedures that work with the
PDC by default. You may see some of these routines refered to as part of the “GUIDE layer” elsewhere
in the documentation.

In addition to the global buffers, it is possible to define IDL variables as data containers. GBTIDL
includes commands and procedures that operate on these as well, and you may see some of these routines
refered to as part of the GBTIDL “toolbox.”
The IDL global structure ``!g`` is central to the GBTIDL implementation. It contains not only the global
data containers, but also a set of values which assist in data reduction. For example, the field ``!g.nfit``
stores the order of the polynomial for the baseline to be fit, so that value does not have to be specified
each time the baseline procedure is run. The :idl:pro:`gstatus` procedure summarizes the current contents of the
``!g`` structure. Many users will never need to interact directly with the ``!g`` structure. 

.. todo:: 

    Add reference to the ``!g`` table section
    
A second global structure called ``!gc`` is used to store various constants . This structure is read-only. It’s
contents are listed in the following table.

.. csv-table:: Content of the global structure `!gc`
   :file: gc.tab
   :widths: 20, 10, 20, 20, 30
   :header-rows: 1

For example, if you wish to use the Planck equation, :math:`\Delta E = h\nu`, for a frequency of 1665 MHz, the following
would calculate the energy:

.. code-block:: IDL

    GBTIDL -> print, !gc.plank_h * 1665d6

and print the result to screen

.. code-block:: text

    1.1032416e-17 ; The result

    
Data Containers and Pointers
----------------------------

A data container is an IDL data structure that uses standard data types for header information, but
uses a pointer for the data array. The reason for using a pointer is that it allows the data container to
hold a spectrum with an arbitrary number of channels. The continuum data container uses additional
pointers to hold auxilliary information stored in arrays that must match the dimensionality of the data
array (e.g. the time at the center of each integration and the pointing direction).
Pointers make the data container very flexible. Unfortunately, they also make it somewhat more difficult
to use the data directly. GBTIDL procedures hide all of the nuances of working with pointers, so nearly
all users will not need to be concerned with how to work with pointers in IDL. It is possible to copy
the data in a data container to a standard IDL array, and back again into the data container using the
GBTIDL function :idl:pro:`getdata` and the command :idl:pro:`setdata`. An example follows later in this 
section. Users who wish to learn more about advanced manipulation of data containers should see the 
:ref:`references/software/gbtidl/users_guide/data_containers:Tips on Using Data Containers for Experts` section.


About the Primary Data Container
--------------------------------

The PDC is the primary data container that is used by default by many GBTIDL procedures to improve ease
of use. So a display operation such as show will display the PDC unless told to do otherwise, and
likewise for smoothing operations, statistics, and so on. Data access procedures copy the data from disk
into the PDC, unless told otherwise. Like all data containers, the PDC includes both the data and the
associated header information. The PDC is stored in the IDL global variable ``!g.s[0]`` if it is a spectrum,
and ``!g.c[0]`` if it is continuum data. In addition to the PDC, there are 15 global data containers that
can be used for storage of results during data reduction sessions. These are called ``!g.s[1]``, ``!g.s[2]``,
... and ``!g.c[1]``, ``!g.c[2]``, ...


Examining and Changing Data Containers
--------------------------------------

You may on occassion need to change the contents of a data container. For example, you may need to
set the rest frequency by hand. The change can be made using the following command:

.. code-block:: IDL

    !g.s[0].line_rest_frequency=1667.359d6 ; Change to 1667.359 MHz

Another example involves setting the y-axis label on the plotter. For more information about changing
axis labels, see Appendix H.

.. todo::

   Replace this with the correct reference.

.. code-block:: IDL   

    !g.s[0].units=’F(Jy)’ ; Set the label to ’F(Jy)’

To access the array containing the actual data values in a data container, use the commands :idl:pro:`getdata`
and :idl:pro:`setdata`. For example:

.. code-block:: IDL

    GBTIDL -> getrec, 0 ; get some data
    GBTIDL -> mydata = getdata() ; copy the data array into an IDL variable
    GBTIDL -> help,mydata
      MYDATA FLOAT = Array[8192]
    GBTIDL -> mydata[0:500] = 0 ; make some changes to the IDL array
    GBTIDL -> setdata,mydata ; insert the new array into the PDC

Data Container Operations
-------------------------

GBTIDL can be used as a calculator, operating on spectra contained in the 16 global data containers.
Procedures are available to perform arithmetic operations on the global data containers, including add,
subtract, multiply, and divide. These procedures take two required parameters: the indices of the
buffers being operated on. They also take an optional third parameter, which identifies the buffer into
which the result will be stored. If a storage buffer is not specified, the result is placed in the PDC (buffer
0), overwriting any existing spectrum there. A copy command copies the contents of one buffer directly
into another. For example, to add two data containers, you could use the following command sequence:

.. code-block:: IDL

    getrec,1        ; Get some data
    copy,0,10       ; Copy the PDC to DC 10
    getrec,0        ; Get some other data
    copy,0,11       ; Copy the PDC to DC 11
    add,10,11,12    ; Put the sum of the two spectra in DC 12
    show,12         ; Show the sum

These operations can be useful for handling baseline subtraction. For example, you can store a
baseline fit in a data container and subtract that fit from any other spectrum, as in the following
example:

.. code-block:: IDL

    getrec, 0                   ; get spectrum A and place it into the PDC (buffer 0)
    nfit, 5                     ; set the order for the polynomial in a baseline fit
    bshape, modelbuffer = 10    ; fit a baseline and store it in buffer 10
    getrec, 1                   ; get spectrum B
    copy, 0, 5                  ; copy spectrum B into buffer 10
    subtract, 5, 10, 11         ; subtract the spectrum A baseline from spectrum B




Tips on Using Data Containers for Experts
-----------------------------------------

There are 16 global data containers, or buffers, numbered 0 through 15. Data container 0 is also called
the primary data container, or PDC for short. If you find you need more than 16 buffers, one option is
to use the nsave facility, which allows you to store an arbitrary number of data containers in a disk file.
Alternatively, you can store data containers as IDL variables. If you choose to store data containers in
IDL variables, there are a few procedures you should be aware of:

* **data_new**: Create a new data container.
* **data_copy**: Copy a data container.
* **data_free**: Free the pointers in a data container or array of data containers.
* **set_data_container**: Copy a data container stored as a variable into one of the 16 global buffers.

Check the reference pages or look at code examples for help on using these procedures. Make sure that
when you create a new data container (either by data new or data copy) you free the pointers using
data free when you are done, otherwise memory will be leaked.
Be sure to avoid this mistake when using data containers:

.. code-block:: IDL

    GBTIDL -> mydc = !g.s[0]
    ; ... you do stuff to mydc here
    ; ... you think you are done, so you free it
    GBTIDL -> data_free, mydc

The mistake here is that the initial assignment copies the value of the pointer, not the array that the
pointer refers to. So, any changes to the data array through mydc will also change the data array in
``!g.s[0]`` because they use the same pointer. More importantly, the data_free at the end will also free
the pointer in ``!g.s[0]``, likely bringing GBTIDL to its knees.
Instead, use data_copy:

.. code-block:: IDL

    GBTIDL -> data_copy, !g.s[0], mydc
    GBTIDL -> set_data_container, mydc              ; Resets index 0 with the contents of mydc
    GBTIDL -> data_copy, !g.s[1], mydc
    GBTIDL -> set_data_container, mydc, index=1     ; Resets index 1 with the contents of mydc
    GBTIDL -> data_free, mydc

This example illustrates the use of set data container to copy a user-named data container into the
global data container. It is not necessary to use data free before calling data copy because data copy
takes care of all pointer maintenance in the output data container without leaking memory.

Also, be aware that when global values are used as parameters to functions or procedures, IDL passes
those values by value and not by reference. So if you send a DC from !g to a procedure or function, all
changes you make to that DC will remain local to that function, and will not be retained in the global
variable.

If you need to work with an array of data containers here is one way you might do that:
Suppose you want to run getfs on scans 50 through 100 and defer saving the data to the output file
until the end. The step where the data are written to disk will be much faster if it can all be done at
once, but it does mean that all 51 spectra will be in memory by the end of this operation so you should
consider whether they will all fit in memory at the same time.

.. code-block:: IDL

    dcarr = replicate({spectrum_struct},51)     ; Create un-initialzed array of 51 data containers
    freeze                                      ; Turn off the plotter’s auto-update feature
    for i=50, 100 do begin                      ; Loop over the scan numbers
        getfs, i
        tmp = dcarr[i-50]                       ; Copy that to dcarr (this is the tricky step)
        data_copy, !g.s[0], tmp
        dcarr[i-50] = tmp
    endfor
    putchunk, dcarr                             ; Save it
    data_free, dcarr                            ; Free up the memory

The ``tmp`` variable is used in the for loop because of the aforementioned issue of IDL passing elements
to functions and procedures by value and not by reference. So we assign to ``tmp`` the specific element of
``dcarr`` that we want to modify. That gets a copy of everything, including the pointer. Inside data_copy,
``tmp`` is modified and since ``tmp`` in this case is passed by reference (because it is not a global value and it
isn’t an array element), changes to tmp will be seen outside of data_copy. Once data_copy returns,
the values in ``tmp`` (including the now valid pointer containing the copy of the data array) will be copied
to ``dcarr``. It is not necessary or desirable to use data_free on ``tmp`` because that would also free the copy
of that pointer in ``dcarr``. That pointer is freed at the end. Be sure and free up all of the pointers that
you create this way so that memory is not leaked.
