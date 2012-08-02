#* 
#* ------------------------------------------------------------------
#* Makefile.am - User Doc Makefile
#* Created by Robert Heller on Fri Nov  4 13:43:37 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

TTUSERTEXS      = TimeTable/TimeTableUser.tex TimeTable/AddingNotes.tex \
		  TimeTable/AddingTrains.tex TimeTable/Install.tex \
		  TimeTable/PrintingATimetable.tex TimeTable/SettingUp.tex \
		  TimeTable/Introduction.tex TimeTable/MainGUI.tex \
		  TimeTable/CommandLineArgs.tex TimeTable/Files.tex
TTUSERFIGS      = TimeTable/getTimeDialog.ps TimeTable/getCabInfoDialog.ps \
		  TimeTable/getStationListDialog.ps \
		  TimeTable/getDuplicateTrackageDialog.ps \
		  TimeTable/getStorageTracksDialog.ps TimeTable/mrrTTMain.ps \
		  TimeTable/viewAllTrainsPopup.ps \
		  TimeTable/createNewTrainDialog.ps \
		  TimeTable/getTrainScheduleDialog.ps \
		  TimeTable/viewSingleTrainPopup.ps TimeTable/viewStations.ps \
		  TimeTable/viewAllNotes.ps TimeTable/createNewNote.ps \
		  TimeTable/deleteNote.ps TimeTable/editNote.ps \
		  TimeTable/addNoteToTrain.ps \
		  TimeTable/addNoteToTrainAtStation1.ps \
		  TimeTable/addNoteToTrainAtStation2.ps \
		  TimeTable/removeNoteFromTrain.ps \
		  TimeTable/removeNoteFromTrainAtStation2.ps \
		  TimeTable/removeNoteFromTrainAtStation1.ps \
		  TimeTable/getBasicTimeTableInfo.ps \
		  TimeTable/multipleTimeTableInfo.ps \
		  TimeTable/classGroupHeader.ps TimeTable/manualGroup.ps

USERMAN_TEXS = UserManual.tex $(TTUSERTEXS)
USERMAN_FIGS = $(TTUSERFIGS)
USERMAN = UserManual
USERMAN_DVI = $(USERMAN).dvi
USERMAN_PS = $(USERMAN).ps
USERMAN_PDF = $(USERMAN).pdf
USERMAN_E_DVI = $(USERMAN)_E.dvi
USERMAN_O_DVI = $(USERMAN)_O.dvi
USERMAN_E_PS = $(USERMAN)_E.ps
USERMAN_O_PS = $(USERMAN)_O.ps

BIBLIO = ../MRR.bib

EXTRA_DIST = $(USERMAN_TEXS) $(USERMAN_FIGS) 

pkgdatadir = $(datadir)/$(PACKAGE)/Doc

pkgdata_DATA = $(USERMAN_PS) $(USERMAN_PDF) #$(USERMAN_E_PS) $(USERMAN_O_PS)

%.tex: ../../Scripts/%.tcl
	$(TCL2TEX) -forinput $@ $<

%.pdf: %.ps
	$(PS2PDF) $< $@

titlepage.tex : ../titlepage.tex
	ln -s ../titlepage.tex ./titlepage.tex

$(USERMAN_PS) : $(USERMAN_DVI) $(USERMAN_FIGS)
	$(DVIPS) $(DVIPSFLAGS) $(USERMAN_DVI) -o $(USERMAN_PS)

$(USERMAN_E_PS) : $(USERMAN_E_DVI) $(USERMAN_FIGS)
	$(DVIPS) $(DVIPSFLAGS) $(USERMAN_E_DVI) -o $(USERMAN_E_PS)

$(USERMAN_O_PS) : $(USERMAN_O_DVI) $(USERMAN_FIGS)
	$(DVIPS) $(DVIPSFLAGS) $(USERMAN_O_DVI) -o $(USERMAN_O_PS)

$(USERMAN_E_DVI) : $(USERMAN_DVI)
	$(DVIDVI) $(EVENPAGES) $(USERMAN_DVI) $(USERMAN_E_DVI)

$(USERMAN_O_DVI) : $(USERMAN_DVI)
	$(DVIDVI) $(ODDPAGES) $(USERMAN_DVI) $(USERMAN_O_DVI)

$(USERMAN_DVI) : $(USERMAN_TEXS) $(USERMAN_FIGS) $(BIBLIO) \
	../MyTitlepage.sty ../MyPart.sty titlepage.tex # ../Cover1.ps
	$(LATEX) $(USERMAN)
	-$(BIBTEX) $(USERMAN)
	$(LATEX) $(USERMAN)
	$(LATEX) $(USERMAN)


