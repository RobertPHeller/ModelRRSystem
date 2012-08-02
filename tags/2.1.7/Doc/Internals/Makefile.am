#* 
#* ------------------------------------------------------------------
#* Makefile.am - Internals Docs Makefile
#* Created by Robert Heller on Fri Nov  4 13:51:34 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

C_INTERNALS_H_HERE = Intro.h Biblio.h
C_INTERNALS_H = $(C_INTERNALS_H_HERE) \
	../../C++/ParserClasses/Begin.h \
	../../C++/ParserClasses/IntegerList.h ../../C++/ParserClasses/ParseFile.h \
	../../C++/ParserClasses/TrackBody.h ../../C++/ParserClasses/TurnoutBody.h \
	../../C++/ParserClasses/TrackGraph.h ../../C++/ParserClasses/End.h \
	../../C++/CMri/cmri.h \
	../../C++/RailDriver/Introduction.h \
	../../C++/RailDriver/raildriverthread.h \
	../../C++/RailDriver/raildriver.h ../../C++/RailDriver/End.h \
	../../C++/XPressNet/Begin.h \
	../../C++/XPressNet/xpressnet.h ../../C++/XPressNet/xpressnet_Event.h \
	../../C++/XPressNet/End.h \
	../../C++/FCFSupport/Begin.h ../../C++/FCFSupport/System.h \
	../../C++/FCFSupport/CallBack.h ../../C++/FCFSupport/Car.h \
	../../C++/FCFSupport/CarType.h ../../C++/FCFSupport/Common.h \
	../../C++/FCFSupport/Division.h ../../C++/FCFSupport/Industry.h \
	../../C++/FCFSupport/LQ24Printer.h ../../C++/FCFSupport/Owner.h \
	../../C++/FCFSupport/Train.h ../../C++/FCFSupport/PathName.h \
	../../C++/FCFSupport/PDFPrinterSupport.h ../../C++/FCFSupport/PDFPrinter.h \
	../../C++/FCFSupport/PostScriptPrinter.h ../../C++/FCFSupport/Printer.h \
	../../C++/FCFSupport/Station.h ../../C++/FCFSupport/SwitchList.h \
	../../C++/FCFSupport/TextPrinter.h \
	../../C++/FCFSupport/End.h \
	../../C++/TTSupport/Begin.h ../../C++/TTSupport/Cab.h \
	../../C++/TTSupport/Common.h ../../C++/TTSupport/End.h \
	../../C++/TTSupport/PathName.h ../../C++/TTSupport/Station.h \
	../../C++/TTSupport/TimeTableSystem.h ../../C++/TTSupport/Train.h \
	Biblio.h
C_INTERNALS_H_DOCORDER = Intro.h ../../C++/ParserClasses/Begin.h \
	../../C++/ParserClasses/IntegerList.h ../../C++/ParserClasses/ParseFile.h \
	../../C++/ParserClasses/TrackBody.h ../../C++/ParserClasses/TurnoutBody.h \
	../../C++/ParserClasses/TrackGraph.h ../../C++/ParserClasses/End.h \
	../../C++/CMri/cmri.h \
	../../C++/RailDriver/Introduction.h \
	../../C++/RailDriver/raildriverthread.h \
	../../C++/RailDriver/raildriver.h ../../C++/RailDriver/End.h \
	../../C++/XPressNet/Begin.h \
	../../C++/XPressNet/xpressnet.h ../../C++/XPressNet/xpressnet_Event.h \
	../../C++/XPressNet/End.h \
	../../C++/FCFSupport/Begin.h \
	../../C++/FCFSupport/PathName.h ../../C++/FCFSupport/SwitchList.h \
	../../C++/FCFSupport/Division.h ../../C++/FCFSupport/Station.h \
	../../C++/FCFSupport/Train.h ../../C++/FCFSupport/Industry.h \
	../../C++/FCFSupport/CarType.h ../../C++/FCFSupport/Owner.h \
	../../C++/FCFSupport/Car.h ../../C++/FCFSupport/System.h \
	../../C++/FCFSupport/CallBack.h ../../C++/FCFSupport/Printer.h \
	../../C++/FCFSupport/TextPrinter.h \
	../../C++/FCFSupport/PostScriptPrinter.h \
	../../C++/FCFSupport/LQ24Printer.h \
	../../C++/FCFSupport/PDFPrinterSupport.h \
	../../C++/FCFSupport/PDFPrinter.h \
	../../C++/FCFSupport/End.h \
	../../C++/TTSupport/Begin.h \
	../../C++/TTSupport/TimeTableSystem.h ./../C++/TTSupport/Common.h \
	../../C++/TTSupport/PathName.h ../../C++/TTSupport/Station.h \
	../../C++/TTSupport/Train.h \
	../../C++/TTSupport/Cab.h \
	../../C++/TTSupport/End.h \
	Biblio.h
C_INTERNALS_PDF = CxxInternals.pdf
C_INTERNALS_LATEX = CxxInternals.tex
C_INTERNALS_LATEX_ENV = CxxInternals.texenv
C_INTERNALS = CxxInternals


TCL2TEX = $(TCLKIT) ../Support/tcl2tex.kit

#COMMON_TCL_INTERNALS = ../../Scripts/StdMenuBar.tcl
#TT_TCL_INTERNALS = ../../Scripts/TimeTable/mrrTimeTable.tcl ../../Scripts/TimeTable/MakeTimeTable.tcl

TCL_INTERNALS_PDF = TclInternals.pdf
COMMON_TCL_INTERNALS_LATEXSX = CTCPanel.tex \
				ReadConfiguration.tex BWStdMenuBar.tex
TT_TCL_INTERNALS_LATEXSX = #mrrTimeTable.tex MakeTimeTable.tex
TCL_INTERNALS_LATEXSX = $(COMMON_TCL_INTERNALS_LATEXSX) \
			$(TT_TCL_INTERNALS_LATEXSX)
TCL_INTERNALS_HERE = IntroTclInternals.tex common_part.tex #timetable_part.tex
TCL_INTERNALS_LATEXS = ../MyTitlepage.sty ../MyPart.sty \
	titlepage.tex $(TT_TCL_INTERNALS_LATEXSX) \
	$(COMMON_TCL_INTERNALS_LATEXSX) $(TCL_INTERNALS_HERE)
TCL_INTERNALS_LATEX = TclInternals.tex 
TCL_INTERNALS_IND = TclInternals.ind
TCL_INTERNALS_IDX = TclInternals.idx
TCL_INTERNALSBase = TclInternals

BIBLIO = ../MRR.bib

%.tex: %.tcl
	$(TCL2TEX) -forinput $@ $<

EXTRA_DIST = $(C_INTERNALS_H_HERE) $(TCL_INTERNALS_HERE) \
		$(C_INTERNALS_LATEX_ENV) docxx.sty $(TCL_INTERNALS_LATEX)

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

#pkgdata_DATA = $(C_INTERNALS_PDF) $(C_INTERNALS_PS) \
#	       $(C_INTERNALS_E_PS) $(C_INTERNALS_O_PS) \
#	       $(SWIG_INTERNALS_PDF) $(SWIG_INTERNALS_PS) \
#	       $(SWIG_INTERNALS_E_PS) $(SWIG_INTERNALS_O_PS) \
#	       $(TCL_INTERNALS_PDF) $(TCL_INTERNALS_PS) \
#	       $(TCL_INTERNALS_E_PS) $(TCL_INTERNALS_O_PS)
pkgdata_DATA = $(C_INTERNALS_PDF)  \
	       $(TCL_INTERNALS_PDF) 



titlepage.tex : ../titlepage.tex
	ln -s ../titlepage.tex ./titlepage.tex

$(C_INTERNALS_PDF) : $(C_INTERNALS_LATEX) docxx.sty $(BIBLIO) \
	../MyTitlepage.sty titlepage.tex # ../Cover1.ps
	$(PDFLATEX) $(C_INTERNALS_LATEX)
	-$(BIBTEX) $(C_INTERNALS)
	$(PDFLATEX) $(C_INTERNALS_LATEX)
	$(PDFLATEX) $(C_INTERNALS_LATEX)

$(C_INTERNALS_LATEX) : $(C_INTERNALS_H) $(C_INTERNALS_LATEX_ENV) Makefile
	$(DOCXX) -c -t -v -p -ef $(C_INTERNALS_LATEX_ENV) -l -o $(C_INTERNALS_LATEX) \
		$(C_INTERNALS_H_DOCORDER)
	echo '\end{document}' >>$(C_INTERNALS_LATEX)

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

StdMenuBar.tex : ../../Scripts/Common/StdMenuBar.tcl $(TCL2TEX)
	$(TCL2TEX) -forinput $@ $<

BWStdMenuBar.tex : ../../Scripts/Common/BWStdMenuBar.tcl $(TCL2TEX)
	$(TCL2TEX) -forinput $@ $<

CTCPanel.tex : ../../Scripts/Common/CTCPanel.tcl $(TCL2TEX)
	$(TCL2TEX) -forinput $@ $<

ReadConfiguration.tex : ../../Scripts/Common/ReadConfiguration.tcl $(TCL2TEX)
	$(TCL2TEX) -forinput $@ $<

mrrTimeTable.tex : ../../Scripts/TimeTable/mrrTimeTable.tcl $(TCL2TEX)
	$(TCL2TEX) -forinput $@ $<

MakeTimeTable.tex : ../../Scripts/TimeTable/MakeTimeTable.tcl $(TCL2TEX)
	$(TCL2TEX) -forinput $@ $<

