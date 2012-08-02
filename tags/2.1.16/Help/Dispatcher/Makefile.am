#* 
#* ------------------------------------------------------------------
#* Makefile.am - Dispatcher Help files
#* Created by Robert Heller on Tue Nov  1 18:52:48 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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
HelpFiles = Dialogs.hh

GIFFiles = NewCTCPanelWindowDialog.gif
CommonHelpFiles = Help.hh Copying.hh Warranty.hh Version.hh
HelpIndex = hh.index
HelpIndexBuilder = $(top_srcdir)/BuildScripts/HelpIndexBuild.kit
IndexHHBuilder = $(top_srcdir)/BuildScripts/IndexHH.kit
IndexHH = index.hh

#BUILT_SOURCES = $(CommonHelpFiles)
noinst_DATA = $(HelpFiles) $(GIFFiles) $(HelpIndex) $(IndexHH) $(CommonHelpFiles)
CLEANFILES = $(HelpIndex) $(IndexHH) $(CommonHelpFiles)

EXTRA_DIST = $(HelpFiles) $(GIFFiles) Version.text

$(HelpIndex): $(HelpFiles) $(CommonHelpFiles)
	$(TCLKIT) $(HelpIndexBuilder) -sourcedir $(srcdir) $(HelpIndex) \
		$(HelpFiles) $(CommonHelpFiles)

$(IndexHH) : $(HelpIndex) $(HelpFiles) $(CommonHelpFiles)
	$(TCLKIT) $(IndexHHBuilder) $(HelpIndex) $(IndexHH)

Version.hh: $(top_builddir)/config.status Version.text
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakeVersionHelp.kit \
		'System patch level' $(MRR_PATCH_LEVEL)
	cat $(srcdir)/Version.text >> Version.hh

Help.hh: $(srcdir)/../Help.hh
	ln -s $(srcdir)/../Help.hh ./Help.hh

Copying.hh: ../Copying.hh
	ln -s ../Copying.hh ./Copying.hh

Warranty.hh: ../Warranty.hh
	ln -s ../Warranty.hh ./Warranty.hh

../Copying.hh: $(top_srcdir)/COPYING
	$(MAKE) -C .. Copying.hh

../Warranty.hh: $(top_srcdir)/COPYING
	$(MAKE) -C .. Warranty.hh


