.. literalinclude:: /references/observing/scripts/cs_observation.py
    :language: python
    :caption: An example cyclic spectroscopy observation.

	      
The above example illustrates all the steps necessary to obtain flux
and polarization calibration data, followed by a cyclic spectroscopy
(CS) pulsar observation.  These are

1. Load an Astrid catalog using the :func:`Catalog()
   <astrid_commands.Catalog>` command.
2. Define configuration blocks for the calibration and pulsar observations.
3. Configure the GBT using the :func:`Configure()
   <astrid_commands.Configure>` command.
4. Move the telescope to a source using the :func:`Slew()
   <astrid_commands.Slew>` command.
5. Update the pointing and focus corrections using
   an :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>`. *Always
   remember to reconfigure after an AutoPeakFocus*, otherwise you
   won't be set up for pulsar observing.
6. Balance the IF system using the :func:`Balance() <astrid_commands.Balance>` command.
7. Take data via one of several observing directives, such as
   :func:`Track() <astrid_commands.Track>` or :func:`OnOff()
   <astrid_commands.OnOff>`.


.. note:: 

    There are a couple of things to take note of in this example.

    1. We do **not** issue a second Balance command after the polarization
       calibration scan, but instead immediately reconfigure and take our
       main pulsar scan.  If we did rebalance, the conversion factor
       between counts and antenna temperature/flux density could change
       and our calibration scan would not be valid for the pulsar scan.
    2. We add 5 seconds to the scan length in cal- and fold-mode scans to
       ensure that the last sub-integration is always written to disk.
    3. This example is verbose by design so as to illustrate all the
       important steps.  Since Astrid scripts are written in Python there
       are numerous techniques for simplifying observing scripts. Contact
       your project friend if you would like help with more advanced
       scripting.

