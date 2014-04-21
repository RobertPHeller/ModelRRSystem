// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu Apr 10 15:29:56 2014
//  Last Modified : <140421.1238>
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

#ifndef __PREFACE_H
#define __PREFACE_H

/** @mainpage Preface
 * This is the user manual for the Model Railroad system.  It is a ``work
 * in progress'' and I will be adding chapters as I write the various
 * self-contained ``main programs''.
 * @anchor toc
 * @htmlonly
 * <div class="contents">
 * <div class="textblock"><ol type="1">
 * <li><a class="el" href="Introduction.html">Introduction</a>
 * </li>
 * <li><a class="el" href="univtest.html">Universal Test Program Reference</a><ol type="1">
 * <li><a class="el" href="univtest.html#maingui">Main GUI Elements</a><ol type="1">
 * <li><a class="el" href="univtest.html#mainwindow">Main Window</a></li>
 * <li><a class="el" href="univtest.html#openport">Open New Port</a></li></ol></li>
 * <li><a class="el" href="univtest.html#tests">Tests</a><ol type="1">
 * <li><a class="el" href="univtest.html#testout">Test Output Card</a></li>
 * <li><a class="el" href="univtest.html#wraparound">Wraparound Test</a></li></ol></li></ol>
 * </li>
 * <li><a class="el" href="azatrax.html">Azatrax Test Programs Reference</a><ol type="1">
 * <li><a class="el" href="azatrax.html#mrdtest">MRD Test Program Reference</a><ol type="1">
 * <li><a class="el" href="azatrax.html#mrdtest_synopsis">Synopsis</a></li>
 * <li><a class="el" href="azatrax.html#mrdtest_gui">Main GUI Screen</a></li>
 * </ol></li>
 * <li><a class="el" href="azatrax.html#mrdsensorloop">MRD Sensor Loop Reference</a><ol type="1">
 * <li><a class="el" href="azatrax.html#mrdsensorloop_synopsis">Synopsis</a></li>
 * <li><a class="el" href="azatrax.html#mrdsensorloop_gui">Main GUI Screen</a></li>
 * </ol></li>
 * <li><a class="el" href="azatrax.html#sr4test">SR4 Test Program Reference</a><ol type="1">
 * <li><a class="el" href="azatrax.html#sr4test_synopsis">Synopsis</a></li>
 * <li><a class="el" href="azatrax.html#sr4test_gui">Main GUI Screen</a></li>
 * </ol></li>
 * <li><a class="el" href="azatrax.html#sl2test">SL2 Test Program Reference</a><ol type="1">
 * <li><a class="el" href="azatrax.html#sl2test_synopsis">Synopsis</a></li>
 * <li><a class="el" href="azatrax.html#sl2test_gui">Main GUI Screen</a></li>
 * </ol></li>
 * <li><a class="el" href="azatrax.html#azatraxdevicemap">Azatrax Device Map Reference</a><ol type="1">
 * <li><a class="el" href="azatrax.html#azatraxdevicemap_synopsis">Synopsis</a></li>
 * <li><a class="el" href="azatrax.html#azatraxdevicemap_gui">Main GUI Screen</a></li>
 * </ol></li>
 * </ol></li>
 * <li><a class="el" href="xpressnetthrot.html">XPressNet Throttle</a><ol type="1">
 * <li><a class="el" href="xpressnetthrot.html#xpressnetthrot_maingui">Main GUI</a></li>
 * <li><a class="el" href="xpressnetthrot.html#xpressnetthrot_progmode">Programming Mode</a></li>
 * <li><a class="el" href="xpressnetthrot.html#xpressnetthrot_openport">Open Port</a></li>
 * </ol></li>
 * <li><a class="el" href="genericthrot.html">Generic Throttle</a><ol type="1">
 * <li><a class="el" href="genericthrot.html#genericthrot_maingui">Main GUI</a></li>
 * <li><a class="el" href="genericthrot.html#genericthrot_progmode">Programming Mode</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_Tutorial.html">Time Table (V2) Tutorial</a><ol type="1">
 * <li><a class="el" href="timetable_Tutorial.html#timetable_tut_crenew">Creating a new time table</a><ol type="1">
 * <li><a class="el" href="timetable_Tutorial.html#timetable_tut_crestat">Creating stations</a></li>
 * <li><a class="el" href="timetable_Tutorial.html#timetable_tut_crecab">Creating cabs</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_Tutorial.html#timetable_tut_cretrain">Creating trains</a></li>
 * <li><a class="el" href="timetable_Tutorial.html#timetable_tut_print">Printing a time table</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_ref.html">Time Table (V2) Reference</a><ol type="1">
 * <li><a class="el" href="timetable_ref.html#timetable_ref_cli">Command Line Usage</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_maingui">Layout of the Main GUI</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_createnewtimetable">Creating a New Time Table</a><ol type="1">
 * <li><a class="el" href="timetable_ref.html#timetable_ref_CreateAllStationsDialog">Creating the station stops for a new time table</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_CreateAllCabsDialog">Create All Cabs Dialog</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_loadexistingtimetable">Loading an Exiting Time Table File</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_savingatimetablefile">Saving a Time Table File</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_addingtrains">Adding Trains</a><ol type="1">
 * <li><a class="el" href="timetable_ref.html#timetable_ref_CreateNewTrainDialog">Create New Train Dialog</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_DeletingTrains">Deleting Trains</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_LinkingUnlinkingDuplicate">Linking and Unlinking Duplicate Stations</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_AddingStationStorage">Adding Station Storage Tracks</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_AddingCabs">Adding Cabs</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_HandlingNotes">Handling Notes</a><ol type="1">
 * <li><a class="el" href="timetable_ref.html#timetable_ref_CreatingNewNotes">Creating New Notes and Editing Existing Notes</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_AddingRemovingNotes">Adding and Removing a Notes To Trains</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_PrintingTimeTable">Printing a Time Table</a><ol type="1">
 * <li><a class="el" href="timetable_ref.html#timetable_ref_PrintDialog">Print Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_PrintConfigurationDialog">Print Configuration Dialog</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_Exiting">Exiting From the Program</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_SelectOneTrainDialog">Select One Train Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_ViewMenu">The View Menu</a><ol type="1">
 * <li><a class="el" href="timetable_ref.html#timetable_ref_ViewingTrains">Trains</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_ViewingStations">Stations</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_ViewingNotes">Notes</a></li>
 * </ol></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_SystemConfiguration">System Configuration</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_AddCabDialog">Add Cab Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_AddRemoveNoteDialog">Add Remove Note Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_EditNoteDialog">Edit Note Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_EditSystemConfigurationDialog">Edit System Configuration</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_EditTrainDialog">Edit Train Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_SelectAStorageTrackName">Select A Storage Track Name</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_SelectOneNoteDialog">Select One Note Dialog</a></li>
 * <li><a class="el" href="timetable_ref.html#timetable_ref_SelectOneStationDialog">Select One Station Dialog</a></li>
 * </ol></li>
 * <li><a class="el" href="fcf_Tutorial.html">Freight Car Forwarder (V2) Tutorial</a><ol type="1">
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_LoadingSystemData">Loading System Data</a></li>
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_AssigningCars">Assigning Cars</a></li>
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_RunningTrains">Running Trains</a></li>
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_PrintingYardSwitchLists">Printing Yard and Switch Lists</a></li>
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_SavingData">Saving the updated car data</a></li>
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_GeneratingReports">Generating Reports</a></li>
 * <li><a class="el" href="fcf_Tutorial.html#fcf_tut_Other">Other activities</a></li>
 * </ol></li>
 * <li><a class="el" href="fcf_Reference.html">Freight Car Forwarder (V2) Reference</a><ol type="1">
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_cli">Command Line Usage</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_maingui">Layout of the Main GUI</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_loadsystem">Opening and loading a system file</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_loadreload">Loading and reloading the cars file</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_savingcars">Saving the cars file</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_managingtrains">Managing trains and printing</a><ol type="1">
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_controllingyardlists">Controlling Yard Lists</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_enablingprint">Enabling printing for all trains</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_disablingprint">Disabling printing for all trains</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_printdispater">Printing a dispatcher report</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_listinglocal">Listing local trains for this shift</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_listingmani">Listing manifests for this shift</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_listingall">Listing all trains for all shifts</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_managingone">Managing one train</a></li>
 * </ol></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_viewingacar">Viewing a car's information</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_editingacar">Editing a car's information</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_addingacar">Adding a new car</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_deletingacar">Deleting an existing car</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_showingcars">Showing cars without assignments</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_runningcars">Running the car assignment procedure</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_runningevery">Running every train in the operating session</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_runningbox">Running the box move trains</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_runningsingle">Running a single train</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_openprinter">Opening a Printer</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_closingprinter">Closing the printer</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_printyard">Printing yard and switch lists</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_showingcarswithout">Showing cars without assignments</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_printingreports">Printing Reports</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_resetindus">Resetting Industry Statistics</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_Quiting">Quiting the application</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_gendialogs">General Dialogs</a><ol type="1">
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_controlyardlists">Control Yard Lists Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_enterowner">Enter Owner Initials Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_selecttraindialog">Select A Train Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_manage1traindialog">Manage One Train Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_openprinterdialog">Open Printer Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_searchcarsdialog">Search For Cars Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_seladiv">Select A Division Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_selanindus">Select An Industry Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_selastat">Select A Station Dialog</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_selcartype">Select Car Type</a></li>
 * </ol></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_Files">Data files</a><ol type="1">
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_FileFormats">Data File Formats</a><ol type="1">
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_SystemFile">System File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_IndustryFile">Industry File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_TrainsFile">Trains File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_OrdersFile">Orders File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_OwnersFile">Owners File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_CarTypesFile">Car Types File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_CarsFile">Cars File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_StatisticsFile">Statistics File</a></li>
 * <li><a class="el" href="fcf_Reference.html#fcf_ref_Otherdatafiles">Other data files</a></li>
 * </ol></li>
 * </ol></li>
 * </ol></li>
 * <li><a class="el" href="rest_Reference.html">Resistor Program Reference</a>
 * </li>
 * <li><a class="el" href="locopull_Reference.html">LocoPull Program Reference</a><ol type="1">
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_BasisMathematics">Basis and Mathematics</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_GUI">The GUI</a><ol type="1">
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Scale">The Scale</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Locomotive">Locomotive Information</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Consist">Consist Information</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Zero-grade">Zero-grade capacity</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Grade">Grade information</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Curve">Curve information</a></li>
 * <li><a class="el" href="locopull_Reference.html#locopull_Reference_Capacity">Capacity and Grade plus Curve</a></li>
 * </ol></li>
 * </ol></li>
 * <li><a class="el" href="camera_1Reference.html">Camera Programs Reference</a>
 * </li>
 * <li><a class="el" href="dispatcher_Tutorial.html">Dispatcher Tutorial</a><ol type="1">
 * <li><a class="el" href="dispatcher_Tutorial.html#dispatcher_Tutorial_SimpleMode">A &quot;Simple Mode&quot; CTC Panel</a></li>
 * <li><a class="el" href="dispatcher_Tutorial.html#dispatcher_Tutorial_Advanced">A more advanced Example</a></li>
 * </ol></li>
 * <li><a class="el" href="dispatcher_Reference.html">Dispatcher Reference</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_MainGUI">Main GUI Screen</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_TrackworkNodeGraphs">Track work Node Graphs</a>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_LoadingLayout">Loading a Layout</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_FindingNodes">Finding Nodes</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_PrintingNodeGraphs">Printing Node Graphs</a></li>
 * </li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_creatingCTCPanels">Creating a new CTC Panel</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_OpeningCTCPanel">Opening an existing CTC Panel</a></li>
 * </ol></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_configopts">Configurable Options</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_CTCPanelWindows">CTC Panel Windows</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_MenuCTCPanel">Menu items available when editing a CTC Panel Window</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_FilemenuCTCPanel">File menu</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_EditmenuCTCPanel">Edit menu</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_ViewmenuCTCPanel">View menu</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_PanelmenuCTCPanel">Panel menu</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_CMrimenuCTCPanel">C/Mri menu</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_AztraxmenuCTCPanel">Aztrax menu</a></li>
 * </ol></li>
 * </ol></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_CTCPanelCode">CTC Panel Code</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_wrapas">Wrapped CTC Panel Programs</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_GeneratedCode">Generated Code</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_confpanel">Configuring CTC Panel Windows</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_addeditdeletePanelElements">Adding, Editing, and deleting elements to CTC Panel Windows</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_AddingEditingCMri">Adding, Editing, and deleting C/Mri nodes to CTC Pane</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_AddingEditingAztrax">Adding, Editing, and deleting Aztrax nodes to CTC Pane</a></li>
 * </ol></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_UserCode">User Code</a><ol type="1">
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_Insert-ableModules">Insert-able Modules</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_MainLoop">The Main Loop</a></li>
 * </ol></li>
 * </ol></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_AddCMRINodeDialog">Add CMRI Node Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_SelectCMRINodeDialog">Select CMRI Node Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_AddAztraxNodeDialog">Add Aztrax Node Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_SelectAztraxNodeDialog">Select Aztrax Node Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_AddPanelObjectDialog">Add Panel Object Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_SelectPanelObjectDialog">Select Panel Object Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_EditUserCodeDialog">Edit User Code Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_FindNodeDialog">Find Node Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_PrintDialog">Print Dialog</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#dispatcher_Reference_SelectPanelDialog">Select Panel Dialog</a></li>
 * </ol></li>
 * <li><a class="el" href="dispatcher_Examples.html">Dispatcher Examples</a><ol type="1">
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex1">Example 1: Simple siding on single track mainline</a></li>
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex2">Example 2: Mainline with an industrial siding</a></li>
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex3">Example 3: double track crossover</a></li>
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex4">Example 4: From Chapter 9 of C/MRI User's Manual V3.0</a></li>
 * </ol></li>
 * <li><a class="el" href="help.html">Help</a>
 * </li>
 * <li><a class="el" href="Version.html">Version</a>
 * </li>
 * <li><a class="el" href="Copying.html">GNU GENERAL PUBLIC LICENSE</a>
 * </li>
 * </ol></div></div> 
 * @endhtmlonly
 */


#endif // __PREFACE_H

