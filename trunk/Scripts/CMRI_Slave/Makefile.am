##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue May 16 11:38:07 2017
#  Last Modified : <210517.1207>
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


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

bin_SCRIPTS = CMRI_Slave${EXEEXT}

pkgdatadir = $(datadir)/$(PACKAGE)/CMRI_Slave
pkgdata_DATA = CMRI_Slave.pot

man_MANS = man1/CMRI_Slave.1

CLEANFILES = CMRI_Slave${EXEEXT} CMRI_Slave.pot

EXTRA_DIST = CMRI_Slave.tcl Doxyfile.in

CMRI_Slave.pot: CMRI_Slave.tcl \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m \
		-L Tcl $(addprefix $(subdir)/,CMRI_Slave.tcl) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for CMRI_Slave/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >CMRI_Slave.pot

WiringPiSupportFiles =  $(top_builddir)/C++/wiringPi/.libs/libtclwiringpi$(SHLIB_SUFFIX) \
			$(top_builddir)/C++/wiringPi/pkgIndex.tcl
WiringPiDependFiles = $(top_builddir)/C++/wiringPi/libtclwiringpi.la \
			$(top_builddir)/C++/wiringPi/pkgIndex.tcl

CMRI_SlaveSCRIPTS = $(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl \
			$(top_srcdir)/Scripts/Common/ParseXML.tcl \
			$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
	                $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
	                $(top_srcdir)/Scripts/Common/snitdialog.tcl \
	                $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
	                $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
			$(top_srcdir)/Scripts/Common/mainwindow.tcl \
			$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
			$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
			$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
	                $(top_srcdir)/Scripts/Common/snitLFs.tcl \
	                $(top_srcdir)/Scripts/Common/snitrotext.tcl \
	                $(top_srcdir)/Scripts/Common/snitScrollNotebook.tcl \
			$(top_srcdir)/Scripts/Common/questhead.xbm \
			$(top_srcdir)/Scripts/Common/unknown.xpm

CMRI_Slave${EXEEXT}: CMRI_Slave.tcl $(CMRI_SlaveSCRIPTS) \
	$(WiringPiDependFiles) $(top_builddir)/po/CMRI_Slave/msgfiles \
	$(top_builddir)/Doc/User/CMRI_Slave/index.html
	-rm -f  CMRI_Slave.kit
	-rm -rf CMRI_Slave.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/CMRI_Slave.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap CMRI_Slave.kit
	-rm -f  CMRI_Slave.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit CMRI_Slave \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit CMRI_Slave \
		lib $(TCLLOGLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit CMRI_Slave \
		lib $(URILIB)
	$(UNZIP) -qq -d CMRI_Slave.vfs/lib \
		$(top_srcdir)/BuildData/Tclxml3.1-GenericPureTcl.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit CMRI_Slave \
		lib/Common $(CMRI_SlaveSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit CMRI_Slave \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit CMRI_Slave \
		lib/WiringPi $(WiringPiSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit CMRI_Slave \
		Help $(top_builddir)/Doc/User/CMRI_Slave/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit CMRI_Slave \
		Messages $(top_builddir)/po/CMRI_Slave/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap CMRI_Slave${EXEEXT}  -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf CMRI_Slave.vfs
	

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

$(top_builddir)/C++/wiringPi/libtclwiringpi.la : \
	$(top_srcdir)/C++/wiringPi/*.i
	$(MAKE) -C $(top_builddir)/C++/wiringPi

$(top_builddir)/Doc/User/CMRI_Slave/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User CMRI_Slave/index.html

../../po/CMRI_Slave/msgfiles: FORCE
	$(MAKE) -C ../../po/CMRI_Slave msgfiles

FORCE:


man1/CMRI_Slave.1 : Doxyfile CMRI_Slave.tcl
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1



