#* 
#* ------------------------------------------------------------------
#* Makefile.am - Freight Car Forwarder 2
#* Created by Robert Heller on Wed Oct 19 19:23:42 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.6  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.5  2006/05/22 17:01:12  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.4  2006/05/19 02:47:46  heller
#* Modification History: Last Minute Updates
#* Modification History:
#* Modification History: Revision 1.3  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:38  heller
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

FCFScripts  = FCFCars.tcl FCFTrains.tcl FCFPrinters.tcl FCFIndustries.tcl 
FCFScripts += FCFDivisions.tcl FCFReports.tcl FCFSearchForCarsDialog.tcl
FCFScripts += FCFSelectATrainDialog.tcl FCFControlYardListsDialog.tcl
FCFScripts += FCFManageOneTrainDialog.tcl FCFSelectAnIndustryDialog.tcl

bin_SCRIPTS = FCFMain$(EXEEXT)
EXTRA_DIST  = FCFMain.src $(FCFScripts) addcar.gif assigncars.gif banner.gif \
		closeprint.gif deletecar.gif editcar.gif loadcars.gif \
		managetrainsprint.gif reports.gif resetIndustries.gif \
		runalltrains.gif runboxmoves.gif runonetrain.gif showcars.gif \
		traindisplay.gif unassignedcars.gif viewcar.gif yardprint.gif


FCFLib = FreightCarForwarder2

FCFLibFiles = $(FCFScripts) addcar.gif assigncars.gif banner.gif \
		closeprint.gif deletecar.gif editcar.gif loadcars.gif \
		managetrainsprint.gif reports.gif resetIndustries.gif \
		runalltrains.gif runboxmoves.gif runonetrain.gif showcars.gif \
		traindisplay.gif unassignedcars.gif viewcar.gif yardprint.gif

FCFCommon = Common
FCFCommonFiles = $(top_builddir)/Scripts/Common/DeepwoodsBanner.gif \
		 $(top_builddir)/Scripts/Common/open.gif \
		 $(top_builddir)/Scripts/Common/close.gif \
		 $(top_builddir)/Scripts/Common/save.gif \
		 $(top_builddir)/Scripts/Common/print.gif \
		 $(top_builddir)/Scripts/Common/BWStdMenuBar.tcl \
		 $(top_builddir)/Scripts/Common/BWHelp.tcl \
		 $(top_builddir)/Scripts/Common/panedw.tcl \
		 $(top_builddir)/Scripts/Common/splash.tcl \
		 $(top_builddir)/Scripts/Common/mainwindow.tcl \
		 $(top_builddir)/Scripts/Common/labelcombobox.tcl \
		 $(top_builddir)/Scripts/Common/labelspinbox.tcl \
		 $(top_builddir)/Scripts/Common/fileentry.tcl

CXXSupport = FCFSupport
CXXSupportFiles =  $(top_builddir)/C++/FCFSupport/.libs/libfcfclasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/FCFSupport/pkgIndex.tcl 

FCFMain${EXEEXT} : FCFMain.src $(FCFLibFiles) $(FCFCommonFiles) \
		$(top_builddir)/Help/FreightCarForwarder2/hh.index \
		$(top_builddir)/Help/FreightCarForwarder2/index.hh \
		$(top_builddir)/C++/FCFSupport/libfcfclasses.la \
		$(top_builddir)/C++/FCFSupport/pkgIndex.tcl
	-rm -rf FCFMain.vfs
	$(TCLKIT) $(SDX) qwrap FCFMain.src
	$(TCLKIT) $(SDX) unwrap  FCFMain.kit
	-rm -rf FCFMain.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit FCFMain \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit FCFMain \
		lib $(SNITLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit FCFMain \
		lib/$(FCFLib) $(FCFLibFiles)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit FCFMain \
		$(FCFLib)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit FCFMain \
		lib/$(FCFCommon) $(FCFCommonFiles)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit FCFMain \
		$(FCFCommon)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit FCFMain \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit FCFMain \
		Help $(top_builddir)/Help/FreightCarForwarder2/*.hh \
		     $(top_builddir)/Help/FreightCarForwarder2/hh.index
	$(TCLKIT) $(SDX) wrap FCFMain${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf FCFMain.vfs FCFMain.kit

$(top_builddir)/Help/FreightCarForwarder2/hh.index : \
		$(top_builddir)/Help/FreightCarForwarder2/*.hh
	$(MAKE) -C $(top_builddir)/Help/FreightCarForwarder2 hh.index

$(top_builddir)/Help/FreightCarForwarder2/index.hh : \
		$(top_builddir)/Help/FreightCarForwarder2/*.hh
	$(MAKE) -C $(top_builddir)/Help/FreightCarForwarder2 index.hh

$(top_builddir)/C++/FCFSupport/libfcfclasses.la : \
		$(top_builddir)/C++/FCFSupport/*.cc \
		$(top_builddir)/C++/FCFSupport/*.h \
		$(top_builddir)/C++/FCFSupport/*.i
	$(MAKE) -C $(top_builddir)/C++/FCFSupport libfcfclasses.la

$(top_builddir)/C++/FCFSupport/pkgIndex.tcl : \
		$(top_builddir)/C++/FCFSupport/libfcfclasses.la
	$(MAKE) -C $(top_builddir)/C++/FCFSupport pkgIndex.tcl

