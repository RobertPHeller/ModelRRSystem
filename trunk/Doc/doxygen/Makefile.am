ParserClassesHeaders = \
	$(top_builddir)/C++/ParserClasses/ParserClassesGroup.h \
	$(top_srcdir)/C++/ParserClasses/IntegerList.h \
	$(top_srcdir)/C++/ParserClasses/ParseFile.h \
	$(top_srcdir)/C++/ParserClasses/TrackBody.h \
	$(top_srcdir)/C++/ParserClasses/TurnoutBody.h \
	$(top_srcdir)/C++/ParserClasses/TrackGraph.h \
	$(top_srcdir)/C++/ParserClasses/SocketPair.h \
	$(top_builddir)/C++/ParserClasses/MRRXtrkCad.tab.h

CMriTcls = $(top_srcdir)/Scripts/CMri/cmri.tcl

CTIAcelaTcls = $(top_srcdir)/Scripts/CTIAcela/CTIAcela.tcl

LCCTcls = $(top_srcdir)/Scripts/LCC/lcc.tcl \
          $(top_srcdir)/Scripts/LCC/ConfigurationEditor.tcl

#MRDHeaders = $(top_builddir)/C++/MRD/mrd.h

AzatraxHeaders = $(top_builddir)/C++/Azatrax/Azatrax.h \
		 $(top_srcdir)/C++/Azatrax/mrd.h \
		 $(top_srcdir)/C++/Azatrax/sl2.h \
		 $(top_srcdir)/C++/Azatrax/sr4.h

XPressNetTcls = $(top_srcdir)/Scripts/XPressNet/xpressnet.tcl

NCETcls = $(top_srcdir)/Scripts/NCE/nce.tcl

FCFSupportHeaders = $(top_srcdir)/C++/FCFSupport/FCFSupportGroup.h \
	$(top_builddir)/C++/FCFSupport/System.h \
	$(top_srcdir)/C++/FCFSupport/Division.h \
	$(top_srcdir)/C++/FCFSupport/Station.h \
	$(top_srcdir)/C++/FCFSupport/Train.h \
	$(top_srcdir)/C++/FCFSupport/Industry.h \
	$(top_srcdir)/C++/FCFSupport/CarType.h \
	$(top_srcdir)/C++/FCFSupport/Owner.h \
	$(top_srcdir)/C++/FCFSupport/Car.h \
	$(top_srcdir)/C++/FCFSupport/CallBack.h \
	$(top_srcdir)/C++/FCFSupport/SwitchList.h \
	$(top_srcdir)/C++/FCFSupport/PathName.h \
	$(top_srcdir)/C++/FCFSupport/Printer.h \
	$(top_srcdir)/C++/FCFSupport/TextPrinter.h \
	$(top_srcdir)/C++/FCFSupport/PostScriptPrinter.h \
	$(top_srcdir)/C++/FCFSupport/LQ24Printer.h  \
	$(top_srcdir)/C++/FCFSupport/PDFPrinterSupport.h \
	$(top_srcdir)/C++/FCFSupport/PDFPrinter.h

TTSupportHeaders = $(top_builddir)/C++/TTSupport/TTSupportGroup.h \
	$(top_srcdir)/C++/TTSupport/TimeTableSystem.h \
	$(top_srcdir)/C++/TTSupport/TimeTableSystemTcl.h \
	$(top_srcdir)/C++/TTSupport/PathName.h \
	$(top_srcdir)/C++/TTSupport/Station.h \
	$(top_srcdir)/C++/TTSupport/Train.h \
	$(top_srcdir)/C++/TTSupport/Cab.h 
	 
RailDriverHeaders = 	$(top_builddir)/C++/RailDriver/RaildriverIO.h

C_INTERNALS_H_HERE = titlepage.h #Intro.h Biblio.h
C_INTERNALS_H = $(C_INTERNALS_H_HERE) \
	$(ParserClassesHeaders) $(AzatraxHeaders) \
	$(FCFSupportHeaders) $(TTSupportHeaders) \
	$(RailDriverHeaders) $(RailDriverHeaders)

SERIAL_TCL_INTERNALS_TCLS = $(CMriTcls) $(CTIAcelaTcls) $(LCCTcls) \
				$(XPressNetTcls) $(NCETcls) 

COMMON_TCL_INTERNALS_TCLS = $(top_srcdir)/Scripts/Common/CommonTclGroup.h \
			    $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl \
			    $(top_srcdir)/Scripts/Common/CTCPanel2.tcl \
			    $(top_srcdir)/Scripts/Common/labelselectcolor.tcl \
			    $(top_srcdir)/Scripts/Common/HTMLHelp.tcl \
			    $(top_srcdir)/Scripts/Common/fileentry.tcl \
			    $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
			    $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
			    $(top_srcdir)/Scripts/Common/panedw.tcl \
			    $(top_srcdir)/Scripts/Common/splash.tcl \
			    $(top_srcdir)/Scripts/Common/mainwindow.tcl \
			    $(top_srcdir)/Scripts/Common/CabWidgets.tcl \
			    $(top_srcdir)/Scripts/Common/gettext.tcl \
			    $(top_srcdir)/Scripts/Common/ParseXML.tcl \
			    $(top_srcdir)/Scripts/Common/snitScrollNotebook.tcl
			    
GRSUPPORT_TCL_INTERNALS_TCLS = $(top_srcdir)/Scripts/GRSupport/GRSupportTclGroup.h \
			       $(top_srcdir)/Scripts/GRSupport/grsupport2.tcl \
			       $(top_srcdir)/Scripts/GRSupport/Instruments2.tcl \
			       $(top_srcdir)/Scripts/GRSupport/LCARSWidgets2.tcl \
			       $(top_srcdir)/Scripts/GRSupport/OvalWidgets2.tcl
CONTROL_SUPPORT_TCL_INTERNALS_TCLS = $(top_srcdir)/Scripts/ControlSupport/CmriSupport.tcl

OTHER_TCL_INTERNALS_TCLS = $(top_srcdir)/Scripts/RailDriverSupport/raildriver_client.tcl

TCL_INTERNALS_TCLS = $(COMMON_TCL_INTERNALS_TCLS) \
			$(GRSUPPORT_TCL_INTERNALS_TCLS) \
			$(CONTROL_SUPPORT_TCL_INTERNALS_TCLS) \
			$(SERIAL_TCL_INTERNALS_TCLS)
TCL_INTERNALS_HERE = #IntroTclInternals.tex common_part.tex grsupport_part.tex control_support_part.tex

EXTRA_DIST = $(C_INTERNALS_H_HERE) tcldoxyfilter.sh.in

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

noinst_DATA=html/index.html 

pkgdata_DATA = internals.pdf

man3dir = $(mandir)/man3

tcldoxyfilter.sh: tcldoxyfilter.sh.in $(top_builddir)/config.status
	$(top_builddir)/config.status --file=tcldoxyfilter.sh:$(srcdir)/tcldoxyfilter.sh.in
	chmod +x tcldoxyfilter.sh
	

html/index.html latex/refman.tex man/man3 : Doxyfile $(C_INTERNALS_H) \
					    $(TCL_INTERNALS_TCLS) \
					    tcldoxyfilter.sh
	-rm -rf html latex man
	-chmod +x tcldoxyfilter.sh
	$(DOXYGEN)
	-rm -f man/man3/*.h.3 man/man3/*.tcl.3


internals.pdf: latex/refman.tex
	$(MAKE) -C latex
	mv latex/refman.pdf internals.pdf

clean-local:
	-rm -rf html latex man
	-rm -f doxygen.log  internals.pdf


install-data-hook: html/index.html man/man3
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/InternalsHTML
	for p in html/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/InternalsHTML/$$f'"; \
	  $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/InternalsHTML/$$f"; \
	done
	test -z "$(man3dir)" || $(mkdir_p) "$(DESTDIR)$(man3dir)"
	@list=man/man3/* ; \
	for i in $$list; do \
	  file=$$i; \
	  ext=`echo $$i | sed -e 's/^.*\\.//'`; \
	  case "$$ext" in \
	    3*) ;; \
	    *) ext='3' ;; \
	  esac; \
	  inst=`echo $$i | sed -e 's/\\.[0-9a-z]*$$//'`; \
	  inst=`echo $$inst | sed -e 's/^.*\///'`; \
	  inst=`echo $$inst | sed '$(transform)'`.$$ext; \
	  echo " $(INSTALL_DATA) '$$file' '$(DESTDIR)$(man3dir)/$$inst'"; \
	  $(INSTALL_DATA) "$$file" "$(DESTDIR)$(man3dir)/$$inst"; \
	done
	
uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/InternalsHTML/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=`echo $$p | sed -e 's|^.*/||'`; \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/InternalsHTML/$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/InternalsHTML/$$f"; \
	done
	@list=man/man3/* ; \
	for i in $$list; do \
	  file=$$i; fi; \
	  ext=`echo $$i | sed -e 's/^.*\\.//'`; \
	  case "$$ext" in \
	    3*) ;; \
	    *) ext='3' ;; \
	  esac; \
	  inst=`echo $$i | sed -e 's/\\.[0-9a-z]*$$//'`; \
	  inst=`echo $$inst | sed -e 's/^.*\///'`; \
	  inst=`echo $$inst | sed '$(transform)'`.$$ext; \
	  echo " rm -f '$(DESTDIR)$(man3dir)/$$inst'"; \
	  rm -f "$(DESTDIR)$(man3dir)/$$inst"; \
	done

$(top_builddir)/C++/ParserClasses/MRRXtrkCad.tab.h : \
		$(top_srcdir)/C++/ParserClasses/MRRXtrkCad.y
	$(MAKE) -C $(top_builddir)/C++/ParserClasses MRRXtrkCad.tab.h


$(top_builddir)/C++/ParserClasses/ParserClassesGroup.h : \
	$(top_srcdir)/C++/ParserClasses/ParserClassesGroup.h.in \
	$(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/C++/ParserClasses ParserClassesGroup.h

$(top_builddir)/C++/MRD/mrd.h : \
	$(top_srcdir)/C++/MRD/mrd.h.in \
	$(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/C++/MRD mrd.h

$(top_builddir)/C++/FCFSupport/System.h : \
	$(top_srcdir)/C++/FCFSupport/System.h.in \
	$(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/C++/FCFSupport System.h

$(top_builddir)/C++/TTSupport/TTSupportGroup.h : \
	$(top_srcdir)/C++/TTSupport/TTSupportGroup.h.in \
	$(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/C++/TTSupport TTSupportGroup.h

$(top_builddir)/C++/RailDriver/RaildriverIO.h : \
	$(top_srcdir)/C++/RailDriver/RaildriverIO.h.in \
	$(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/C++/RailDriver RaildriverIO.h

$(top_builddir)/C++/Azatrax/Azatrax.h : \
	$(top_srcdir)/C++/Azatrax/Azatrax.h.in \
	$(top_builddir)/config.status
	$(MAKE) -C $(top_builddir)/C++/Azatrax Azatrax.h
