#* 
#* ------------------------------------------------------------------
#* Reference.hh - Online Reference for Time Table
#* Created by Robert Heller on Thu Apr 26 12:27:19 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#*

0 Reference Manual

The Time Table (V2) program is a hybrid program, consisting of a Tcl/Tk
GUI on top of a C++ class library.  The GUI provides the user interface
to the algorithms and data structures contained in the C++ class
library.

Table of Contents:

    <Command Line Usage>
    <Layout of the Main GUI>
    <Creating a New Time Table>
    <Loading an Exiting Time Table File>
    <Saving a Time Table File>
    <Adding Trains>
    <Deleting Trains>
    <Linking and Unlinking Duplicate Stations>
    <Adding Station Storage Tracks>
    <Adding Cabs>
    <Handling Notes>
    <Printing a Time Table>
    <Exiting From the Program>
    <Select One Train Dialog>
    <The View Menu>
    <System Configuration>

1 Command Line Usage

There are two formats for the TimeTable program's command line.  The
command line can either have a single file name, the name of an
existing time table file or it can have two options ([-totaltime] and
[-timeincrement]) and the name of a new time table.  The first form
loads an existing time table (see <Loading an Exiting Time Table File>)
and the second form creates a new time table (see <Creating a New Time
Table>).  These two command line formats are shown in below.

 	[TimeTable oldtimetablefile ]
	[TimeTable -totaltime time -timeincrement time nameoftimetable ]

1 Layout of the Main GUI

The main GUI window contains a menu bar, a toolbar, a time table chart,
and a button menu.

{TTMainGUIBlank.gif}

{TTMainGUIToolBar.gif}

{TTMainGUIButtonMenu.gif}


1 Creating a New Time Table

Creating a new time table can be done from the command line by
specifying a total time (in minutes) value with the [-totaltime] option
and a time increment value (in minutes) value with the [-timeincrement]
option and a name for the new time table (see <Command Line Usage>).  A
new time table can also be created with the [New] menu item of the
[File] menu or the {../lib/Common/new.gif} toolbar button. These later
two methods use the <Create a New Time Table> dialog to get the total
time, time increment, and the name of the new time table.  If there is
a time table file already loaded, a confirmation dialog will be
displayed.

2 Creating the station stops for a new time table

Stations for a time table must all be created when the time table is
created.  Stations cannot be added or removed later.  When a new time
table is created the <Create All Stations Dialog> is displayed to
create all of the station stops.

2 Creating an initial set of "cabs"

Once the stations have been created, an initial set of "cabs" can be
created.  Commonly, cabs are only used on block switch DC layouts, but
the cabs can be used as with a  DCC layout as a way to associate trains
with different operating "crews" (operators) or just to identify
different classes of trains by color, etc.  The <Create All Cabs>
dialog is used to bulk create an initial set of cabs.

A simple chart with three stations, four cabs (labeled "Crew 1" through
"Crew 4"), and two storage tracks is shown below.

{TTChart3station.gif}

1 Loading an Exiting Time Table File

An existing time table file can be loaded from the command line (see
<Command Line Usage>),  with the [Open...] menu item of the [File] menu
or the {../lib/Common/open.gif} toolbar button. If there is a time
table file already loaded, a confirmation dialog will be displayed.

1 Saving a Time Table File

The currently loaded time table can be saved with either the
[Save] (or [Save As...]) menu item of the [File] menu or
the {../lib/Common/save.gif} toolbar button. 

1 Adding Trains

Trains are added using the either the [Add Train] menu item of the
[Trains] menu, clicking on the add train
({../lib/TimeTable2/addtrain.gif}) toolbar button or the [Add a
new train] button. All of these display the "Create New Train
Dialog", described in <Create New Train Dialog>.

2 Create New Train Dialog

The "Create New Train Dialog" first collects some basic information
about the new train, as shown below.
The basic train information consists of the train's common name, its
number (or symbol), its class number, its average speed, its scheduled
departure time, and the two stations it travels between.

{TTCreateNewTrain1.gif}

The train's number (or symbol) needs to be a unique identification of
the train.  The common name need not be unique.  The class is a whole
number, with smaller numbers generally being the "higher" class. The
class is used to indicate a train's priority and is also used to group
similar trains together.  The speed is the (scale) speed the train will
be traveling between stops.  The scheduled departure time is the time
the train is scheduled to leave its origin station.  The origin and
termination stations are the station end points the train travels between.

The [Schedule] button selects the scheduling page of the "Create a New
Train Dialog", as shown below.  On this page, the cab can be selected
and layover periods at intermediate stations can be set.  The [Update]
buttons propagate the cab settings and adjust the times to allow for
the layovers.

{TTCreateNewTrain2.gif}


The [Storage] button selects the storage track allocation page of the
"Create a New Train Dialog", as shown below.  This page lists those
stations that have storage tracks available.  It only makes sense to
select storage tracks for intermediate stops if there is a layover or
for originating or terminating stops.

{TTCreateNewTrain3.gif}

1 Deleting Trains

Trains are deleted using the [Delete Train] menu item of the [Trains]
menu, clicking on the delete train
({../lib/TimeTable2/deletetrain.gif}) toolbar button or the [Delete an
Existing train] button. All of these display the <Select One Train
Dialog>. A delete confirmation dialog will also be displayed.

1 Linking and Unlinking Duplicate Stations

Duplicate stations occur mostly with "out and back" type layouts where
the opposite ends of the line are modeled with the same trackage
(usually a yard).  Duplicate stations also occur with reverse loops.
In all cases, these are stations which are logically different, but
which use the same tracks.  It is necessary to keep track of this
trackage in the schedule.  The duplicate station linking handles this.
Duplicate stations need to be setup before trains have been added.

The [Set Duplicate Station] and 
[Clear Duplicate Station] menu items of the [Stations] menu, the
{../lib/TimeTable2/setdupstation.gif} and
{../lib/TimeTable2/cleardupstation.gif} toolbar buttons, and the
[Set Duplicate Station] and [Clear Duplicate Station] buttons
set and clear duplicate stations.

1 Adding Station Storage Tracks

Storage tracks are sidings where whole trains can be stored, either
during a long layover or between trips. The  [Add Storage Track]
menu item of the [Stations] menu, the
{../lib/TimeTable2/addstorage.gif} toolbar button, or the  [Add
Storage Track] button are used to add a storage track to a station.

1 Adding Cabs

Generally "Cabs" refer to the separate throttle controls on a block
switched DC layout.  They are generally non-existent with a DCC layout,
but virtual cabs might be used as a way of assigning crews (operators)
to a train or to a segment of a train's run.  Cabs are added with the
[Add A Cab] menu item of the [Cabs] menu, the
{../lib/TimeTable2/addcab.gif} toolbar button or the [Add A Cab]
button.

1 Handling Notes

Notes are brief memos about the operating rules in effect.  There is a
single pool of notes.  Notes from this pool can be associated either
with a whole train or with a train at a station stop.  The notes can
specify schedule exceptions (eg "Daily except Saturdays, Sundays, and
Holidays"), or operating rules relating to meets.

2 Creating New Notes and Editing Existing Notes

Notes are created and edited the [Create New Note] and [Edit Existing
Note] menu items of the [Notes] menu, the
{../lib/TimeTable2/createnote.gif} and
{../lib/TimeTable2/editnote.gif} toolbar buttons, or
the [Create New Note] and  [Edit Existing Note] buttons.  The the "Note
editor dialog", shown below is used to create or edit the note.  Notes
are numbered consecutively starting with 1.

{TTEditNote.gif}

2 Adding and Removing a Notes To Trains

Notes are added to trains or removed from trains with [Notes] menu
items [Add note to train], [Add note to train at station stop], [Remove
note from train], and  [Remove note from train at station stop]; the
{../lib/TimeTable2/addnotetotrain.gif},
{../lib/TimeTable2/addnotetotrainatstation.gif},
{../lib/TimeTable2/removenotefromtrain.gif}, and
{../lib/TimeTable2/removenotefromtrainatstation.gif}; or the   [Add
note to train], [Add note to train at station stop],  [Remove note from
train], and  [Remove note from train at station stop] buttons.  All of
these display the "Add (or Remove) Note dialog", shown below.

{TTAddNote.gif}

1 Printing a Time Table

"Printing" a time table actually means creating a LaTeX file and
then processing that LaTeX file through a LaTeX processing program
(typically [pdflatex]).  LaTeX provides the means to produce a
professionally formatted document and has the means to provide things
like table of contents and the creation of a final document in a
selection of different final formats, including PDF (via
[pdflatex]), PostScript (via [latex] and [dvips])
or HTML (via the [htlatex] script from [tex4ht] package).

Much of the formatting is customizable through the insertion of LaTeX
code fragments as well as through various parameter settings.  It is
also possible to edit the LaTeX style file that comes with the Time
Table program ([TimeTable.sty]) to tweak some of the fine details
of the formatting as well (1).

--------------------------
(1) Some knowledge of how LaTeX works is recommended when messing with the
style file.

The [Print] menu item of the [File] menu or the
{../lib/Common/print.gif} toolbar button initiate the print
process by displaying the <Print Timetable Dialog>.


2 Print Timetable Dialog

The "Print Timetable" dialog, shown below collects the basic
information needed to generate and process a LaTeX source file from
the time table data structure.  This information consists of the name of
the name of the LaTeX source file to create, the LaTeX processing
program ([pdflatex] by default), whether to run the LaTeX
processing three times (to get the table of contents right), the name of
any post processing command (such as [dvips] if using plain
[latex]).  Most of the time, this is enough for a standard, basic
time table.  The [Configure] button can be used to configure a
selection of options using a <Print Configuration Dialog>.

Once the settings and configuration have been set, the [Print]
initiates the process.  First a LaTeX source file is generated, then
the LaTeX processing program is run once or three times.  The output
from these runs are displayed in a process log window (LaTeX outputs
a fair amount of diagnostic output, most of which can be ignored).  If
you are using the default processor ([pdflatex]), you should now
have a PDF file which can be viewed or printed with the PDF viewer of
your choice.

2 Print Configuration Dialog

The Print Configuration Dialog, shown below, provide for the setting of
many print configuration options. The general settings, provide for
setting the title, subtitle, the date, whether to have LaTeX format for
double sided printing, setting the time format, setting the logical
direction of trains, column widths, and including additional commands
in the LaTeX preamble (usually including additional style packages (1)
and style settings). The multi-table settings, provide for settings
relating to time tables using multiple tables.  These settings include
whether to create a table of contents, whether to use multiple tables
at all, LaTeX code to precede the table of contents, LaTeX code to
precede notes section, the header to use if a single "All Trains" table
is generated, and LaTeX code to precede this single "All Trains" table.
The groups settings, provide for settings for each group.  This
includes whether to group by class or to manually group trains and
provides for setting the class or group heading and for LaTeX code to
precede the group table, and if grouping manually, selecting the trains
in the group.


{TTPrintConfigurationDialog1.gif}

{TTPrintConfigurationDialog2.gif}

{TTPrintConfigurationDialog3.gif}

--------------------------------
(1) The style pages supertabular and graphicx are already included.

1 Exiting From the Program

The [Exit] (or [Close]) menu item of the [File]
menu, the {../lib/Common/close.gif} toolbar button, or the
[Quit -- Exit NOW] button exit the program.  A confirmation
dialog is displayed to get confirmation.

1 Select One Train Dialog

The "Select One Train dialog" is used to select a train either for
deletion (<Deleting Trains>) or for viewing.

1 The View Menu

The view menu contains menu items for viewing detailed information
about various things, including <Trains>, <Stations>, and  <Notes>.

2 Trains

There are two menu items for viewing trains, [View One Train] and [View
All Trains].  The [View One Train] uses the <Select One Train Dialog>)
to select a train to display detailed information about and the [View
All Trains] menu item displays a dialog listing all of the trains, by
number and name, with buttons to get more detailed information.

2 Stations

There are two menu items for viewing stations, [View One
Station] and [View All Stations].  The [View One Station]
uses the "Select One Station dialog" to select a station to display
detailed information about and the [View All Stations] menu item
displays a dialog listing all of the stations, by name and scale mile, with
buttons to get more detailed information.

2 Notes

There are two menu items for viewing notes, [View One Note] and
[View All Notes].  The [View One Note] uses the "Select
One Note dialog" to select a note to display detailed information
about and the [View All Notes] menu item displays a dialog
listing all of the notes, by number and beginning text, with buttons to
get more detailed information.

1 System Configuration

The Time Table program has a small number of global
configuration options.  These are stored in a file named
[.timeTable] ([TimeTable.rc] under MS-Windows) in the
current user's HOME directory.  These configuration options are:

   [Path to pdflatex] The pathname to the [pdflatex] executable.
   [Label Width in Chart] The width in pixels of cab, station, and
                          storage track labels in the time table chart.
   [Height of main window] The initial height of the main window.
   [Width of main window] The initial width of the main window.

The system configuration file is read at program startup.  If the
configuration does not exist, a default one is created the first time
the program is run.

The [Options] menu manages the system configuration, with menu
items to edit the system configuration, save it and reload it.


