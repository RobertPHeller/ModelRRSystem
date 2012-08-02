#* 
#* ------------------------------------------------------------------
#* FCFPrinters.tcl - Printing functions
#* Created by Robert Heller on Sun Oct 30 13:49:41 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.6  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.5  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.4  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.3  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.2  2005/11/20 09:46:33  heller
#* Modification History: Nov. 20, 2005 Lockdown
#* Modification History:
#* Modification History: Revision 1.1  2005/11/04 19:06:38  heller
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

# $Id$

package require gettext
package require Tk
package require BWidget
package require BWFileEntry
package require BWLabelSpinBox
package require BWLabelComboBox
package require snit

SplashWorkMessage "Loading Printer code" 60

snit::type OpenPrinterDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent pfile
  typecomponent ptype

  typevariable printerTypes
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .openPrinterDialog \
		-bitmap questhead -default 0 \
		-cancel 1 -modal local -transient yes -parent . \
		-side bottom -title [_ "Open Printer"]]
    $dialog add -name ok -text [_m "Button|OK"] -command [mytypemethod _Openit]
    $dialog add -name cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancelit]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancelit]
    $dialog add -name help -text [_m "Button|Help"] \
		-command [list HTMLHelp::HTMLHelp help {Open Printer Dialog}]
    set frame [Dialog::getframe $dialog]
    set lwidth [_mx "Label|Print file:" "Label|Type of printer:"]
    set pfile [FileEntry::create $frame.pfile \
		-label [_m "Label|Print file:"] -labelwidth $lwidth -filedialog save \
		-title [_ "File to send printout to"]]
    pack $pfile -fill x
    set printerTypes {}
    foreach p [info commands {*PrinterDevice}] {
      if {[string first _ $p] >= 0} {continue}
      set name {}
      regsub {PrinterDevice$} "$p" {} name
      if {[string equal "$name" {}]} {continue}
      lappend printerTypes $name
    }
    set ptype [LabelComboBox::create $frame.ptype \
		-label [_m "Label|Type of printer:"] -labelwidth $lwidth \
		-values $printerTypes]
    pack $ptype -fill x
    wm transient [winfo toplevel $dialog] .
  }
  typemethod draw {} {
    $type createDialog
    BWidget::focus $pfile 1
    wm transient [winfo toplevel $dialog] .
    return [eval [list Dialog::draw $dialog]]
  }
  typemethod _Cancelit {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog Cancel]
  }
  typemethod _Openit {} {
    Dialog::withdraw $dialog
    set prfile [$pfile cget -text]
    set printer [$ptype cget -text]
    set printerCommand "${printer}PrinterDevice"
#    catch "$printerCommand" message
    if {[llength [info commands TheSystem]] == 0} {
      set title [_ "Print lists for Unknown Railroad."]
    } else {
      set title [_ "Print lists for %s." [TheSystem SystemName]]
    }
    $printerCommand Printer "$prfile" "$title"
    global PrinterIndicator
    $PrinterIndicator configure -image PrintImage
    return [Dialog::enddialog $dialog OK]
  }
}

proc OpenPrinter {} {

  OpenPrinterDialog draw
}

proc ClosePrinter {} {
  if {[llength [info commands Printer]] > 0} {
    if {![Printer IsOpenP]} {
      tk_messageBox -icon warning -type ok -message [_ "Printer is not open."]
      rename Printer {}
    } else {
      Printer ClosePrinter
      rename Printer {}
      tk_messageBox -icon info -type ok -message [_ "Printer is closed."]
    }
  } else {
    tk_messageBox -icon warning -type ok -message [_ "Printer is not open."]
  }
  global PrinterIndicator
  $PrinterIndicator configure -image ClosePrintImage
}

proc PrintYardLists {} {
  if {[llength [info commands TheSystem]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please load a system first."]
    return
  }
  if {[llength [info commands Printer]] == 0} {
    tk_messageBox -icon error -type ok -message [_ "Please open a printer first."]
    return
  }
  if {![TheSystem RanAllTrains]} {
    tk_messageBox -icon error -type ok -message [_ "Please Run the trains first."]
    return
  }
  TheSystem PrintAllLists [Log cget -this] [Banner cget -this] \
			  [Printer cget -this]
}



package provide FCFPrinters 1.0
