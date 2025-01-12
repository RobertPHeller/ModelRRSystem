#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Mon Aug 22 21:10:56 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/04 19:06:36  heller
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

BUILT_SOURCES = diskfree_wrap.c

pkglibdir = $(libdir)/$(PACKAGE)/Installer

pkglib_LTLIBRARIES = libdiskfree.la
AM_CPPFLAGS = -I$(top_builddir)  -I. -I$(TCL_INC_DIR)
nodist_libdiskfree_la_SOURCES = diskfree_wrap.c
if CROSSCOMPILING
libdiskfree_la_LDFLAGS = -no-undefined  -g -avoid-version
else
libdiskfree_la_LDFLAGS = -g -version-info 0:0:0
endif
libdiskfree_la_LIBADD = $(INTLLIBS) $(TCL_STUB_LIB_SPEC)
libdiskfree_la_CFLAGS = -DUSE_TCL_STUBS $(AM_CPPFLAGS) $(KIT_EXTRA_CFLAGS)
setupSCRIPTS = $(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/snitpagesmanager.tcl \
		$(top_srcdir)/Scripts/Common/snitrotext.tcl \
		$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/unknown.xpm \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/openfold.png \
		$(top_srcdir)/Scripts/Common/snitLFs.tcl
setupIMAGES = 
setupLIBIMAGES = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif
EXTRA_DIST = diskfree.i setup.tcl $(setupIMAGES) setup.png

noinst_SCRIPTS = setup${EXEEXT}

if MACOSX
install-data-hook: setup.app
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
	$(top_srcdir)/BuildScripts/macappInstall.sh setup.app $(DESTDIR)$(pkglibdir)

setup.app: setup${EXEEXT}
else
install-data-hook: setup${EXEEXT}
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
	$(INSTALL_DATA) "setup${EXEEXT}"  "$(DESTDIR)$(pkglibdir)/setup${EXEEXT}"
endif

CLEANFILES = $(BUILT_SOURCES) pkgIndex.tcl setup.kit setup${EXEEXT}

SWIG_FLAGS =  -tcl8 $(AM_CPPFLAGS)

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES += $(TCLKIT)

diskfree_wrap.c : diskfree.i
	$(SWIG) $(SWIG_FLAGS) $(AM_CPPFLAGS) -o diskfree_wrap.c \
			$(srcdir)/diskfree.i

pkgIndex.tcl: libdiskfree.la
	echo 'package ifneeded Diskfree 1.0 [list load [file join $$dir libdiskfree[info sharedlibextension]] Diskfree]' > pkgIndex.tcl

setup${EXEEXT}: setup.tcl $(setupSCRIPTS) $(setupIMAGES) $(setupLIBIMAGES) \
		pkgIndex.tcl libdiskfree.la
	-rm -f  setup.kit
	-rm -rf setup.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/setup.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap setup.kit
	-rm -f  setup.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit setup \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit setup \
		lib/Diskfree .libs/libdiskfree$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit setup \
		lib/Images $(setupIMAGES) $(setupLIBIMAGES)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit setup lib/Common \
		$(setupSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit setup Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap setup${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf setup.vfs
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf setup.app
	mkdir -p setup.app/Contents/MacOS/
	cp setup$(EXEEXT) setup.app/Contents/MacOS/
	mkdir -p setup.app/Contents/Resources/
	-rm -rf setup.iconset
	mkdir setup.iconset
	sips -z 16 16     $(srcdir)/setup.png --out setup.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/setup.png --out setup.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/setup.png --out setup.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/setup.png --out setup.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/setup.png --out setup.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/setup.png --out setup.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/setup.png --out setup.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/setup.png --out setup.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/setup.png --out setup.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/setup.png --out setup.iconset/icon_512x512@2x.png
	iconutil -c icns setup.iconset
	-rm -rf setup.iconset
	cp setup.icns setup.app/Contents/Resources/
	-rm -f setup.icns
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit setup 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o setup.app/Contents/Info.plist \
		setup.plist
	-rm -f setup.plist

clean-local:
	-rm -rf setup.app
endif

$(top_builddir)/Scripts/Common/Version.tcl : $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl


$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

FORCE:
