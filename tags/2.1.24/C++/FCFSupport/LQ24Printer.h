/* 
 * ------------------------------------------------------------------
 * LQ24Printer.h - Epson LQ 24 Printer
 * Created by Robert Heller on Sun Sep 18 11:59:25 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:41:57  heller
 * Modification History: Nov 4, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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

#ifndef _LQ24PRINTER_H_
#define _LQ24PRINTER_H_

#ifndef SWIG
#include <Printer.h>
#endif

/** @addtogroup FCFSupport
  * @{
  */

namespace FCFSupport {

/** @brief Class for an LQ24 compatible printer.
 *
 * This is Epson's 24-bit dot matrix printers.
 *
 * @author Robert Heller \<heller\@deepsoft.com\>
 *
 */
class LQ24PrinterDevice : public PrinterDevice {
public:
#ifdef SWIG
	/* Constructor. Create a new printer device instance from a set of parameters,
	   all of which are defaultable.
	 @param filename Output filename.
	 @param title An internal document title string.
	 @param pageSize The page size to use.
	 */
	LQ24PrinterDevice(const char * filename="",const char *title="",PageSize pageSize = Letter,char **outmessage=NULL);
#else
	/** @brief Constructor.
	  * Create a new printer device instance from a set of parameters,
	  * all of which have default values, so this also doubles as the
	  * default base constructor.
	  *
	  * @param filename Output filename.
	  * @param title An internal document title string.
	  * @param pageSize The page size to use.  This parameter is not used.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	LQ24PrinterDevice(const string filename="",const string title="",
			  PageSize pageSize = Letter,char **outmessage=NULL);
#endif
#ifndef SWIG
	/** Member function to open the printer.
	  * @param filename Output filename.
	  * @param pageSize The page size to use.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	virtual bool OpenPrinter(const string filename,
				 PageSize pageSize = Letter,
				 char **outmessage=NULL);
	/** Close the printer.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	virtual bool ClosePrinter(char **outmessage);
	/** Set the the spacing.
	  *  @param spacing The new type spacing.
	  */
	virtual bool SetTypeSpacing(TypeSpacing spacing);
	/** Set the type weight.
	  * @param weight The new type weight.
	   */
	virtual bool SetTypeWeight(TypeWeight weight);
	/** Set the type slant.
	  *  @param slant The new type slant.
	  */
	virtual bool SetTypeSlant(TypeSlant slant);
	/** Perform a page feed and print a heading.
	  *@param heading The heading string.
	  */ 
	virtual bool NewPage(const string heading = "");
	/** Print out a string and follow it with a new line sequence.
	  * @param line The line to print.
	  */
	virtual bool PutLine(const string line);
	/** Print a string of text.  Don't include a newline.
	  * @param text The string to print.
	  */
	virtual bool Put(const string text);
	/** Tab over to the specified column.
	  * @param column The desired tab column.
	  */
	virtual bool Tab(int column);
#endif
	/** @brief Destructor.  
	  * Close the printer.
	  */
	virtual ~LQ24PrinterDevice();
#ifndef SWIG
private:
	/** Output stream.
	  */
	ofstream printerStream;
	/** Current column.
	  */
	int currentColumn;
	/** Current column fraction.
	  */
	double currentColumnFraction;
	/** Current spacing.
	  */
	TypeSpacing currentSpacing;
	/** Current weight.
	  */
	TypeWeight currentWeight;
	/** Current slant.
	  */
	TypeSlant currentSlant;
	/** One column's width fraction.
	  */
	double oneColumnWidthFraction;
	/** @brief Special character codes.
	  * These character codes introduce various special printer functions
	  * and modes.
	  */
	enum ChCodes {
		/** @brief Form feed.
		  * This code causes a page feed.
		  */		
		FF = 12,
		/** @brief Shift In
		  * This character starts condensed (half width) spacing.
		  */
		SI = 15,
		/** @brief Device control 2.
		  * This character ends condensed (half width) spacing.
		  */
		DC2 = 18,
		/** @brief Escape.
		  * This character is used to introduce a number of escape
		  * sequences to perform a number of printer functions and/or
		  * set various printing modes.
		  */
		ESC = 27
	};
#endif
};

}

/** @} */

#endif // _LQ24PRINTER_H_

