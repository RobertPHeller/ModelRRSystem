POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/CalcScripts/CalcScripts.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/CalcScripts/CalcScripts.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<


../../Scripts/CalcScripts/CalcScripts.pot: FORCE
	$(MAKE) -C ../../Scripts/CalcScripts/ CalcScripts.pot

FORCE:
