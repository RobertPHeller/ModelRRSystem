#* 
#* ------------------------------------------------------------------
#* Makefile.am - Makefile for TT2
#* Created by Robert Heller on Fri Dec 23 11:01:33 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.11  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.10  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.9  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.8  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.7  2006/08/04 01:59:26  heller
#* Modification History: Aug 3 Lockdown
#* Modification History:
#* Modification History: Revision 1.6  2006/05/22 17:01:12  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.5  2006/05/20 14:23:16  heller
#* Modification History: Added LaTeX Style file
#* Modification History:
#* Modification History: Revision 1.4  2006/05/19 02:47:46  heller
#* Modification History: Last Minute Updates
#* Modification History:
#* Modification History: Revision 1.3  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/03/06 18:46:21  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/01/03 15:30:21  heller
#* Modification History: Lockdown
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

TTScripts = TTMainWindow.tcl TTMenuSupport.tcl TTFileIO.tcl \
	    TTTrains.tcl TTStations.tcl TTCabs.tcl TTNotes.tcl TTPrint.tcl \
	    TTSystemConfiguration.tcl

bin_SCRIPTS = TTChart2TT2$(EXEEXT) TimeTable$(EXEEXT)
GIFS =  addstorage.gif  cleardupstation.gif  setdupstation.gif \
	addtrain.gif    deletetrain.gif      smallStation.gif \
	banner.gif      edittrain.gif        smallTrack.gif \
	addcab.gif      createnote.gif       editnote.gif \
	addnotetotrain.gif addnotetotrainatstation.gif \
	removenotefromtrain.gif removenotefromtrainatstation.gif \
	largePrinter.gif 

CLEANFILES = TTChart2TT2.kit TimeTable.kit $(bin_SCRIPTS)
	
EXTRA_DIST  = TTChart2TT2.src TimeTable.src $(TTScripts) $(GIFS) TimeTable.sty \
		ReadOldTT.tcl Doxyfile.in TimeTable.png TimeTable.desktop


desktopdir = $(datadir)/applications
desktop_DATA = TimeTable.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = TimeTable.png

man_MANS = man1/TimeTable.1 man1/TTChart2TT2.1

TTLib = TimeTable2
TTLibFiles = $(TTScripts) $(GIFS)

TTCommon = Common
TTCommonFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
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
		 $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl \
		 $(top_srcdir)/Scripts/Common/fileentry.tcl \
		 $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
		 $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
		 $(top_srcdir)/Scripts/Common/labelselectcolor.tcl \
		 $(top_builddir)/Scripts/Common/Version.tcl

CXXSupport = TTSupport
CXXSupportFiles =  $(top_builddir)/C++/TTSupport/.libs/libttclasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/TTSupport/pkgIndex.tcl 

pkgdatadir = $(datadir)/$(PACKAGE)/TTScripts
pkgdata_DATA = TimeTable.sty

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

TTChart2TT2$(EXEEXT) : TTChart2TT2.src ReadOldTT.tcl \
			$(top_builddir)/C++/TTSupport/libttclasses.la \
			$(top_builddir)/C++/TTSupport/pkgIndex.tcl
	-rm -rf TTChart2TT2.vfs $(srcdir)/TTChart2TT2.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/TTChart2TT2.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap TTChart2TT2.kit
	-rm -rf TTChart2TT2.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) TTChart2TT2 \
		lib/$(TTLib) ReadOldTT.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TTChart2TT2 \
		$(TTLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TTChart2TT2 \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap TTChart2TT2${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf TTChart2TT2.vfs TTChart2TT2.kit
	

TimeTable$(EXEEXT) : TimeTable.src $(TTLibFiles) $(TTCommonFiles) \
		$(top_builddir)/Doc/User/TimeTable/TimeTable.html \
		$(top_builddir)/C++/TTSupport/libttclasses.la \
		$(top_builddir)/C++/TTSupport/pkgIndex.tcl
	-rm -rf TimeTable.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/TimeTable.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  TimeTable.kit
	-rm -rf TimeTable.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit TimeTable \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit TimeTable \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) TimeTable \
		lib/$(TTLib) $(TTLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TimeTable \
		$(TTLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(TTCommon) $(TTCommonFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TimeTable \
		$(TTCommon)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(UNZIP) -qq -d TimeTable.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		Help $(top_builddir)/Doc/User/TimeTable/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap TimeTable${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf TimeTable.vfs TimeTable.kit

$(top_builddir)/C++/TTSupport/libttclasses.la : \
		$(top_srcdir)/C++/TTSupport/*.cc \
		$(top_srcdir)/C++/TTSupport/*.h \
		$(top_srcdir)/C++/TTSupport/*.i
	$(MAKE) -C $(top_builddir)/C++/TTSupport

$(top_builddir)/C++/TTSupport/pkgIndex.tcl : \
		$(top_builddir)/C++/TTSupport/libttclasses.la
	$(MAKE) -C $(top_builddir)/C++/TTSupport pkgIndex.tcl

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/TimeTable/TimeTable.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User TimeTable/TimeTable.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

FORCE:

man1/TimeTable.1 : Doxyfile TimeTable.src
	-rm -f man1/TimeTable.1
	$(DOXYGEN)

man1/TTChart2TT2.1 : Doxyfile TTChart2TT2.src
	-rm -f man1/TTChart2TT2.1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

