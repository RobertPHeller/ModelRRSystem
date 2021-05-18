TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

EXTRA_DIST = raildriver_client.tcl xplocotest.src Doxyfile.in

pkgdatadir = $(datadir)/$(PACKAGE)/RailDriverSupport
pkgdata_DATA = raildriver_client.tcl pkgIndex.tcl

CLEANFILES = pkgIndex.tcl xplocotest${BEXEEXT} xplocotest.kit xplocotest.pot

man_MANS = man1/xplocotest.1

pkgIndex.tcl : raildriver_client.tcl
	for f in $(notdir $^) ; do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)

bin_SCRIPTS = xplocotest${BEXEEXT}

xplocotestScripts = $(top_srcdir)/Scripts/Common/gettext.tcl \
	    $(top_srcdir)/Scripts/RailDriverSupport/raildriver_client.tcl \
	    $(top_srcdir)/Scripts/XPressNet/xpressnet.tcl

xplocotest.pot: xplocotest.src \
	$(top_srcdir)/Scripts/RailDriverSupport/raildriver_client.tcl \
	$(top_srcdir)/Scripts/XPressNet/xpressnet.tcl
	$(XGETTEXT) -D $(top_srcdir) --force-po -o - -n -k_ -k_n:1,2 \
		 -k_m -L Tcl $(addprefix $(subdir)/,xplocotest.src raildriver_client.tcl) \
		Scripts/XPressNet/xpressnet.tcl|\
	sed -e 's/PACKAGE/@PACKAGE@/g' -e 's/VERSION/@VERSION@/g' \
	    -e "s/THE @PACKAGE@'S COPYRIGHT HOLDER/Robert Heller/g" \
	    -e 's/FIRST AUTHOR <EMAIL@ADDRESS>,/Robert Heller <heller@deepsoft.com>/g' \
	    -e 's/SOME DESCRIPTIVE TITLE/Messages for xplocotest/g' \
	    -e "s/YEAR/`date +%Y`/g" \
	    -e 's/CHARSET/ascii/g' >xplocotest.pot

xplocotest${BEXEEXT}: xplocotest.src $(xplocotestScripts) \
		$(top_builddir)/po/xplocotest/msgfiles
	-rm -f  xplocotest.kit
	-rm -rf xplocotest.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/xplocotest.src
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap xplocotest.kit
	-rm -f  xplocotest.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit xplocotest \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit xplocotest \
		lib/Common $(xplocotestScripts)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit xplocotest \
		Common
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit xplocotest \
		Messages $(top_builddir)/po/xplocotest/*.msg
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap xplocotest${BEXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf xplocotest.vfs


$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

../../po/xplocotest/msgfiles: FORCE
	$(MAKE) -C ../../po/xplocotest msgfiles

FORCE:

man1/xplocotest.1 : Doxyfile xplocotest.src
	-rm -rf man1
	$(DOXYGEN)


clean-local:
	-rm -rf man1




noinst_DATA = BUNDLE.DAT

BUNDLE.DAT: $(bin_SCRIPTS) $(man_MANS) $(pkgdata_DATA)
	-rm -f BUNDLE.DAT
	touch BUNDLE.DAT
	for b in $(bin_SCRIPTS); do \
	  echo "bin/$$b" >> BUNDLE.DAT; \
	done
	for b in $(pkgdata_DATA); do \
	  echo "share/$(PACKAGE)/RailDriverSupport/$$b >> BUNDLE.DAT; \
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

