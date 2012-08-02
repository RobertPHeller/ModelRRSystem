0 Tutorial

The Freight Car Forwarder is a program designed to simulate freight car
traffic on your model railroad.  It does this by matching types of
freight cars with industries.  Specific types of freight cars are meant
to carry specific types of commidities and specific industries produce
or consume specific types of commidities.

The Freight Car Forwarder program uses a collection of data files, which
describe the system layout (system file), the industries (industry
file), the train that will move the cars (trains file), and the cars
themselves (the cars file).  There are some additional files, including
an owner's file and a car types file, as well as a file for statistics. 
All of these files are plain text files -- See <Files> and 
<File Formats> for more information on these files and their formats.

Table of contents:

  1 <Loading System Data>
  2 <Assigining Cars>
  3 <Running Trains>
  4 <Printing Yard Lists>
  5 <Generating Reports>
  6 <Other activities>

1 Loading System Data

The Freight Car Forwarder starts loading data by opening and reading
the system file, using either the file menu's Open... item or open file
button on the toolbar.  This file contains the path names of the other
files, which are assumed to be relative to the directory (folder) that
contains the system file.  All of the system data is loaded into a
large data structure, which is then used by the program to simulate car
movements. Only car data is altered by the Freight Car Forwarder and the only
files that ever get re-written are the cars and statistics files.  The
other data files are never altered by the Freight Car Forwarder.  These
file can be edited using a plain text editor, such as Notepad
(MS-Windows) or Emacs (UNIX), should this be needed, as industries or
trains are added or removed, etc.

2 Files

The Freight Car Forwarder uses a collection of eight data files:

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

1 Assigining Cars

  In order to move cars, the cars need to be "assigned", that is, they
need to have a destination set, either to be loaded (if empty) or
unloaded (is loaded).  The Car Assignment procedure performs this task.

1 Running Trains

  Once cars has been assigned, they need to be moved.  Cars are moved on
trains, and this is done with the run trains procedures.  There are
three of these procedures: Run All Trains in Operating Session, Run
Boxmoves, and Run One Train at a time.  The run trains procedures
simulate the actual movement of cars and determines which trains will
move which cars and in what order.  From this simulation, a set of yard
and switch lists can be generated and printed out for use during your
operating session.

1 Printing Yard Lists

  Once the trains have been run, yard and switch lists can be printed
out, using the print yard lists menu.

1 Generating Reports

  Various reports can also be generated and printed using the reports
menu. 

1 Other activities

  Other activities include adding, removing, and editing cars and
displaying various state information, such as assigned and unassigned
cars, car movement information, lists of trains, and lists of
industries, stations, and divisions.
