POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/LCC/OpenLCB.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/LCC/OpenLCB.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/LCC/OpenLCB.pot: FORCE
	$(MAKE) -C ../../Scripts/LCC/ OpenLCB.pot

FORCE:
