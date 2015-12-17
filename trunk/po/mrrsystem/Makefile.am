ALWAYSCCPOTFILES = ../../C++/TTSupport/TTClasses.potlist \
		   ../../C++/FCFSupport/FCFClasses.potlist \
		   ../../C++/Azatrax/azatrax.potlist \
                   ../../C++/RailDriver/raildriverio.potlist

if DONT_HAVE_BISONXX
PARSERPOT =
else
PARSERPOT = ../../C++/ParserClasses/mrr.potlist
endif


ALLCCPOTFILES = $(ALWAYSCCPOTFILES) $(PARSERPOT)

POFILES = $(wildcard *.po)

EXTRA_DIST = mrrsystem_header.pot.in $(POFILES)
pkgdatadir = $(datadir)/$(PACKAGE)
pkgdata_DATA = mrrsystem.pot

CLEANFILES = *.mo en.po mrrsystem.pot

mrrsystem.pot: mrrsystem_header.pot $(ALLCCPOTFILES)
	cat $(ALLCCPOTFILES) >temp.potlist
	$(XGETTEXT) --omit-header --force-po -o mrrsystem.pot0 -n -k_ -k_n:1,2 \
		-C -D $(top_srcdir) -D $(top_builddir) -f temp.potlist 
	cat mrrsystem_header.pot mrrsystem.pot0 > mrrsystem.pot
	-rm -f temp.potlist mrrsystem.pot0

en.po: mrrsystem.pot
	$(MSGEN) --force-po -o en.po mrrsystem.pot

MOFILES = $(patsubst %.po,%.mo,$(POFILES)) en.mo

noinst_DATA = $(MOFILES)

%.mo : %.po
	$(MSGFMT) -o $@ $<

install-data-hook: $(MOFILES)
	$(mkinstalldirs) $(DESTDIR)$(datadir)
	catalogs='$^'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed 's/\.mo$$//'`; \
	  dir=$(LOCALEDIR)/$$lang/LC_MESSAGES; \
	  $(mkinstalldirs) $(DESTDIR)$$dir; \
	  if test -r $$cat; then \
	    $(INSTALL_DATA) $$cat $(DESTDIR)$$dir/mrrsystem.mo; \
	    echo "installing $$cat as $(DESTDIR)$$dir/mrrsystem.mo"; \
	  else \
	    $(INSTALL_DATA) $(srcdir)/$$cat $(DESTDIR)$$dir/mrrsystem.mo; \
	    echo "installing $(srcdir)/$$cat as" \
		 "$(DESTDIR)$$dir/mrrsystem.mo"; \
	  fi; \
	done

uninstall-hook:
	catalogs='$(MOFILES)'; \
	for cat in $$catalogs; do \
	  cat=`basename $$cat`; \
	  lang=`echo $$cat | sed 's/\.mo$$//'`; \
	  rm -f $(DESTDIR)$(localedir)/$$lang/LC_MESSAGES/mrrsystem.mo"; \
	done

../../C++/TTSupport/TTClasses.potlist: FORCE
	$(MAKE) -C ../../C++/TTSupport  TTClasses.potlist

../../C++/FCFSupport/FCFClasses.potlist: FORCE
	$(MAKE) -C ../../C++/FCFSupport FCFClasses.potlist

../../C++/RailDriver/raildriverio.potlist: FORCE
	$(MAKE) -C ../../C++/RailDriver raildriverio.potlist

../../C++/ParserClasses/mrr.potlist: FORCE
	$(MAKE) -C ../../C++/ParserClasses mrr.potlist

../../C++/CMri/cmri.potlist: FORCE
	$(MAKE) -C ../../C++/CMri cmri.potlist

../../C++/XPressNet/xpressnet.potlist: FORCE
	$(MAKE) -C ../../C++/XPressNet xpressnet.potlist

FORCE:
