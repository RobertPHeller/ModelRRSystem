#* 
#* ------------------------------------------------------------------
#* Makefile.am - Graphics Support Scripts
#* Created by Robert Heller on Wed Oct 19 18:55:13 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.4  2007/02/02 00:52:01  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.2  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
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

pkgdatadir = $(datadir)/$(PACKAGE)/GRSupport
GRPackages = grsupport.tcl  Instruments.tcl  LCARSWidgets.tcl OvalWidgets.tcl \
	     grsupport2.tcl Instruments2.tcl LCARSWidgets2.tcl OvalWidgets2.tcl
GRBitmaps  = HBar.xbm VBar.xbm LRHFatVNarrow.xbm  ULHNarrowVFat.xbm \
	     LLHFatVNarrow.xbm  LRHNarrowVFat.xbm  URHFatVNarrow.xbm \
	     LLHNarrowVFat.xbm  ULHFatVNarrow.xbm  URHNarrowVFat.xbm

pkgdata_DATA = $(GRPackages) $(GRBitmaps) pkgIndex.tcl
EXTRA_DIST = $(GRPackages) $(GRBitmaps) testinstruments.tcl 

testinstrumentsSCRIPTS = grsupport2.tcl Instruments2.tcl OvalWidgets2.tcl \
		HBar.xbm VBar.xbm \
		$(top_builddir)/Scripts/Common/BWStdMenuBar.tcl \
		$(top_builddir)/Scripts/Common/BWHelp.tcl

pkgIndex.tcl : $(GRPackages)
	echo "pkg_mkIndex . $(GRPackages)" | $(TCLKIT)

TESTS = testinstruments$(EXEEXT)

testinstruments$(EXEEXT): testinstruments.tcl $(testinstrumentsSCRIPTS)
	-rm -rf testinstruments.vfs testinstruments.kit
	$(TCLKIT) $(SDX) qwrap testinstruments.tcl
	$(TCLKIT) $(SDX) unwrap testinstruments.kit
	-rm -rf testinstruments.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit testinstruments \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit testinstruments \
		lib $(SNITLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit testinstruments \
		lib/Common $(testinstrumentsSCRIPTS)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit testinstruments \
		Common
	$(TCLKIT) $(SDX) wrap testinstruments$(EXEEXT) -runtime $(TCLKITRUN)
	-rm -rf testinstruments.vfs testinstruments.kit

