POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/LinuxGpio/LinuxGpio.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/LinuxGpio/LinuxGpio.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/LinuxGpio/LinuxGpio.pot: FORCE
	$(MAKE) -C ../../Scripts/LinuxGpio/ LinuxGpio.pot

FORCE:
