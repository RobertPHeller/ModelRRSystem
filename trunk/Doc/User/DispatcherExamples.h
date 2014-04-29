// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:44:09 2014
//  Last Modified : <140429.1129>
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

#ifndef __DISPATCHEREXAMPLES_H
#define __DISPATCHEREXAMPLES_H

/** @page dispatcher_Examples Dispatcher Examples
 * These are four examples created using the Dispatcher program.  The code
 * files are included and can be used as references or even modified to
 * suit some part of your layout.
 * 
 * @section dispatcher_Examples_ex1 Example 1: Simple siding on single track mainline
 * 
 * This example, shown below, implements a simple
 * passing siding on a single track main line.  There are two control
 * points, one at each end of the siding.  Both control points are handled
 * with a single SMINI board.
 * 
 * @image latex DISPExample1.png "Example 1: Simple siding on single track mainline" width=5in
 * @image html  DISPExample1Small.png
 * 
 * Here is the code:
 * 
 * @dontinclude example1.tcl
 * @skipline # Add User code after this line
 * @until Main Loop End
 * 
 * And the I/O Worksheet:
 * 
 * @dontinclude example1.iow
 * @skipline SMINI @ UA 0:
 * @until EOF
 * 
 * @section dispatcher_Examples_ex2 Example 2: Mainline with an industrial siding
 * 
 * This example, shown below, implements an industrial
 * siding on a single track main line.  There are two control points, one
 * at each end of the siding.  This example uses three SMINI boards, one
 * for each control point and one for the siding.
 * 
 * @image latex DISPExample2.png "Example 2: Mainline with an industrial siding" width=5in
 * @image html  DISPExample2Small.png
 * 
 * Here is the code:
 * 
 * @dontinclude example2.tcl
 * @skipline # Add User code after this line
 * @until Main Loop End
 * 
 * And the I/O Worksheet:
 * 
 * @dontinclude example2.iow
 * @skipline SMINI @ UA 0
 * @until EOF
 * 
 * @section dispatcher_Examples_ex3 Example 3: double track crossover
 * 
 * This example, shown below, implements a double track
 * crossover. Uses two SMINI boards, one for each of the two control points.
 *
 * @image latex DISPExample3.png "Example 3: Double track crossover" width=5in
 * @image html  DISPExample3Small.png
 * 
 * Here is the code:
 * 
 * @dontinclude example3.tcl
 * @skipline # Add User code after this line
 * @until Main Loop End
 * 
 * And the I/O Worksheet:
 * 
 * @dontinclude example3.iow
 * @skipline SMINI @ UA 0
 * @until EOF
 * 
 * @section dispatcher_Examples_ex4 Example 4: From Chapter 9 of C/MRI User's Manual V3.0
 * 
 * This example, shown below, implements the yard
 * example from Chapter 9 of C/MRI User's Manual V3.0.
 * @latexonly
 * \cite{Chubb03}
 * @endlatexonly
 * 
 * This example uses a single SMINI board.  The physical push buttons are
 * replaced by "virtual" push buttons on the computer screen.  Otherwise,
 * this code is a drop-in replacement, in Tcl under Linux, for the Quick
 * BASIC code under MS-Windows included in Bruce Chubb's manual.
 * 
 * @image latex DISPExample4.png "Example 4: From Chapter 9 of C/MRI User's Manual V3.0" width=5in
 * @image html  DISPExample4Small.png
 * 
 * Here is the code:
 * 
 * @dontinclude example4.tcl
 * @skipline # Add User code after this line
 * @until Main Loop End
 * 
 * And the I/O Worksheet:
 * 
 * @include example4.iow
 * 
 */

#endif // __DISPATCHEREXAMPLES_H

