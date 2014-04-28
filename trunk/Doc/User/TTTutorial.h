// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Thu Apr 10 16:39:59 2014
//  Last Modified : <140428.1553>
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

#ifndef __TTTUTORIAL_H
#define __TTTUTORIAL_H

/** @page timetable_Tutorial Time Table (V2) Tutorial
 * 
 * The Time Table is a program designed to create railroad employee 
 * timetables.  The program's main display is a graph of time (of day) versus 
 * distance (along the railroad), gridded at time intervals and at station 
 * stops.  Trains schedules are represented as colored lines on this graph, 
 * with diagonals representing train movement at speed and horizontal lines 
 * representing trains "siting" at stations (layovers or switching).
 * 
 * @section timetable_tut_crenew Creating a new time table
 * 
 * To create an new time table select the @c File->New menu item or
 * the 
 * @image latex TTNewTool.png 
 * @htmlonly
 *  <img src="TTNewTool.png" alt="New Time Table toolbar button"/>
 * @endhtmlonly
 * toolbar button. A "Create a New Time Table" dialog, described in
 * Section @ref timetable_ref_createnewtimetable. is displayed.  This dialog
 * box collects three pieces of information: the name of the new time
 * table, the total time (in minutes) the time table will cover (there are
 * 1440 minutes in a 24 hour day), and the tick interval in minutes.  A
 * new time table can also me created from the command line by including
 * the options @c -totaltime and @c -timeincrement along with a
 * name for the new time table.
 * 
 * @subsection timetable_tut_crestat Creating stations
 * 
 * Once the name and the two time elements have been selected, a set of at
 * least two stations need to be created.  This is done with the "Create
 * All Stations Dialog",  described in
 * Section @ref timetable_ref_CreateAllStationsDialog.  This dialog box is
 * used to create stations, which can have zero or more storage tracks. 
 * Storage tracks are used when a train has a long layover (and needs to
 * be "out of the way" of other traffic) or when a train terminates and
 * the train set is re-used for a different schedule, generally in the
 * opposite direction. As the stations and their storage tracks are
 * created, they are displayed in the station listing in the upper part of
 * the dialog. 
 * 
 * @subsection timetable_tut_crecab Creating cabs
 * 
 * After creating all of the stations, zero or more cabs can be created. 
 * Cabs are mostly for switched block DC layouts, but creating "cabs"
 * for a DCC layout is useful, since it allows for a way to visually group
 * trains operationally. Think of the cabs as a way of defining "crews"
 * (operators).  This allows for things like crew (operator) changes as
 * the train moves to different parts of the layout for example.
 * 
 * @section timetable_tut_cretrain Creating trains
 * 
 * Once the stations and cabs have been created, the program displays an
 * empty chart.  The chart's @c x axis is time (in minutes).  The upper
 * section of the chart has the cabs (if any), the middle part of the chart
 * has the stations, and the bottom part of the chart has the storage
 * tracks (if any).  Now we can create a train.  This is done by selecting
 * either the @c Trains->Add Train menu item, clicking on the add train
 * ( 
 * @image latex TTaddtrain.png
 * @htmlonly
 * <img src="TTaddtrain.png" alt="Add Train toolbar button">
 * @endhtmlonly
 * ) toolbar button or the @c Add a new train button.  All of these display 
 * the "Create New Train Dialog", described in Section 
 * @ref timetable_ref_CreateNewTrainDialog. Trains have a (common) name, 
 * a number (or symbol), a class number, an average speed, a scheduled 
 * departure time, and travel between two stations.  The train's number (or 
 * symbol) needs to be a unique identification of the train. The class is a 
 * whole number, with smaller numbers generally being the "higher" class.  
 * The class is used to indicate a train's priority and is also used to group 
 * similar trains together.  The speed is the (scale) speed the train will be 
 * traveling between stops.  The scheduled departure time is the time the 
 * train is scheduled to leave its origin station.  The origin and termination 
 * stations are the station end points the train travels between.  The train 
 * will get a "stop" at every intermediate station between these two 
 * stations.  Note that the train won't be expected to actually stop at any 
 * station where the layover time is set to zero.  Such stops would just be 
 * timekeeping points.
 * 
 * Once the train's basic information is set, the @c Schedule button can be
 * clicked.  This shifts to the schedule page, where layovers and cab
 * assignments cab be set.  The @c Update buttons propagate the
 * cab settings and adjust the times to allow for the layovers.  If the
 * train makes use of station storage tracks, the @c Storage button can
 * be clicked and storage tracks selected.  When the train is fully
 * configured, the @c Done button can be clicked to actually create the
 * train.
 * 
 * @section timetable_tut_print Printing a time table
 * 
 * Once all of the trains have been added, it it possible to "print" a
 * timetable.  The LaTeX system is used to format the time table and the
 * TimeTable program generates a LaTeX source file (.tex) and will
 * run the LaTeX program, @c pdflatex, to create a PDF file from the
 * LaTeX source file.  This process is started with the
 * @c File->Print... menu item or the
 * @image latex TTprintTool.png
 * @htmlonly
 * <img src="TTprintTool.png" alt="Print toolbar button">
 * @endhtmlonly
 * toolbar button.  This pops up the "Print Dialog", described in Section 
 * @ref timetable_ref_PrintTimetableDialog. This dialog collects the name of 
 * the LaTeX source file, and the path to the LaTeX processing programing, as 
 * well as a few other options.  It also has a button to configure how the 
 * timetable will be formatted.  
 * 
 * The @c Configure button pops up the "Print Configuration Dialog",
 * described in Section @ref timetable_ref_PrintConfigurationDialog, which has
 * three sections, a @c General section which gets some general
 * configuration settings, a @c Multi section for various
 * configuration settings relating to printing multiple tables, and a
 * @c Groups section, for configuring groups of trains.  Some of the
 * configuration assumes some knowledge of LaTeX. A visit to the TeX and
 * LaTeX web pages (http://www.tug.org) is a good place to start,
 * with the beginner's page at http://www.tug.org/begin.html as the
 * obvious starting point.  You don't really have to learn how to use
 * LaTeX, you just need to have a TeX/LaTeX system installed.  The only
 * other issue is the @c TimeTable.sty file.  This file either needs to be
 * installed somewhere in the TeX/LaTeX search path or it needs to be in
 * the same directory as the LaTeX source file generated by the TimeTable
 * program. You will need to learn a little about LaTeX if you want to
 * include various sorts of customizations.
 */

#endif // __TTTUTORIAL_H
