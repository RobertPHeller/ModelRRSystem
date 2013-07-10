#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file for the Tcl version of the C/MRI code
#* Created by Robert Heller on Mon Apr 23 12:37:41 2012
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
TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

bin_SCRIPTS = UniversalTest${EXEEXT}
pkgdatadir = $(datadir)/$(PACKAGE)/CMri
pkgdata_DATA = UniversalTest.pot cmri.tcl pkgIndex.tcl

desktopdir = $(datadir)/applications
desktop_DATA = UniversalTest.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA =  UniversalTest.png

man_MANS = man1/UniversalTest.1

CLEANFILES = UniversalTest${EXEEXT} pkgIndex.tcl UniversalTest.pot

pkgIndex.tcl : cmri.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)
	

UniversalTestSCRIPTS = $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
                $(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
                $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
                $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/CMri/cmri.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl

EXTRA_DIST = UniversalTest.src cmri.tcl UniversalTest.desktop UniversalTest.png \
	     Doxyfile.in


UniversalTest.pot: UniversalTest.src cmri.tcl \
			$(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl 
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,UniversalTest.src cmri.tcl) \
		Scripts/Common/BWStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for UniversalTest/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >UniversalTest.pot


UniversalTest${EXEEXT}: UniversalTest.src $(UniversalTestSCRIPTS) \
		$(top_builddir)/Doc/User/UniversalTest/UniversalTest.html \
		$(top_builddir)/po/UniversalTest/msgfiles
	-rm -f  UniversalTest.kit
	-rm -rf UniversalTest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/UniversalTest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap UniversalTest.kit
	-rm -f  UniversalTest.kit
	$(UNZIP) -qq -d UniversalTest.vfs/lib \
	        $(top_srcdir)/BuildData/bwidget-1.9.6.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit UniversalTest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		lib/Common $(UniversalTestSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit UniversalTest \
		Common
	$(UNZIP) -qq -d UniversalTest.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		Help $(top_builddir)/Doc/User/UniversalTest/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit UniversalTest \
		Messages $(top_builddir)/po/UniversalTest/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap UniversalTest${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf UniversalTest.vfs
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



