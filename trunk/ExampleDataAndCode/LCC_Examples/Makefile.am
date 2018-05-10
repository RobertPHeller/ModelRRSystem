SUBDIRS = 
CODEFILES = CrossingInterchangeExample.h
FIGURES = CrossingInterchange_CP1Signals.png CrossingInterchange.png \
	  CrossingInterchange_CP2Signals.png \
	  CrossingInterchange_SMCSenseHAT.png \
	  CrossingInterchange_CP3Signals.png \
	  CrossingInterchange_OccupencyHAT.jpg \
	  CrossingInterchange_Small.png \
	  CrossingInterchange_CP1Signals_Small.png \
	  CrossingInterchange_CP2Signals_Small.png \
	  CrossingInterchange_CP3Signals_Small.png \
	  CrossingInterchange_SMCSenseHAT_Small.png \
	  CrossingInterchange_OccupencyHAT_Small.jpg
OTHERFILES = CrossingInterchange.pdf QuadSignalDriverCA.pdf SMCSenseHAT.pdf \
	BlockCSV2PiGPIO.tcl CrossingInterchange.tcl LoadSignalMatrix.tcl \
	CrossingInterchange_CP1Signals.xml CrossingInterchange_CP2Signals.xml \
	CrossingInterchange_CP3Signals.xml \
	CrossingInterchange_PiGPIO_Turnouts_Occupency.xml \
	CrossingInterchangeBlocks.csv  CrossingInterchangeSignals.csv \
	CrossingInterchange.csv        CrossingInterchangeSwitchMotors.csv \
	CrossingInterchange.xtc
EXTRA_DIST = $(OTHERFILES) $(CODEFILES) $(FIGURES) Doxyfile.in main.h 
pkgdatadir = $(datadir)/$(PACKAGE)/ExampleDataAndCode/LCC_Examples
noinst_DATA = html/index.html
pkgdata_DATA =  $(OTHERFILES) latex/refman.pdf# pkgIndex.tcl

CLEANFILES= *.tag navheader.html

html/index.html latex/refman.pdf : Doxyfile main.h $(CODEFILES) $(FIGURES) \
	$(top_builddir)/Doc/doxygen/tcldoxyfilter.sh
	-rm -rf latex/ html/
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
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done                                                         
