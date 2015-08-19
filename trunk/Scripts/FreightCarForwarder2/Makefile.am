#* 
#* ------------------------------------------------------------------
#* Makefile.am - Freight Car Forwarder 2
#* Created by Robert Heller on Wed Oct 19 19:23:42 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.13  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
#* Modification History:
#* Modification History: Revision 1.12  2007/10/22 21:10:05  heller
#* Modification History: 10221007
#* Modification History:
#* Modification History: Revision 1.11  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.10  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.9  2007/10/16 13:06:24  heller
#* Modification History: *** empty log message ***
#* Modification History:
#* Modification History: Revision 1.8  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.7  2007/02/01 20:00:54  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.6  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.5  2006/05/22 17:01:12  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.4  2006/05/19 02:47:46  heller
#* Modification History: Last Minute Updates
#* Modification History:
#* Modification History: Revision 1.3  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:38  heller
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

FCFScripts  = FCFCars.tcl FCFTrains.tcl FCFPrinters.tcl FCFIndustries.tcl 
FCFScripts += FCFDivisions.tcl FCFReports.tcl FCFSearchForCarsDialog.tcl
FCFScripts += FCFSelectATrainDialog.tcl FCFControlYardListsDialog.tcl
FCFScripts += FCFManageOneTrainDialog.tcl FCFSelectAnIndustryDialog.tcl
FCFScripts += FCFSelectAStationDialog.tcl
#FCFScripts += FCFdialog.tcl FCFTestDialog.tcl

FCFCreScripts = FCFCreSystem.tcl FCFCreIndustries.tcl FCFCreTrains.tcl \
		FCFCreOwners.tcl FCFCreOrders.tcl FCFCreCars.tcl

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)


SUBDIRS = NorthAmerican

if MACOSX                                                                       
bin_SCRIPTS = FCFMain.dmg FCFCreate.dmg
else                                                                            
bin_SCRIPTS = FCFMain$(EXEEXT) FCFCreate$(EXEEXT)
endif                                                                           

EXTRA_DIST  = FCFMain.src FCFCreate.src $(FCFScripts) $(FCFCreScripts) \
		addcar.gif assigncars.gif banner.gif \
		closeprint.gif deletecar.gif editcar.gif loadcars.gif \
		managetrainsprint.gif reports.gif resetIndustries.gif \
		runalltrains.gif runboxmoves.gif runonetrain.gif showcars.gif \
		traindisplay.gif unassignedcars.gif viewcar.gif yardprint.gif \
		FCFMain.png FCFCreate.png FCFMain.desktop FCFCreate.desktop \
		Doxyfile.in

desktopdir = $(datadir)/applications
desktop_DATA = FCFMain.desktop FCFCreate.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = FCFMain.png FCFCreate.png

man_MANS = man1/FCFMain.1 man1/FCFCreate.1

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = FreightCarForwarder2.pot


CLEANFILES = FCFMain.kit FCFCreate.kit $(bin_SCRIPTS) FreightCarForwarder2.pot

FCFLib = FreightCarForwarder2
FCFCreLib = FreightCarForwarder2
FCFLibFiles = $(FCFScripts) addcar.gif assigncars.gif banner.gif \
		closeprint.gif deletecar.gif editcar.gif loadcars.gif \
		managetrainsprint.gif reports.gif resetIndustries.gif \
		runalltrains.gif runboxmoves.gif runonetrain.gif showcars.gif \
		traindisplay.gif unassignedcars.gif viewcar.gif yardprint.gif

FCFCreLibFiles = $(FCFCreScripts) banner.gif

FCFCommon = Common
FCFCommonFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
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
		 $(top_srcdir)/Scripts/Common/unknown.xpm \
		 $(top_srcdir)/Scripts/Common/

CXXSupport = FCFSupport
CXXSupportFiles =  $(top_builddir)/C++/FCFSupport/.libs/libfcfclasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/FCFSupport/pkgIndex.tcl 

FreightCarForwarder2.pot: FCFMain.src FCFCreate.src $(FCFScripts) \
			$(FCFCreScripts)\
			$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,FCFMain.src FCFCreate.src $(FCFScripts) $(FCFCreScripts)) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Freight Car Forwarder/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >FreightCarForwarder2.pot

FCFMain${EXEEXT} : FCFMain.src $(FCFLibFiles) $(FCFCommonFiles) \
		$(top_builddir)/Doc/User/FCF/index.html \
		$(top_builddir)/po/FreightCarForwarder2/msgfiles \
		$(top_builddir)/C++/FCFSupport/libfcfclasses.la \
		$(top_builddir)/C++/FCFSupport/pkgIndex.tcl
	-rm -rf FCFMain.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/FCFMain.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  FCFMain.kit
	-rm -rf FCFMain.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit FCFMain \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) FCFMain \
		lib/$(FCFLib) $(FCFLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit FCFMain \
		$(FCFLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) FCFMain \
		lib/$(FCFCommon) $(FCFCommonFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit FCFMain \
		$(FCFCommon)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit FCFMain \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(UNZIP) -qq -d FCFMain.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit FCFMain \
		Help $(top_builddir)/Doc/User/FCF/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit FCFMain \
		Messages $(top_builddir)/po/FreightCarForwarder2/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap FCFMain${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf FCFMain.vfs FCFMain.kit

if MACOSX
# create application for Mac OSX                                               $
FCFMain.dmg: FCFMain$(EXEEXT)
	-rm -rf FCFMain.app
	mkdir -p FCFMain.app/Contents/MacOS/
	cp FCFMain$(EXEEXT) FCFMain.app/Contents/MacOS/
	mkdir -p FCFMain.app/Contents/Resources/
	-rm -rf FCFMain.iconset
	mkdir FCFMain.iconset
	sips -z 16 16     $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/FCFMain.png --out FCFMain.iconset/icon_512x512@2x.png
	iconutil -c icns FCFMain.iconset
	-rm -rf FCFMain.iconset
	cp FCFMain.icns FCFMain.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit FCFMain 2.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o FCFMain.app/Contents/Info.plist \
		FCFMain.plist
	-rm -f FCFMain.plist
	-rm -rf dmg
	mkdir dmg
	cp -r FCFMain.app dmg
	ln -s /Applications dmg/
	rm -f FCFMain.dmg
	hdiutil create -srcfolder dmg -format UDZO -volname FCFMain.dmg FCFMain.dmg
	-rm -rf dmg
endif

FCFCreate$(EXEEXT) : FCFCreate.src $(FCFCreLibFiles) $(FCFCommonFiles) \
		$(top_builddir)/po/FreightCarForwarder2/msgfiles \
		$(top_builddir)/Doc/User/FCF/index.html \
		$(srcdir)/*/*.dat
	-rm -rf FCFCreate.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap  $(srcdir)/FCFCreate.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap FCFCreate.kit
	-rm -rf FCFCreate.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit FCFCreate \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) FCFCreate \
		lib/$(FCFCreLib) $(FCFCreLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit FCFCreate \
		$(FCFCreLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit FCFCreate \
		lib/$(FCFCommon) $(FCFCommonFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit FCFCreate \
		$(FCFCommon)
	$(UNZIP) -qq -d FCFCreate.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit FCFCreate \
		Help $(top_builddir)/Doc/User/FCF/*
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  $(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit  FCFCreate \
	    Data/$$subdir $(srcdir)/$$subdir/*.dat; done;	
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit FCFCreate \
		Messages $(top_builddir)/po/FreightCarForwarder2/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap FCFCreate${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf FCFCreate.vfs FCFCreate.kit

if MACOSX
# create application for Mac OSX                                               $
FCFCreate.dmg: FCFCreate$(EXEEXT)
	-rm -rf FCFCreate.app
	mkdir -p FCFCreate.app/Contents/MacOS/
	cp FCFCreate$(EXEEXT) FCFCreate.app/Contents/MacOS/
	mkdir -p FCFCreate.app/Contents/Resources/
	-rm -rf FCFCreate.iconset
	mkdir FCFCreate.iconset
	sips -z 16 16     $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/FCFCreate.png --out FCFCreate.iconset/icon_512x512@2x.png
	iconutil -c icns FCFCreate.iconset
	-rm -rf FCFCreate.iconset
	cp FCFCreate.icns FCFCreate.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit FCFCreate 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o FCFCreate.app/Contents/Info.plist \
		FCFCreate.plist
	-rm -f FCFCreate.plist
	-rm -rf dmg
	mkdir dmg
	cp -r FCFCreate.app dmg
	ln -s /Applications dmg/
	rm -f FCFCreate.dmg
	hdiutil create -srcfolder dmg -format UDZO -volname FCFCreate.dmg FCFCreate.dmg
	-rm -rf dmg
endif

if MACOSX
install-exec-local: FCFMain.dmg FCFCreate.dmg
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh FCFMain.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh FCFCreate.app $(DESTDIR)$(bindir)

endif

$(top_builddir)/Doc/User/FCF/index.html : FORCE
	$(MAKE) -C $(top_builddir)/Doc/User FCF/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

$(top_builddir)/po/FreightCarForwarder2/msgfiles: FORCE
	$(MAKE) -C $(top_builddir)/po/FreightCarForwarder2 msgfiles

FORCE:

$(top_builddir)/C++/FCFSupport/libfcfclasses.la : \
		$(top_srcdir)/C++/FCFSupport/*.cc \
		$(top_srcdir)/C++/FCFSupport/*.h \
		$(top_srcdir)/C++/FCFSupport/*.i
	$(MAKE) -C $(top_builddir)/C++/FCFSupport

$(top_builddir)/C++/FCFSupport/pkgIndex.tcl : \
		$(top_builddir)/C++/FCFSupport/libfcfclasses.la
	$(MAKE) -C $(top_builddir)/C++/FCFSupport pkgIndex.tcl

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl


man1/FCFMain.1 man1/FCFCreate.1 : Doxyfile FCFMain.src FCFCreate.src
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

