POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../C++/XPressNet/XPressNetThrottle.pot
	$(MSGEN) --force-po -o en.po ../../C++/XPressNet/XPressNetThrottle.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 

../../C++/XPressNet/XPressNetThrottle.pot: FORCE
	$(MAKE) -C ../../C++/XPressNet/ XPressNetThrottle.pot

FORCE:
