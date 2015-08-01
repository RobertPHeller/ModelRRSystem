SUBDIRS = 
CODEFILES = MRD2_Block.tcl C4TSR4_Block.tcl C4TSMINI_Block.tcl C4TTB_Block.tcl
FIGURES = 4circleblocks.png  EditingBlock1.png \
		MRD2_Block-thumb.png MRD2_Block.png \
		C4TSR4_Block-thumb.png C4TSR4_Block.png \
		C4TSMINI_Block.png C4TSMINI_Block-thumb.png \
		C4TTB_Block-thumb.png C4TTB_Block.png
OTHERFILES = ODtoSR4-UALL.png ODtoSR4-UComponent.png ODtoSR4-UGND.png \
	     ODtoSR4-U.partsList ODtoSR4-U.pcb ODtoSR4-U.pdf \
	     ODtoSR4-UPower.png ODtoSR4-U.ps MRD2_Block.xtc C4TSR4_Block.xtc \
	     C4TSMINI_Block.xtc C4TTB_Block.xtc
EXTRA_DIST = $(OTHERFILES) $(CODEFILES) $(FIGURES) Doxyfile.in main.h navbar.html

pkgdatadir = $(datadir)/$(PACKAGE)/ExampleDataAndCode/Blocks

noinst_DATA = html/index.html
pkgdata_DATA =  latex/refman.pdf pkgIndex.tcl

CLEANFILES = pkgIndex.tcl
TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

html/index.html latex/refman.pdf : Doxyfile main.h $(CODEFILES) \
	$(top_builddir)/Doc/doxygen/tcldoxyfilter.sh navbar.html
	-rm -rf latex/ html/
	$(DOXYGEN) -w html header0.html /dev/null doxygen.css  Doxyfile
	rm doxygen.css
	cat header0.html $(srcdir)/navbar.html > navheader.html
	rm header0.html
	-chmod +x $(top_builddir)/Doc/doxygen/tcldoxyfilter.sh
	$(DOXYGEN) Doxyfile
	for p in $(FIGURES); do \
	  if test ! \( -f html/$$p \); then cp $(srcdir)/$$p html/; fi; \
	done
	$(MAKE) -C latex pdf
	

$(top_builddir)/Doc/doxygen/tcldoxyfilter.sh : $(top_builddir)/Doc/doxygen/tcldoxyfilter.sh.in
	$(MAKE) -C $(top_builddir)/Doc/doxygen tcldoxyfilter.sh

clean-local:
	-rm -rf latex/ html/

install-data-hook: $(CODEFILES) $(OTHERFILES) html/index.html
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)
	for p in $(CODEFILES) $(OTHERFILES); do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$(USERMANHBase)$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done
	
uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/*; do \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " rm -rf '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  rm -rf "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done                                                         

pkgIndex.tcl : $(CODEFILES)
	for f in $(notdir $^) ; do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)
