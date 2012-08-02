#* 
#* ------------------------------------------------------------------
#* Makefile.am - Calculation Scripts
#* Created by Robert Heller on Wed Oct 19 19:22:40 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.2  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
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

EXTRA_DIST = Resistor.tcl
bin_SCRIPTS =  Resistor${EXEEXT}
ResistorSCRIPTS = $(top_builddir)/Scripts/Common/BWStdMenuBar.tcl \
                $(top_builddir)/Scripts/Common/BWHelp.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl
CLEANFILES = Resistor.kit $(bin_SCRIPTS)

Resistor${EXEEXT}: Resistor.tcl $(ResistorSCRIPTS) \
		$(top_builddir)/Help/CalcScripts/hh.index \
		$(top_builddir)/Help/CalcScripts/index.hh
	-rm -rf Resistor.vfs
	$(TCLKIT) $(SDX) qwrap Resistor.tcl
	$(TCLKIT) $(SDX) unwrap Resistor.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit Resistor \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit Resistor \
		lib/Common $(ResistorSCRIPTS)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit Resistor \
		Common
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit Resistor \
		Help $(top_builddir)/Help/CalcScripts/*.hh \
		     $(top_builddir)/Help/CalcScripts/hh.index
	$(TCLKIT) $(SDX) wrap Resistor${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf Resistor.vfs Resistor.kit

$(top_builddir)/Help/CalcScripts/hh.index : $(top_builddir)/Help/CalcScripts/*.hh
	$(MAKE) -C $(top_builddir)/Help/CalcScripts hh.index

$(top_builddir)/Help/CalcScripts/index.hh : $(top_builddir)/Help/CalcScripts/*.hh
	$(MAKE) -C $(top_builddir)/Help/CalcScripts index.hh

