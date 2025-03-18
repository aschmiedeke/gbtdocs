####################
GBT observations 101
####################


We assume you are either on-site or are using a :ref:`remote connection <How to connect remotely to the GBO network>`. 

Observing Preparation
=====================

Latest 30 minutes before the start of your observing session (give it more time if you're new to the GBT):

#. Log into *ariel* or *titania*, one of the two dedicated observing computers. 
#. Start CLEO's talk & draw application :code:`cleo talk`
    .. note::

        If the fontsize in talk&draw is unreadably small, close all open CLEO applications and run :code:`xrandr --dpi 96` in a terminal. Then reopen your CLEO application.


    .. image:: material/observing_talkDraw.png

#. Contact the telescope operator 30 minutes before the start of your observing session
    * either via talk & draw or
    * call via telephone: The contact number is +1-304-456-2346 or the Operator's direct line at +1-304-456-2341 (x2346 connects to a speaker phone and is the preferred number to use. 
    * Tell the operator who you, your project, and what computer you will be running your observations from (*ariel* or *titania*). They usually will tell you right away, if not, ask for the operator's name (you will need that later). 

#. Start AstrID, type :code:`astrid` in a terminal
    * Choose "Work Offline" mode when prompted

      .. image:: material/observing_astridMode_offline.png

#. In AstrID: 
    * Make sure all your scripts are ready to go:
        .. image:: material/observing_astrid_ObservationManagementTab_Edit.png    

    * Fill in your project details in the ObservationManagement Run Tab
        * Enter your project (if not there already)
        * Enter your name as observer.
            .. note::

                The dropdown menu is very long and impractical. Instead start typing your first name and it will bring up the options that match what is typed. Keep typing until you see your name.

        * Enter the telescope operator's name. 

        .. image:: material/observing_astrid_ObservationManagementTab_Run_01.png

Observing
=========

Once the operator lets you know your observing time has started and they give you security access (put you in the "gateway"), you should 
    #. Put your Astrid into *online with control of the telescope* mode
        .. image:: material/observing_astridMode_change.png
        .. image:: material/observing_astridMode_onlineControl.png

    #. Load your observing script and submit it
        .. image:: material/observing_astrid_ObservationManagementTab_Run_02.png
