###########################
Writing Your Own Procedures
###########################

GBTIDL is designed to allow you to write your own procedures easily. The best approach to writing
your own procedures is to start by looking at the code of a similar existing procedure. All the
code in GBTIDL is available for your perusal in the Green Bank and Charlottesville installations at
``/home/gbtidl/release/gbtidl``. All of the NRAO-developed or modified code can be found in the ``pro``
subdirectory, user-contributed code can be found in ``contrib``, and IDL code from other sources can be
found in the ``lib`` subdirectory.

To write custom procedures, you should become familiar with IDL programming, and with the data
container structure. Here is a simple example of a procedure to use as a template. This example scales
the data in the spectrum by a factor given by the user.

.. code-block:: IDL

    pro myscale,factor
        tmp_data = getdata()
        tmp_data = tmp_data * factor
        setdata, tmp_data
        if !g.frozen eq 0 then show
    end

Suppose the code is stored in a file is called ``myscale.pro``. To access the function, do this within GBTIDL:

.. code-block:: IDL

    .compile myscale.pro    ; Compile the program
    show                    ; Show the data
    myscale, 2              ; Scale the data by a factor of 2

That’s it!

You can put procedures in the directory from which you are running GBTIDL, or in a special
subdirectory off of your home directory called ``gbtidlpro``. In case there are procedures with 
identical names in your IDL path, the directories will be searched in the following order: 

1. the current directory
2. ``$HOME/gbtidlpro``
3. GBTIDL installation directories
4. IDL installation itself.
  
If the file is not in one of these directories, you will need to specify the path when compiling it:

.. code-block:: IDL

    .compile /users/aeinstein/mypros/myscale.pro
