
Mapping Strategies
------------------

The sky should be sampled five times across the beam (i.e., the scan rate and integration
times should be set such that there are five integrations recorded in the time the telescope
scans across an angle equal to the beam FWHM) and there should be four switching periods per
integration (see :cite:t:`Mangum2007` for details).  

* **VEGAS**: Minimum recommended integration times and switching periods are listed in 
  :numref:`tab-vegas-swper-cal` and :numref:`tab-vegas-swper-nocal`.  

* **DCR**: The DCR has a minimum integration time of 100 ms.

The `GBT Mapping Calculator <http://www.gb.nrao.edu/~rmaddale/GBT/GBTMappingCalculator.html>`__
is a useful tool for planning mapping observations and may be used to provide AstrID commands
and parameters for many of the mapping scan types.  

It is important to take account of the overheads involved with mapping scans. For example, 
depending on the mapping speed, it may take ~5-25 seconds to start a mapping scan. So if you 
schedule short scans you can lose a large fraction of your observing time to overheads. 

Using Daisy pattern scans are more efficient for scheduling small maps,
as a region can be mapped in a single scan.  However there is an additional delay in starting a 
:func:`Daisy() <astrid_commands.Daisy>` procedure, as the system computes the antenna trajectories. 
As a rule of thumb, maps larger than about 10-20 beam FWHM in size should use the :func:`RALongMap() <astrid_commands.RALongMap>`
or :func:`DecLatMap() <astrid_commands.DecLatMap>` scan types while smaller maps should use 
:func:`Daisy() <astrid_commands.Daisy>` scans. For practical reasons, it is often best to keep 
the scan length under about 15 minutes.

Observers wishing to use the GBT mapping pipeline may periodically wish to include reference scans 
into their SBs. Further information on using the pipeline can be found `here <https://safe.nrao.edu/wiki/bin/view/GB/Gbtpipeline/PipelineRelease>`__.

.. todo:: Wiki page is not publicly accessible. Move content over to GBTdocs. 

