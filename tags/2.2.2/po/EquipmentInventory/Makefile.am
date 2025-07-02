POFILES = $(wildcard *.po)
EXTRA_DIST = $(POFILES)

en.po: ../../Scripts/EquipmentInventory/EquipmentInventory.pot
	$(MSGEN) --force-po -o en.po ../../Scripts/EquipmentInventory/EquipmentInventory.pot



msgfiles: $(patsubst %.po,%.msg,$(POFILES)) en.msg
	
%.msg : %.po
	$(MSGFMT) -l $* --tcl -d . $<

CLEANFILES = en.po *.msg 


../../Scripts/EquipmentInventory/EquipmentInventory.pot: FORCE
	$(MAKE) -C ../../Scripts/EquipmentInventory/ EquipmentInventory.pot

FORCE:
