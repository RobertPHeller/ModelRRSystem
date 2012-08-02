#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file for Camera Scripts
#* Created by Robert Heller on Fri Nov  4 13:25:53 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.4  2007/02/02 01:04:02  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.2  2006/08/04 01:59:26  heller
#* Modification History: Aug 3 Lockdown
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

bin_SCRIPTS = AnyDistance${EXEEXT} Closest${EXEEXT}
EXTRA_DIST  = AnyDistance.src Closest.src
CLEANFILES = AnyDistance.kit Closest.kit $(bin_SCRIPTS)
CameraSCRIPTS = $(top_builddir)/Scripts/Common/BWStdMenuBar.tcl \
			$(top_builddir)/Scripts/Common/BWHelp.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl \
		Lens.tcl CameraCalculator.tcl CameraPrintDialog.tcl
EXTRA_DIST += Lens.tcl CameraCalculator.tcl CameraPrintDialog.tcl

AnyDistance${EXEEXT} : AnyDistance.src $(CameraSCRIPTS) \
		     $(top_builddir)/Help/CameraScripts/hh.index \
		     $(top_builddir)/Help/CameraScripts/index.hh
	-rm -rf AnyDistance.vfs
	$(TCLKIT) $(SDX) qwrap  AnyDistance.src
	$(TCLKIT) $(SDX) unwrap  AnyDistance.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit AnyDistance \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit AnyDistance \
		lib $(SNITLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit AnyDistance \
		lib/Common $(CameraSCRIPTS)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit AnyDistance \
		Common
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit AnyDistance \
		Help $(top_builddir)/Help/CameraScripts/*.hh \
		     $(top_builddir)/Help/CameraScripts/hh.index
	$(TCLKIT) $(SDX) wrap AnyDistance${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf AnyDistance.vfs AnyDistance.kit



Closest${EXEEXT} : Closest.src $(CameraSCRIPTS) \
		     $(top_builddir)/Help/CameraScripts/hh.index \
		     $(top_builddir)/Help/CameraScripts/index.hh
	-rm -rf Closest.vfs
	$(TCLKIT) $(SDX) qwrap  Closest.src
	$(TCLKIT) $(SDX) unwrap  Closest.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit Closest \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit Closest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit Closest \
		lib/Common $(CameraSCRIPTS)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit Closest \
		Common
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit Closest \
		Help $(top_builddir)/Help/CameraScripts/*.hh \
		     $(top_builddir)/Help/CameraScripts/hh.index
	$(TCLKIT) $(SDX) wrap Closest${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf Closest.vfs Closest.kit



$(top_builddir)/Help/CameraScripts/hh.index : $(top_builddir)/Help/CameraScripts/*.hh
	$(MAKE) -C $(top_builddir)/Help/CameraScripts hh.index

$(top_builddir)/Help/CameraScripts/index.hh : $(top_builddir)/Help/CameraScripts/*.hh
	$(MAKE) -C $(top_builddir)/Help/CameraScripts index.hh


