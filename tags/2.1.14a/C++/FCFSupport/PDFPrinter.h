/* 
 * ------------------------------------------------------------------
 * PDFPrinter.h - PDF Printer
 * Created by Robert Heller on Sun Sep 18 12:01:45 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.5  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.4  2005/11/21 03:01:35  heller
 * Modification History: Lockdown
 * Modification History:
 * Modification History: Revision 1.3  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
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

#ifndef _PDFPRINTER_H_
#define _PDFPRINTER_H_

#ifndef SWIG
#include <Printer.h>
#include <PDFPrinterSupport.h>
#include <map>


#endif

/** PDF Printer device
  */
class PDFPrinterDevice : public PrinterDevice {
public:
#ifdef SWIG
	/* Constructor.  Create a PDF Printer device.
	 *  @param filename The name of the file to print to.
	 *  @param title The document title.
	 *  @param pageSize The document page size.
	 */
	PDFPrinterDevice(const char * filename="",const char *title="",
			 PageSize pageSize = Letter,char **outmessage=NULL);
#else
	/** @memo Constructor.
	  * @doc Create a PDF Printer device.
	  *  @param filename The name of the file to print to.
	  *  @param title The document title.
	  *  @param pageSize The document page size.
	  *  @param outmessage Pointer to get an error message buffer pointer.
	  */
	PDFPrinterDevice(const string filename="",const string title_ = "",
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
	/** @memo Destructor.
	  */
	virtual ~PDFPrinterDevice();
#ifndef SWIG
	//using namespace PDFFileStructures;
private:
	/** PDF Cross reference table.
	  */
	PDFFileStructures::CrossReferenceTable crossReferenceTable;
	/** PDF Root catalog.
	  */
	PDFFileStructures::CatalogDictionary *rootDictionary;
	/** Current PDF Page.
	  */
	PDFFileStructures::Page *currentPage;
	/** Current PDF Stream
	  */
	PDFFileStructures::PDFStream *currentStream;
	/** PDF Page Tree root.
	  */
	PDFFileStructures::PageTree *pageTreeRoot;
	/** Information dictionary.
	  */
	PDFFileStructures::InformationDirectory *info;
	/** Output stream.
	  */
	ofstream printerStream;
	/** Title string.
	  */
	string title;
	/** Current font name.
	  */
	string currentFontName;
	/** Number of lines.
	  */
	int lines;
	/** Current horizontal scaling.
	  */
	int horizontalScaling;
	/** Maximum number of lines.
	  */
	int maxLines;
	/** Partial line flag.
	  */
	bool partline;
	/** Need page flag.
	  */
	bool needPage;
	/** Create a new page.
	  */
	bool CreateNewPage();
	/** Create new stream.
	  */
	bool CreateNewStream();
	/** Current column.
	  */
	int currentColumn;
	/** Current column fraction.
	  */
	double currentColumnFraction;
#define oneColumnWidthFraction (((double)horizontalScaling)/100.0)
#endif
};

	

#endif // _PDFPRINTER_H_

