##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Oct 13 21:26:48 2018
#  Last Modified : <220812.1440>
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
#    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
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


LinuxGpioScripts = LinuxGpio.tcl pkgIndex.tcl
bin_Scripts = TestGPIOOutput${EXEEXT} TestGPIOInput${EXEEXT}

CLEANFILES = TestGPIOOutput.kit TestGPIOInput.kit $(bin_Scripts) \
	LinuxGpio.pot
EXTRA_DIST = $(LinuxGpioScripts) TestGPIOOutput.tcl TestGPIOInput.tcl \
	Doxyfile.in

man_MANS = man1/TestGPIOOutput.1 man1/TestGPIOInput.1

pkgdatadir = $(datadir)/$(PACKAGE)/LinuxGpio
pkgdata_DATA = $(LinuxGpioScripts)

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

LinuxGpio.pot: TestGPIOOutput.tcl TestGPIOInput.tcl LinuxGpio.tcl \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl 
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,TestGPIOOutput.tcl TestGPIOInput.tcl LinuxGpio.tcl) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for LinuxGpio/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >LinuxGpio.pot

	                                  
TestGPIO_IOScripts = LinuxGpio.tcl \
	$(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
	$(top_srcdir)/Scripts/Common/new.gif \
	$(top_srcdir)/Scripts/Common/open.gif \
	$(top_srcdir)/Scripts/Common/close.gif \
	$(top_srcdir)/Scripts/Common/save.gif \
	$(top_srcdir)/Scripts/Common/print.gif \
	$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
	$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
	$(top_srcdir)/Scripts/Common/splash.tcl \
	$(top_srcdir)/Scripts/Common/mainwindow.tcl \
	$(top_srcdir)/Scripts/Common/snitLFs.tcl \
	$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
	$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
	$(top_srcdir)/Scripts/Common/snitdialog.tcl \
	$(top_srcdir)/Scripts/Common/snitlistbox.tcl \
	$(top_srcdir)/Scripts/Common/snitrotext.tcl \
	$(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
	$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
	$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
	$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
	$(top_srcdir)/Scripts/Common/gettext.tcl \
	$(top_builddir)/Scripts/Common/Version.tcl \
	$(top_srcdir)/Scripts/Common/gray50.xbm \
	$(top_srcdir)/Scripts/Common/info.xbm \
	$(top_srcdir)/Scripts/Common/questhead.xbm \
	$(top_srcdir)/Scripts/Common/openfold.png \
	$(top_srcdir)/Scripts/Common/palette.png \
	$(top_srcdir)/Scripts/Common/unknown.xpm

TestGPIOOutput${EXEEXT}: TestGPIOOutput.tcl $(TestGPIO_IOScripts) \
		$(top_builddir)/Doc/User/LinuxGpio/index.html \
		$(top_builddir)/po/LinuxGpio/msgfiles
	-rm -rf TestGPIOOutput.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/TestGPIOOutput.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap TestGPIOOutput.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit TestGPIOOutput \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) TestGPIOOutput \
		lib/Common $(TestGPIO_IOScripts)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TestGPIOOutput \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TestGPIOOutput \
		Help $(top_builddir)/Doc/User/LinuxGpio/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TestGPIOOutput \
		Messages $(top_builddir)/po/LinuxGpio/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap TestGPIOOutput${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf TestGPIOOutput.vfs TestGPIOOutput.kit
	
TestGPIOInput${EXEEXT}: TestGPIOInput.tcl $(TestGPIO_IOScripts) \
		$(top_builddir)/Doc/User/LinuxGpio/index.html \
		$(top_builddir)/po/LinuxGpio/msgfiles
	-rm -rf TestGPIOInput.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/TestGPIOInput.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap TestGPIOInput.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit TestGPIOInput \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) TestGPIOInput \
		lib/Common $(TestGPIO_IOScripts)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit TestGPIOInput \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TestGPIOInput \
		Help $(top_builddir)/Doc/User/LinuxGpio/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit TestGPIOInput \
		Messages $(top_builddir)/po/LinuxGpio/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap TestGPIOInput${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf TestGPIOInput.vfs TestGPIOInput.kit
	

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/LinuxGpio/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User LinuxGpio/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/LinuxGpio/msgfiles: FORCE
	$(MAKE) -C ../../po/LinuxGpio msgfiles

FORCE:

man1/TestGPIOOutput.1 : Doxyfile TestGPIOOutput.tcl
	-rm -rf man1
	$(DOXYGEN)

man1/TestGPIOInput.1 : Doxyfile TestGPIOInput.tcl
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

