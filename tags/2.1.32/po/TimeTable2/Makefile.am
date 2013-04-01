POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/TimeTable2/TimeTable2.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/TimeTable2/TimeTable2.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/TimeTable2/TimeTable2.pot: FORCE
	$(MAKE) -C ../../Scripts/TimeTable2/ TimeTable2.pot

FORCE:
