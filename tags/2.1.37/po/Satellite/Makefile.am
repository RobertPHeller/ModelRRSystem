POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/Satellite/SatelliteDaemon.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/Satellite/SatelliteDaemon.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/Satellite/SatelliteDaemon.pot: FORCE
	$(MAKE) -C ../../Scripts/Satellite/ SatelliteDaemon.pot

FORCE:
