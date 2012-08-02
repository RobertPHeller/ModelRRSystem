/* 
 * ------------------------------------------------------------------
 * PostScriptPrinter.h - PostScript Printer
 * Created by Robert Heller on Sun Sep 18 12:00:48 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:21  heller
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

#ifndef _POSTSCRIPTPRINTER_H_
#define _POSTSCRIPTPRINTER_H_

#ifndef SWIG
#include <Printer.h>
#endif

/** @addtogroup FCFSupport
  * @{
  */

namespace FCFSupport {

/** @brief Derived class for printing on Postscript printers.
 *
 * Uses a standard 12pt Courier family of fonts and simulates an impact
 * printer.
 *
 * @author Robert Heller \<heller\@deepsoft.com\>
 *
 */
class PostScriptPrinterDevice : public PrinterDevice {
public:
#ifdef SWIGTCL8
	/* Constructor. Create a new printer device instance from a set of parameters,
	   all of which are defaultable.
	 @param filename Output filename.
	 @param title An internal document title string.
	 @param pageSize The page size to use.
	 */
	PostScriptPrinterDevice(const char * filename,const char *title,PageSize pageSize,char **outmessage);
#else
	/** @brief Constructor.
	  * Create a new printer device instance from a set of parameters,
	  * all of which have default values, so this also doubles as the
	  * default base constructor.
	  *
	  * @param filename Output filename.
	  * @param title An internal document title string.
	  * @param pageSize The page size to use.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	PostScriptPrinterDevice(const string filename="",const string title_ = "",PageSize pageSize = Letter,char **outmessage=NULL);
#endif
#ifndef SWIG
	/** Member function to open the printer.
	  * @param filename Output filename.
	  * @param pageSize The page size to use.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	virtual bool OpenPrinter(const string filename,PageSize pageSize = Letter,char **outmessage=NULL);
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
	virtual bool PutLine(const string line = "");
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
	virtual ~PostScriptPrinterDevice();
#ifndef SWIG
private:
	/** Output stream.
	  */
	ofstream printerStream;
	/** The document title.
	  */
	string title;
	/** The page count.
	  */
	int pages;
	/** The line count.
	  */
	int lines;
	/** The maximum number of lines per page.
	  */
	int maxLines;
	/** Partial line flag.
	  */
	bool partline;
	/** Flag to let us know if we need a page header,
	  */
	bool needPageHeader;
	/** Function to put the page header.
	  */
	bool PutPageHeader();
	/** Function to PostScript quote a string.
	  * @param s The string to quote.
	  */
	const string PSQuote(const string s) const;
#endif
};

}

/** @} */

#endif // _POSTSCRIPTPRINTER_H_

