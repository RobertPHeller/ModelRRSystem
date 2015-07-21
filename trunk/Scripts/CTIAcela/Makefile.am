TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

EXTRA_DIST = CTIAcela.tcl

pkgdatadir = $(datadir)/$(PACKAGE)/CTIAcela
pkgdata_DATA = CTIAcela.tcl pkgIndex.tcl

CLEANFILES = pkgIndex.tcl

pkgIndex.tcl : CTIAcela.tcl
	for f in $(notdir $^) ; do \
	   if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)
	

