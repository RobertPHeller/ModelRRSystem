#* 
#* ------------------------------------------------------------------
#* TTCabs.tcl - Cab related code
#* Created by Robert Heller on Sat Apr  1 23:05:07 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

catch {SplashWorkMessage {Loading Cab Code} 66}

package require snit

snit::type createAllCabsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent _MainDialog
  typecomponent _CabList
  typecomponent _AddOneCab
  typeconstructor {
    set _MainDialog [Dialog::create .createAllCabsDialog \
			-class CreateAllCabsDialog \
			-bitmap questhead \
			-title "Create All Cabs" \
			-modal local \
			-transient yes \
			-default 0 -cancel 1 \
			-parent . -side bottom]
    $_MainDialog add -name ok -text OK -command [mytypemethod _OK]
    $_MainDialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    $_MainDialog add -name help -text Help -command [list BWHelp::HelpTopic CreateAllCabsDialog]
    set frame [$_MainDialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Create All Cabs}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set clScrollerFrame [LabelFrame::create $frame.clScrollerFrame \
			-text "Cabs:" -side top]
    pack $clScrollerFrame -expand yes -fill both
    set clScroller [ScrolledWindow::create \
			[$clScrollerFrame getframe].clScroller \
			-auto both -scrollbar both]
    pack $clScroller -expand yes -fill both
    set _CabList [ListBox::create $clScroller.cabs]
    pack $_CabList -expand yes -fill both
    $clScroller setwidget $_CabList
    set add1CabFrame [LabelFrame::create $frame.add1CabFrame \
				-text "Add Cab:" -side top]
    pack $add1CabFrame -fill x
    set _AddOneCab [$add1CabFrame getframe]
    pack [LabelEntry::create $_AddOneCab.name \
			-label "Name:" -labelwidth 12] -fill x
    $_AddOneCab.name bind <Return> "[list $_AddOneCab.addit invoke];break"
    pack [LabelFrame::create $_AddOneCab.color \
			-text "Color:" -width 12] -fill x
    set f [$_AddOneCab.color getframe]
    pack [Entry::create $f.e -text black] -expand yes -fill x -side left
    bind $f.e <Return> "[list $_AddOneCab.addit invoke];break"
    pack [Button::create $f.b -text "Select" \
			      -command [mytypemethod _SelectCabColor]] \
	 -side right
    pack [Button::create $_AddOneCab.addit \
			-text "Add" -command [mytypemethod _AddOneCab]] \
			-fill x
    BWidget::focus set $_AddOneCab.name
  }
  typemethod _SelectCabColor {} {
    set newcolor [SelectColor $_AddOneCab.color.selectColor \
			-color [[$_AddOneCab.color getframe].e cget -text]]
    if {[string equal "$newcolor" {}]} {return}
    [$_AddOneCab.color getframe].e configure -text "$newcolor"
  }
  typemethod _AddOneCab {} {
    set name [$_AddOneCab.name cget -text]
    set color [[$_AddOneCab.color getframe].e cget -text]
    if {[string equal "$name" {}] || [string equal "$color" {}]} {return}
    foreach e [$_CabList items] {
      set edata [$_CabList itemcget $e -data]
      switch -exact -- [string compare -nocase "[lindex $edata 0]" "$name"] {
	-1 {continue}
	0  {
	  TtErrorMessage draw -message "Duplicate Cab name!"
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
    $_CabList delete [$_CabList items]
    $_AddOneCab.name configure -text {}
    [$_AddOneCab.color getframe].e configure -text black
    return [Dialog::draw $_MainDialog]
  }
  typevariable _CabListing
  typemethod _OK {} {
    set _CabListing {}
    foreach e [$_CabList items] {
      lappend _CabListing [$_CabList itemcget $e -data]
    }
    Dialog::withdraw $_MainDialog
    return [Dialog::enddialog $_MainDialog ok]
  }
  typemethod _Cancel {} {
    set _CabListing {}
    Dialog::withdraw $_MainDialog
    return [Dialog::enddialog $_MainDialog cancel]
  }
  typemethod cablist {} {
    return $_CabListing
  }
}


proc CreateAllCabs {} {
  set what [createAllCabsDialog draw]
  switch -exact $what {
    ok {
      set cabs [createAllCabsDialog cablist]
#      puts stderr "*** CreateAllCabs: cabs = $cabs"
      foreach cab $cabs {
	foreach {name color} $cab {
#	  puts stderr "*** CreateAllCabs: name = $name, color = $color"
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

snit::type addCabDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent name
  typecomponent color
  typeconstructor {
    set dialog [Dialog::create .addCabDialog \
			-class AddCabDialog \
			-bitmap questhead \
			-title "Add A Cab" \
			-modal local \
			-transient yes \
			-default 0 -cancel 1 \
			-parent . -side bottom]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list BWHelp::HelpTopic AddCabDialog]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Add a Cab}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set name [LabelEntry::create $frame.name -label "Name:" -labelwidth 7]
    pack $name -fill x
    pack [LabelFrame::create [set color $frame.color] \
			-text "Color:" -width 12] -fill x
    set f [$color getframe]
    pack [Entry::create $f.e -text black] -expand yes -fill x -side left
    pack [Button::create $f.b -text "Select" \
			      -command [mytypemethod _SelectCabColor]] \
	 -side right
  }
  typemethod _SelectCabColor {} {
    set newcolor [SelectColor $color.selectColor \
			-color [[$color getframe].e cget -text]]
    if {[string equal "$newcolor" {}]} {return}
    [$color getframe].e configure -text "$newcolor"
  }
  typevariable _Name {}
  typevariable _Color {}
  typemethod _OK {} {
    set _Name "[$name cget -text]"
    set _Color "[[$color getframe].e cget -text]"
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog ok]
  }
  typemethod _Cancel {} {
    set _Name {}
    set _Color {}
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog cancel]
  }
  typemethod draw {args} {
    return [Dialog::draw $dialog]
  }
  typemethod getname {} {
    return "$_Name"
  }
  typemethod getcolor {} {
    return "$_Color"
  }
}

proc AddCab {} {
  set what [addCabDialog draw]
  switch -exact $what {
    ok {
	set cabName  "[addCabDialog getname]"
	set cabColor "[addCabDialog getcolor]"
	if {[string equal [TimeTable FindCab "$cabName"] {NULL}]} {
	  $::ChartDisplay addACab [TimeTable AddCab "$cabName" "$cabColor"]
	} else {
	  TtErrorMessage draw -message "Duplicate Cab name!"
	}
	return 1
    }
    cancel {
	return 0
    }
  }
}

catch {
$::Main menu add cabs command -label {Add A Cab} \
			      -command AddCab \
			      -dynamichelp "Add a cab"
$::Main buttons add -name addACab -text {Add A Cab} -anchor w \
			      -command AddCab \
			      -helptext "Add a cab"
image create photo AddCabImage \
			-file [file join $ImageDir addcab.gif]
$::Main toolbar addbutton tools addACab \
			-image AddCabImage \
			-command AddCab \
			-helptext "Add a cab"
}

package provide TTCabs 1.0


