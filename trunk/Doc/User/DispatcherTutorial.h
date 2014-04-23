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
//  Last Modified : <140423.1351>
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
 * Section @ref dispatche_Reference_wrapas for more information.
 * 
 * 
 * @section dispatcher_Tutorial_Advanced A more advanced Example
 */

#endif // __DISPATCHERTUTORIAL_H

