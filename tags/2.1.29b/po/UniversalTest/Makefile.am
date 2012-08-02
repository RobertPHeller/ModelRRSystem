POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../C++/CMri/UniversalTest.pot
	$(MSGEN) --force-po -o en.po ../../C++/CMri/UniversalTest.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<


../../C++/CMri/UniversalTest.pot: FORCE
	$(MAKE) -C ../../C++/CMri/ UniversalTest.pot

FORCE:
