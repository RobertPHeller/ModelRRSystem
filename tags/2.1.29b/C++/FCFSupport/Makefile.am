#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Tue Aug 23 10:14:30 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.16  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.15  2007/04/19 17:23:20  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.14  2007/02/21 19:13:52  heller
#* Modification History: SWIG Hackery
#* Modification History:
#* Modification History: Revision 1.12  2007/02/02 03:30:21  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.11  2007/02/02 03:27:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.9  2007/02/02 03:12:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.8  2007/02/02 02:37:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.7  2007/02/02 01:51:01  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.6  2007/02/01 20:00:51  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.5  2007/01/08 19:05:54  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.4  2006/05/22 19:38:06  heller
#* Modification History: Release 2.1.4 Final
#* Modification History:
#* Modification History: Revision 1.3  2005/11/14 20:28:44  heller
#* Modification History: Nov 14, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.2  2005/11/04 19:41:57  heller
#* Modification History: Nov 4, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:33  heller
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

pkgincludedir = $(includedir)/$(PACKAGE)/FCFSupport

pkginclude_HEADERS = System.h Division.h Station.h Common.h PathName.h \
			Train.h Industry.h CarType.h Owner.h Car.h \
			SwitchList.h CallBack.h Printer.h TextPrinter.h \
			LQ24Printer.h PostScriptPrinter.h PDFPrinter.h \
			PDFPrinterSupport.h
lib_LTLIBRARIES = libfcfclasses.la
libfcfclasses_la_SOURCES = System.cc System_ReadDivisions.cc \
			   System_ReadStations.cc System_ReadTrains.cc \
			   System_ReadIndustries.cc System_ReadTrainOrders.cc \
			   System_ReadOwners.cc System_ReadCarTypes.cc \
			   System_LoadCars.cc System_LoadStats.cc \
			   System_CarAssignment.cc \
			   System_RunTrains.cc System_Reports.cc \
			   System_CarEdit.cc \
			   SwitchList.cc \
			   PathName.cc TextPrinter.cc LQ24Printer.cc \
			   PostScriptPrinter.cc PDFPrinter.cc \
			   PDFPrinterSupport.cc $(pkginclude_HEADERS) \
			   ../gettext.h
libfcfclasses_la_XGETTEXTFILES = $(libfcfclasses_la_SOURCES)
nodist_libfcfclasses_la_SOURCES = FCFClasses_wrap.cc ../gettext.c
if CROSSCOMPILING
libfcfclasses_la_LDFLAGS = -g -avoid-version $(TCL_STUB_LIB_SPEC)
else
libfcfclasses_la_LDFLAGS = -g -version-info 0:0:0 $(TCL_STUB_LIB_SPEC)
endif
INCLUDES = -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)  
libfcfclasses_la_CXXFLAGS = $(INCLUDES) -Wall
libfcfclasses_la_LIBADD   = $(LTLIBOBJS)

BUILT_SOURCES = FCFClasses_wrap.cc
noinst_SCRIPTS = pkgIndex.tcl
noinst_DATA = FCFClasses.potlist

EXTRA_DIST = FCFSupportGroup.h FCFClasses.i
CLEANFILES = $(BUILT_SOURCES) pkgIndex.tcl FCFClasses.potlist
DEFS = @DEFS@ $(TCL_DEFS)
SWIG_FLAGS = -tcl8 -c++ $(INCLUDES)

FCFClasses_wrap.cc : FCFClasses.i $(pkginclude_HEADERS) \
		$(top_builddir)/config.status
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o FCFClasses_wrap.cc \
		$(srcdir)/FCFClasses.i

FCFClasses.potlist: $(libfcfclasses_la_XGETTEXTFILES)
	echo $(addprefix $(subdir)/,$(libfcfclasses_la_XGETTEXTFILES)) |\
	tr ' ' '\n' > FCFClasses.potlist

pkgIndex.tcl: libfcfclasses.la $(top_builddir)/config.status
	echo 'package ifneeded Fcfclasses $(FCFCLASSES_VERSIONLIB) [list load [file join $$dir libfcfclasses[info sharedlibextension]]]' > pkgIndex.tcl

install-exec-hook: libfcfclasses.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
if CROSSCOMPILING
	cp    $(DESTDIR)$(bindir)/libfcfclasses$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libfcfclasses$(SHLIB_SUFFIX)
else
	ln -fs $(libdir)/libfcfclasses$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libfcfclasses$(SHLIB_SUFFIX)
endif
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_fcfclasses.tcl
