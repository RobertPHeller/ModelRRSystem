// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:37:13 2014
//  Last Modified : <140420.1517>
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

#ifndef __LOCOPULLMANUAL_H
#define __LOCOPULLMANUAL_H

/** @page locopull_Reference LocoPull Program Reference
 * 
 * @section locopull_Reference_BasisMathematics Basis and Mathematics
 * 
 * This program is based on the information posted by Mark U. on the Yahoo
 * XTrkCad list at the URL http://groups.yahoo.com/group/XTrkCad/message/4983
 * and the information supplied by rtroop on the TrainBoard forum in post 
 * no. 9 at the URL http://www.trainboard.com/grapevine/showthread.php?t=114497.
 * This is a standalone program that incorporates the formulas presented in
 * Mark U's spreadsheet and explained in rtroop's message.  The formulas
 * are as follows:
 * 
 * @f{eqnarray}{
 * E_{unit} &=& W_{unit}{A}  \\
 * E  &=& E_{unit}{N}  \\
 * R_{ave}  &=& W_{ave}{F}  \\
 * C_{0~Grade} &=& \Biggl\lfloor \frac{E}{R_{ave}} \Biggr\rfloor  \\
 * R_{grade}    &=& W_{ave}{G}  \\
 * R_{net~at~grade} &=& R_{ave} + R_{grade}  \\
 * R_{unit~at~grade} &=& W_{unit}{G}  \\
 * D &=& \frac{5730}{\frac{rS}{12}}  \\
 * C_{grade~and~curve} &=& \Biggl\lfloor 
 *      \frac{ {E} - {N} {W_{unit}} ( G + F + D ) }
 *           { {R_{ave}} + {W_{ave}} ( G + {F_{per~degree}} {D} ) }
 * 	\Biggr\rfloor 
 * @f}
 *
 * Where:
 * <dl>
 * <dt>@f$W_{unit}@f$</dt><dd>is the weight of each locomotive in ounces.</dd>
 * <dt>@f$A@f$ </dt><dd>is the adhesion factor generally 25\%. </dd>
 * <dt>@f$E_{unit}@f$</dt><dd>is the tractive effort per unit in ounces. </dd>
 * <dt>@f$E@f$</dt><dd>is the net tractive effort in ounces. </dd>
 * <dt>@f$N@f$</dt><dd>is the number of units. </dd>
 * <dt>@f$F@f$ </dt><dd>is the resistance factor of each car, typically 4\% for N
 * scale cars.</dd>
 * <dt>@f$W_{ave}@f$</dt><dd>is the average weight per car, typically 1 ounce for N scale cars.</dd>
 * <dt>@f$R_{ave}@f$</dt><dd>is the average rolling resistance of each car.</dd>
 * <dt>@f$C_{0~Grade}@f$</dt><dd>is the capacity of the train on level, straight
 * track.</dd>
 * <dt>@f$G@f$</dt><dd>is the percent of grade.</dd>
 * <dt>@f$R_{grade}@f$</dt><dd>is the added rolling resistance of each car due to
 * grade.</dd>
 * <dt>@f$R_{net~at~grade}@f$</dt><dd>is the net rolling resistance of each car at
 * grade.</dd>
 * <dt>@f$r@f$ </dt><dd>is the track radius in inches.</dd>
 * <dt>@f$S@f$</dt><dd>is the scale factor (160 for N scale, 87 for H0 scale, etc.).</dd>
 * <dt>@f$D@f$</dt><dd> is the degree of curvature.</dd>
 * <dt>@f$F_{per~degree}@f$</dt><dd>is the resistance factor per degree of curvature,
 * typically .04\%.</dd>
 * <dt>@f$C_{grade~and~curve}@f$</dt><dd>is the capacity of the train on at grade on a
 * curve.</dd>
 * </dl>
 * 
 * @section locopull_Reference_GUI The GUI
 * 
 * The main GUI screen of the LocoPull program is shown below.
 * The GUI is broken down into sections: 
 *    - The Scale section.  The scale is selected here.
 *    - The Locomotive Information section.  Information about the
 *      locomotives is entered here.  The number of locomotives, how much they
 *      weigh each, and their adhesion factor. The tractive effort for each 
 *      unit and the net tractive effort are computed and displayed here. It is
 *      assumed that all of the powered engines are the same, typically the 
 *      same make and model, with the same weight and same adhesion factor.
 *    - The Consist Information. Information about the cars, including
 *      their average weight and their average resistance factor are entered 
 *      and the rolling rolling resistance is computed and displayed.
 *    - The Zero-grade Capacity section.  The maximum number of cars that
 *      can be pulled on a straight track on a level grade is computed and
 *      displayed here.
 *    - The Grade Information section. The percent of grade is entered and
 *      the added rolling resistance per car at grade, the net rolling
 *      resistance, and the added resistance per unit are computed and 
 *      displayed here. 
 *    - The Curve Information section. The radius of the curve in inches
 *      and the rolling resistance per degree of curve are entered and the
 *      degree of curvature is computed and displayed.
 *    - The Capacity at Grade and Curve section.  This is the maximum
 *      number of cars that can be pulled at the grade and curve specified.
 *    - Calculate button. This button performs the calculation and updates
 *      all of the displayed values.
 * 
 * @image latex LocoPullMain.png "The main GUI screen of the LocoPull program" width=5in
 * @image html  LocoPullMain.png
 * 
 * @subsection locopull_Reference_Scale The Scale
 * 
 * The scale selection simply select the scale and is used to compute the
 * degree of curvature.
 * 
 * @subsection locopull_Reference_Locomotive Locomotive Information
 * 
 * This section of the GUI gathers information about the locomotives
 * pulling the train.  It is assumed that all of the locomotives have the
 * same tractive effort, that is they are the same weight and have the same
 * adhesion factor.  This would generally be the case if the locomotives
 * were the make and model.  Three inputs are gathered in this section: the
 * number of locomotives, the weight of each locomotive, and the adhesion
 * factor of the locomotives.  Two intermediate outputs are displayed here:
 * the tractive effort of each locomotive and the net tractive effort of
 * all of the locomotives together.
 * 
 * @subsection locopull_Reference_Consist Consist Information
 * 
 * This section gathers two inputs and displays one intermediate result. 
 * The two inputs are the average weight of the cars and the average
 * rolling resistance factor.  The intermediate result is the average car
 * rolling resistance.
 * 
 * @subsection locopull_Reference_Zero-grade Zero-grade capacity
 * 
 * This is simply the net tractive effort divided by the average car
 * rolling resistance.  The floor of the result is displayed as a whole
 * number (since pulling a fraction of a car is not meaningful).
 * 
 * @subsection locopull_Reference_Grade Grade information
 * 
 * One input is gathered and three intermediate results are displayed.  The
 * input is the percent of grade and the intermediate results displayed are
 * the added rolling resistance at grade of each car, the net rolling
 * resistance per car, and the added rolling resistance of each locomotive
 * at grade.
 * 
 * @subsection locopull_Reference_Curve Curve information
 * 
 * This section gathers two inputs and displays one intermediate result.
 * The added inputs are the curve radius and the rolling resistance per
 * degree of curvature and the intermediate result is the degree of
 * curvature. 
 * 
 * @subsection locopull_Reference_Capacity Capacity and Grade plus Curve
 * 
 * This is just the tractive effort less the tractive effort needed to
 * pull the locomotives themselves divided by the combined rolling
 * resistance of the average car: base rolling resistance plus the added
 * rolling resistance due to grade, plus the added rolling resistance due
 * to the curvature.  The floor of the result is displayed as a whole
 * number (since pulling a fraction of a car is not meaningful).
 * 
 */


#endif // __LOCOPULLMANUAL_H

