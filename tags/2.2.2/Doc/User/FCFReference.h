// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:33:54 2014
//  Last Modified : <170727.1045>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2014 Deepwoods Software.
// 
//  All Rights Reserved.
// 
// This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
// reproduced,  translated,  or  reduced to any  electronic  medium or machine
// readable form without prior written consent from Deepwoods Software.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __FCFREFERENCE_H
#define __FCFREFERENCE_H

/** @page fcf_Reference Freight Car Forwarder (V2) Reference
 * The Freight Car Forwarder (V2) is a hybrid program, consisting of a
 * Tcl/Tk GUI on top of a C++ class library.  The GUI provides the user
 * interface to the algorithms and data structures contained in the C++
 * class library. The program is based on Tim O'Connor's Freight Car Forwarder
 * originally written in QBASIC.  I first ported the program to a pure Tcl/Tk
 * application.  Then for better performance, I recoded the low-level guts 
 * (mostly heavy data indexing logic) to a C++ class library, using the STL to 
 * implement the various aggregate collections of objects, retaining Tcl/Tk 
 * for the GUI.
 * 
 * @section fcf_ref_cli Command Line Usage
 * 
 * The name of the system file to load can be specified on the command
 * line. See Section @ref fcf_ref_loadsystem for more information.
 * 
 * @section fcf_ref_maingui Layout of the Main GUI
 * 
 * The main GUI window, shown below,
 * @addindex "Freight Car Forwarder, main GUI"
 * @image latex FCFMain.png "The main GUI screen of the Freight Car Forwarder (V2) Program" width=5in
 * @image html  FCFMainSmall.png
 * contains a menu bar, a toolbar, 
 * @image latex FCFMainToolbar.png "The Toolbar of the Freight Car Forwarder (V2) Program" width=5in
 * @image html  FCFMainToolbarSmall.png
 * a text display area, and a button menu.
 * @n
 * @image latex FCFMainButtonMenu.png "The Button Menu of the Freight Car Forwarder (V2) Program"
 * @image html  FCFMainButtonMenu.png
 * @n
 * There is also a work in progress message area, a  general status area, 
 * a progress meter, and several indicators.
 * @n
 * @image latex FCFMainIndicators.png "The Indicators of the Freight Car Forwarder (V2) Program"
 * @image html  FCFMainIndicators.png
 * 
 * The main GUI also has three "slide out" frames, one for showing train
 * status when trains are run, one for viewing a car's information, and
 * one for editing a car's information. Each slide out has a corresponding
 * indicator. 
 * 
 * @section fcf_ref_loadsystem Opening and loading a system file.
 * The @c File->Open... menu button and the
 * @image latex FCFLoadTool.png
 * @htmlonly
 * <img src="FCFLoadTool.png" alt="Load toolbar button">
 * @endhtmlonly
 * toolbar button pop-up a file selection dialog to select a system file to 
 * load. Once this file is successfully loaded, the name of the file, the name 
 * of the system, the current session and shift number, plus a count of  
 * divisions, stations, industries, cars, and trains is displayed in the main 
 * GUI's text area. Also all of the buttons are made active.  The name of the 
 * system file can be specified on the command line and the named system file 
 * will be loaded when the program starts.
 * 
 * @section fcf_ref_loadreload  Loading and reloading the cars file.
 * 
 * The @c Load Cars File menu button and the
 * @image latex FCFLoadCarsTool.png
 * @htmlonly
 * <img src="FCFLoadCarsTool.png" alt="Load Cars toolbar button">
 * @endhtmlonly
 * toolbar button load (or reload) the cars file.
 * 
 * @section fcf_ref_savingcars Saving the cars file.
 * 
 * The @c Save @c Cars @c File menu button and the 
 * @image latex FCFSaveCarsTool.png
 * @htmlonly
 * <img src="FCFSaveCarsTool.png" alt="Save Cars toolbar button">
 * @endhtmlonly
 * @addindex "cars, saving"
 * toolbar button save the cars and statistics files. This is something you
 * need to do after you have simulated a session, by running the car
 * assignment procedure and then run the trains in your session.  This
 * saves the state for the next time you run the Freight Car Forwarder.
 * 
 * @section fcf_ref_managingtrains Managing trains and printing
 * 
 * The @c Manage trains/printing menu button and the 
 * @image latex FCFManageTrainsTool.png
 * @htmlonly
 * <img src="FCFManageTrainsTool.png" alt="Manage Trains toolbar button">
 * @endhtmlonly
 * toolbar button pop-up the train/printing management menu.  This menu 
 * provides a set of functions relating to what trains are printed and can 
 * also  print a dispatcher report and generate lists of various sorts of 
 * trains.  The menu is shown below.
 * 
 * @image latex FCFManageTrainsMenu.png "Train/Printing Management Menu."
 * @image html  FCFManageTrainsMenu.png
 * 
 * @subsection fcf_ref_controllingyardlists Controlling Yard Lists
 * 
 * The @c Control @c Yard @c Lists menu item (y key) pops up a dialog, shown
 * @addindex "Yard Lists, printing"
 * below, to control whether to print 0, 1, or 2 alphabetical lists and 
 * whether to print 0, 1, or 2 train lists.
 * 
 * @image latex FCFControlYardLDialog.png "Control Yard Lists Dialog"
 * @image html  FCFControlYardLDialog.png
 * 
 * 
 * @subsection fcf_ref_enablingprint Enabling printing for all trains
 * 
 * The @c Print @c All @c Trains menu item (p key) turns on printing for all
 * trains. 
 * 
 * @subsection fcf_ref_disablingprint Disabling printing for all trains
 * 
 * The @c Print @c No @c Trains menu item (n key) turns off printing for all
 * trains.
 * 
 * @subsection fcf_ref_printdispater Printing a dispatcher report
 * 
 * The @c Print @c Dispatcher @c Report menu item (d key) enables the
 * printing of a dispatcher report.
 * 
 * @subsection fcf_ref_listinglocal Listing local trains for this shift
 * 
 * The @c List @c Locals @c This @c Shift menu item (l key) lists all locals 
 * for this shift.
 * 
 * @subsection fcf_ref_listingmani Listing manifests for this shift
 * 
 * The @c List @c Manifests @c This @c Shift menu item (m key) lists manifest
 * freights for this shift.
 * 
 * @subsection fcf_ref_listingall Listing all trains for all shifts
 * 
 * The @c List @c All @c Trains @c All @c Shifts (? key) Lists all trains.
 * 
 * @subsection fcf_ref_managingone Managing one train
 * 
 * The @c Manage @c One @c Train menu item (1 key) pops up a dialog, shown
 * below, to enable or disable printing of a single train, as well as 
 * setting the train's maximum length and setting which shift the train will 
 * be run.  The train is selected with the "Select Train Dialog", described 
 * in Section @ref fcf_ref_selecttraindialog.
 * 
 * @n
 * @image latex FCFManage1TrainDialog.png "Train Management Dialog"
 * @image html  FCFManage1TrainDialog.png
 * 
 * @section fcf_ref_viewingacar Viewing a car's information
 * 
 * The @c View @c Car @c Information menu button and the
 * @image latex FCFViewCarTool.png
 * @htmlonly
 * <img src="FCFViewCarTool.png" alt="View Car toolbar button">
 * @endhtmlonly
 * toolbar button display the information about a single car.  The information 
 * is displayed on the view car "slide out", shown below. The car is 
 * selected with the "Search For Cars Dialog", described in Section
 * @ref fcf_ref_searchcarsdialog. 
 * 
 * @image latex FCFViewCarSlideout.png "View Car Information Slideout"
 * @image html  FCFViewCarSlideout.png
 * 
 * @section fcf_ref_editingacar Editing a car's information
 * 
 * The @c Edit @c Car @c Information menu button and the
 * @image latex FCFEditCarTool.png
 * @htmlonly
 * <img src="FCFEditCarTool.png" alt="Edit Car toolbar button">
 * @endhtmlonly
 * toolbar button display the information about a single car and allow for 
 * editing this information. The information is displayed on the edit car 
 * "slide out", shown below. The car is selected with the "Search For Cars 
 * Dialog", described in Section @ref fcf_ref_searchcarsdialog. 
 * 
 * @n
 * @image latex FCFEditCarSlideout.png "Edit Car Information Slideout"
 * @image html  FCFEditCarSlideout.png
 * 
 * @section fcf_ref_addingacar Adding a new car
 * 
 * The @c Add a New Car menu button and the
 * @image latex FCFAddCarTool.png
 * @htmlonly
 * <img src="FCFAddCarTool.png" alt="Add Car toolbar button">
 * @endhtmlonly
 * toolbar button provide for adding a new car.  The edit car "slide out", 
 * shown above, is displayed and the information about the new car can be 
 * filled in and the car added.
 * 
 * @section fcf_ref_deletingacar Deleting an existing car
 * 
 * The @c Delete @c An @c Existing @c Car menu button and the
 * @image latex FCFDeleteCarTool.png
 * @htmlonly
 * <img src="FCFDeleteCarTool.png" alt="Delete Car toolbar button">
 * @endhtmlonly
 * toolbar button provide for deleting an existing car.  The car is selected 
 * with the "Search For Cars Dialog", described in Section 
 * @ref fcf_ref_searchcarsdialog and the car's information is displayed in the 
 * view car "slide out", shown above. Actual removal can then be confirmed.
 * 
 * @section fcf_ref_showingcarswithout Showing cars without assignments
 * 
 * The @c Show @c Unassigned @c Cars menu button and the
 * @image latex FCFShowUACarsTool.png
 * @htmlonly
 * <img src="FCFShowUACarsTool.png" alt="Show Unassigned Cars toolbar button">
 * @endhtmlonly
 * toolbar button display unassigned cars in the text window.
 * 
 * @section fcf_ref_runningcars Running the car assignment procedure
 * 
 * The @c Run @c Car @c Assignments menu button and the
 * @image latex FCFRunCarATool.png
 * @htmlonly
 * <img src="FCFRunCarATool.png" alt="Run Car Assignments toolbar button">
 * @endhtmlonly
 * toolbar button run the car assignment procedure.  This procedure attempts 
 * to give as many unassigned cars assignments, that is possible destinations.
 * Considerations taken into account are the type of car, whether it is
 * loaded or not, industries with available trackage to accommodate the car,
 * and so on.  The list of cars is scanned twice and the progress of the
 * procedure is displayed in the text area.
 * 
 * @section fcf_ref_runningevery Running every train in the operating session
 * 
 * The @c Run @c All @c Trains @c in @c Operating @c Session menu button and 
 * the
 * @image latex FCFRunAllTrTool.png
 * @htmlonly
 * <img src="FCFRunAllTrTool.png" alt="Run All Trains toolbar button">
 * @endhtmlonly
 * toolbar button run all trains in the operating session, except the end of 
 * session box moves.  Each train's progress is shown in the "Train Status 
 * Slideout", shown below.
 * 
 * @n
 * @image latex FCFTrainStatusSlideout.png "Train Status Slideout"
 * @image html  FCFTrainStatusSlideout.png
 * 
 * @section fcf_ref_runningbox Running the box move trains
 * 
 * The @c Run @c Boxmove @c Trains menu button and the
 * @image latex FCFRunBTrTool.png
 * @htmlonly
 * <img src="FCFRunBTrTool.png" alt="Run Boxmove toolbar button">
 * @endhtmlonly
 * toolbar button run all of the box move trains in the operating session.  
 * Each train's progress is shown in the "Train Status Slideout", shown 
 * above.
 * 
 * @section fcf_ref_runningsingle Running a single train
 * 
 * The @c Run @c Trains @c One @c At @c A @c Time menu button and the
 * @image latex FCFRun1TrTool.png
 * @htmlonly
 * <img src="FCFRun1TrTool.png" alt="Run One Train toolbar button">
 * @endhtmlonly
 * toolbar button run a single train, selected with the "Select Train 
 * Dialog", described in Section @ref fcf_ref_selecttraindialog. The train's 
 * progress is shown in the "Train Status Slideout", shown above.
 * 
 * @section fcf_ref_openprinter Opening a Printer
 * 
 * The @c Open @c Printer menu button and the
 * @image latex FCFOpenPrinterTool.png
 * @htmlonly
 * <img src="FCFOpenPrinterTool.png" alt="Open Printer toolbar button">
 * @endhtmlonly
 * toolbar button open the printer output file, using the "Open Printer 
 * Dialog", shown below. The status of the printer output, open or closed, 
 * is shown with the printer status indication.
 * @image latex FCFPrinterInd.png
 * @htmlonly
 * <img src="FCFPrinterInd.png" alt="Printer status indication">
 * @endhtmlonly
 * 
 * @n
 * @image latex FCFOpenPrinterDialog.png "Open Printer Dialog"
 * @image html  FCFOpenPrinterDialog.png
 * 
 * @section fcf_ref_closingprinter Closing the printer
 * 
 * The @c Close @c Printer menu button and the
 * @image latex FCFClosePrinterTool.png
 * @htmlonly
 * <img src="FCFClosePrinterTool.png" alt="Close Printer toolbar button">
 * @endhtmlonly
 * toolbar button close the printer.The status of the printer output, open or 
 * closed, is shown with the printer status indication.
 * @image latex FCFPrinterInd.png
 * @htmlonly
 * <img src="FCFPrinterInd.png" alt="Printer status indication">
 * @endhtmlonly
 * 
 * @section fcf_ref_printyard Printing yard and switch lists
 * 
 * The @c Print @c Yard @c Lists, etc. menu button and the
 * @addindex "Yard Lists, printing"
 * @image latex FCFPrintYardTool.png
 * @htmlonly
 * <img src="FCFPrintYardTool.png" alt="Print Yard Lists toolbar button">
 * @endhtmlonly
 * toolbar button print the yard and switch lists.
 * 
 * @section fcf_ref_showingcars Showing cars on the screen
 * 
 * The @c Show @c Cars @c On @c Screen menu button and the
 * @image latex FCFShowCarsTool.png
 * @htmlonly
 * <img src="FCFShowCarsTool.png" alt="Show Cars On Screen toolbar button">
 * @endhtmlonly
 * toolbar button pops up a menu, shown below, of classes of cars to show.
 * 
 * @n
 * @image latex FCFShowCarsMenu.png "Show Cars Menu"
 * @image html  FCFShowCarsMenu.png
 * 
 * @section fcf_ref_printingreports Printing Reports
 * 
 * The @c Reports @c Menu menu button and the
 * @addindex "Reports, printing"
 * @image latex FCFReportsTool.png
 * @htmlonly
 * <img src="FCFReportsTool.png" alt="Reports Menu toolbar button">
 * @endhtmlonly
 * toolbar button pops up a menu, shown below, of possible reports.
 * 
 * @n
 * @image latex FCFReportsMenu.png "Reports Menu"
 * @image html  FCFReportsMenu.png
 * 
 * @section fcf_ref_resetindus Resetting Industry Statistics
 * 
 * The @c Reset @c Industry @c Statistics menu button and the
 * @image latex FCFResetStatsTool.png
 * @htmlonly
 * <img src="FCFResetStatsTool.png" alt="Reset Industry Statistics toolbar button">
 * @endhtmlonly
 * toolbar button resets the industry statistics.
 * 
 * @section fcf_ref_Quiting Quiting the application
 * 
 * The @c Quit -- @c Exit @c NOW menu button and the
 * @image latex FCFCloseTool.png
 * @htmlonly
 * <img src="FCFCloseTool.png" alt="Quit toolbar button">
 * @endhtmlonly
 * toolbar button exit the program. A confirmation dialog is popped up.
 * 
 * @section fcf_ref_gendialogs General Dialogs
 * @subsection fcf_ref_controlyardlists Control Yard Lists Dialog
 * @subsection fcf_ref_enterowner Enter Owner Initials Dialog
 * @subsection fcf_ref_selecttraindialog Select A Train Dialog
 * 
 * The Select a Train Dialog is used to select a train (to manage, run, or
 * print). The @c Filter button uses the Train Name Pattern to match
 * against train names to select a subset of trains to select from and can
 * contain these special sequences:  
 *   - @c * Matches any sequence of zero or more characters in the
 *     train name.
 *   - @c ? Matches any single character in the train name. 
 *   - @c [chars] Matches any character in the set given by chars. 
 *   - If a sequence of the form @c x-y appears in chars, then any
 *     character between @c x and  @c y,  inclusive,  will match.
 *     Characters are matched in a case insensitive way. 
 *   - @c \\x matches the single character @c x. This provides a 
 *     way of avoiding the special interpretation of the characters
 *     @c *?[]\\ in the pattern.
 * 
 * @image latex FCFSelectATrainDialog.png "Select A Train Dialog"
 * @image html  FCFSelectATrainDialog.png
 * 
 * @subsection fcf_ref_manage1traindialog Manage One Train Dialog
 * @subsection fcf_ref_openprinterdialog Open Printer Dialog
 * @subsection fcf_ref_searchcarsdialog Search For Cars Dialog
 * 
 * The Search For Cars Dialog is used to select a car (to view, edit, or
 * delete). The @c Filter button selects a  subset of cars based on the
 * trailing car number digits.
 * 
 * @image latex FCFSelectACarDialog.png "Search For Cars Dialog"
 * @image html  FCFSelectACarDialog.png
 * 
 * @subsection fcf_ref_seladiv Select A Division Dialog
 * @subsection fcf_ref_selanindus Select An Industry Dialog
 * @subsection fcf_ref_selastat Select A Station Dialog
 * @subsection fcf_ref_selcartype Select Car Type
 * @section fcf_ref_Files Data files
 * 
 * The Freight Car Forwarder uses a collection of eight data files:
 * 
 *   -# @c System @c File This is the @b master file.  It contains the
 *      (relative) paths to the remaining seven files, along with the name of
 *      the railroad system, its divisions, and its stations.
 *   -# @c Industry @c File This file holds the description of the industries, 
 *      both on-line, which are actually modeled on the layout and off-line, 
 *      which are imaginary industries not actually on the layout, but might 
 *      be modeled as implied by staging yards or by interchange with other 
 *      layouts or imaginary off-line railroads.
 *   -# @c Trains @c File This file holds the description of the trains used
 *      to actually move the cars about the layout.
 *   -# @c Orders @c File This file contains standing train orders and is
 *      only used to add additional information to the printouts given to train
 *      operators.
 *   -# @c Owners @c File This file contains a mapping between owner initials
 *      and owner names.  Used with various generated reports.
 *   -# @c Car @c Types @c File This file contains a mapping between car type
 *      codes and full names and descriptions of car types.
 *   -# @c Cars @c File This is the file containing information about all of
 *      the rolling stock on or off the layout.
 *   -# @c Statistics @c File This is the statistics file.  It is generated
 *      by the program and contains statistical information about car and
 *      industry utilization.
 * 
 * @subsection fcf_ref_FileFormats Data File Formats
 * 
 * Some general notes:
 * 
 * A comment it indicated by an apostrophe.  All characters from the
 * apostrophe to the end of the line are discarded when read.  The files
 * generally contain lines of comma separated fields, a format
 * designed for BASIC read statements--the original program that this
 * program is based on was written in a version of BASIC and uses the same
 * file format.
 * 
 * @subsubsection fcf_ref_SystemFile System File
 * 
 * The first line of the system file is the name of the railroad system. 
 * This line is used in various banners and report headings.
 * 
 * The second line should be a blank line.
 * 
 * Then come the names of the remaining seven data files, one per line, in
 * this order: @c Industry @c File, @c Trains @c File, @c Orders @c File, 
 * @c Owners @c File, @c Car @c Types @c File, @c Cars @c File, and finally 
 * @c Statistics @c File. 
 * 
 * After the file names comes the division list.  This starts with a count
 * of the maximum number of divisions:
 * 
 * @code
 * Divisions = Number
 * @endcode
 * 
 * where Number is a positive non zero integer.
 * 
 * This is followed by division specifications, which is a list of 5 values
 * separated by commas:
 * 
 * @code
 * Number,Symbol,Home,Area,Name
 * @endcode
 * 
 * Where Number is the index of the division (between 1 and the max number
 * of divisions, inclusive), Symbol is an alphanumeric character (a-z, 0-9,
 * A-Z), Home is the number of the home yard for this division (must be a
 * yard specified in the @c Industry @c File), area is an Area symbol, and
 * Name is the name of the division.
 * 
 * A line containing a -1 terminates the list of divisions.
 * 
 * Then comes the stations (cities), starting with a line defining the maximum
 * number of stations:
 * 
 * @code
 * Stations = Number
 * @endcode
 * 
 * where Number is a positive non zero integer.
 * 
 * This is followed by station specifications, which is a list of 4 values
 * separated by commas:
 * 
 * @code
 * Number,Name,Division,Comment
 * @endcode
 * 
 * Where Number is the index of the station (between 1 and the max number
 * of stations, inclusive), Name is the name of the city, Division is the
 * division index, and Comment is commentary about the station. 
 * City/Station number one is used for the workbench.
 * 
 * A line containing a -1 terminates the list of stations.
 * 
 * @subsubsection fcf_ref_IndustryFile Industry File
 * 
 * The industry file contains industries and yards.  The file starts with a
 * line specifying the maximum number of industries:
 * 
 * @code
 * Industries = Number
 * @endcode
 * 
 * where Number is a positive non zero integer.
 * 
 * Followed by a line for each industry or yard.  Industry number 0 is
 * used for the repair yard, which is for cars not in service.  Each
 * industry's line contains these fields:
 * 
 * @code
 * ID,T,STA,NAME,TLEN,ALEN,P,R,H,MIR,C,W,DCL,MAX,LD,EM
 * @endcode
 * 
 * Where:
 * 
 * <dl>
 * <dt>ID</dt><dd>Numeric identifier.</dd>
 * <dt>T</dt><dd>Types are @b Y for yard or @b I for industry or @b O for 
 *               offline.</dd>
 * <dt>STA</dt><dd>Station Identifier.</dd>
 * <dt>NAME</dt><dd>User friendly place name.</dd>
 * <dt>TLEN</dt><dd>Actual or virtual track length.</dd>
 * <dt>ALEN</dt><dd>Assignable length.</dd>
 * <dt>P</dt><dd>Priority for car assignments. If @b YARD or @b STAGE, 
 *               @b P is @f$n@f$, the number of yard lists to print of type 
 *               @c A, @c P, or @c D.</dd>
 * <dt>R</dt><dd>Reloads cars @b Y for yes or @b N for no.</dd>
 * <dt>H</dt><dd>Hazard class for outbound cargo.</dd>
 * <dt>MIR</dt><dd>Mirror industry or 0 if none.</dd>
 * <dt>C</dt><dd>Maximum clearance plate.</dd>
 * <dt>W</dt><dd>Maximum weight class.</dd>
 * <dt>DCL</dt><dd>Destination Control List of divisions. If @b YARD or 
 *                 @b STAGE, DCL can contain:
 *    <dl>
 *    <dt>A</dt><dd>Alphabetical listing of cars in yard is permitted.</dd>
 *    <dt>P</dt><dd>Pickup listing of cars in yard is permitted.</dd>
 *    <dt>D</dt><dd>Dropoff listing of cars in yard is permitted.</dd>
 *    </dl></dd>
 * <dt>MAX</dt><dd>Maximum allowed car length.</dd>
 * <dt>LD</dt><dd>Loaded car types accepted.</dd>
 * <dt>EM</dt><dd>Empty car types accepted.</dd>
 * </dl>
 * 
 * The industry listing is terminated by a line containing a -1.
 * 
 * @subsubsection fcf_ref_TrainsFile Trains File
 * 
 * The trains file contains the trains used to move the cars.  The file
 * starts with a line specifying the maximum number of trains:
 * 
 * @code
 * Trains = Number
 * @endcode
 * 
 * where Number is a positive non zero integer.
 * 
 * Followed by a record for each train (a newline is acceptable alternative
 * to a comma):
 * 
 * @code
 * Number,Type,Shift,Done,Name,Maxcars, Divisions, Stops
 *	filler,Onduty,Print,Maxclear, Maxweight, Types,  Maxlen, 
 *      Description
 * @endcode
 * 
 * Where Number is the train number, Type is @b M for manifest;
 * @b B for boxmove; @b W for wayfreight; or @b P for passenger, Shift is
 * 1; 2; or 3, Done is @b Y for yes or @b N for no, Name is the train
 * name, Maxcars is the maximum number of cars, Divisions is a set of
 * division symbols or a wildcard (@c *),Stops is a space separated
 * list of stations (Boxmove and Wayfrieghts) or industries (Manifests),
 * filler is an unused slot (use 0), Onduty is the time on duty (the
 * train's departure time) in the format HHMM, Print is @b P for print or
 * @b N for noprint, Maxclear is the maximum clearance number, Maxweight
 * is the maximum weight number, Types is a set of car types this train
 * can carry, Maxlen is the maximum train length in feet, and Description
 * is a textual description of the train.
 * 
 * The train listing is terminated by a line containing a -1.
 * 
 * @subsubsection fcf_ref_OrdersFile Orders File
 * 
 * This file contains lines with pairs:
 * 
 * @code
 * Name,Order
 * @endcode
 * 
 * where Name is the name of a train and Order is a quoted string
 * containing the order.
 * 
 * @subsubsection fcf_ref_OwnersFile Owners File
 * 
 * This file starts with a count of owners and then lines with with
 * triples:
 * 
 * @code
 * Initials,Name,Comment
 * @endcode
 * 
 * where Initials are the three letter initials of an owner, Name is the
 * full name of the owner, and Comment is some descriptive text.
 * 
 * @subsubsection fcf_ref_CarTypesFile Car Types File
 * 
 * This is a file with exactly 91 records.  Each record contains:
 * 
 * @code
 * Car Type Code,Car Type Group,Description,pad,Comment
 * @endcode
 * 
 * where Car Type Code is one of 91 printable characters, Car Type Group
 * is a single character, Description is a 16 character brief description,
 * pad is 0, and Comment is some descriptive text.
 * 
 * After the car types is the Car type groupings, which map groups of car
 * types into groups using the second single character, with lines
 * containing these fields:
 * 
 * @code
 * Car Type Group,Description,Comment
 * @endcode
 * 
 * where Car Type Group is a single character, Description is a 16
 * character brief description, and Comment is some descriptive text.
 * 
 * @subsubsection fcf_ref_CarsFile Cars File
 * 
 * The cars file starts with three numbers, one per line:
 * 
 * @code
 * Total shifts
 * Current shift
 * Max car count
 * @endcode
 * 
 * The first number is the total number of shifts, the second is the
 * current shift number (1, 2, or 3), and the third number is the maximum
 * number of cars in the file.
 * 
 * The remainder of the file is car records. This file must be kept in
 * @b alphabetical @b order! Each record contains:
 * 
 * @code
 * Type,Marks,Number,Home,CarLen,ClearPlate,CarWeight,EmptyWt,
 * 	LoadLimit,Loaded,Mirror?,Fixed?,Owner,Done,Last,Moves,Loc,
 * 	Dest,NTrips,NAssigns
 * @endcode
 * 
 * Where Type is from car types file, Marks is the railroad reporting
 * marks (9 characters max), Number is the car number (8 characters max),
 * Home is car home division (from system file), CarLen is extreme car
 * length, ClearPlate is the clearance plate (from plate file), CarWeight
 * is car weight class (from weight file), EmptyWt is light weight in
 * tons, LoadLimit is load limit in tons, Loaded is @b L for loaded or
 * @b E for empty, Mirror? is ok to mirror @b Y for yes or @b N for no,
 * Fixed? is fixed route @b Y for yes or @b N for no, Owner is car owner's
 * 3 character initials (from owners file), Done is car is done moving for
 * this session @b Y for yes or @b N for no, Last is last train to handle
 * the car from trains file,Moves is actual movements this session,Loc is
 * car's present location from industry file, Dest car's destination from
 * industry file, NTrips is number of car trips, and NAssigns is number of
 * car assignments.
 * 
 * @subsubsection fcf_ref_StatisticsFile Statistics File
 * 
 * The statistics is a file generated as an output and should not be hand
 * edited.  This file has two formats, V1 and V2.  V1 is the original
 * format used by the original BASIC program.  V2 is an improved version
 * that avoids getting the fields jammed together due to numerical overflow
 * (result numbers too large for the field sizes).
 * 
 * The first line of either format contains the statistics period number. 
 * If in the new format (V2), this number is followed by a comma.
 * 
 * The rest of file file contains lines of four numbers, either space
 * separated (V1) or comma separated (V2): industry index, car count, car
 * length, and statistics length.
 * 
 * @subsubsection fcf_ref_Otherdatafiles Other data files
 * 
 * There are some additional data files, which are not actually loaded into
 * the system.  These are the plate, weight, and hazard files.  These are
 * just informational files that are used to map clearance plate, weight
 * class, and hazard levels of cars.
 * 
 */


#endif // __FCFREFERENCE_H

