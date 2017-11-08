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


package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames

snit::widget LabelYesNoTwice {
    hulltype ttk::frame
    widgetclass LabelYesNoTwice
    option -style LabelYesNoTwice
    typeconstructor {
        ttk::style layout $type [ttk::style layout TLabelframe]
        ttk::style layout $type.Label [ttk::style layout TLabelframe.Label]
    }
    component label
    component yesno
    component twice
    variable checkbutton
    variable value no
    delegate option -label to label as -text
    delegate option -labelwidth to label as -width
    delegate option -labelimage to label as -image
    delegate option -labelcompound to label as -compound
    delegate option -labelanchor to label as -anchor
    delegate option -labelfont to label as -font
    delegate option -labeljustify to label as -justify
    constructor {args} {
        install label using ttk::label $win.label
        pack $label -side left
        install yesno using ttk::button $win.yesno \
              -text [_m "Label|No"] -command [mymethod _yesno]
        pack $yesno -side left
        install twice using ttk::checkbutton $win.twice \
              -command [mymethod _twice] \
              -variable [myvar checkbutton] \
              -text [_m "Label|Twice"]
        pack $twice -side left
        $self configurelist $args
    }
    method getvalue {} {return $value}
    method setvalue {valuelist} {
        set yescount 0
        set nocount  0
        set twicecount 0
        set newvalue {}
        foreach e $valuelist {
            set el [string tolower "$e"]
            if {"$el" eq "yes"} {
                incr yescount
            } elseif {"$el" eq "no"} {
                incr nocount
            } elseif {"$el" eq "twice"} {
                incr twicecount
            } else {
                error [_ "Not a legal value element: %s in %s" $e $value]
            }
            lappend newvalue $el
        }
        if {$yescount > 1} {
            error [_ "More than one yes in %s" $valuelist]
        }
        if {$nocount > 1} {
            error [_ "More than one no in %s" $valuelist]
        }
        if {$twicecount > 1} {
            error [_ "More than one twice in %s" $valuelist]
        }
        if {$yescount > 0 && $nocount > 0} {
            error [_ "Yes and no both specified in %s" $valuelist]
        }
        if {$yescount == 0 && $nocount == 0} {
            error [_ "Neigher yes nor no specified in %s" $valuelist]
        }
        if {$twicecount == 0} {
            set checkbutton 0
        } else {
            set checkbutton 1
        }
        if {$yescount > 0} {
            $yesno configure -text [_m "Label|Yes"]
        } else {
            $yesno configure -text [_m "Label|No"]
        }
        set value $newvalue
    }
    
    method _yesno {} {
        if {"[$yesno cget -text]" eq [_m "Label|Yes"]} {
            set index [lsearch -exact $value yes]
            $yesno configure -text [_m "Label|No"]
            set value [lreplace $value $index $index no]
        } else {
            set index [lsearch -exact $value no]
            $yesno configure -text [_m "Label|Yes"]
            set value [lreplace $value $index $index yes]
        }
    }
    method _twice {} {
        if {$checkbutton} {
            lappend value twice
        } else {
            set index [lsearch -exact $value twice]
            set value [lreplace $value $index $index]
        }
    }
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
    set dialog [Dialog .controlYardListsDialog \
		  -bitmap questhead -default 0 \
		  -cancel 1 -modal local -transient yes -parent . \
		  -side bottom -title [_ "Control Yard Lists"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Control Yard Lists Dialog}]
    set frame [$dialog getframe]
    set lwidth [_mx "Label|Alphabetical Lists:" "Label|Train Lists:"]
    set alphaLists [LabelYesNoTwice $frame.alphaLists \
	-label [_m "Label|Alphabetical Lists:"] -labelwidth $lwidth]
    pack $alphaLists -fill x
    set trainLists [LabelYesNoTwice $frame.trainLists \
	-label [_m "Label|Train Lists:"] -labelwidth $lwidth]
    pack $trainLists -fill x
    wm transient [winfo toplevel $dialog] .
  }

  typemethod _OK {} {
    $dialog withdraw
    set alphaValue [$alphaLists getvalue]
    set trainValue [$trainLists getvalue]
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
    return [eval [list $dialog enddialog] [list OK]]
  }

  typemethod _Cancel {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list Cancel]]
  }

  typemethod draw {} {
    $type createDialog
    focus -force $alphaLists
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
    return [eval [list $dialog draw]]
  }
}    
    

package provide FCFControlYardListsDialog 1.0
