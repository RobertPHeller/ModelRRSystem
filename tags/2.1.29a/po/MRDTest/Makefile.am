POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../C++/MRD/MRDTest.pot
	$(MSGEN) --force-po -o en.po ../../C++/MRD/MRDTest.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<


../../C++/MRD/MRDTest.pot: FORCE
	$(MAKE) -C ../../C++/MRD/ MRDTest.pot

FORCE:
