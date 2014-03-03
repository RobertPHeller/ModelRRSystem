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
		$(top_builddir)/Doc/User/XPressNetThrottle/XPressNetThrottle.html \
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


$(top_builddir)/Scripts/Common/Version.tcl: $(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/Scripts/Common Version.tcl

$(top_builddir)/Doc/User/XPressNetThrottle/XPressNetThrottle.html: FORCE
	$(MAKE) -C $(top_builddir)/Doc/User XPressNetThrottle/XPressNetThrottle.html

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/XPressNetThrottle/msgfiles: FORCE
	$(MAKE) -C ../../po/XPressNetThrottle msgfiles

man1/XPressNetThrottle.1 : Doxyfile XPressNetThrottle.src
	-rm -rf man1
	$(DOXYGEN)

clean-local:
	-rm -rf man1

FORCE:


