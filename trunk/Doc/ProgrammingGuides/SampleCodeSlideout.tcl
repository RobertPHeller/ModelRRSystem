#* 
#* ------------------------------------------------------------------
#* SampleCodeSlideout.tcl - Sample Code Slideout (misc LabelXxx widgets)
#* Created by Robert Heller on Wed Nov 28 08:41:28 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/11/30 13:56:50  heller
#* Modification History: Novemeber 30, 2007 lockdown.
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

# $Id$

package require LabelFrames;# Label<mumble> (LabelEntry, LabelSpinBox, LabelComboBox)

# Populate the sample slideout with various LabelEntry like
# Widgets.  These widgets all have a Label and some kind of 
# Entry-like widget for gathering some sort of user input.

namespace eval SampleCode {}
proc SampleCode::SampleCodeSlideout {} {
  variable Slideout

  # FileEntry widgets are used to get file and directory
  # names.  There are three types: old (existing) files,
  # generally for use as input files, new files for saving
  # information to, and directories (folders).
  #
  # First an old file:
  pack [FileEntry $Slideout.oldfile \
		-label "Old file:" -labelwidth 20\
		-filedialog open -defaultextension .text \
		-filetypes {
			{{Text Files} {.text .txt} TEXT}
			{{All Files}  *            }}] \
	-fill x
  # Second a new file:
  pack [FileEntry $Slideout.newfile \
		-label "New file:" -labelwidth 20\
		-filedialog save -defaultextension .text \
		-filetypes {
			{{Text Files} {.text .txt} TEXT}
			{{All Files}  *            }}] \
	-fill x
  # Finally, a directory:
  pack [FileEntry $Slideout.directory \
		-label "Directory:" -labelwidth 20\
		-filedialog directory] -fill x
  # A LabelComboBox would be used for selecting 
  # from a list of values.
  pack [LabelComboBox $Slideout.combo \
		-label "Pick one:" -labelwidth 20\
		-values {A B C D}] -fill x
  # A LabelSpinBox would be usually be used for 
  # selecting a number from a range.
  pack [LabelSpinBox $Slideout.spin \
		-label "Pick a value:" -labelwidth 20\
		-range {1 10 1}] -fill x
  # A LabelSelectColor would be used to select a
  # color.
  pack [LabelSelectColor $Slideout.color \
  		-label "Choose a color:" -labelwidth 20] \
	-fill x
}

package provide SampleCodeSlideout 1.0
