TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

EXTRA_DIST = xpressnet.tcl Doxyfile.in  XPressNetThrottle.src \
		XPressNetThrottle.desktop XPressNetThrottle.png

pkgdatadir = $(datadir)/$(PACKAGE)/XPressNet
pkgdata_DATA =  xpressnet.tcl pkgIndex.tcl XPressNetThrottle.pot

BUILT_SOURCES = $(TCLKIT)

bin_SCRIPTS = XPressNetThrottle${EXEEXT}

desktopdir = $(datadir)/applications
desktop_DATA = XPressNetThrottle.desktop

pixmapdir = $(datadir)/pixmaps
pixmap_DATA = XPressNetThrottle.png

man_MANS = man1/XPressNetThrottle.1

XPressNetThrottleSCRIPTS = $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
		$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
		$(top_srcdir)/Scripts/Common/snitCabWidgets.tcl \
		$(top_srcdir)/Scripts/Common/snitLFs.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_srcdir)/Scripts/Common/snitHTMLHelp.tcl \
		$(top_srcdir)/Scripts/Common/mainwindow.tcl \
		$(top_srcdir)/Scripts/Common/splash.tcl \
		$(top_srcdir)/Scripts/Common/snitdialog.tcl \
		$(top_srcdir)/Scripts/Common/snitbuttonbox.tcl \
		$(top_srcdir)/Scripts/Common/IconsAndImages.tcl \
		$(top_srcdir)/Scripts/Common/questhead.xbm \
		$(top_srcdir)/Scripts/Common/snitmainframe.tcl \
		$(top_srcdir)/Scripts/Common/unknown.xpm \
		$(top_srcdir)/Scripts/Common/openfold.png \
		$(top_srcdir)/Scripts/Common/snitscrollw.tcl \
		$(top_srcdir)/Scripts/Common/DynamicHelp.tcl \
		$(top_srcdir)/Scripts/Common/snitpagesmanager.tcl \
		$(top_srcdir)/Scripts/Common/snitrotext.tcl \
		$(top_srcdir)/Scripts/Common/gettext.tcl \
		$(top_builddir)/Scripts/Common/Version.tcl \
		$(top_srcdir)/Scripts/XPressNet/xpressnet.tcl

CLEANFILES = pkgIndex.tcl XPressNetThrottle.pot XPressNetThrottle${EXEEXT} \
		XPressNetThrottle.kit 

pkgIndex.tcl : xpressnet.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)

XPressNetThrottle.pot: XPressNetThrottle.src \
	$(top_srcdir)/Scripts/Common/snitStdMenuBar.tcl \
	$(top_srcdir)/Scripts/Common/snitCabWidgets.tcl \
	$(top_srcdir)/Scripts/XPressNet/xpressnet.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		-k_m -L Tcl $(addprefix $(subdir)/,XPressNetThrottle.src) \
		Scripts/Common/snitStdMenuBar.tcl Scripts/Common/snitCabWidgets.tcl \
		Scripts/XPressNet/xpressnet.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for XPressNetThrottle/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >XPressNetThrottle.pot

XPressNetThrottle${EXEEXT}: XPressNetThrottle.src \
		$(XPressNetThrottleSCRIPTS) \
		$(top_builddir)/Doc/User/XPressNetThrottle/index.html \
		$(top_builddir)/po/XPressNetThrottle/msgfiles
	-rm -f  XPressNetThrottle.kit
	-rm -rf XPressNetThrottle.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/XPressNetThrottle.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap XPressNetThrottle.kit
	-rm -f  XPressNetThrottle.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit XPressNetThrottle \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit XPressNetThrottle \
		lib/Common $(XPressNetThrottleSCRIPTS)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit XPressNetThrottle \
		Common
	$(UNZIP) -qq -d XPressNetThrottle.vfs/lib \
		$(top_srcdir)/BuildData/$(IMG_ZIP)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit XPressNetThrottle \
		Help $(top_builddir)/Doc/User/XPressNetThrottle/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit XPressNetThrottle \
		Messages $(top_builddir)/po/XPressNetThrottle/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap XPressNetThrottle${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf XPressNetThrottle.vfs
if MACOSX
# create application for Mac OSX                                               $
	-rm -rf XPressNetThrottle.app
	mkdir -p XPressNetThrottle.app/Contents/MacOS/
	cp XPressNetThrottle$(EXEEXT) XPressNetThrottle.app/Contents/MacOS/
	mkdir -p XPressNetThrottle.app/Contents/Resources/
	-rm -rf XPressNetThrottle.iconset
	mkdir XPressNetThrottle.iconset
	sips -z 16 16     $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_16x16.png
	sips -z 32 32     $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_16x16@2x.png
	sips -z 32 32     $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_32x32.png
	sips -z 64 64     $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_32x32@2x.png
	sips -z 128 128   $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_128x128.png
	sips -z 256 256   $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_128x128@2x.png
	sips -z 256 256   $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_256x256.png
	sips -z 512 512   $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_256x256@2x.png
	sips -z 512 512   $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_512x512.png
	sips -z 1024 1024 $(srcdir)/XPressNetThrottle.png --out XPressNetThrottle.iconset/icon_512x512@2x.png
	iconutil -c icns XPressNetThrottle.iconset
	-rm -rf XPressNetThrottle.iconset
	cp XPressNetThrottle.icns XPressNetThrottle.app/Contents/Resources/
	$(TCLKIT) $(top_srcdir)/BuildScripts/MacOSXPlist.kit XPressNetThrottle 1.0 "1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software"
	plutil -convert binary1 -o XPressNetThrottle.app/Contents/Info.plist \
		XPressNetThrottle.plist
	-rm -f XPressNetThrottle.plist XPressNetThrottle.icns
	
install-exec-local: XPressNetThrottle.app
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(top_srcdir)/BuildScripts/macappInstall.sh XPressNetThrottle.app $(DESTDIR)$(bindir)

XPressNetThrottle.app: XPressNetThrottle${EXEEXT}

endif


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/XPressNetThrottle/index.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User XPressNetThrottle/index.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/XPressNetThrottle/msgfiles: FORCE
	$(MAKE) -C ../../po/XPressNetThrottle msgfiles

man1/XPressNetThrottle.1 : Doxyfile XPressNetThrottle.src
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1
if MACOSX
	-rm -rf XPressNetThrottle.app
endif

FORCE:


