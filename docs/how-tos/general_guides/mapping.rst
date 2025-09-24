
Mapping Strategies
------------------

The sky should be sampled five times across the beam (i.e., the scan rate and integration
times should be set such that there are five integrations recorded in the time the telescope
scans across an angle equal to the beam FWHM) and there should be four switching periods per
integration (see Mangum, Emerson, and Greisen 2007 A\&A, 474, 679 for details).  

.. todo:: Add reference to Magnum et al 2007.

For VEGAS, minimum recommended integration times and switching periods are listed in Table XXX
and YYY.  

.. todo:: Add references to tables 10.1 and 10.4 from observer guide.


The DCR has a minimum integration time of 100 ms.

The `GBT Mapping Calculator <http://www.gb.nrao.edu/~rmaddale/GBT/GBTMappingCalculator.html>`
is a useful tool for planning mapping observations and may be used to provide AstrID commands
and parameters for many of the mapping scan types.  

It is important to take account of the overheads involved with mapping scans. For example, it 
takes approximately 25 seconds to start a :func:`RALongMap() <astrid_commands.RALongMap>` mapping 
scan. So if you schedule scans much shorter than 1 minute you will lose a large fraction of your
observing time to overheads. 

.. todo:: Check if this is still the case, I believe the start time for an individual scan has been significantly reduced by now.

Using Daisy pattern scans are more efficient for scheduling small maps,
as a region can be mapped in a single scan.  However there is an additional delay in starting a 
:func:`Daisy() <astrid_commands.Daisy>` procedure, as the system computes the antenna trajectories. 
As a rule of thumb, maps larger than about 10-20 beam FWHM in size should use the :func:`RALongMap() <astrid_commands.RALongMap>`
or :func:`DecLatMap() <astrid_commands.DecLatMap>` scan types while smaller maps should use 
:func:`Daisy() <astrid_commands.Daisy>` scans. For practical reasons, it is often best to keep 
the scan length under about 15 minutes.

Observers wishing to use the GBT mapping pipeline may periodically wish to include reference scans 
into their SBs. Further information on using the pipeline can be found at `https://safe.nrao.edu/wiki/bin/view/GB/Gbtpipeline/PipelineRelease`__.

.. todo:: Check if that links still works and is accessible. Replace if needed. 

