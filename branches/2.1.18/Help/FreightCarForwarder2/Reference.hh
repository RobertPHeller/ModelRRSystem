#* 
#* ------------------------------------------------------------------
#* Reference.hh - Online Reference Docs
#* Created by Robert Heller on Thu Apr 26 09:02:34 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/05/06 12:49:44  heller
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

The Freight Car Forwarder (V2) is a hybrid program, consisting of a
Tcl/Tk GUI on top of a C++ class library.  The GUI provides the user
interface to the algorithmns and data structures contained in the C++
class library.

Table of Contents

    <Command Line Usage>
    <Layout of the Main GUI>
    <Opening and loading a system file>
    <Loading and reloading the cars file>
    <Saving the cars file>
    <Managing trains and printing>
    <Viewing a car's information>
    <Editing a car's information>
    <Adding a new car>
    <Deleting an existing car>
    <Showing cars without assignments>
    <Running the car assignment procedure>
    <Running every train in the operating session>
    <Running the boxmove trains>
    <Running a single train>
    <Openning the printer>
    <Closing the printer>
    <Printing yard and switch lists>
    <Showing cars on the screen>
    <Printing Reports>
    <Reseting Industry Statistics>
    <Quiting the application>
    <Files>

1 Command Line Usage

The name of the system file to load can be specified on the command
line. See <Opening and loading a system file> for more information.


1 Layout of the Main GUI

The main GUI window contains a menu bar, a toolbar, a text display
area, and a button menu. There is also a  work in progress message
area, a  general status area, a progress meter, and several indicators.
The main GUI also has three "slide out" frames, one for showing train
status when trains are run, one for viewing a car's information, and
one for editing a car's information. Each slide out has a corresponding
indicator. 


1 Opening and loading a system file

The [File->Open...] menu button and the {../lib/Common/open.gif}
toolbar button popup a file selection dialog to select a system file to
load. Once this file is successfully loaded, the name of the file, the
name of the system, the current session and shift number, plus a count
of  divisions, stations, industries, cars, and trains is displayed in
the main GUI's text area.  Also all of the buttons are made avtive. 
The name of the system file can be specified on the command line and
the named system file will be loaded when the program starts.

1 Loading and reloading the cars file

The [Load Cars File] menu button and the
{../lib/FreightCarForwarder2/loadcars.gif} toolbar button load (or
reload) the cars file.

1 Saving the cars file

The [Save Cars File] menu button and the {../lib/Common/save.gif} 
toolbar button save the cars and statistics files. This is something you
need to do after you have simulated a session, by running the car
assignment procedure and then run the trains in your session.  This
saves the state for the next time you run the Freight Car Forwarder.

1 Managing trains and printing

The [Manage trains/printing] menu button and the 
{../lib/FreightCarForwarder2/managetrainsprint.gif} toolbar button popup the
train/printing management menu.  This menu provides a set of functions
relating to what trains are printed and can also  print a displatcher
report and generate lists of various sorts of trains.

Menu:

   <Controlling yard lists>
   <Enabling printing for all trains>
   <Disabling printing for all trains>
   <Printing a dispatcher report>
   <Listing local trains for this shift>
   <Listing manifests for this shift>
   <Listing all trains for all shifts>
   <Managing a single train>

2 Controlling yard lists


The [Control Yard Lists] menu item (y key) pops up a dialog, (see
<ControlYardListsDialog>), to control whether to print 0, 1, or 2
alphabetical lists and whether to print 0, 1, or 2 train lists.

2 Enabling printing for all trains

The [Print All Trains] menu item (p key) turns on printing for all
trains. 

2 Disabling printing for all trains

The [Print No Trains] menu item (n key) turns off printing for all
trains.

2 Printing a dispatcher report

The [Print Dispatcher Report] menu item (d key) enables the
printing of a dispatcher report.

2 Listing local trains for this shift

The [List Locals This Shift] menu item (l key) lists all locals for
this shift.

2 Listing manifests for this shift

The [List Manifests This Shift] menu item (m key) lists manifest
freights for this shift.

2 Listing all trains for all shifts

The [List All Trains All Shifts] (? key) Lists all trains.

2 Managing a single train

The [Manage One Train] menu item (1 key) pops up a dialog (see
<ManageOneTrainDialog>), to enable or disable printing of
a single train, as well as setting the train's maximum length and
setting which shift the train will be run.  The train is selected with
the <SelectATrainDialog>.

1 Viewing a car's information

The [View Car Information] menu button and the
{../lib/FreightCarForwarder2/viewcar.gif} toolbar button display the
information about a single car.  The information is displayed on the
view car "slide out".
The car is selected with the <SearchForCarsDialog>. 

1 Editing a car's information

The [Edit Car Information] menu button and the
{../lib/FreightCarForwarder2/editcar.gif} toolbar button display the
information about a single car and allow for editing this information. 
The information is displayed on the edit car "slide out". The car is
selected with the <SearchForCarsDialog>.

1 Adding a new car

The [Add a New Car] menu button and the
{../lib/FreightCarForwarder2/addcar.gif} toolbar button provide for
adding a new car.  The edit car "slide out" is displayed and the
information about the new car can be filled in and the car added.

1 Deleting an existing car

The [Delete An Existing Car] menu button and the
{../lib/FreightCarForwarder2/deletecar.gif} toolbar button provide for
deleting an existing car.  The car is selected with the
<SearchForCarsDialog> and the car's information is displayed in the
view car "slide out". Actual removal can then be confirmed.

1 Showing cars without assignments

The [Show Unassigned Cars] menu button and the
{../lib/FreightCarForwarder2/unassignedcars.gif} toolbar button display
unassigned cars in the text window.

1 Running the car assignment procedure

The [Run Car Assignments] menu button and the
{../lib/FreightCarForwarder2/assigncars.gif} toolbar button run the car
assignment procedure.  This procedure attempts to give as many
unassigned cars assignments, that is possible destinations. 
Considerations taken into account are the type of car, whether it is
loaded or not, industries with available trackage to accomdate the car,
and so on.  The list of cars is scanned twice and the progress of the
procedure is displayed in the text area.

1 Running every train in the operating session

The [Run All Trains in Operating Session] menu button and the
{../lib/FreightCarForwarder2/runalltrains.gif} toolbar button run all trains in
the operating session, except the end of session box moves.  Each
train's progress is shown in the "Train Status Slideout".

1 Running the boxmove trains

The [Run Boxmove Trains] menu button and the
{../lib/FreightCarForwarder2/runboxmoves.gif} toolbar button run all of the box
move trains in the operating session.  Each train's progress is shown
in the "Train Status Slideout".

1 Running a single train

The [Run Trains One At A Time] menu button and the
{../lib/FreightCarForwarder2/runonetrain.gif} toolbar button run a
single train, selected with the <SelectATrainDialog>. The train's
progress is shown in the "Train Status Slideout".


1 Openning the printer

The [Open Printer] menu button and the
{../lib/Common/print.gif} toolbar button open the printer
output file, using the <OpenPrinterDialog>. The status of the printer
output, open or closed, is shown with the printer status indicator.

1 Closing the printer

The [Close Printer] menu button and the
{../lib/FreightCarForwarder2/closeprint.gif} toolbar button close the
printer.The status of the printer output, open or closed, is shown with
the printer status indicator.

1 Printing yard and switch lists

The [Print Yard Lists, etc.] menu button and the
{../lib/FreightCarForwarder2/yardprint.gif} toolbar button print the
yard and switch lists.

1 Showing cars on the screen

The [Show Cars On Screen] menu button and the
{../lib/FreightCarForwarder2/showcars.gif} toolbar button pops up a
menu of classes of cars to show.

1 Printing Reports

The [Reports Menu] menu button and the
{../lib/FreightCarForwarder2/reports.gif} toolbar button pops up a menu
of possible reports.

1 Reseting Industry Statistics

The [Reset Industry Statistics] menu button and the
{../lib/FreightCarForwarder2/resetIndustries.gif} toolbar button resets
the industry statistics.

1 Quiting the application

The [Quit -- Exit NOW] menu button and the
{../lib/Common/close.gif} toolbar button exit the program. A
confirmation dialog is popped up.


1 Files

The Freight Car Forwarder uses a collection of eight data files  (see
<File Formats>):

  1. <System File> This is the [master] file.  It contains the
(relative) paths to the remaining seven files, along with the name of
the railroad system, its divisions, and its stations.

  2. <Industry File> This file holds the description of the
industries, both on-line, which are actually modeled on the layout and
off- line, which are imaginary industries not actually on the layout,
but might be modeled as implied by staging yards or by interchange with
other layouts or imaginary off-line railroads.

  3. <Trains File> This file holds the description of the trains used
to acutally move the cars about the layout.

  4. <Orders File> This file contains standing train orders and is
only used to add additional information to the printouts given to trail
operators.

  5. <Owners File> This file contains a mapping between owner initials
and owner names.  Used with various generated reports.

  6. <Car Types File> This file contains a mapping between car type
codes and full names and descriptions of car types.

  7. <Cars File> This is the file containing information about all of
the rolling stock on or off the layout.

  8. <Statistics File> This is the statistics file.  It is generated
by the program and contains statistical information about car and
industry utilization.



2 File Formats

Some general notes:

A comment it indicated by an appostrophe.  All characters from the
appostrophe to the end of the line are discarded when read.  The files
generally contain lines of comma separated fields, a format
designed for BASIC read statements -- the original program that this
program is based on was written in a version of BASIC and uses the same
file format.

  <System File>
  <Industry File>
  <Trains File>
  <Orders File>
  <Owners File>
  <Car Types File>
  <Cars File>
  <Statistics File>
  <Other data files>

3 System File

The first line of the system file is the name of the railroad system. 
This line is used in various banners and report headings.

The second line should be a blank line.

Then come the names of the remaining seven data files, one per line, in
this order: <Industry File>, <Trains File>, <Orders File>, 
<Owners File>, <Car Types File>, <Cars File>, and finally <Statistics File>. 

After the file names comes the division list.  This starts with a count
of the maximum number of divisions:

Divisions = Number

where Number is a positive non zero integer.

This is followed by division specifications, which is a list of 5 values
separacted by commas:

  Number,Symbol,Home,Area,Name

Where Number is the index of the division (between 1 and the max number
of divisions, inclusive), Symbol is an alphanumeric character (a-z, 0-9,
A-Z), Home is the number of the home yard for this division (must be a
yard specificed in the <Industry File>), area is an Area symbol, and
Name is the name of the division.

A line containing a -1 terminates the list of divisions.

Then comes the stations (cities), starting with a line defining the maximum
number of stations:

Stations = Number

where Number is a positive non zero integer.

This is followed by station specifications, which is a list of 4 values
separacted by commas:

  Number,Name,Division,Comment

Where Number is the index of the station (between 1 and the max number
of stations, inclusive), Name is the name of the city, Division is the
division index, and Comment is commentary about the station. 
City/Station number one is used for the workbench.

A line containing a -1 terminates the list of stations.

3 Industry File

The industry file contains industries and yards.  The file starts with a
line specifying the maximum number of industries:

Industries = Number

where Number is a positive non zero integer.

Followed by a line for each industry or yard.  Industry number 0 is
used for the repair yard, which is for cars not in service.  Each
industry's line contains these fields:

  ID,T,STA,NAME,TLEN,ALEN,P,R,H,MIR,C,W,DCL,MAX,LD,EM

Where:

       ID    Numeric identifier
       T     Types are [Y]ard or [I]ndustry or [O]ffline
       STA   Station Identifier
       NAME  User friendly place name
       TLEN  Actual or virtual track length
       ALEN  Assignable length
       P     Priority for car assignments

             If YARD or STAGE, P is

                 n     number of yardlists to print of type A P D

       R     Reloads cars [Y]es or [N]o
       H     Hazard class for outbound cargo
       MIR   Mirror industry or 0 if none
       C     Maximum clearance plate
       W     Maximum weight class
       DCL   Destination Control List of divisions

             If YARD or STAGE, DCL can contain

                 A     alphabetical listing of cars in yard is permitted
                 P     pickup listing of cars in yard is permitted
                 D     dropoff listing of cars in yard is permitted

       MAX   Maximum allowed car length
       LD    Loaded car types accepted
       EM    Empty car types accepted

The industry listing is terminated by a line containing a -1.

3 Trains File

The trains file contains the trains used to move the cars.  The file
starts with a line specifying the maximum number of trains:

Trains = Number

where Number is a positive non zero integer.

Followed by a record for each train (a newline is acceptable alternitive
to a comma):

Number,Type,Shift,Done,Name,Maxcars, Divisions, Stops
	filler,Onduty,Print,Maxclear, Maxweight, Types,  Maxlen, Description

Where Number is the train number, Type is [M]anifest; [B]oxmove;
[W]ayfreight; or [P]assenger, Shift is 1; 2; or 3, Done is [Y]es or
[N]o, Name is the train name, Maxcars is the maximum number of cars,
Divisions is a set of division symbols or a wildcard (*),Stops is a
space separated list of stations (Boxmove and Wayfrieghts) or industries
(Manifests), filler is an unused slot (use 0), Onduty is the time on
duty (the train's departure time) in the format HHMM, Print is [P]rint
or [N]oprint, Maxclear is the maximum clearance number, Maxweight is the
maximum weight number, Types is a set of car types this train can carry,
Maxlen is the maximum train length in feet, and Description is a textual
description of the train.

The train listing is terminated by a line containing a -1.

3 Orders File

This file contains lines with pairs:

Name,Order

where Name is the name of a train amd Order is a quoted string
containing the order.

3 Owners File

This file starts with a count of owners and then lines with with
triples:

Initials,Name,Comment

where Initials are the three letter initials of an owner, Name is the
full name of the owner, and Comment is some descriptive text.

3 Car Types File

This is a file with exactly 91 records.  Each record contains:

Car Type Code,Car Type Group,Description,pad,Comment

where Car Type Code is one of 91 printable characters, Car Type Group
is a single character, Description is a 16 character brief description,
pad is 0, and Comment is some descriptive text.

After the car types is the Car type groupings, which map groups of car
types into groups using the second single character, with lines
containing these fields:

Car Type Group,Description,Comment

where Car Type Group is a single character, Description is a 16
character brief description, and Comment is some descriptive text.

3 Cars File

The cars file starts with three numbers, one per line:

Total shifts
Current shift
Max car count

The first number is the total number of shifts, the second is the
current shift number (1, 2, or 3), and the third number is the maximum
number of cars in the file.

The remainder of the file is car records. This file must be kept in
[alphabetical order]! Each record contains:

Type,Marks,Number,Home,CarLen,ClearPlate,CarWeight,EmptyWt,LoadLimit,Loaded,Mirror?,Fixed?,Owner,Done,Last,Moves,Loc,Dest,NTrips,NAssigns

Where Type is from car types file, Marks is the railroad reporting marks
(9 characters max), Number is the car number (8 characters max), Home is
car home division (from system file), CarLen is extreme car length,
ClearPlate is the clearance plate (from plate file), CarWeight is car
weight class (from weight file), EmptyWt is light weight in tons,
LoadLimit is load limit in tons, Loaded is [L]loaded or [E]mpty, Mirror?
is ok to mirror [Y]es or [N]o, Fixed? is fixed route [Y]es or [N]o,
Owner is car owner's 3 character initals (from owners file), Done is car
is done moving for this session [Y]es or [N]o, Last is last train to
handle the car from trains file,Moves is actual movements this
session,Loc is car's present location from industry file, Dest car's
destination from industry file, NTrips is number of car trips, and
NAssigns is number of car assignments.

3 Statistics File

The statistics is a file generated as an output and should not be hand
edited.  This file has two formats, V1 and V2.  V1 is the original
format used by the original BASIC program.  V2 is an improved version
that avoids getting the fields jammed together due to numerical overflow
(result numbers too large for the field sizes).

The first line of either format contains the statistics period number. 
If in the new format (V2), this number is followed by a comma.

The rest of file file contains lines of four numbers, either space
separated (V1) or comma separated (V2): industry index, car count, car
length, and statistics len.

3 Other data files

There are some additional data files, which are not actually loaded into
the system.  These are the plate, weight, and hazzard files.  These are
just informational files that are used to map clearance plate, weight
class, and hazzard levels of cars.




