#* 
#* ------------------------------------------------------------------
#* Makefile.am - Dispatcher scripts
#* Created by Robert Heller on Wed Oct 19 19:01:36 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
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

DispatcherScripts = RawNodeGraph.tcl CompressedNodeGraph.tcl \
		    NodeGraphCanvas.tcl CTCPanelWindow.tcl \
		    PrintDialog.tcl
DispatcherImages  = banner.gif search.gif load.gif

bin_SCRIPTS = Dispatcher$(EXEEXT)

CLEANFILES  = Dispatcher.kit $(bin_SCRIPTS)

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
		 $(top_srcdir)/Scripts/Common/BWHelp.tcl \
		 $(top_srcdir)/Scripts/Common/panedw.tcl \
		 $(top_srcdir)/Scripts/Common/splash.tcl \
		 $(top_srcdir)/Scripts/Common/mainwindow.tcl \
		 $(top_builddir)/Scripts/Common/Version.tcl \
		 $(top_srcdir)/Scripts/GRSupport/grsupport2.tcl \
		 $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
		 $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
		 $(top_srcdir)/Scripts/Common/labelselectcolor.tcl \
		 $(top_srcdir)/Scripts/Common/fileentry.tcl \
		 $(top_srcdir)/Scripts/Common/CTCPanel2.tcl

CXXSupport = Mrr
CXXSupportFiles =  $(top_builddir)/C++/ParserClasses/.libs/libMRRParserClasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/ParserClasses/pkgIndex.tcl

CodeLibraryFiles = cmriCode.tcl panelCode.tcl
EXTRA_DIST  = Dispatcher.src $(DispatcherScripts) $(DispatcherImages) \
		$(CodeLibraryFiles)


Dispatcher$(EXEEXT) : Dispatcher.src $(DispatcherLibFiles) $(CommonLibFiles) \
		      $(CodeLibraryFiles) \
		      $(top_builddir)/Help/Dispatcher/hh.index \
		      $(top_srcdir)/Help/Dispatcher/*.gif \
		      $(top_builddir)/Help/Dispatcher/index.hh \
		      $(top_builddir)/C++/ParserClasses/libMRRParserClasses.la \
		      $(top_builddir)/C++/ParserClasses/pkgIndex.tcl
	-rm -rf Dispatcher.vfs
	$(TCLKIT) $(SDX) qwrap $(srcdir)/Dispatcher.src
	$(TCLKIT) $(SDX) unwrap  Dispatcher.kit
	-rm -rf Dispatcher.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Dispatcher \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Dispatcher \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) Dispatcher \
		lib/$(DispatcherLib) $(DispatcherLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Dispatcher \
		$(DispatcherLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		lib/$(CommonLib) $(CommonLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Dispatcher \
		$(CommonLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		Help $(top_srcdir)/Help/Dispatcher/*.hh \
		     $(top_builddir)/Help/Dispatcher/*.hh \
		     $(top_srcdir)/Help/Dispatcher/*.gif \
		     $(top_builddir)/Help/Dispatcher/hh.index
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) Dispatcher \
		CodeLibrary $(CodeLibraryFiles)
	$(TCLKIT) $(SDX) wrap Dispatcher${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf Dispatcher.vfs Dispatcher.kit


$(top_builddir)/Help/Dispatcher/hh.index : \
		$(top_srcdir)/Help/Dispatcher/*.hh
		$(top_builddir)/Help/Dispatcher/*.hh
	$(MAKE) -C $(top_builddir)/Help/Dispatcher hh.index

$(top_builddir)/Help/Dispatcher/index.hh : \
		$(top_srcdir)/Help/Dispatcher/*.hh
		$(top_builddir)/Help/Dispatcher/*.hh
	$(MAKE) -C $(top_builddir)/Help/Dispatcher index.hh

$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la : \
		$(top_srcdir)/C++/ParserClasses/*.cc \
		$(top_srcdir)/C++/ParserClasses/*.h \
		$(top_srcdir)/C++/ParserClasses/*.i
	$(MAKE) -C $(top_builddir)/C++/ParserClasses libMRRParserClasses.la

$(top_builddir)/C++/ParserClasses/pkgIndex.tcl : \
		$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la
	$(MAKE) -C $(top_builddir)/C++/ParserClasses pkgIndex.tcl


