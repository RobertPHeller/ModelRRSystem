#* 
#* ------------------------------------------------------------------
#* Makefile.am - Automake file for Camera Scripts
#* Created by Robert Heller on Fri Nov  4 13:25:53 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.4  2007/02/02 01:04:02  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.2  2006/08/04 01:59:26  heller
#* Modification History: Aug 3 Lockdown
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

bin_SCRIPTS = AnyDistance${EXEEXT} Closest${EXEEXT}

EXTRA_DIST  = AnyDistance.src Closest.src
CLEANFILES = AnyDistance.kit Closest.kit $(bin_SCRIPTS) CameraScripts.pot
CameraSCRIPTS = $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
			$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
			$(top_builddir)/Scripts/Common/Version.tcl \
			$(top_srcdir)/Scripts/Common/gettext.tcl \
			$(top_srcdir)/Scripts/Common/snitLFs.tcl \
			$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
			$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
			$(top_srcdir)/Scripts/Common/snitdialog.tcl \
			$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
			$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
			$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
			$(top_srcdir)/Scripts/Common/questhead.xbm \
			$(top_srcdir)/Scripts/Common/unknown.xpm \
			$(top_srcdir)/Scripts/Common/info.xbm \
		Lens.tcl CameraCalculator.tcl CameraPrintDialog.tcl
EXTRA_DIST += Lens.tcl CameraCalculator.tcl CameraPrintDialog.tcl
EXTRA_DIST += AnyDistance.png Closest.png AnyDistance.desktop Closest.desktop
EXTRA_DIST += Doxyfile.in

desktopdir = $(datadir)/applications
desktop_DATA = AnyDistance.desktop Closest.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA =  AnyDistance.png Closest.png

pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = CameraScripts.pot

man_MANS = man1/AnyDistance.1 man1/Closest.1

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

CameraScripts.pot: Lens.tcl CameraCalculator.tcl CameraPrintDialog.tcl \
			$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,Lens.tcl CameraCalculator.tcl CameraPrintDialog.tcl) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for CameraScripts/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >CameraScripts.pot

AnyDistance${EXEEXT} : AnyDistance.src $(CameraSCRIPTS) \
		     $(top_builddir)/po/CameraScripts/msgfiles \
		     $(top_builddir)/Doc/User/Camera/index.html
	-rm -rf AnyDistance.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap  $(srcdir)/AnyDistance.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  AnyDistance.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit AnyDistance \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) AnyDistance \
		lib/Common $(CameraSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit AnyDistance \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit AnyDistance \
		Help $(top_builddir)/Doc/User/Camera/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit AnyDistance \
		Messages $(top_builddir)/po/CameraScripts/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap AnyDistance${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf AnyDistance.vfs AnyDistance.kit
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf AnyDistance.app
	mkdir -p AnyDistance.app/Contents/MacOS/
	cp AnyDistance$(EXEEXT) AnyDistance.app/Contents/MacOS/
	mkdir -p AnyDistance.app/Contents/Resources/
	-rm -rf AnyDistance.iconset
	mkdir AnyDistance.iconset
	sips -z 16 16     $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/AnyDistance.png --out AnyDistance.iconset/icon_512x512@2x.png
	iconutil -c icns AnyDistance.iconset
	-rm -rf AnyDistance.iconset
	cp AnyDistance.icns AnyDistance.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit AnyDistance 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o AnyDistance.app/Contents/Info.plist \
		AnyDistance.plist
	-rm -f AnyDistance.plist AnyDistance.icns
endif


Closest${EXEEXT} : Closest.src $(CameraSCRIPTS) \
		     $(top_builddir)/po/CameraScripts/msgfiles \
		     $(top_builddir)/Doc/User/Camera/index.html
	-rm -rf Closest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap  $(srcdir)/Closest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  Closest.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Closest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) Closest \
		lib/Common $(CameraSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Closest \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Closest \
		Help $(top_builddir)/Doc/User/Camera/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Closest \
		Messages $(top_builddir)/po/CameraScripts/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap Closest${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf Closest.vfs Closest.kit
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf Closest.app
	mkdir -p Closest.app/Contents/MacOS/
	cp Closest$(EXEEXT) Closest.app/Contents/MacOS/
	mkdir -p Closest.app/Contents/Resources/
	-rm -rf Closest.iconset
	mkdir Closest.iconset
	sips -z 16 16     $(srcdir)/Closest.png --out Closest.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/Closest.png --out Closest.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/Closest.png --out Closest.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/Closest.png --out Closest.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/Closest.png --out Closest.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/Closest.png --out Closest.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/Closest.png --out Closest.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/Closest.png --out Closest.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/Closest.png --out Closest.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/Closest.png --out Closest.iconset/icon_512x512@2x.png
	iconutil -c icns Closest.iconset
	-rm -rf Closest.iconset
	cp Closest.icns Closest.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit Closest 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o Closest.app/Contents/Info.plist \
		Closest.plist
	-rm -f Closest.plist Closest.icns
endif

if MACOSX
install-exec-local: AnyDistance.app Closest.app
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh AnyDistance.app $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh Closest.app $(DESTDIR)$(bindir)

AnyDistance.app: AnyDistance${EXEEXT}

Closest.app: Closest${EXEEXT}

endif


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/Camera/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User Camera/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/CameraScripts/msgfiles: FORCE
	$(MAKE) -C ../../po/CameraScripts msgfiles

FORCE:

man1/AnyDistance.1 : Doxyfile AnyDistance.src
	-rm -rf man1
	$(DOXYGEN)
	

man1/Closest.1 : man1/AnyDistance.1
	echo ".so man1/AnyDistance.1" > @builddir@/man1/Closest.1


clean-local:
	-rm -rf man1
if MACOSX
	-rm -rf AnyDistance.app Closest.app
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
