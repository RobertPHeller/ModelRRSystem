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

USERMAN_MRD_TEST_PART = MRDTestPart.tex MRDTestReference.tex
MRD_TEST_TEXS = MRDTest.tex MRDTestReference.tex
MRD_TEST = MRDTest
MRD_TESTHBase = MRDTest
MRD_TEST_HTML = $(MRD_TESTHBase)/$(MRD_TEST).html
USERMAN_MRD_TEST_FIGS =

USERMAN_UNIVERSALTEST_PART = UniversalTestPart.tex UniversalTestReference.tex
UNIVERSALTEST_TEXS = UniversalTest.tex UniversalTestReference.tex
UNIVERSALTEST = UniversalTest
UNIVERSALTESTHBase = UniversalTest
UNIVERSALTEST_HTML = $(UNIVERSALTESTHBase)/$(UNIVERSALTEST).html
USERMAN_UNIVERSALTEST_FIGS = UTMain.png UTNewCard.png UTOutputTest.png \
		UTWrapAround.png

USERMAN_XPRESSNETTHROTTLE_PART = XPressNetThrottlePart.tex XPressNetThrottleReference.tex
XPRESSNETTHROTTLE_TEXS = XPressNetThrottle.tex  XPressNetThrottleReference.tex
XPRESSNETTHROTTLE = XPressNetThrottle
XPRESSNETTHROTTLEHBase = XPressNetThrottle
XPRESSNETTHROTTLE_HTML = $(XPRESSNETTHROTTLEHBase)/$(XPRESSNETTHROTTLE).html
USERMAN_XPRESSNETTHROTTLE_FIGS =

USERMAN_GENERICTHROTTLE_PART = GenericThrottlePart.tex GenericThrottleReference.tex
GENERICTHROTTLE_TEXS = GenericThrottle.tex  GenericThrottleReference.tex
GENERICTHROTTLE = GenericThrottle
GENERICTHROTTLEHBase = GenericThrottle
GENERICTHROTTLE_HTML = $(GENERICTHROTTLEHBase)/$(GENERICTHROTTLE).html
USERMAN_GENERICTHROTTLE_FIGS =

USERMAN_TIMETABLE_PART = TimeTablePart.tex TTTutorial.tex TTReference.tex
TIMETABLE_TEXS = TimeTable.tex TTTutorial.tex TTReference.tex
TIMETABLE = TimeTable
TIMETABLEHBase = TimeTable
TIMETABLE_HTML = $(TIMETABLEHBase)/$(TIMETABLE).html
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
FCF_TEXS = FCF.tex FCFTutorial.tex FCFReference.tex
FCF = FCF
FCFHBase = FCF
FCF_HTML = $(FCFHBase)/$(FCF).html
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
USERMAN_CALC_PART = CalcPart.tex  ResistorManual.tex LocoPullManual.tex
CALC_TEXS = Calc.tex ResistorManual.tex LocoPullManual.tex
CALC = Calc
CALCHBase = Calc
CALC_HTML = $(CALCHBase)/$(CALC).html
USERMAN_CALC_FIGS = RestMain.png LocoPullMain.png
USERMAN_CAMERA_PART = CameraPart.tex  CameraManual.tex
CAMERA_TEXS = Camera.tex CameraManual.tex
CAMERA = Camera
CAMERAHBase = Camera
CAMERA_HTML = $(CAMERAHBase)/$(CAMERA).html
USERMAN_CAMERA_FIGS = CameraAnyDist.png
USERMAN_DISPATCHER_PART = DispatcherPart.tex DispatcherTutorial.tex \
	DispatcherReference.tex DispatcherExamples.tex
DISPATCHER_TEXS = Dispatcher.tex DispatcherTutorial.tex \
	DispatcherReference.tex DispatcherExamples.tex
DISPATCHER = Dispatcher
DISPATCHERHBase = Dispatcher
DISPATCHER_HTML = $(DISPATCHERHBase)/$(DISPATCHER).html
USERMAN_DISPATCHER_FIGS = DISPNewCTCPanel.png DISPEmptyCTCPanel.png \
	DISPMainGUI.png DISPEditPanelOptions.png DISPExample1.png \
	DISPExample2.png DISPExample3.png DISPExample4.png \
	DISPAddEditCMR_INode.png DISPAddEditMRDNode.png \
	DISPSelectCMRINodeDialog.png \
	DISPSelectMRDNodeDialog.png DISPSimpleTutNewCTC.png \
	DISPSimpleTutBlankCTC.png DISPSimpleTutSw1.png \
	DISPSimpleTutSw1CrossHairs.png DISPSimpleTutPanel1.png \
	DISPSimpleTutSWPlate1.png DISPSimpleTutPanel2.png \
	DISPSimpleTutCB1.png DISPSimpleTutPanel3.png DISPSimpleTutPanel4.png \
	DISPAddEditPanelObject.png DISPEditUserCode.png DISPFindNodeDialog.png \
	DISPSelectPanelObject.png DISPPrintDialog.png DISPSelectCTCPanel.png

USERMAN_DISPATCHER_DEPS = example1.tcl example1.iow example2.tcl example2.iow \
	example3.tcl example3.iow example4.tcl example4.iow 
USERMAN_MAINPROGRAM_PART = #MainProgramPart.tex
MAINPROGRAM_TEXS = MainProgram.tex 
MAINPROGRAM = MainProgram
MAINPROGRAMHBase = MainProgram
MAINPROGRAM_HTML = $(MAINPROGRAMHBase)/$(MAINPROGRAM).html
USERMAN_MAINPROGRAM_FIGS =

USERMAN_TEXS = UserManual.tex Preface.tex Introduction.tex \
	$(USERMAN_UNIVERSALTEST_PART)  \
	$(USERMAN_XPRESSNETTHROTTLE_PART) $(USERMAN_GENERICTHROTTLE_PART) \
	$(USERMAN_TIMETABLE_PART) $(USERMAN_FCF_PART) $(USERMAN_CALC_PART) \
	$(USERMAN_CAMERA_PART) $(USERMAN_DISPATCHER_PART) \
	$(USERMAN_MAINPROGRAM_PART) $(USERMAN_MRD_TEST_PART) \
	$(USERMAN_XPRESSNETTHROTTLE_PART) Help.tex
USERMAN_FIGS = $(USERMAN_TIMETABLE_FIGS) $(USERMAN_FCF_FIGS) \
	$(USERMAN_CALC_FIGS) $(USERMAN_CAMERA_FIGS) $(USERMAN_DISPATCHER_FIGS) \
	$(USERMAN_MAINPROGRAM_FIGS) $(USERMAN_DISPATCHER_DEPS) \
	$(USERMAN_MRD_TEST_FIGS) $(USERMAN_UNIVERSALTEST_FIGS) \
	$(USERMAN_XPRESSNETTHROTTLE_FIGS) $(USERMAN_GENERICTHROTTLE_FIGS)
USERMAN = UserManual
USERMAN_PDF = $(USERMAN).pdf
USERMANHBase = UserManual
USERMAN_HTML = $(USERMANHBase)/$(USERMAN).html

BIBLIO = ../MRR.bib

EXTRA_DIST = $(USERMAN_TEXS) $(USERMAN_FIGS) $(TIMETABLE).tex $(FCF).tex \
	     $(CALC).tex $(CAMERA).tex $(DISPATCHER).tex COPYING.tex \
	     $(UNIVERSALTEST).tex $(MAINPROGRAM).tex $(MRD_TEST).tex \
	     $(XPRESSNETTHROTTLE_TEXS) $(GENERICTHROTTLE_TEXS)

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

pkgdata_DATA = $(USERMAN_PDF) Help.tex
noinst_DATA  = $(USERMAN_HTML) $(TIMETABLE_HTML) $(FCF_HTML) $(CALC_HTML) \
	       $(CAMERA_HTML) $(DISPATCHER_HTML) $(UNIVERSALTEST_HTML) \
	       $(MRDTEST_HTML)


CLEANFILES = *_Version.tex $(USERMAN_PDF) $(MRD_TEST).pdf $(UNIVERSALTEST).pdf \
		$(XPRESSNETTHROTTLE).pdf $(GENERICTHROTTLE).pdf \
		$(TIMETABLE).pdf $(FCF).pdf $(CALC).pdf $(CAMERA).pdf \
		$(DISPATCHER).pdf $(MAINPROGRAM).pdf *.aux *.bbl *.blg \
		*.idx *.ilg *.ind *.lof *.lot *.lol *.toc *.css *.log 

clean-local:
	-rm -rf $(MRD_TESTHBase) $(UNIVERSALTESTHBase) \
		$(XPRESSNETTHROTTLEHBase) $(GENERICTHROTTLEHBase) \
		$(TIMETABLEHBase) $(FCFHBase) $(CALCHBase) \
		$(CAMERAHBase) $(DISPATCHERHBase) $(MAINPROGRAMHBase) \
		$(USERMANHBase)

%.pdf: %.ps
	$(PS2PDF) $< $@

titlepage.tex : ../titlepage.tex
	ln -sf $(srcdir)/../titlepage.tex ./titlepage.tex

example1.tcl example1.iow example2.tcl example2.iow \
	example3.tcl example3.iow example4.tcl example4.iow : $(srcdir)/../../Scripts/Dispatcher/example[1234].tcl $(srcdir)/../../Scripts/Dispatcher/example[1234].iow
	for f in $(?F); do \
		if test -f "./$$f"; then continue; else ln -s $(srcdir)/../../Scripts/Dispatcher/$$f ./; fi; \
	done

$(USERMAN)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(USERMAN)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(USERMAN)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(USERMAN)_Version.tex
	echo "TT Support Library version is $(TTCLASSES_VERSIONLIB).\\\\" >>$(USERMAN)_Version.tex
	echo "FCF Support Library version is $(FCFCLASSES_VERSIONLIB).\\\\" >>$(USERMAN)_Version.tex
	echo "CMri Library version is $(CMRI_VERSIONLIB).\\\\" >>$(USERMAN)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(USERMAN)_Version.tex


$(USERMAN_PDF) : $(USERMAN_TEXS) $(USERMAN_FIGS) $(BIBLIO) \
	$(USERMAN)_Version.tex ../MyTitlepage.sty ../MyBibIndex.sty \
	../tips.sty \
	titlepage.tex COPYING.tex # ../Cover1.ps
	for f in $(USERMAN_TEXS) $(USERMAN_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	-ln -s $(srcdir)/../MyBibIndex.sty ./
	-ln -s $(srcdir)/../tips.sty ./
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

$(MRD_TEST)_Version.tex : $(top_builddir)/config.status 
	echo '\chapter*{Version}'               >$(MRD_TEST)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(MRD_TEST)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(MRD_TEST)_Version.tex
	echo "MRD Library version is $(MRD_VERSIONLIB).\\\\" >>$(MRD_TEST)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(MRD_TEST)_Version.tex

$(MRD_TEST).pdf : COPYING.tex $(MRD_TEST_TEXS) \
	$(USERMAN_MRD_TEST_FIGS) $(BIBLIO) \
	../MyTitlepage.sty titlepage.tex \
	$(MRD_TEST)_Version.tex Help.tex
	for f in $(MRD_TEST_TEXS) $(USERMAN_MRD_TEST_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(MRD_TEST)
	-$(BIBTEX) $(MRD_TEST)
	echo '\begin{theindex}' > $(MRD_TEST).ind
	echo '\item Dummy, 0' >> $(MRD_TEST).ind
	echo '\end{theindex}' >> $(MRD_TEST).ind
	$(PDFLATEX) $(MRD_TEST)
	$(MAKEINDEX) $(MRD_TEST).idx
	$(PDFLATEX) $(MRD_TEST)

$(MRD_TEST_HTML) : $(MRD_TEST).pdf
	-rm -rf $(MRD_TESTHBase)
	-mkdir $(MRD_TESTHBase)
	$(HTLATEX) $(MRD_TEST) "html,4,info" "" "-d$(MRD_TESTHBase)/"
	for f in $(USERMAN_MRD_TEST_FIGS); do \
	    (cd $(MRD_TESTHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(MRD_TEST).p* $(MRD_TEST).4ct $(MRD_TEST).xref \
		 $(MRD_TEST).4tc tex4ht.fls $(MRD_TEST).tmp $(MRD_TEST).lg \
		 $(MRD_TEST).idv $(MRD_TEST).dvi $(MRD_TEST)*.html
	

$(UNIVERSALTEST)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(UNIVERSALTEST)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(UNIVERSALTEST)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(UNIVERSALTEST)_Version.tex
	echo "CMri Library version is $(CMRI_VERSIONLIB).\\\\" >>$(UNIVERSALTEST)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(UNIVERSALTEST)_Version.tex

$(UNIVERSALTEST).pdf : COPYING.tex $(UNIVERSALTEST_TEXS) \
		    $(USERMAN_UNIVERSALTEST_FIGS) $(BIBLIO) \
		    ../MyTitlepage.sty titlepage.tex \
		    $(UNIVERSALTEST)_Version.tex Help.tex
	for f in $(UNIVERSALTEST_TEXS) $(USERMAN_UNIVERSALTEST_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(UNIVERSALTEST)
	-$(BIBTEX) $(UNIVERSALTEST)
	echo '\begin{theindex}' > $(UNIVERSALTEST).ind
	echo '\item Dummy, 0' >> $(UNIVERSALTEST).ind
	echo '\end{theindex}' >> $(UNIVERSALTEST).ind
	$(PDFLATEX) $(UNIVERSALTEST)
	$(MAKEINDEX) $(UNIVERSALTEST).idx
	$(PDFLATEX) $(UNIVERSALTEST)

$(UNIVERSALTEST_HTML) : $(UNIVERSALTEST).pdf
	-rm -rf $(UNIVERSALTESTHBase)
	-mkdir $(UNIVERSALTESTHBase)
	$(HTLATEX) $(UNIVERSALTEST) "html,4,info" "" "-d$(UNIVERSALTESTHBase)/"
	for f in $(USERMAN_UNIVERSALTEST_FIGS); do \
	   (cd $(UNIVERSALTESTHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(UNIVERSALTEST).p* $(UNIVERSALTEST).4ct $(UNIVERSALTEST).xref \
		 $(UNIVERSALTEST).4tc tex4ht.fls $(UNIVERSALTEST).tmp $(UNIVERSALTEST).lg \
		 $(UNIVERSALTEST).idv $(UNIVERSALTEST).dvi $(UNIVERSALTEST)*.html

$(XPRESSNETTHROTTLE)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(XPRESSNETTHROTTLE)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(XPRESSNETTHROTTLE)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(XPRESSNETTHROTTLE)_Version.tex
	echo "XPressNet Library version is $(XPRESSNET_VERSIONLIB).\\\\" >>$(XPRESSNETTHROTTLE)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(XPRESSNETTHROTTLE)_Version.tex

$(XPRESSNETTHROTTLE).pdf : COPYING.tex $(XPRESSNETTHROTTLE_TEXS) \
		    $(USERMAN_XPRESSNETTHROTTLE_FIGS) $(BIBLIO) \
		    ../MyTitlepage.sty titlepage.tex \
		    $(XPRESSNETTHROTTLE)_Version.tex Help.tex
	for f in $(XPRESSNETTHROTTLE_TEXS) $(USERMAN_XPRESSNETTHROTTLE_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(XPRESSNETTHROTTLE)
	-$(BIBTEX) $(XPRESSNETTHROTTLE)
	echo '\begin{theindex}' > $(XPRESSNETTHROTTLE).ind
	echo '\item Dummy, 0' >> $(XPRESSNETTHROTTLE).ind
	echo '\end{theindex}' >> $(XPRESSNETTHROTTLE).ind
	$(PDFLATEX) $(XPRESSNETTHROTTLE)
	$(MAKEINDEX) $(XPRESSNETTHROTTLE).idx
	$(PDFLATEX) $(XPRESSNETTHROTTLE)

$(XPRESSNETTHROTTLE_HTML) : $(XPRESSNETTHROTTLE).pdf
	-rm -rf $(XPRESSNETTHROTTLEHBase)
	-mkdir $(XPRESSNETTHROTTLEHBase)
	$(HTLATEX) $(XPRESSNETTHROTTLE) "html,4,info" "" "-d$(XPRESSNETTHROTTLEHBase)/"
	for f in $(USERMAN_XPRESSNETTHROTTLE_FIGS); do \
	   (cd $(XPRESSNETTHROTTLEHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(XPRESSNETTHROTTLE).p* $(XPRESSNETTHROTTLE).4ct $(XPRESSNETTHROTTLE).xref \
		 $(XPRESSNETTHROTTLE).4tc tex4ht.fls $(XPRESSNETTHROTTLE).tmp $(XPRESSNETTHROTTLE).lg \
		 $(XPRESSNETTHROTTLE).idv $(XPRESSNETTHROTTLE).dvi $(XPRESSNETTHROTTLE)*.html

$(GENERICTHROTTLE)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(GENERICTHROTTLE)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(GENERICTHROTTLE)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(GENERICTHROTTLE)_Version.tex
	echo "XPressNet Library version is $(XPRESSNET_VERSIONLIB).\\\\" >>$(GENERICTHROTTLE)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(GENERICTHROTTLE)_Version.tex

$(GENERICTHROTTLE).pdf : COPYING.tex $(GENERICTHROTTLE_TEXS) \
		    $(USERMAN_GENERICTHROTTLE_FIGS) $(BIBLIO) \
		    ../MyTitlepage.sty titlepage.tex \
		    $(GENERICTHROTTLE)_Version.tex Help.tex
	for f in $(GENERICTHROTTLE_TEXS) $(USERMAN_GENERICTHROTTLE_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(GENERICTHROTTLE)
	-$(BIBTEX) $(GENERICTHROTTLE)
	echo '\begin{theindex}' > $(GENERICTHROTTLE).ind
	echo '\item Dummy, 0' >> $(GENERICTHROTTLE).ind
	echo '\end{theindex}' >> $(GENERICTHROTTLE).ind
	$(PDFLATEX) $(GENERICTHROTTLE)
	$(MAKEINDEX) $(GENERICTHROTTLE).idx
	$(PDFLATEX) $(GENERICTHROTTLE)

$(GENERICTHROTTLE_HTML) : $(GENERICTHROTTLE).pdf
	-rm -rf $(GENERICTHROTTLEHBase)
	-mkdir $(GENERICTHROTTLEHBase)
	$(HTLATEX) $(GENERICTHROTTLE) "html,4,info" "" "-d$(GENERICTHROTTLEHBase)/"
	for f in $(USERMAN_GENERICTHROTTLE_FIGS); do \
	   (cd $(GENERICTHROTTLEHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(GENERICTHROTTLE).p* $(GENERICTHROTTLE).4ct $(GENERICTHROTTLE).xref \
		 $(GENERICTHROTTLE).4tc tex4ht.fls $(GENERICTHROTTLE).tmp $(GENERICTHROTTLE).lg \
		 $(GENERICTHROTTLE).idv $(GENERICTHROTTLE).dvi $(GENERICTHROTTLE)*.html

$(TIMETABLE)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(TIMETABLE)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(TIMETABLE)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(TIMETABLE)_Version.tex
	echo "TT Support Library version is $(TTCLASSES_VERSIONLIB).\\\\" >>$(TIMETABLE)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(TIMETABLE)_Version.tex


$(TIMETABLE).pdf : COPYING.tex $(TIMETABLE_TEXS) $(TIMETABLE)_Version.tex \
		    $(USERMAN_TIMETABLE_FIGS) $(BIBLIO) \
		    ../MyTitlepage.sty titlepage.tex Help.tex
	for f in $(TIMETABLE_TEXS) $(USERMAN_TIMETABLE_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(TIMETABLE)
	-$(BIBTEX) $(TIMETABLE)
	echo '\begin{theindex}' > $(TIMETABLE).ind
	echo '\item Dummy, 0' >> $(TIMETABLE).ind
	echo '\end{theindex}' >> $(TIMETABLE).ind
	$(PDFLATEX) $(TIMETABLE)
	$(MAKEINDEX) $(TIMETABLE).idx
	$(PDFLATEX) $(TIMETABLE)

$(TIMETABLE_HTML) : $(TIMETABLE).pdf
	-rm -rf $(TIMETABLEHBase)
	-mkdir $(TIMETABLEHBase)
	$(HTLATEX) $(TIMETABLE) "html,4,info" "" "-d$(TIMETABLEHBase)/"
	for f in $(USERMAN_TIMETABLE_FIGS); do \
	   (cd $(TIMETABLEHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(TIMETABLE).p* $(TIMETABLE).4ct $(TIMETABLE).xref \
		 $(TIMETABLE).4tc tex4ht.fls $(TIMETABLE).tmp $(TIMETABLE).lg \
		 $(TIMETABLE).idv $(TIMETABLE).dvi $(TIMETABLE)*.html

$(FCF)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(FCF)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(FCF)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(FCF)_Version.tex
	echo "FCF Support Library version is $(FCFCLASSES_VERSIONLIB).\\\\" >>$(FCF)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(FCF)_Version.tex


$(FCF).pdf : COPYING.tex $(FCF_TEXS) $(USERMAN_FCF_FIGS) $(BIBLIO) \
		    ../MyTitlepage.sty titlepage.tex  \
		    $(FCF)_Version.tex Help.tex
	for f in $(FCF_TEXS) $(USERMAN_FCF_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(FCF)
	-$(BIBTEX) $(FCF)
	echo '\begin{theindex}' > $(FCF).ind
	echo '\item Dummy, 0' >> $(FCF).ind
	echo '\end{theindex}' >> $(FCF).ind
	$(PDFLATEX) $(FCF)
	$(MAKEINDEX) $(FCF).idx
	$(PDFLATEX) $(FCF)

$(FCF_HTML) : $(FCF).pdf
	-rm -rf $(FCFHBase)
	-mkdir $(FCFHBase)
	$(HTLATEX) $(FCF) "html,4,info" "" "-d$(FCFHBase)/"
	for f in $(USERMAN_FCF_FIGS); do \
	   (cd $(FCFHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(FCF).p* $(FCF).4ct $(FCF).xref \
		 $(FCF).4tc tex4ht.fls $(FCF).tmp $(FCF).lg \
		 $(FCF).idv $(FCF).dvi $(FCF)*.html

$(CALC)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(CALC)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(CALC)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(CALC)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(CALC)_Version.tex


$(CALC).pdf : COPYING.tex $(CALC_TEXS) $(USERMAN_CALC_FIGS) \
		$(BIBLIO) ../MyTitlepage.sty titlepage.tex \
		$(CALC)_Version.tex Help.tex
	for f in $(CALC_TEXS) $(USERMAN_CALC_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(CALC)
	-$(BIBTEX) $(CALC)
	echo '\begin{theindex}' > $(CALC).ind
	echo '\item Dummy, 0' >> $(CALC).ind
	echo '\end{theindex}' >> $(CALC).ind
	$(PDFLATEX) $(CALC)
	$(MAKEINDEX) $(CALC).idx
	$(PDFLATEX) $(CALC)

$(CALC_HTML) : $(CALC).pdf
	-rm -rf $(CALCHBase)
	-mkdir $(CALCHBase)
	$(HTLATEX) $(CALC) "html,4,info" "" "-d$(CALCHBase)/"
	for f in $(USERMAN_CALC_FIGS); do \
	   (cd $(CALCHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(CALC).p* $(CALC).4ct $(CALC).xref \
		 $(CALC).4tc tex4ht.fls $(CALC).tmp $(CALC).lg \
		 $(CALC).idv $(CALC).dvi $(CALC)*.html

$(CAMERA)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(CAMERA)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(CAMERA)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(CAMERA)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(CAMERA)_Version.tex

$(CAMERA).pdf : COPYING.tex $(CAMERA_TEXS) $(CAMERA)_Version.tex \
		$(USERMAN_CAMERA_FIGS) $(BIBLIO) ../MyTitlepage.sty \
		titlepage.tex Help.tex
	for f in $(CAMERA_TEXS) $(USERMAN_CAMERA_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(CAMERA)
	-$(BIBTEX) $(CAMERA)
	echo '\begin{theindex}' > $(CAMERA).ind
	echo '\item Dummy, 0' >> $(CAMERA).ind
	echo '\end{theindex}' >> $(CAMERA).ind
	$(PDFLATEX) $(CAMERA)
	$(MAKEINDEX) $(CAMERA).idx
	$(PDFLATEX) $(CAMERA)

$(CAMERA_HTML) : $(CAMERA).pdf
	-rm -rf $(CAMERAHBase)
	-mkdir $(CAMERAHBase)
	$(HTLATEX) $(CAMERA) "html,4,info" "" "-d$(CAMERAHBase)/"
	for f in $(USERMAN_CAMERA_FIGS); do \
	   (cd $(CAMERAHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(CAMERA).p* $(CAMERA).4ct $(CAMERA).xref \
		 $(CAMERA).4tc tex4ht.fls $(CAMERA).tmp $(CAMERA).lg \
		 $(CAMERA).idv $(CAMERA).dvi $(CAMERA)*.html

$(DISPATCHER)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(DISPATCHER)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(DISPATCHER)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(DISPATCHER)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(DISPATCHER)_Version.tex

$(DISPATCHER).pdf : COPYING.tex $(DISPATCHER_TEXS) $(DISPATCHER)_Version.tex \
			$(USERMAN_DISPATCHER_FIGS) $(BIBLIO) \
			../MyTitlepage.sty ../tips.sty titlepage.tex \
			$(USERMAN_DISPATCHER_DEPS) Help.tex
	for f in $(DISPATCHER_TEXS) $(USERMAN_DISPATCHER_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	-ln -s $(srcdir)/../tips.sty ./
	$(PDFLATEX) $(DISPATCHER)
	-$(BIBTEX) $(DISPATCHER)
	echo '\begin{theindex}' > $(DISPATCHER).ind
	echo '\item Dummy, 0' >> $(DISPATCHER).ind
	echo '\end{theindex}' >> $(DISPATCHER).ind
	$(PDFLATEX) $(DISPATCHER)
	$(MAKEINDEX) $(DISPATCHER).idx
	$(PDFLATEX) $(DISPATCHER)

$(DISPATCHER_HTML) : $(DISPATCHER).pdf 
	-rm -rf $(DISPATCHERHBase)
	-mkdir $(DISPATCHERHBase)
	$(HTLATEX) $(DISPATCHER) "html,4,info" "" "-d$(DISPATCHERHBase)/"
	for f in $(USERMAN_DISPATCHER_FIGS); do \
	   (cd $(DISPATCHERHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(DISPATCHER).p* $(DISPATCHER).4ct $(DISPATCHER).xref \
		 $(DISPATCHER).4tc tex4ht.fls $(DISPATCHER).tmp $(DISPATCHER).lg \
		 $(DISPATCHER).idv $(DISPATCHER).dvi $(DISPATCHER)*.html

$(MAINPROGRAM)_Version.tex : $(top_builddir)/config.status
	echo '\chapter*{Version}'               >$(MAINPROGRAM)_Version.tex
	echo '\addcontentsline{toc}{chapter}{Version}' \
						>>$(MAINPROGRAM)_Version.tex
	echo '\markboth{Version}{Version}' 	>>$(MAINPROGRAM)_Version.tex
	echo "System patch level is $(MRR_PATCH_LEVEL).\\\\" >>$(MAINPROGRAM)_Version.tex

$(MAINPROGRAM).pdf : COPYING.tex $(MAINPROGRAM_TEXS) $(MAINPROGRAM)_Version.tex \
			$(USERMAN_MAINPROGRAM_FIGS) $(BIBLIO) \
		    ../MyTitlepage.sty titlepage.tex Help.tex
	for f in $(MAINPROGRAM_TEXS) $(USERMAN_MAINPROGRAM_FIGS); do \
	    if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
	-ln -s $(srcdir)/COPYING.tex ./
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	$(PDFLATEX) $(MAINPROGRAM)
	-$(BIBTEX) $(MAINPROGRAM)
	echo '\begin{theindex}' > $(MAINPROGRAM).ind
	echo '\item Dummy, 0' >> $(MAINPROGRAM).ind
	echo '\end{theindex}' >> $(MAINPROGRAM).ind
	$(PDFLATEX) $(MAINPROGRAM)
	$(MAKEINDEX) $(MAINPROGRAM).idx
	$(PDFLATEX) $(MAINPROGRAM)

$(MAINPROGRAM_HTML) : $(MAINPROGRAM).pdf
	-rm -rf $(MAINPROGRAMHBase)
	-mkdir $(MAINPROGRAMHBase)
	$(HTLATEX) $(MAINPROGRAM) "html,4,info" "" "-d$(MAINPROGRAMHBase)/"
	for f in $(USERMAN_MAINPROGRAM_FIGS); do \
	   (cd $(MAINPROGRAMHBase)&&ln -s ../$$f ./) \
	done
	-rm -f zz$(MAINPROGRAM).p* $(MAINPROGRAM).4ct $(MAINPROGRAM).xref \
		 $(MAINPROGRAM).4tc tex4ht.fls $(MAINPROGRAM).tmp $(MAINPROGRAM).lg \
		 $(MAINPROGRAM).idv $(MAINPROGRAM).dvi $(MAINPROGRAM)*.html

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
	

