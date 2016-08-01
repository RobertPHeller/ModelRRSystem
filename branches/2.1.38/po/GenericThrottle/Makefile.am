POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/GenericThrottle/GenericThrottle.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/GenericThrottle/GenericThrottle.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 

../../Scripts/GenericThrottle/GenericThrottle.pot: FORCE
	$(MAKE) -C ../../Scripts/GenericThrottle/ GenericThrottle.pot

FORCE:
