SUBDIRS = 
TCLCODEFILES = SignalDriverMax72xx_Host.tcl
CODEFILES = SignalDriverMax72xx.ino $(TCLCODEFILES)
FIGURES = Xover-WithSiding.png Xover-WithSiding-small.png \
	  SignalDriverMax72xx_back-photo.jpg \
	  SignalDriverMax72xx_back-photo-thumb.jpg \
	  SignalDriverMax72xx_back.png \
	  SignalDriverMax72xx_back-thumb.png \
	  SignalDriverMax72xx_group2-photo.jpg \
	  SignalDriverMax72xx_group2-photo-thumb.jpg \
	  SignalDriverMax72xx_group2.png \
	  SignalDriverMax72xx_group2-thumb.png \
	  SignalDriverMax72xx_group3-photo.jpg \
	  SignalDriverMax72xx_group3-photo-thumb.jpg \
	  SignalDriverMax72xx_group3.png \
	  SignalDriverMax72xx_group3-thumb.png \
	  SignalDriverMax72xx_group4-photo.jpg \
	  SignalDriverMax72xx_group4-photo-thumb.jpg \
	  SignalDriverMax72xx_group4.png \
	  SignalDriverMax72xx_group4-thumb.png \
	  SignalDriverMax72xx_group5-photo.jpg \
	  SignalDriverMax72xx_group5-photo-thumb.jpg \
	  SignalDriverMax72xx_group5.png \
	  SignalDriverMax72xx_group5-thumb.png \
	  SignalDriverMax72xx_group6-photo.jpg \
	  SignalDriverMax72xx_group6-photo-thumb.jpg \
	  SignalDriverMax72xx_group6.png \
	  SignalDriverMax72xx_group6-thumb.png \
	  SignalDriverMax72xx_group7-photo.jpg \
	  SignalDriverMax72xx_group7-photo-thumb.jpg \
	  SignalDriverMax72xx_group7.png \
	  SignalDriverMax72xx_group7-thumb.png \
	  SignalDriverMax72xx_frontassembly-photo.jpg \
	  SignalDriverMax72xx_frontassembly-photo-thumb.jpg \
	  SignalDriverMax72xx_frontassembly.png \
	  SignalDriverMax72xx_frontassembly-thumb.png \
	  SignalDriverMax72xx_frontassembly-angle-photo.jpg \
	  SignalDriverMax72xx_frontassembly-angle-photo-thumb.jpg \
	  SignalDriverMax72xx_frontassembly-wpinnos.png \
	  SignalDriverMax72xx_frontassembly-wpinnos-thumb.png \
	  SignalConnectorBoard_bare.jpg \
	  SignalConnectorBoard_cablesecuredwithwiretie.jpg \
	  SignalConnectorBoard_cablesolderedon.jpg \
	  SignalConnectorBoard_cablesolderedon_solderside.jpg \
	  SignalConnectorBoard_ColorCodes.jpg \
	  SignalConnectorBoard_copperremoved.jpg \
	  SignalConnectorBoard_holesdrilled.jpg \
	  SignalConnectorBoard_terminalblocksinstalled.jpg \
	  SignalConnectorBoard_bare-thumb.jpg \
	  SignalConnectorBoard_cablesecuredwithwiretie-thumb.jpg \
	  SignalConnectorBoard_cablesolderedon-thumb.jpg \
	  SignalConnectorBoard_cablesolderedon_solderside-thumb.jpg \
	  SignalConnectorBoard_ColorCodes-thumb.jpg \
	  SignalConnectorBoard_copperremoved-thumb.jpg \
	  SignalConnectorBoard_holesdrilled-thumb.jpg \
	  SignalConnectorBoard_terminalblocksinstalled-thumb.jpg \
	  SignalConnectorCable_wiresstripedandtinned.jpg \
	  SignalConnectorCable_wiresstripedandtinned-thumb.jpg \
	  SignalConnectorCable_headerpluginstalled.jpg \
	  SignalConnectorCable_headerpluginstalled-thumb.jpg \
	  ComponentsideofUnoconnector.jpg \
	  ComponentsideofUnoconnector-thumb.jpg \
	  UnoConnector_FoilSide.jpg \
	  UnoConnector_FoilSide-thumb.jpg \
	  connector_on_Uno.jpg \
	  connector_on_Uno-thumb.jpg \
	  ConnectorPlug_Installed.jpg \
	  ConnectorPlug_Installed-thumb.jpg \
	  InstallingConnectorPlugs.jpg \
	  InstallingConnectorPlugs-thumb.jpg \
	  ChipPackageOutline.png  ChipPhoto.jpg ChipTape.png \
	  ChipTape-thumb.png ChipPackageOutline-thumb.png \
	  SignalChipLEDInCarrier.jpg SignalChipLEDInCarrier-thumb.jpg \
	  SignalTargetAndStripBoard.jpg SignalTargetAndStripBoard-thumb.jpg \
	  SignalCircuitBoard_WiresSoldered.jpg \
	  SignalChipLEDSoldered.jpg SerialMonitor_TestSketch.png \
	  SerialMonitor_TestSketch-thumb.png
OTHERFILES = SignalDriverMax72xx.zip
DOCFILES = Preface.h Introduction.h SignalDriverBoard.h \
           ConnectingSignalDriverBoard.h SignalDriverboardcables.h \
           Assemblingsignaltargets.h ProgrammingtheArduino.h
EXTRA_DIST = $(OTHERFILES) $(CODEFILES) $(FIGURES) Doxyfile.in $(DOCFILES) \
            navbar.html
pkgdatadir = $(datadir)/$(PACKAGE)/ExampleDataAndCode/Signals/ArdunioMAX72XX
noinst_DATA = html/index.html
pkgdata_DATA =  latex/refman.pdf pkgIndex.tcl

html/index.html latex/refman.pdf : Doxyfile $(DOCFILES) $(CODEFILES) $(FIGURES)\
	$(top_builddir)/Doc/doxygen/tcldoxyfilter.sh
	$(DOXYGEN) -w html header0.html /dev/null doxygen.css  Doxyfile
	rm doxygen.css
	cat header0.html $(srcdir)/navbar.html > navheader.html
	rm header0.html
	-rm -rf latex/ html/
	-chmod +x $(top_builddir)/Doc/doxygen/tcldoxyfilter.sh
	$(DOXYGEN) Doxyfile
	for p in $(FIGURES) $(CODEFILES) $(OTHERFILES); do \
	  if test ! \( -f html/$$p \); then cp $(srcdir)/$$p html/; fi; \
	done
	$(MAKE) -C latex pdf

$(top_builddir)/Doc/doxygen/tcldoxyfilter.sh : $(top_builddir)/Doc/doxygen/tcldoxyfilter.sh.in
	$(MAKE) -C $(top_builddir)/Doc/doxygen tcldoxyfilter.sh

clean-local:
	-rm -rf latex/ html/

CLEANFILES = pkgIndex.tcl
TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}

pkgIndex.tcl : $(TCLCODEFILES)
	for f in $(notdir $^) ; do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi;\
	done
	echo "pkg_mkIndex . $(notdir $^)" | $(TCLKIT)

install-data-hook: $(CODEFILES) $(OTHERFILES) html/index.html
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)
	for p in $(CODEFILES) $(OTHERFILES); do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$(USERMANHBase)$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done

uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/*; do \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/$$f"; \
	done                                                         

