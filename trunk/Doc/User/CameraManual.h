// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:38:47 2014
//  Last Modified : <140506.0820>
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

#ifndef __CAMERAMANUAL_H
#define __CAMERAMANUAL_H

/** @page camera_Reference Camera Programs Reference
 * AnyDistance and Closest compute the view angle in both real and scale
 * units. It also computes the effective scale of the imaging plane, such
 * as the size of a 35mm slide, which might be used as a transparency for
 * model window panes or locomotive number boards.
 * 
 * Both programs work the same. The only difference is that Closest uses
 * the closest effective focus of the lens and AnyDistance uses a user
 * specified focus distance.  Given the input parameters, the distance,
 * the lens, the scale, and the film size, a diagram is displayed with the
 * dimensions of the view.  This diagram can be printed using the @c Print...
 * menu item under the @c File menu.
 * 
 * New lenses can be entered with the @c New menu item under the
 * @c File menu. The @c Open... and @c Save.. menu items can
 * load and save the set of available lenses.
 * 
 * Both programs solve the equation below and display a
 * diagram illustrating the solution.  AnyDistance uses a user entered
 * value for @f$D@f$ and Closest uses the closest focusing distance for the
 * selected lens.
 * 
 * @f{equation}{
 * W_{view} = (D S) 2 \tan(\frac{\theta}{2})
 * @f}
 * 
 * Where:
 * 
 * @f{eqnarray*}{
 * W_{view} &=& \mbox{The scale view width.}\\
 * D &=& \mbox{The distance between the scene and the camera lens.}\\
 * S &=& \mbox{The model scale factor.}\\
 * \mbox{and} \\
 * \theta &=& \mbox{The lens view angle.}
 * @f}
 * 
 * The main GUI screen of the AnyDistance program is shown below.
 * The Closest program is much the same, except that the distance parameter is 
 * omitted.
 * 
 * @image latex CameraAnyDist.png "The main GUI screen of the AnyDistance program" width=5in
 * @image html  CameraAnyDistSmall.png
 */

#endif // __CAMERAMANUAL_H

