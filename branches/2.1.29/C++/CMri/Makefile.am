#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Tue Aug 23 10:14:50 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.12  2007/10/22 17:39:01  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.11  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.10  2007/04/19 17:23:20  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.9  2007/02/21 20:21:20  heller
#* Modification History: SWIG Hackery
#* Modification History:
#* Modification History: Revision 1.8  2007/02/02 03:21:12  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.7  2007/02/02 03:12:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.6  2007/02/02 02:37:16  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.5  2007/02/01 20:00:51  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.4  2007/01/08 19:05:54  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.3  2006/05/22 19:38:06  heller
#* Modification History: Release 2.1.4 Final
#* Modification History:
#* Modification History: Revision 1.2  2006/05/22 17:01:11  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:33  heller
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

pkgincludedir = $(includedir)/$(PACKAGE)/CMri
pkginclude_HEADERS = cmri.h

lib_LTLIBRARIES = libcmri.la
libcmri_la_SOURCES = cmri.cc $(pkginclude_HEADERS) ../gettext.h
libcmri_la_XGETTEXTFILES = $(libcmri_la_SOURCES)
nodist_libcmri_la_SOURCES = cmri_wrap.cc ../gettext.c
INCLUDES = -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)
libcmri_la_CXXFLAGS =  $(INCLUDES) -Wall
libcmri_la_LDFLAGS = -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC) 

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT) cmri_wrap.cc

bin_SCRIPTS = UniversalTest${EXEEXT}
noinst_SCRIPTS = pkgIndex.tcl

noinst_DATA = cmri.potlist

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = UniversalTest.pot

desktopdir = $(datadir)/applications
desktop_DATA = UniversalTest.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA =  UniversalTest.png

man_MANS = man1/UniversalTest.1

UniversalTestSCRIPTS = $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
                $(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
                $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
                $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl

EXTRA_DIST = UniversalTest.src cmri.i UniversalTest.desktop UniversalTest.png \
	     Doxyfile.in

DEFS = @DEFS@ $(TCL_DEFS)
SWIG_FLAGS =  -tcl8 -c++ $(INCLUDES)
CLEANFILES    = $(BUILT_SOURCES)  UniversalTest.kit UniversalTest${EXEEXT} \
		pkgIndex.tcl UniversalTest.pot cmri.potlist

cmri_wrap.cc : cmri.i $(pkginclude_HEADERS) $(top_builddir)/config.status
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o cmri_wrap.cc $(srcdir)/cmri.i

cmri.potlist: $(libcmri_la_XGETTEXTFILES) 
	echo $(addprefix $(subdir)/,$(libcmri_la_XGETTEXTFILES)) |\
	tr ' ' '\n' > cmri.potlist

UniversalTest.pot: UniversalTest.src \
			$(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl 
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,UniversalTest.src) \
		Scripts/Common/BWStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for UniversalTest/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >UniversalTest.pot

pkgIndex.tcl: libcmri.la $(top_builddir)/config.status
	echo 'package ifneeded Cmri $(CMRI_VERSIONLIB) [list load [file join $$dir libcmri[info sharedlibextension]]]' > pkgIndex.tcl


UniversalTest${EXEEXT}: UniversalTest.src libcmri.la $(UniversalTestSCRIPTS) \
		pkgIndex.tcl \
		$(top_builddir)/Doc/User/UniversalTest/UniversalTest.html \
		$(top_builddir)/po/UniversalTest/msgfiles
	-rm -f  UniversalTest.kit
	-rm -rf UniversalTest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/UniversalTest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap UniversalTest.kit
	-rm -f  UniversalTest.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit UniversalTest \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit UniversalTest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		lib/Common $(UniversalTestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit UniversalTest \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		lib/CMri .libs/libcmri$(SHLIB_SUFFIX) pkgIndex.tcl
	$(UNZIP) -qq -d UniversalTest.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		Help $(top_builddir)/Doc/User/UniversalTest/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		Messages $(top_builddir)/po/UniversalTest/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap UniversalTest${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf UniversalTest.vfs

install-exec-hook: libcmri.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
	ln -fs $(libdir)/libcmri$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libcmri$(SHLIB_SUFFIX)
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_cmri.tcl

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/UniversalTest/UniversalTest.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User UniversalTest/UniversalTest.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/UniversalTest/msgfiles: FORCE
	$(MAKE) -C ../../po/UniversalTest msgfiles

FORCE:


man1/UniversalTest.1 : Doxyfile UniversalTest.src
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

	
