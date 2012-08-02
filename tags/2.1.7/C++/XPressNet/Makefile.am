#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Tue Aug 23 11:26:07 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.8  2007/02/02 03:21:12  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.7  2007/02/02 03:12:17  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.5  2007/02/01 20:00:52  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.4  2007/01/08 19:05:54  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.3  2006/05/22 19:38:06  heller
#* Modification History: Release 2.1.4 Final
#* Modification History:
#* Modification History: Revision 1.2  2005/11/14 20:28:45  heller
#* Modification History: Nov 14, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:35  heller
#* Modification History: Nov 4, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

pkgincludedir = $(includedir)/$(PACKAGE)/XPressNet

pkginclude_HEADERS = xpressnet_Event.h xpressnet.h

lib_LTLIBRARIES = libxpressnet.la
libxpressnet_la_SOURCES = xpressnet.cc xpressnet_Event.cc $(pkginclude_HEADERS)
nodist_libxpressnet_la_SOURCES = xpressnet_wrap.cc
INCLUDES = -I. -I$(TCL_INC_DIR)
libxpressnet_la_CXXFLAGS = $(INCLUDES)
libxpressnet_la_LDFLAGS = -g -version-info 0:0:0 $(TCL_STUB_LIB_SPEC)

noinst_SCRIPTS = pkgIndex.tcl

BUILT_SOURCES = xpressnet_wrap.cc
CLEANFILES    = $(BUILT_SOURCES)
EXTRA_DIST = Begin.h End.h xpressnet.i

DEFS = @DEFS@ $(TCL_DEFS)
SWIG_FLAGS =  -tcl8 -c++ $(INCLUDES) \
	-DSWIGVERSION=$(SWIGVERSION) -DSWIGVERSIONMAJOR=$(SWIGVERSIONMAJOR) \
	-DSWIGVERSIONMINOR=$(SWIGVERSIONMINOR)

xpressnet_wrap.cc : xpressnet.i $(pkginclude_HEADERS)
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o xpressnet_wrap.cc \
		xpressnet.i

pkgIndex.tcl: libxpressnet.la
	echo 'package ifneeded Xpressnet $(XPRESSNET_VERSIONLIB) [list load [file join $$dir libxpressnet[info sharedlibextension]]]' > pkgIndex.tcl

install-exec-hook: libxpressnet.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
	ln -s $(libdir)/libxpressnet$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libxpressnet$(SHLIB_SUFFIX)
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl

