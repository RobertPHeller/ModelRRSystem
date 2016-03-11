##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Feb 2 13:41:10 2016
#  Last Modified : <160311.1504>
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
#    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
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


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

EXTRA_DIST = lcc.tcl lcctest.src ConfigurationEditor.tcl eventDialogs.tcl \
		ConfigDialogs.tcl OpenLCB.tcl OpenLCB.desktop OpenLCB.png \
		Doxyfile.in

bin_SCRIPTS = OpenLCB${EXEEXT}

pkgdatadir = $(datadir)/$(PACKAGE)/LCC
pkgdata_DATA = lcc.tcl pkgIndex.tcl ConfigDialogs.tcl eventDialogs.tcl \
		ConfigurationEditor.tcl OpenLCB.pot
desktopdir = $(datadir)/applications
desktop_DATA = OpenLCB.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = OpenLCB.png

man_MANS = man1/OpenLCB.1

CLEANFILES = pkgIndex.tcl OpenLCB${EXEEXT} OpenLCB.pot

pkgIndex.tcl : lcc.tcl ConfigurationEditor.tcl eventDialogs.tcl \
		ConfigDialogs.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)
	
LCCTestSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
                $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
                $(top_srcdir)/Scripts/Common/snitdialog.tcl \
                $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/mainwindow.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
                $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/snitrotext.tcl \
                $(top_srcdir)/Scripts/Common/ParseXML.tcl \
                $(top_srcdir)/Scripts/Common/snitScrollNotebook.tcl \
                $(top_srcdir)/Scripts/LCC/ConfigurationEditor.tcl \
                $(top_srcdir)/Scripts/LCC/lcc.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/questhead.xbm \
		$(top_srcdir)/Scripts/Common/unknown.xpm
		

LCCTest${EXEEXT}: LCCTest.src $(LCCTestSCRIPTS)
	-rm -f  LCCTest.kit
	-rm -rf  LCCTest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/LCCTest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap LCCTest.kit
	-rm -f  LCCTest.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit LCCTest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit LCCTest \
		lib $(URILIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit LCCTest \
		lib/Common $(LCCTestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit LCCTest \
		Common
	$(UNZIP) -qq -d LCCTest.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(UNZIP) -qq -d LCCTest.vfs/lib \
		$(top_srcdir)/BuildData/Tclxml3.1-GenericPureTcl.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap LCCTest${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf LCCTest.vfs

OpenLCBSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
                $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
                $(top_srcdir)/Scripts/Common/snitdialog.tcl \
                $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/mainwindow.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
                $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/snitrotext.tcl \
                $(top_srcdir)/Scripts/Common/ParseXML.tcl \
                $(top_srcdir)/Scripts/Common/snitScrollNotebook.tcl \
                $(top_srcdir)/Scripts/LCC/ConfigurationEditor.tcl \
                $(top_srcdir)/Scripts/LCC/lcc.tcl \
                $(top_srcdir)/Scripts/LCC/eventDialogs.tcl \
                $(top_srcdir)/Scripts/LCC/ConfigDialogs.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/questhead.xbm \
		$(top_srcdir)/Scripts/Common/unknown.xpm
		

OpenLCB.pot: OpenLCB.tcl lcc.tcl \
                ConfigDialogs.tcl eventDialogs.tcl ConfigurationEditor.tcl \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m \
		-L Tcl $(addprefix $(subdir)/,OpenLCB.tcl lcc.tcl ConfigDialogs.tcl eventDialogs.tcl ConfigurationEditor.tcl) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for OpenLCB/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >OpenLCB.pot

OpenLCB${EXEEXT}: OpenLCB.tcl $(OpenLCBSCRIPTS) \
	$(top_builddir)/Doc/User/OpenLCB/index.html \
	$(top_builddir)/po/OpenLCB/msgfiles
	-rm -f  OpenLCB.kit
	-rm -rf  OpenLCB.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/OpenLCB.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap OpenLCB.kit
	-rm -f  OpenLCB.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit OpenLCB \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit OpenLCB \
		lib $(URILIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit OpenLCB \
		lib/Common $(OpenLCBSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit OpenLCB \
		Common
	$(UNZIP) -qq -d OpenLCB.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(UNZIP) -qq -d OpenLCB.vfs/lib \
		$(top_srcdir)/BuildData/Tclxml3.1-GenericPureTcl.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit OpenLCB \
		Help $(top_builddir)/Doc/User/OpenLCB/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit OpenLCB \
		Messages $(top_builddir)/po/OpenLCB/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap OpenLCB${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf OpenLCB.vfs
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf OpenLCB.app
	mkdir -p OpenLCB.app/Contents/MacOS/
	cp OpenLCB$(EXEEXT) OpenLCB.app/Contents/MacOS/
	mkdir -p OpenLCB.app/Contents/Resources/
	-rm -rf OpenLCB.iconset
	mkdir OpenLCB.iconset
	sips -z 16 16     $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/OpenLCB.png --out OpenLCB.iconset/icon_512x512@2x.png
	iconutil -c icns OpenLCB.iconset
	-rm -rf OpenLCB.iconset
	cp OpenLCB.icns OpenLCB.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit OpenLCB 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o OpenLCB.app/Contents/Info.plist \
		OpenLCB.plist
	-rm -f OpenLCB.plist OpenLCB.icns

install-exec-local: OpenLCB.app
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh OpenLCB.app $(DESTDIR)$(bindir)

OpenLCB.app: OpenLCB${EXEEXT}

endif


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

	
$(top_builddir)/Doc/User/OpenLCB/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User OpenLCB/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/OpenLCB/msgfiles: FORCE
	$(MAKE) -C ../../po/OpenLCB msgfiles

FORCE:


man1/OpenLCB.1 : Doxyfile OpenLCB.tcl
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1
if MACOSX
	-rm -rf OpenLCB.app
endif
