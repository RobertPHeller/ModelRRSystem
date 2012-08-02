POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/FreightCarForwarder2/FreightCarForwarder2.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/FreightCarForwarder2/FreightCarForwarder2.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<


../../Scripts/FreightCarForwarder2/FreightCarForwarder2.pot: FORCE
	$(MAKE) -C ../../Scripts/FreightCarForwarder2/ FreightCarForwarder2.pot

FORCE:
