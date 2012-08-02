#* 
#* ------------------------------------------------------------------
#* Makefile.am - User Doc Makefile
#* Created by Robert Heller on Fri Nov  4 13:43:37 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/05/06 15:15:26  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.6  2007/05/06 14:23:39  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.5  2007/05/06 12:49:40  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.4  2007/02/01 20:58:49  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/01/03 15:30:21  heller
#* Modification History: Lockdown
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
DVIPSFLAGS	= -t letter
#GUPDVIPSFLAGS   = -P GUP -x 823 -t GUP
ODDPAGES = 2:0
EVENPAGES = 2:-1

USERMAN_TIMETABLE_PART = TimeTablePart.tex TTTutorial.tex TTReference.tex
USERMAN_TIMETABLE_FIGS = TTaddtrain.png TTprintTool.png TTNewTool.png \
	TTMainGUIBlank.png TTMainGUIToolBar.png TTMainGUIButtonMenu.png \
	TTCreateNewTT.png TTCreateAllStations.png TTCreateAllCabs.png \
	TTChart3station.png TTOpenTool.png TTSaveTool.png \
	TTCreateNewTrain1.png  TTCreateNewTrain2.png  TTCreateNewTrain3.png \
	TTdeletetrain.png TTsetdupstation.png TTcleardupstation.png \
	TTaddstorage.png TTaddcab.png TTcreatenote.png TTeditnote.png \
	TTEditNote.png TTAddNote.png TTaddnotetotrainatstation.png \
	TTaddnotetotrain.png TTremovenotefromtrainatstation.png \
	TTremovenotefromtrain.png TTPrintTimetableDialog.png \
	TTPrintConfigurationDialog1.png TTPrintConfigurationDialog2.png \
	TTPrintConfigurationDialog3.png TTCloseTool.png TTSelectOneTrain.png
USERMAN_FCF_PART = FCFPart.tex  FCFTutorial.tex FCFReference.tex
USERMAN_FCF_FIGS = FCFMain.png FCFMainButtonMenu.png FCFMainIndicators.png \
	FCFMainToolbar.png FCFLoadTool.png FCFLoadCarsTool.png \
	FCFSaveCarsTool.png FCFManageTrainsTool.png FCFViewCarTool.png \
	FCFViewCarInd.png FCFEditCarInd.png   FCFEditCarTool.png \
	FCFAddCarTool.png FCFDeleteCarTool.png FCFShowUACarsTool.png \
	FCFRunCarATool.png FCFRunAllTrTool.png FCFRunBTrTool.png \
	FCFRunTrInd.png  FCFPrinterInd.png FCFRun1TrTool.png \
	FCFOpenPrinterTool.png FCFClosePrinterTool.png FCFPrintYardTool.png \
	FCFShowCarsTool.png FCFReportsTool.png FCFResetStatsTool.png \
	FCFCloseTool.png FCFManageTrainsMenu.png FCFControlYardLDialog.png  \
	FCFManage1TrainDialog.png FCFViewCarSlideout.png \
	FCFEditCarSlideout.png FCFTrainStatusSlideout.png  \
	FCFOpenPrinterDialog.png FCFShowCarsMenu.png FCFSelectATrainDialog.png \
	FCFSelectACarDialog.png FCFReportsMenu.png
USERMAN_CALC_PART = CalcPart.tex  ResistorManual.tex
USERMAN_CALC_FIGS = RestMain.png
USERMAN_CAMERA_PART = CameraPart.tex  CameraManual.tex
USERMAN_CAMERA_FIGS = CameraAnyDist.png
USERMAN_DISPATCHER_PART = DispatcherPart.tex DispatcherTutorial.tex \
	DispatcherReference.tex DispatcherExamples.tex
USERMAN_DISPATCHER_FIGS = DISPNewCTCPanel.png DISPEmptyCTCPanel.png \
	DISPMainGUI.png DISPEditPanelOptions.png DISPExample1.png \
	DISPExample2.png DISPExample3.png DISPExample4.png
USERMAN_DISPATCHER_DEPS = example1.tcl example1.iow example2.tcl example2.iow \
	example3.tcl example3.iow example4.tcl example4.iow 
USERMAN_MAINPROGRAM_PART = #MainProgramPart.tex
USERMAN_MAINPROGRAM_FIGS =
USERMAN_TEXS = UserManual.tex Preface.tex Introduction.tex \
	$(USERMAN_TIMETABLE_PART) $(USERMAN_FCF_PART) $(USERMAN_CALC_PART) \
	$(USERMAN_CAMERA_PART) $(USERMAN_DISPATCHER_PART) \
	$(USERMAN_MAINPROGRAM_PART)
USERMAN_FIGS = $(USERMAN_TIMETABLE_FIGS) $(USERMAN_FCF_FIGS) \
	$(USERMAN_CALC_FIGS) $(USERMAN_CAMERA_FIGS) $(USERMAN_DISPATCHER_FIGS) \
	$(USERMAN_MAINPROGRAM_FIGS) $(USERMAN_DISPATCHER_DEPS)
USERMAN = UserManual
USERMAN_PDF = $(USERMAN).pdf
USERMANHBase = UserManual
USERMAN_HTML = $(USERMANHBase)/$(USERMAN).html

BIBLIO = ../MRR.bib

EXTRA_DIST = $(USERMAN_TEXS) $(USERMAN_FIGS) 

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

pkgdata_DATA = $(USERMAN_PDF)
noinst_DATA  = $(USERMAN_HTML)

CLEANFILES = UserManual.pdf *.aux *.bbl *.blg *.idx *.ilg \
	*.ind *.lof *.lot *.lol *.toc *.css UserManual

%.pdf: %.ps
	$(PS2PDF) $< $@

titlepage.tex : ../titlepage.tex
	ln -s $(srcdir)/../titlepage.tex ./titlepage.tex

example1.tcl example1.iow example2.tcl example2.iow \
	example3.tcl example3.iow example4.tcl example4.iow : $(srcdir)/../../Scripts/Dispatcher/example[1234].tcl $(srcdir)/../../Scripts/Dispatcher/example[1234].iow
	for f in $(?F); do \
		if test -f "./$$f"; then continue; else ln -s $(srcdir)/../../Scripts/Dispatcher/$$f ./; fi; \
	done

$(USERMAN_PDF) : $(USERMAN_TEXS) $(USERMAN_FIGS) $(BIBLIO) \
	../MyTitlepage.sty ../MyBibIndex.sty titlepage.tex $(USERMAN_DEPS) # ../Cover1.ps
	for f in $(USERMAN_TEXS) $(USERMAN_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	-ln -s $(srcdir)/../MyBibIndex.sty ./
	$(PDFLATEX) $(USERMAN)
	-$(BIBTEX) $(USERMAN)
	echo '\begin{theindex}' > $(USERMAN).ind
	echo '\item Dummy, 0' >> $(USERMAN).ind
	echo '\end{theindex}' >> $(USERMAN).ind
	$(PDFLATEX) $(USERMAN)
	$(MAKEINDEX) $(USERMAN).idx
	$(PDFLATEX) $(USERMAN)

$(USERMAN_HTML) : $(USERMAN_PDF)
	-rm -rf $(USERMANHBase)
	-mkdir $(USERMANHBase)
	$(HTLATEX) $(USERMAN) "html,2,info" "" "-d$(USERMANHBase)/"
	(cd $(USERMANHBase)&&ln -s ../*.png ./)
	-rm -f zz$(USERMAN).p* $(USERMAN).4ct $(USERMAN).xref \
		 $(USERMAN).4tc tex4ht.fls $(USERMAN).tmp $(USERMAN).lg \
		 $(USERMAN).idv $(USERMAN).dvi $(USERMAN)*.html


install-data-hook: $(USERMAN_HTML)
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/$(USERMANHBase)
	for p in $(USERMANHBase)/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=$(am__strip_dir) \
	  echo " $(pkgdataDATA_INSTALL) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$(USERMANHBase)$$f'"; \
	  $(pkgdataDATA_INSTALL) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/$(USERMANHBase)/$$f"; \
	done
	
uninstall-hook: 
	for p in $(DESTDIR)$(pkgdatadir)/$(USERMANHBase)/*; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=$(am__strip_dir) \
	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/$(USERMANHBase)$$f'"; \
	  rm -f "$(DESTDIR)$(pkgdatadir)/$(USERMANHBase)/$$f"; \
	done
	

