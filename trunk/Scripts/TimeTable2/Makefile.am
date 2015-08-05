#* 
#* ------------------------------------------------------------------
#* Makefile.am - Makefile for TT2
#* Created by Robert Heller on Fri Dec 23 11:01:33 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.11  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.10  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.9  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.8  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.7  2006/08/04 01:59:26  heller
#* Modification History: Aug 3 Lockdown
#* Modification History:
#* Modification History: Revision 1.6  2006/05/22 17:01:12  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.5  2006/05/20 14:23:16  heller
#* Modification History: Added LaTeX Style file
#* Modification History:
#* Modification History: Revision 1.4  2006/05/19 02:47:46  heller
#* Modification History: Last Minute Updates
#* Modification History:
#* Modification History: Revision 1.3  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/03/06 18:46:21  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/01/03 15:30:21  heller
#* Modification History: Lockdown
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

TTScripts = TTMainWindow.tcl TTMenuSupport.tcl TTFileIO.tcl \
	    TTTrains.tcl TTStations.tcl TTCabs.tcl TTNotes.tcl TTPrint.tcl \
	    TTSystemConfiguration.tcl

if MACOSX                                                                       
bin_SCRIPTS = TTChart2TT2$(EXEEXT) TimeTable.dmg
else
bin_SCRIPTS = TTChart2TT2$(EXEEXT) TimeTable$(EXEEXT)
endif

GIFS =  addstorage.gif  cleardupstation.gif  setdupstation.gif \
	addtrain.gif    deletetrain.gif      smallStation.gif \
	banner.gif      edittrain.gif        smallTrack.gif \
	addcab.gif      createnote.gif       editnote.gif \
	addnotetotrain.gif addnotetotrainatstation.gif \
	removenotefromtrain.gif removenotefromtrainatstation.gif \
	largePrinter.gif 

CLEANFILES = TTChart2TT2.kit TimeTable.kit $(bin_SCRIPTS) TimeTable2.pot
	
EXTRA_DIST  = TTChart2TT2.src TimeTable.src $(TTScripts) $(GIFS) TimeTable.sty \
		ReadOldTT.tcl Doxyfile.in TimeTable.png TimeTable.desktop


desktopdir = $(datadir)/applications
desktop_DATA = TimeTable.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = TimeTable.png

man_MANS = man1/TimeTable.1 man1/TTChart2TT2.1 man1/TimeTableLaTeXOpts.1

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = TimeTable2.pot

TTLib = TimeTable2
TTLibFiles = $(TTScripts) $(GIFS)

TTCommon = Common
TTCommonFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
		 $(top_srcdir)/Scripts/Common/new.gif \
		 $(top_srcdir)/Scripts/Common/open.gif \
		 $(top_srcdir)/Scripts/Common/close.gif \
		 $(top_srcdir)/Scripts/Common/save.gif \
		 $(top_srcdir)/Scripts/Common/print.gif \
		 $(top_srcdir)/Scripts/Common/gray50.xbm \
		 $(top_srcdir)/Scripts/Common/info.xbm \
		 $(top_srcdir)/Scripts/Common/openfold.png \
		 $(top_srcdir)/Scripts/Common/palette.png \
		 $(top_srcdir)/Scripts/Common/unknown.xpm \
		 $(top_srcdir)/Scripts/Common/questhead.xbm \
		 $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		 $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		 $(top_srcdir)/Scripts/Common/splash.tcl \
		 $(top_srcdir)/Scripts/Common/mainwindow.tcl \
		 $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl \
                 $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                 $(top_srcdir)/Scripts/Common/snitmainframe.tcl \
                 $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
                 $(top_srcdir)/Scripts/Common/snitdialog.tcl \
                 $(top_srcdir)/Scripts/Common/snitlistbox.tcl \
                 $(top_srcdir)/Scripts/Common/snitrotext.tcl \
                 $(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
                 $(top_srcdir)/Scripts/Common/snitscrollw.tcl \
                 $(top_srcdir)/Scripts/Common/snitpagesmanager.tcl \
                 $(top_srcdir)/Scripts/Common/snittree.tcl \
                 $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
                 $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		 $(top_srcdir)/Scripts/Common/gettext.tcl \
		 $(top_builddir)/Scripts/Common/Version.tcl

CXXSupport = TTSupport
CXXSupportFiles =  $(top_builddir)/C++/TTSupport/.libs/libttclasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/TTSupport/pkgIndex.tcl 

pkgdata2dir = $(datadir)/$(PACKAGE)/TTScripts
pkgdata2_DATA = TimeTable.sty

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

TimeTable2.pot: TTChart2TT2.src ReadOldTT.tcl TimeTable.src $(TTScripts) \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,TTChart2TT2.src ReadOldTT.tcl TimeTable.src $(TTScripts)) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Time Table/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >TimeTable2.pot


TTChart2TT2$(EXEEXT) : TTChart2TT2.src ReadOldTT.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_builddir)/C++/TTSupport/libttclasses.la \
			$(top_builddir)/C++/TTSupport/pkgIndex.tcl \
			$(top_builddir)/po/TimeTable2/msgfiles
	-rm -rf TTChart2TT2.vfs $(srcdir)/TTChart2TT2.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/TTChart2TT2.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap TTChart2TT2.kit
	-rm -rf TTChart2TT2.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) TTChart2TT2 \
		lib/$(TTLib) ReadOldTT.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TTChart2TT2 \
		$(TTLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TTChart2TT2 \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TTChart2TT2 \
		Messages $(top_builddir)/po/TimeTable2/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap TTChart2TT2${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf TTChart2TT2.vfs TTChart2TT2.kit
	

TimeTable$(EXEEXT) : TimeTable.src $(TTLibFiles) $(TTCommonFiles) \
		$(top_builddir)/Doc/User/TimeTable/index.html \
		$(top_builddir)/C++/TTSupport/libttclasses.la \
		$(top_builddir)/C++/TTSupport/pkgIndex.tcl \
			$(top_builddir)/po/TimeTable2/msgfiles
	-rm -rf TimeTable.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/TimeTable.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  TimeTable.kit
	-rm -rf TimeTable.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit TimeTable \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) TimeTable \
		lib/$(TTLib) $(TTLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TimeTable \
		$(TTLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(TTCommon) $(TTCommonFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TimeTable \
		$(TTCommon)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(UNZIP) -qq -d TimeTable.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		Help $(top_builddir)/Doc/User/TimeTable/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TimeTable \
		Messages $(top_builddir)/po/TimeTable2/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap TimeTable${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf TimeTable.vfs TimeTable.kit

if MACOSX
# create application for Mac OSX                                               $
TimeTable.dmg: TimeTable$(EXEEXT)
	-rm -rf TimeTable.app
	mkdir -p TimeTable.app/Contents/MacOS/
	cp TimeTable$(EXEEXT) TimeTable.app/Contents/MacOS/
	mkdir -p TimeTable.app/Contents/Resources/
	-rm -rf TimeTable.iconset
	mkdir TimeTable.iconset
	sips -z 16 16     $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/TimeTable.png --out TimeTable.iconset/icon_512x512@2x.png
	iconutil -c icns TimeTable.iconset
	-rm -rf TimeTable.iconset
	cp TimeTable.icns TimeTable.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit TimeTable 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o TimeTable.app/Contents/Info.plist \
		TimeTable.plist
	-rm -f TimeTable.plist
	-rm -rf dmg
	mkdir dmg
	cp -r TimeTable.app dmg
	ln -s /Applications dmg/
	rm -f TimeTable.dmg
	hdiutil create -srcfolder dmg -format UDZO -volname TimeTable.dmg TimeTable.dmg
	-rm -rf dmg
endif

$(top_builddir)/C++/TTSupport/libttclasses.la : \
		$(top_srcdir)/C++/TTSupport/*.cc \
		$(top_srcdir)/C++/TTSupport/*.h \
		$(top_srcdir)/C++/TTSupport/*.i
	$(MAKE) -C $(top_builddir)/C++/TTSupport

$(top_builddir)/C++/TTSupport/pkgIndex.tcl : \
		$(top_builddir)/C++/TTSupport/libttclasses.la
	$(MAKE) -C $(top_builddir)/C++/TTSupport pkgIndex.tcl

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/TimeTable/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User TimeTable/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

$(top_builddir)/po/TimeTable2/msgfiles: FORCE
	$(MAKE) -C $(top_builddir)/po/TimeTable2 msgfiles

FORCE:

man1/TimeTable.1 : Doxyfile TimeTable.src
	-rm -f man1/TimeTable.1
	$(DOXYGEN)

man1/TimeTableLaTeXOpts.1 : Doxyfile TTPrint.tcl
	-rm -f man1/TimeTableLaTeXOpts.1
	$(DOXYGEN)

man1/TTChart2TT2.1 : Doxyfile TTChart2TT2.src
	-rm -f man1/TTChart2TT2.1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

