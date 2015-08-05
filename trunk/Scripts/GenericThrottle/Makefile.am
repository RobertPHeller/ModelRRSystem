#* 
#* ------------------------------------------------------------------
#* Makefile.am - Generic Throttle program
#* Created by Robert Heller on Sun Apr 22 08:44:32 2012
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 2012  Robert Heller D/B/A Deepwoods Software
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

GTScripts = 
if MACOSX                                                                       
bin_SCRIPTS = GenericThrottle.dmg
else
bin_SCRIPTS = GenericThrottle$(EXEEXT)
endif

GIFS = 

CLEANFILES = GenericThrottle.kit $(bin_SCRIPTS) GenericThrottle.pot

EXTRA_DIST = GenericThrottle.src $(TTScripts) $(GIFS) Doxyfile.in \
		GenericThrottle.png GenericThrottle.desktop

desktopdir = $(datadir)/applications
desktop_DATA = GenericThrottle.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = GenericThrottle.png

man_MANS = man1/GenericThrottle.1

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = GenericThrottle.pot

pkgcodedir = $(datadir)/$(PACKAGE)/GenericThrottle
pkgcode_DATA = GenericThrottle.src

GTLib = GenericThrottle
GTLibFiles = $(GTScripts) $(GIFS)

GTCommon = Common
GTCommonFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
	$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
	$(top_srcdir)/Scripts/Common/snitCabWidgets.tcl \
	$(top_srcdir)/Scripts/Common/snitLFs.tcl \
	$(top_srcdir)/Scripts/Common/gettext.tcl \
	$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
	$(top_srcdir)/Scripts/Common/mainwindow.tcl \
	$(top_srcdir)/Scripts/Common/splash.tcl \
	$(top_srcdir)/Scripts/Common/snitdialog.tcl \
	$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
	$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
	$(top_srcdir)/Scripts/Common/questhead.xbm \
	$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
	$(top_srcdir)/Scripts/Common/unknown.xpm \
	$(top_srcdir)/Scripts/Common/openfold.png \
	$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
	$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
	$(top_srcdir)/Scripts/Common/snitpagesmanager.tcl \
	$(top_builddir)/Scripts/Common/Version.tcl

CXXSupport = GTSupport
CXXSupportFiles = 

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

GenericThrottle.pot: GenericThrottle.src $(GTScripts) \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,GenericThrottle.src $(GTScripts)) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Generic Throttle/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >GenericThrottle.pot

GenericThrottle$(EXEEXT) : GenericThrottle.src $(GTLibFiles) $(GTCommonFiles) \
		$(top_builddir)/Doc/User/GenericThrottle/index.html \
		$(top_builddir)/po/GenericThrottle/msgfiles
	-rm -rf GenericThrottle.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/GenericThrottle.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap GenericThrottle.kit
	-rm -rf GenericThrottle.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit GenericThrottle \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit GenericThrottle \
		lib/$(GTCommon) $(GTCommonFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit GenericThrottle \
		$(GTCommon)
	$(UNZIP) -qq -d GenericThrottle.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit GenericThrottle \
		Help $(top_builddir)/Doc/User/GenericThrottle/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit GenericThrottle \
		Messages $(top_builddir)/po/GenericThrottle/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap GenericThrottle${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf GenericThrottle.vfs GenericThrottle.kit

#  Waiting for an actual list of file in $(GTLibFiles)
#	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) GenericThrottle \
#		lib/$(GTLib) $(GTLibFiles)
#	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit GenericThrottle \
#		$(GTLib)

if MACOSX
# create application for Mac OSX                                               $
GenericThrottle.dmg: GenericThrottle$(EXEEXT)
	-rm -rf GenericThrottle.app
	mkdir -p GenericThrottle.app/Contents/MacOS/
	cp GenericThrottle$(EXEEXT) GenericThrottle.app/Contents/MacOS/
	mkdir -p GenericThrottle.app/Contents/Resources/
	-rm -rf GenericThrottle.iconset
	mkdir GenericThrottle.iconset
	sips -z 16 16     $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/GenericThrottle.png --out GenericThrottle.iconset/icon_512x512@2x.png
	iconutil -c icns GenericThrottle.iconset
	-rm -rf GenericThrottle.iconset
	cp GenericThrottle.icns GenericThrottle.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit GenericThrottle 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o GenericThrottle.app/Contents/Info.plist \
		GenericThrottle.plist
	-rm -f GenericThrottle.plist
	-rm -rf dmg
	mkdir dmg
	cp -r GenericThrottle.app dmg
	ln -s /Applications dmg/
	rm -f GenericThrottle.dmg
	hdiutil create -srcfolder dmg -format UDZO -volname GenericThrottle.dmg GenericThrottle.dmg
	-rm -rf dmg
endif

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/GenericThrottle/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User GenericThrottle/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

$(top_builddir)/po/GenericThrottle/msgfiles: FORCE
	$(MAKE) -C $(top_builddir)/po/GenericThrottle msgfiles

FORCE:

man1/GenericThrottle.1 : Doxyfile GenericThrottle.src
	-rm -f man1/GenericThrottle.1
	$(DOXYGEN)

clean-local:
	-rm -rf man1


