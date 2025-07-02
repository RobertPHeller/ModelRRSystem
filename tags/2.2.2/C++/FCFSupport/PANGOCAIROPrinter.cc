// -!- C++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Sat Aug 12 10:13:14 2017
//  Last Modified : <170814.0911>
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

static const char rcsid[] = "@(#) : $Id$";

#include "config.h"
#include <PANGOCAIROPrinter.h>
#include "../gettext.h"
namespace FCFSupport {

#ifdef HAVE_PANGOCAIRO



PANGOCAIROPrinterDevice::PANGOCAIROPrinterDevice(const string filename,
                                                 const string title_,
                                                 PageSize pageSize_,
                                                 char **outmessage) {
    title = title_;
    pageSize = pageSize_;
    lines = 0;
    switch (pageSize) {
    case Letter: swidth = 8.5*72; sheight = 11*72; break;
    case A4: swidth = 595; sheight = 842; break;
    }
    maxLines = (int)((sheight-72)/12.0);
    partline = false;
    needPage = true;
    isOpenP = false;
    currentColumn = 0;
    currentColumnFraction = 0;
    current_slant = Roman;
    current_weight = Normal;
    current_spacing = One;
    if (filename != "") OpenPrinter(filename,pageSize_,outmessage);
}

PANGOCAIROPrinterDevice::~PANGOCAIROPrinterDevice() {
    if (isOpenP) ClosePrinter();
}

bool PANGOCAIROPrinterDevice::OpenPrinter(const string filename,PageSize pageSize_,
                                     char **outmessage) {
    static char messageBuffer[2048];
    if (isOpenP) return false;
    pageSize = pageSize_;
    lines = 0;
    switch (pageSize) {
    case Letter: swidth = 8.5*72; sheight = 11*72; break;
    case A4: swidth = 595; sheight = 842; break;
    }
    maxLines = (int)((sheight-72)/12.0);
    partline = false;
    isOpenP = false;
    partline = false;
    currentColumn = 0;
    currentColumnFraction = 0;
    current_slant = Roman;
    current_weight = Normal;
    current_spacing = One;
    pdf_surface = cairo_pdf_surface_create(filename.c_str(),swidth,sheight);
    if (!pdf_surface) {
        if (outmessage != NULL) {
            snprintf(messageBuffer,sizeof(messageBuffer),
                     _("Error opening %s for output (PANGOCAIROPrinterDevice)"),
                     filename.c_str());
            *outmessage = new char[strlen(messageBuffer)+1];
            strcpy(*outmessage,messageBuffer);
        }
        return false;
    }
    pdf_context = cairo_create (pdf_surface);
    layout = pango_cairo_create_layout (pdf_context);
    Courier = pango_font_description_from_string ("Courier 10px");
    CourierBold = pango_font_description_from_string ("Courier Bold 10px");
    CourierOblique = pango_font_description_from_string ("Courier Oblique 10px");
    CourierBoldOblique = pango_font_description_from_string ("Courier BoldOblique 10px");

    cairo_set_source_rgb (pdf_context, 0, 0, 0);
    needPage = false;
    isOpenP = true;
    return true;
}

bool PANGOCAIROPrinterDevice::ClosePrinter(char **outmessage) {
    
    if (!isOpenP) return false;
    g_object_unref (layout);
    pango_font_description_free (Courier);
    pango_font_description_free (CourierBold);
    pango_font_description_free (CourierOblique);
    pango_font_description_free (CourierBoldOblique);
    cairo_destroy (pdf_context);
    cairo_surface_destroy (pdf_surface);
    isOpenP = false;
    return true;
}

bool PANGOCAIROPrinterDevice::SetTypeSlant(TypeSlant slant)
{
    //cerr << "*** PANGOCAIROPrinterDevice::SetTypeSlant("<<slant<<")"<<endl;
    if (!isOpenP) return false;
    current_slant = slant;
    return true;
}

bool PANGOCAIROPrinterDevice::SetTypeWeight(TypeWeight weight)
{
    //cerr << "*** PANGOCAIROPrinterDevice::SetTypeWeight("<<weight<<")"<<endl;
    if (!isOpenP) return false;
    current_weight = weight;
    return true;
}

bool PANGOCAIROPrinterDevice::SetTypeSpacing(TypeSpacing spacing)
{
    if (!isOpenP) return false;
    current_spacing = spacing;
}

bool PANGOCAIROPrinterDevice::NewPage(const string heading)
{
    if (!isOpenP) return false;
    //cerr << "*** PANGOCAIROPrinterDevice::NewPage(\""<<heading<<"\")"<<endl;
    needPage = true;
    lines = 0;
    if (heading != "") return Put(heading);
    else return true;
}

bool PANGOCAIROPrinterDevice::PutLine(const string line)
{
    if (!isOpenP) return false;
    if (line != "") Put(line);
    partline = false;
    lines++;
    if (lines >= maxLines) NewPage("");
    currentColumn = 0;
    currentColumnFraction = 0;
    return true;
}

bool PANGOCAIROPrinterDevice::Put(const string text)
{
    string::size_type nl, lastnl = string::npos;
    
    if (!isOpenP) return false;
    while ((nl = text.find('\n',lastnl+1)) != string::npos) {
        //cerr << "*** PANGOCAIROPrinterDevice::Put(): needPage = "<<needPage<<endl;
        if (needPage) {
            cairo_show_page (pdf_context);
            needPage = false;
        }
        putstring(text.substr(lastnl+1,nl-lastnl-1));
        currentColumn = 0;
        currentColumnFraction = 0;
        lastnl = nl;
        partline = false;
        lines++;
        if (lines >= maxLines) NewPage("");
    }
    if (lastnl+1 < text.length()) {
        //cerr << "*** PANGOCAIROPrinterDevice::Put(): needPage = "<<needPage<<endl;
        if (needPage) {
            cairo_show_page (pdf_context);
            needPage = false;
        }
        currentColumnFraction += putstring(text.substr(lastnl+1));
        currentColumn = (int) currentColumnFraction;
        partline = true;
    }
    return true;
}

bool PANGOCAIROPrinterDevice::Tab(int column)
{
    if (!isOpenP) return false;
    //cerr << "*** PANGOCAIROPrinterDevice::Tab("<<column<<")"<<endl;
    //cerr << "*** PANGOCAIROPrinterDevice::Tab(): (enter) currentColumn = "<<currentColumn<<endl;
    while (currentColumn < column) Put(" ");
    //cerr << "*** PANGOCAIROPrinterDevice::Tab(): (exit) currentColumn = "<<currentColumn<<endl;
    return true;
}

double PANGOCAIROPrinterDevice::putstring(const string text)
{
    int w,h;
    double x,y;
    PangoFontDescription *desc;
    
    //cerr << "*** PANGOCAIROPrinterDevice::putstring(\"" << text << "\")" << endl;
    switch (current_slant) {
    case Roman:
        switch (current_weight) {
        case Normal:
            desc = Courier;
            break;
        case Bold:
            desc = CourierBold;
            break;
        }
        break;
    case Italic:
        switch (current_weight) {
        case Normal:
            desc = CourierOblique;
            break;
        case Bold:
            desc = CourierBoldOblique;
            break;
        }
        break;
    }
    //cerr << "*** PANGOCAIROPrinterDevice::putstring(): desc = "<<desc<<endl;
    pango_layout_set_font_description (layout, desc);
    pango_layout_set_text(layout," ",-1);
    pango_layout_get_size(layout,&w,&h);
    //cerr << "*** PANGOCAIROPrinterDevice::putstring(): [1 space]: w = "<<w<<", h = "<<h<<" x units are "<<pango_units_to_double(w)<<endl;
    
    pango_layout_set_font_description (layout, desc);
    pango_layout_set_text(layout,text.c_str(),-1);
    cairo_save(pdf_context);
    switch (current_spacing) {
    case One: cairo_scale(pdf_context,1.0,1.0); break;
    case Half: cairo_scale(pdf_context,.6,1.0); break;
    case Double: cairo_scale(pdf_context,2.0,1.0); break;
    }
    pango_cairo_update_layout (pdf_context,layout);
    //cerr << "*** PANGOCAIROPrinterDevice::putstring(): lines = "<<lines<<", currentColumnFraction = "<<currentColumnFraction<<endl;
    y = (lines*pango_units_to_double(h))+36;
    x = (currentColumn*pango_units_to_double(w))+36;
    //cerr << "*** PANGOCAIROPrinterDevice::putstring(): y = "<<y<<", x = "<<x<<endl;
    cairo_move_to(pdf_context,x,y);
    pango_cairo_show_layout (pdf_context, layout);
    cairo_restore(pdf_context);
    return (pango_units_to_double(w)*text.length())/PANGO_PIXELS(w);
}


#endif

}

