#* 
#* ------------------------------------------------------------------
#* Makefile.am - Dispatcher w/ Boost makefile
#* Created by Robert Heller on Tue Apr 28 08:33:41 2009
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

DispatcherScripts = NodeGraphCanvas.tcl PrintDialog.tcl TrackGraph.tcl \
		    CTCPanelWindow.tcl WrapIt.tcl

DispatcherImages  = banner.gif search.gif load.gif largePrinter.gif \
		    largeImage.gif

ExampleScripts = example1.tcl example2.tcl example3.tcl example4.tcl \
		 example1.iow example2.iow example3.iow example4.iow

if MACOSX
bin_SCRIPTS = Dispatcher.dmg
else
bin_SCRIPTS = Dispatcher$(EXEEXT)
endif

pkgdataexdir = $(datadir)/$(PACKAGE)/Doc/DispatcherExamples
pkgdataex_DATA = $(ExampleScripts) 
pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = Dispatcher.pot

CLEANFILES  = Dispatcher.kit $(bin_SCRIPTS) Dispatcher.pot

DispatcherLib = DispatcherLib
DispatcherLibFiles = $(DispatcherScripts) $(DispatcherImages)

CommonLib = Common
CommonLibFiles = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
		 $(top_srcdir)/Scripts/Common/new.gif \
		 $(top_srcdir)/Scripts/Common/open.gif \
		 $(top_srcdir)/Scripts/Common/close.gif \
		 $(top_srcdir)/Scripts/Common/save.gif \
		 $(top_srcdir)/Scripts/Common/print.gif \
		 $(top_srcdir)/Scripts/Common/unknown.xpm \
		 $(top_srcdir)/Scripts/Common/openfold.png \
		 $(top_srcdir)/Scripts/Common/palette.png \
		 $(top_srcdir)/Scripts/Common/questhead.xbm \
		 $(top_srcdir)/Scripts/Common/gray50.xbm \
		 $(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		 $(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		 $(top_srcdir)/Scripts/Common/splash.tcl \
		 $(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		 $(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		 $(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		 $(top_srcdir)/Scripts/Common/snitscrollableframe.tcl \
		 $(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
		 $(top_srcdir)/Scripts/Common/snitdialog.tcl \
		 $(top_srcdir)/Scripts/Common/snitLFs.tcl \
		 $(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		 $(top_srcdir)/Scripts/Common/snitrotext.tcl \
		 $(top_srcdir)/Scripts/Common/mainwindow.tcl \
		 $(top_srcdir)/Scripts/Common/snitlistbox.tcl \
		 $(top_builddir)/Scripts/Common/Version.tcl \
		 $(top_srcdir)/Scripts/GRSupport/grsupport2.tcl \
		 $(top_srcdir)/Scripts/Common/CTCPanel2.tcl \
		 $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl \
		 $(top_srcdir)/Scripts/Common/gettext.tcl

CXXSupport = Mrr
CXXSupportFiles =  $(top_builddir)/C++/ParserClasses/.libs/libMRRParserClasses$(SHLIB_SUFFIX) \
		   $(top_builddir)/C++/ParserClasses/pkgIndex.tcl

#CMriSupportFiles =  $(top_builddir)/C++/CMri/.libs/libcmri$(SHLIB_SUFFIX) \
#		    $(top_builddir)/C++/CMri/pkgIndex.tcl
#CMriDependFiles = $(top_builddir)/C++/CMri/libcmri.la \
#		  $(top_builddir)/C++/CMri/pkgIndex.tcl

CMriSupportFiles = $(top_srcdir)/Scripts/CMri/cmri.tcl  \
			$(top_builddir)/Scripts/CMri/pkgIndex.tcl
CMriDependFiles  = $(CMriSupportFiles)

AzatraxSupportFiles =  $(top_builddir)/C++/Azatrax/.libs/libazatrax$(SHLIB_SUFFIX) \
		    $(top_builddir)/C++/Azatrax/pkgIndex.tcl
AzatraxDependFiles = $(top_builddir)/C++/Azatrax/libazatrax.la \
		  $(top_builddir)/C++/Azatrax/pkgIndex.tcl

if HAVE_WIRINGPI
WIRINGPISupportFiles = $(top_builddir)/C++/wiringPi/.libs/libtclwiringpi$(SHLIB_SUFFIX) \
			$(top_builddir)/C++/wiringPi/pkgIndex.tcl
WIRINGPIDependFiles = $(top_builddir)/C++/wiringPi/libtclwiringpi.la \
			$(top_builddir)/C++/wiringPi/pkgIndex.tcl
else
WIRINGPISupportFiles = 
WIRINGPIDependFiles = 
endif

ControlSupportFiles = $(top_srcdir)/Scripts/ControlSupport/*.tcl \
			$(top_builddir)/Scripts/ControlSupport/pkgIndex.tcl
ControlSupportDependFiles  = $(ControlSupportFiles)

CTIAcelaSupportFiles = $(top_srcdir)/Scripts/CTIAcela/*.tcl \
			$(top_builddir)/Scripts/CTIAcela/pkgIndex.tcl

CTIAcelaDependFiles  = $(CTIAcelaSupportFiles)


CodeLibraryFiles = cmriCode.tcl panelCode.tcl userCodeModules.tcl
EXTRA_DIST  = Dispatcher.src $(DispatcherScripts) $(DispatcherImages) \
		$(CodeLibraryFiles) $(ExampleScripts) Dispatcher.png \
		Dispatcher.desktop Doxyfile.in

desktopdir = $(datadir)/applications
desktop_DATA = Dispatcher.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = Dispatcher.png

man_MANS = man1/Dispatcher.1


TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

BUILT_SOURCES = $(TCLKIT)

Dispatcher.pot: Dispatcher.src $(DispatcherScripts) \
			$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl \
		$(addprefix $(subdir)/,Dispatcher.src $(DispatcherScripts)) \
		Scripts/Common/snitStdMenuBar.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for Dispatcher/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >Dispatcher.pot


Dispatcher$(EXEEXT) : Dispatcher.src $(DispatcherLibFiles) $(CommonLibFiles) \
		      $(CodeLibraryFiles) \
		      $(top_builddir)/po/Dispatcher/msgfiles \
		      $(top_builddir)/Doc/User/Dispatcher/index.html \
		      $(CMriDependFiles)  $(AzatraxDependFiles) \
		      $(ControlSupportDependFiles) \
		      $(CTIAcelaDependFiles) $(WIRINGPIDependFiles) \
		      $(top_builddir)/C++/ParserClasses/libMRRParserClasses.la \
		      $(top_builddir)/C++/ParserClasses/pkgIndex.tcl
	-rm -rf Dispatcher.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/Dispatcher.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap  Dispatcher.kit
	-rm -rf Dispatcher.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Dispatcher \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) Dispatcher \
		lib/$(DispatcherLib) $(DispatcherLibFiles) 
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Dispatcher \
		$(DispatcherLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		lib/$(CommonLib) $(CommonLibFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Dispatcher \
		$(CommonLib)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		lib/$(CXXSupport) $(CXXSupportFiles)
	$(UNZIP) -qq -d Dispatcher.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(UNZIP) -qq -d Dispatcher.vfs/lib \
		$(top_srcdir)/BuildData/pdf4tcl05.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		Help $(top_builddir)/Doc/User/Dispatcher/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) Dispatcher \
		CodeLibrary $(CodeLibraryFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/CMri $(CMriSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/CTIAcela $(CTIAcelaSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/Azatrax $(AzatraxSupportFiles)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/ControlSupport $(ControlSupportFiles)
if HAVE_WIRINGPI
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		CodeLibrary/WiringPi $(WIRINGPISupportFiles)
endif
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Dispatcher \
		Messages $(top_builddir)/po/Dispatcher/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap Dispatcher${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf Dispatcher.vfs Dispatcher.kit

if MACOSX 
# create application for Mac OSX                                                
Dispatcher.dmg: Dispatcher$(EXEEXT)
	-rm -rf Dispatcher.app
	mkdir -p Dispatcher.app/Contents/MacOS/
	cp Dispatcher$(EXEEXT) Dispatcher.app/Contents/MacOS/
	mkdir -p Dispatcher.app/Contents/Resources/
	-rm -rf Dispatcher.iconset
	mkdir Dispatcher.iconset
	sips -z 16 16     $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/Dispatcher.png --out Dispatcher.iconset/icon_512x512@2x.png
	iconutil -c icns Dispatcher.iconset
	-rm -rf Dispatcher.iconset
	cp Dispatcher.icns Dispatcher.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit Dispatcher 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o Dispatcher.app/Contents/Info.plist \
		Dispatcher.plist
	-rm -f Dispatcher.plist
	-rm -rf dmg
	mkdir dmg
	cp -r Dispatcher.app dmg
	ln -s /Applications dmg/
	rm -f Dispatcher.dmg
	hdiutil create -srcfolder dmg -format UDZO -volname Dispatcher.dmg Dispatcher.dmg
	-rm -rf dmg

install-exec-local: Dispatcher.dmg
	$(top_srcdir)/BuildScripts/macappInstall.sh Dispatcher.app $(DESTDIR)$(bindir)

endif
	
	
$(top_builddir)/Doc/User/Dispatcher/index.html : FORCE
	$(MAKE) -C $(top_builddir)/Doc/User Dispatcher/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/Dispatcher/msgfiles: FORCE
	$(MAKE) -C ../../po/Dispatcher msgfiles

FORCE:

$(top_builddir)/C++/ParserClasses/pkgIndex.tcl : \
		$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la
	$(MAKE) -C $(top_builddir)/C++/ParserClasses pkgIndex.tcl

$(top_builddir)/C++/ParserClasses/libMRRParserClasses.la : \
	$(top_srcdir)/C++/ParserClasses/*.cc \
	$(top_srcdir)/C++/ParserClasses/*.h \
	$(top_srcdir)/C++/ParserClasses/*.i \
	$(top_srcdir)/C++/ParserClasses/MRRXtrkCad.y
	$(MAKE) -C $(top_builddir)/C++/ParserClasses

$(top_builddir)/C++/Azatrax/libazatrax.la : \
	$(top_srcdir)/C++/Azatrax/*.cc \
	$(top_srcdir)/C++/Azatrax/*.h \
	$(top_srcdir)/C++/Azatrax/*.i
	$(MAKE) -C $(top_builddir)/C++/Azatrax

$(top_builddir)/Scripts/CMri/pkgIndex.tcl : $(top_srcdir)/Scripts/CMri/cmri.tcl
	$(MAKE) -C $(top_builddir)/Scripts/CMri pkgIndex.tcl

$(top_builddir)/Scripts/ControlSupport/pkgIndex.tcl : $(top_srcdir)/Scripts/ControlSupport/*.tcl
	$(MAKE) -C $(top_builddir)/Scripts/ControlSupport pkgIndex.tcl

$(top_builddir)/Scripts/CTIAcela/pkgIndex.tcl : $(top_srcdir)/Scripts/CTIAcela/*.tcl
	$(MAKE) -C $(top_builddir)/Scripts/CTIAcela pkgIndex.tcl

man1/Dispatcher.1 : Doxyfile Dispatcher.src
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

$(top_builddir)/Scripts/Common/Version.tcl: FORCE
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

