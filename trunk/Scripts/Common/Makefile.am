#* 
#* ------------------------------------------------------------------
#* Makefile.am - Common Scripts
#* Created by Robert Heller on Tue Oct 18 19:29:26 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.11  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.10  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
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
		fileentry.tcl labelcombobox.tcl labelspinbox.tcl \
		panedw.tcl CabWidgets.tcl \
		splash.tcl mainwindow.tcl HTMLHelp.tcl gettext.tcl \
		DynamicHelp.tcl IconsAndImages.tcl snitbuttonbox.tcl \
		snitdialog.tcl snitHTMLHelp.tcl snitLFs.tcl snitmainframe.tcl \
		snitscrollableframe.tcl snitscrollw.tcl snitStdMenuBar.tcl \
		snitrotext.tcl snitlistbox.tcl snitpagesmanager.tcl \
		snittree.tcl snitCabWidgets.tcl snitScrollNotebook.tcl \
		ParseXML.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/Common
pkgdata_DATA = $(CommonScripts) pkgIndex.tcl \
	DeepwoodsBanner.gif new.gif open.gif save.gif print.gif close.gif
pkgdocdir = $(datadir)/$(PACKAGE)/Doc
pkgdoc_DATA = Finn.pdf
BUILT_SOURCES = Version.tcl
noinst_DATA = Version.tcl

EXTRA_DIST = $(CommonScripts) \
	     Finn.tex FinnFigure1.pdf FinnFigure2a.pdf FinnFigure2b.pdf \
	     DeepwoodsBanner.gif new.gif open.gif save.gif print.gif \
	     close.gif CommonTests.tcl CommonTclGroup.h gray50.xbm info.xbm \
	     questhead.xbm unknown.xpm openfold.png palette.png

XXX_TESTS = CommonTests${EXEEXT}

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES += $(TCLKIT)

CLEANFILES = Finn.pdf *.aux *.toc *.log Version.tcl pkgIndex.tcl 

Finn.pdf : Finn.tex FinnFigure1.pdf FinnFigure2a.pdf FinnFigure2b.pdf
	-ln -s $(srcdir)/Finn.tex ./
	-ln -s $(srcdir)/FinnFigure*.pdf ./
	$(PDFLATEX) Finn
	$(PDFLATEX) Finn
	$(PDFLATEX) Finn

Version.tcl : $(top_builddir)/config.status 
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakeVersion.kit \
		$(PACKAGE) $(VERSION) \
		MRR_VERSION $(MRR_VERSION) \
		MRR_MAJOR_VERSION $(MRR_MAJOR_VERSION) \
		MRR_MINOR_VERSION $(MRR_MINOR_VERSION) \
		SYSTEMVERSION $(SYSTEMVERSION) \
		MRR_PATCH_LEVEL $(MRR_PATCH_LEVEL)



CommonTests${EXEEXT}: CommonTests.tcl $(CommonScripts) DeepwoodsBanner.gif \
		new.gif open.gif save.gif print.gif close.gif gray50.xbm \
		info.xbm questhead.xbm unknown.xpm openfold.png palette.png
	-rm -f CommonTests.kit
	-rm -rf CommonTests.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/CommonTests.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap CommonTests.kit
	-rm -f CommonTests.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit CommonTests \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) CommonTests \
		lib/Common $(CommonScripts) DeepwoodsBanner.gif new.gif \
			   open.gif save.gif print.gif close.gif gray50.xbm \
			   info.xbm questhead.xbm unknown.xpm openfold.png \
			   palette.png
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit CommonTests \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap CommonTests${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf CommonTests.vfs


pkgIndex.tcl : $(CommonScripts) Version.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)



$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

FORCE:
