/* 
 * ------------------------------------------------------------------
 * PDFPrinter.cc - PDF Printer
 * Created by Robert Heller on Sun Sep 18 12:02:05 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2005/11/21 03:01:35  heller
 * Modification History: Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:06:33  heller
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

#include <PDFPrinter.h>
#include "../gettext.h"

static char Id[] = "$Id$";

namespace FCFSupport {

using namespace PDFFileStructures;

PDFPrinterDevice::PDFPrinterDevice(const string filename,
				   const string title_,PageSize pageSize_,
				   char **outmessage)
{
	title = title_;
	pageSize = pageSize_;
	lines = 0;
	switch (pageSize) {
	  case Letter: maxLines = (int)((792-72)/12.0); break;
	  case A4: maxLines = (int)((842-72)/12.0); break;
	}
	partline = false;
	needPage = true;
	isOpenP = false;
	horizontalScaling = 100;
	currentPage = NULL;
	currentStream = NULL;
	currentColumn = 0;
	currentColumnFraction = 0;
	if (filename != "") OpenPrinter(filename,pageSize_,outmessage);
}

bool PDFPrinterDevice::OpenPrinter(const string filename,PageSize pageSize_,
				   char **outmessage)
{
	static char messageBuffer[2048];

	if (isOpenP) return false;
	pageSize = pageSize_;
	switch (pageSize) {
	  case Letter: maxLines = (int)((792-72)/12.0); break;
	  case A4: maxLines = (int)((842-72)/12.0); break;
	}
	isOpenP = false;
	printerStream.open(filename.c_str());
	if (!printerStream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,
		    _("Error opening %s for output (PDFPrinterDevice)"),
		    filename.c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	isOpenP = true;
	printerStream << "%PDF-1.1" << endl;
//	printerStream << "%\200\200\200\200" << endl;
	rootDictionary = new CatalogDictionary();
	crossReferenceTable.AddIndirectObjectToTable(rootDictionary);
	info = new InformationDirectory();
	crossReferenceTable.AddIndirectObjectToTable(info);
	info->title = title;
	info->producer = "$Id$";
	info->creationDate = time(NULL);
	Rectangle *mbox;
	if (pageSize == Letter) {
		mbox = new Rectangle(0,0,612,792);
	} else {
		mbox = new Rectangle(0,0,595,842);
	}
	ResourceDictionary *resources = new ResourceDictionary();
	resources->AddProcSet("PDF");
	resources->AddProcSet("Text");
	PostScriptStandardType1FontDictionary *font;
	font = new PostScriptStandardType1FontDictionary("Courier");
	crossReferenceTable.AddIndirectObjectToTable(font);
	font->WriteObjectToFile(printerStream);
	resources->AddFont("Roman",font);
	font = new PostScriptStandardType1FontDictionary("Courier-Bold");
	crossReferenceTable.AddIndirectObjectToTable(font);
	font->WriteObjectToFile(printerStream);
	resources->AddFont("Bold",font);
	font = new PostScriptStandardType1FontDictionary("Courier-Oblique");
	crossReferenceTable.AddIndirectObjectToTable(font);
	font->WriteObjectToFile(printerStream);
	resources->AddFont("Italic",font);
	font = new PostScriptStandardType1FontDictionary("Courier-BoldOblique");
	crossReferenceTable.AddIndirectObjectToTable(font);
	font->WriteObjectToFile(printerStream);
	resources->AddFont("BoldItalic",font);
	pageTreeRoot = new PageTree(resources,mbox);
	crossReferenceTable.AddIndirectObjectToTable(pageTreeRoot);
	rootDictionary->AddPageTree(pageTreeRoot);
	currentFontName = "Roman";
//	currentPage = new Page();
//	crossReferenceTable.AddIndirectObjectToTable(currentPage);
//	rootDictionary->AddPage(currentPage);
	needPage = true;
	currentPage = NULL;
	currentStream = NULL;
	return false;
}

bool PDFPrinterDevice::ClosePrinter(char **outmessage)
{
	if (!isOpenP) return false;
	info->WriteObjectToFile(printerStream);
	if (currentStream != NULL) {
		(*currentStream) << "ET" << endl;
		currentStream->WriteObjectToFile(printerStream);
		if (needPage) CreateNewPage();
		currentPage->AppendStream(currentStream);
		currentStream = NULL;
	}
	if (currentPage != NULL) {
		currentPage->WriteObjectToFile(printerStream);
	}
	pageTreeRoot->WriteObjectToFile(printerStream);
	rootDictionary->WriteObjectToFile(printerStream);
	streampos xrefPos = crossReferenceTable.WriteTable(printerStream);
	printerStream << "trailer" << endl;
	printerStream << "<< /Size "
		      << crossReferenceTable.HighestObjectNumber() + 1
		      << " /Root ";
	rootDictionary->WriteIndirectReference(printerStream) << endl;
	printerStream << " /Info ";
	info->WriteIndirectReference(printerStream) << endl;
	printerStream << ">>" << endl;
	printerStream << "startxref" << endl;
	printerStream << xrefPos << endl;
	printerStream << "%%EOF" << endl;
	printerStream.close();
	isOpenP = false;
	return true;
}

bool PDFPrinterDevice::SetTypeSpacing(TypeSpacing spacing)
{
	if (!isOpenP) return false;
	switch (spacing) {
	  case One: horizontalScaling = 100; break;
	  case Double: horizontalScaling = 200; break;
	  case Half: horizontalScaling = 60; break;
	}
	if (currentStream == NULL) {
	  CreateNewStream();
	} else {
	  (*currentStream) << "  " << horizontalScaling << " Tz" << endl;
	}	
	return true;
}

bool PDFPrinterDevice::SetTypeWeight(TypeWeight weight)
{
	if (!isOpenP) return false;
	switch (weight) {
	  case Bold:   if (currentFontName == "Roman") currentFontName = "Bold";
	  	       else if (currentFontName == "Italic") currentFontName = "BoldItalic";
	  	       break;
	  case Normal: if (currentFontName == "Bold") currentFontName = "Roman";
	  	       else if (currentFontName == "BoldItalic") currentFontName = "Italic";
	  	       break;
	}
	if (currentStream == NULL) {
	  CreateNewStream();
	} else {
	  (*currentStream) << "  /" << currentFontName << " 10 Tf" << endl;
	  (*currentStream) << "  " << horizontalScaling << " Tz" << endl;
	}
	return true;
}

bool PDFPrinterDevice::SetTypeSlant(TypeSlant slant)
{
	if (!isOpenP) return false;
	switch (slant) {
	  case Roman:  if (currentFontName == "Italic") currentFontName = "Roman";
	  	       else if (currentFontName == "BoldItalic") currentFontName = "Bold";
	  	       break;
	  case Italic: if (currentFontName == "Roman") currentFontName = "Italic";
		       else if (currentFontName == "Bold") currentFontName = "BoldItalic";
		       break;
	}
	if (currentStream == NULL) {
	  CreateNewStream();
	} else {
	  (*currentStream) << "  /" << currentFontName << " 10 Tf" << endl;
	  (*currentStream) << "  " << horizontalScaling << " Tz" << endl;
	}
	return true;
}

bool PDFPrinterDevice::CreateNewStream()
{
	currentStream = new PDFStream();
	crossReferenceTable.AddIndirectObjectToTable(currentStream);
	(*currentStream) << "BT" << endl;
	(*currentStream) << "  /" << currentFontName << " 10 Tf" << endl;
	(*currentStream) << "  " << horizontalScaling << " Tz" << endl;
	(*currentStream) << "  " << .5 * 72;
	switch (pageSize) {
	  case Letter: (*currentStream) << " " << 10.5 * 72; break;
	  case A4:     (*currentStream) << " " << 11 * 72; break;
	}
	(*currentStream) << " Td" << endl;
	(*currentStream) << "  12 TL" << endl;
	lines = 0;
	return true;
}	

bool PDFPrinterDevice::NewPage(const string heading)
{
	if (!isOpenP) return false;
	if (currentStream != NULL) {
		(*currentStream) << "ET" << endl;
		currentStream->WriteObjectToFile(printerStream);
		if (needPage) CreateNewPage();
		currentPage->AppendStream(currentStream);
		currentStream = NULL;
	}
	if (currentPage != NULL) {
		currentPage->WriteObjectToFile(printerStream);
		
	}
	currentPage = NULL;
	needPage = true;
	if (heading != "") return Put(heading);
	else return true;
}

bool PDFPrinterDevice::PutLine(const string line)
{
	if (!isOpenP) return false;
	if (line != "") Put(line);
	if (currentStream == NULL) {CreateNewStream();}
	(*currentStream) << "  T*" << endl;
	partline = false;
	lines++;
	if (lines >= maxLines) NewPage("");
	currentColumn = 0;
	currentColumnFraction = 0;
	return true;
}

bool PDFPrinterDevice::Put(const string text)
{
	string::size_type nl, lastnl = string::npos;
	if (!isOpenP) return false;
	while ((nl = text.find('\n',lastnl+1)) != string::npos) {
		if (currentStream == NULL) {CreateNewStream();}
		(*currentStream) << "  (" << QuotePDFString(text.substr(lastnl+1,nl-lastnl-1)) << ") Tj T*" << endl;
		currentColumn = 0;
		currentColumnFraction = 0;
		lastnl = nl;
		partline = false;
		lines++;
#ifdef DEBUG
		cerr << "*** PostScriptPrinterDevice::Put: lines = " << lines << endl;
#endif
		if (lines >= maxLines) NewPage("");
	}
	if (lastnl+1 < text.length()) {
		if (currentStream == NULL) {CreateNewStream();}
		(*currentStream) << "  (" << QuotePDFString(text.substr(lastnl+1)) << ") Tj" << endl;;
		currentColumnFraction += (text.substr(lastnl+1).length() * oneColumnWidthFraction);
		currentColumn = (int) currentColumnFraction;
		partline = true;
	}
	return true;
	
}

bool PDFPrinterDevice::Tab(int column)
{
	if (!isOpenP) return false;
	while (currentColumn < column) Put(" ");
	return true;
}

PDFPrinterDevice::~PDFPrinterDevice()
{
	if (isOpenP) ClosePrinter();
}

bool PDFPrinterDevice::CreateNewPage()
{
	if (!isOpenP) return false;
	if (needPage) {
		currentPage = new Page();
		crossReferenceTable.AddIndirectObjectToTable(currentPage);
		rootDictionary->AddPage(currentPage);
		needPage = false;
	}
	return true;
}
}
