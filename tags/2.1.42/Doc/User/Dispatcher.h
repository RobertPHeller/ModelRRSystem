// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 16:52:45 2014
//  Last Modified : <170328.1408>
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

#ifndef __DISPATCHER_H
#define __DISPATCHER_H

/** @mainpage Table Of Contents
 * @anchor toc
 * @htmlonly
 * <div class="contents">
 * <div class="textblock"><ol type="1">
 * <li><a class="el" href="dispatcher_Tutorial.html">Dispatcher Tutorial</a><ol type="1">
 * <li><a class="el" href="dispatcher_Tutorial.html#dispatcher_Tutorial_SimpleMode">A &quot;Simple Mode&quot; CTC Panel</a></li>
 * <li><a class="el" href="dispatcher_Tutorial.html#dispatcher_LCC_Tutorial">A LCC Example</a></li>
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
 * <li><a class="el" href="dispatcher_Reference.html#xtrkcadLCC">Using the Dispatcher program with layouts designed in XtrackCAD</a></li>
 * <li><a class="el" href="dispatcher_Reference.html#Dispatcher_Reference_insertableModules">Insertable Module Library</a></li>
 * 
 * </ol></li>
 * <li><a class="el" href="dispatcher_Examples.html">Dispatcher Examples</a><ol type="1">
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex1">Example 1: Simple siding on single track mainline</a></li>
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex2">Example 2: Mainline with an industrial siding</a></li>
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex3">Example 3: double track crossover</a></li>
 * <li><a class="el" href="dispatcher_Examples.html#dispatcher_Examples_ex4">Example 4: From Chapter 9 of C/MRI User's Manual V3.0</a></li>
 * </ol></li>
 * <li><a class="el" href="help.html">Help</a></li>
 * <li><a class="el" href="Version.html">Version</a></li>
 * <li><a class="el" href="Copying.html">Copying</a><ol type="a">
 * <li><a class="el" href="Copying.html#Warranty">Warranty</a></li>
 * </ol></li>
 * </ol></div></div>
 * @endhtmlonly
 */      


#endif // __DISPATCHER_H

