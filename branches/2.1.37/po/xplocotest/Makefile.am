POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/RailDriverSupport/xplocotest.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/RailDriverSupport/xplocotest.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/RailDriverSupport/xplocotest.pot: FORCE
	$(MAKE) -C ../../Scripts/RailDriverSupport/ xplocotest.pot

FORCE:
