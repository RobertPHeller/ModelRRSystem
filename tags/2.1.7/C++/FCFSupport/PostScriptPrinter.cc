/* 
 * ------------------------------------------------------------------
 * PostScriptPrinter.cc - PostScript Printer
 * Created by Robert Heller on Sun Sep 18 12:01:08 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.2  2005/11/05 05:52:08  heller
 * Modification History: Upgraded for G++ 3.2
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

#include <PostScriptPrinter.h>

static char Id[] = "$Id$";

PostScriptPrinterDevice::PostScriptPrinterDevice(const string filename,const string title_,PageSize pageSize_,char **outmessage)
{
	title = title_;
	pageSize = pageSize_;
	pages = 0;
	lines = 0;
	switch (pageSize) {
	  case Letter: maxLines = (int)((792-72)/12.0); break;
	  case A4: maxLines = (int)((842-72)/12.0); break;
	}
#ifdef DEBUG
	cerr << "*** PostScriptPrinterDevice::PostScriptPrinterDevice: maxLines = " << maxLines << endl;
#endif
	partline = false;
	needPageHeader = true;
	isOpenP = false;
	if (filename != "") OpenPrinter(filename,pageSize_,outmessage);
}

bool PostScriptPrinterDevice::OpenPrinter(const string filename,PageSize pageSize_,char **outmessage)
{
	static char messageBuffer[2048];

	if (isOpenP) return false;
	pageSize = pageSize_;
	switch (pageSize) {
	  case Letter: maxLines = (int)((792-72)/12.0); break;
	  case A4: maxLines = (int)((842-72)/12.0); break;
	}
#ifdef DEBUG
	cerr << "*** PostScriptPrinterDevice::OpenPrinter: maxLines = " << maxLines << endl;
#endif
	isOpenP = false;
	printerStream.open(filename.c_str());
	if (!printerStream) {
	  if (outmessage != NULL) {
	    sprintf(messageBuffer,
		    "Error opening %s for output (PostScriptPrinterDevice)",
		    filename.c_str());
	    *outmessage = new char[strlen(messageBuffer)+1];
	    strcpy(*outmessage,messageBuffer);
	  }
	  return false;
	}
	printerStream << "%!PS-Adobe-2.0" << endl;
	printerStream << "%%Creator:  " << Id << endl;
	if (title.length() > 0) {
	  printerStream << "%%Title: " << title << endl;
	}
	printerStream << "%%Pages: (atend)" << endl;
	switch (pageSize) {
	  case Letter: printerStream << "%%BoundingBox: 0 0 612 792" << endl;
		       break;
	  case A4: printerStream << "%%BoundingBox: 0 0 595 842" << endl;
		   break;
	}
	printerStream << "%%EndComments" << endl;
	printerStream << "%%BeginProlog" << endl;
	printerStream << "/FCFDict 20 dict def" << endl;
	printerStream << "/FCFDictLocals 10 dict def" << endl;
	printerStream << "FCFDict begin" << endl;
	printerStream << "/inch {72 mul} def" << endl;
	printerStream << "/LineHeight 12 def" << endl;
	printerStream << "/LeftMargin .5 inch def" << endl;
	switch (pageSize) {
	  case Letter: printerStream << "/TopOfPage 10.5 inch def" << endl;
	  	       break;
	  case A4: printerStream << "/TopOfPage 11 inch def" << endl;
	           break;
	}
	printerStream << "/FontName /Courier def" << endl;
	printerStream << "/NormalMatrix [10 0 0 10 0 0] def" << endl;
	printerStream << "/DoubleWMatrix [20 0 0 10 0 0] def" << endl;
	printerStream << "/NarrowMatrix [6 0 0 10 0 0] def" << endl;
	printerStream << "/CurrentMatrix NormalMatrix def" << endl;
	printerStream << "/CurrentWeight () def" << endl;
	printerStream << "/CurrentSlant  () def" << endl;
	printerStream << "/putPrinterRoman" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    /CurrentSlant () def" << endl;
	printerStream << "    setPrinterFont" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterItalic" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    /CurrentSlant (Oblique) def" << endl;
	printerStream << "    setPrinterFont" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterNormal" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    /CurrentWeight () def" << endl;
	printerStream << "    setPrinterFont" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterBold" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    /CurrentWeight (Bold) def" << endl;
	printerStream << "    setPrinterFont" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/setPrinterFont" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    /FontName CurrentWeight () " << endl;
	printerStream << "         eq {CurrentSlant () eq {/Courier}" << endl;
	printerStream << "                                {/Courier-Oblique} ifelse}" << endl;
	printerStream << "            {CurrentSlant () eq {/Courier-Bold}" << endl;
	printerStream << "                                {/Courier-BoldOblique} ifelse}" << endl;
	printerStream << "         ifelse def" << endl;
	printerStream << "    FontName findfont CurrentMatrix makefont setfont" << endl;
	printerStream << "    /SpaceWidth ( ) stringwidth pop def" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterNormalWidth" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    FontName findfont NormalMatrix makefont setfont" << endl;
	printerStream << "    /SpaceWidth ( ) stringwidth pop def" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterNarrow" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    FontName findfont NarrowMatrix makefont setfont" << endl;
	printerStream << "    /SpaceWidth ( ) stringwidth pop def" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterDouble" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    FontName findfont DoubleWMatrix makefont setfont" << endl;
	printerStream << "    /SpaceWidth ( ) stringwidth pop def" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterTab" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    dup CurrentColumn sub dup 0 le " << endl;
	printerStream << "    {pop pop} " << endl;
	printerStream << "    {SpaceWidth mul xpos add /xpos exch def /CurrentColumn exch def} ifelse" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterString" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    xpos ypos moveto" << endl;
	printerStream << "    dup stringwidth pop dup " << endl;
	printerStream << "	SpaceWidth div CurrentColumn add /CurrentColumn exch def " << endl;
	printerStream << "	xpos add /xpos exch def" << endl;
	printerStream << "    show" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/newline" << endl;
	printerStream << "  { FCFDictLocals begin" << endl;
	printerStream << "    /xpos LeftMargin def" << endl;
	printerStream << "    /ypos ypos LineHeight sub def" << endl;
	printerStream << "    /CurrentColumn 1 def" << endl;
	printerStream << "  end } def" << endl;
	printerStream << "/putPrinterLine" << endl;
	printerStream << "  { putPrinterString" << endl;
	printerStream << "    newline" << endl;
	printerStream << "  } def" << endl;
	printerStream << "FCFDictLocals begin" << endl;
	printerStream << "  /xpos LeftMargin def" << endl;
	printerStream << "  /ypos TopOfPage def" << endl;
	printerStream << "  /CurrentColumn 1 def " << endl;
	printerStream << "  FontName findfont NormalMatrix makefont setfont" << endl;
	printerStream << "  /SpaceWidth ( ) stringwidth pop def" << endl;
	printerStream << "end" << endl;
	printerStream << "%%EndProlog" << endl;
	pages = 0;
	lines = 0;
	partline = false;
	needPageHeader = true;
	isOpenP = true;
	return true;
}

bool PostScriptPrinterDevice::ClosePrinter(char **outmessage)
{
	if (!isOpenP) return false;
	if (!needPageHeader) {
	  if (partline) PutLine("");
	  NewPage("");
	}
	printerStream << endl << "%%Trailer" << endl <<
			"%%Pages: " << pages << endl << "%%EOF" << endl;
	printerStream.close();
	isOpenP = false;
	return true;
}

PostScriptPrinterDevice::~PostScriptPrinterDevice()
{
	ClosePrinter(NULL);
}  

bool PostScriptPrinterDevice::SetTypeSpacing(TypeSpacing spacing)
{
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	switch (spacing) {
	  case One: printerStream << "putPrinterNormalWidth" << endl; break;
	  case Double: printerStream << "putPrinterDouble" << endl; break;
	  case Half: printerStream << "putPrinterNarrow" << endl; break;
	}
	return true;
}

bool PostScriptPrinterDevice::SetTypeWeight(TypeWeight weight)
{
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	switch (weight) {
	  case Normal: printerStream << "putPrinterNormal" << endl; break;
	  case Bold:   printerStream << "putPrinterBold" << endl; break;
	}
	return true;
}

bool PostScriptPrinterDevice::SetTypeSlant(TypeSlant slant)
{
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	switch (slant) {
	  case Roman:  printerStream << "putPrinterRoman" << endl; break;
	  case Italic: printerStream << "putPrinterItalic" << endl; break;
	}
	return true;
}

bool PostScriptPrinterDevice::NewPage(const string heading)
{
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	if (partline) PutLine("");
	partline = false;
	printerStream << "showpage" << endl;
	lines = 0;
	needPageHeader = true;
	if (heading.length() > 0) PutLine(heading);
	return true;
}

bool PostScriptPrinterDevice::PutPageHeader()
{
	if (!isOpenP) return false;
	if (!needPageHeader) return true;
	pages++;
        printerStream << "%%Page: " << pages << " " << pages << endl;
	printerStream << "FCFDictLocals begin" << endl;
	printerStream << "  /xpos LeftMargin def" << endl;
	printerStream << "  /ypos TopOfPage def" << endl;
	printerStream << "  /CurrentColumn 1 def" << endl;
	printerStream << "end" << endl;
	needPageHeader = false;
	return true;
}

const string PostScriptPrinterDevice::PSQuote(const string s) const
{
	string result;
	int esc, lastesc = -1;
	while ((esc = s.find_first_of("\\()%",lastesc+1)) != string::npos) {
		result += s.substr(lastesc+1,esc-lastesc-1);
		result += '\\';
		result += s[esc];
		lastesc = esc;
	}
	if (lastesc+1 < s.length()) result += s.substr(lastesc+1);
	return result;
}

bool PostScriptPrinterDevice::PutLine(const string line)
{
	int nl, lastnl = -1;
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	while ((nl = line.find('\n',lastnl+1)) != string::npos) {
		if (needPageHeader) PutPageHeader();
		printerStream << "(" << PSQuote(line.substr(lastnl+1,nl-lastnl-1)) << ") putPrinterLine" << endl;
		lastnl = nl;
		partline = false;
		lines++;
#ifdef DEBUG
		cerr << "*** PostScriptPrinterDevice::PutLine: (1) lines = " << lines << endl;
#endif
		if (lines >= maxLines) NewPage("");
	}
	if (needPageHeader) PutPageHeader();
	if (lastnl+1 < line.length()) {
		printerStream << "(" << PSQuote(line.substr(lastnl+1)) << ") putPrinterLine"  << endl;
	} else printerStream << "newline" << endl;
	partline = false;
	lines++;
#ifdef DEBUG
	cerr << "*** PostScriptPrinterDevice::PutLine: (2) lines = " << lines << endl;
#endif
	if (lines >= maxLines) NewPage("");
	return true;	
}

bool PostScriptPrinterDevice::Put(const string text)
{
	int nl, lastnl = -1;
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	while ((nl = text.find('\n',lastnl+1)) != string::npos) {
		if (needPageHeader) PutPageHeader();
		printerStream << "(" << PSQuote(text.substr(lastnl+1,nl-lastnl-1)) << ") putPrinterLine" << endl;
		lastnl = nl;
		partline = false;
		lines++;
#ifdef DEBUG
		cerr << "*** PostScriptPrinterDevice::Put: lines = " << lines << endl;
#endif
		if (lines >= maxLines) NewPage("");
	}
	if (lastnl+1 < text.length()) {
		if (needPageHeader) PutPageHeader();
		printerStream << "(" << PSQuote(text.substr(lastnl+1)) << ") putPrinterString" << endl;;
		partline = true;
	}
	return true;
}

bool PostScriptPrinterDevice::Tab(int column)
{
	if (!isOpenP) return false;
	if (needPageHeader) PutPageHeader();
	printerStream << column << " putPrinterTab" << endl;
	return true;
}


