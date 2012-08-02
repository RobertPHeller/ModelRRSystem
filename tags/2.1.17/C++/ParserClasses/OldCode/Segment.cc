/* 
 * ------------------------------------------------------------------
 * Segment.cc - Segemnt and successor Class
 * Created by Robert Heller on Tue Aug 29 13:09:43 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.8  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.7  1995/09/12 02:45:33  heller
 * Modification History: Add in NULL (EMPTY) NextElement case.
 * Modification History:
// Revision 2.6  1995/09/09  22:59:47  heller
// write proper output functions
//
// Revision 2.5  1995/09/02  21:23:56  heller
// More fixes to MRRcreateNextElement...
//
// Revision 2.4  1995/09/02  21:13:38  heller
// More fixing to MRRcreateNextElement.
//
// Revision 2.3  1995/09/02  21:06:17  heller
// fix MRRcreateSegment -- wrong argv elements.
//
// Revision 2.2  1995/09/02  20:59:08  heller
// Fix MRRcreateNextElement (wrong argv element)
//
// Revision 2.1  1995/09/02  19:08:54  heller
// Initial version
//
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
 * 			51 Locke Hill Road
 * 			Wendell, MA 01379-9728
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 *  
 */

static char rcsid[] = "$Id$";

#include <math.h>
#include <Segment.h>
#include <Turnout.h>
#include <Block.h>
#include <Table.h>
#include <Cross.h>
#include <strstream.h>

#define DEGREES(x) (((x) / M_PI) * 180.0)

static const double FUZZ = 0.0001;

static int sign(double x)
{
	if (fabs(x) <= FUZZ) return(0);
	else if (x < 0.0) return(-1);
	else if (x > 0.0) return(1);
	else return(0);
}

static double square(double x) {return(x*x);}

static const double M_2xPI = M_PI + M_PI;
static const double M_PI3_2 = M_PI + M_PI_2;

bool Segment::ComputeCurve(double &radius, double &Xc, double &Yc, double &Alpha1, 
		      double &Alpha2, double &Xx, double &Yy, 
		      double &w, double &h, double &NewTheta)
{
	double Xa = X1, Ya = Y1, Xb = X2, Yb = Y2, Theta = Tan;
	double dx, dy, Tx, Ty, Nx, Ny, t, top, bottom, Theta_a, Theta_b,
	       dxca, dyca, tb;
	
	dx = Xb - Xa;
	dy = Yb - Ya;
	Tx = cos(Theta);
	Ty = -sin(Theta);
	Nx = Ty;
	Ny = -Tx;
	// t = (P+Q)^2/(2N*(Q-P)
	//sub figure_t
	//  let top = (Px-Qx)^2 + (Py-Qy)^2
	//  let bottom = 2*(Nx*(Qx-Px) + Ny*(Qy-Py)]
	//  let t = top/bottom
	//end sub
	top = square(dx) + square(dy);
	bottom = 2 * (Nx * dx + Ny * dy);
	// overflow/straight line check
	if (fabs(bottom) <= FUZZ)
	{
		//  Bogus point check.
		if (sign(dx) == sign(Tx) && sign(dy) == sign(Ty))
		{
		//    ligit straight (tangent) track
			radius = 0.0;
			return false;
		} else
		{
		//    imposible straight (tangent) track
		//    (requires infinite radius curve).
			radius = -1.0;
			return false;
		}
	}
	t = top / bottom;
	//sub getA
	//  let Ax = Px + t*Nx
	//  let Ay = Py + t*Ny
	//end sub
	Xc = Xa + t * Nx;
	Yc = Ya + t * Ny;

	//  let Theta_P = angle(Px-Ax, Py-Ay)
	//  let Theta_Q = angle(Qx-Ax, Qy-Ay)
	//  True BASIC angle(x,y) == C++ atan2(-y,x)
	Theta_a  = atan2(-(Ya - Yc),Xa - Xc);
	Theta_b  = atan2(-(Yb - Yc),Xb - Xc);

	// compute radius

	dxca = Xc - Xa;
	dyca = Yc - Ya;
	radius = sqrt(square(dxca)+square(dyca));

	// start computing Alpha1 (start of arc) and Alpha2 (delta of arc)
	// (for draw Arc later)

	Alpha1 = Theta_a;
	// we want 0 to 2PI range, not -PI to PI
	if (Alpha1 < 0) Alpha1 = M_2xPI + Alpha1;
	// also -0.0 is pesky
  	if (Alpha1 == -0.0) Alpha1 = 0.0;
	// dito for tb (abs pos of end of arc)
	tb = Theta_b;
	if (tb < 0) tb = M_2xPI + tb;

/****************************************
 ****************************************
 *
 * ABANDON ALL HOPE YE WHO ENTER HERE!!!!
 * (totally kludgey code warning)
 *
 * This section was created by trial and 
 * error.  I have no mathametically sound
 * proof of any of this.  It works -- leave
 * it alone.  Don't try to understand it.
 *
 *
 ****************************************
 ****************************************/

	if (Theta < M_PI_2)
	{
	  // horiz (right) to straight up
	  if (Ya > Yc)
	  {
	    // CCW
	    if (tb < Alpha1) Alpha2 = (tb + M_2xPI) - Alpha1;
	    else Alpha2 = tb - Alpha1;
          } else
          {
	    // CW
	    if (tb < Alpha1) Alpha2 = -(Alpha1 - tb);
	    else Alpha2 = -(M_2xPI - (tb - Alpha1));
          }
	} else if (Theta < M_PI)
	{
	  // straight up to horiz (left)
	  if (Xa < Xc) 
	  {
	    // CW
	    if (tb < Alpha1) Alpha2 = -(Alpha1 - tb);
	    else Alpha2 = -(Alpha1 + M_2xPI - tb);
    	  } else 
	    // CCW
	    Alpha2 = tb - Alpha1;
	} else if (Theta < M_PI3_2)
	{
	  // horiz (left) to straight down
	  if (Ya < Yc)
	  {
	    // CCW
	    if (tb > Alpha1) Alpha2 = tb - Alpha1;
	    else Alpha2 = M_2xPI - (Alpha1 - tb);
	  } else 
	  {
	    // CW
	    if (tb < Alpha1) Alpha2 = -(Alpha1 - tb);
	    else Alpha2 = -(Alpha1 + M_2xPI - tb);
	  }
	} else
	{
	  // straight down to horiz (right)
	  if (Xa < Xc)
	  {
	    // CCW
	   if (tb > Alpha1) Alpha2 = tb - Alpha1;
	   else Alpha2 = M_2xPI - (Alpha1 - tb);
	  } else 
	  {
	    // CW
	    if (tb < Alpha1) Alpha2 = -(Alpha1 - tb);
	    else Alpha2 = -(Alpha1 + M_2xPI - tb);
	  }
	}

  
/****************************************
 ****************************************
 *
 * And now back to normal code...
 *
 ****************************************
 ****************************************/


	Xx = Xc - radius;
	Yy = Yc - radius;
	w  = radius * 2;
	h  = w;
	Nx = Xc - Xb;
	Ny = Yc - Yb;
	Tx = Ny;
	Ty = -Nx;
	if (Alpha2 < 0) NewTheta = atan2(-Ty,Tx);
	else NewTheta = atan2(Ty,-Tx);
	if (NewTheta < 0) NewTheta = M_2xPI + NewTheta;
	if (NewTheta == -0.0) NewTheta = 0.0;
	return true;
}


double Segment::Length()
{
	double radius, Xc, Yc, Alpha1, Alpha2, Xx, Yy, w, h, NewTheta;
	if (ComputeCurve(radius, Xc, Yc,
		         Alpha1, Alpha2, Xx, Yy, w, h, NewTheta))
	{
		return (Alpha2 * radius);
	} else if (radius == 0.0) {
		double dx = X2 - X1,
		       dy = Y2 - Y1;
		return sqrt(square(dx)+square(dy));
	} else return 0.0;
}

void Segment::Rotate(double angle)
{
	double c = cos(angle);
	double s = sin(angle);
	double tx = (c * X1) + ((-s) * Y1);
	double ty = (s * X1) + (c * Y1);
	X1 = tx; Y1 = ty;
	tx = (c * X2) + ((-s) * Y2);
	ty = (s * X2) + (c * Y2);
	X2 = tx; Y2 = ty;
}

void Segment::Rotate(double angle,double ax,double ay)
{
	Translate(-ax,-ay);
	Rotate(angle);
	Translate(ax,ay);
}

ostream& operator << (ostream& stream,NextElement& nxsg)
{
	switch (nxsg.TypeOfNext())
	{
		case NextElement::_Turnout:
			stream << "turnout ";
			stream << nxsg.NextTurnout()->Name();
			break;
		case NextElement::_Block:
			stream << "block ";
			stream << nxsg.NextBlock()->Name();
			break;
		case NextElement::_Table:
			stream << "table ";
			stream << nxsg.NextTable()->Name();
			break;
		case NextElement::_Cross:
			stream << "cross ";
			stream << nxsg.NextCross()->Name();
			break;
		case NextElement::None:
			stream << "none";
			break;
		default: break;	// print nothing for NextSegment()
	}
	return stream;
}

ostream& operator << (ostream& stream,Segment& sg)
{
	stream << '{'
	       << sg.X1 << " " << sg.Y1 << " " << sg.Z1 << " ";
	if (sg.N1 == NULL) stream << "EMPTY";
	else stream << *(sg.N1);
	stream << " "
	       << sg.X2 << " " << sg.Y2 << " " << sg.Z2 << " ";
	if (sg.N2 == NULL) stream << "EMPTY";
	else stream << *(sg.N2);
	stream << " "
	       << DEGREES(sg.Tan) 
	       << '}';
	return stream;
}
