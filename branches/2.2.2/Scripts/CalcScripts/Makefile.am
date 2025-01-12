#* 
#* ------------------------------------------------------------------
#* Makefile.am - Calculation Scripts
#* Created by Robert Heller on Wed Oct 19 19:22:40 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.2  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:37  heller
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

EXTRA_DIST = Resistor.tcl LocoPull.tcl

bin_SCRIPTS =  Resistor${EXEEXT} LocoPull${EXEEXT}

ResistorSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
                $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
                $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
                $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/snitmainframe.tcl \
                $(top_srcdir)/Scripts/Common/snitscrollw.tcl \
                $(top_srcdir)/Scripts/Common/snitdialog.tcl \
                $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/unknown.xpm \
		$(top_srcdir)/Scripts/Common/questhead.xbm \
		$(top_srcdir)/Scripts/Common/info.xbm
LocoPullSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
                $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
                $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
                $(top_srcdir)/Scripts/Common/snitLFs.tcl \
                $(top_srcdir)/Scripts/Common/snitmainframe.tcl \
                $(top_srcdir)/Scripts/Common/snitscrollw.tcl \
                $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
                $(top_srcdir)/Scripts/Common/snitdialog.tcl \
                $(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/Common/mainwindow.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/unknown.xpm \
		$(top_srcdir)/Scripts/Common/questhead.xbm \
		$(top_srcdir)/Scripts/Common/info.xbm
		
CLEANFILES = Resistor.kit LocoPull.kit $(bin_SCRIPTS) CalcScripts.pot
EXTRA_DIST += Resistor.png Resistor.desktop LocoPull.png LocoPull.desktop 
EXTRA_DIST += Doxyfile.in

desktopdir = $(datadir)/applications
desktop_DATA = Resistor.desktop LocoPull.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA =  Resistor.png LocoPull.png

man_MANS = man1/Resistor.1 man1/LocoPull.1

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = CalcScripts.pot

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

CalcScripts.pot: Resistor.tcl LocoPull.tcl \
	 	 $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl 
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,Resistor.tcl LocoPull.tcl) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for CalcScripts/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >CalcScripts.pot
	

Resistor${EXEEXT}: Resistor.tcl $(ResistorSCRIPTS) \
		$(top_builddir)/Doc/User/Calc/index.html \
		$(top_builddir)/po/CalcScripts/msgfiles
	-rm -rf Resistor.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/Resistor.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap Resistor.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Resistor \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Resistor \
		lib/Common $(ResistorSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Resistor \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Resistor \
		Help $(top_builddir)/Doc/User/Calc/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Resistor \
		Messages $(top_builddir)/po/CalcScripts/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap Resistor${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf Resistor.vfs Resistor.kit
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf Resistor.app
	mkdir -p Resistor.app/Contents/MacOS/
	cp Resistor$(EXEEXT) Resistor.app/Contents/MacOS/
	mkdir -p Resistor.app/Contents/Resources/
	-rm -rf Resistor.iconset
	mkdir Resistor.iconset
	sips -z 16 16     $(srcdir)/Resistor.png --out Resistor.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/Resistor.png --out Resistor.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/Resistor.png --out Resistor.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/Resistor.png --out Resistor.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/Resistor.png --out Resistor.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/Resistor.png --out Resistor.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/Resistor.png --out Resistor.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/Resistor.png --out Resistor.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/Resistor.png --out Resistor.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/Resistor.png --out Resistor.iconset/icon_512x512@2x.png
	iconutil -c icns Resistor.iconset
	-rm -rf Resistor.iconset
	cp Resistor.icns Resistor.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit Resistor 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o Resistor.app/Contents/Info.plist \
		Resistor.plist
	-rm -f Resistor.plist Resistor.icns
endif


LocoPull${EXEEXT}: LocoPull.tcl $(LocoPullSCRIPTS) \
		$(top_builddir)/Doc/User/Calc/index.html \
		$(top_builddir)/po/CalcScripts/msgfiles
	-rm -rf LocoPull.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/LocoPull.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap LocoPull.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit LocoPull \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit LocoPull \
		lib/Common $(LocoPullSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit LocoPull \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit LocoPull \
		Help $(top_builddir)/Doc/User/Calc/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit LocoPull \
		Messages $(top_builddir)/po/CalcScripts/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap LocoPull${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf LocoPull.vfs LocoPull.kit
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf LocoPull.app
	mkdir -p LocoPull.app/Contents/MacOS/
	cp LocoPull$(EXEEXT) LocoPull.app/Contents/MacOS/
	mkdir -p LocoPull.app/Contents/Resources/
	-rm -rf LocoPull.iconset
	mkdir LocoPull.iconset
	sips -z 16 16     $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/LocoPull.png --out LocoPull.iconset/icon_512x512@2x.png
	iconutil -c icns LocoPull.iconset
	-rm -rf LocoPull.iconset
	cp LocoPull.icns LocoPull.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit LocoPull 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o LocoPull.app/Contents/Info.plist \
		LocoPull.plist
	-rm -f LocoPull.plist LocoPull.icns
endif

if MACOSX
install-exec-local: Resistor.app LocoPull.app
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh Resistor.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh LocoPull.app $(DESTDIR)$(bindir)

Resistor.app: Resistor${EXEEXT}

LocoPull.app: LocoPull${EXEEXT}

endif

$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/Calc/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User Calc/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/CalcScripts/msgfiles: FORCE
	$(MAKE) -C ../../po/CalcScripts msgfiles

FORCE:

man1/Resistor.1 : Doxyfile Resistor.tcl
	-rm -rf man1
	$(DOXYGEN)

man1/LocoPull.1 : Doxyfile LocoPull.tcl
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1
if MACOSX
	-rm -rf Resistor.app LocoPull.app
endif

noinst_DATA = BUNDLE.DAT

BUNDLE.DAT: $(bin_SCRIPTS) $(man_MANS)
	-rm -f BUNDLE.DAT
	touch BUNDLE.DAT
	for b in $(bin_SCRIPTS); do \
	   echo "bin/$$b" >> BUNDLE.DAT; \
	done
	for b in $(pkgdata_DATA); do \
	   echo "share/$(PACKAGE)/$$b" >> BUNDLE.DAT; \
	done
	for b in $(desktop_DATA); do \
	   echo "share/applications/$$b" >> BUNDLE.DAT; \
	done
	for b in $(pixmap_DATA); do \
	    echo "share/pixmaps/$$b" >> BUNDLE.DAT; \
	done
	for b in $(man_MANS); do \
	    echo "share/man/$$b" >> BUNDLE.DAT; \
	done
