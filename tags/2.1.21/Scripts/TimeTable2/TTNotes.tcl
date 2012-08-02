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


catch {SplashWorkMessage {Loading Notes Code} 77}

package require snit
package require BWidget
package require BWLabelSpinBox
package require BWLabelComboBox

snit::type viewAllNotesDialog {
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
    set dialog [Dialog::create .viewAllNotesDialog \
			-bitmap info \
			-default 0 -cancel 0 -modal none -transient yes \
			-parent . -side bottom -title {All Available Notes}]
    $dialog add -name dismis -text Dismis -command [mytypemethod _Dismis]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Dismis]
    set mainframe [$dialog getframe]
    set headerframe $mainframe.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    set notesSWindow $mainframe.notesSWindow
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {All Available Notes}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    ScrolledWindow::create $notesSWindow \
		-auto vertical -scrollbar vertical
    pack $notesSWindow -expand yes -fill both
    set notesSFrame [ScrollableFrame::create $notesSWindow.notesSFrame]
    pack $notesSFrame -expand yes -fill both
    $notesSWindow setwidget $notesSFrame
    set notesFrame [$notesSFrame getframe]
    Label::create $notesFrame.number0 -text {Number} -anchor e
    Label::create $notesFrame.text0   -text {Begining text} -anchor w
    foreach w  {number text} \
	    c  {0      1} \
	    sk {e      w} {
      grid configure $notesFrame.${w}0 -column $c -row 0 -sticky $sk
    }
  }
  typemethod _Dismis {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list {}]]
  }

  typevariable _NumberOfNotesInDialog 0
  typemethod draw {args} {
    $type createDialog
    for {set inote 1} {$inote <= [TimeTable NumberOfNotes]} {incr inote} {
      if {$inote > $_NumberOfNotesInDialog} {
	Button::create $notesFrame.number$inote -anchor e
	Label::create  $notesFrame.text$inote   -anchor w
	foreach w  {number text} \
		c  {0      1} \
		sk {e      w} {
	  grid configure $notesFrame.${w}$inote -column $c -row $inote -sticky $sk
	}
	incr _NumberOfNotesInDialog
      }
      $notesFrame.number$inote configure -text $inote \
					 -command [list displayOneNote draw \
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
    return [eval [list Dialog::draw $dialog]]      
  }
}

proc ViewAllNotes {} {
  viewAllNotesDialog draw
}

snit::type selectOneNoteDialog {
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
    set dialog [Dialog::create .selectOneNoteDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title {Select one note}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Select One Note Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Select one note}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set nlist [eval [list ScrolledWindow::create $frame.nlist] -scrollbar both -auto both]
    pack $nlist -expand yes -fill both
    set nlistlist [eval [list ListBox::create $frame.nlist.list] -selectmode single]
    pack $nlistlist -expand yes -fill both
    $nlist setwidget $nlistlist
    $nlistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $nlistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set number [LabelEntry::create $frame.number -label {Note Number Selection:}]
    pack $number -fill x
    $number bind <Return> [mytypemethod _OK]
  }

  typemethod _OK {} {
    Dialog::withdraw $dialog
    set result "[$number cget -text]"
    return [eval [list Dialog::enddialog $dialog] [list "$result"]]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list {}]]
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
    BWidget::focus set $number 
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [eval [list Dialog::draw $dialog]]
  }

  typemethod _SelectFromList {selectedItem} {
    set elt [$nlistlist itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval [list Dialog::withdraw $dialog]
    return [eval [list Dialog::enddialog $dialog] \
		[list $result]]
  }

  typemethod _BrowseFromList {selectedItem} {
    set elt [$nlistlist itemcget $selectedItem -data]
    set value "[lindex $elt 0]"
    $number configure -text "$value"
  }
}

snit::widget displayOneNote {
  TtStdShell DisplayOneNote

  component theTextSW
  component theText

  option -title -default {Displaying one note} -configuremethod _SetTitle

  option -note -default 0 -validatemethod _CheckNote
  method _CheckNote {option value} {
    if {[string equal "$value" {}]} {
      $self configure $option  0
      set value [$self cget $option]
    }
    if {![string is integer -strict "$value"]} {
      error "Expected an integer for $option, got $value"
    }
    if {$value < 0 || $value > [TimeTable NumberOfNotes]} {
      error "Note number out of range for $option: $value"
    }
    return $value
  }
  method settopframeoption {frame option value} {
    catch [list $theTextSW   configure $option "$value"]
    catch [list $theText     configure $option "$value"]
  }

  method constructtopframe {frame args} {
    set theTextSW [ScrolledWindow::create $frame.theTextSW \
			-auto vertical -scrollbar vertical]
    pack $theTextSW -expand yes -fill both
    set theText [text $theTextSW.theText -wrap word -state disabled \
			-takefocus no]
    pack $theText -expand yes -fill both
    $theTextSW setwidget $theText
  }

  method initializetopframe {frame args} {
    $self configurelist $args
    $theText configure -state normal
    $theText delete 1.0 end
    set note [$self cget -note]
    if {$note == 0} {
      $self configure -title {}
    } else {
      $self configure -title "Displaying note $note"
      $theText insert end "[TimeTable Note $note]"
    }
    $theText configure -state disabled
  }
}

proc ViewOneNote {} {
  set number [selectOneNoteDialog draw]
  if {[string equal "$number" {}]} {return}
  if {$number <= 0 || $number > [TimeTable NumberOfNotes]} {
    TtErrorMessage draw -message "Note number out of range: $number"
    return
  }
  displayOneNote draw -note $number
}
    
snit::type editNoteDialog {
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
    set dialog [Dialog::create .editNoteDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title {Editing note NNNNN}]
    $dialog add -name save -text Save -command [mytypemethod _Save]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Edit Note Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Editing note NNNNN}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set theTextSW [ScrolledWindow::create $frame.theTextSW \
			-auto vertical -scrollbar vertical]
    pack $theTextSW -expand yes -fill both
    set theText [text $theTextSW.theText -wrap word -takefocus no]
    pack $theText -expand yes -fill both
    $theTextSW setwidget $theText
    bind $theText <Return> "[bind Text <Return>];break"

  }
  typevariable _Note
  typemethod _Save {} {
    Dialog::withdraw $dialog
    set text "[$theText get 1.0 end]"
    if {$_Note < 1} {
      set result [TimeTable AddNote "$text"]
    } elseif {[TimeTable SetNote $_Note "$text"]} {
      set result $_Note
    } else {
      set result 0
    }      
    return [eval [list Dialog::enddialog $dialog] [list "$result"]]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list 0]]
  }
  typemethod draw {args} {
    $type createDialog
    set _Note [from args -note 0]
    $theText delete 1.0 end
    if {$_Note < 1} {
      $dialog configure -title "Creating new note"
      $headerlabel configure -text "Creating new note"
    } else {
      set title "[format {Editing note %-5d} $_Note]"
      $dialog configure -title "$title"
      $headerlabel configure -text "$title"
      $theText insert end "[TimeTable Note $_Note]"
    }
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [Dialog::draw $dialog]
  }
}

proc CreateNewNote {} {
  set newNoteNumber [editNoteDialog draw]
  if {$newNoteNumber > 0} {
    TtInfoMessage draw -message "[format {Note %-5d created.} $newNoteNumber]"
  } else {
    TtErrorMessage draw -message "Note not created!"
  }
}

proc EditExistingNote {} {
  set number [selectOneNoteDialog draw]
  if {[string equal "$number" {}]} {return}
  if {$number <= 0 || $number > [TimeTable NumberOfNotes]} {
    TtErrorMessage draw -message "Note number out of range: $number" 
    return
  }
  set result [editNoteDialog draw -note $number]
  if {$result > 0} {
    TtInfoMessage draw -message "[format {Note %-5d updated.} $result]"
  } else {
    TtErrorMessage draw -message "[format {Note %-5d not updated!} $number]"
  }
}

snit::type addRemoveNoteDialog {
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
    set dialog [Dialog::create .addRemoveNoteDialog  \
			-bitmap questhead -default 0 -cancel 1 -modal local \
			-transient yes -parent . -side bottom \
			-title {Add/Remove note to/from train [at station]}]
    $dialog add -name addremove -text Add/Remove -command [mytypemethod _Update]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help \
		-command [list HTMLHelp::HTMLHelp help {Add Remove Note Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Add/Remove note to/from train [at station]}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set trainNumber [LabelComboBox::create $frame.trainNumber \
				-label "Train: " \
				-labelwidth 14 \
				-editable no \
				-modifycmd [mytypemethod _TrainNumberUpdated]]
    pack $trainNumber -fill x
    set noteNumber [LabelSpinBox::create $frame.noteNumber \
				-label "Note Number: " \
				-labelwidth 14 \
				-editable no]
    pack $noteNumber -fill x
    set stationStop [LabelComboBox::create $frame.stationStop \
				-label "At Station: " \
				-labelwidth 14 \
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
      $stationStop setvalue first
    }
    if {[string equal "$_Mode" "remove"]} {
      set notes {}
      if {$_AtStation} {
      	set stopIndex [$stationStop getvalue]
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
      set stopIndex [$stationStop getvalue]
      set stop [Train_StopI $train $stopIndex]
      for {set i 0} {$i < [Stop_NumberOfNotes $stop]} {incr i} {
	lappend notes [Stop_Note $stop $i]
      }
      $noteNumber configure -values $notes
    }
  }
  typemethod _Update {} {
    Dialog::withdraw $dialog
    set train [TimeTable FindTrainByNumber "[$trainNumber cget -text]"]
    if {$_AtStation} {
      set stopIndex [$stationStop getvalue]
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
    return [Dialog::enddialog $dialog $result]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog {}]
  }
  typemethod draw {args} {
    $type createDialog
    set _Mode [from args -mode add]
    if {[lsearch -exact {add remove} $_Mode] < 0} {
      error "Not a legal value for -mode: $_Mode"
    }
    set _AtStation [from args -atstation no]
    if {![string is boolean -strict $_AtStation]} {
      error "Not a boolean value for -atstation: $_AtStation"
    }
    set trains {}
    ForEveryTrain [TimeTable cget -this] train {
      set _number [Train_Number $train]
      lappend trains "$_number"
    }
    $trainNumber configure -values $trains
    $trainNumber setvalue first
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
      $stationStop setvalue first
    } else {
      $stationStop configure -state disabled
    }
    switch -exact $_Mode {
      add {
	set title "Add note to train"
	$noteNumber configure -range [list 1 [TimeTable NumberOfNotes] 1]
	$dialog itemconfigure addremove -text Add
      }
      remove {
        set title "Remove note from train"
	$dialog itemconfigure addremove -text Remove
	set notes {}
	if {$_AtStation} {
	  set stopIndex [$stationStop getvalue]
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
    if {$_AtStation} {
      append title " at station"
    }
    $dialog configure -title "$title"
    $headerlabel configure -text "$title"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [Dialog::draw $dialog]
  }
}

proc AddNoteToTrain {} {
  set result [addRemoveNoteDialog draw -mode add -atstation no]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    TtInfoMessage draw -message "Note $note added to $trainNumber"
  }
}

proc AddNoteToTrainAtStation {} {
  set result [addRemoveNoteDialog draw -mode add -atstation yes]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    set stop [Train_StopI [lindex $result 0] [lindex $result 2]]
    set stationName [Station_Name [TimeTable IthStation [Stop_StationIndex $stop]]]
    TtInfoMessage draw -message "Note $note added to $trainNumber at $stationName"
  }
}

proc RemoveNoteFromTrain {} {
  set result [addRemoveNoteDialog draw -mode remove -atstation no]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    TtInfoMessage draw -message "Note $note removed from $trainNumber"
  }
}

proc RemoveNoteFromTrainAtStation {} {
  set result [addRemoveNoteDialog draw -mode remove -atstation yes]
  if {[llength $result] > 0} {
    set note [lindex $result 1]
    set trainNumber [Train_Number [lindex $result 0]]
    set stop [Train_StopI [lindex $result 0] [lindex $result 2]]
    set stationName [Station_Name [TimeTable IthStation [Stop_StationIndex $stop]]]
    TtInfoMessage draw -message "Note $note removed from $trainNumber at $stationName"
  }
}

catch {
$::Main menu add view separator
$::Main menu add view command -label {View One Note} \
			      -command ViewOneNote \
			      -dynamichelp "View one note"
$::Main menu add view command -label {View All Notes} \
			      -command ViewAllNotes \
			      -dynamichelp "View all notes"
$::Main menu add notes command -label {Create New Note} \
			       -command CreateNewNote \
			       -dynamichelp "Create new note"
$::Main buttons add -name createNote -text {Create New Note} -anchor w \
				-command CreateNewNote \
				-helptext "Create new note"
global ImageDir
image create photo CreateNoteImage -file [file join $ImageDir createnote.gif]
$::Main toolbar addbutton tools createNote \
				-image CreateNoteImage \
				-command CreateNewNote \
				-helptext "Create new note"

$::Main menu add notes command -label {Edit Existing Note} \
			       -command EditExistingNote \
			       -dynamichelp "Edit existing note"
$::Main buttons add -name editNote -text {Edit Existing Note} -anchor w \
				-command EditExistingNote \
				-helptext "Edit existing note"
image create photo EditNoteImage -file [file join $ImageDir editnote.gif]
$::Main toolbar addbutton tools editNote \
				-image EditNoteImage \
				-command EditExistingNote \
				-helptext "Edit existing note"

$::Main menu add notes separator
$::Main menu add notes command -label {Add note to train} \
			       -command AddNoteToTrain \
			       -dynamichelp "Add note to train"
$::Main buttons add -name addNoteToTrain -text {Add note to train} -anchor w \
				-command AddNoteToTrain \
				-helptext "Add note to train"
image create photo AddNoteToTrainImage \
				-file [file join $ImageDir addnotetotrain.gif]
$::Main toolbar addbutton tools addNoteToTrain \
				-image AddNoteToTrainImage \
				-command AddNoteToTrain \
				-helptext "Add note to train"

$::Main menu add notes command -label {Add note to train at station stop} \
			       -command AddNoteToTrainAtStation \
			       -dynamichelp "Add note to train at station stop"

$::Main buttons add -name addNoteToTrainAtStation \
				 -text {Add note to train at station stop} \
				-anchor w \
				-command AddNoteToTrainAtStation \
				-helptext "Add note to train at station stop"
image create photo AddNoteToTrainAtStationImage \
			-file [file join $ImageDir addnotetotrainatstation.gif]
$::Main toolbar addbutton tools addNoteToTrainAtStation \
				-image AddNoteToTrainAtStationImage \
				-command AddNoteToTrainAtStation \
				-helptext "Add note to train at station stop"

$::Main menu add notes separator
$::Main menu add notes command -label {Remove note from train} \
			       -command RemoveNoteFromTrain \
			       -dynamichelp "Remove note from train"
$::Main buttons add -name removeNoteFromTrain -text {Remove note from train} \
				-anchor w \
				-command RemoveNoteFromTrain\
				-helptext "Remove note from train"
image create photo RemoveNoteFromTrainImage \
				-file [file join $ImageDir removenotefromtrain.gif]
$::Main toolbar addbutton tools removeNoteFromTrain \
				-image RemoveNoteFromTrainImage \
				-command RemoveNoteFromTrain \
				-helptext "Remove note from train"

$::Main menu add notes command -label {Remove note from train at station stop} \
			       -command RemoveNoteFromTrainAtStation \
			       -dynamichelp "Remove note from train at station stop"
$::Main buttons add -name removeNoteFromTrainAtStation \
				-text {Remove note from train at station stop} \
				-anchor w \
				-command RemoveNoteFromTrainAtStation\
				-helptext "Remove note from train at station stop"
image create photo RemoveNoteFromTrainAtStationImage \
				-file [file join $ImageDir removenotefromtrainatstation.gif]
$::Main toolbar addbutton tools removeNoteFromTrainAtStation \
				-image RemoveNoteFromTrainAtStationImage \
				-command RemoveNoteFromTrainAtStation \
				-helptext "Remove note from train at station stop"

} message
#puts stderr "*** TTNotes: $message: $errorInfo"


package provide TTNotes 1.0


