#* 
#* ------------------------------------------------------------------
#* Makefile.am - Azatrax USB Model Railroad interface devices
#* Created by Robert Heller on Mon Jun 25 10:23:39 2012
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
#*     Copyright (C) 1994,1995,2002-2012  Robert Heller D/B/A Deepwoods Software
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

AUTOMAKE_OPTIONS = subdir-objects
BUILT_SOURCES = $(TCLKIT) azatrax_wrap.cc Azatrax.h

pkgincludedir = $(includedir)/$(PACKAGE)/Azatrax
pkginclude_HEADERS = Azatrax.h mrd.h sl2.h sr4.h
lib_LTLIBRARIES = libazatrax.la
libazatrax_la_SOURCES = Azatrax.cc $(pkginclude_HEADERS) ../gettext.h
libazatrax_la_XGETTEXTFILES = $(libazatrax_la_SOURCES)
nodist_libazatrax_la_SOURCES = azatrax_wrap.cc ../gettext.c
#INCLUDES = -I$(top_srcdir) -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)
AM_CPPFLAGS = -I$(top_builddir) -I$(srcdir)/.. -I$(TCL_INC_DIR)
#LTCFLAGS = -O0 -ggdb -g
libazatrax_la_CXXFLAGS = -DUSE_TCL_STUBS -Wall $(LIBUSB_CFLAGS) -g $(KIT_EXTRA_CFLAGS)
if CROSSCOMPILING
libazatrax_la_LDFLAGS = -no-undefined  -g -avoid-version  $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
else
libazatrax_la_LDFLAGS =   -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
endif
libazatrax_la_LIBADD = $(INTLLIBS) $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
#libazatrax_la-azatrax_wrap.lo : azatrax_wrap.cc
#	if $(LIBTOOL) --tag=CXX --mode=compile $(CXX) $(DEFS) $(TCL_DEFS) $(DEFAULT_INCLUDES) 	$(AM_CPPFLAGS) $(CPPFLAGS) $(libazatrax_la_CXXFLAGS) $(CXXFLAGS) -MT libazatrax_la-Azatrax.lo -MD -MP -MF "$(DEPDIR)/libazatrax_la-Azatrax.Tpo" -c -o libazatrax_la-Azatrax.lo `test -f 'Azatrax.cc' || echo '$(srcdir)/'`Azatrax.cc; \
#	then mv -f "$(DEPDIR)/libazatrax_la-Azatrax.Tpo" "$(DEPDIR)/libazatrax_la-Azatrax.Plo"; else rm -f "$(DEPDIR)/libazatrax_la-Azatrax.Tpo"; exit 1; fi
##	source='Azatrax.cc' object='libazatrax_la-Azatrax.lo' libtool=yes \
##	DEPDIR=$(DEPDIR) $(CXXDEPMODE) $(depcomp) \
##	$(LIBTOOL) --tag=CXX --mode=compile $(CXX) $(DEFS) $(TCL_DEFS) $(DEFAULT_INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(libazatrax_la_CXXFLAGS) $(CXXFLAGS) -c -o libazatrax_la-Azatrax.lo `test -f 'Azatrax.cc' || echo '$(srcdir)/'`Azatrax.cc
	
	

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

bin_SCRIPTS = MRDTest${EXEEXT} MRDSensorLoop${EXEEXT} \
		AzatraxDeviceMap${EXEEXT} SL2Test${EXEEXT} SR4Test${EXEEXT}
noinst_SCRIPTS = pkgIndex.tcl

noinst_DATA = azatrax.potlist

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = AzatraxProg.pot
pkgdata2dir = $(datadir)/$(PACKAGE)/Azatrax
pkgdata2_SCRIPTS = 90-Azatrax.rules 90-Azatrax.rules-Ubuntu

desktopdir = $(datadir)/applications
desktop_DATA = MRDTest.desktop MRDSensorLoop.desktop AzatraxDeviceMap.desktop \
		SL2Test.desktop SR4Test.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = MRDTest.png MRDSensorLoop.png AzatraxDeviceMap.png \
		SL2Test.png SR4Test.png

man_MANS = man1/MRDTest.1 man1/MRDSensorLoop.1 man1/AzatraxDeviceMap.1 \
		man1/SL2Test.1 man1/SR4Test.1

MRDTestSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/snitdialog.tcl \
                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/unknown.xpm \
                $(top_srcdir)/Scripts/Common/openfold.png \
                $(top_srcdir)/Scripts/Common/info.xbm \
                $(top_srcdir)/Scripts/Common/questhead.xbm \
                $(top_srcdir)/Scripts/Common/gray50.xbm \
		$(top_builddir)/Scripts/Common/Version.tcl

MRDSensorLoopSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
			$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
		        $(top_srcdir)/Scripts/Common/snitdialog.tcl \
                        $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		        $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
        		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
        		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		        $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		        $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                        $(top_srcdir)/Scripts/Common/unknown.xpm \
                        $(top_srcdir)/Scripts/Common/openfold.png \
                        $(top_srcdir)/Scripts/Common/info.xbm \
                        $(top_srcdir)/Scripts/Common/questhead.xbm \
                        $(top_srcdir)/Scripts/Common/gray50.xbm \
			$(top_builddir)/Scripts/Common/Version.tcl

AzatraxDeviceMapSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
			$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
		        $(top_srcdir)/Scripts/Common/snitdialog.tcl \
	                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
        	        $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
        		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
        		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		        $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		        $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                        $(top_srcdir)/Scripts/Common/unknown.xpm \
                        $(top_srcdir)/Scripts/Common/openfold.png \
                        $(top_srcdir)/Scripts/Common/info.xbm \
                        $(top_srcdir)/Scripts/Common/questhead.xbm \
                        $(top_srcdir)/Scripts/Common/gray50.xbm \
			$(top_builddir)/Scripts/Common/Version.tcl

SL2TestSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/snitdialog.tcl \
                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/unknown.xpm \
                $(top_srcdir)/Scripts/Common/openfold.png \
                $(top_srcdir)/Scripts/Common/info.xbm \
                $(top_srcdir)/Scripts/Common/questhead.xbm \
                $(top_srcdir)/Scripts/Common/gray50.xbm \
		$(top_builddir)/Scripts/Common/Version.tcl

SR4TestSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/snitdialog.tcl \
		$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
       		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/unknown.xpm \
                $(top_srcdir)/Scripts/Common/openfold.png \
                $(top_srcdir)/Scripts/Common/info.xbm \
                $(top_srcdir)/Scripts/Common/questhead.xbm \
                $(top_srcdir)/Scripts/Common/gray50.xbm \
		$(top_builddir)/Scripts/Common/Version.tcl

EXTRA_DIST = MRDTest.src azatrax.i MRDTest.desktop MRDTest.png Doxyfile.in \
	90-Azatrax.rules.in 90-Azatrax.rules-Ubuntu.in MRDSensorLoop.src \
	MRDSensorLoop.desktop MRDSensorLoop.png AzatraxDeviceMap.desktop \
	AzatraxDeviceMap.png AzatraxDeviceMap.src SL2Test.desktop SL2Test.png \
	SL2Test.src SR4Test.desktop SR4Test.png SR4Test.src Azatrax.h.in

#DEFS = @DEFS@
SWIG_FLAGS =  -tcl8 $(AM_CPPFLAGS)
CLEANFILES    = $(BUILT_SOURCES) *.kit azatrax_wrap.cc MRDTest${EXEEXT} \
		pkgIndex.tcl AzatraxProg.pot azatrax.potlist 90-Azatrax.rules \
		90-Azatrax.rules-Ubuntu \
		MRDSensorLoop${EXEEXT} SL2Test${EXEEXT} SR4Test${EXEEXT} \
		AzatraxDeviceMap${EXEEXT}

azatrax_wrap.cc: azatrax.i $(pkginclude_HEADERS) $(top_builddir)/config.status
	$(SWIG_CXX) $(SWIG_FLAGS) $(AM_CPPFLAGS) -o azatrax_wrap.cc $(srcdir)/azatrax.i

azatrax.potlist: $(libazatrax_la_XGETTEXTFILES)
	echo $(addprefix $(subdir)/,$(libazatrax_la_XGETTEXTFILES)) |\
	tr ' ' '\n' > azatrax.potlist

AzatraxProg.pot: MRDTest.src MRDSensorLoop.src AzatraxDeviceMap.src \
		SL2Test.src SR4Test.src \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,MRDTest.src \
				MRDSensorLoop.src AzatraxDeviceMap.src \
				SL2Test.src SR4Test.src) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for MRDTest/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >AzatraxProg.pot

pkgIndex.tcl: libazatrax.la $(top_builddir)/config.status
	echo 'package ifneeded Azatrax $(AZATRAX_VERSIONLIB) [list load [file join $$dir libazatrax[info sharedlibextension]]]' > pkgIndex.tcl

MRDTest${EXEEXT}: MRDTest.src libazatrax.la $(MRDTestSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/AzatraxProg/index.html \
		$(top_builddir)/po/AzatraxProg/msgfiles
	-rm -f  MRDTest.kit
	-rm -rf MRDTest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/MRDTest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap MRDTest.kit
	-rm -f  MRDTest.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDTest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		lib/Common $(MRDTestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit MRDTest \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		lib/Azatrax .libs/libazatrax$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		Help $(top_builddir)/Doc/User/AzatraxProg/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		Messages $(top_builddir)/po/AzatraxProg/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap MRDTest${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf MRDTest.vfs
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf MRDTest.app
	mkdir -p MRDTest.app/Contents/MacOS/
	cp MRDTest$(EXEEXT) MRDTest.app/Contents/MacOS/
	mkdir -p MRDTest.app/Contents/Resources/
	-rm -rf MRDTest.iconset
	mkdir MRDTest.iconset
	sips -z 16 16     $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/MRDTest.png --out MRDTest.iconset/icon_512x512@2x.png
	iconutil -c icns MRDTest.iconset
	-rm -rf MRDTest.iconset
	cp MRDTest.icns MRDTest.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit MRDTest 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o MRDTest.app/Contents/Info.plist \
		MRDTest.plist
	-rm -f MRDTest.plist MRDTest.icns
endif

SL2Test${EXEEXT}: SL2Test.src libazatrax.la $(SL2TestSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/AzatraxProg/index.html \
		$(top_builddir)/po/AzatraxProg/msgfiles
	-rm -f  SL2Test.kit
	-rm -rf SL2Test.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/SL2Test.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap SL2Test.kit
	-rm -f  SL2Test.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit SL2Test \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SL2Test \
		lib/Common $(SL2TestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit SL2Test \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SL2Test \
		lib/Azatrax .libs/libazatrax$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SL2Test \
		Help $(top_builddir)/Doc/User/AzatraxProg/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SL2Test \
		Messages $(top_builddir)/po/AzatraxProg/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap SL2Test${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf SL2Test.vfs
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf SL2Test.app
	mkdir -p SL2Test.app/Contents/MacOS/
	cp SL2Test$(EXEEXT) SL2Test.app/Contents/MacOS/
	mkdir -p SL2Test.app/Contents/Resources/
	-rm -rf SL2Test.iconset
	mkdir SL2Test.iconset
	sips -z 16 16     $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/SL2Test.png --out SL2Test.iconset/icon_512x512@2x.png
	iconutil -c icns SL2Test.iconset
	-rm -rf SL2Test.iconset
	cp SL2Test.icns SL2Test.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit SL2Test 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o SL2Test.app/Contents/Info.plist \
		SL2Test.plist
	-rm -f SL2Test.plist SL2Test.icns
endif

SR4Test${EXEEXT}: SR4Test.src libazatrax.la $(SR4TestSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/AzatraxProg/index.html \
		$(top_builddir)/po/AzatraxProg/msgfiles
	-rm -f  SR4Test.kit
	-rm -rf SR4Test.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/SR4Test.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap SR4Test.kit
	-rm -f  SR4Test.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit SR4Test \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SR4Test \
		lib/Common $(SR4TestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit SR4Test \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SR4Test \
		lib/Azatrax .libs/libazatrax$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SR4Test \
		Help $(top_builddir)/Doc/User/AzatraxProg/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SR4Test \
		Messages $(top_builddir)/po/AzatraxProg/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap SR4Test${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf SR4Test.vfs
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf SR4Test.app
	mkdir -p SR4Test.app/Contents/MacOS/
	cp SR4Test$(EXEEXT) SR4Test.app/Contents/MacOS/
	mkdir -p SR4Test.app/Contents/Resources/
	-rm -rf SR4Test.iconset
	mkdir SR4Test.iconset
	sips -z 16 16     $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/SR4Test.png --out SR4Test.iconset/icon_512x512@2x.png
	iconutil -c icns SR4Test.iconset
	-rm -rf SR4Test.iconset
	cp SR4Test.icns SR4Test.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit SR4Test 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o SR4Test.app/Contents/Info.plist \
		SR4Test.plist
	-rm -f SR4Test.plist SR4Test.icns
endif

MRDSensorLoop${EXEEXT}: MRDSensorLoop.src libazatrax.la $(MRDSensorLoopSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/AzatraxProg/index.html \
		$(top_builddir)/po/AzatraxProg/msgfiles
	-rm -f  MRDSensorLoop.kit
	-rm -rf MRDSensorLoop.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/MRDSensorLoop.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap MRDSensorLoop.kit
	-rm -f  MRDSensorLoop.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDSensorLoop \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		lib/Common $(MRDSensorLoopSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit MRDSensorLoop \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		lib/Azatrax .libs/libazatrax$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		Help $(top_builddir)/Doc/User/AzatraxProg/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		Messages $(top_builddir)/po/AzatraxProg/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap MRDSensorLoop${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf MRDSensorLoop.vfs
if MACOSX
# create application for Mac OSX
	-rm -rf MRDSensorLoop.app
	mkdir -p MRDSensorLoop.app/Contents/MacOS/
	cp MRDSensorLoop$(EXEEXT) MRDSensorLoop.app/Contents/MacOS/
	mkdir -p MRDSensorLoop.app/Contents/Resources/
	-rm -rf MRDSensorLoop.iconset
	mkdir MRDSensorLoop.iconset
	sips -z 16 16     $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/MRDSensorLoop.png --out MRDSensorLoop.iconset/icon_512x512@2x.png
	iconutil -c icns MRDSensorLoop.iconset
	-rm -rf MRDSensorLoop.iconset
	cp MRDSensorLoop.icns MRDSensorLoop.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit MRDSensorLoop 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o MRDSensorLoop.app/Contents/Info.plist \
		MRDSensorLoop.plist
	-rm -f MRDSensorLoop.plist MRDSensorLoop.icns
endif

AzatraxDeviceMap${EXEEXT}: AzatraxDeviceMap.src libazatrax.la $(AzatraxDeviceMapSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/AzatraxProg/index.html \
		$(top_builddir)/po/AzatraxProg/msgfiles
	-rm -f  AzatraxDeviceMap.kit
	-rm -rf AzatraxDeviceMap.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/AzatraxDeviceMap.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap AzatraxDeviceMap.kit
	-rm -f  AzatraxDeviceMap.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit AzatraxDeviceMap \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit AzatraxDeviceMap \
		lib $(CSVLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit AzatraxDeviceMap \
		lib $(STRUCTLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit AzatraxDeviceMap \
		lib/Common $(AzatraxDeviceMapSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit AzatraxDeviceMap \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit AzatraxDeviceMap \
		lib/Azatrax .libs/libazatrax$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit AzatraxDeviceMap \
		Help $(top_builddir)/Doc/User/AzatraxProg/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit AzatraxDeviceMap \
		Messages $(top_builddir)/po/AzatraxProg/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap AzatraxDeviceMap${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf AzatraxDeviceMap.vfs
if MACOSX
# create application for Mac OSX
	-rm -rf AzatraxDeviceMap.app
	mkdir -p AzatraxDeviceMap.app/Contents/MacOS/
	cp AzatraxDeviceMap$(EXEEXT) AzatraxDeviceMap.app/Contents/MacOS/
	mkdir -p AzatraxDeviceMap.app/Contents/Resources/
	-rm -rf AzatraxDeviceMap.iconset
	mkdir AzatraxDeviceMap.iconset
	sips -z 16 16     $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/AzatraxDeviceMap.png --out AzatraxDeviceMap.iconset/icon_512x512@2x.png
	iconutil -c icns AzatraxDeviceMap.iconset
	-rm -rf AzatraxDeviceMap.iconset
	cp AzatraxDeviceMap.icns AzatraxDeviceMap.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit AzatraxDeviceMap 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o AzatraxDeviceMap.app/Contents/Info.plist \
		AzatraxDeviceMap.plist
	-rm -f AzatraxDeviceMap.plist AzatraxDeviceMap.icns
endif

if MACOSX
install-exec-local: MRDTest.app MRDSensorLoop.app AzatraxDeviceMap.app \
			SL2Test.app SR4Test.app
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh MRDTest.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh MRDSensorLoop.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh AzatraxDeviceMap.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh SL2Test.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh SR4Test.app $(DESTDIR)$(bindir)

MRDTest.app: MRDTest${EXEEXT}

MRDSensorLoop.app: MRDSensorLoop${EXEEXT}

AzatraxDeviceMap.app: AzatraxDeviceMap${EXEEXT}

SL2Test.app: SL2Test${EXEEXT}

SR4Test.app: SR4Test${EXEEXT}

endif



install-exec-hook: libazatrax.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
if CROSSCOMPILING
	cp    $(DESTDIR)$(bindir)/libazatrax$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libazatrax$(SHLIB_SUFFIX)
else
	ln -fs $(libdir)/libazatrax$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libazatrax$(SHLIB_SUFFIX)
endif
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_azatrax.tcl
	
$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/AzatraxProg/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User AzatraxProg/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/AzatraxProg/msgfiles: FORCE
	$(MAKE) -C ../../po/AzatraxProg msgfiles

FORCE:

90-Azatrax.rules : 90-Azatrax.rules.in 
	cp $(srcdir)/90-Azatrax.rules.in ./90-Azatrax.rules

90-Azatrax.rules-Ubuntu : 90-Azatrax.rules-Ubuntu.in 
	cp $(srcdir)/90-Azatrax.rules-Ubuntu.in ./90-Azatrax.rules-Ubuntu

man1/MRDTest.1 : Doxyfile MRDTest.src
	-rm -rf man1/MRDTest.1
	$(DOXYGEN)

man1/SL2Test.1 : Doxyfile SL2Test.src
	-rm -rf man1/SL2Test.1
	$(DOXYGEN)

man1/SR4Test.1 : Doxyfile SR4Test.src
	-rm -rf man1/SR4Test.1
	$(DOXYGEN)

man1/MRDSensorLoop.1 : Doxyfile MRDSensorLoop.src
	-rm -rf man1/MRDSensorLoop.1
	$(DOXYGEN)

man1/AzatraxDeviceMap.1 : Doxyfile AzatraxDeviceMap.src
	-rm -rf man1/AzatraxDeviceMap.1
	$(DOXYGEN)

clean-local:
	-rm -rf man1
if MACOSX
	-rm -rf MRDTest.app MRDSensorLoop.app AzatraxDeviceMap.app \
		SL2Test.app SR4Test.app
	
endif


	
Azatrax.h : Azatrax.h.in $(top_builddir)/config.status
	sed -e 's|=AZATRAX_VERSIONLIB=|@AZATRAX_VERSIONLIB@|g' \
	< $(srcdir)/Azatrax.h.in > ./Azatrax.h



