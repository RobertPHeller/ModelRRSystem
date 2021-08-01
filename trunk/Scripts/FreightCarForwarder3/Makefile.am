##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 31 14:57:38 2021
#  Last Modified : <210801.1700>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#    Copyright (C) 2021  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
##############################################################################


FCF3Scripts = Cartypes.tcl  Cars.tcl

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

bin_SCRIPTS = FCF3Main$(EXEEXT)

EXTRA_DIST = FCF3Main.tcl $(FCF3Scripts) FCF3Main.desktop FCF3Main.png

desktopdir = $(datadir)/applications
desktop_DATA = FCF3Main.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = FCF3Main.png

man_MANS = man1/FCF3Main.1

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = FCF3Main.pot

CLEANFILES = FCF3Main.kit $(bin_SCRIPTS) FCF3Main.pot

FCF3Main.pot: FCF3Main.tcl $(FCF3MainScripts) \
			$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,FCF3Main.tcl $(FCF3MainScripts)) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Freight Car Forwarder V3/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >FCF3Main.pot
	    
FCF3MainCommonScripts = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
	$(top_srcdir)/Scripts/Common/new.gif \
	$(top_srcdir)/Scripts/Common/open.gif \
	$(top_srcdir)/Scripts/Common/close.gif \
	$(top_srcdir)/Scripts/Common/save.gif \
	$(top_srcdir)/Scripts/Common/print.gif \
	$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
	$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
	$(top_srcdir)/Scripts/Common/splash.tcl \
	$(top_srcdir)/Scripts/Common/mainwindow.tcl \
	$(top_srcdir)/Scripts/Common/snitLFs.tcl \
	$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
	$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
	$(top_srcdir)/Scripts/Common/snitdialog.tcl \
	$(top_srcdir)/Scripts/Common/snitlistbox.tcl \
	$(top_srcdir)/Scripts/Common/snitrotext.tcl \
	$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
	$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
	$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
	$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
	$(top_srcdir)/Scripts/Common/gettext.tcl \
	$(top_builddir)/Scripts/Common/Version.tcl \
	$(top_srcdir)/Scripts/Common/gray50.xbm \
	$(top_srcdir)/Scripts/Common/info.xbm \
	$(top_srcdir)/Scripts/Common/questhead.xbm \
	$(top_srcdir)/Scripts/Common/openfold.png \
	$(top_srcdir)/Scripts/Common/palette.png \
	$(top_srcdir)/Scripts/Common/unknown.xpm

FCF3Main${EXEEXT} : FCF3Main.tcl \
		$(FCF3MainScripts) \
		$(FCF3MainCommonScripts)
		$(top_builddir)/Doc/User/FCF3/index.html \
		$(top_builddir)/po/FCF3/msgfiles
	-rm -rf FCF3Main.vfs FCF3Main.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/FCF3Main.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap FCF3Main.kit
	-rm -rf FCF3Main.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit FCF3Main \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit FCF3Main \
		lib $(CSVLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) \
		FCF3Main lib/Common $(FCF3MainScripts) \
			$(FCF3MainCommonScripts)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit \
		FCF3Main Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit \
		FCF3Main Help $(top_builddir)/Doc/User/FCF3/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit \
		FCF3Main Messages \
		$(top_builddir)/po/FCF3/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap \
		FCF3Main${EXEEXT} -runtime \
			$(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf FCF3Main.vfs FCF3Main.kit
	

