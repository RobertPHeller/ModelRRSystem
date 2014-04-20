// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 16:10:37 2014
//  Last Modified : <140420.1039>
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

#ifndef __FCF_H
#define __FCF_H

/** @mainpage Table Of Contents
 * @anchor toc
 * @htmlonly
 * <div class="contents">
 * <div class="textblock"><ol type="1">
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
 * <li><a class="el" href="help.html">Help</a></li>
 * <li><a class="el" href="Version.html">Version</a></li>
 * <li><a class="el" href="Copying.html">Copying</a><ol type="a">
 * <li><a class="el" href="Copying.html#Warranty">Warranty</a></li>
 * </ol>
 * </li>
 * </ol></div></div>
 * @endhtmlonly
 */      

#endif // __FCF_H

