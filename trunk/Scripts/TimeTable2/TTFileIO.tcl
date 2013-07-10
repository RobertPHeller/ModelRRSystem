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

namespace eval TimeTable {}

catch {SplashWorkMessage [_ "Loading File I/O Support"] 33}

proc TimeTable::LoadTimeTable {{filename {}}} {
  variable ChartDisplay
  variable Main

  if {[string length "$filename"] == 0} {
  set filename [tk_getOpenFile \
	-defaultextension {.tt} \
	-initialfile timetable.tt \
	-parent . \
	-title [_ "Name of time table file to load"]]
  }
  if {[string length "$filename"] == 0} {return}

  if {[llength [info commands TimeTable]] > 0} {
    if {![TtYesNo draw -title [_ "TT Already Loaded"] -message \
	[_ "There is a time table already loaded.  Do you want to dump it and load another?"]]} {
      return
    }
    rename TimeTable {}
    $ChartDisplay deleteWholeChart
  }

  TimeTableSystem TimeTable -this [OldCreateTimeTable "$filename"]

  $ChartDisplay buildWholeChart [TimeTable cget -this]
  $Main menu entryconfigure file [_m "Menu|File|Save"] -state normal
  $Main toolbar buttonconfigure tools save -state normal
  $Main menu entryconfigure file [_m "Menu|File|Save As..."]  -state normal
  EnableTrainCommands
  EnableStationCommands
  EnableCabCommands
  EnableNoteCommands
  EnablePrintCommands
}

package require BWLabelSpinBox
package require snit

snit::type TimeTable::CreateANewTimeTableDialog {
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
    set dialog [Dialog::create .createANewTimeTableDialog \
			-bitmap questhead \
			-default 0 \
			-cancel 1 \
			-modal local \
			-transient yes \
			-parent . \
			-side bottom \
			-title [_ "Create A New Time Table"]]
    $dialog add -name ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add -name cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Create A New Time Table Dialog}]
    set frame [Dialog::getframe $dialog]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Create a New Time Table"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set lwidth [_mx "Label|Name of Time Table:" "Label|Total Time:" \
			"Label|Time Interval for ticks:"]
    set name [LabelEntry::create $frame.name \
			-label [_m "Label|Name of Time Table:"] \
			-labelwidth $lwidth]
    pack $name -fill x
    set totalTime [LabelSpinBox::create $frame.totalTime \
			-label [_m "Label|Total Time:"] \
			-labelwidth $lwidth \
			-range {60 1440 1}]
    $totalTime bind <Return> [mytypemethod _OK]
    pack $totalTime -fill x
    set timeInterval [LabelSpinBox::create $frame.timeInterval \
			-label [_m "Label|Time Interval for ticks:"] \
			-labelwidth $lwidth \
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


proc TimeTable::NewTimeTable {{name {}} {totaltime 1440} {timeinterval 15}} {
  variable ChartDisplay
  variable Main

  if {[string equal "$name" {}]} {
    set result [CreateANewTimeTableDialog draw \
			-name "$name" \
			-totaltime $totaltime \
			-timeinterval $timeinterval]


#    puts stderr "*** NewTimeTable: result = $result"
    if {[string equal "$result" Cancel]} {return}
    set name "[CreateANewTimeTableDialog cget -name]"
#    puts stderr "*** NewTimeTable: name = '$name'"
    set totaltime [CreateANewTimeTableDialog cget -totaltime]
#    puts stderr "*** NewTimeTable: totaltime = $totaltime"
    set timeinterval [CreateANewTimeTableDialog cget -timeinterval]
#    puts stderr "*** NewTimeTable: timeinterval = $timeinterval"
  }
  if {[string equal "$name" {}]} {return}

  if {[llength [info commands TimeTable]] > 0} {
    if {![TtYesNo draw -title [_ "TT Already Loaded"] -message \
	[_ "There is a time table already loaded.  Do you want to dump it and load another?"]]} {
      return
    }
    rename TimeTable {}
    $ChartDisplay deleteWholeChart
  }

  TimeTableSystem TimeTable -this [NewCreateTimeTable "$name" $totaltime $timeinterval]
  while {[CreateAllStations] == 0} {
    TtErrorMessage draw -message [_ "You need to create stations before proceding!"]
  }
  CreateAllCabs
  $ChartDisplay buildWholeChart [TimeTable cget -this]
  $Main menu entryconfigure file [_m "Menu|File|Save"] -state normal
  $Main toolbar buttonconfigure tools save -state normal
  $Main menu entryconfigure file [_m "Menu|File|Save As..."]  -state normal
  EnableTrainCommands
  EnableStationCommands
  EnableCabCommands
  EnableNoteCommands
  EnablePrintCommands
}

proc TimeTable::SaveTimeTable {} {
  if {[llength [info commands TimeTable]] == 0} {
    ::TimeTable::TtWarningMessage draw -message [_ "There is no time table to save!"]
    return
  }
  SaveTimeTableAs "[TimeTable Filename]"
}

proc TimeTable::SaveTimeTableAs {{filename {}}} {
  if {[llength [info commands TimeTable]] == 0} {
    ::TimeTable::TtWarningMessage draw -message [_ "There is no time table to save!"]
    return
  }

  if {[string length "$filename"] == 0} {
  set filename [tk_getSaveFile \
	-defaultextension {.tt} \
	-initialfile timetable.tt \
	-parent . \
	-title [_ "Name of time table file to save"]]
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
$TimeTable::Main menu entryconfigure file [_m "Menu|File|New"] -command TimeTable::NewTimeTable -state normal \
	-dynamichelp [_ "Create a new Time Table"]
image create photo NewButtonImage -file [file join $TimeTable::CommonImageDir new.gif]
$TimeTable::Main toolbar addbutton tools new -image NewButtonImage -command TimeTable::NewTimeTable \
	-helptext [_ "Create a new Time Table"]
$TimeTable::Main menu entryconfigure file [_m "Menu|File|Open..."] -command TimeTable::LoadTimeTable \
	-state normal -dynamichelp [_ "Open an Existing Time Table"]
image create photo OpenButtonImage -file [file join $TimeTable::CommonImageDir open.gif]
$TimeTable::Main toolbar addbutton tools open -image OpenButtonImage -command TimeTable::LoadTimeTable \
	-helptext [_ "Open an Existing Time Table"]
$TimeTable::Main menu entryconfigure file [_m "Menu|File|Save"] -command TimeTable::SaveTimeTable -state disabled \
	-dynamichelp [_ "Save the current Time Table"]
image create photo SaveButtonImage -file [file join $TimeTable::CommonImageDir save.gif]
$TimeTable::Main toolbar addbutton tools save -image SaveButtonImage -command TimeTable::SaveTimeTable \
	-helptext [_ "Save the current Time Table"] -state disabled
$TimeTable::Main menu entryconfigure file [_m "Menu|File|Save As..."] -command TimeTable::SaveTimeTableAs \
	-state disabled -dynamichelp [_ "Save the current Time Table in a new file"]

} message
#puts stderr "*** TTFileIO button/menu configuration: $message"

package provide TTFileIO 1.0
