SUBDIRS = Blocks Switches Signals InterlockingPlants Yards Sidings TimeTables \
	  FreightCarForwarding


EXTRA_DIST = Readme.txt

pkgdatadir = $(datadir)/$(PACKAGE)/ExampleDataAndCode

install-data-hook: $(EXTRA_DIST)
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)
	for p in $^; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done

uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/*; do \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done                                                         
	            
	            
