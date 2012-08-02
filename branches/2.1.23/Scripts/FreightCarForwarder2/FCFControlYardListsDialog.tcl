#* 
#* ------------------------------------------------------------------
#* FCFControlYardListsDialog.tcl - Control Yard Lists Dialog
#* Created by Robert Heller on Sun Feb 19 10:46:05 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.6  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.5  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.4  2007/04/19 17:23:24  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.3  2006/04/01 17:12:09  heller
#* Modification History: Lock Down APR012006
#* Modification History:
#* Modification History: Revision 1.2  2006/03/06 18:46:20  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.1  2006/02/26 23:09:24  heller
#* Modification History: Lockdown for machine xfer
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


package require BWidget
package require snit

namespace eval LabelYesNoTwice {
  Widget::define LabelYesNoTwice FCFControlYardListsDialog LabelFrame Button

  Widget::bwinclude LabelYesNoTwice LabelFrame .labf \
	remove {-relief -borderwidth -focus} \
	rename {-text -label} \
	prefix {label -justify -width -anchor -height -font -textvariable}
  Widget::bwinclude LabelYesNoTwice Button .yesno \
	initialize {-text No}

  Widget::tkinclude LabelYesNoTwice checkbutton .twice \
	initialize {-text Twice -onvalue 1 -offvalue 0 -indicatoron yes}

  ::bind BwLabelYesNoTwice <FocusIn> [list focus %W.labf]
  ::bind BwLabelYesNoTwice <Destroy> [list LabelYesNoTwice::_destroy %W]
  variable checkbuttons
}

proc LabelYesNoTwice::create { path args } {
  array set maps [list LabelYesNoTwice {} :cmd {} .labf {} .yesno {} \
		       .twice {}]
  array set maps [Widget::parseArgs LabelYesNoTwice $args]
  eval [list frame $path] $maps(:cmd) -class LabelYesNoTwice \
	-relief flat -bd 0 -highlightthickness 0 -takefocus 0
  Widget::initFromODB LabelYesNoTwice $path $maps(LabelYesNoTwice)
  set labf [eval [list LabelFrame::create $path.labf] $maps(.labf) \
		[list -relief flat -borderwidth 0 -focus $path.yes]]
  set subf  [LabelFrame::getframe $labf]
  set yesno [eval [list Button::create $path.yesno] $maps(.yesno) \
		[list -command [list LabelYesNoTwice::_yesno $path]]]
  pack $yesno -in $subf -side left
  set twice [eval [list checkbutton $path.twice] $maps(.twice) \
		[list -command [list LabelYesNoTwice::_twice $path] \
		      -variable LabelYesNoTwice::checkbuttons($path)]]
  set LabelYesNoTwice::checkbuttons($path) 0
  pack $twice -in $subf -side left
  pack $labf  -fill both -expand yes

  Widget::getVariable $path value
  set value {no}

  bindtags $path [list $path BwLabelYesNoTwice [winfo toplevel $path] all]
  return [Widget::create LabelYesNoTwice $path]
}

# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::configure
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::configure { path args } {
    return [Widget::configure $path $args]
}


# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::cget
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::cget { path option } {
    return [Widget::cget $path $option]
}

# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::getvalue
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::getvalue { path } {
    Widget::getVariable $path value
    return $value
}

# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::setvalue
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::setvalue { path valuelist } {
    Widget::getVariable $path value
    variable checkbuttons
    set yescount 0
    set nocount  0
    set twicecount 0
    set newvalue {}
    foreach e $valuelist {
      set el [string tolower "$e"]
      if {[string equal "$el" "yes"]} {
	incr yescount
      } elseif {[string equal "$el" "no"]} {
        incr nocount
      } elseif {[string equal "$el" "twice"]} {
	incr twicecount
      } else {
	error "Not a legal value element: $e in $value"
      }
      lappend newvalue $el
    }
    if {$yescount > 1} {
      error "More than one yes in $valuelist"
    }
    if {$nocount > 1} {
      error "More than one no in $valuelist"
    }
    if {$twicecount > 1} {
      error "More than one twice in $valuelist"
    }
    if {$yescount > 0 && $nocount > 0} {
      error "Yes and no both specified in $valuelist"
    }
    if {$yescount == 0 && $nocount == 0} {
      error "Neigher yes nor no specified in $valuelist"
    }
    if {$twicecount == 0} {
      set checkbuttons($path) 0
    } else {
      set checkbuttons($path) 1
    }
    if {$yescount > 0} {
      $path.yesno configure -text Yes
    } else {
      $path.yesno configure -text No
    }
    set value $newvalue
}

# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::_yesno
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::_yesno { path } {
    Widget::getVariable $path value
    if {[string equal [$path.yesno cget -text] "Yes"]} {
      set index [lsearch -exact $value yes]
      $path.yesno configure -text No
      set value [lreplace $value $index $index no]
    } else {
      set index [lsearch -exact $value no]
      $path.yesno configure -text Yes
      set value [lreplace $value $index $index yes]
    }
}

# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::_twice
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::_twice { path } {
  variable checkbuttons
  Widget::getVariable $path value
  if {$checkbuttons($path)} {
    lappend value twice
  } else {
    set index [lsearch -exact $value twice]
    set value [lreplace $value $index $index]
  }
}

# ------------------------------------------------------------------------------
#  Command LabelYesNoTwice::_path_command
# ------------------------------------------------------------------------------
proc LabelYesNoTwice::_path_command { path cmd larg } {
  if { [string equal $cmd "configure"] ||
       [string equal $cmd "cget"] ||
       [string equal $cmd "getvalue"] ||
       [string equal $cmd "setvalue"]} {
    return [eval [list LabelYesNoTwice::$cmd $path] $larg]
  }
}

proc LabelYesNoTwice::_destroy { path } {
  Widget::destroy $path
}

snit::type ControlYardListsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent alphaLists
  typecomponent trainLists

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .controlYardListsDialog \
		  -bitmap questhead -default 0 \
		  -cancel 1 -modal local -transient yes -parent . \
		  -side bottom -title {Control Yard Lists}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Control Yard Lists Dialog}]
    set frame [Dialog::getframe $dialog]
    set alphaLists [LabelYesNoTwice::create $frame.alphaLists \
	-label {Alphabetical Lists:} -labelwidth 19]
    pack $alphaLists -fill x
    set trainLists [LabelYesNoTwice::create $frame.trainLists \
	-label {Train Lists:} -labelwidth 19]
    pack $trainLists -fill x
    wm transient [winfo toplevel $dialog] .
  }

  typemethod _OK {} {
    Dialog::withdraw $dialog
    set alphaValue [LabelYesNoTwice::getvalue $alphaLists]
    set trainValue [LabelYesNoTwice::getvalue $trainLists]
    if {[llength [info commands TheSystem]] > 0} {
      if {[lsearch $alphaValue yes] >= 0} {
	::TheSystem SetPrintAlpha 1
      } else {
	::TheSystem SetPrintAlpha 0
      }
      if {[lsearch $alphaValue twice] >= 0} {
	::TheSystem SetPrintAtwice 1
      } else {
	::TheSystem SetPrintAtwice 0
      }
      if {[lsearch $trainValue yes] >= 0} {
	::TheSystem SetPrintList 1
      } else {
	::TheSystem SetPrintList 0
      }
      if {[lsearch $trainValue twice] >= 0} {
	::TheSystem SetPrintLtwice 1
      } else {
	::TheSystem SetPrintLtwice 0
      }
    }
    return [eval [list Dialog::enddialog $dialog] [list OK]]
  }

  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list Cancel]]
  }

  typemethod draw {} {
    $type createDialog
    BWidget::focus $alphaLists 1
    if {[llength [info commands TheSystem]] > 0} {
      set pa  [::TheSystem PrintAlpha]
      set pa2 [::TheSystem PrintAtwice]
      if {$pa} {
	if {$pa2} {
	  $alphaLists setvalue [list yes twice]
	} else {
	  $alphaLists setvalue [list yes]
	}
      } else {
	if {$pa2} {
          $alphaLists setvalue [list no twice]
	} else {
	  $alphaLists setvalue [list no]
	}
      }
      set pt  [::TheSystem PrintList]
      set pt2 [::TheSystem PrintLtwice]
      if {$pt} {
	if {$pt2} {
	  $trainLists setvalue [list yes twice]
	} else {
	  $trainLists setvalue [list yes]
	}
      } else {
	if {$pt2} {
	  $trainLists setvalue [list no twice]
	} else {
	  $trainLists setvalue [list no]
	}
      }
    } else {
      $alphaLists setvalue [list no]
      $trainLists setvalue [list no]
    }
    wm transient [winfo toplevel $dialog] .
    return [eval [list Dialog::draw $dialog]]
  }
}    
    

package provide FCFControlYardListsDialog 1.0
