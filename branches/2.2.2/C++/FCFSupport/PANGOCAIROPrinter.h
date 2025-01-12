// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sat Aug 12 10:12:57 2017
//  Last Modified : <170814.0906>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
//			51 Locke Hill Road
//			Wendell, MA 01379-9728
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// 
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __PANGOCAIROPRINTER_H
#define __PANGOCAIROPRINTER_H

#ifndef SWIG
#include "config.h"
#include <Printer.h>
#ifdef HAVE_PANGOCAIRO
#include <cairo-pdf.h>
#include <pango/pangocairo.h>
#endif
#endif

namespace FCFSupport {

#ifdef HAVE_PANGOCAIRO

class PANGOCAIROPrinterDevice : public PrinterDevice {
public:
#ifdef SWIGTCL8
	/* Constructor.  Create a PANGOCAIRO (PDF) Printer device.
	 *  @param filename The name of the file to print to.
	 *  @param title The document title.
	 *  @param pageSize The document page size.
	 */
	PANGOCAIROPrinterDevice(const char * filename,const char *title,
			 PageSize pageSize,char **outmessage);
#else
	/** @brief Constructor.
	  * Create a PANGOCAIRO (PDF) Printer device.
	  *  @param filename The name of the file to print to.
	  *  @param title The document title.
	  *  @param pageSize The document page size.
	  *  @param outmessage Pointer to get an error message buffer pointer.
	  */
	PANGOCAIROPrinterDevice(const string filename="",const string title_ = "",
			 PageSize pageSize = Letter,char **outmessage=NULL);
#endif
#ifndef SWIG
	/** Open the printer file.
	  *  @param filename The name of the file to print to.
	  *  @param pageSize The document page size.
	  *  @param outmessage Pointer to get an error message buffer pointer.
	  */
	virtual bool OpenPrinter(const string filename,
				 PageSize pageSize = Letter,
				 char **outmessage=NULL);
	/** Close the printer.
	  *  @param outmessage Pointer to get an error message buffer pointer.
	  */
	virtual bool ClosePrinter(char **outmessage=NULL);
	/** Set the type spacing.
	  *  @param spacing The spacing value to set.
	  */
	virtual bool SetTypeSpacing(TypeSpacing spacing);
	/** Set the type weight.
	  *  @param weight The weight value to set.
	  */
	virtual bool SetTypeWeight(TypeWeight weight);
	/** Set the type slant.
	  *  @param slant The slant value to set.
	  */
	virtual bool SetTypeSlant(TypeSlant slant);
	/** Generate a new page.
	  *  @param heading The new page heading string.
	  */
	virtual bool NewPage(const string heading = "");
	/** Put a line of text.
	  *  @param line The line of text.
	  */
	virtual bool PutLine(const string line = "");
	/** Put a string.
	  *  @param text The text string to print.
	  */
	virtual bool Put(const string text);
	/** Move to the specified tab column.
	  *  @param column the column to move to.
	  */
	virtual bool Tab(int column);
#endif
	/** @brief Destructor.
	  */
	virtual ~PANGOCAIROPrinterDevice();
#ifndef SWIG
private:
    cairo_surface_t *pdf_surface;
    cairo_t *pdf_context;
    PangoLayout *layout;
    PangoFontDescription *Courier;
    PangoFontDescription *CourierBold;
    PangoFontDescription *CourierOblique;
    PangoFontDescription *CourierBoldOblique;
    TypeSlant current_slant;
    TypeWeight current_weight;
    TypeSpacing current_spacing;
    int swidth, sheight;
    /** Title string.
     */
    string title;
    /** Number of lines.
     */
    int lines;
    /** Maximum number of lines.
     */
    int maxLines;
    /** Partial line flag.
     */
    bool partline;
    /** Need page flag.
     */
    bool needPage;
    /** Current column.
     */
    int currentColumn;
    /** Current column fraction.
     */
    double currentColumnFraction;
    double putstring(const string text);
#endif
};

#endif

}

#endif // __PANGOCAIROPRINTER_H

