#* 
#* ------------------------------------------------------------------
#* Makefile.am - Azatrax MRD series USB Model Railroad sensor / relay units
#* Created by Robert Heller on Sun Oct 23 10:09:44 2011
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

pkgincludedir = $(includedir)/$(PACKAGE)/MRD
pkginclude_HEADERS = mrd.h

lib_LTLIBRARIES = libmrd.la
libmrd_la_SOURCES = mrd.cc $(pkginclude_HEADERS) ../gettext.h
libmrd_la_XGETTEXTFILES = $(libmrd_la_SOURCES)
nodist_libmrd_la_SOURCES = mrd_wrap.cc ../gettext.c
INCLUDES = -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)
#LTCFLAGS = -O0 -ggdb -g
libmrd_la_CXXFLAGS =  $(INCLUDES) -Wall $(LIBUSB_CFLAGS) -g
if CROSSCOMPILING
libmrd_la_LDFLAGS =   -g -avoid-version  $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
else
libmrd_la_LDFLAGS =   -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
endif

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT) mrd_wrap.cc mrd.h

bin_SCRIPTS = MRDTest${EXEEXT} MRDSensorLoop${EXEEXT} MRDDeviceMap${EXEEXT}
noinst_SCRIPTS = pkgIndex.tcl

noinst_DATA = mrd.potlist

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = MRDTest.pot 
pkgdata2dir = $(datadir)/$(PACKAGE)/MRD
pkgdata2_SCRIPTS = 90-MRD.rules

desktopdir = $(datadir)/applications
desktop_DATA = MRDTest.desktop MRDSensorLoop.desktop MRDDeviceMap.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = MRDTest.png MRDSensorLoop.png MRDDeviceMap.png

man_MANS = man1/MRDTest.1 man1/MRDSensorLoop.1 man1/MRDDeviceMap.1

MRDTestSCRIPTS = $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
		$(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl

MRDSensorLoopSCRIPTS = $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
			$(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl

MRDDeviceMapSCRIPTS = $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
			$(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl

EXTRA_DIST = MRDTest.src mrd.i MRDTest.desktop MRDTest.png Doxyfile.in \
		90-MRD.rules.in MRDSensorLoop.src MRDSensorLoop.desktop \
		MRDSensorLoop.png MRDDeviceMap.desktop MRDDeviceMap.png \
		MRDDeviceMap.src mrd.h.in

DEFS = @DEFS@ $(TCL_DEFS)
SWIG_FLAGS =  -tcl8 -c++ $(INCLUDES)
CLEANFILES    = $(BUILT_SOURCES) *.kit MRDTest${EXEEXT} \
		pkgIndex.tcl MRDTest.pot mrd.potlist 90-MRD.rules \
		MRDDeviceMap${EXEEXT} MRDSensorLoop${EXEEXT} 

mrd_wrap.cc : mrd.i $(pkginclude_HEADERS) $(top_builddir)/config.status
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o mrd_wrap.cc $(srcdir)/mrd.i

mrd.potlist: $(libmrd_la_XGETTEXTFILES)
	echo $(addprefix $(subdir)/,$(libmrd_la_XGETTEXTFILES)) |\
	tr ' ' '\n' > mrd.potlist

MRDTest.pot: MRDTest.src MRDSensorLoop.src MRDDeviceMap.src \
		$(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,MRDTest.src MRDSensorLoop.src) \
		Scripts/Common/BWStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for MRDTest/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >MRDTest.pot

pkgIndex.tcl: libmrd.la $(top_builddir)/config.status
	echo 'package ifneeded Mrd $(MRD_VERSIONLIB) [list load [file join $$dir libmrd[info sharedlibextension]]]' > pkgIndex.tcl


MRDTest${EXEEXT}: MRDTest.src libmrd.la $(MRDTestSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/MRDTest/MRDTest.html \
		$(top_builddir)/po/MRDTest/msgfiles
	-rm -f  MRDTest.kit
	-rm -rf MRDTest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/MRDTest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap MRDTest.kit
	-rm -f  MRDTest.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDTest \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDTest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		lib/Common $(MRDTestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit MRDTest \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		lib/mrd .libs/libmrd$(SHLIB_SUFFIX) pkgIndex.tcl
	$(UNZIP) -qq -d MRDTest.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		Help $(top_builddir)/Doc/User/MRDTest/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDTest \
		Messages $(top_builddir)/po/MRDTest/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap MRDTest${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf MRDTest.vfs

MRDSensorLoop${EXEEXT}: MRDSensorLoop.src libmrd.la $(MRDSensorLoopSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/MRDTest/MRDTest.html \
		$(top_builddir)/po/MRDTest/msgfiles
	-rm -f  MRDSensorLoop.kit
	-rm -rf MRDSensorLoop.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/MRDSensorLoop.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap MRDSensorLoop.kit
	-rm -f  MRDSensorLoop.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDSensorLoop \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDSensorLoop \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		lib/Common $(MRDSensorLoopSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit MRDSensorLoop \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		lib/mrd .libs/libmrd$(SHLIB_SUFFIX) pkgIndex.tcl
	$(UNZIP) -qq -d MRDSensorLoop.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		Help $(top_builddir)/Doc/User/MRDTest/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDSensorLoop \
		Messages $(top_builddir)/po/MRDTest/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap MRDSensorLoop${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf MRDSensorLoop.vfs

MRDDeviceMap${EXEEXT}: MRDDeviceMap.src libmrd.la $(MRDDeviceMapSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/MRDTest/MRDTest.html \
		$(top_builddir)/po/MRDTest/msgfiles
	-rm -f  MRDDeviceMap.kit
	-rm -rf MRDDeviceMap.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/MRDDeviceMap.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap MRDDeviceMap.kit
	-rm -f  MRDDeviceMap.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDDeviceMap \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDDeviceMap \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDDeviceMap \
		lib $(CSVLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit MRDDeviceMap \
		lib $(STRUCTLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDDeviceMap \
		lib/Common $(MRDDeviceMapSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit MRDDeviceMap \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDDeviceMap \
		lib/mrd .libs/libmrd$(SHLIB_SUFFIX) pkgIndex.tcl
	$(UNZIP) -qq -d MRDDeviceMap.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDDeviceMap \
		Help $(top_builddir)/Doc/User/MRDTest/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit MRDDeviceMap \
		Messages $(top_builddir)/po/MRDTest/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap MRDDeviceMap${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf MRDDeviceMap.vfs

install-exec-hook: libmrd.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
if CROSSCOMPILING
	cp    $(DESTDIR)$(bindir)/libmrd$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libmrd$(SHLIB_SUFFIX)
else
	ln -fs $(libdir)/libmrd$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libmrd$(SHLIB_SUFFIX)
endif
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_mrd.tcl

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/MRDTest/MRDTest.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User MRDTest/MRDTest.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/MRDTest/msgfiles: FORCE
	$(MAKE) -C ../../po/MRDTest msgfiles

FORCE:

90-MRD.rules : 90-MRD.rules.in 
	cp $(srcdir)/90-MRD.rules.in ./90-MRD.rules

man1/MRDTest.1 : Doxyfile MRDTest.src
	-rm -rf man1/MRDTest.1
	$(DOXYGEN)

man1/MRDSensorLoop.1 : Doxyfile MRDSensorLoop.src
	-rm -rf man1/MRDSensorLoop.1
	$(DOXYGEN)

man1/MRDDeviceMap.1 : Doxyfile MRDDeviceMap.src
	-rm -rf man1/MRDDeviceMap.1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

	
mrd.h : mrd.h.in $(top_builddir)/config.status
	sed -e 's|=MRD_VERSIONLIB=|@MRD_VERSIONLIB@|g' \
	< $(srcdir)/mrd.h.in > ./mrd.h
