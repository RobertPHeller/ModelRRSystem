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
		    CTCPanelWindow.tcl WrapIt.tcl

DispatcherImages  = banner.gif search.gif load.gif largePrinter.gif \
		    largeImage.gif

ExampleScripts = example1.tcl example2.tcl example3.tcl example4.tcl \
		 example1.iow example2.iow example3.iow example4.iow

bin_SCRIPTS = Dispatcher$(EXEEXT)

pkgdataexdir = $(datadir)/$(PACKAGE)/Doc/DispatcherExamples
pkgdataex_DATA = $(ExampleScripts) 
pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = Dispatcher.pot

CLEANFILES  = Dispatcher.kit $(bin_SCRIPTS) Dispatcher.pot

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
		 $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl \
		 $(top_srcdir)/Scripts/Common/gettext.tcl

CXXSupport = Mrr
CXXSupportFiles =  $(top_builddir)/C++/ParserClasses/.libs/libMRRParserClasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/ParserClasses/pkgIndex.tcl

#CMriSupportFiles =  $(top_builddir)/C++/CMri/.libs/libcmri$(SHLIB_SUFFIX) \
#		    $(top_builddir)/C++/CMri/pkgIndex.tcl
#CMriDependFiles = $(top_builddir)/C++/CMri/libcmri.la \
#		  $(top_builddir)/C++/CMri/pkgIndex.tcl

CMriSupportFiles = $(top_srcdir)/Scripts/CMri/cmri.tcl  \
			$(top_builddir)/Scripts/CMri/pkgIndex.tcl
CMriDependFiles  = $(CMriSupportFiles)

MRDSupportFiles =  $(top_builddir)/C++/MRD/.libs/libmrd$(SHLIB_SUFFIX) \
		    $(top_builddir)/C++/MRD/pkgIndex.tcl
MRDDependFiles = $(top_builddir)/C++/MRD/libmrd.la \
		  $(top_builddir)/C++/MRD/pkgIndex.tcl

CodeLibraryFiles = cmriCode.tcl panelCode.tcl userCodeModules.tcl
EXTRA_DIST  = Dispatcher.src $(DispatcherScripts) $(DispatcherImages) \
		$(CodeLibraryFiles) $(ExampleScripts) Dispatcher.png \
		Dispatcher.desktop Doxyfile.in

desktopdir = $(datadir)/applications
desktop_DATA = Dispatcher.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = Dispatcher.png

man_MANS = man1/Dispatcher.1


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

Dispatcher.pot: Dispatcher.src $(DispatcherScripts) \
			$(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,Dispatcher.src $(DispatcherScripts)) \
		Scripts/Common/BWStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Dispatcher/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >Dispatcher.pot


Dispatcher$(EXEEXT) : Dispatcher.src $(DispatcherLibFiles) $(CommonLibFiles) \
		      $(CodeLibraryFiles) \
		      $(top_builddir)/po/Dispatcher/msgfiles \
		      $(top_builddir)/Doc/User/Dispatcher/Dispatcher.html \
		      $(CMriDependFiles)  $(MRDDependFiles) \
		      $(top_builddir)/C++/ParserClasses/libMRRParserClasses.la \
		      $(top_builddir)/C++/ParserClasses/pkgIndex.tcl
	-rm -rf Dispatcher.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/Dispatcher.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  Dispatcher.kit
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
	$(UNZIP) -qq -d Dispatcher.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(UNZIP) -qq -d Dispatcher.vfs/lib \
		$(top_srcdir)/BuildData/pdf4tcl05.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		Help $(top_builddir)/Doc/User/Dispatcher/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) Dispatcher \
		CodeLibrary $(CodeLibraryFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/CMri $(CMriSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/MRD $(MRDSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		Messages $(top_builddir)/po/Dispatcher/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap Dispatcher${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf Dispatcher.vfs Dispatcher.kit

$(top_builddir)/Doc/User/Dispatcher/Dispatcher.html : FORCE
	$(MAKE) -C $(top_builddir)/Doc/User Dispatcher/Dispatcher.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/Dispatcher/msgfiles: FORCE
	$(MAKE) -C ../../po/Dispatcher msgfiles

FORCE:

$(top_builddir)/C++/ParserClasses/pkgIndex.tcl : \
		$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la
	$(MAKE) -C $(top_builddir)/C++/ParserClasses pkgIndex.tcl

$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la : \
	$(top_srcdir)/C++/ParserClasses/*.cc \
	$(top_srcdir)/C++/ParserClasses/*.h \
	$(top_srcdir)/C++/ParserClasses/*.i \
	$(top_srcdir)/C++/ParserClasses/MRRXtrkCad.y
	$(MAKE) -C $(top_builddir)/C++/ParserClasses

$(top_builddir)/Scripts/CMri/pkgIndex.tcl : $(top_srcdir)/Scripts/CMri/cmri.tcl
	$(MAKE) -C $(top_builddir)/Scripts/CMri pkgIndex.tcl

man1/Dispatcher.1 : Doxyfile Dispatcher.src
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

