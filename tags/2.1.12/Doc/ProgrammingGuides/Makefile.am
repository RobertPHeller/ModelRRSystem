#* 
#* ------------------------------------------------------------------
#* Makefile.am - Programming guides makefile
#* Created by Robert Heller on Sun Apr 15 08:25:16 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.8  2007/11/30 13:56:50  heller
#* Modification History: Novemeber 30, 2007 lockdown.
#* Modification History:
#* Modification History: Revision 1.7  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.6  2007/05/06 22:46:56  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.2  2007/05/06 12:49:38  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.1  2007/04/19 17:23:22  heller
#* Modification History: April 19 Lock Down
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

SUFFIXES        = .tex .sty

SampleCodePackages = SampleCodeMain.tcl SampleCodeCTCPanel.tcl \
			SampleCodeRC.tcl SampleCodeSlideout.tcl \
			SampleCodeInstrumentPanel.tcl

PROGRAMMINGGUIDE = ProgrammingGuide
PROGRAMMINGGUIDE_TEXS = ../MyTitlepage.sty \
		titlepage.tex $(PROGRAMMINGGUIDE).tex Introduction.tex \
		RaildriverServer.tex CMRIProgramming.tex \
		XPressNetProgramming.tex BWHelp.tex CTCPanels.tex \
		ReadConfiguration.tex LabelFrameWidgets.tex SplashWindows.tex \
		MainWindows.tex GraphicsSupport.tex PanelInstruments.tex \
		OvalWidgets.tex LCARSWidgets.tex StarKitsStarPacks.tex
PROGRAMMINGGUIDE_FIGS = CTCPanel.png EditConf.png SplashScreen.png \
			MainWindow1.png MainWindow2.png
PROGRAMMINGGUIDE_DEPS = LocoTest.tcl SampleCode.tcl $(SampleCodePackages)
PROGRAMMINGGUIDE_PDF = $(PROGRAMMINGGUIDE).pdf
PROGRAMMINGGUIDEHBase = ProgrammingGuide
PROGRAMMINGGUIDE_HTML = $(PROGRAMMINGGUIDEHBase)/$(PROGRAMMINGGUIDE).html

EXTRA_DIST = $(PROGRAMMINGGUIDE_TEXS)  $(PROGRAMMINGGUIDE_FIGS)

pkgdatadir = $(datadir)/$(PACKAGE)/Doc


pkgdata_DATA = $(PROGRAMMINGGUIDE_PDF) SampleCode.tcl \
	$(SampleCodePackages)
#noinst_DATA = $(PROGRAMMINGGUIDE_HTML)

titlepage.tex : ../titlepage.tex
	ln -s ../titlepage.tex ./titlepage.tex

LocoTest.tcl : ../../C++/RailDriver/LocoTest
	ln -s ../../C++/RailDriver/LocoTest ./LocoTest.tcl

../../C++/RailDriver/LocoTest: ../../C++/RailDriver/LocoTest.src
	$(MAKE) -C ../../C++/RailDriver LocoTest

BIBLIO = ../MRR.bib

$(PROGRAMMINGGUIDE_PDF) : $(PROGRAMMINGGUIDE_TEXS) $(BIBLIO)  \
	$(PROGRAMMINGGUIDE_DEPS) $(PROGRAMMINGGUIDE_FIGS) # ../Cover1.ps
	$(PDFLATEX) $(PROGRAMMINGGUIDE)
	-$(BIBTEX) $(PROGRAMMINGGUIDE)
	echo '\begin{theindex}' > $(PROGRAMMINGGUIDE).ind
	echo '\item Dummy, 0' >> $(PROGRAMMINGGUIDE).ind
	echo '\end{theindex}' >> $(PROGRAMMINGGUIDE).ind
	$(PDFLATEX) $(PROGRAMMINGGUIDE)
	$(MAKEINDEX) $(PROGRAMMINGGUIDE).idx
	$(PDFLATEX) $(PROGRAMMINGGUIDE)

#$(PROGRAMMINGGUIDE_HTML) : $(PROGRAMMINGGUIDE_PDF)
#	-rm -rf $(PROGRAMMINGGUIDEHBase)
#	-mkdir $(PROGRAMMINGGUIDEHBase)
#	$(HTLATEX) $(PROGRAMMINGGUIDE) "html,2,info" "" \
#		"-d$(PROGRAMMINGGUIDEHBase)/"
#	(cd $(PROGRAMMINGGUIDEHBase)&&ln -s ../*.png ./)
#	-rm -f zz$(PROGRAMMINGGUIDE).p* $(PROGRAMMINGGUIDE).4ct \
#		$(PROGRAMMINGGUIDE).xref $(PROGRAMMINGGUIDE).4tc tex4ht.fls \
#		$(PROGRAMMINGGUIDE).tmp $(PROGRAMMINGGUIDE).lg \
#		$(PROGRAMMINGGUIDE).idv $(PROGRAMMINGGUIDE).dvi \
#		$(PROGRAMMINGGUIDE)*.html

SampleCodeScripts = $(top_builddir)/Scripts/Common/CTCPanel2.tcl \
		    $(top_builddir)/Scripts/Common/ReadConfiguration.tcl \
		    $(top_builddir)/Scripts/Common/DeepwoodsBanner.gif \
		    $(top_builddir)/Scripts/Common/open.gif \
		    $(top_builddir)/Scripts/Common/close.gif \
		    $(top_builddir)/Scripts/Common/save.gif \
		    $(top_builddir)/Scripts/Common/print.gif \
		    $(top_builddir)/Scripts/Common/BWStdMenuBar.tcl \
		    $(top_builddir)/Scripts/Common/BWHelp.tcl \
		    $(top_builddir)/Scripts/Common/panedw.tcl \
		    $(top_builddir)/Scripts/Common/splash.tcl \
		    $(top_builddir)/Scripts/Common/mainwindow.tcl \
		    $(top_builddir)/Scripts/Common/labelcombobox.tcl \
		    $(top_builddir)/Scripts/Common/labelspinbox.tcl \
		    $(top_builddir)/Scripts/Common/labelselectcolor.tcl \
		    $(top_builddir)/Scripts/Common/fileentry.tcl \
		    $(top_builddir)/Scripts/GRSupport/grsupport2.tcl \
		    $(top_builddir)/Scripts/GRSupport/Instruments2.tcl

SampleCodeHelpDep = $(top_builddir)/Help/hh.index \
		    $(top_builddir)/Help/index.hh
SampleCodeHelpFiles = $(top_builddir)/Help/hh.index \
		      $(top_builddir)/Help/*.hh

EXTRA_DIST += SampleCode.tcl $(SampleCodePackages)

SampleCode${EXEEXT}: SampleCode.tcl $(SampleCodeScripts) $(SampleCodeHelpDep) \
		SamplePkgIndex.tcl $(SampleCodePackages)
	-rm -rf SampleCode.vfs
	$(TCLKIT) $(SDX) qwrap SampleCode.tcl
	$(TCLKIT) $(SDX) unwrap SampleCode.kit
	-rm -rf SampleCode.kit
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit SampleCode \
		lib $(BWLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitDir.kit SampleCode \
		lib $(SNITLIB)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit SampleCode \
		lib/Common $(SampleCodeScripts)
	$(TCLKIT) $(top_builddir)/BuildScripts/MakePkgIndex.kit SampleCode \
		Common
	cat SamplePkgIndex.tcl >>SampleCode.vfs/lib/Common/pkgIndex.tcl
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit SampleCode \
		lib/Common $(SampleCodePackages)
	$(TCLKIT) $(top_builddir)/BuildScripts/AddKitFile.kit SampleCode \
		Help $(SampleCodeHelpFiles)
	$(TCLKIT) $(SDX) wrap SampleCode${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf SampleCode.vfs

$(top_builddir)/Help/hh.index : $(top_builddir)/Help/*.hh
	$(MAKE) -C $(top_builddir)/Help hh.index

$(top_builddir)/Help/index.hh : $(top_builddir)/Help/*.hh
	$(MAKE) -C $(top_builddir)/Help index.hh





#install-data-hook: $(PROGRAMMINGGUIDE_HTML)
#	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/$(PROGRAMMINGGUIDEHBase)
#	for p in $(PROGRAMMINGGUIDEHBase)/*; do \
#	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
#	  f=$(am__strip_dir) \
#	  echo " $(pkgdataDATA_INSTALL) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/$(PROGRAMMINGGUIDEHBase)$$f'"; \
#	  $(pkgdataDATA_INSTALL) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/$(PROGRAMMINGGUIDEHBase)/$$f"; \
#        done
	
#uninstall-hook: 
#	for p in $(DESTDIR)$(pkgdatadir)/$(PROGRAMMINGGUIDEHBase)/*; do \
#	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
#	  f=$(am__strip_dir) \
#	  echo " rm -f '$(DESTDIR)$(pkgdatadir)/$(PROGRAMMINGGUIDEHBase)$$f'"; \
#	  rm -f "$(DESTDIR)$(pkgdatadir)/$(PROGRAMMINGGUIDEHBase)/$$f"; \
#        done
	

