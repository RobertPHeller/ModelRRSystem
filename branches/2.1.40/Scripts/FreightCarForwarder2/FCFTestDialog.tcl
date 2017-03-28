#* 
#* ------------------------------------------------------------------
#* FCFTestDialog.tcl - Dialog test code
#* Created by Robert Heller on Wed Oct 17 09:57:08 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
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

package require FCFDialog

snit::type FCFTestDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent pfile
  typecomponent ptype

  typevariable printerTypes
  typeconstructor {
    set dialog [Dialog::create .testDialog \
		-bitmap questhead -default 0 \
		-cancel 1 -modal local -transient yes -parent . \
		-side bottom -title {Test Dialog}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    set pfile {}
    set ptype {}
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {} {
    BWidget::focus $pfile 1
    wm transient [winfo toplevel $dialog] .
    return [eval [list Dialog::draw $dialog]]
  }
  typemethod addpfile {} {
    if {[string equal "$pfile" {}]} {
      set frame [Dialog::getframe $dialog]
      set pfile [FileEntry::create $frame.pfile \
		-label {Print file:} -labelwidth 16 -filedialog save \
		-title {File to send printout to}]
      pack $pfile -fill x
    }
  }
  typemethod addpthpe {} {
    if {[string equal "$ptype" {}]} {
      set frame [Dialog::getframe $dialog]
      set printerTypes {}
      foreach p [info commands {*PrinterDevice}] {
	if {[string first _ $p] >= 0} {continue}
	set name {}
	regsub {PrinterDevice$} "$p" {} name
	if {[string equal "$name" {}]} {continue}
	lappend printerTypes $name
      }
      set ptype [LabelComboBox::create $frame.ptype \
		-label {Type of printer:} -labelwidth 16 \
		-values $printerTypes]
      pack $ptype -fill x
    }
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog Cancel]
  }
  typemethod _OK {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog OK]
  }
}

package provide FCFTestDialog 1.0
