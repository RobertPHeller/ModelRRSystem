POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../C++/RailDriver/raildriverd.pot
	$(MSGEN) --force-po -o en.po ../../C++/RailDriver/raildriverd.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../C++/RailDriver/raildriverd.pot: FORCE
	$(MAKE) -C ../../C++/RailDriver/ raildriverd.pot

FORCE:
