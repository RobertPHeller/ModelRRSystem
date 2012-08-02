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
			SampleCodeInstrumentPanel.tcl SampleCodeCircle.tcl

PROGRAMMINGGUIDE = ProgrammingGuide
PROGRAMMINGGUIDE_TEXS = ../MyTitlepage.sty \
		../titlepage.tex $(PROGRAMMINGGUIDE).tex Introduction.tex \
		RaildriverServer.tex CMRIProgramming.tex \
		XPressNetProgramming.tex BWHelp.tex CTCPanels.tex \
		ReadConfiguration.tex LabelFrameWidgets.tex SplashWindows.tex \
		MainWindows.tex GraphicsSupport.tex PanelInstruments.tex \
		OvalWidgets.tex LCARSWidgets.tex StarKitsStarPacks.tex
PROGRAMMINGGUIDE_FIGS = CTCPanel.png EditConf.png SplashScreen.png \
			MainWindow1.png MainWindow2.png Circles.png \
			PanelInstrument.png fig9-5.cc fig9-5.tcl \
			fig12-13.cc fig12-13.tcl fig14-5.cc fig14-5.tcl
PROGRAMMINGGUIDE_DEPS = ../../C++/RailDriver/LocoTest SampleCode.tcl \
		$(SampleCodePackages) Makefile.am
PROGRAMMINGGUIDE_PDF = $(PROGRAMMINGGUIDE).pdf
PROGRAMMINGGUIDEHBase = ProgrammingGuide
PROGRAMMINGGUIDE_HTML = $(PROGRAMMINGGUIDEHBase)/$(PROGRAMMINGGUIDE).html

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

CLEANFILES = LocoTest.tcl ProgrammingGuide.pdf *.aux *.bbl *.blg *.idx *.ilg \
	*.ind *.lof *.lot *.lol *.toc *.log titlepage.tex LocoTest.tcl MRR.bib \
	MyTitlepage.sty

pkgdata_DATA = $(PROGRAMMINGGUIDE_PDF) SampleCode.tcl \
	$(SampleCodePackages) fig9-5.cc fig9-5.tcl fig12-13.cc fig12-13.tcl \
	fig14-5.cc fig14-5.tcl
EXTRA_DIST = $(PROGRAMMINGGUIDE_TEXS)  $(PROGRAMMINGGUIDE_FIGS)

#noinst_DATA = $(PROGRAMMINGGUIDE_HTML)

../../C++/RailDriver/LocoTest: $(srcdir)/../../C++/RailDriver/LocoTest.src
	$(MAKE) -C ../../C++/RailDriver LocoTest

BIBLIO = ../MRR.bib

$(PROGRAMMINGGUIDE_PDF) : $(PROGRAMMINGGUIDE_TEXS) $(BIBLIO)  \
	$(PROGRAMMINGGUIDE_DEPS) $(PROGRAMMINGGUIDE_FIGS) # ../Cover1.ps
	-ln -s $(srcdir)../titlepage.tex ./titlepage.tex
	-ln -s $(srcdir)/$(BIBLIO) ./
	-ln -s $(srcdir)/../MyTitlepage.sty ./
	-ln -s ../../C++/RailDriver/LocoTest ./LocoTest.tcl
	for f in $(PROGRAMMINGGUIDE_TEXS) SampleCode.tcl $(SampleCodePackages) \
		 $(PROGRAMMINGGUIDE_FIGS) Makefile.am; do \
	  if test -f "./$$f"; then continue; else ln -s $(srcdir)/$$f ./; fi; \
	done
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

SampleCodeScripts = $(top_srcdir)/Scripts/Common/CTCPanel2.tcl \
		    $(top_srcdir)/Scripts/Common/ReadConfiguration.tcl \
		    $(top_srcdir)/Scripts/Common/DeepwoodsBanner.gif \
		    $(top_srcdir)/Scripts/Common/open.gif \
		    $(top_srcdir)/Scripts/Common/close.gif \
		    $(top_srcdir)/Scripts/Common/save.gif \
		    $(top_srcdir)/Scripts/Common/print.gif \
		    $(top_srcdir)/Scripts/Common/BWStdMenuBar.tcl \
		    $(top_srcdir)/Scripts/Common/BWHelp.tcl \
		    $(top_srcdir)/Scripts/Common/panedw.tcl \
		    $(top_srcdir)/Scripts/Common/splash.tcl \
		    $(top_srcdir)/Scripts/Common/mainwindow.tcl \
		    $(top_srcdir)/Scripts/Common/labelcombobox.tcl \
		    $(top_srcdir)/Scripts/Common/labelspinbox.tcl \
		    $(top_srcdir)/Scripts/Common/labelselectcolor.tcl \
		    $(top_srcdir)/Scripts/Common/fileentry.tcl \
		    $(top_srcdir)/Scripts/GRSupport/grsupport2.tcl \
		    $(top_srcdir)/Scripts/GRSupport/Instruments2.tcl

SampleCodeHelpDep = $(top_builddir)/Help/hh.index \
		    $(top_builddir)/Help/index.hh
SampleCodeHelpFiles = $(top_builddir)/Help/hh.index \
		      $(top_builddir)/Help/*.hh \
		      $(top_srcdir)/Help/*.hh

EXTRA_DIST += SampleCode.tcl $(SampleCodePackages)

SampleCode${EXEEXT}: SampleCode.tcl $(SampleCodeScripts) $(SampleCodeHelpDep) \
		SamplePkgIndex.tcl $(SampleCodePackages)
	-rm -rf SampleCode.kit
	-rm -rf SampleCode.vfs
	$(TCLKIT) $(SDX) qwrap $(srcdir)/SampleCode.tcl
	$(TCLKIT) $(SDX) unwrap SampleCode.kit
	-rm -rf SampleCode.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit SampleCode \
		lib $(BWLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit SampleCode \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SampleCode \
		lib/Common $(SampleCodeScripts)
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit SampleCode \
		Common
	cat SamplePkgIndex.tcl >>SampleCode.vfs/lib/Common/pkgIndex.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir) SampleCode \
		lib/Common $(SampleCodePackages)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit SampleCode \
		Help $(SampleCodeHelpFiles)
	$(TCLKIT) $(SDX) wrap SampleCode${EXEEXT} -runtime $(TCLKITRUN)
	-rm -rf SampleCode.vfs

$(top_builddir)/Help/hh.index : $(top_builddir)/Help/*.hh $(top_srcdir)/Help/*.hh
	$(MAKE) -C $(top_builddir)/Help hh.index

$(top_builddir)/Help/index.hh : $(top_builddir)/Help/*.hh $(top_srcdir)/Help/*.hh
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
	

