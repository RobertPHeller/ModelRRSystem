POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/CameraScripts/CameraScripts.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/CameraScripts/CameraScripts.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 

../../Scripts/CameraScripts/CameraScripts.pot: FORCE
	$(MAKE) -C ../../Scripts/CameraScripts/ CameraScripts.pot

FORCE:
