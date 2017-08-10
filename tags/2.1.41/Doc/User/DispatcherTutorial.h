// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:40:00 2014
//  Last Modified : <170727.1050>
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

#ifndef __DISPATCHERTUTORIAL_H
#define __DISPATCHERTUTORIAL_H

/** @page dispatcher_Tutorial Dispatcher Tutorial
 * 
 * 
 * @section dispatcher_Tutorial_SimpleMode A "Simple Mode" CTC Panel
 * 
 * This tutorial will go through the steps of creating a simple CTC panel
 * for a passing siding.  First, after starting up the Dispatcher program,
 * we will click on the @c New @c CTC @c Window toolbar button and get a
 * @c New @c CTCPanel dialog box, as shown below. See Section 
 * @ref dispatcher_Reference_creatingCTCPanels for more information.
 * 
 * @n
 * @image latex DISPSimpleTutNewCTC.png "Creating a new Simple Mode CTC Panel"
 * @image html  DISPSimpleTutNewCTC.png
 * 
 * We fill in a name and select the @c Simple @c Mode  check button.
 * Clicking on @c Create gives us the blank panel shown below. 
 * 
 * @image latex DISPSimpleTutBlankCTC.png "Initial blank panel" width=5in
 * @image html  DISPSimpleTutBlankCTCSmall.png
 * 
 * Now we can start adding track work and control elements.  But first a 
 * brief discussion about how things are structured.  First of all every 
 * object has a unique name and every object is in a named control point.  
 * A "control point" is a collection of track work elements and control 
 * panel elements that relate to a single controlled feature, typically a 
 * turnout of some sort. The control point usually includes a code button, 
 * which is a button that initiates some change in the track work (turnouts, 
 * signals, etc.), based upon the settings of one or more control panel 
 * elements.  In this tutorial we will be creating four control points, @b CP1,
 * @b CP2, @b Main, and @b Siding.  @b CP1 is the turnout at the Western 
 * (left) end of the siding, @b CP2 is the turnout at the Eastern (right) end 
 * of the siding, @b Main is the mainline trackage, and @b Siding is the 
 * siding track. The @b Main and @b Siding control points won't have any 
 * control panel objects and are only being used to contain the simple track
 * elements. These are essentially "dummy" control points and are just
 * being used as containers for track work that does not contain any
 * centrally controllable track work.
 * 
 * First we will create turnout 1 (named @b Switch1) by selecting
 * @c Add @c Object on the @c Panel menu, which gives us the 
 * @c Add @c Panel @c Object @c to @c panel dialog box, shown below. See
 * Section @ref dispatcher_Reference_addeditdeletePanelElements for more
 * information. 
 * 
 * @n
 * @image latex DISPSimpleTutSw1.png "Creating Turnout 1"
 * @image html  DISPSimpleTutSw1Small.png
 * 
 * We will "flip" the turnout to give it the proper orientation. Turnouts 
 * can be flipped and can also be rotated to one of eight positions (45 degree 
 * increments). We will use the cross hairs to roughly position the turnout, 
 * as shown below.
 * 
 * @n
 * @image latex DISPSimpleTutSw1CrossHairs.png "Positioning Turnout 1" width=4in
 * @image html  DISPSimpleTutSw1CrossHairsSmall.png
 * 
 * Clicking the @c Add button places the turnout on the track work schematic, 
 * as shown below. 
 * 
 * @n
 * @image latex DISPSimpleTutPanel1.png "Turnout 1 placed on the panel" width=4in
 * @image html  DISPSimpleTutPanel1Small.png
 * 
 * You can fine tune the location of the object by making small changes to 
 * the X and Y coordinates after you have roughly placed the object using the
 * cross hairs. You can always go back and edit an object by using the 
 * @c Edit Object menu item on the @c Panel menu and then selecting the name 
 * of the object to edit.
 * 
 * Next, we will add a switch plate (named @b SwitchPlate1), again
 * by selecting @c Add @c Object on the @c Panel menu, again
 * using the @ Add @c Panel @c Object @c to @c panel dialog box, shown below.
 * 
 * @n
 * @image latex DISPSimpleTutSWPlate1.png "Adding a Switch Plate" width=4in
 * @image html  DISPSimpleTutSWPlate1Small.png
 * 
 * We will enter the name of the turnout it controls (@b Switch1) and the 
 * serial number of the MRD2-U board that will be controlling the Switch-It 
 * board powering the switch motor. Again we will use the cross hairs to place 
 * the switch plate. The result is shown below.
 * 
 * @n
 * @image latex DISPSimpleTutPanel2.png "Switch Plate 1 placed on the panel" width=4in
 * @image html  DISPSimpleTutPanel2Small.png
 * 
 * Finally, we will add a code button, as shown below.
 * 
 * @n
 * @image latex DISPSimpleTutCB1.png "Adding a code button" width=4in
 * @image html  DISPSimpleTutCB1Small.png
 * 
 * @image latex DISPSimpleTutPanel3.png "Code button 1 placed on the panel" width=4in
 * @image html  DISPSimpleTutPanel3Small.png
 * 
 * We repeat this process to add the mainline, the siding, and the second
 * turnout, with its switch plate and code button. Place the
 * second turnout next, then add the mainline and the siding tracks. Once
 * the turnouts have been placed, the locations of the endpoints of the
 * straight track sections are easy to select. Finally we get the
 * panel shown below.
 * 
 * @image latex DISPSimpleTutPanel4.png "The completed panel" width=5in
 * @image html  DISPSimpleTutPanel4Small.png
 * 
 * Once the panel has been completed, we can use the @c Wrap @c As menu
 * item under the @c File menu to create a "wrapped" version of
 * the generated program.  This is a self-contained, stand-alone
 * executable program that implements the CTC panel. See
 * Section @ref dispatcher_Reference_wrapas for more information.
 * 
 * @section dispatcher_LCC_Tutorial A LCC Example
 * 
 * In this tutorial we will transfer a layout designed in XtrackCAD to a 
 * dispatcher CTC panel.  XtrackCAD implements five type of "Layout Control" 
 * objects.  These are objects that can be manipulated and stored with a 
 * layout file that hold layout control information (called scripts).  These 
 * objects are:
 *   - Blocks.  Blocks are named groupings of track that have a script that 
 *     determines block occupancy.
 *   - Switch Motors.  Switch Motors are named objects associated with a 
 *     turnout and have three scripts: a normal action script, a reverse 
 *     action script, and a point sense script.  The normal action script
 *     activates a switch machine to align the points to the normal position
 *     (generally aligned to the main route) and the reverse action script 
 *     activates a switch machine to align the points to the reverse position
 *     (generally aligned to the spur route).  The point sense script returns
 *     a value indicating the current alignment of the points (eg normal or
 *     reverse).
 *   - Signals.  Signals are devices that display various aspects that indicate
 *     train movement permissions.  Signals have a location, an orientation,
 *     a number of heads (one, two, or three), and one or more aspects, which
 *     have a name and a script.
 *   - Sensors.  Sensors are just single on or off state.  A sensor could be
 *     a push button switch or some sort of device that senses something on the
 *     layout (generally not block occupancy, since that is already handled by
 *     the block object).
 *   - Controls.  Controls are just a single actuator or other on or off 
 *     device (like a lamp).  Could be some track side animation (like a log
 *     loader or a crossing gate).
 * 
 * XtrackCAD imposes no particular syntax for the scripts.  For layouts using
 * LCC and Dispatcher, the scripts are defined as one or two LCC event numbers.
 * A LCC event number is a 64-bit number formatted as eight pairs of 
 * hexadecimal digits separated by periods.  For actions, it is a single event
 * id that is consumed by the actuator (eg switch machine or signal).  For 
 * sensors (eg block detection sensors, point sensors), it is a pair of event
 * numbers separated by a colon.  These event numbers are produced by the 
 * sensor for each of two states.  For blocks, the first event number is 
 * produced when the block becomes occupied and the second event number is
 * produced when the block becomes unoccupied.  For point sense scripts the
 * first event is produced when the points become normal aligned and the second
 * event is produced when the points become reverse aligned.
 * 
 * The layout we will add is a simple passing siding on a main line as shown 
 * below.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingXtrkCAD.png "Simple passing siding in XtrackCAD" width=5in
 * @image html  Dispatcher_PassingSidingXtrkCADSmall.png
 * 
 * We have already filled in the control elements for this layout in the 
 * XtrackCAD layout file.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingLCEManager.png "Passing Siding Layout control elements" width=5in
 * @image html  Dispatcher_PassingSidingLCEManagerSmall.png
 * 
 * After loading the XtrackCAD file into the Dispatcher, the dispatcher shows
 * a graph of the layout, detailing the various track and control elements
 * and their connectedness.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingGraph.png "Passing Siding Layout as a graph in Dispatcher" width=5in
 * @image html  Dispatcher_PassingSidingGraphSmall.png
 * 
 * Next we will create a fresh CTC Panel by clicking on the "New CTC Window"
 * button.  This gives us a "New CTCPanel" dialog box.
 * 
 * @n 
 * @image latex Dispatcher_PassingSidingNewCTCPanelDialog.png "New CTCPanel dialog"
 * @image html  Dispatcher_PassingSidingNewCTCPanelDialogSmall.png
 *
 * We will give the CTC Panel a name (Passing Siding), select the OpenLCB Mode
 * checkbox, and fill in the OpenLCB transport constructor and its opts.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingNewCTCPanelDialogUpd.png "New CTCPanel dialog, updated"
 * @image html  Dispatcher_PassingSidingNewCTCPanelDialogUpdSmall.png
 * 
 * After clicking the Create button we have a new fresh CTC Panel window.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCTCPanelEmpty.png "Empty Passing Siding CTC Panel" width=5in
 * @image html  Dispatcher_PassingSidingCTCPanelEmptySmall.png
 * 
 * First we will transfer track segment 1, the western most segment of the 
 * main line just before the siding.  We will use the right button to get the
 * context menu and then select "Add To Panel" on this menu.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingContextMenu.png "Context menu for track element 1"
 * @image html  Dispatcher_PassingSidingContextMenu.png
 * 
 * This gives us an "Add Panel Object to panel" dialog box.  Notice how 
 * various fields are preloaded.  We will shortly change a few things: remove
 * the unneeded label, add a control point, and position the track on the 
 * schematic using the cross hairs.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingSegment1Initial.png "Initial Add Panel Object to panel dialog box for segment 1"
 * @image html  Dispatcher_PassingSidingSegment1InitialSmall.png
 * 
 * And after some minor updates, we have this:
 * 
 * @n
 * @image latex Dispatcher_PassingSidingSegment1Updated.png "Updated Add Panel Object to panel dialog box for segment 1"
 * @image html  Dispatcher_PassingSidingSegment1UpdatedSmall.png
 * 
 * Next we will add the western turnout.  This is track segment 3.  Again we 
 * right click on the segment node on the Dispatcher main window and select 
 * "Add to Panel".  Note how most of the fields are filled in from the layout
 * file.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingSegment3Initial.png "Initial Add Panel Object to panel dialog box for segment 3"
 * @image html  Dispatcher_PassingSidingSegment3InitialSmall.png
 * 
 * @n
 * @image latex Dispatcher_PassingSidingSegment3Updated.png "Updated Add Panel Object to panel dialog box for segment 3"
 * @image html  Dispatcher_PassingSidingSegment3UpdatedSmall.png
 * 
 * Because this is a turnout with a switch motor, we will also add a switch 
 * plate.  The only additional work needed is positioning it.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingSwitchPlate.png "Updated Add Panel Object to panel dialog box for turnout switch plate"
 * @image html  Dispatcher_PassingSidingSwitchPlateSmall.png
 * 
 * Our panel is now like this:
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCTCPanel.png "Updated CTC Panel" width=5in
 * @image html  Dispatcher_PassingSidingCTCPanelSmall.png
 * 
 * Finally we will add one of the signals, CP1E, which is node number 19.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCP1EInitial.png "Initial Add Panel Object dialog box for CP1E"
 * @image html  Dispatcher_PassingSidingCP1EInitialSmall.png
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCP1EUpdated.png "Updated Add Panel Object dialog box for CP1E"
 * @image html  Dispatcher_PassingSidingCP1EUpdatedSmall.png
 * 
 * This gives us this panel:
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCTCPanelWSignal.png "Panel with signal CP1E added." width=5in
 * @image html  Dispatcher_PassingSidingCTCPanelWSignalSmall.png
 * 
 * The remaining track elements and switch plates can be added by repeating 
 * these steps.  
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCTCPanelCompleteBeforeSigPlates.png "Panel with all elements from the layout file added." width=5in
 * @image html  Dispatcher_PassingSidingCTCPanelCompleteBeforeSigPlatesSmall.png
 * 
 * Finally, the signal plates and code buttons can be added using the Panel 
 * menu on the CTC Panel.
 * 
 * @n
 * @image latex Dispatcher_PassingSidingCTCPanelComplete.png "Completed panel." width=5in
 * @image html  Dispatcher_PassingSidingCTCPanelCompleteSmall.png
 * 
 * Now we can save the file and wrap it into a ready to run executable.
 */

/* @section dispatcher_Tutorial_Advanced A more advanced Example
 */

#endif // __DISPATCHERTUTORIAL_H

