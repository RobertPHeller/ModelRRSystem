##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Apr 30 11:46:29 2017
#  Last Modified : <230527.1358>
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
#    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
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


pkgincludedir = $(includedir)/$(PACKAGE)/TclSocketCAN

pkginclude_HEADERS = 
lib_LTLIBRARIES = libtclsocketcan.la
libtclsocketcan_la_SOURCES = TclSocketCAN.c 
nodist_libtclsocketcan_la_SOURCES = TclSocketCAN_wrap.c
libtclsocketcan_la_XGETTEXTFILES = $(libtclsocketcan_la_SOURCES)
if CROSSCOMPILING
libtclsocketcan_la_LDFLAGS = -no-undefined -g -avoid-version $(TCL_STUB_LIB_SPEC)
else
libtclsocketcan_la_LDFLAGS = -g -version-info 0:0:0 $(TCL_STUB_LIB_SPEC)
endif
AM_CPPFLAGS = -I$(top_builddir) -I$(srcdir) -I$(srcdir)/.. -I$(TCL_INC_DIR)  
libtclsocketcan_la_CFLAGS =  -g -DUSE_TCL_STUBS -DTCLSOCKETCAN_VERSIONLIB=\"$(TCLSOCKETCAN_VERSIONLIB)\" $(AM_CPPFLAGS) -Wall $(KIT_EXTRA_CFLAGS)
libtclsocketcan_la_LIBADD   = $(TCL_STUB_LIB_SPEC)

BUILT_SOURCES = TclSocketCAN_wrap.c
noinst_SCRIPTS = pkgIndex.tcl
noinst_DATA = TclSocketCAN.potlist
EXTRA_DIST = TclSocketCAN.i

CLEANFILES = $(BUILT_SOURCES) pkgIndex.tcl TclSocketCAN.potlist

SWIG_FLAGS = -tcl8 $(AM_CPPFLAGS)
TclSocketCAN_wrap.c : TclSocketCAN.i $(pkginclude_HEADERS) \
	$(top_builddir)/config.status
	$(SWIG) $(SWIG_FLAGS) $(AM_CPPFLAGS) -o TclSocketCAN_wrap.c \
		$(srcdir)/TclSocketCAN.i

TclSocketCAN.potlist: $(libtclsocketcan_la_XGETTEXTFILES)
	echo $(addprefix $(subdir)/,$(libtclsocketcan_la_XGETTEXTFILES)) |\
	tr ' ' '\n' > TclSocketCAN.potlist
	 

pkgIndex.tcl: libtclsocketcan.la $(top_builddir)/config.status
	echo 'package ifneeded Tclsocketcan $(TCLSOCKETCAN_VERSIONLIB) [list load [file join $$dir libtclsocketcan[info sharedlibextension]]]' > pkgIndex.tcl

install-exec-hook: libtclsocketcan.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
if CROSSCOMPILING
	cp    $(DESTDIR)$(bindir)/libtclsocketcan$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libtclsocketcan$(SHLIB_SUFFIX)
else
	ln -fs $(libdir)/libtclsocketcan$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libtclsocketcan$(SHLIB_SUFFIX)
endif
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_tclsocketcan.tcl

