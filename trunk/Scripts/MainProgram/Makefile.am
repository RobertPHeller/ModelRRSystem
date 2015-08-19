#* 
#* ------------------------------------------------------------------
#* Makefile.am - Main Program Script
#* Created by Robert Heller on Wed Oct 19 19:24:44 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2005/11/04 19:06:38  heller
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

MainProgramScripts = IconFrame.tcl
MainProgramImages  = AnyDistance.xbm banner.gif Closest.xbm \
		     DeepwoodsBanner.gif dot.xbm menu.xbm resistor.xbm \
		     TimeTable.xbm xtc64.xbm Dispatcher.xbm FCF.xbm \
		     FCFCre.xbm

if MACOSX                                                                       
bin_SCRIPTS = ModelRRSystem.dmg                                                 
else
bin_SCRIPTS = ModelRRSystem$(EXEEXT)
endif

CLEANFILES = ModelRRSystem.kit $(bin_SCRIPTS)

EXTRA_DIST  = ModelRRSystem.src $(MainProgramScripts) $(MainProgramImages)

ModelRRSystemLib = ModelRRSystemLib
ModelRRSystemLibFiles = $(MainProgramScripts) $(MainProgramImages)

CommonLib = Common
CommonLibFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
		 $(top_srcdir)/Scripts/Common/new.gif \
		 $(top_srcdir)/Scripts/Common/open.gif \
		 $(top_srcdir)/Scripts/Common/close.gif \
		 $(top_srcdir)/Scripts/Common/save.gif \
		 $(top_srcdir)/Scripts/Common/print.gif \
		 $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		 $(top_srcdir)/Scripts/Common/snitdialog.tcl \
		 $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
		 $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		 $(top_srcdir)/Scripts/Common/questhead.xbm \
		 $(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		 $(top_srcdir)/Scripts/Common/unknown.xpm \
		 $(top_srcdir)/Scripts/Common/openfold.png \
		 $(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		 $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		 $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		 $(top_srcdir)/Scripts/Common/snitLFs.tcl \
		 $(top_srcdir)/Scripts/Common/gettext.tcl \
		 $(top_srcdir)/Scripts/Common/splash.tcl \
		 $(top_srcdir)/Scripts/Common/mainwindow.tcl \
		 $(top_builddir)/Scripts/Common/Version.tcl

CXXSupport = Mrr
CXXSupportFiles =  $(top_builddir)/C++/ParserClasses/.libs/libMRRParserClasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/ParserClasses/pkgIndex.tcl


#		      $(top_srcdir)/Help/ModelRRSystem/*.gif 

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

ModelRRSystem$(EXEEXT) : ModelRRSystem.src $(ModelRRSystemLibFiles) $(CommonLibFiles) \
		      $(top_builddir)/Doc/User/MainProgram/index.html \
		      $(top_builddir)/C++/ParserClasses/libMRRParserClasses.la \
		      $(top_builddir)/C++/ParserClasses/pkgIndex.tcl
	-rm -rf ModelRRSystem.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/ModelRRSystem.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  ModelRRSystem.kit
	-rm -rf ModelRRSystem.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit ModelRRSystem \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) ModelRRSystem \
		lib/$(ModelRRSystemLib) $(ModelRRSystemLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit ModelRRSystem \
		$(ModelRRSystemLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit ModelRRSystem \
		lib/$(CommonLib) $(CommonLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit ModelRRSystem \
		$(CommonLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit ModelRRSystem \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(UNZIP) -qq -d ModelRRSystem.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit ModelRRSystem \
		Help $(top_builddir)/Doc/User/MainProgram/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap ModelRRSystem${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf ModelRRSystem.vfs ModelRRSystem.kit

if MACOSX
# create application for Mac OSX                                               $
ModelRRSystem.dmg: ModelRRSystem$(EXEEXT)
	-rm -rf ModelRRSystem.app
	mkdir -p ModelRRSystem.app/Contents/MacOS/
	cp ModelRRSystem$(EXEEXT) ModelRRSystem.app/Contents/MacOS/
	mkdir -p ModelRRSystem.app/Contents/Resources/
#	-rm -rf ModelRRSystem.iconset
#	mkdir ModelRRSystem.iconset
#	sips -z 16 16     $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_16x16.png
#	sips -z 32 32     $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_16x16@2x.png
#	sips -z 32 32     $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_32x32.png
#	sips -z 64 64     $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_32x32@2x.png
#	sips -z 128 128   $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_128x128.png
#	sips -z 256 256   $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_128x128@2x.png
#	sips -z 256 256   $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_256x256.png
#	sips -z 512 512   $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_256x256@2x.png
#	sips -z 512 512   $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_512x512.png
#	sips -z 1024 1024 $(srcdir)/ModelRRSystem.png --out ModelRRSystem.iconset/icon_512x512@2x.png
#	iconutil -c icns ModelRRSystem.iconset
#	-rm -rf ModelRRSystem.iconset
#	cp ModelRRSystem.icns ModelRRSystem.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit ModelRRSystem 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o ModelRRSystem.app/Contents/Info.plist \
		ModelRRSystem.plist
	-rm -f ModelRRSystem.plist
	-rm -rf dmg
	mkdir dmg
	cp -r ModelRRSystem.app dmg
	ln -s /Applications dmg/
	rm -f ModelRRSystem.dmg
	hdiutil create -srcfolder dmg -format UDZO -volname ModelRRSystem.dmg ModelRRSystem.dmg
	-rm -rf dmg

install-exec-local: ModelRRSystem.dmg
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh ModelRRSystem.app $(DESTDIR)$(bindir)

endif


$(top_builddir)/Doc/User/MainProgram/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User MainProgram/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

FORCE:

$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la : \
		$(top_srcdir)/C++/ParserClasses/*.cc \
		$(top_srcdir)/C++/ParserClasses/*.h \
		$(top_srcdir)/C++/ParserClasses/*.i \
		$(top_srcdir)/C++/ParserClasses/MRRXtrkCad.y
	$(MAKE) -C $(top_builddir)/C++/ParserClasses

$(top_builddir)/C++/ParserClasses/pkgIndex.tcl : \
		$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la
	$(MAKE) -C $(top_builddir)/C++/ParserClasses pkgIndex.tcl


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl
