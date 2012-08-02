#* 
#* ------------------------------------------------------------------
#* TTFileIO.tcl - File I/O support code
#* Created by Robert Heller on Sat Dec 31 11:14:49 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.6  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.5  2007/05/06 12:49:45  heller
#* Modification History: Lock down  for 2.1.8 release candidate 1
#* Modification History:
#* Modification History: Revision 1.4  2006/05/16 19:27:46  heller
#* Modification History: May162006 Lockdown
#* Modification History:
#* Modification History: Revision 1.3  2006/03/06 18:46:21  heller
#* Modification History: March 6 lockdown
#* Modification History:
#* Modification History: Revision 1.2  2006/02/26 23:09:25  heller
#* Modification History: Lockdown for machine xfer
#* Modification History:
#* Modification History: Revision 1.1  2006/01/03 15:30:22  heller
#* Modification History: Lockdown
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

catch {SplashWorkMessage {Loading File I/O Support} 33}

proc LoadTimeTable {{filename {}}} {
  global ChartDisplay

  if {[string length "$filename"] == 0} {
  set filename [tk_getOpenFile \
	-defaultextension {.tt} \
	-initialfile timetable.tt \
	-parent . \
	-title {Name of time table file to load}]
  }
  if {[string length "$filename"] == 0} {return}

  if {[llength [info commands TimeTable]] > 0} {
    if {![TtYesNo draw -title {TT Already Loaded} -message \
	"There is a time table already loaded.  Do you want to dump it and load another?"]} {
      return
    }
    rename TimeTable {}
    $ChartDisplay deleteWholeChart
  }

  TimeTableSystem TimeTable -this [OldCreateTimeTable "$filename"]

  $ChartDisplay buildWholeChart [TimeTable cget -this]  
}

package require BWLabelSpinBox
package require snit

snit::type GetNewTimeTableDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent name
  typecomponent totalTime
  typecomponent timeInterval
  typevariable nameValue {}
  typevariable totalTimeValue 60
  typevariable timeIntervalValue 1

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .getNewTimeTableDialog \
			-bitmap questhead \
			-default 0 \
			-cancel 1 \
			-modal local \
			-transient yes \
			-parent . \
			-side bottom \
			-title {Create a New Time Table}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list BWHelp::HelpTopic GetNewTimeTableDialog]
    set frame [Dialog::getframe $dialog]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Create a New Time Table}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set name [LabelEntry::create $frame.name \
			-label {Name of Time Table:} \
			-labelwidth 24]
    pack $name -fill x
    set totalTime [LabelSpinBox::create $frame.totalTime \
			-label {Total Time:} \
			-labelwidth 24 \
			-range {60 1440 1}]
    $totalTime bind <Return> [mytypemethod _OK]
    pack $totalTime -fill x
    set timeInterval [LabelSpinBox::create $frame.timeInterval \
			-label {Time Interval for ticks:} \
			-labelwidth 24 \
			-range {1 60 1}]
    $timeInterval bind <Return> [mytypemethod _OK]
    pack $timeInterval -fill x
    BWidget::focus set $frame.name
  }

  typemethod _OK {} {
    Dialog::withdraw $dialog
    set nameValue "[$name cget -text]"
    set totalTimeValue [$totalTime cget -text]
    set timeIntervalValue [$timeInterval cget -text]
    return [eval [list Dialog::enddialog $dialog] [list OK]]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list Cancel]]
  }

  typemethod draw {args} {
    $type createDialog
    $name configure -text "[from args -name]"
    $totalTime configure -text [from args -totaltime]
    $timeInterval configure -text [from args -timeinterval]
    BWidget::focus $name 1
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }

  typemethod cget {option} {
    switch -exact -- $option {
      -name {return "$nameValue"}
      -totaltime {return $totalTimeValue}
      -timeinterval {return $timeIntervalValue}
      default {
	error "Unknown option: $option"
      }
    }
  }
}


proc NewTimeTable {{name {}} {totaltime 1440} {timeinterval 15}} {
  global ChartDisplay

  if {[string equal "$name" {}]} {
    set result [GetNewTimeTableDialog draw \
			-name "$name" \
			-totaltime $totaltime \
			-timeinterval $timeinterval]


#    puts stderr "*** NewTimeTable: result = $result"
    if {[string equal "$result" Cancel]} {return}
    set name "[GetNewTimeTableDialog cget -name]"
#    puts stderr "*** NewTimeTable: name = '$name'"
    set totaltime [GetNewTimeTableDialog cget -totaltime]
#    puts stderr "*** NewTimeTable: totaltime = $totaltime"
    set timeinterval [GetNewTimeTableDialog cget -timeinterval]
#    puts stderr "*** NewTimeTable: timeinterval = $timeinterval"
  }
  if {[string equal "$name" {}]} {return}

  if {[llength [info commands TimeTable]] > 0} {
    if {![TtYesNo draw -title {TT Already Loaded} -message \
	"There is a time table already loaded.  Do you want to dump it and load another?"]} {
      return
    }
    rename TimeTable {}
    $ChartDisplay deleteWholeChart
  }

  TimeTableSystem TimeTable -this [NewCreateTimeTable "$name" $totaltime $timeinterval]
  while {[CreateAllStations] == 0} {
    TtErrorMessage draw -message "You need to create stations before proceding!"
  }
  CreateAllCabs
  $ChartDisplay buildWholeChart [TimeTable cget -this]
}

proc SaveTimeTable {} {
  if {[llength [info commands TimeTable]] == 0} {
    TtWarningMessage draw -message "There is no time table to save!"
    return
  }
  SaveTimeTableAs "[TimeTable Filename]"
}

proc SaveTimeTableAs {{filename {}}} {
  if {[llength [info commands TimeTable]] == 0} {
    TtWarningMessage draw -message "There is no time table to save!"
    return
  }

  if {[string length "$filename"] == 0} {
  set filename [tk_getSaveFile \
	-defaultextension {.tt} \
	-initialfile timetable.tt \
	-parent . \
	-title {Name of time table file to save}]
  }
  if {[string length "$filename"] == 0} {return}
  if {[string equal "[TimeTable Filename]" {}]} {
    set newfile 1
  } else {
    set newfile 0
  }

  TimeTable WriteNewTimeTableFile "$filename" $newfile
}

catch {
$::Main menu entryconfigure file New -command NewTimeTable -state normal \
	-dynamichelp "Create a new Time Table"
image create photo NewButtonImage -file [file join $CommonImageDir new.gif]
$::Main toolbar addbutton tools new -image NewButtonImage -command NewTimeTable \
	-helptext "Create a new Time Table"
$::Main menu entryconfigure file {Open...} -command LoadTimeTable \
	-state normal -dynamichelp "Open an Existing Time Table"
image create photo OpenButtonImage -file [file join $CommonImageDir open.gif]
$::Main toolbar addbutton tools open -image OpenButtonImage -command LoadTimeTable \
	-helptext "Open an Existing Time Table"
$::Main menu entryconfigure file {Save} -command SaveTimeTable -state normal \
	-dynamichelp "Save the current Time Table"
image create photo SaveButtonImage -file [file join $CommonImageDir save.gif]
$::Main toolbar addbutton tools save -image SaveButtonImage -command SaveTimeTable \
	-helptext "Save the current Time Table"
$::Main menu entryconfigure file {Save As...} -command SaveTimeTableAs \
	-state normal -dynamichelp "Save the current Time Table in a new file"

} message
#puts stderr "*** TTFileIO button/menu configuration: $message"

package provide TTFileIO 1.0
