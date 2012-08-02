#* 
#* ------------------------------------------------------------------
#* Makefile.am - Dispatcher w/ Boost makefile
#* Created by Robert Heller on Tue Apr 28 08:33:41 2009
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

DispatcherScripts = NodeGraphCanvas.tcl PrintDialog.tcl TrackGraph.tcl \
		    CTCPanelWindow.tcl

DispatcherImages  = banner.gif search.gif load.gif

ExampleScripts = example1.tcl example2.tcl example3.tcl example4.tcl \
		 example1.iow example2.iow example3.iow example4.iow

bin_SCRIPTS = DispatcherBoost$(EXEEXT)

pkgdatadir = $(datadir)/$(PACKAGE)/Doc/DispatcherExamples
pkgdata_DATA = $(ExampleScripts)

CLEANFILES  = DispatcherBoost.kit $(bin_SCRIPTS)

DispatcherLib = DispatcherLib
DispatcherLibFiles = $(DispatcherScripts) $(DispatcherImages)

CommonLib = Common
CommonLibFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
		 $(top_srcdir)/Scripts/Common/new.gif \
		 $(top_srcdir)/Scripts/Common/open.gif \
		 $(top_srcdir)/Scripts/Common/close.gif \
		 $(top_srcdir)/Scripts/Common/save.gif \
		 $(top_srcdir)/Scripts/Common/print.gif \
		 $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
		 $(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
		 $(top_srcdir)/Scripts/Common/panedw.tcl \
		 $(top_srcdir)/Scripts/Common/splash.tcl \
		 $(top_srcdir)/Scripts/Common/mainwindow.tcl \
		 $(top_builddir)/Scripts/Common/Version.tcl \
		 $(top_srcdir)/Scripts/GRSupport/grsupport2.tcl \
		 $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
		 $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
		 $(top_srcdir)/Scripts/Common/labelselectcolor.tcl \
		 $(top_srcdir)/Scripts/Common/fileentry.tcl \
		 $(top_srcdir)/Scripts/Common/CTCPanel2.tcl \
		 $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl

CXXSupport = Mrrboost
CXXSupportFiles =  $(top_builddir)/C++/ParserClassesBoost/.libs/libMRRParserClassesBoost$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/ParserClassesBoost/pkgIndex.tcl


CodeLibraryFiles = cmriCode.tcl panelCode.tcl userCodeModules.tcl
EXTRA_DIST  = DispatcherBoost.src $(DispatcherScripts) $(DispatcherImages) \
		$(CodeLibraryFiles) $(ExampleScripts)

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

DispatcherBoost$(EXEEXT) : DispatcherBoost.src $(DispatcherLibFiles) $(CommonLibFiles) \
		      $(CodeLibraryFiles) \
		      $(top_builddir)/Doc/User/Dispatcher/Dispatcher.html \
		      $(top_builddir)/C++/ParserClassesBoost/libMRRParserClassesBoost.la \
		      $(top_builddir)/C++/ParserClassesBoost/pkgIndex.tcl
	-rm -rf DispatcherBoost.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/DispatcherBoost.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  DispatcherBoost.kit
	-rm -rf DispatcherBoost.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit DispatcherBoost \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit DispatcherBoost \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) DispatcherBoost \
		lib/$(DispatcherLib) $(DispatcherLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit DispatcherBoost \
		$(DispatcherLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit DispatcherBoost \
		lib/$(CommonLib) $(CommonLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit DispatcherBoost \
		$(CommonLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit DispatcherBoost \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(UNZIP) -qq -d DispatcherBoost.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit DispatcherBoost \
		Help $(top_builddir)/Doc/User/Dispatcher/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) DispatcherBoost \
		CodeLibrary $(CodeLibraryFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap DispatcherBoost${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf DispatcherBoost.vfs DispatcherBoost.kit

$(top_builddir)/Doc/User/Dispatcher/Dispatcher.html : FORCE
	$(MAKE) -C $(top_builddir)/Doc/User Dispatcher/Dispatcher.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

FORCE:

$(top_builddir)/C++/ParserClassesBoost/pkgIndex.tcl : \
		$(top_builddir)/C++/ParserClassesBoost/libMRRParserClassesBoost.la
	$(MAKE) -C $(top_builddir)/C++/ParserClassesBoost pkgIndex.tcl

$(top_builddir)/C++/ParserClassesBoost/libMRRParserClassesBoost.la : \
	$(top_srcdir)/C++/ParserClassesBoost/*.cc \
	$(top_srcdir)/C++/ParserClassesBoost/*.h \
	$(top_srcdir)/C++/ParserClassesBoost/*.i \
	$(top_srcdir)/C++/ParserClassesBoost/MRRXtrkCad.y
	$(MAKE) -C $(top_builddir)/C++/ParserClassesBoost

