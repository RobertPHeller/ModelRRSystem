POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/CMRI_Slave/CMRI_Slave.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/CMRI_Slave/CMRI_Slave.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/CMRI_Slave/CMRI_Slave.pot: FORCE
	$(MAKE) -C ../../Scripts/CMRI_Slave/ CMRI_Slave.pot

FORCE:
