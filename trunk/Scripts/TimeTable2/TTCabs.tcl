#* 
#* ------------------------------------------------------------------
#* TTCabs.tcl - Cab related code
#* Created by Robert Heller on Sat Apr  1 23:05:07 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.4  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.3  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.2  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.1  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
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

namespace eval TimeTable {}

catch {TimeTable::SplashWorkMessage [_ "Loading Cab Code"] 66}

package require gettext
package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames
package require ScrollWindow
package require ListBox

snit::type TimeTable::createAllCabsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent _MainDialog
  typecomponent _CabList
  typecomponent _AddOneCab
  typeconstructor {
    set _MainDialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$_MainDialog" {}] && 
	[winfo exists $_MainDialog]} {return}
    set _MainDialog [Dialog .createAllCabsDialog \
			-bitmap questhead \
			-title [_ "Create All Cabs"] \
			-modal local \
			-transient yes \
			-default 0 -cancel 1 \
			-parent . -side bottom]
    $_MainDialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $_MainDialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $_MainDialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $_MainDialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Create All Cabs Dialog}]
    set frame [$_MainDialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Create All Cabs}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set clScrollerFrame [ttk::labelframe $frame.clScrollerFrame \
			-text [_m "Label|Cabs:"] -labelanchor n]
    pack $clScrollerFrame -expand yes -fill both
    set clScroller [ScrolledWindow \
			$clScrollerFrame.clScroller \
			-auto both -scrollbar both]
    pack $clScroller -expand yes -fill both
    set _CabList [ListBox $clScroller.cabs]
    pack $_CabList -expand yes -fill both
    $clScroller setwidget $_CabList
    set add1CabFrame [ttk::labelframe $frame.add1CabFrame \
				-text [_m "Label|Add Cab:"] -labelanchor n]
    pack $add1CabFrame -fill x
    set _AddOneCab $add1CabFrame
    set lwidth [_mx "Label|Name:" "Label|Color:"]
    pack [LabelEntry $_AddOneCab.name \
			-label [_m "Label|Name:"] -labelwidth $lwidth] -fill x
    $_AddOneCab.name bind <Return> "[list $_AddOneCab.addit invoke];break"
    pack [LabelFrame $_AddOneCab.color \
			-text [_m "Label|Color:"] -width $lwidth] -fill x
    set f [$_AddOneCab.color getframe]
    pack [ttk::entry $f.e] -expand yes -fill x -side left
    $f.e insert end black
    bind $f.e <Return> "[list $_AddOneCab.addit invoke];break"
    pack [ttk::button $f.b -text [_m "Button|Select"] \
			      -command [mytypemethod _SelectCabColor]] \
	 -side right
    pack [ttk::button $_AddOneCab.addit \
			-text [_m "Button|Add"] -command [mytypemethod _AddOneCab]] \
			-fill x
    focus -force $_AddOneCab.name
  }
  typemethod _SelectCabColor {} {
    set newcolor [tk_chooseColor \
                  -initialcolor [[$_AddOneCab.color getframe].e get]]
    if {[string equal "$newcolor" {}]} {return}
    [$_AddOneCab.color getframe].e delete 0 end
    [$_AddOneCab.color getframe].e insert end "$newcolor"
  }
  typemethod _AddOneCab {} {
    set name [$_AddOneCab.name cget -text]
    set color [[$_AddOneCab.color getframe].e get]
    if {[string equal "$name" {}] || [string equal "$color" {}]} {return}
    foreach e [$_CabList items] {
      set edata [$_CabList itemcget $e -data]
      switch -exact -- [string compare -nocase "[lindex $edata 0]" "$name"] {
	-1 {continue}
	0  {
	  TtErrorMessage draw -message [_ "Duplicate Cab name!"]
	  return
	}
	1  {
	  $_CabList insert [$_CabList index $e] $name \
		-data [list "$name" "$color"] \
		-text [format {%s (%s)} "$name" "$color"]
	  return
        }
      }
    }
    $_CabList insert end $name \
		-data [list "$name" "$color"] \
		-text [format {%s (%s)} "$name" "$color"]
  }
  typemethod draw {args} {
    $type createDialog
    $_CabList delete [$_CabList items]
    $_AddOneCab.name configure -text {}
    [$_AddOneCab.color getframe].e delete 0 end
    [$_AddOneCab.color getframe].e insert end black
    wm transient [winfo toplevel $_MainDialog] [$_MainDialog cget -parent]
    return [$_MainDialog draw]
  }
  typevariable _CabListing
  typemethod _OK {} {
    set _CabListing {}
    foreach e [$_CabList items] {
      lappend _CabListing [$_CabList itemcget $e -data]
    }
    $_MainDialog withdraw
    return [$_MainDialog enddialog ok]
  }
  typemethod _Cancel {} {
    set _CabListing {}
    $_MainDialog withdraw
    return [$_MainDialog enddialog cancel]
  }
  typemethod cablist {} {
    return $_CabListing
  }
}


proc TimeTable::CreateAllCabs {} {
  set what [createAllCabsDialog draw]
  switch -exact $what {
    ok {
      set cabs [createAllCabsDialog cablist]
      puts stderr "*** CreateAllCabs: cabs = $cabs"
      foreach cab $cabs {
	foreach {name color} $cab {
	  puts stderr "*** CreateAllCabs: name = $name, color = $color"
	  TimeTable AddCab "$name" "$color"
	}
      }
      return [llength $cabs]
    }
    cancel {
      return 0
    }
  }
}

snit::type TimeTable::addCabDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent name
  typecomponent color
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .addCabDialog \
			-bitmap questhead \
			-title [_ "Add A Cab"] \
			-modal local \
			-transient yes \
			-default 0 -cancel 1 \
			-parent . -side bottom]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Add Cab Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Add a Cab"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set lwidth [_mx "Label|Name:" "Label|Color:"]
    set name [LabelEntry $frame.name -label [_m "Label|Name:"] -labelwidth $lwidth]
    pack $name -fill x
    pack [LabelFrame [set color $frame.color] \
			-text [_m "Label|Color:"] -width $lwidth] -fill x
    set f [$color getframe]
    pack [ttk::entry $f.e] -expand yes -fill x -side left
    $f.e insert end black
    pack [ttk::button $f.b -text [_m "Button|Select"] \
			      -command [mytypemethod _SelectCabColor]] \
	 -side right
  }
  typemethod _SelectCabColor {} {
    set newcolor [tk_chooseColor \
			-initialcolor [[$color getframe].e get]]
    if {[string equal "$newcolor" {}]} {return}
    [$color getframe].e delete 0 end
    [$color getframe].e insert end "$newcolor"
  }
  typevariable _Name {}
  typevariable _Color {}
  typemethod _OK {} {
    set _Name "[$name cget -text]"
    set _Color "[[$color getframe].e get]"
    $dialog withdraw
    return [$dialog enddialog ok]
  }
  typemethod _Cancel {} {
    set _Name {}
    set _Color {}
    $dialog withdraw
    return [$dialog enddialog cancel]
  }
  typemethod draw {args} {
    $type createDialog
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }
  typemethod getname {} {
    return "$_Name"
  }
  typemethod getcolor {} {
    return "$_Color"
  }
}

proc TimeTable::AddCab {} {
  set what [addCabDialog draw]
  switch -exact $what {
    ok {
	set cabName  "[addCabDialog getname]"
	set cabColor "[addCabDialog getcolor]"
	if {[string equal [TimeTable FindCab "$cabName"] {NULL}]} {
	  $::ChartDisplay addACab [TimeTable AddCab "$cabName" "$cabColor"]
	} else {
	  TtErrorMessage draw -message [_ "Duplicate Cab name!"]
	}
	return 1
    }
    cancel {
	return 0
    }
  }
}

catch {
$TimeTable::Main menu add cabs command -label [_m "Menu|Cabs|Add A Cab"] \
			      -command TimeTable::AddCab \
			      -dynamichelp [_ "Add a cab"]
$TimeTable::Main buttons add ttk::button addACab \
      -text [_m "Button|Add A Cab"] \
      -command TimeTable::AddCab \
      -state disabled
#      -helptext [_ "Add a cab"] 
image create photo AddCabImage \
			-file [file join $TimeTable::ImageDir addcab.gif]
$TimeTable::Main toolbar addbutton tools addACab \
			-image AddCabImage \
			-command TimeTable::AddCab \
			-helptext [_ "Add a cab"] -state disabled
}

proc TimeTable::EnableCabCommands {} {
  variable Main
  $Main mainframe setmenustate cabs:menu normal
  $Main buttons itemconfigure addACab -state normal
  $Main toolbar buttonconfigure tools addACab -state normal
}

package provide TTCabs 1.0


