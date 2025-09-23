.. _dss:
Dynamic Scheduling System
-------------------------


.. todo::

   Add a short paragraph describing why the DSS is important from the perspective of the observer. 

The GBT has been scheduled with the Dynamic Scheduling System (DSS) since October 1, 2009.
You can access the DSS through `https://dss.gb.nrao.edu`__.


Overview of the DSS
^^^^^^^^^^^^^^^^^^^

The Green Bank Telescope Dynamic Scheduling System (DSS) improves observing efficiency by matching
schedules to weather forecasts while preserving observer control of the telescope. Each day, the 
DSS evaluates weather, equipment, and observer availability, then generates a 24-hour schedule for
the following day. Observers therefore usually receive 24–48 hours’ notice before their project will 
observer. 

Observers can use the DSS to pause their projects, set blackout dates, or withdraw if conditions do 
not meet their science goals.

Remote observing is supported, but visiting Green Bank increases the chance of being scheduled. 
Visits should be arranged in advance with the assigned GBT project friend. To improve scheduling
opportunities, we recommend visits of one to two weeks, with high-frequency projects (20 GHz and
above) often requiring stays of two weeks or longer.


DSS Terminology
^^^^^^^^^^^^^^^

The process of scheduling GBT observations begins with the preparation of the proposal using the 
`NRAO Proposal Submission Tool (PST) <https://my.nrao.edu/>`__. Proposals accepted by the NRAO 
Time Allocation Committee (TAC) become GBT projects that appear in the DSS system and are identified
by an assigned project ID (e.g., ``GBT09A-001``).

Projects are divided into sessions, which have associated parameters that define how the observation
should be scheduled. These parameters include sky position, time allocated, observing frequency,
and minimum and maximum durations preferred for a single, contiguous block. Sessions for monitoring
observations have additional parameters describing how often to repeat the observation. The project 
investigator (PI) initially defines the session parameters in the proposal, but the parameters may 
be modified by request to the :email:`DSS helpdesk <helpdesk-dss@nrao.edu>`. Observers can see the 
most critical session parameters on the DSS web pages.

Completing the observations for a session may require scheduling multiple segments. Each contiguous
block of scheduled time is called a **telescope period**.

As telescope periods are completed, the project and associated sessions will be billed for the time.
If any time is lost to weather or an equipment failure, the observer may consult with the telescope 
scheduler (via the helpdesk) and request that the project not be billed for the lost time.


Controlling the Scheduling of a Project}
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Users can access their DSS account by logging in to the system at `https://dss.gb.nrao.edu`__.
The DSS username and password are the same as those used for NRAO Interactive Services (i.e.,
the Proposal Submission Tool).

From the DSS web site, users can view and manage the scheduling information for their projects.
In order for a project session to enter the pool of sessions eligible for scheduling, the user 
is responsible for ensuring that the session is enabled in the DSS, and that a qualified observer
is available to perform the observation. Sessions and observers are enabled for observing simply
by clicking a check box in the DSS project page (See figure~\ref{fig:dss_project_page}). 

Users can control when their project is scheduled by enabling or disabling individual sessions.

.. important:: 

    Astronomers intending to observe remotely must be trained and approved by GB staff before
    the project can be authorized and made eligible for scheduling.

Observers can enter personal blackout dates. Blackouts can be entered either as one time events 
(e.g., May 1, 20:00 to May 4, 05:00 UT) or as repeating events (e.g., every Monday from 15:30 
to 17:30 ET). If all observers for a given project are blacked out at a given time, that project
will not get scheduled. If at least one observer is not blacked out, the project is eligible for
scheduling. The default time zone used for entering blackouts is set in the *Preferences* tab,
which is linked at the top of every DSS web page. Observers can also override the default by 
selecting a time zone when making a blackout entry.

Observers with more than one project will find that they need to enter blackout dates only
once, and the dates will be applied to all their projects. **Those visiting Green Bank to
observe should use blackout dates to mark the periods of their travel before and after the
run to ensure they are scheduled only when available and ready on-site.**

When entering blackouts, keep in mind, too, that projects do expire, so it is in the interest 
of the observer to keep the projects eligible for scheduling as much as possible.


Guidelines for the use of blackouts
''''''''''''''''''''''''''''''''''

While blackout dates give observers control of the scheduling process, efficient GBT operation
requires that not too much time be blacked out or disabled. It is especially important that 
projects with large observing allocations not have too much time unavailable for scheduling
because of blackouts. As a guideline, projects with more than 20 hours of allocated observing
should limit time that cannot be scheduled to no more than 20% of the total eligible observing 
time over the course of a semester. If a project cannot meet this guideline, the PI is encouraged
to increase observing opportunities by enlisting additional observers who are qualified for
remote observing. Projects that require observers to visit Green Bank for training are excluded
from this guideline until the observers are trained for remote observing.

Caution Regarding Blackouts
'''''''''''''''''''''''''''

If a project has only one observer, that observer should be particularly conscientious of 
blackouts. It can be easy for an observer to inadvertently hamper observing opportunities 
by setting blackout dates too freely, particularly repeating blackouts. Repeating blackouts 
should be used with care. Targets with low declinations, such as the Galactic Center, have 
tightly constrained observing opportunities to begin with, so observers on such projects
should be particularly careful with blackouts that would further limit their observing
opportunities. Consider, as an example, a project that has a session with a 4-hour
minimum duration to observe the Galactic Center. If the observer has a repeating 1-hour
blackout date that intersects the window, the entire session becomes ineligible each time
the blackout intersects the 4-hour window.  The Green Bank Observatory is not responsible
for lost observing opportunities due to excessive blackouts.


Canonical Target Positions
^^^^^^^^^^^^^^^^^^^^^^^^^^

The DSS keeps track of a project's scheduling requirements via the session parameters,
which can be viewed on the project page. The PI should check that session parameters
properly reflect the needs of the project. The project Friend assigned by NRAO can also
offer advice on optimizing session parameters, where appropriate. In some cases, a
session's target position may be representative of a group of objects clustered on the sky.
As the project progresses and some of these targets are observed, this representative
position may need to be updated. In this case, the PI should send an email request to
the DSS helpdesk.

The DSS can automatically update the sky coordinates of common, fast-moving solar system objects,
including comets. The position is updated each day prior to scheduling. On the project page under
*Project Sessions*, an asterisk next to the coordinates indicates that the position for that 
session is automatically updated in this manner.

Many observers find it helpful to use a sky-plotting tool to help plan their observations
and keep track of target locations on the sky. The CLEO Scheduler & Skyview tool, which
runs on Linux systems in Green Bank and can be run remotely through VNC or FastX, is one such tool
that allows a GBT user to plot target locations on the sky for any date and time. This
application can read target coordinates from a standard astrid catalog file. Observers will find
this tool handy for identifying the time of day a project may get scheduled, as well as helping to
plan observations in detail after they are scheduled. 

.. todo:: 

    Add the relevant references CLEO scheduler, FastX/VNC connection. 


Contact Information and Project Notes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Observers can specify how they should be contacted, prior to and during their observations. 
It is critical to keep contact information current. Each observer can provide *dynamic contact*
information in a free-format text box. Here the observer should provide any contact information
not available through the person's (static) NRAO contact information, which is also listed on the
page. Observers can also specify the order in which they should be contacted by GBT operations, 
in the event of any schedule changes or in case there is need to contact the observer for any 
reason prior to the scheduled start time. Specify the order by clicking the arrow icons next to 
the list of team members, on the DSS project page.

Finally, observers can record *Project Notes* on the DSS project web page. Project notes provide
observers a place to store and share observing instructions. The notes are visible to all project
team members as well as the GBT operations staff and schedulers. Observers who need to share
instructions or other information with the GBT operator prior to the start of an observation can 
provide these instructions in the project notes area. Project notes are not intended to be a log 
for observations, but rather a place to store brief instructions or news that should be shared 
among observers and the GBT operator.


The DSS Software
^^^^^^^^^^^^^^^^

DSS Home Page
'''''''''''''

Upon logging in to the DSS system, you will arrive at your DSS home page where you see a list of
active projects on which you appear as (co-)investigator.

.. image:: images/dss_home_page_new.jpg

From the \gls{DSS} home page, you can:

* access the project page for each of your affiliated projects
* see a list of upcoming observations
* see a list of upcoming Green Bank room reservations
* see your *static* contact information, as entered in the `NRAO services syste <http://my.nrao.edu>`__.
* set *dynamic* contact information
* set blackout dates
* follow a link to the current GBT fixed schedule
* follow a link to the weather forecasts page
* follow a link to the \gls{NRAO} support center
* set the default time zone via the * Preferences* link (under your name)
* access DSS documentation
* establish an iCalendar subscription. Instructions for using iCalendar are available by hovering
  the mouse cursor over the iCal icon on the DSS Home Page.


DSS Project Page
''''''''''''''''

By selecting a project ID, you are presented with the project page. 

.. image:: images/dss_project_page1_new.png
.. image:: images/dss_project_page2.jpg
.. image:: images/dss_project_page3.jpg
.. image:: images/dss_project_page4.jpg

Here is a list of what you can do on this page: 

* inspect session parameters
* enable or disable individual sessions
* view total allocated and billed time
* see a project calendar
* view scheduling alerts
* view receiver availability 
* view upcoming reservations
* view upcoming observations
* specify observers from the project team, and set the order they should be
  contacted by GBT operations

  * see a list of blackout dates for all observers on the project
  * see a list of completed telescope periods
  * store and share project notes
  * view your abstract and disposition letter


The project calendar gives observers an idea when their project is eligible for scheduling.
Regardless of the weather, there will be times when a project is not eligible for scheduling,
for example because of no receiver availability, observer blackouts, fixed telescope maintenance
periods, and other fixed projects appearing on the GBT schedule. Times not eligible for 
scheduling will be grayed out on the project calendar.

The project calendar helps with planning in a number of ways. However, it is important to 
understand that a session's eligibility is based on ever-changing constraints, and can 
change from *not eligible* to *eligible* at any time. Therefore, if observers wish to 
take a break from observing based on the calendar outlook, they should either disable
all sessions until they are ready to resume with the observing, or enter blackout dates 
to cover the period they do not wish to observe.

The project page includes a panel with project team members listed. Using a checkbox, 
team members can select or deselect those identified as observers. They can also rearrange
the order observers are listed. The top observer in the list is expected to observe the 
next scheduled session. If there is a change in schedule, this person will be called first.




Responsibilities
^^^^^^^^^^^^^^^^

Each project has a PI and, optionally, a list of additional investigators. An investigator 
is eligible to be an observer for a given project if that person is qualified for remote 
observing or is on site in Green Bank.

It is essential that one of the observers for a scheduled project contact GBT operations 
at least 30 minutes prior to the start of the observation. Observers can contact the GBT
operator by telephone (304-456-2341), by the CLEO chat program ``Talk and Draw``  (for 
qualified remote observers), or by showing up in the GBT control room. If the GBT operator
has not been contacted before the session's start time, the operator will phone observers
in the order they are listed on their project web page.

.. note:: 

    The PI is responsible for:

    * managing the project
    * identifying all associated observers
    * working with project team members and the GBT project friend to ensure that Scheduling
      Blocks are properly and promptly prepared.
    * enabling each session by clicking the ``Enabled`` checkbox on the project's web page. 
      Sessions should be enabled only if they will be ready for observing in the next 24 hours.
    * ensuring that all associated observers have provided contact information including a 
      current telephone number and an email address for each observer.
    * ensuring that a project's scheduling information is current. This includes checking the 
      hours remaining on the project and ensuring that the session parameters are up-to-date 
      and accurate.
    * ensuring that each scheduled telescope period has an observer who is available at least
      30 minutes before the session is scheduled to begin.

.. note:: 

    Observers are responsible for:
    
    * ensuring that the DSS project web page has their current contact information. For remote
      observers, this includes entering telephone numbers where they can be reached at the time of observation.
    * contacting GBT operations 30 minutes prior to the start time of an observation.
    * attending to observations during a scheduled telescope period. The PI is responsible for 
      "no-shows" and the ensuing reduction in their alloted time. 
    * notifying GBT operations if they find conditions unsuitable for their session.
  

Remote Observing
^^^^^^^^^^^^^^^^

To use the GBT remotely, observers must first be trained and certified by Green Bank staff. 
We encourage experienced observers to request additional training from GBO staff when using
instruments or observing modes unfamiliar to them.

Contact your GBt project friend or the :email:`DSS helpdesk <helpdesk-dss@gb.nrao.edu>` if
you believe the DSS does not have you listed properly as a qualified remote observer.

See :ref:`how-tos/infrastructure/remote-connection:How to connect remotely to the GBO network`
for remote connection details.


The Daily Schedule
^^^^^^^^^^^^^^^^^^

Each day between about 7:00 and 12:00 PM ET the telescope schedule is fixed for the 24-hour
period beginning 8:00 AM ET the next day. For example, by 12:00 PM ET Monday, the observing 
schedule is fixed for the period 8:00 AM ET Tuesday through 8:00 AM ET Wednesday. Each morning
this daily schedule is published and can be viewed on the DSS web site by anyone. Those with 
projects on the 24-hour fixed schedule will be notified by email.

Observers must ensure that their blackout dates and session enabled flags are up to date each
day by about 5:00 AM ET. Changes made after this time may not be reflected in the upcoming
day's schedule.

It is possible that weather conditions may change after a schedule is published, compromising 
the observing efficiency for some scheduled telescope periods. The observer or GBT staff may
then decide to cancel a telescope period and substitute an alternate "backup" observation in 
its place. Note that the observer may decide that the weather conditions are too poor even 
after beginning the observation. Equipment failure can also lead to cancellations. If GBT
staff must change the 24-hour schedule for these reasons, affected observers will be notified
immediately by email or telephone.


Backup Projects
^^^^^^^^^^^^^^^

When a scheduled telescope period is cancelled, a backup project will be scheduled on short
notice. By volunteering as a backup project, observers improve their project's chances of 
getting observing time. Backup projects can come in two categories: observer-run and 
operator-run. There are several requirements that must be met before a project can be 
considered for backup status.


Session Types
^^^^^^^^^^^^^

There are four types of sessions defined for astronomy projects:
* open 
* windowed
* elective
* fixed
 
Open sessions have no major constraints on when they can be scheduled, beyond the functional
requirements that an observer is available, the source is above the horizon, and the weather
is suitable. Most sessions fall into this category and provide the most flexibility in the DSS.
At the other extreme are fixed sessions that have no flexibility and are prescheduled at a 
particular date/time; that is, their telescope periods have already been defined.

The other two types are windowed and elective sessions, which have some constraints but are 
not fixed on the schedule. The most common examples are monitoring and VLBI sessions, where 
the science demands that an object must be observed at defined intervals or times.

Windowed sessions are defined by a cadence that may be either periodic or irregular. For 
example, an observer may require observing a target once per month for five months, with 
each observation having a tolerance of plus or minus 3 days. In this example, the window 
size is 7 days.

Currently, windowed sessions are scheduled in the following way. The cadence information from 
the proposal is used to preschedule all windowed sessions whereby all of the telescope periods
are temporarily fixed in what are called default periods. The user is given the window template
(e.g, 8-14 January; 8-14 February; 8-14 March; 8-14 April; and 8-14 May). Within a windowed 
period, a windowed session will be considered like an open session. Near the end of each 
window range is a default period. If the session has not been selected by the time the default
period arrives, the session will be scheduled in the default period. The default period may be
moved manually to a later time slot within the window if the human scheduler notices a problem
with the original default period. When the windowed period is scheduled, the observer will be
informed 24-48 hours in advance, just like an open session. The only difference is that the
observer will be provided with the window template for planning purposes. 

Elective sessions are a restrictive form of windowed sessions.  Here, rather than having a
range of days on which the project session can be scheduled, there is a list of possible days.
As with windows the list of possible days, or * opportunities*, has a default period on which
the session will be scheduled if it has not run in advance of that date.



Projects that can Tolerate Degraded Weather
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The DSS is designed to schedule projects in weather that is appropriate for the 
frequency being observed. Some projects can tolerate lesser weather conditions than the
DSS would assign by default. For example, consider a project at K-band that observes many
targets, each for a short duration, say 10 seconds. The observing time for this project is
dominated by overheads in slewing from one position to the next, so marginal K-band weather
might be acceptable. The observing team may prefer not to wait for very good K-band weather,
which is rare and would delay their scheduling.

To enable more aggressive scheduling, the observer should send an email to the :email:`DSS helpdesk
<helpdesk-dss@nrao.edu>` requesting that the project be considered for scheduling in lesser
weather conditions. The DSS support team can enter a session-specific factor, :math:`\xi`,
that effectively elevates the score for this session in marginal opacity conditions. The :math:`\xi`
parameter is tunable so the observer can request that the project be scheduled very aggressively,
or modestly so. The factor only affects scoring related to atmospheric opacity, so high frequency
projects that are sensitive to high winds will still not get scheduled when the forecasted winds
preclude accurate pointing.

The DSS support team will help observers decide if their project can tolerate lesser weather. 
Note that this capability will not be used to accelerate scheduling of projects that truly do 
benefit from the most appropriate weather.


Other DSS Control Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A list of the most relevant parameters can be found in Appendix~\ref{appendix:dsscontrolparameters}.

.. todo:: Add these parameters here.

There are a number of additional controls and parameters that can be used within the DSS system which
are fully described in \citet{ONeil2011}.

.. todo:: Add these descriptions here.

Any changes to these parameters must be requested by contacting the GBT scheduler via the :email:`DSS helpdesk <helpdesk-dss@nrao.edu>`.



