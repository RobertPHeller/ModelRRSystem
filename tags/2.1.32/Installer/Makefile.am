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

BUILT_SOURCES = diskfree_wrap.cc

pkglibdir = $(libdir)/$(PACKAGE)/Installer

pkglib_LTLIBRARIES = diskfree.la
INCLUDES = -I$(top_builddir)  -I. -I$(TCL_INC_DIR)
nodist_diskfree_la_SOURCES = diskfree_wrap.cc
diskfree_la_LDFLAGS = -g -module -avoid-version $(TCL_STUB_LIB_SPEC)
diskfree_la_CXXFLAGS = -DUSE_TCL_STUBS $(INCLUDES)
setupSCRIPTS = $(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/fileentry.tcl
setupIMAGES = 
setupLIBIMAGES = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif
EXTRA_DIST = diskfree.i setup.tcl $(setupIMAGES)

noinst_SCRIPTS = setup${EXEEXT}

install-data-hook: setup${EXEEXT}
	test -z "$(pkglibdir)" || $(mkdir_p) "$(DESTDIR)$(pkglibdir)"
	@list='setup${EXEEXT}'; for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkglibdir)/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkglibdir)/$$f"; \
	done

CLEANFILES = $(BUILT_SOURCES) pkgIndex.tcl setup.kit setup${EXEEXT}

SWIG_FLAGS =  -tcl8 -c++ $(INCLUDES)

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES += $(TCLKIT)

diskfree_wrap.cc : diskfree.i
	$(SWIG) $(SWIG_FLAGS) $(INCLUDES) -o diskfree_wrap.cc \
			$(srcdir)/diskfree.i

pkgIndex.tcl: diskfree.la
	echo 'package ifneeded Diskfree 1.0 [list load [file join $$dir diskfree[info sharedlibextension]] Diskfree]' > pkgIndex.tcl

setup${EXEEXT}: setup.tcl $(setupSCRIPTS) $(setupIMAGES) $(setupLIBIMAGES) \
		pkgIndex.tcl diskfree.la
	-rm -f  setup.kit
	-rm -rf setup.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/setup.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap setup.kit
	-rm -f  setup.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit setup \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit setup \
		lib/Diskfree .libs/diskfree$(SHLIB_SUFFIX) pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit setup \
		lib/Images $(setupIMAGES) $(setupLIBIMAGES)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit setup lib/Common \
		$(setupSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit setup Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap setup${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf setup.vfs




$(top_builddir)/Scripts/Common/Version.tcl : $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl


$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

FORCE:
