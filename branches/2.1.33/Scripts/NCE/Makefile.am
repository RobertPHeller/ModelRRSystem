TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

EXTRA_DIST = nce.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/NCE
pkgdata_DATA = nce.tcl pkgIndex.tcl

CLEANFILES = pkgIndex.tcl

pkgIndex.tcl : nce.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)

