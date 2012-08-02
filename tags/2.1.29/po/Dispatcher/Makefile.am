POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/Dispatcher/Dispatcher.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/Dispatcher/Dispatcher.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<


../../Scripts/Dispatcher/Dispatcher.pot: FORCE
	$(MAKE) -C ../../Scripts/Dispatcher/ Dispatcher.pot

FORCE:
