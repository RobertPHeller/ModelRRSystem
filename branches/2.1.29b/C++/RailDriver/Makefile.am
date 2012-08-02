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
INCLUDES = -I.

sbin_PROGRAMS = raildriverd
raildriverd_SOURCES = RaildriverIO.h  RaildriverServer.h \
		      RaildriverIO.cc RaildriverServer.cc \
		      raildriverd_main.cc
nodist_raildriverd_SOURCES = raildriver.tab.cc raildriver.tab.h  \
			../gettext.c ../gettext.h
raildriverd_XGETTEXTSOURCES = $(raildriverd_SOURCES)
pkgdatadir = $(datadir)/$(PACKAGE)/RailDriver
pkgdata_SCRIPTS = raildriverd.hotplug print-usb-usermap raildriverd.udev \
			90-raildriver.rules
BUILT_SOURCES       = raildriver.tab.cc raildriver.tab.h
CLEANFILES	    = $(BUILT_SOURCES) LocoTest print-usb-usermap \
			 raildriver.output raildriverd.potlist
noinst_DATA	    = raildriverd.potlist 
bin_SCRIPTS	    = LocoTest
EXTRA_DIST	    = LocoTest.src raildriver.y \
			raildriverd.hotplug.in RailDriverGroup.h \
			print-usb-usermap.src Doxyfile.in raildriverd.udev.in \
			90-raildriver.rules.in

man_MANS = man8/raildriverd.8

DEFS = @DEFS@ 
raildriverd_LDFLAGS = -g $(LIBUSB_LIBS)
raildriverd_CXXFLAGS = -g -Wall $(LIBUSB_CFLAGS)

raildriverd.potlist: $(raildriverd_XGETTEXTSOURCES)
	echo $(addprefix $(subdir)/,$(raildriverd_XGETTEXTSOURCES)) |\
	tr ' ' '\n' > raildriverd.potlist

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

raildriver.tab.h: raildriver.tab.cc
raildriver.tab.cc : raildriver.y
	$(BISONXX) \
		--verbose --defines \
		--output-file=./raildriver.tab.cc -h ./raildriver.tab.h \
		$(srcdir)/raildriver.y

$(top_builddir)/config_tcl.sed: $(top_builddir)/config.status \
				$(top_builddir)/config_tcl.sed.in
	cd $(top_builddir) && CONFIG_FILES=$(@F) CONFIG_HEADERS= $(SHELL) ./config.status


man8/raildriverd.8: Doxyfile raildriverd_main.cc
	-rm -rf man8
	$(DOXYGEN)

clean-local:
	-rm -rf man8

