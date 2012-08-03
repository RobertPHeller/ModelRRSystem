#* 
#* ------------------------------------------------------------------
#* Makefile.am - Toplevel Makefile
#* Created by Robert Heller on Sat Aug  5 05:56:29 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.6  2007/05/06 12:49:37  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.5  2007/04/19 17:23:19  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.4  2007/02/02 00:52:00  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/01/08 19:05:52  heller
#* Modification History: Jan 8, 2007 Lockdown
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

SUBDIRS = BuildScripts BuildData Doc C++ Scripts Installer intl po

EXTRA_DIST = $(PACKAGE).spec bootstrap config_tcl.sed.in Doxyfile.in \
	ModelRailroadSystem.h

man_MANS = man1/ModelRailroadSystem.1

man1/ModelRailroadSystem.1 : Doxyfile ModelRailroadSystem.h
	-rm -rf man1
	$(DOXYGEN)
	-rm man1/ModelRailroadSystem.h.1


clean-local:
	-rm -rf man1

rpm: dist
	rpmbuild -ta $(distdir).tar.gz
