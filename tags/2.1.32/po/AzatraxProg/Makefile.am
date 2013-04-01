POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../C++/Azatrax/AzatraxProg.pot
	$(MSGEN) --force-po -o en.po ../../C++/Azatrax/AzatraxProg.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../C++/Azatrax/AzatraxProg.pot: FORCE
	$(MAKE) -C ../../C++/Azatrax/ AzatraxProg.pot

FORCE:
