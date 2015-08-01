##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Jun 11 11:28:01 2015
#  Last Modified : <150801.0826>
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
TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

sbin_SCRIPTS = SatelliteDaemon${EXEEXT}
man_MANS = man8/SatelliteDaemon.8
CLEANFILES          = SatelliteDaemon${EXEEXT} pkgIndex.tcl SatelliteDaemon.pot

EXTRA_DIST          = SatelliteDaemon.src Satellite.tcl
pkgdatadir = $(datadir)/$(PACKAGE)/Satellite
pkgdata_DATA =  Satellite.tcl pkgIndex.tcl SatelliteDaemon.pot

BUILT_SOURCES = $(TCLKIT)                                                       

SatelliteDaemon.pot: SatelliteDaemon.src
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		    -k_m -L Tcl $(addprefix $(subdir)/,SatelliteDaemon.src) |\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for SatelliteDaemon/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >SatelliteDaemon.pot
	    

../../po/Satellite/msgfiles: FORCE
	$(MAKE) -C ../../po/Satellite msgfiles


CMriSupportFiles = $(top_srcdir)/Scripts/CMri/cmri.tcl  \
			$(top_builddir)/Scripts/CMri/pkgIndex.tcl
CMriDependFiles  = $(CMriSupportFiles)

AzatraxSupportFiles =  $(top_builddir)/C++/Azatrax/.libs/libazatrax$(SHLIB_SUFFIX) \
		    $(top_builddir)/C++/Azatrax/pkgIndex.tcl
AzatraxDependFiles = $(top_builddir)/C++/Azatrax/libazatrax.la \
		  $(top_builddir)/C++/Azatrax/pkgIndex.tcl
ControlSupportFiles = $(top_srcdir)/Scripts/ControlSupport/*.tcl \
			$(top_builddir)/Scripts/ControlSupport/pkgIndex.tcl
ControlSupportDependFiles  = $(ControlSupportFiles)

CTIAcelaSupportFiles = $(top_srcdir)/Scripts/CTIAcela/*.tcl \
			$(top_builddir)/Scripts/CTIAcela/pkgIndex.tcl

CTIAcelaDependFiles  = $(CTIAcelaSupportFiles)

if HAVE_WIRINGPI
WIRINGPISupportFiles = $(top_builddir)/C++/wiringPi/.libs/libtclwiringpi$(SHLIB_SUFFIX) \
			$(top_builddir)/C++/wiringPi/pkgIndex.tcl
WIRINGPIDependFiles = $(top_builddir)/C++/wiringPi/libtclwiringpi.la \
			$(top_builddir)/C++/wiringPi/pkgIndex.tcl
else
WIRINGPISupportFiles = 
WIRINGPIDependFiles = 
endif

SigtermDependFiles = $(top_builddir)/C++/RailDriver/libsigterm.la
SigtermSupportFiles = $(top_builddir)/C++/RailDriver/.libs/libsigterm$(SHLIB_SUFFIX)

pkgIndex.tcl : Satellite.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)


SatelliteDaemonSCRIPTS = $(top_srcdir)/Scripts/Common/gettext.tcl \
	$(top_builddir)/Scripts/Common/Version.tcl

SatelliteDaemon${EXEEXT}: SatelliteDaemon.src $(CMriDependFiles)  \
			$(ControlSupportDependFiles) \
			$(CTIAcelaDependFiles) \
			$(AzatraxDependFiles) $(SigtermDependFiles) \
			$(top_builddir)/po/Satellite/msgfiles \
			$(SatelliteDaemonSCRIPTS) $(WIRINGPIDependFiles)
	-rm -f  SatelliteDaemon.kit
	-rm -rf SatelliteDaemon.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/SatelliteDaemon.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap SatelliteDaemon.kit
	-rm -f  SatelliteDaemon.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit SatelliteDaemon \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit SatelliteDaemon \
		lib $(TCLLOGLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/Common $(SatelliteDaemonSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit SatelliteDaemon \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/CMri $(CMriSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/Azatrax $(AzatraxSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/ControlSupport $(ControlSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/CTIAcela $(CTIAcelaSupportFiles)
if HAVE_WIRINGPI
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/WiringPi $(WIRINGPISupportFiles)
endif
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		lib/sigterm $(SigtermSupportFiles)
	echo 'package ifneeded Sigterm 1.0 [list load [file join $$dir libsigterm[info sharedlibextension]]]' > SatelliteDaemon.vfs/lib/sigterm/pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SatelliteDaemon \
		Messages $(top_builddir)/po/Satellite/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap SatelliteDaemon${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf SatelliteDaemon.vfs

man8/SatelliteDaemon.8: Doxyfile SatelliteDaemon.src
	-rm -rf man8
	$(DOXYGEN)

clean-local:
	-rm -rf man8

$(top_builddir)/C++/Azatrax/libazatrax.la : \
	$(top_srcdir)/C++/Azatrax/*.cc \
	$(top_srcdir)/C++/Azatrax/*.h \
	$(top_srcdir)/C++/Azatrax/*.i
	$(MAKE) -C $(top_builddir)/C++/Azatrax

$(top_builddir)/C++/RailDriver/libsigterm.la : \
	$(top_srcdir)/C++/RailDriver/sigterm.i
	$(MAKE) -C $(top_builddir)/C++/RailDriver libsigterm.la

$(top_builddir)/Scripts/CMri/pkgIndex.tcl : $(top_srcdir)/Scripts/CMri/cmri.tcl
	$(MAKE) -C $(top_builddir)/Scripts/CMri pkgIndex.tcl

$(top_builddir)/Scripts/ControlSupport/pkgIndex.tcl : $(top_srcdir)/Scripts/ControlSupport/*.tcl
	$(MAKE) -C $(top_builddir)/Scripts/ControlSupport pkgIndex.tcl



FORCE:
