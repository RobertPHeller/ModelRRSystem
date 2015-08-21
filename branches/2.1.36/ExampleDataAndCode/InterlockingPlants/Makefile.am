SUBDIRS = 
CODEFILES =
FIGURES = 
OTHERFILES =
EXTRA_DIST = $(OTHERFILES) $(CODEFILES) $(FIGURES) Doxyfile.in main.h 
pkgdatadir = $(datadir)/$(PACKAGE)/ExampleDataAndCode/InterlockingPlants

noinst_DATA = html/index.html
pkgdata_DATA =  latex/refman.pdf

html/index.html latex/refman.pdf : Doxyfile main.h $(CODEFILES) \
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
	  echo " rm -rf '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  rm -rf "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done                                                         
