POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/CMri/UniversalTest.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/CMri/UniversalTest.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/CMri/UniversalTest.pot: FORCE
	$(MAKE) -C ../../Scripts/CMri/ UniversalTest.pot

FORCE:
