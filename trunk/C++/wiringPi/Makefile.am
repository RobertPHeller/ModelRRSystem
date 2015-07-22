##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Wed Jul 22 10:53:17 2015
#  Last Modified : <150722.1105>
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


lib_LTLIBRARIES = libtclwiringpi.la
libtclwiringpi_la_SOURCES =
nodist_libtclwiringpi_la_SOURCES = tclwiringpi_wrap.c
INCLUDES = 
libtclwiringpi_la_CFLAGS = -DUSE_TCL_STUBS -Wall $(WIRINGPI_CFLAGS) -g
libtclwiringpi_la_LDFLAGS =   -g -version-info 0:0:0  $(TCL_STUB_LIB_SPEC) $(WIRINGPI_LDFLAGS)
libtclwiringpi_la_LIBADD = $(TCL_STUB_LIB_SPEC) $(WIRINGPI_LIBS)

BUILT_SOURCES = pkgIndex.tcl

noinst_SCRIPTS = pkgIndex.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/wiringPi

SWIG_FLAGS =  -tcl8 $(INCLUDES) $(WIRINGPI_CFLAGS)

CLEANFILES    = $(BUILT_SOURCES)

tclwiringpi_wrap.c tclwiringpi.i $(top_builddir)/config.status
	$(SWIG_C) $(SWIG_FLAGS) -o tclwiringpi_wrap.c $(srcdir)/tclwiringpi.i
	

pkgIndex.tcl: libtclwiringpi.la $(top_builddir)/config.status
	echo 'package ifneeded Tclwiringpi 1.0.0 [list load [file join $$dir libtclwiringpi[info sharedlibextension]]]' > pkgIndex.tcl


install-exec-hook: libtclwiringpi.la pkgIndex.tcl
	$(INSTALL) -d $(DESTDIR)$(pkglibdir)
	ln -fs $(libdir)/libtclwiringpi$(SHLIB_SUFFIX) $(DESTDIR)$(pkglibdir)/libtclwiringpi$(SHLIB_SUFFIX)
	touch $(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	cat   pkgIndex.tcl >>$(DESTDIR)$(pkglibdir)/pkgIndex.tcl
	$(INSTALL_DATA) pkgIndex.tcl $(DESTDIR)$(pkglibdir)/pkgIndex_tclwiringpi.tcl

