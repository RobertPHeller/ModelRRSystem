#* 
#* ------------------------------------------------------------------
#* TTNotes.tcl - Notes code
#* Created by Robert Heller on Sat Apr  1 23:06:14 2006
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

catch {TimeTable::SplashWorkMessage [_ "Loading Notes Code"] 77}

package require gettext
package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames

snit::type TimeTable::viewAllNotesDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerframe
  typecomponent iconimage
  typecomponent headerlabel
  typecomponent dismisbutton
  typecomponent notesSFrame
  typecomponent notesSWindow
  typecomponent notesFrame

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .viewAllNotesDialog \
			-bitmap info \
			-default 0 -cancel 0 -modal none -transient yes \
			-parent . -side bottom -title [_ "All Available Notes"]]
    $dialog add dismis -text [_m "Button|Dismis"] -command [mytypemethod _Dismis]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Dismis]
    set mainframe [$dialog getframe]
    set headerframe $mainframe.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    set notesSWindow $mainframe.notesSWindow
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "All Available Notes"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    ScrolledWindow $notesSWindow \
		-auto vertical -scrollbar vertical
    pack $notesSWindow -expand yes -fill both
    set notesSFrame [ScrollableFrame $notesSWindow.notesSFrame]
    $notesSWindow setwidget $notesSFrame
    set notesFrame [$notesSFrame getframe]
    ttk::label $notesFrame.number0 -text [_m "Label|Number"] -anchor e
    ttk::label $notesFrame.text0   -text [_m "Label|Begining text"] -anchor w
    foreach w  {number text} \
	    c  {0      1} \
	    sk {e      w} {
      grid configure $notesFrame.${w}0 -column $c -row 0 -sticky $sk
    }
  }
  typemethod _Dismis {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list {}]]
  }

  typevariable _NumberOfNotesInDialog 0
  typemethod draw {args} {
    $type createDialog
    for {set inote 1} {$inote <= [TimeTable NumberOfNotes]} {incr inote} {
      if {$inote > $_NumberOfNotesInDialog} {
	ttk::button $notesFrame.number$inote
	ttk::label  $notesFrame.text$inote   -anchor w
	foreach w  {number text} \
		c  {0      1} \
		sk {e      w} {
	  grid configure $notesFrame.${w}$inote -column $c -row $inote -sticky $sk
	}
	incr _NumberOfNotesInDialog
      }
      $notesFrame.number$inote configure -text $inote \
					 -command [list TimeTable::displayOneNote draw \
							-note $inote]
      set textfrag "[string range [TimeTable Note $inote] 0 100]"
      regsub -all "\n" $textfrag { } textfrag
      $notesFrame.text$inote   configure -text "$textfrag"
    }
    for {set iextra $inote} {$iextra < $_NumberOfNotesInDialog} {incr iextra} {
      foreach w  {number text} {
	destroy $notesFrame.${w}$iextra
      }
    }
    update idle
    set dialogWidth [expr 60 + [winfo reqwidth $notesFrame]]
    set dialogHeight [expr (4 * $dialogWidth) / 3]
    if {$dialogHeight > 500} {set dialogHeight 500}
    set geo "${dialogWidth}x${dialogHeight}"
    $dialog configure -geometry "$geo"
    set _NumberOfNotesInDialog $inote
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list $dialog draw]]      
  }
}

proc TimeTable::ViewAllNotes {} {
  viewAllNotesDialog draw
}

snit::type TimeTable::selectOneNoteDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerlabel
  typecomponent number
  typecomponent nlist
  typecomponent nlistlist

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .selectOneNoteDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title [_ "Select one note"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Select One Note Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Select one note"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set nlist [eval [list ScrolledWindow $frame.nlist] -scrollbar both -auto both]
    pack $nlist -expand yes -fill both
    set nlistlist [eval [list ListBox $frame.nlist.list] -selectmode single]
    $nlist setwidget $nlistlist
    $nlistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $nlistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set number [LabelEntry $frame.number -label [_m "Label|Note Number Selection:"]]
    pack $number -fill x
    $number bind <Return> [mytypemethod _OK]
  }

  typemethod _OK {} {
    $dialog withdraw
    set result "[$number cget -text]"
    return [eval [list $dialog enddialog] [list "$result"]]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list {}]]
  }

  typemethod draw {args} {
    $type createDialog
    set title [from args -title]
    if {[string length "$title"]} {
      $dialog configure -title "$title"
      $headerlabel configure -text "$title"
    }
    $nlistlist delete [$nlistlist items]
    for {set inote 1} {$inote <= [TimeTable NumberOfNotes]} {incr inote} {
      set _number $inote
      set _wholeText "[TimeTable Note $inote]"
      if {[string length "$_wholeText"] > 15} {
	set _text [string range "$_wholeText" 0 15]...
      } else {
	set _text "$_wholeText"
      }
      regsub -all "\n" $_text { } _text
      $nlistlist insert end $inote \
		-data [list $_number "$_text"] \
		-text [format {%-5d %-15s} "$_number" "$_text"]
    }
    focus -force $number 
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list $dialog draw]]
  }

  typemethod _SelectFromList {selectedItem} {
    set elt [$nlistlist itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval [list $dialog withdraw]
    return [eval [list $dialog enddialog] \
		[list $result]]
  }

  typemethod _BrowseFromList {selectedItem} {
    set elt [$nlistlist itemcget $selectedItem -data]
    set value "[lindex $elt 0]"
    $number configure -text "$value"
  }
}

snit::widget TimeTable::displayOneNote {
  TimeTable::TtStdShell DisplayOneNote

  component theTextSW
  component theText

  option -title -default {} -configuremethod _SetTitle

  option -note -default 0 -validatemethod _CheckNote
  method _CheckNote {option value} {
    if {[string equal "$value" {}]} {
      $self configure $option  0
      set value [$self cget $option]
    }
    if {![string is integer -strict "$value"]} {
      error [_ "Expected an integer for %s, got %s" $option $value]
    }
    if {$value < 0 || $value > [TimeTable NumberOfNotes]} {
      error [_ "Note number out of range for %s: %d" $option $value]
    }
    return $value
  }
  method settopframeoption {frame option value} {
    catch [list $theTextSW   configure $option "$value"]
    catch [list $theText     configure $option "$value"]
  }

  method constructtopframe {frame args} {
    set theTextSW [ScrolledWindow $frame.theTextSW \
			-auto vertical -scrollbar vertical]
    pack $theTextSW -expand yes -fill both
    set theText [text $theTextSW.theText -wrap word -state disabled \
			-takefocus no]
    $theTextSW setwidget $theText
  }

  method initializetopframe {frame args} {
    $self configurelist $args
    if {$options(-title) eq ""} {$self configure -title [_ "Displaying one note"]}
    $theText configure -state normal
    $theText delete 1.0 end
    set note [$self cget -note]
    if {$note == 0} {
      $self configure -title {}
    } else {
      $self configure -title [_ "Displaying note %d" $note]
      $theText insert end "[TimeTable Note $note]"
    }
    $theText configure -state disabled
  }
}

proc TimeTable::ViewOneNote {} {
  set number [selectOneNoteDialog draw]
  if {[string equal "$number" {}]} {return}
  if {$number <= 0 || $number > [TimeTable NumberOfNotes]} {
    TtErrorMessage draw -message [_ "Note number out of range: %d" $number]
    return
  }
  displayOneNote draw -note $number
}
    
snit::type TimeTable::editNoteDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent mainframe
  typecomponent headerframe
  typecomponent iconimage
  typecomponent headerlabel
  typecomponent theTextSW
  typecomponent theText
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .editNoteDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title [_ "Editing note NNNNN"]]
    $dialog add save -text [_m "Button|Save"] -command [mytypemethod _Save]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Edit Note Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Editing note NNNNN"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set theTextSW [ScrolledWindow $frame.theTextSW \
			-auto vertical -scrollbar vertical]
    pack $theTextSW -expand yes -fill both
    set theText [text $theTextSW.theText -wrap word -takefocus no]
    $theTextSW setwidget $theText
    bind $theText <Return> "[bind Text <Return>];break"

  }
  typevariable _Note
  typemethod _Save {} {
    $dialog withdraw
    set text "[$theText get 1.0 end]"
    if {$_Note < 1} {
      set result [TimeTable AddNote "$text"]
    } elseif {[TimeTable SetNote $_Note "$text"]} {
      set result $_Note
    } else {
      set result 0
    }      
    return [eval [list $dialog enddialog] [list "$result"]]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [eval [list $dialog enddialog] [list 0]]
  }
  typemethod draw {args} {
    $type createDialog
    set _Note [from args -note 0]
    $theText delete 1.0 end
    if {$_Note < 1} {
      $dialog configure -title [_ "Creating new note"]
      $headerlabel configure -text [_ "Creating new note"]
    } else {
      set title [_ "Editing note %-5d" $_Note]
      $dialog configure -title "$title"
      $headerlabel configure -text "$title"
      $theText insert end "[TimeTable Note $_Note]"
    }
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }
}

proc TimeTable::CreateNewNote {} {
  set newNoteNumber [editNoteDialog draw]
  if {$newNoteNumber > 0} {
    TtInfoMessage draw -message [_ "Note %-5d created." $newNoteNumber]
  } else {
    TtErrorMessage draw -message [_ "Note not created!"]
  }
}

proc TimeTable::EditExistingNote {} {
  set number [selectOneNoteDialog draw]
  if {[string equal "$number" {}]} {return}
  if {$number <= 0 || $number > [TimeTable NumberOfNotes]} {
    TtErrorMessage draw -message [_ "Note number out of range: %d" $number]
    return
  }
  set result [editNoteDialog draw -note $number]
  if {$result > 0} {
    TtInfoMessage draw -message [_ "Note %-5d updated." $result]
  } else {
    TtErrorMessage draw -message [_ "Note %-5d not updated!" $number]
  }
}

snit::type TimeTable::addRemoveNoteDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent mainframe
  typecomponent headerframe
  typecomponent iconimage
  typecomponent headerlabel
  typecomponent trainNumber
  typecomponent noteNumber
  typecomponent stationStop
  typevariable _Mode add
  typevariable _AtStation no
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .addRemoveNoteDialog  \
			-bitmap questhead -default 0 -cancel 1 -modal local \
			-transient yes -parent . -side bottom \
			-title [_ "Add/Remove note to/from train (at station)"]]
    $dialog add addremove -text [_m "Button|Add/Remove"] -command [mytypemethod _Update]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] \
		-command [list HTMLHelp::HTMLHelp help {Add Remove Note Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Add/Remove note to/from train (at station)"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set lwidth [_mx "Label|Train:" "Label|Note Number:" "Label|At Station:"]
    set trainNumber [LabelComboBox $frame.trainNumber \
				-label [_m "Label|Train:"] \
				-labelwidth $lwidth \
				-editable no \
				-modifycmd [mytypemethod _TrainNumberUpdated]]
    pack $trainNumber -fill x
    set noteNumber [LabelSpinBox $frame.noteNumber \
				-label [_m "Label|Note Number:"] \
				-labelwidth $lwidth \
				-editable no]
    pack $noteNumber -fill x
    set stationStop [LabelComboBox $frame.stationStop \
				-label [_m "Label|At Station:"] \
				-labelwidth $lwidth \
				-editable no \
				-state disabled \
				-modifycmd [mytypemethod _StationStopUpdated]]
    pack $stationStop -fill x
  }
  typemethod _TrainNumberUpdated {} {
    set train [TimeTable FindTrainByNumber "[$trainNumber cget -text]"]
    if {$_AtStation} {
      set stationList {}
      ForEveryStop $train stop {
	set _sname "[Station_Name [TimeTable IthStation [Stop_StationIndex $stop]]]"
	lappend stationList "$_sname"
      }
      $stationStop configure -values $stationList
      $stationStop set [lindex $stationList 0]
    }
    if {[string equal "$_Mode" "remove"]} {
      set notes {}
      if {$_AtStation} {
      	set stopIndex [lsearch [$stationStop cget -values] [$stationStop get]]
      	set stop [Train_StopI $train $stopIndex]
	for {set i 0} {$i < [Stop_NumberOfNotes $stop]} {incr i} {
	  lappend notes [Stop_Note $stop $i]
	}
      } else {
	for {set i 0} {$i < [Train_NumberOfNotes $train]} {incr i} {
	  lappend notes [Train_Note $train $i]
	}
      }
      $noteNumber configure -values $notes
    }
  }
  typemethod _StationStopUpdated {} {
    set train [TimeTable FindTrainByNumber "[$trainNumber cget -text]"]
    if {[string equal "$_Mode" "remove"]} {
      set notes {}
      set stopIndex [lsearch [$stationStop cget -values] [$stationStop get]]
      set stop [Train_StopI $train $stopIndex]
      for {set i 0} {$i < [Stop_NumberOfNotes $stop]} {incr i} {
	lappend notes [Stop_Note $stop $i]
      }
      $noteNumber configure -values $notes
    }
  }
  typemethod _Update {} {
    $dialog withdraw
    set train [TimeTable FindTrainByNumber "[$trainNumber cget -text]"]
    if {$_AtStation} {
      set stopIndex [lsearch [$stationStop cget -values] [$stationStop get]]
    } else {
      set stopIndex -1
    }
    set note  [$noteNumber cget -text]
    switch -exact $_Mode {
      add {
	if {$_AtStation} {
	  Train_AddNoteToStop $train $stopIndex $note
	} else {
	  Train_AddNoteToTrain $train $note
        }
      }
      remove {
	if {$_AtStation} {
	  Train_RemoveNoteFromStop $train $stopIndex $note
	} else {
	  Train_RemoveNoteFromTrain $train $note
	}
      }
    }
    set result [list $train $note $stopIndex]
    return [$dialog enddialog $result]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog {}]
  }
  typemethod draw {args} {
    $type createDialog
    set _Mode [from args -mode add]
    if {[lsearch -exact {add remove} $_Mode] < 0} {
      error [_ "Not a legal value for -mode: %s" $_Mode]
    }
    set _AtStation [from args -atstation no]
    if {![string is boolean -strict $_AtStation]} {
      error [_ "Not a boolean value for -atstation: %s" $_AtStation]
    }
    set trains {}
    ForEveryTrain [TimeTable cget -this] train {
      set _number [Train_Number $train]
      lappend trains "$_number"
    }
    $trainNumber configure -values $trains
    $trainNumber set [lindex $trains 0]
    set train [TimeTable FindTrainByNumber "[$trainNumber cget -text]"]
    $stationStop configure -text {}
    if {$_AtStation} {
      $stationStop configure -state normal
      set stationList {}
      ForEveryStop $train stop {
	set _sname "[Station_Name [TimeTable IthStation [Stop_StationIndex $stop]]]"
	lappend stationList "$_sname"
      }
      $stationStop configure -values $stationList
      $stationStop set [lindex $stationList 0]
    } else {
      $stationStop configure -state disabled
    }
    switch -exact $_Mode {
      add {
	if {$_AtStation} {
	  set title [_ "Add note to train at station"]
	} else {
	  set title [_ "Add note to train"]
	}
	$noteNumber configure -range [list 1 [TimeTable NumberOfNotes] 1]
	$dialog itemconfigure addremove -text [_m "Button|Add"]
      }
      remove {
	if {$_AtStation} {
	  set title [_ "Remove note from train at station"]
	} else {
	  set title [_ "Remove note from train"]
	}
	$dialog itemconfigure addremove -text [_m "Button|Remove"]
	set notes {}
	if {$_AtStation} {
          set stopIndex [lsearch [$stationStop cget -values] [$stationStop get]]
          #puts stderr "*** $type draw (remove): stopIndex = '$stopIndex'"
	  set stop [Train_StopI $train $stopIndex]
	  for {set i 0} {$i < [Stop_NumberOfNotes $stop]} {incr i} {
	    lappend notes [Stop_Note $stop $i]
	  }
        } else {
	  set train [TimeTable FindTrainByNumber "[$trainNumber cget -text]"]
	  for {set i 0} {$i < [Train_NumberOfNotes $train]} {incr i} {
	    lappend notes [Train_Note $train $i]
	  }
	}
	$noteNumber configure -values $notes
      }
    }
    $dialog configure -title "$title"
    $headerlabel configure -text "$title"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }
}

proc TimeTable::AddNoteToTrain {} {
  set result [addRemoveNoteDialog draw -mode add -atstation no]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    TtInfoMessage draw -message [_ "Note %d added to %s" $note $trainNumber]
  }
}

proc TimeTable::AddNoteToTrainAtStation {} {
  set result [addRemoveNoteDialog draw -mode add -atstation yes]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    set stop [Train_StopI [lindex $result 0] [lindex $result 2]]
    set stationName [Station_Name [TimeTable IthStation [Stop_StationIndex $stop]]]
    TtInfoMessage draw -message [_ "Note %d added to %s at %s" $note $trainNumber $stationName]
  }
}

proc TimeTable::RemoveNoteFromTrain {} {
  set result [addRemoveNoteDialog draw -mode remove -atstation no]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    TtInfoMessage draw -message [_ "Note %d removed from %s" $note $trainNumber]
  }
}

proc TimeTable::RemoveNoteFromTrainAtStation {} {
  set result [addRemoveNoteDialog draw -mode remove -atstation yes]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    set stop [Train_StopI [lindex $result 0] [lindex $result 2]]
    set stationName [Station_Name [TimeTable IthStation [Stop_StationIndex $stop]]]
    TtInfoMessage draw -message [_ "Note %d removed from %s at %s" $note $trainNumber $stationName]
  }
}

catch {
$TimeTable::Main menu add view separator
$TimeTable::Main menu add view command -label [_m "Menu|View|View One Note"] \
			      -command TimeTable::ViewOneNote \
			      -dynamichelp [_ "View one note"] -state disabled
$TimeTable::Main menu add view command -label [_m "Menu|View|View All Notes"] \
			      -command TimeTable::ViewAllNotes \
			      -dynamichelp [_ "View all notes"] -state disabled
$TimeTable::Main menu add notes command -label [_m "Menu|Notes|Create New Note"] \
			       -command TimeTable::CreateNewNote \
			       -dynamichelp [_ "Create new note"]
$TimeTable::Main buttons add ttk::button createNote \
      -text [_m "Button|Create New Note"] \
      -command TimeTable::CreateNewNote \
      -state disabled
#				-helptext [_ "Create new note"] 
image create photo CreateNoteImage -file [file join $TimeTable::ImageDir createnote.gif]
$TimeTable::Main toolbar addbutton tools createNote \
				-image CreateNoteImage \
      -command TimeTable::CreateNewNote \
      -state disabled \
      -helptext [_ "Create new note"] 

$TimeTable::Main menu add notes command -label [_m "Menu|Notes|Edit Existing Note"] \
			       -command TimeTable::EditExistingNote \
			       -dynamichelp [_ "Edit existing note"]
$TimeTable::Main buttons add ttk::button editNote -text [_m "Button|Edit Existing Note"] \
      -command TimeTable::EditExistingNote \
      -state disabled
#				-helptext [_ "Edit existing note"] 
image create photo EditNoteImage -file [file join $TimeTable::ImageDir editnote.gif]
$TimeTable::Main toolbar addbutton tools editNote \
				-image EditNoteImage \
				-command TimeTable::EditExistingNote \
				-helptext [_ "Edit existing note"] -state disabled

$TimeTable::Main menu add notes separator
$TimeTable::Main menu add notes command -label [_m "Menu|Notes|Add note to train"] \
			       -command TimeTable::AddNoteToTrain \
			       -dynamichelp [_ "Add note to train"]
$TimeTable::Main buttons add ttk::button addNoteToTrain -text [_m "Button|Add note to train"] \
      -command TimeTable::AddNoteToTrain \
       -state disabled
#				-helptext [_ "Add note to train"]
image create photo AddNoteToTrainImage \
				-file [file join $TimeTable::ImageDir addnotetotrain.gif]
$TimeTable::Main toolbar addbutton tools addNoteToTrain \
				-image AddNoteToTrainImage \
				-command TimeTable::AddNoteToTrain \
				-helptext [_ "Add note to train"] -state disabled

$TimeTable::Main menu add notes command -label [_m "Menu|Notes|Add note to train at station stop"] \
			       -command TimeTable::AddNoteToTrainAtStation \
			       -dynamichelp [_ "Add note to train at station stop"]

$TimeTable::Main buttons add ttk::button addNoteToTrainAtStation \
				 -text [_m "Button|Add note to train at station stop"] \
      -command TimeTable::AddNoteToTrainAtStation \
      -state disabled
#				-helptext [_ "Add note to train at station stop"] 
				
image create photo AddNoteToTrainAtStationImage \
			-file [file join $TimeTable::ImageDir addnotetotrainatstation.gif]
$TimeTable::Main toolbar addbutton tools addNoteToTrainAtStation \
				-image AddNoteToTrainAtStationImage \
				-command TimeTable::AddNoteToTrainAtStation \
				-helptext [_ "Add note to train at station stop"] \
				-state disabled

$TimeTable::Main menu add notes separator
$TimeTable::Main menu add notes command -label [_m "Menu|Notes|Remove note from train"] \
			       -command TimeTable::RemoveNoteFromTrain \
			       -dynamichelp [_ "Remove note from train"]
$TimeTable::Main buttons add ttk::button removeNoteFromTrain -text [_m "Button|Remove note from train"] \
      -command TimeTable::RemoveNoteFromTrain\
       -state disabled
#				-helptext [_ "Remove note from train"]
image create photo RemoveNoteFromTrainImage \
				-file [file join $TimeTable::ImageDir removenotefromtrain.gif]
$TimeTable::Main toolbar addbutton tools removeNoteFromTrain \
				-image RemoveNoteFromTrainImage \
				-command TimeTable::RemoveNoteFromTrain \
				-helptext [_ "Remove note from train"] -state disabled

$TimeTable::Main menu add notes command -label [_m "Menu|Notes|Remove note from train at station stop"] \
			       -command TimeTable::RemoveNoteFromTrainAtStation \
			       -dynamichelp [_ "Remove note from train at station stop"]
$TimeTable::Main buttons add ttk::button removeNoteFromTrainAtStation \
				-text [_m "Button|Remove note from train at station stop"] \
      -command TimeTable::RemoveNoteFromTrainAtStation\
      -state disabled
#				-helptext [_ "Remove note from train at station stop"] 
image create photo RemoveNoteFromTrainAtStationImage \
				-file [file join $TimeTable::ImageDir removenotefromtrainatstation.gif]
$TimeTable::Main toolbar addbutton tools removeNoteFromTrainAtStation \
				-image RemoveNoteFromTrainAtStationImage \
				-command TimeTable::RemoveNoteFromTrainAtStation \
				-helptext [_ "Remove note from train at station stop"] -state disabled

} message
#puts stderr "*** TTNotes: $message: $errorInfo"

proc TimeTable::EnableNoteCommands {} {
  variable Main
  $Main mainframe setmenustate notes:menu normal
  $Main menu entryconfigure view {View One Note} -state normal
  $Main menu entryconfigure view {View All Notes} -state normal
  $Main buttons itemconfigure createNote -state normal
  $Main toolbar buttonconfigure tools createNote -state normal
  $Main buttons itemconfigure editNote -state normal
  $Main toolbar buttonconfigure tools editNote -state normal
  $Main buttons itemconfigure addNoteToTrain -state normal
  $Main toolbar buttonconfigure tools addNoteToTrain -state normal
  $Main buttons itemconfigure addNoteToTrainAtStation -state normal
  $Main toolbar buttonconfigure tools addNoteToTrainAtStation -state normal
  $Main buttons itemconfigure removeNoteFromTrain -state normal
  $Main toolbar buttonconfigure tools removeNoteFromTrain -state normal
  $Main buttons itemconfigure removeNoteFromTrainAtStation -state normal
  $Main toolbar buttonconfigure tools removeNoteFromTrainAtStation -state normal
}

package provide TTNotes 1.0


