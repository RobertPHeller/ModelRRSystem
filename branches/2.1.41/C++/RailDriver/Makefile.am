##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Dec 16 14:39:16 2015
#  Last Modified : <170727.1200>
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
#    Copyright (C) 2015  Robert Heller D/B/A Deepwoods Software
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


SUBDIRS = linux mac windows

HIDAPI_HEADER = hidapi.h
HIDAPI_SOURCE = $(HIDAPI_C)
HIDAPI_OBJECT = $(HIDAPI_SOURCE:.c=.o)

pkgincludedir = $(includedir)/$(PACKAGE)/RaildriverIO
pkginclude_HEADERS = RaildriverIO.h $(HIDAPI_HEADER)

INCLUDES = -I$(top_builddir) -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)
lib_LTLIBRARIES = libraildriverio.la
libraildriverio_la_SOURCES = RaildriverIO.cc $(pkginclude_HEADERS) \
	../gettext.h
libraildriverio_la_XGETTEXTFILES = $(libraildriverio_la_SOURCES)
nodist_libraildriverio_la_SOURCES = raildriverio_wrap.cc ../gettext.c  hid.c
libraildriverio_la_CFLAGS =  -DUSE_TCL_STUBS $(INCLUDES) -Wall $(HIDAPI_CFLAGS) $(KIT_EXTRA_CFLAGS)
libraildriverio_la_CXXFLAGS = $(libraildriverio_la_CFLAGS)
if CROSSCOMPILING
libraildriverio_la_LDFLAGS = -no-undefined   -g -avoid-version  $(TCL_STUB_LIB_SPEC) $(HIDAPI_LIBS) 
else
libraildriverio_la_LDFLAGS =   -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC) $(HIDAPI_LIBS)
endif
libraildriverio_la_LIBADD = $(INTLLIBS) $(TCL_STUB_LIB_SPEC)  $(HIDAPI_LIBS)
xlibdir = $(libdir)/$(PACKAGE)/RailDriverNotInstalled
xlib_LTLIBRARIES = libsigterm.la
libsigterm_la_SOURCES = sigterm_wrap.cc
libsigterm_la_CXXFLAGS =  -DUSE_TCL_STUBS $(INCLUDES) -Wall -g  $(KIT_EXTRA_CFLAGS)
if CROSSCOMPILING
libsigterm_la_LDFLAGS = -no-undefined -g -avoid-version  $(TCL_STUB_LIB_SPEC)
else
libsigterm_la_LDFLAGS = -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC)
endif
libsigterm_la_LIBADD = $(INTLLIBS) $(TCL_STUB_LIB_SPEC)

hid.c : $(HIDAPI_SOURCE)
	cp $(srcdir)/$(HIDAPI_SOURCE) hid.c

SWIG_FLAGS =  -tcl8  $(INCLUDES)


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

sbin_SCRIPTS = raildriverd${EXEEXT}

pkgdatadir = $(datadir)/$(PACKAGE)/RailDriver
pkgdata_SCRIPTS = raildriverd.hotplug print-usb-usermap raildriverd.udev \
			90-raildriver.rules \
			ButtonLegends.cls

pkgdatadir_systemd $(pkgdatadir)/systemd
pkgdatadir_systemd_SCRIPTS = systemd/90-raildriver.rules \
			systemd/raildriverd-hidraw \
			systemd/raildriverd-hidraw@.service \
			systemd/raildriver-get-hidraw
systemd/raildriverd-hidraw@.service : systemd/raildriverd-hidraw_AT.service
	cp $(srcdir)/systemd/raildriverd-hidraw_AT.service \
		systemd/raildriverd-hidraw@.service

BUILT_SOURCES       = $(TCLKIT) raildriverio_wrap.cc sigterm_wrap.cc \
			RaildriverIO.h hid.c 
CLEANFILES	    = $(BUILT_SOURCES) LocoTest print-usb-usermap \
			 raildriverd.hotplug raildriverio.potlist \
			 raildriverd.pot 90-raildriver.rules \
			 pkgIndex.tcl \
			 raildriverd.udev raildriverd${EXEEXT}
noinst_DATA	    = raildriverd.pot
bin_SCRIPTS	    = LocoTest

EXTRA_DIST	    = LocoTest.src raildriverd.src raildriverio.i  \
			raildriverd.hotplug.in sigterm.i \
			print-usb-usermap.src Doxyfile.in raildriverd.udev.in \
			90-raildriver.rules.in \
			ButtonLegends.cls RaildriverIO.h.in

raildriverdSCRIPTS = $(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl

man_MANS = man8/raildriverd.8

raildriverio_wrap.cc : raildriverio.i $(pkginclude_HEADERS) \
			$(top_builddir)/config.status
	$(SWIG_CXX) $(SWIG_FLAGS) $(INCLUDES) -o raildriverio_wrap.cc $(srcdir)/raildriverio.i

sigterm_wrap.cc : sigterm.i
	$(SWIG_CXX) $(SWIG_FLAGS) $(INCLUDES) -o sigterm_wrap.cc $(srcdir)/sigterm.i

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
