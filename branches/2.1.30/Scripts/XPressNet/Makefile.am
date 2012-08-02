TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

EXTRA_DIST = xpressnet.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/XPressNet
pkgdata_DATA =  xpressnet.tcl pkgIndex.tcl

CLEANFILES = pkgIndex.tcl

pkgIndex.tcl : xpressnet.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)

