#* 
#* ------------------------------------------------------------------
#* Makefile.am - Internals Docs Makefile
#* Created by Robert Heller on Fri Nov  4 13:51:34 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.15  2007/05/06 14:44:38  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.14  2007/05/06 12:49:38  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.13  2007/04/19 17:23:22  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.12  2007/02/02 01:29:23  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.10  2007/02/01 20:58:49  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.9  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.8  2007/01/08 19:05:54  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.7  2006/08/04 01:59:25  heller
#* Modification History: Aug 3 Lockdown
#* Modification History:
#* Modification History: Revision 1.6  2006/05/17 23:42:37  heller
#* Modification History: May 17, 2006 Lock down
#* Modification History:
#* Modification History: Revision 1.5  2006/02/06 00:18:09  heller
#* Modification History: Start converting to BWidget from Tix
#* Modification History:
#* Modification History: Revision 1.4  2006/01/03 15:30:21  heller
#* Modification History: Lockdown
#* Modification History:
#* Modification History: Revision 1.3  2005/11/20 09:46:33  heller
#* Modification History: Nov. 20, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.2  2005/11/14 20:28:45  heller
#* Modification History: Nov 14, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:35  heller
#* Modification History: Nov 4, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
#* 			51 Locke Hill Road
#* 			Wendell, MA 01379-9728
#* 
#*     This program is free software; you can redistribute it and/or modify
#*     it under the terms of the GNU General Public License as published by
#*     the Free Software Foundation; either version 2 of the License, or
#*     (at your option) any later version.
#* 
#*     This program is distributed in the hope that it will be useful,
#*     but WITHOUT ANY WARRANTY; without even the implied warranty of
#*     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#*     GNU General Public License for more details.
#* 
#*     You should have received a copy of the GNU General Public License
#*     along with this program; if not, write to the Free Software
#*     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#* 
#*  
#* 

SUFFIXES	= .tcl .sty

ParserClassesHeaders = 	../../C++/ParserClasses/Begin.h \
	../../C++/ParserClasses/IntegerList.h \
	../../C++/ParserClasses/ParseFile.h \
	../../C++/ParserClasses/TrackBody.h \
	../../C++/ParserClasses/TurnoutBody.h \
	../../C++/ParserClasses/TrackGraph.h \
	../../C++/ParserClasses/SocketPair.h \
	../../C++/ParserClasses/End.h

CMriHeaders = ../../C++/CMri/cmri.h

XPressNetHeaders = ../../C++/XPressNet/Begin.h \
	../../C++/XPressNet/xpressnet.h ../../C++/XPressNet/xpressnet_Event.h \
	../../C++/XPressNet/End.h 

FCFSupportHeaders = ../../C++/FCFSupport/Begin.h \
	../../C++/FCFSupport/PathName.h ../../C++/FCFSupport/SwitchList.h \
	../../C++/FCFSupport/Division.h ../../C++/FCFSupport/Station.h \
	../../C++/FCFSupport/Train.h ../../C++/FCFSupport/Industry.h \
	../../C++/FCFSupport/CarType.h ../../C++/FCFSupport/Owner.h \
	../../C++/FCFSupport/Car.h ../../C++/FCFSupport/System.h \
	../../C++/FCFSupport/CallBack.h ../../C++/FCFSupport/Printer.h \
	../../C++/FCFSupport/TextPrinter.h \
	../../C++/FCFSupport/PostScriptPrinter.h \
	../../C++/FCFSupport/LQ24Printer.h  \
	../../C++/FCFSupport/PDFPrinterSupport.h \
	../../C++/FCFSupport/PDFPrinter.h \
	../../C++/FCFSupport/End.h

TTSupportHeaders = ../../C++/TTSupport/Begin.h \
	../../C++/TTSupport/TimeTableSystem.h ../../C++/TTSupport/PathName.h \
	../../C++/TTSupport/Station.h ../../C++/TTSupport/Train.h \
	../../C++/TTSupport/Cab.h ../../C++/TTSupport/End.h
	 

RailDriverHeaders = 	../../C++/RailDriver/Introduction.h \
	../../C++/RailDriver/RaildriverIO.h \
	../../C++/RailDriver/RaildriverServer.h \
	../../C++/RailDriver/End.h


C_INTERNALS_H_HERE = Intro.h Biblio.h
C_INTERNALS_H = $(C_INTERNALS_H_HERE) \
	$(ParserClassesHeaders) $(CMriHeaders) $(XPressNetHeaders) \
	$(FCFSupportHeaders) $(TTSupportHeaders) \
	$(RailDriverHeaders)


C_INTERNALS_H_DOCORDER = Intro.h $(ParserClassesHeaders) $(CMriHeaders) \
	$(XPressNetHeaders) $(FCFSupportHeaders) \
	$(TTSupportHeaders) $(RailDriverHeaders) \
	Biblio.h
C_INTERNALS_PDF = CxxInternals.pdf
C_INTERNALS_LATEX = CxxInternals.tex
C_INTERNALS_LATEX_ENV = CxxInternals.texenv
C_INTERNALS = CxxInternals
C_INTERNALS_HTML = #$(C_INTERNALS)/CxxInternals.html

TCL2TEXKIT = ../Support/tcl2tex.kit
TCL2TEX = $(TCLKIT) $(TCL2TEXKIT)

TCL_INTERNALS_PDF = TclInternals.pdf
TCL_INTERNALS_HTML = TclInternals/TclInternals.html
COMMON_TCL_INTERNALS_LATEXSX = CTCPanel.tex ReadConfiguration.tex \
			       BWStdMenuBar.tex CTCPanel2.tex \
			       labelselectcolor.tex BWHelp.tex \
			       fileentry.tex labelcombobox.tex \
			       labelspinbox.tex panedw.tex \
			       splash.tex mainwindow.tex
GRSUPPORT_TCL_INTERNALS_LATEXSX = grsupport.tex Instruments.tex \
				  LCARSWidgets.tex OvalWidgets.tex \
				  grsupport2.tex Instruments2.tex \
				  LCARSWidgets2.tex OvalWidgets2.tex
CONTROL_SUPPORT_TCL_INTERNALS_LATEXSX = CmriSupport.tex
TCL_INTERNALS_LATEXSX = $(COMMON_TCL_INTERNALS_LATEXSX) \
			$(GRSUPPORT_TCL_INTERNALS_LATEXSX) \
			$(CONTROL_SUPPORT_TCL_INTERNALS_LATEXSX)
TCL_INTERNALS_HERE = IntroTclInternals.tex common_part.tex grsupport_part.tex \
			control_support_part.tex
TCL_INTERNALS_LATEXS = ../MyTitlepage.sty ../MyPart.sty ../MyBibIndex.sty \
	titlepage.tex $(TCL_INTERNALS_LATEXSX) $(TCL_INTERNALS_HERE)
TCL_INTERNALS_LATEX = TclInternals.tex 
TCL_INTERNALS_IND = TclInternals.ind
TCL_INTERNALS_IDX = TclInternals.idx
TCL_INTERNALSBase = TclInternals

BIBLIO = ../MRR.bib

%.tex: %.tcl
	$(TCL2TEX) -forinput $@ $<


EXTRA_DIST = $(C_INTERNALS_H_HERE) $(TCL_INTERNALS_HERE) \
		$(C_INTERNALS_LATEX_ENV) \
		$(TCL_INTERNALS_LATEX) docxx.sty

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

install-data-hook: $(TCL_INTERNALS_HTML) #$(C_INTERNALS_HTML) 
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/TclInternals
	for p in TclInternals/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=$(am__strip_dir) \
	  echo " $(pkgdataDATA_INSTALL) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/TclInternals$$f'"; \
	  $(pkgdataDATA_INSTALL) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/TclInternals/$$f"; \
        done
	
uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/TclInternals/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=$(am__strip_dir) \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/TclInternals$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/TclInternals/$$f"; \
        done
	

#pkgdata_DATA = $(C_INTERNALS_PDF) $(C_INTERNALS_PS) \
#	       $(C_INTERNALS_E_PS) $(C_INTERNALS_O_PS) \
#	       $(SWIG_INTERNALS_PDF) $(SWIG_INTERNALS_PS) \
#	       $(SWIG_INTERNALS_E_PS) $(SWIG_INTERNALS_O_PS) \
#	       $(TCL_INTERNALS_PDF) $(TCL_INTERNALS_PS) \
#	       $(TCL_INTERNALS_E_PS) $(TCL_INTERNALS_O_PS)
pkgdata_DATA = $(C_INTERNALS_PDF)  \
	       $(TCL_INTERNALS_PDF) 

noinst_DATA = $(TCL_INTERNALS_HTML) $(C_INTERNALS_HTML)


titlepage.tex : ../titlepage.tex
	ln -s ../titlepage.tex ./titlepage.tex

$(C_INTERNALS_PDF) : $(C_INTERNALS_LATEX) docxx.sty $(BIBLIO) \
	../MyTitlepage.sty titlepage.tex # ../Cover1.ps
	$(PDFLATEX) $(C_INTERNALS_LATEX)
	-$(BIBTEX) $(C_INTERNALS)
	$(PDFLATEX) $(C_INTERNALS_LATEX)
	$(PDFLATEX) $(C_INTERNALS_LATEX)



$(C_INTERNALS_LATEX) : $(C_INTERNALS_H) $(C_INTERNALS_LATEX_ENV) Makefile
	$(DOCXX) -t -v -p -ef $(C_INTERNALS_LATEX_ENV) -l -o $(C_INTERNALS_LATEX) \
		$(C_INTERNALS_H_DOCORDER)
	echo '\end{document}' >>$(C_INTERNALS_LATEX)

#$(C_INTERNALS_HTML) :  $(C_INTERNALS_H) $(C_INTERNALS_LATEX_ENV) Makefile \
#			$(C_INTERNALS_PDF)
#	-rm -rf $(C_INTERNALS)
#	-mkdir $(C_INTERNALS)
#	$(DOCXX) -c -v -p -d $(C_INTERNALS) $(C_INTERNALS_H_DOCORDER)

$(TCL_INTERNALS_PDF) : $(TCL_INTERNALS_LATEX) $(TCL_INTERNALS_LATEXS) \
	$(BIBLIO)  # ../Cover1.ps
	$(PDFLATEX) $(TCL_INTERNALS_LATEX)
	-$(BIBTEX) $(TCL_INTERNALSBase)
	echo '\begin{theindex}' > $(TCL_INTERNALS_IND)
	echo '\item Dummy, 0' >> $(TCL_INTERNALS_IND)
	echo '\end{theindex}' >> $(TCL_INTERNALS_IND)
	$(PDFLATEX) $(TCL_INTERNALS_LATEX)
	$(MAKEINDEX) $(TCL_INTERNALS_IDX)
	$(PDFLATEX) $(TCL_INTERNALS_LATEX)

$(TCL_INTERNALS_HTML) : $(TCL_INTERNALS_PDF)
	-rm -rf $(TCL_INTERNALSBase)
	-mkdir $(TCL_INTERNALSBase)
	$(HTLATEX) $(TCL_INTERNALSBase) "html,2,info" "" \
		"-d$(TCL_INTERNALSBase)/"
	-rm -f zz$(TCL_INTERNALSBase).p* $(TCL_INTERNALSBase).4ct \
		$(TCL_INTERNALSBase).xref $(TCL_INTERNALSBase).4tc tex4ht.fls \
		$(TCL_INTERNALSBase).tmp $(TCL_INTERNALSBase).lg \
		$(TCL_INTERNALSBase).idv $(TCL_INTERNALSBase).dvi \
		$(TCL_INTERNALSBase)*.html

BWStdMenuBar.tex : ../../Scripts/Common/BWStdMenuBar.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

CTCPanel.tex : ../../Scripts/Common/CTCPanel.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

ReadConfiguration.tex : ../../Scripts/Common/ReadConfiguration.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

CTCPanel2.tex : ../../Scripts/Common/CTCPanel2.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

labelselectcolor.tex : ../../Scripts/Common/labelselectcolor.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

BWHelp.tex : ../../Scripts/Common/BWHelp.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

fileentry.tex : ../../Scripts/Common/fileentry.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

labelcombobox.tex : ../../Scripts/Common/labelcombobox.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

labelspinbox.tex : ../../Scripts/Common/labelspinbox.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

panedw.tex : ../../Scripts/Common/panedw.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

splash.tex : ../../Scripts/Common/splash.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

mainwindow.tex : ../../Scripts/Common/mainwindow.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

grsupport.tex : ../../Scripts/GRSupport/grsupport.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

Instruments.tex : ../../Scripts/GRSupport/Instruments.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

LCARSWidgets.tex : ../../Scripts/GRSupport/LCARSWidgets.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

OvalWidgets.tex : ../../Scripts/GRSupport/OvalWidgets.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

grsupport2.tex : ../../Scripts/GRSupport/grsupport2.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

Instruments2.tex : ../../Scripts/GRSupport/Instruments2.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

LCARSWidgets2.tex : ../../Scripts/GRSupport/LCARSWidgets2.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<

OvalWidgets2.tex : ../../Scripts/GRSupport/OvalWidgets2.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<


CmriSupport.tex : ../../Scripts/ControlSupport/CmriSupport.tcl $(TCL2TEXKIT)
	$(TCL2TEX) -forinput $@ $<
