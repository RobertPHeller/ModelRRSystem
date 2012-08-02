#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Tue Jan  9 10:48:20 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.10  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.9  2007/04/19 17:23:21  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.8  2007/02/21 20:25:27  heller
#* Modification History: SWIG Hackery
#* Modification History:
#* Modification History: Revision 1.7  2007/02/02 03:30:21  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.5  2007/02/02 03:21:12  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.4  2007/02/02 03:12:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/02/02 02:37:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.1  2007/02/01 20:00:51  heller
#* Modification History: Lock down for Release 2.1.7
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

pkgincludedir = $(includedir)/$(PACKAGE)/ParserClassesBoost

BUILT_SOURCES = MRRXtrkCad.tab.cc MRRXtrkCad.tab.h mrrboost_wrap.cc

pkginclude_HEADERS = TrackGraph.h TrackBody.h ParseFile.h IntegerList.h \
			TurnoutBody.h MRRXtrkCad.tab.h

lib_LTLIBRARIES = libMRRParserClassesBoost.la
INCLUDES = -I. -I$(TCL_INC_DIR)
nodist_libMRRParserClassesBoost_la_SOURCES = MRRXtrkCad.tab.cc MRRXtrkCad.tab.h \
		mrrboost_wrap.cc
libMRRParserClassesBoost_la_SOURCES = ParseFile.cc TrackGraph.cc
if CROSSCOMPILING
libMRRParserClassesBoost_la_LDFLAGS = -g -avoid-version $(TCL_STUB_LIB_SPEC) -lwsock32 -lws2_32
else
libMRRParserClassesBoost_la_LDFLAGS = -g -version-info 0:0:0 $(TCL_STUB_LIB_SPEC)
endif
libMRRParserClassesBoost_la_CXXFLAGS = $(INCLUDES) $(BOOST_CPPFLAGS)

EXTRA_DIST = MRRXtrkCad.y ParserClassesBoostGroup.h mrrboost.i SocketPair.h
noinst_SCRIPTS = pkgIndex.tcl

CLEANFILES = $(BUILT_SOURCES) MRRXtrkCad.tab.cc~output pkgIndex.tcl *~

DEFS = @DEFS@ $(TCL_DEFS)
SWIG_FLAGS =  -tcl8 -c++ $(INCLUDES) \
	$(SWIGVERSIONFLAGS)


MRRXtrkCad.tab.cc MRRXtrkCad.tab.h : MRRXtrkCad.y 
	$(BISONXX) \
		--verbose --defines \
		--output-file=./MRRXtrkCad.tab.cc~ -h ./MRRXtrkCad.tab.h~ \
		$(srcdir)/MRRXtrkCad.y
	sed 's/class YY_MRRXtrkCad_CLASS YY_MRRXtrkCad_INHERIT/class Parsers::YY_MRRXtrkCad_CLASS YY_MRRXtrkCad_INHERIT/g' \
		<MRRXtrkCad.tab.h~ >MRRXtrkCad.tab.h
	sed 's/class YY_MRRXtrkCad_CLASS YY_MRRXtrkCad_INHERIT/class Parsers::YY_MRRXtrkCad_CLASS YY_MRRXtrkCad_INHERIT/g' \
		<MRRXtrkCad.tab.cc~ >MRRXtrkCad.tab.cc
	
	
mrrboost_wrap.cc : mrrboost.i $(pkginclude_HEADERS) SocketPair.h \
		$(top_builddir)/config.status
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o mrrboost_wrap.cc $(srcdir)/mrrboost.i

pkgIndex.tcl: libMRRParserClassesBoost.la $(top_builddir)/config.status
	echo 'package ifneeded  Mrrboost $(MRR_PATCH_LEVELLIB) [list load [file join $$dir libMRRParserClassesBoost[info sharedlibextension]] Mrrboost]' > pkgIndex.tcl

install-exec-hook: libMRRParserClassesBoost.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
if CROSSCOMPILING
	cp    $(DESTDIR)$(bindir)/libMRRParserClassesBoost$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libMRRParserClassesBoost$(SHLIB_SUFFIX)
else
	ln -fs $(libdir)/libMRRParserClassesBoost$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libMRRParserClassesBoost$(SHLIB_SUFFIX)
endif
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_mrrboost.tcl
