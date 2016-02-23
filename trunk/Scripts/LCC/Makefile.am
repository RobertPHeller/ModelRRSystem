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
#  Last Modified : <160223.0949>
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

EXTRA_DIST = lcc.tcl lcctest.src ConfigurationEditor.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/LCC
pkgdata_DATA = lcc.tcl pkgIndex.tcl

CLEANFILES = pkgIndex.tcl

pkgIndex.tcl : lcc.tcl ConfigurationEditor.tcl
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
                $(top_srcdir)/Scripts/LCC/ConfigurationEditor.tcl \
                $(top_srcdir)/Scripts/LCC/lcc.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/questhead.xbm \
		$(top_srcdir)/Scripts/Common/unknown.xpm
		

LCCTest.pot: LCCTest.src lcc.tcl \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,LCCTest.src lcc.tcl) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for LCCTest/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >LCCTest.pot

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
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf LCCTest.app
	mkdir -p LCCTest.app/Contents/MacOS/
	cp LCCTest$(EXEEXT) LCCTest.app/Contents/MacOS/
	mkdir -p LCCTest.app/Contents/Resources/
	-rm -rf LCCTest.iconset
	mkdir LCCTest.iconset
	sips -z 16 16     $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/LCCTest.png --out LCCTest.iconset/icon_512x512@2x.png
	iconutil -c icns LCCTest.iconset
	-rm -rf LCCTest.iconset
	cp LCCTest.icns LCCTest.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit LCCTest 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o LCCTest.app/Contents/Info.plist \
		LCCTest.plist
	-rm -f LCCTest.plist LCCTest.icns

install-exec-local: LCCTest.app
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh LCCTest.app $(DESTDIR)$(bindir)

LCCTest.app: LCCTest${EXEEXT}

endif


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

	
