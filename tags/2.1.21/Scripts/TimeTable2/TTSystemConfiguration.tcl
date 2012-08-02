#* 
#* ------------------------------------------------------------------
#* TTSystemConfiguration.tcl - System Configuration Object
#* Created by Robert Heller on Sun Apr  2 12:22:40 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.4  2007/10/17 14:06:34  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.3  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.2  2006/05/22 17:01:12  heller
#* Modification History: Updated make install
#* Modification History:
#* Modification History: Revision 1.1  2006/05/18 16:46:09  heller
#* Modification History: *** empty log message ***
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

package require snit
package require ReadConfiguration
package require BWidget
package require BWFileEntry
package require BWLabelSpinBox

snit::type TimeTableConfiguration {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent _EditDialog
  typecomponent _PDFLaTeXFileEntry
  typecomponent _LabelWidthSpinBox
  typecomponent _MainWindowHeight
  typecomponent _MainWindowWidth
  typevariable _Configuration -array {}
  typeconstructor {
    global tcl_platform
    switch $tcl_platform(platform) {
      windows {
	set PDFLATEX "C:/Program Files/pdflatex.exe";# Guess
      }
      macintosh -
      unix {
	foreach pdflatex {/usr/bin/pdflatex /usr/local/bin/pdflatex /opt/bin/pdflatex pdflatex} {
	  set PDFLATEX [auto_execok $pdflatex]
	  if {![string equal "$PDFLATEX" {}]} {break}
	}
	if {[string equal "$PDFLATEX" {}]} {set PDFLATEX /usr/bin/pdflatex}
      }
    }

    set _Configuration(pdflatex) "$PDFLATEX"
    set _Configuration(chart:labelwidth) 100
    set _Configuration(mainwindow:height) 0
    set _Configuration(mainwindow:width) 0

    set _EditDialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$_EditDialog" {}] && 
	[winfo exists $_EditDialog]} {return}
    set _EditDialog [Dialog::create .editSystemConfiguration \
				-bitmap questhead \
				-title "Edit System Configuration" \
				-modal local \
				-transient yes \
				-default 0 -cancel 2 \
				-parent . -side bottom]
    $_EditDialog add -name ok -text OK -command [mytypemethod _OK]
    $_EditDialog add -name apply -text Apply -command [mytypemethod _Apply]
    $_EditDialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $_EditDialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $_EditDialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Edit System Configuration}]
    set frame [$_EditDialog  getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Edit System Configuration}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    global tcl_platform
    if {[string equal $tcl_platform(platform) "windows"]} {
      set exeExtension .exe
      set exeFiletypes {{{Executable Files} {.exe}}}
    } else {
      set exeExtension {}
      set exeFiletypes {{{Executable Files} {}}}
    }
    set _PDFLaTeXFileEntry [FileEntry $frame.pdfLaTeXfile \
		-labelwidth 21 \
		-label "Path to pdflatex:" \
		-defaultextension "$exeExtension" \
		-filetypes $exeFiletypes \
		-filedialog open \
		-title "PDFLaTeX Application Path" \
		-text "$_Configuration(pdflatex)"]
    pack $_PDFLaTeXFileEntry -fill x
    set _LabelWidthSpinBox [LabelSpinBox $frame.lwspinBox \
		-labelwidth 21 \
		-label "Label Width in Chart:" \
		-range [list 1 1024 1] \
		-text $_Configuration(chart:labelwidth)]
    pack $_LabelWidthSpinBox -fill x
    set _MainWindowHeight [LabelSpinBox $frame.mwheightsb \
		-labelwidth 21 \
		-label "Height of main window:" \
		-range [list 0 1024 1] \
		-text $_Configuration(mainwindow:height)]
    pack $_MainWindowHeight -fill x
    set _MainWindowWidth [LabelSpinBox $frame.mwwidsb \
		-labelwidth 21 \
		-label "Width of main window:" \
		-range [list 0 1280 1] \
		-text $_Configuration(mainwindow:width)]
    pack $_MainWindowWidth -fill x
  }

  typemethod read {filename} {
    # parray _Configuration
    ReadConfiguration::ReadConfiguration "$filename" [mytypevar _Configuration]
    # parray _Configuration
  }
  typemethod write {filename} {
    ReadConfiguration::WriteConfiguration "$filename" [mytypevar _Configuration]
  }
  typemethod edit {} {
    $type createDialog
    $type _UpdateDialog
    wm transient [winfo toplevel $_EditDialog] [$_EditDialog cget -parent]
    return [Dialog::draw $_EditDialog]
  }
  typemethod _UpdateDialog {} {
    $_PDFLaTeXFileEntry configure -text "$_Configuration(pdflatex)"
    $_LabelWidthSpinBox  configure -text $_Configuration(chart:labelwidth)
    $_MainWindowHeight configure -text $_Configuration(mainwindow:height)
    $_MainWindowWidth configure -text $_Configuration(mainwindow:width)
  }
  typemethod _OK {} {
    $type _Apply
    Dialog::withdraw $_EditDialog
    return [Dialog::enddialog $_EditDialog ok]
  }
  typemethod _Apply {} {
    set _Configuration(pdflatex)         "[$_PDFLaTeXFileEntry cget -text]"
    set _Configuration(chart:labelwidth)  [$_LabelWidthSpinBox cget -text]
    set _Configuration(mainwindow:height) [$_MainWindowHeight cget -text]
    set _Configuration(mainwindow:width)  [$_MainWindowWidth cget -text]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $_EditDialog
    return [Dialog::enddialog $_EditDialog cancel]
  }
  typemethod getkeyoption {name key} {
    if {[info exists _Configuration(${name}:${key})]} {
      return $_Configuration(${name}:${key})
    } else {
      error "No such keyed option: ${name}:${key}!"
    }
  }
  typemethod getoption {name} {
    if {[info exists _Configuration($name)]} {
      return $_Configuration($name)
    } else {
      error "No such option $name!"
    }
  }
  typemethod getanonoymous {} {
    if {[info exists _Configuration(_Anonoymous_)]} {
      return $_Configuration(_Anonoymous_)
    } else {
      error "No Anonoymous options!"
    }
  }
}



package provide TTSystemConfiguration 1.0
