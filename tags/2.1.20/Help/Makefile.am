#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Mon Aug 22 21:05:41 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/04/19 17:23:22  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.4  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/04/01 17:12:09  heller
#* Modification History: Lock Down APR012006
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:36  heller
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
#*  $Id$
#* 

SUBDIRS = FreightCarForwarder2 TimeTable2 CameraScripts CalcScripts \
	  UniversalTest Dispatcher DispatcherBoost ModelRRSystem

HelpIndexBuilder = $(top_srcdir)/BuildScripts/HelpIndexBuild.kit
IndexHHBuilder = $(top_srcdir)/BuildScripts/IndexHH.kit
HelpIndex = hh.index
IndexHH = index.hh

HelpFiles = Help.hh
GeneratedHelpFiles = Copying.hh Warranty.hh
GIFFiles = 
BUILT_SOURCES = $(GeneratedHelpFiles)

noinst_DATA = $(HelpFiles) $(GIFFiles) $(GeneratedHelpFiles) $(HelpIndex) \
		$(IndexHH)
EXTRA_DIST = $(HelpFiles) $(GIFFiles)
CLEANFILES = $(GeneratedHelpFiles) $(HelpIndex) $(IndexHH) 

$(HelpIndex): $(HelpFiles) $(GeneratedHelpFiles)
	$(TCLKIT) $(HelpIndexBuilder) -sourcedir $(srcdir) $(HelpIndex) $(HelpFiles) \
		$(GeneratedHelpFiles)

$(IndexHH) : $(HelpIndex) $(HelpFiles) $(GeneratedHelpFiles)
	$(TCLKIT) $(IndexHHBuilder) $(HelpIndex) $(IndexHH)

Copying.hh : $(top_srcdir)/COPYING
	echo '0 Copying' | cat - $(top_srcdir)/COPYING >Copying.hh

Warranty.hh : $(top_srcdir)/COPYING
	echo '0 Warranty' > Warranty.hh
	sed '1,/of promoting the sharing and reuse of software generally./d' \
		$(top_srcdir)/COPYING | \
	sed '/How to Apply These Terms to Your New Programs/,999d' >>Warranty.hh
