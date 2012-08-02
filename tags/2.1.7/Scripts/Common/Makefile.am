#* 
#* ------------------------------------------------------------------
#* Makefile.am - Common Scripts
#* Created by Robert Heller on Tue Oct 18 19:29:26 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.9  2007/02/02 00:52:01  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.8  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.7  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.6  2006/05/22 17:25:15  heller
#* Modification History: Last minute changes for release 2.1.4
#* Modification History:
#* Modification History: Revision 1.5  2006/05/22 17:01:12  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.4  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.3  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.2  2006/02/06 00:18:09  heller
#* Modification History: Start converting to BWidget from Tix
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

CommonScripts = CTCPanel.tcl ReadConfiguration.tcl \
		BWStdMenuBar.tcl CTCPanel2.tcl labelselectcolor.tcl \
		BWHelp.tcl fileentry.tcl labelcombobox.tcl labelspinbox.tcl \
		panedw.tcl \
		splash.tcl mainwindow.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/Common
pkgdata_DATA = $(CommonScripts) pkgIndex.tcl CommonPaths.tcl \
	DeepwoodsBanner.gif new.gif open.gif save.gif print.gif close.gif
pkgdocdir = $(datadir)/$(PACKAGE)/Doc
pkgdoc_DATA = Finn.pdf Finn.ps

EXTRA_DIST = $(CommonScripts) CommonPaths.src \
	     Finn.tex FinnFigure1.ps FinnFigure2a.ps FinnFigure2b.ps \
	     DeepwoodsBanner.gif new.gif open.gif save.gif print.gif close.gif

Finn.pdf Finn.ps: Finn.tex FinnFigure1.ps FinnFigure2a.ps FinnFigure2b.ps
	$(LATEX) Finn
	$(LATEX) Finn
	$(DVIPS) -t letter Finn -o Finn.ps
	$(PS2PDF) Finn.ps Finn.pdf

pkgIndex.tcl : $(CommonScripts)
	echo "pkg_mkIndex . $(CommonScripts)" | $(TCLKIT)

CommonPaths.tcl : CommonPaths.src $(top_srcdir)/config_tcl.sed
	sed -f $(top_srcdir)/config_tcl.sed <$< >$@

$(top_builddir)/config_tcl.sed: $(top_builddir)/config.status \
				$(top_builddir)/config_tcl.sed.in
	cd $(top_builddir) && CONFIG_FILES=$(@F) CONFIG_HEADERS= $(SHELL) ./config.status

