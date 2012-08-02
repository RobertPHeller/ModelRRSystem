#* 
#* ------------------------------------------------------------------
#* Makefile.am - Freight Car Forwarder V2 Help files
#* Created by Robert Heller on Tue Nov  1 18:52:48 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/10/22 17:17:27  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.6  2007/05/06 12:49:44  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.5  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.4  2007/02/02 00:52:01  heller
#* Modification History: Lock down for 2.1.7
#* Modification History:
#* Modification History: Revision 1.3  2007/02/01 20:58:49  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.2  2007/01/08 19:05:55  heller
#* Modification History: Jan 8, 2007 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/04/01 17:12:09  heller
#* Modification History: Lock Down APR012006
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:36  heller
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
#*  $Id$
#* 
HelpFiles = Reference.hh Tutorial.hh #MainGUI.hh
GIFFiles = TTMainGUIBlank.gif TTMainGUIToolBar.gif TTMainGUIButtonMenu.gif \
	   TTChart3station.gif TTCreateNewTrain1.gif TTCreateNewTrain2.gif \
	   TTCreateNewTrain3.gif TTEditNote.gif TTAddNote.gif \
	   TTPrintConfigurationDialog1.gif TTPrintConfigurationDialog2.gif \
	   TTPrintConfigurationDialog3.gif
CommonHelpFiles = Help.hh Copying.hh Warranty.hh Version.hh
HelpIndex = hh.index 
HelpIndexBuilder = $(top_srcdir)/BuildScripts/HelpIndexBuild.kit
IndexHHBuilder = $(top_srcdir)/BuildScripts/IndexHH.kit
IndexHH = index.hh

EXTRA_DIST = $(HelpFiles) $(GIFFiles) Version.text

BUILT_SOURCES = $(CommonHelpFiles)
noinst_DATA = $(HelpFiles) $(GIFFiles) $(HelpIndex) $(IndexHH) $(CommonHelpFiles)
DISTCLEAN = $(HelpIndex) $(IndexHH) $(CommonHelpFiles)


$(HelpIndex): $(HelpFiles) $(CommonHelpFiles)
	$(TCLKIT) $(HelpIndexBuilder) $(HelpIndex) $(HelpFiles) $(CommonHelpFiles)

$(IndexHH) : $(HelpIndex) $(CommonHelpFiles)
	$(TCLKIT) $(IndexHHBuilder) $(HelpIndex) $(IndexHH) $(CommonHelpFiles)

Version.hh: $(top_srcdir)/config.status Version.text
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakeVersionHelp.kit \
		'TT Support Library version' $(TTCLASSES_VERSIONLIB) \
		'System patch level' $(MRR_PATCH_LEVEL)
	cat Version.text >> Version.hh


Help.hh: ../Help.hh
	ln -s ../Help.hh Help.hh

Copying.hh: ../Copying.hh
	ln -s ../Copying.hh Copying.hh

Warranty.hh: ../Warranty.hh
	ln -s ../Warranty.hh Warranty.hh




../Copying.hh: ../../COPYING
	$(MAKE) -C .. Copying.hh

../Warranty.hh: ../../COPYING
	$(MAKE) -C ..Warranty.hh



