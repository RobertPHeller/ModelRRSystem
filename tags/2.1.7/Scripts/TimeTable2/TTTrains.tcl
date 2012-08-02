#* 
#* ------------------------------------------------------------------
#* TTTrains.tcl - Train related code
#* Created by Robert Heller on Sat Dec 31 13:19:08 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

catch {SplashWorkMessage {Loading Train Code} 44}

package require snit
package require BWLabelSpinBox
package require BWLabelComboBox

snit::type SelectOneTrainDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerlabel
  typecomponent number
  typecomponent tlist
  typecomponent tlistlist

  typeconstructor {
    set dialog [Dialog::create .selectOneTrainDialog \
			-class SelectOneTrainDialog -bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title {Select one train}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list BWHelp::HelpTopic SelectOneTrainDialog]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Select one train}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set tlist [eval [list ScrolledWindow::create $frame.tlist] -scrollbar both -auto both]
    pack $tlist -expand yes -fill both
    set tlistlist [eval [list ListBox::create $frame.tlist.list] -selectmode single]
    pack $tlistlist -expand yes -fill both
    $tlist setwidget $tlistlist
    $tlistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $tlistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set number [LabelEntry::create $frame.number -label {Train Number Selection:}]
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
    set title [from args -title]
    if {[string length "$title"]} {
      $dialog configure -title "$title"
      $headerlabel configure -text "$title"
    }
    $tlistlist delete [$tlistlist items]
    set tindex 0
    ForEveryTrain [TimeTable cget -this] train {
      set _number [Train_Number $train]
      set _name   [Train_Name   $train]
      incr tindex
      $tlistlist insert end $tindex \
		-dat
a [list "$_number" "$_name"] \
		-text [format {%-5s %-15s} "$_number" "$_name"]
    }
    BWidget::focus set $number 
    return [eval [list Dialog::draw $dialog]]
  }

  typemethod _SelectFromList {selectedItem} {
    set elt [$tlistlist itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval [list Dialog::withdraw $dialog]
    return [eval [list Dialog::enddialog $dialog] \
		[list $result]]
  }

  typemethod _BrowseFromList {selectedItem} {
    set elt [$tlistlist itemcget $selectedItem -data]
    set value "[lindex $elt 0]"
    $number configure -text "$value"
  }
}

package require DWpanedw

snit::widget displayOneTrain {
  TtStdShell DisplayOneTrain

  component numberLabel
  component nameLabel
  component classLabel
  component speedLabel
  component notesLabel
  component snPane
  component schedPane
  component notesPane
  component schedSWindow
  component schedFrame
  component notesSWindow
  component notesText

  option -title -default {Displaying one train} \
		-configuremethod _SetTitle

  option -train -default NULL -validatemethod _CheckTrain
  method _CheckTrain {option value} {
    if {[string equal "$value" {}]} {
      $self configure $option NULL
      set value [$self cget $option]
    }
    if {![string equal "$value" NULL] &&
	 [regexp {^_[0-9a-z]*_Train_p$} "$value"] < 1} {
      error "Not a pointer to a train: $value"
    }
  }    

  option -minutes -default -1 -validatemethod _CheckDouble
  method _CheckDouble {option value} {
    if {![string is double -strict "$value"]} {
      error "Not a number for option $option: $value"
    }
  }

  method settopframeoption {frame option value} {
    catch [list $numberLabel configure $option "$value"]
    catch [list $nameLabel configure $option "$value"]
    catch [list $classLabel configure $option "$value"]
    catch [list $speedLabel configure $option "$value"]
    catch [list $notesLabel configure $option "$value"]
    catch [list $snPane configure $option "$value"]
    catch [list $schedPane configure $option "$value"]
    catch [list $notesPane configure $option "$value"]
    catch [list $schedSWindow configure $option "$value"]
    catch [list $schedFrame configure $option "$value"]
    catch [list $notesSWindow configure $option "$value"]
    catch [list $notesText configure $option "$value"]
  }

  method constructtopframe {frame args} {
    set header [frame $frame.header]
    pack $header -fill x
    set numberLabel [Label $header.number -relief sunken]
    pack $numberLabel -side left
    set nameLabel [Label $header.name -relief sunken]
    pack $nameLabel -side left -expand yes -fill x
    pack [label $header.l1 -text {Class: }] -side left
    set classLabel [Label $header.class -relief sunken]
    pack $classLabel -side left
    pack [label $header.l2 -text {Speed: }] -side left
    set speedLabel [Label $header.speed -relief sunken]
    pack $speedLabel -side left
    pack [label $header.l3 -text {Notes: }] -side left
    set notesLabel [Label $header.notes -relief sunken]
    pack $notesLabel -side right

    set snPane [eval [list PanedWindow::create $frame.schedNotes] -side right]
    pack $snPane -expand yes -fill both
    set schedPane [$snPane add -name sched]
    set notesPane [$snPane add -name notes]

    set schedSWindow [eval [list ScrolledWindow::create $frame.schedscroll] -scrollbar both -auto both]
    pack $schedSWindow -in $schedPane -expand yes -fill both

    set schedFrame [eval [list ScrollableFrame::create $frame.schedscroll.sched] -width 300 -height 150  ]
    pack $schedFrame -expand yes -fill both
    $schedSWindow setwidget $schedFrame
    Label $schedFrame.mile0 -text {Mile} -anchor e
    Label $schedFrame.arrival0 -text {Arival} -anchor w
    Label $schedFrame.station0 -text {Station} -anchor w
    Label $schedFrame.depart0  -text {Depart} -anchor e
    Label $schedFrame.notes0 -text {Notes} -anchor w

    foreach wid  {mile arrival station depart notes} \
	    c    {0    1       2       3      4} \
	    sk   {e    e       nsw     e      w} {
      grid configure $schedFrame.${wid}0 \
    	-column $c -row 0 -sticky $sk
    }

    set notesSWindow [eval [list ScrolledWindow::create $frame.notescroll] -scrollbar both -auto both]
    pack $notesSWindow -in $notesPane -expand yes -fill both

    set notesText [eval [list text $frame.notescroll.notes] -height 8 -width 24]
    pack $notesText -expand yes -fill both
    $notesSWindow setwidget $notesText
  }

  method initializetopframe {frame args} {
    $self configure -minutes -1
    $self configurelist $args
    set rows [lindex [grid size $schedFrame] 1]
    for {set ir 1} {$ir < $rows} {incr ir} {
      eval [concat grid forget [grid slave $schedFrame -row $ir]]
    }
    $notesText delete 1.0 end 
    set nlist {}
    set train [$self cget -train]
#    puts stderr "${self}::initializetopframe: train = $train"
    set minutes [$self cget -minutes]
#    puts stderr "${self}::initializetopframe: minutes = $minutes"
    if {[string equal $train NULL]} {
      $numberLabel configure -text {}
      $nameLabel configure -text {}
      $classLabel configure -text {0}
      $speedLabel configure -text {0}
      $notesLabel configure -text {}
      $self configure -title {}
    } else {
      $numberLabel configure -text "[Train_Number $train]"
      $nameLabel configure -text "[Train_Name $train]"
      $self configure -title "[Train_Number $train] [Train_Name $train]"
      $classLabel configure -text "[Train_ClassNumber $train]"
      $speedLabel configure -text "[Train_Speed $train]"
      set tnotes {}
      for {set i 0} {$i < [Train_NumberOfNotes $train]} {incr i} {
        set tn [Train_Note $train $i]
        lappend tnotes $tn
        if {[lsearch -exact $nlist $tn] < 0} {lappend nlist $tn}
      }
      $notesLabel configure -text "$tnotes"
      set departure [Train_Departure $train]
      set oldDepart -1
      set oldSmile -1
      set speed  [Train_Speed $train]
      set ir 1
      set locationSMile -1
      ForEveryStop $train stop {
        set sindex [Stop_StationIndex $stop]
        set station [TimeTable IthStation $sindex]
        set smile [Station_SMile $station]
#	puts stderr "${self}::initializetopframe: station = $station, smile = $smile, ir = $ir"
        if {$oldDepart >= 0} {
	  set arrival [expr $oldDepart + (abs($smile - $oldSmile) * (double($speed) / 60.0))]
#	  puts stderr "${self}::initializetopframe: arrival = $arrival"
	  if {$minutes >= $oldDepart && $minutes < $arrival} {
	    set locationSMile [expr (($minutes - $oldDepart) / (double($speed) / 60.0)) + $oldSmile]
	  }
        } else {
	  set arrival $departure
        }
        set depart [Stop_Departure $stop $arrival]
#	puts stderr "${self}::initializetopframe: depart = $depart"
	if {$minutes >= $arrival && $minutes < $depart} {
	  set locationSMile $smile
	}
#	puts stderr "${self}::initializetopframe: locationSMile = $locationSMile"
        set notes {}
        for {set i 0} {$i < [Stop_NumberOfNotes $stop]} {incr i} {
	  set anote [Stop_Note $stop $i]
	  lappend notes $anote
	  if {[lsearch -exact $nlist $anote] < 0} {lappend nlist $anote}
        }
#        puts stderr "*** displayOneTrain:resetTrainValues: ir = $ir"
#        puts stderr "*** displayOneTrain:resetTrainValues: winfo exists $schedFrame.mile$ir = [winfo exists $schedFrame.mile$ir]"
        if {![winfo exists $schedFrame.mile$ir]} {
	  Label $schedFrame.mile$ir -anchor e
	  Label $schedFrame.arrival$ir -anchor w
	  Label $schedFrame.station$ir -anchor w
	  Label $schedFrame.depart$ir -anchor e
	  Label $schedFrame.notes$ir -anchor w
        }
        switch [Stop_Flag $stop] {
	  Origin {
	    set arrivalText {}
	    set departText "[format {%2d:%02d} [expr int($depart) / 60] [expr int($depart) % 60]]"
	  }
	  Transit {
	    set arrivalText "[format {%2d:%02d} [expr int($arrival) / 60] [expr int($arrival) % 60]]"
	    set departText "[format {%2d:%02d} [expr int($depart) / 60] [expr int($depart) % 60]]"
	  }
	  Terminate {
	    set arrivalText "[format {%2d:%02d} [expr int($arrival) / 60] [expr int($arrival) % 60]]"
	    set departText {}
	  }
        }
        $schedFrame.mile$ir configure -text [expr abs(int($smile + .5))]
        $schedFrame.arrival$ir configure -text "$arrivalText"
        $schedFrame.station$ir configure -text "[Station_Name $station]"
        $schedFrame.depart$ir configure -text "$departText"
        $schedFrame.notes$ir  configure -text "$notes"  
        foreach wid  {mile arrival station depart notes} \
	          c  {0    1       2       3      4} \
	          sk {e    e       nsw     e      w} {
	    grid configure $schedFrame.${wid}$ir \
	    	-column $c -row $ir -sticky $sk
        }
        set oldDepart $depart
        set oldSmile  $smile
        incr ir
      }
    }
    foreach an [lsort -integer $nlist] {
      $notesText insert end "[format {%2d. %s} $an [TimeTable Note $an]]\n"
    }
    if {$minutes >= 0 && $locationSMile >= 0} {
      $notesText insert end "[format {%2d:%02d} [expr int($minutes) / 60] [expr int($minutes) % 60]] At or near milepost: [expr int($locationSMile + .5)]"
    }
  }
}

proc ViewOneTrain {} {
  set trainNum "[SelectOneTrainDialog draw]"
#  puts stderr "*** ViewOneTrain: trainNum = $trainNum"
  
  if {[string equal "$trainNum" {}]} {return}
  set train [TimeTable FindTrainByNumber "$trainNum"]
  if {[string equal "$train" NULL]} {return}

  set v [displayOneTrain draw -train $train]
}

snit::type viewAllTrainsDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent mainframe
  typecomponent headerframe
  typecomponent iconimage
  typecomponent headerlabel
  typecomponent dismisbutton
  typecomponent scheduleSFrame
  typecomponent scheduleSWindow
  typecomponent scheduleFrame
  
  typeconstructor {
    set dialog [Dialog::create .viewAllTrainsDialog \
			-class ViewAllTrainsDialog -bitmap info \
			-default 0 -cancel 0 -modal none -transient yes \
			-parent . -side bottom -title {All Available Trains}]
    $dialog add -name dismis -text Dismis -command [mytypemethod _Dismis]
    set mainframe [$dialog getframe]
    set headerframe $mainframe.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    set scheduleSWindow $mainframe.scheduleSWindow
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {All Available Trains}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    ScrolledWindow::create $scheduleSWindow \
		-auto vertical -scrollbar vertical
    pack $scheduleSWindow -expand yes -fill both
    set scheduleSFrame [ScrollableFrame::create $scheduleSWindow.scheduleSFrame]
    pack $scheduleSFrame -expand yes -fill both
    $scheduleSWindow setwidget $scheduleSFrame
    set scheduleFrame [$scheduleSFrame getframe]
    Label::create $scheduleFrame.number0 -text {Number} -anchor e
    Label::create $scheduleFrame.name0 -text {Name} -anchor w
    Label::create $scheduleFrame.speed0 -text {Speed} -anchor e    
    Label::create $scheduleFrame.orig0 -text {Origin} -anchor w
    Label::create $scheduleFrame.dest0 -text {Destination} -anchor w
    Label::create $scheduleFrame.length0 -text {Miles} -anchor e
    Label::create $scheduleFrame.time0 -text {Running Time}  -anchor e
    foreach w  {number name speed orig dest length time} \
	    c  {0      1    2     3    4    5      6} \
	    sk {e      w    e     w    w    e      e} {
      grid configure $scheduleFrame.${w}0 -column $c -row 0 -sticky $sk
    }
  }
  typemethod _Dismis {} {
    Dialog::withdraw $dialog
    return [eval [list Dialog::enddialog $dialog] [list {}]]
  }

  typevariable _NumberOfTrainsInDialog 0
  typemethod draw {args} {
    set tindex 0
    ForEveryTrain [TimeTable cget -this] train {
      incr tindex
#      puts stderr "*** viewAllTrainsDialog::draw: tindex = $tindex, train = $train, _NumberOfTrainsInDialog = $_NumberOfTrainsInDialog"
      if {$tindex > $_NumberOfTrainsInDialog} {
	Button::create $scheduleFrame.number$tindex -anchor e
	Label::create  $scheduleFrame.name$tindex   -anchor w
	Label::create  $scheduleFrame.speed$tindex  -anchor e    
	Label::create  $scheduleFrame.orig$tindex   -anchor w
	Label::create  $scheduleFrame.dest$tindex   -anchor w
	Label::create  $scheduleFrame.length$tindex -anchor e
	Label::create  $scheduleFrame.time$tindex   -anchor e
	foreach w  {number name speed orig dest length time} \
		c  {0      1    2     3    4    5      6} \
		sk {e      w    e     w    w    e      e} {
	  grid configure $scheduleFrame.${w}$tindex -column $c -row $tindex -sticky $sk
	}
        incr _NumberOfTrainsInDialog
      }
      $scheduleFrame.number$tindex configure \
		-text "[Train_Number $train]" \
		-command [list displayOneTrain draw \
			-train $train]
      $scheduleFrame.name$tindex configure -text "[Train_Name $train]"
      $scheduleFrame.speed$tindex configure -text "[Train_Speed $train]"
      set departure [Train_Departure $train]
      set oldDepart -1
      set oldSmile -1
      set speed  [Train_Speed $train]
      ForEveryStop $train stop {
        set sindex [Stop_StationIndex $stop]
        set station [TimeTable IthStation $sindex]
        set smile [Station_SMile $station]
        if {$oldDepart >= 0} {
	  set arrival [expr $oldDepart + (abs($smile - $oldSmile) * (double($speed) / 60.0))]
        } else {
	  set arrival $departure
        }
        set depart [Stop_Departure $stop $arrival]
        switch [Stop_Flag $stop] {
	  Origin {
	    set sindex [Stop_StationIndex $stop]
	    set station [TimeTable IthStation $sindex]
	    set smile0 [Station_SMile $station]
	    $scheduleFrame.orig$tindex configure -text "[Station_Name $station]"
	  }
	  Transit {
	  }
	  Terminate {
	    set sindex [Stop_StationIndex $stop]
	    set station [TimeTable IthStation $sindex]
	    set smileN [Station_SMile $station]
	    $scheduleFrame.dest$tindex configure -text "[Station_Name $station]"
	  }
        }
        set oldDepart $depart
        set oldSmile  $smile
      }
      $scheduleFrame.length$tindex configure -text [expr $smileN - $smile0]
      set rtime [expr $arrival - $departure]
      set rtimeFmt [format {%2d:%02d} [expr int($rtime) / 60] [expr int($rtime) % 60]]
      $scheduleFrame.time$tindex configure -text "$rtimeFmt"
    }
#    puts stderr "*** viewAllTrainsDialog::draw: tindex = $tindex, _NumberOfTrainsInDialog = $_NumberOfTrainsInDialog"
    for {set iextra $tindex} {$iextra < $_NumberOfTrainsInDialog} {incr iextra} {
      foreach w {number name speed orig dest length time} {
        destroy scheduleFrame.${w}$iextra
      }
    }
    update idle
    set dialogWidth [expr 60 + [winfo reqwidth $scheduleFrame]]
    set dialogHeight [expr (4 * $dialogWidth) / 3]
    if {$dialogHeight > 500} {set dialogHeight 500}
    set geo "${dialogWidth}x${dialogHeight}"
    $dialog configure -geometry "$geo"    
    set _NumberOfTrainsInDialog $tindex
    return [eval [list Dialog::draw $dialog]]
  }
  
}

proc ViewAllTrains {} {
  viewAllTrainsDialog draw
}

catch {
$::Main menu sethelpvar view
$::Main menu add view command -label {View One Train} -command ViewOneTrain \
		      -dynamichelp "View a single train"
$::Main menu add view command -label {View All Trains} -command ViewAllTrains \
		      -dynamichelp "View all trains"
}

snit::type editTrainDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerlabel
  typecomponent editpages
  typecomponent basicpageframe
  typecomponent  name
  typecomponent  number
  typecomponent  class
  typecomponent  speed
  typecomponent  departure
  typecomponent    departureFrame
  typecomponent      departureHours
  typecomponent      departureMinutes
  typecomponent  firststation
  typecomponent  laststation
  typecomponent  basicpagebuttons
  typecomponent scheduleframe
  typecomponent  schedscroll
  typecomponent  schedscrollframe
  typecomponent    schedule
  typecomponent  schedulebuttons
  typecomponent storageframe
  typecomponent  storagescroll
  typecomponent  storagescrollframe
  typecomponent    storage
  typecomponent  storagebuttons

  typevariable _NumberOfScheduleRows 1
  typevariable _NumberOfStorageRows 1
  typeconstructor {
    set dialog [Dialog::create .editTrainDialog \
			-class EditTrainDialog -bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title {Edit Train}]
    $dialog add -name done -text Done -command [mytypemethod _Done] \
		-state disabled
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list BWHelp::HelpTopic EditTrainDialog]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Edit Train}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set editpages [PagesManager::create $frame.editpages]
    pack $editpages -expand yes -fill both
    set basicpageframe [$editpages add basicpage]
    set name	[LabelEntry::create $basicpageframe.name \
			-label "Name:" -labelwidth 12]
    pack $name -fill x
    set number	[LabelEntry::create $basicpageframe.number \
			-label "Number:" -labelwidth 12]
    pack $number -fill x
    set class	[LabelComboBox::create $basicpageframe.class \
			-label "Class:" -labelwidth 12 \
			-values {1 2 3 4 5 6 7 8 9 10} -editable no]
    pack $class -fill x
    set speed	[LabelSpinBox::create $basicpageframe.speed \
    			-label "Speed:" -labelwidth 12 \
			-range {10 150 5}]
    pack $speed	-fill x
    set  departure [LabelFrame::create $basicpageframe.departure \
			-text "Departure:" -width 12]
    pack $departure -fill x
    set departureFrame [$departure getframe]
    set  departureHours [SpinBox::create $departureFrame.departureHours \
				-width 2 -range {0 23 1} -justify r]
    pack $departureHours -side left
    pack [Label::create $departureFrame.colon -text {:}] -side left
    set departureMinutes [SpinBox::create $departureFrame.departureMinutes \
				-width 2 -range {0 59 1} -justify r \
	-modifycmd \
	"[mytypemethod _FormatMinutes] $departureFrame.departureMinutes"]
    pack $departureMinutes -side left
    pack [frame $departureFrame.filler -bd 0 -relief flat] -side right -fill x
    set firststation  [LabelComboBox::create $basicpageframe.firststation \
			-label "Origin:" -labelwidth 12 -editable no]
    pack $firststation -fill x
    set laststation  [LabelComboBox::create $basicpageframe.laststation \
			-label "Termination:" -labelwidth 12 -editable no]
    pack $laststation -fill x
    set basicpagebuttons [ButtonBox::create $basicpageframe.basicpagebuttons \
				-orient horizontal]
    pack $basicpagebuttons -fill x
    $basicpagebuttons add -name next -text {Schedule} \
			  -command [mytypemethod _GotoSchedulePage]
    $basicpagebuttons add -name reset -text {Reset Information} \
			  -command [mytypemethod _ResetBasicPage]
    set scheduleframe  [$editpages add schedule]
    set schedscroll    [ScrolledWindow::create $scheduleframe.schedscroll \
				-auto both -scrollbar both]
    pack $schedscroll -expand yes -fill both
    set schedscrollframe [ScrollableFrame::create $schedscroll.schedscrollframe]
    pack $schedscrollframe -expand yes -fill both
    $schedscroll setwidget $schedscrollframe
    set schedule [$schedscrollframe getframe]
    Label::create $schedule.mile0 -text {Smile}
    Label::create $schedule.arrive0 -text {Arrival}
    Label::create $schedule.station0 -text {Station Name}
    Label::create $schedule.layover0 -text {Layover}
    Label::create $schedule.depart0 -text {Departure}
    Label::create $schedule.cab0 -text {Cab}
    Label::create $schedule.update0
    foreach wid    {mile arrive station layover depart cab update} \
	    col    {0    1      2       3       4      5   6} \
	    sticky {e    e      w       e       e      w   w} {
      grid configure $schedule.${wid}0 -column $col -row 0 -sticky $sticky
    }
    set schedulebuttons  [ButtonBox::create $scheduleframe.buttons \
					-orient horizontal]
    pack $schedulebuttons -fill x
    $schedulebuttons add -name next -text {Storage} \
			 -command [mytypemethod _GotoStoragePage]
    $schedulebuttons add -name reset -text {Reset Schedule} \
			 -command [mytypemethod _ResetSchedule]
    set storageframe   [$editpages add storage]
    set storagescroll [ScrolledWindow::create $storageframe.storagescroll \
				-auto both -scrollbar both]
    pack $storagescroll -expand yes -fill both
    set storagescrollframe [ScrollableFrame::create $storagescroll.storagescrollframe]
    pack $storagescrollframe -expand yes -fill both
    $storagescroll setwidget $storagescrollframe
    set storage [$storagescrollframe getframe]
    Label::create $storage.mile0 -text {Smile}
    Label::create $storage.arrive0 -text {Arrival}
    Label::create $storage.station0 -text {Station Name}
    Label::create $storage.track0 -text {Storage Track}
    Label::create $storage.depart0 -text {Departure}
    foreach wid    {mile arrive station track depart} \
	    col    {0    1      2       3     4} \
	    sticky {e    e      w       w     e} {
      grid configure $storage.${wid}0 -column $col -row 0 -sticky $sticky
    }
    set storagebuttons [ButtonBox::create $storageframe.buttons \
					-orient horizontal]
    pack $storagebuttons -fill x
    $storagebuttons add -name reset -text {Reset Storage} \
			-command [mytypemethod _ResetStorage]
    $editpages compute_size
  }
  typemethod _FormatMinutes {w} {
    set v [$w cget -text]
    if {[string length $v] == 2} {return}
    set v [format {%02d} $v]
    $w configure -text "$v"
  }
  typevariable _StationValuesSet no
  typevariable _Name
  typemethod getName {} {return "$_Name"}
  typevariable _Number
  typemethod getNumber {} {return "$_Number"}
  typevariable _Class
  typemethod getClass {} {return "$_Class"}
  typevariable _Speed
  typemethod getSpeed {} {return "$_Speed"}
  typevariable _First
  typemethod getFirst {} {return "$_First"}
  typevariable _Last
  typemethod getLast {} {return "$_Last"}
  typevariable _Departure
  typemethod getDeparture {} {return "$_Departure"}
  typevariable _Train
  typevariable _StopArrival -array {}
  typemethod getStopArrival {stop} {
    if {[catch "set _StopArrival($stop)" arrival]} {
      return -1.0
    } else {
      return $arrival
    }
  }
  typevariable _StopLayover -array {}
  typemethod getStopLayover {stop} {
    if {[catch "set _StopLayover($stop)" layover]} {
      return -
    } else {
      return $layover
    }
  }
  typevariable _StopCab     -array {}
  typemethod getStopCab {stop} {
    if {[catch "set _StopCab($stop)" cab]} {
      return {}
    } else {
      return "$cab"
    }
  }
  typevariable _StopStorageTrack -array {}
  typemethod getStopStorageTrack {stop} {
    if {[catch "set _StopStorageTrack($stop)" storage]} {
      return {}
    } else {
      return "$storage"
    }
  }
  typevariable _EditFlag
  typemethod draw {args} {
    set title [from args -title]
    if {[string length "$title"]} {
      $dialog configure -title "$title"
      $headerlabel configure -text "$title"
    }
    if {!$_StationValuesSet} {
      set allStations {}
      ForEveryStation [TimeTable cget -this] station {
        lappend allStations "[Station_Name $station]"
      }
      $firststation configure -values $allStations
      $laststation  configure -values $allStations
      set _StationValuesSet yes
    }
    set _Train [from args -train NULL]
    if {[string equal "$_Train" NULL]} {
      set _Name {}
      set _Number {}
      set _Class 1
      set _Speed 60
      set _First 0
      set _Last  [expr [TimeTable NumberOfStations] - 1]
      set _Departure 0
      set _EditFlag no
      $number configure -editable yes
   } else {
      set _Name   "[Train_Name $_Train]"
      set _Number "[Train_Number $_Train]"
      set _Class  [Train_ClassNumber $_Train]
      set _Speed  [Train_Speed $_Train]
      set _First  [Stop_StationIndex [Train_StopI $_Train 0]]
      set _Last   [Stop_StationIndex [Train_StopI $_Train [expr [Train_NumberOfStops $_Train] - 1]]]
      set _Departure [Train_Departure $_Train]
      $number configure -editable no
      set _EditFlag yes
    }
    $type _ResetBasicPage
    $editpages raise basicpage
    $dialog itemconfigure done -state disabled
    return [Dialog::draw $dialog]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog cancel]
  }
  typemethod _Done {} {
    Dialog::withdraw $dialog
    foreach stop [array names _StopStorageTrack] {
      set storage_row $_StopStorageTrack($stop)
      if {$storage_row < 0} {
	set _StopStorageTrack($stop) {}
      } else {
	set _StopStorageTrack($stop) "[$storage.track$_StopStorageTrack($stop) cget -text]"
      }
    }
    return [Dialog::enddialog $dialog done]
  }
  typemethod _GotoSchedulePage {} {
    set _Name "[$name cget -text]"
    set _Number "[$number cget -text]"
    set _Class [$class cget -text]
    set _Speed [$speed cget -text]
    set _First [TimeTable FindStationByName "[$firststation get]"]
    set _Last  [TimeTable FindStationByName "[$laststation get]"]
    set dHours [$departureHours cget -text]
    set dMinutes [$departureMinutes cget -text]
    set _Departure [expr $dHours * 60]
    regsub {^0([0-9])$} "$dMinutes" {\1} dMinutes
    incr _Departure $dMinutes
    $type _ResetSchedule
    $editpages raise schedule
  }
  typemethod _AddOrUpdateScheduleRow {row smile stationName arrival depart \
				      layover cabName} {
    if {$row >= $_NumberOfScheduleRows} {
      Label::create $schedule.mile$_NumberOfScheduleRows
      Entry::create $schedule.arrive$_NumberOfScheduleRows -editable no -width 6
      Label::create $schedule.station$_NumberOfScheduleRows
      SpinBox::create $schedule.layover$_NumberOfScheduleRows \
		-range {0 999 1} -width 6
      Entry::create $schedule.depart$_NumberOfScheduleRows -editable no -width 9
      ComboBox::create $schedule.cab$_NumberOfScheduleRows \
		-values [TimeTable CabNameList] -width 6
      Button::create $schedule.update$_NumberOfScheduleRows \
		-text Update \
		-command "[mytypemethod _UpdateScheduleRow] [expr $_NumberOfScheduleRows - 1]"
      foreach wid    {mile arrive station layover depart cab update} \
	      col    {0    1      2       3       4      5   6} \
	      sticky {e    e      w       e       e      w   w} {
	grid configure $schedule.${wid}$_NumberOfScheduleRows \
		-column $col -row $_NumberOfScheduleRows -sticky $sticky
      }
      incr _NumberOfScheduleRows
    }
    $schedule.layover$row configure -editable yes
    $schedule.update$row configure -state normal
    $schedule.cab$row configure -state normal
    $schedule.mile$row configure -text $smile
    if {$arrival < 0} {
      $schedule.arrive$row configure -text {Origin}
      $schedule.layover$row configure -editable no
    } else {
      $schedule.arrive$row configure \
	-text [format {%2d:%02d} [expr int($arrival) / 60] \
				 [expr int($arrival) % 60]]
    }
    $schedule.station$row configure -text "$stationName"
    $schedule.layover$row configure -text $layover
    if {$depart < 0} {
      $schedule.depart$row configure -text {Terminate}
      $schedule.layover$row configure -editable no
      $schedule.update$row configure -state disabled
      $schedule.cab$row configure -state disabled
    } else {
      $schedule.depart$row configure \
	-text [format {%2d:%02d} [expr int($depart) / 60] \
				 [expr int($depart) % 60]]
      
    }
    $schedule.cab$row setvalue first
    if {[string length "$cabName"]} {
      set index [lsearch [$schedule.cab$row cget -values] "$cabName"]
      if {$index >= 0} {$schedule.cab$row setvalue @$index}
    }
  }
  typemethod _UpdateScheduleRow {stopNumber} {
    set rowNumber [expr $stopNumber + 1]
    set _StopLayover($stopNumber) [$schedule.layover$rowNumber cget -text]
    set _StopCab($stopNumber) "[$schedule.cab$rowNumber cget -text]"
    if {$stopNumber > 0} {
      scan [$schedule.arrive$rowNumber cget -text] {%2d:%02d} h m
      set arrival [expr ($h * 60) + $m]
      scan [$schedule.depart$rowNumber cget -text] {%2d:%02d} h m
      set olddepart [expr ($h * 60) + $m]
      set newdepart [expr $arrival + $_StopLayover($stopNumber)]
      set diff [expr $newdepart - $olddepart]
    } else {
      set diff 0
    }
    for {set row $rowNumber} {$row < $_NumberOfScheduleRows} {incr row} {
      if {$diff > 0} {
	scan [$schedule.arrive$row cget -text] {%2d:%02d} h m
	set arrival [expr ($h * 60) + $m]
	if {$row > $rowNumber} {
	  set arrival [expr $arrival + $diff]
	  $schedule.arrive$row configure \
		-text [format {%2d:%02d} [expr int($arrival) / 60] \
					 [expr int($arrival) % 60]]
	}
	if {![string equal [$schedule.depart$row cget -text] {Terminate}]} {
	  scan [$schedule.depart$row cget -text] {%2d:%02d} h m
	  set depart [expr ($h * 60) + $m]
	  set depart [expr $depart + $diff]
	  $schedule.depart$row configure \
	    -text [format {%2d:%02d} [expr int($depart) / 60] \
				     [expr int($depart) % 60]]
	}
      }
      set index [lsearch [$schedule.cab$row cget -values] "$_StopCab($stopNumber)"]
      if {$index >= 0} {$schedule.cab$row setvalue @$index}
    }
  }
  typemethod _DeleteLastScheduleRow {} {
    incr _NumberOfScheduleRows -1
    set i $_NumberOfScheduleRows
    foreach w {mile arrive station layover depart cab update} {
      destroy $schedule.${w}${i}
    }
  }
  typemethod _ResetBasicPage {} {
    $name configure -text "$_Name"
    $number configure -text "$_Number"
    $class configure -text $_Class
    $speed configure -text $_Speed
    $firststation setvalue @[lsearch [$firststation cget -values] "[Station_Name [TimeTable IthStation $_First]]"]
    $laststation  setvalue @[lsearch [$laststation  cget -values] "[Station_Name [TimeTable IthStation $_Last]]"]
    set dHours [expr int($_Departure) / 60]
    set dMinutes [expr int($_Departure) % 60]
    $departureHours configure -text $dHours
    $departureMinutes configure -text [format {%02d} $dMinutes]
  }
  typemethod _GotoStoragePage {} {
    foreach stop [array names _StopLayover] {
      set sched_row [expr $stop + 1]
      set _StopLayover($stop) [$schedule.layover$sched_row cget -text]
      set _StopCab($stop)     "[$schedule.cab$sched_row cget -text]"
      if {$sched_row > 1} {
	scan [$schedule.arrive$sched_row cget -text] {%2d:%02d} h m
	set _StopArrival($stop) [expr ($h * 60) + $m]
      }
    }
    if {[$type _ResetStorage]} {
      $editpages raise storage
      $dialog itemconfigure done -state normal
    } else {
      $type _Done
    }
  }
  typemethod _ResetSchedule {} {
    set numberOfStops [expr ($_Last - $_First) + 1]
    set depart $_Departure
    set lastsmile -1
    array unset _StopLayover
    array unset _StopCab
    for {set stop 0} {$stop < $numberOfStops} {incr stop} {
      set station [TimeTable IthStation [expr $_First + $stop]]
      set smile [Station_SMile $station]
      if {$stop == 0} {
	set layover -
	set arrival -1
      } else {
	if {$_EditFlag} {
	  set layover [Stop_Layover [Train_StopI $_Train $stop]]
	} else {
	  set layover 0
	}
	set arrival [expr $depart + ((double($_Speed) / 60.0) * \
				     ($smile - $lastsmile))]
      }
      set cabName {}
      if {$_EditFlag} {
	set cab [Stop_TheCab [Train_StopI $_Train $stop]]
        if {![string equal $cab NULL]} {
	  set cabName [Cab_Name $cab]
	}
      }
      if {[expr $stop + 1] == $numberOfStops} {
	set depart -1
	set layover -
      } elseif {$stop != 0} {
	set depart [expr $arrival + $layover]
      }
      set _StopLayover($stop) $layover
      set _StopCab($stop) "$cabName"
      $type _AddOrUpdateScheduleRow [expr $stop + 1] $smile [Station_Name $station] \
				    $arrival $depart $layover "$cabName"
      set lastsmile $smile
      
    }
    set lastrow [expr $stop + 1]
    while {$lastrow < $_NumberOfScheduleRows} {
      $type _DeleteLastScheduleRow
    }
    puts stderr "*** ${type}::_ResetSchedule: lastrow = $lastrow, _NumberOfScheduleRows = $_NumberOfScheduleRows"
    $editpages compute_size
  }
  typemethod _ResetStorage {} {
    set storage_row 0
    array unset _StopStorageTrack
    set hasStorageTracks no
    foreach stop [lsort -integer [array names _StopLayover]] {
      set station [TimeTable IthStation [expr $_First + $stop]]
      set sched_row [expr $stop + 1]
      set arrival [$schedule.arrive$sched_row cget -text]
      set depart  [$schedule.depart$sched_row cget -text]
      set layover $_StopLayover($stop)
      set numtracks [Station_NumberOfStorageTracks $station]
      if {([string equal "$layover" {-}] || $layover > 0) && $numtracks > 0} {
	incr storage_row
	if {$_EditFlag} {
	  set storageTrackName "[Stop_StorageTrackName [Train_StopI $_Train $stop]]"
	} else {
	  set storageTrackName {}
	}
	$type _AddOrUpdateStorageRow $storage_row $arrival $station \
				     "$storageTrackName" $depart
	set _StopStorageTrack($stop) $storage_row
	set hasStorageTracks yes
      } else {
	set _StopStorageTrack($stop) -1
      }
    }
    incr storage_row
    while {$storage_row < $_NumberOfStorageRows} {
      $type _DeleteLastStorageRow
    }
    $editpages compute_size
    return $hasStorageTracks
  }
  typemethod _AddOrUpdateStorageRow {row arrival station storageTrack depart} {
    if {$row >= $_NumberOfStorageRows} {
      Label::create $storage.mile$_NumberOfStorageRows
      Label::create $storage.arrive$_NumberOfStorageRows
      Label::create $storage.station$_NumberOfStorageRows
      ComboBox::create $storage.track$_NumberOfStorageRows -editable no
      Label::create $storage.depart$_NumberOfStorageRows
      foreach wid    {mile arrive station track depart} \
	      col    {0    1      2       3     4} \
	      sticky {e    e      w       w     e} {
	grid configure $storage.${wid}${_NumberOfStorageRows} \
		-column $col -row $_NumberOfStorageRows -sticky $sticky
      }
      incr _NumberOfStorageRows
    }
    $storage.mile$row configure -text [Station_SMile $station]
    $storage.arrive$row configure -text "$arrival"
# if arrival == Origin # - from train, time
    $storage.station$row configure -text "[Station_Name $station]"
    set tracks [Station_StorageTrackNameList $station]
    lappend tracks {}
    $storage.track$row configure -values $tracks
    set index [lsearch $tracks "$storageTrack"]
    if {$index >= 0} {
      $storage.track$row setvalue @$index
    } else {
      $storage.track$row configure -text "$storageTrack"
    }
    $storage.depart$row configure -text "$depart"
# if depart == Terminate # - to train, time
  }
  typemethod _DeleteLastStorageRow {} {
    incr _NumberOfStorageRows -1
    set i $_NumberOfStorageRows
    foreach w {mile arrive station track depart} {
      destroy $storage.${w}${i}
    }
  }
}

proc AddTrain {} {
  puts stderr "*** AddTrain"
  set result [editTrainDialog draw -title {Create New Train}]
  puts stderr "*** AddTrain: result = $result"
  if {[string equal "$result" cancel]} {return}
  set name   "[editTrainDialog getName]"
  set number "[editTrainDialog getNumber]"
  if {![string equal [TimeTable FindTrainByNumber "$number"] NULL]} {
    TtErrorMessage draw -message "Train number already in use: $number, pick another!"
    return
  }
  if {![string equal [TimeTable FindTrainByName "$name"] NULL]} {
    TtInfoMessage draw -message "Duplicate train name: $name."
  }
  set speed [editTrainDialog getSpeed]
  set classnumber [editTrainDialog getClass]
  set departure [editTrainDialog getDeparture]
  set start [editTrainDialog getFirst]
  set end [editTrainDialog getLast]
  set layoverList {}
  set cabnameList {}
  set storageTrackList {}
  for {set istop $start} {$istop <= $end} {incr istop} {
    lappend layoverList [editTrainDialog getStopLayover $istop]
    lappend cabnameList "[editTrainDialog getStopCab $istop]"
    lappend storageTrackList "[editTrainDialog getStopStorageTrack $istop]"
  }
  if {[catch "TimeTable AddTrainLongVersion "$name" "$number" $speed \
					    $classnumber $departure $start \
					    $end $layoverList $cabnameList \
					    $storageTrackList" result]} {
    set error "Error adding train $number: [lindex $result 1]"
    TtErrorMessage draw -message "$error"
    return
  } else {
    $::ChartDisplay addATrain [TimeTable cget -this] $result
  }
}

proc EditTrain {} {
  TtInfoMessage draw -message "Edit Train Not Implemented Yet!"
#  puts stderr "*** EditTrain"
#  set trainNum "[SelectOneTrainDialog draw]"
#  if {[string equal "$trainNum" {}]} {return}
#  set train [TimeTable FindTrainByNumber "$trainNum"]
#  if {[string equal "$train" NULL]} {return}
#  set result [editTrainDialog draw -title "Edit Train [Train_Number $train]" -train $train]
#  puts stderr "*** EditTrain: result = $result"
}

proc DeleteTrain {} {
  puts stderr "*** DeleteTrain"
  set trainNum "[SelectOneTrainDialog draw]"
  if {[string equal "$trainNum" {}]} {return}
  set train [TimeTable FindTrainByNumber "$trainNum"]
  if {[string equal "$train" NULL]} {return}
  if {![TtYesNo draw -title {Delete Train?} \
	-message "Are you SURE you want to delete train $trainNum?"]} {return}
  if {[catch "TimeTable DeleteTrain $trainNum" result]} {
    set error "Error deleting train $trainNum: [lindex $result 1]"
    TtErrorMessage draw -message "$error"
    set result [lindex $result 0]
  }
  if {$result} {
    $::ChartDisplay deleteTrain "$trainNum"
  }
}

catch {
$::Main menu add trains command -label {Add Train} -command AddTrain \
			-dynamichelp "Add a new train"
#$::Main menu add trains command -label {Edit Train} -command EditTrain \
#			-dynamichelp "Edit a train"
$::Main menu add trains command -label {Delete Train} -command DeleteTrain \
			-dynamichelp "Delete a train"
$::Main buttons add -name addTrain -anchor w \
	-text {Add a new train} -command AddTrain \
	-helptext "Add a new train"
#$::Main buttons add -name editTrain -anchor w \
#	-text {Edit an existing train} -command EditTrain \
#	-helptext "Edit an existin train"
$::Main buttons add -name deleteTrain -anchor w \
	-text {Delete an existing train} -command DeleteTrain \
	-helptext "Delete an existing train"
image create photo AddTrainButtonImage -file [file join $ImageDir addtrain.gif]
$::Main toolbar addbutton tools addtrain -image AddTrainButtonImage \
			-command AddTrain \
			-helptext "Add a new train"
#image create photo EditTrainButtonImage -file [file join $ImageDir edittrain.gif]
#$::Main toolbar addbutton tools edittrain -image EditTrainButtonImage \
#			-command EditTrain \
#			-helptext "Edit an existing train"
image create photo DeleteTrainButtonImage -file [file join $ImageDir deletetrain.gif]
$::Main toolbar addbutton tools deletetrain -image DeleteTrainButtonImage \
			-command DeleteTrain \
			-helptext "Delete an existing train"
}


package provide TTTrains 1.0
