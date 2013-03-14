#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file
#* Created by Robert Heller on Tue Aug 23 18:13:01 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.8  2007/04/19 17:23:21  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.7  2007/02/01 20:58:49  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.6  2007/01/08 19:05:54  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.5  2006/08/04 05:31:37  heller
#* Modification History: 2.1.6
#* Modification History:
#* Modification History: Revision 1.4  2006/05/22 17:01:11  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.3  2006/05/18 00:13:12  heller
#* Modification History: May 17, 2006 Lock down III
#* Modification History:
#* Modification History: Revision 1.2  2005/11/14 20:28:45  heller
#* Modification History: Nov 14, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:34  heller
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

#INCLUDES = -I.
#sbin_PROGRAMS = raildriverd
#raildriverd_SOURCES = RaildriverIO.h  RaildriverServer.h \
#		      RaildriverIO.cc RaildriverServer.cc \
#		      raildriverd_main.cc
#nodist_raildriverd_SOURCES = raildriver.tab.cc raildriver.tab.h  \
#			../gettext.c ../gettext.h
#raildriverd_XGETTEXTSOURCES = $(raildriverd_SOURCES)
#DEFS = @DEFS@ 
#raildriverd_LDFLAGS = -g $(LIBUSB_LIBS)
#raildriverd_CXXFLAGS = -g -Wall $(LIBUSB_CFLAGS)
#BUILT_SOURCES       = raildriver.tab.cc raildriver.tab.h
#raildriverd.potlist: $(raildriverd_XGETTEXTSOURCES)
#	echo $(addprefix $(subdir)/,$(raildriverd_XGETTEXTSOURCES)) |\
#	tr ' ' '\n' > raildriverd.potlist
#raildriver.tab.h: raildriver.tab.cc
#raildriver.tab.cc : raildriver.y
#	$(BISONXX) \
#		--verbose --defines \
#		--output-file=./raildriver.tab.cc -h ./raildriver.tab.h \
#		$(srcdir)/raildriver.y
#EXTRA_DIST	    = LocoTest.src raildriver.y \
#			raildriverd.hotplug.in RailDriverGroup.h \
#			print-usb-usermap.src Doxyfile.in raildriverd.udev.in \
#			90-raildriver.rules.in ButtonLegends.cls

pkgincludedir = $(includedir)/$(PACKAGE)/RaildriverIO
pkginclude_HEADERS = RaildriverIO.h

INCLUDES = -I$(top_builddir) -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)
lib_LTLIBRARIES = libraildriverio.la
libraildriverio_la_SOURCES = RaildriverIO.cc $(pkginclude_HEADERS) ../gettext.h
libraildriverio_la_XGETTEXTFILES = $(libraildriverio_la_SOURCES)
nodist_libraildriverio_la_SOURCES = raildriverio_wrap.cc ../gettext.c
libraildriverio_la_CXXFLAGS = -DUSE_TCL_STUBS $(INCLUDES) -Wall $(LIBUSB_CFLAGS) -g
if CROSSCOMPILING
libraildriverio_la_LDFLAGS =   -g -avoid-version  $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
else
libraildriverio_la_LDFLAGS =   -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC) $(LIBUSB_LIBS)
endif
xlibdir = $(libdir)/$(PACKAGE)/RailDriverNotInstalled
xlib_LTLIBRARIES = libsigterm.la
libsigterm_la_SOURCES = sigterm_wrap.cc
libsigterm_la_CXXFLAGS =  $(INCLUDES) -Wall -g
if CROSSCOMPILING
libsigterm_la_LDFLAGS = -g -avoid-version  $(TCL_STUB_LIB_SPEC)
else
libsigterm_la_LDFLAGS = -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC)
endif
SWIG_FLAGS =  -tcl8 -c++ $(INCLUDES)


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

sbin_SCRIPTS = raildriverd${EXEEXT}

pkgdatadir = $(datadir)/$(PACKAGE)/RailDriver
pkgdata_SCRIPTS = raildriverd.hotplug print-usb-usermap raildriverd.udev \
			90-raildriver.rules 90-raildriver.rules-Ubuntu \
			ButtonLegends.cls
BUILT_SOURCES       = $(TCLKIT) raildriverio_wrap.cc sigterm_wrap.cc \
			RaildriverIO.h
CLEANFILES	    = $(BUILT_SOURCES) LocoTest print-usb-usermap \
			 raildriverd.hotplug raildriverio.potlist \
			 raildriverd.pot 90-raildriver.rules \
			 90-raildriver.rules-Ubuntu pkgIndex.tcl \
			 raildriverd.udev raildriverd${EXEEXT}
noinst_DATA	    = raildriverd.pot
bin_SCRIPTS	    = LocoTest

EXTRA_DIST	    = LocoTest.src raildriverd.src raildriverio.i  \
			raildriverd.hotplug.in sigterm.i \
			print-usb-usermap.src Doxyfile.in raildriverd.udev.in \
			90-raildriver.rules.in 90-raildriver.rules-Ubuntu.in \
			ButtonLegends.cls RaildriverIO.h.in

raildriverdSCRIPTS = $(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl

man_MANS = man8/raildriverd.8

raildriverio_wrap.cc : raildriverio.i $(pkginclude_HEADERS) \
			$(top_builddir)/config.status
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o raildriverio_wrap.cc $(srcdir)/raildriverio.i

sigterm_wrap.cc : sigterm.i
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o sigterm_wrap.cc $(srcdir)/sigterm.i

noinst_DATA += raildriverio.potlist

raildriverio.potlist: $(libraildriverio_la_XGETTEXTFILES)
	echo $(addprefix $(subdir)/,$(libraildriverio_la_XGETTEXTFILES)) |\
	tr ' ' '\n' > raildriverio.potlist

raildriverd.pot: raildriverd.src
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		 -k_m -L Tcl $(addprefix $(subdir)/,raildriverd.src) |\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for raildriverd/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >raildriverd.pot

pkgIndex.tcl: libraildriverio.la $(top_builddir)/config.status
	echo 'package ifneeded Raildriverio $(RAILDRIVERIO_VERSIONLIB) [list load [file join $$dir libraildriverio[info sharedlibextension]]]' > pkgIndex.tcl

raildriverd${EXEEXT}: raildriverd.src libraildriverio.la \
		pkgIndex.tcl $(raildriverdSCRIPTS) \
		libsigterm.la \
		$(top_builddir)/po/raildriverd/msgfiles
	-rm -f  raildriverd.kit
	-rm -rf raildriverd.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/raildriverd.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap raildriverd.kit
	-rm -f  raildriverd.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit raildriverd \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit raildriverd \
		lib $(TCLLOGLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit raildriverd \
		lib/raildriverio .libs/libraildriverio$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit raildriverd \
		lib/sigterm .libs/libsigterm$(SHLIB_SUFFIX)
	echo 'package ifneeded Sigterm 1.0 [list load [file join $$dir libsigterm[info sharedlibextension]]]' > raildriverd.vfs/lib/sigterm/pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit  raildriverd \
		lib/Common $(raildriverdSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit raildriverd \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit raildriverd \
		Messages $(top_builddir)/po/raildriverd/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap raildriverd${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf raildriverd.vfs

raildriverd.hotplug : raildriverd.hotplug.in $(top_builddir)/config.status
	sed -e 's|=sbindir=|@sbindir@|g' < $(srcdir)/raildriverd.hotplug.in > ./raildriverd.hotplug
	chmod +x raildriverd.hotplug
	
raildriverd.udev : raildriverd.udev.in $(top_builddir)/config.status
	sed -e 's|=sbindir=|@sbindir@|g' < $(srcdir)/raildriverd.udev.in > ./raildriverd.udev
	chmod +x raildriverd.udev
	
90-raildriver.rules : 90-raildriver.rules.in 
	cp $(srcdir)/90-raildriver.rules.in ./90-raildriver.rules
	
90-raildriver.rules-Ubuntu : 90-raildriver.rules-Ubuntu.in 
	cp $(srcdir)/90-raildriver.rules-Ubuntu.in ./90-raildriver.rules-Ubuntu
	

LocoTest : LocoTest.src $(top_builddir)/config_tcl.sed
	sed -f $(top_builddir)/config_tcl.sed <$(srcdir)/LocoTest.src >./LocoTest
	chmod +x LocoTest

print-usb-usermap : print-usb-usermap.src $(top_builddir)/config_tcl.sed
	sed -f $(top_builddir)/config_tcl.sed <$(srcdir)/print-usb-usermap.src > ./print-usb-usermap
	chmod +x print-usb-usermap


$(top_builddir)/config_tcl.sed: $(top_builddir)/config.status \
				$(top_builddir)/config_tcl.sed.in
	cd $(top_builddir) && CONFIG_FILES=$(@F) CONFIG_HEADERS= $(SHELL) ./config.status

../../po/raildriverd/msgfiles: FORCE
	$(MAKE) -C ../../po/raildriverd msgfiles

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}


FORCE:


man8/raildriverd.8: Doxyfile raildriverd.src
	-rm -rf man8
	$(DOXYGEN)

clean-local:
	-rm -rf man8

install-exec-hook: libraildriverio.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
if CROSSCOMPILING
	cp    $(DESTDIR)$(bindir)/libraildriverio$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libraildriverio$(SHLIB_SUFFIX)
else
	ln -fs $(libdir)/libraildriverio$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libraildriverio$(SHLIB_SUFFIX)
endif
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_raildriverio.tcl

install-data-hook:
	-rm -rf $(DESTDIR)$(xlibdir)


RaildriverIO.h: RaildriverIO.h.in $(top_builddir)/config.status
	sed -e 's|=RAILDRIVERIO_VERSIONLIB=|@RAILDRIVERIO_VERSIONLIB@|g' \
	< $(srcdir)/RaildriverIO.h.in > ./RaildriverIO.h
