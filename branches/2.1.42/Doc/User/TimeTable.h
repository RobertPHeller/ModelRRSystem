// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 15:01:57 2014
//  Last Modified : <140415.1057>
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

#ifndef __TIMETABLE_H
#define __TIMETABLE_H

/** @mainpage Table Of Contents
 * @anchor toc
 * @htmlonly
 * <div class="contents">
 * <div class="textblock"><ol type="1">
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
 * <li><a class="el" href="help.html">Help</a></li>
 * <li><a class="el" href="Version.html">Version</a></li>
 * <li><a class="el" href="Copying.html">Copying</a><ol type="a">
 * <li><a class="el" href="Copying.html#Warranty">Warranty</a></li>
 * </ol>
 * </li>
 * </ol></div></div>
 * @endhtmlonly
 */

#endif // __TIMETABLE_H

