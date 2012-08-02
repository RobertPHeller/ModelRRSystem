/* 
 * ------------------------------------------------------------------
 * Printer.h - Printer interface code
 * Created by Robert Heller on Sat Sep 17 10:40:58 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.4  2007/04/19 17:23:21  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.3  2006/08/04 01:59:25  heller
 * Modification History: Aug 3 Lockdown
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

#ifndef _PRINTER_H_
#define _PRINTER_H_

#ifndef SWIG
#include <Common.h>
#include <iostream>
#include <fstream>
#include <stdio.h>
#endif

#ifdef SWIG

#include <string.h>

%typemap(tcl8,in) PrinterDevice::PageSize {
	char *p;
	p = Tcl_GetString($input);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (p == NULL || strlen(p) < 1) {
		Tcl_SetStringObj(tcl_result,"Missing PageSize, should be one of letter or a4",-1);
		return TCL_ERROR;
	} else if (strncasecmp("letter",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Letter;
	} else if (strncasecmp("a4",p,strlen(p)) == 0) {
		$1 = PrinterDevice::A4;
	} else {
		Tcl_SetStringObj(tcl_result,"Bad PageSize, should be one of letter or a4",-1);
		return TCL_ERROR;
	}
}

%typemap(tcl8,out) PrinterDevice::PageSize {
	Tcl_Obj *tcl_result = $result;
	switch ($1) {
		case PrinterDevice::Letter:
			Tcl_SetStringObj(tcl_result,"Letter",-1);
			break;
		case PrinterDevice::A4:
			Tcl_SetStringObj(tcl_result,"A4",-1);
			break;
		default:
			Tcl_SetStringObj(tcl_result,"Unknown page size",-1);
			return TCL_ERROR;
	}
}

%typemap(tcl8,in) PrinterDevice::TypeSpacing {
	char *p;
	p = Tcl_GetString($input);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (p == NULL || strlen(p) < 1) {
		Tcl_SetStringObj(tcl_result,"Missing TypeSpacing, should be one of one, half, or double",-1);
		return TCL_ERROR;
	} else if (strncasecmp("one",p,strlen(p)) == 0) {
		$1 = PrinterDevice::One;
	} else if (strncasecmp("half",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Half;
	} else if (strncasecmp("double",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Double;
	} else {
		Tcl_SetStringObj(tcl_result,"Bad TypeSpacing, should be one of one, half, or double",-1);
		return TCL_ERROR;
	}
}

%typemap(tcl8,out) PrinterDevice::TypeSpacing {
	Tcl_Obj *tcl_result = $result;
	switch ($1) {
		case PrinterDevice::One:
			Tcl_SetStringObj(tcl_result,"One",-1);
			break;
		case PrinterDevice::Half:
			Tcl_SetStringObj(tcl_result,"Half",-1);
			break;
		case PrinterDevice::Double:
			Tcl_SetStringObj(tcl_result,"Double",-1);
			break;
		default:
			Tcl_SetStringObj(tcl_result,"Unknown type spacing",-1);
			return TCL_ERROR;
	}
}

%typemap(tcl8,in) PrinterDevice::TypeWeight {
	char *p;
	p = Tcl_GetString($input);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (p == NULL || strlen(p) < 1) {
		Tcl_SetStringObj(tcl_result,"Missing TypeWeight, should be one of normal or bold",-1);
		return TCL_ERROR;
	} else if (strncasecmp("normal",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Normal;
	} else if (strncasecmp("bold",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Bold;
	} else {
		Tcl_SetStringObj(tcl_result,"Bad TypeWeight, should be one of normal or bold",-1);
		return TCL_ERROR;
	}
}

%typemap(tcl8,out) PrinterDevice::TypeWeight {
	Tcl_Obj *tcl_result = $result;
	switch ($1) {
		case PrinterDevice::Normal:
			Tcl_SetStringObj(tcl_result,"Normal",-1);
			break;
		case PrinterDevice::Bold:
			Tcl_SetStringObj(tcl_result,"Bold",-1);
			break;
		default:
			Tcl_SetStringObj(tcl_result,"Unknown type weight",-1);
			return TCL_ERROR;
	}
}

%typemap(tcl8,in) PrinterDevice::TypeSlant {
	char *p;
	p = Tcl_GetString($input);
	Tcl_Obj *tcl_result = Tcl_GetObjResult(interp);
	if (p == NULL || strlen(p) < 1) {
		Tcl_SetStringObj(tcl_result,"Missing TypeSlant, should be one of roman or italic",-1);
		return TCL_ERROR;
	} else if (strncasecmp("roman",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Roman;
	} else if (strncasecmp("italic",p,strlen(p)) == 0) {
		$1 = PrinterDevice::Italic;
	} else {
		Tcl_SetStringObj(tcl_result,"Bad TypeSlant, should be one of roman or italic",-1);
		return TCL_ERROR;
	}
}

%typemap(tcl8,out) PrinterDevice::TypeSlant {
	Tcl_Obj *tcl_result = $result;
	switch ($1) {
		case PrinterDevice::Roman:
			Tcl_SetStringObj(tcl_result,"Roman",-1);
			break;
		case PrinterDevice::Italic:
			Tcl_SetStringObj(tcl_result,"Italic",-1);
			break;
		default:
			Tcl_SetStringObj(tcl_result,"Unknown type slant",-1);
			return TCL_ERROR;
	}
}


#endif

/** Base class for printer devices (hard copy output).  Defines a very basic
  * set of printing operations, including printing strings, numbers, lines,
  * form feeds, tabbing, and changing the spacing, weight, and slant of
  * the type used.
  */
class PrinterDevice {
public:
	/** Page size selection, for those printers that support different
	  * page sizes.
	  */
	enum PageSize {
		/** US Letter page size.
		  */
		Letter,
		/** European A4 page size.
		  */
		A4
	};
#ifdef SWIG
	/* Constructor. Create a new printer device instance from a set of
	   parameters, all of which are defaultable.
	 @param filename Output filename.
	 @param title An internal document title string.
	 @param pageSize The page size to use.
	 */
	PrinterDevice(const char * filename="",const char *title="",
		      PageSize pageSize = Letter,char **outmessage=NULL);
#else
	/** @memo Constructor.
	  * @doc Create a new printer device instance from a set of parameters,
	  * all of which have default values, so this also doubles as the
	  * default base constructor.
	  *
	  * @param filename Output filename.
	  * @param title An internal document title string.
	  * @param pageSize_ The page size to use.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	PrinterDevice(const string filename="",const string title="",
		      PageSize pageSize_ = Letter,char **outmessage=NULL) {
		pageSize = pageSize_;
		isOpenP = false;
	}
#endif
#ifdef SWIG
	/* Member function to open the printer.
	 @param filename Output filename.
	 @param pageSize The page size to use.
	 */
	virtual bool OpenPrinter(const char * filename,
			         PageSize pageSize = Letter,
				 char **outmessage=NULL);
#else
	/** Member function to open the printer.
	  * @param filename Output filename.
	  * @param pageSize The page size to use.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	virtual bool OpenPrinter(const string filename,
				 PageSize pageSize_ = Letter,
				 char **outmessage=NULL) {isOpenP = true;
							  pageSize = pageSize_;}
#endif
	/** Close the printer.
	  * @param outmessage Pointer to a pointer to receive any error messages
	  *		  for any errors that might occur. This parameter is
	  *		  hidden from the Tcl interface.
	  */
	virtual bool ClosePrinter(char **outmessage) {isOpenP = false;}
	/** Is the printer open?
	  */
	bool IsOpenP() const {return isOpenP;}
	/** Return the page size.
	  */
	PageSize PrinterPageSize() const {return pageSize;}
	/** Horizontal type spacing.  This is the character width.
	  */
	enum TypeSpacing {
		/** Single wide characters. Normal width charactes.
		  */
		One,
		/** Half (actually 60%) wide characters.  Condensed printing.
		  */
		Half, 
		/** Double wide characters.
		  */
		Double
	};
	/** Type weight.
	  */
	enum TypeWeight  {
		/** Normal weight.
		  */
		Normal,
		/** Heavy (bold) weight.
		  */
		Bold
	};
	/** Type slant
	  */
	enum TypeSlant   {
		/** Upright.
		  */
		Roman,
		/** Italic.
		  */
		Italic
	};
	/** Set the the spacing.
	  *  @param spacing The new type spacing.
	  */
	virtual bool SetTypeSpacing(TypeSpacing spacing) {}
	/** Set the type weight.
	  * @param weight The new type weight.
	   */
	virtual bool SetTypeWeight(TypeWeight weight) {}
	/** Set the type slant.
	  *  @param slant The new type slant.
	  */
	virtual bool SetTypeSlant(TypeSlant slant) {}
#ifdef SWIG
	/* Perform a page feed and print a heading.
	 @param heading The heading string.
	 */
	virtual bool NewPage(const char * heading = "");
#else
	/** Perform a page feed and print a heading.
	  *@param heading The heading string.
	  */ 
	virtual bool NewPage(const string heading = "") {}
#endif
#ifdef SWIG
	/* Print out a string and follow it with a new line sequence.
	 @param line The line to print.
	 */
	virtual bool PutLine(const char * line = "");
#else
	/** Print out a string and follow it with a new line sequence.
	  * @param line The line to print.
	  */
	virtual bool PutLine(const string line = "") {}
#endif
#ifdef SWIG
	/* Print a string of text.  Don't include a newline.
	 @param text The string to print.
	 */
	virtual bool Put(const char * text);
#else
	/** Print a string of text.  Don't include a newline.
	  * @param text The string to print.
	  */
	virtual bool Put(const string text) {}
	/** Print an integer.  Don't include a newline.
	  * @param number The string to print.
	  */
	virtual bool Put(int number) {
		char buffer[32];
		sprintf(buffer,"%d",number);
		Put(buffer);
		return true;
	}
	/** Print a double.  Don't include a newline.
	  * @param number The string to print.
	  */
	virtual bool Put(double number) {
		char buffer[32];
		sprintf(buffer,"%g",number);
		Put(buffer);
                return true;
	}
#endif
	/** Tab over to the specified column.
	  * @param column The desired tab column.
	  */
	virtual bool Tab(int column) {}
	/** @memo Destructor.  
	  * @doc Close the printer.
	  */
	virtual ~PrinterDevice() {ClosePrinter(NULL);}
#ifndef SWIG
protected:
	/** Is open flag.
	  */
	bool isOpenP;
	/** Document page size.
	  */
	PageSize pageSize;
#endif
};

#endif // _PRINTER_H_

