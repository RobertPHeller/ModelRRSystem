#* 
#* ------------------------------------------------------------------
#* Makefile.am - Makefile for TT2
#* Created by Robert Heller on Fri Dec 23 11:01:33 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

	
EXTRA_DIST  = TTChart2TT2.src TimeTable.src $(TTScripts) $(GIFS) TimeTable.sty \
		ReadOldTT.tcl

TTLib = TimeTable2
TTLibFiles = $(TTScripts) $(GIFS)

TTCommon = Common
TTCommonFiles = $(top_builddir)/Scripts/Common/DeepwoodsBanner.gif \
		 $(top_builddir)/Scripts/Common/open.gif \
		 $(top_builddir)/Scripts/Common/close.gif \
		 $(top_builddir)/Scripts/Common/save.gif \
		 $(top_builddir)/Scripts/Common/print.gif \
		 $(top_builddir)/Scripts/Common/BWStdMenuBar.tcl \
		 $(top_builddir)/Scripts/Common/BWHelp.tcl \
		 $(top_builddir)/Scripts/Common/panedw.tcl \
		 $(top_builddir)/Scripts/Common/splash.tcl \
		 $(top_builddir)/Scripts/Common/mainwindow.tcl \
		 $(top_builddir)/Scripts/Common/ReadConfiguration.tcl \
		 $(top_builddir)/Scripts/Common/fileentry.tcl \
		 $(top_builddir)/Scripts/Common/labelcombobox.tcl \
		 $(top_builddir)/Scripts/Common/labelspinbox.tcl


CXXSupport = TTSupport
CXXSupportFiles =  $(top_builddir)/C++/TTSupport/.libs/libttclasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/TTSupport/pkgIndex.tcl 

pkgdatadir = $(datadir)/$(PACKAGE)/TTScripts
pkgdata_DATA = TimeTable.sty

TTChart2TT2$(EXEEXT) : TTChart2TT2.src ReadOldTT.tcl \
			$(top_builddir)/C++/TTSupport/libttclasses.la \
			$(top_builddir)/C++/TTSupport/pkgIndex.tcl
	-rm -rf TTChart2TT2.vfs TTChart2TT2.kit
	$(TCLKIT) $(SDX) qwrap TTChart2TT2.src
	$(TCLKIT) $(SDX) unwrap TTChart2TT2.kit
	-rm -rf TTChart2TT2.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit TTChart2TT2 \
		lib/$(TTLib) ReadOldTT.tcl
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit TTChart2TT2 \
		$(TTLib)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit TTChart2TT2 \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(TCLKIT) $(SDX) wrap TTChart2TT2${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf TTChart2TT2.vfs TTChart2TT2.kit
	

TimeTable$(EXEEXT) : TimeTable.src $(TTLibFiles) $(TTCommonFiles) \
		$(top_builddir)/Help/TimeTable2/hh.index \
		$(top_builddir)/Help/TimeTable2/index.hh \
		$(top_builddir)/C++/TTSupport/libttclasses.la \
		$(top_builddir)/C++/TTSupport/pkgIndex.tcl
	-rm -rf TimeTable.vfs
	$(TCLKIT) $(SDX) qwrap TimeTable.src
	$(TCLKIT) $(SDX) unwrap  TimeTable.kit
	-rm -rf TimeTable.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit TimeTable \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit TimeTable \
		lib $(SNITLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(TTLib) $(TTLibFiles)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit TimeTable \
		$(TTLib)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(TTCommon) $(TTCommonFiles)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit TimeTable \
		$(TTCommon)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit TimeTable \
		Help $(top_builddir)/Help/TimeTable2/*.hh \
		     $(top_builddir)/Help/TimeTable2/hh.index
	$(TCLKIT) $(SDX) wrap TimeTable${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf TimeTable.vfs TimeTable.kit

$(top_builddir)/Help/TimeTable2/hh.index : \
		$(top_builddir)/Help/TimeTable2/*.hh
	$(MAKE) -C $(top_builddir)/Help/TimeTable2 hh.index

$(top_builddir)/Help/TimeTable2/index.hh : \
		$(top_builddir)/Help/TimeTable2/*.hh
	$(MAKE) -C $(top_builddir)/Help/TimeTable2 index.hh

$(top_builddir)/C++/TTSupport/libttclasses.la : \
		$(top_builddir)/C++/TTSupport/*.cc \
		$(top_builddir)/C++/TTSupport/*.h \
		$(top_builddir)/C++/TTSupport/*.i
	$(MAKE) -C $(top_builddir)/C++/TTSupport libttclasses.la

$(top_builddir)/C++/TTSupport/pkgIndex.tcl : \
		$(top_builddir)/C++/TTSupport/libttclasses.la
	$(MAKE) -C $(top_builddir)/C++/TTSupport pkgIndex.tcl



