#* 
#* ------------------------------------------------------------------
#* TTTrains.tcl - Train related code
#* Created by Robert Heller on Sat Dec 31 13:19:08 2005
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.7  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.6  2007/10/17 14:06:34  heller
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

catch {TimeTable::SplashWorkMessage [_ "Loading Train Code"] 44}

package require gettext
package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames
package require ScrollWindow
package require ListBox
package require ScrollableFrame
package require PagesManager
package require ButtonBox
package require ROText

snit::type TimeTable::SelectOneTrainDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerlabel
  typecomponent number
  typecomponent tlist
  typecomponent tlistlist

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .selectOneTrainDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title [_ "Select one train"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Select One Train Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Select one train"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set tlist [ScrolledWindow $frame.tlist -scrollbar both -auto both]
    pack $tlist -expand yes -fill both
    set tlistlist [ListBox $frame.tlist.list -selectmode single]
    $tlist setwidget $tlistlist
    $tlistlist bindText <ButtonPress-1> [mytypemethod _BrowseFromList]
    $tlistlist bindText <Double-1> [mytypemethod _SelectFromList]
    set number [LabelEntry $frame.number -label [_m "Label|Train Number Selection:"]]
    pack $number -fill x
    $number bind <Return> [mytypemethod _OK]
  }

  typemethod _OK {} {
    $dialog withdraw
    set result "[$number cget -text]"
    return [$dialog enddialog "$result"]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog {}]
  }

  typemethod draw {args} {
    $type createDialog
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
		-data [list "$_number" "$_name"] \
		-text [format {%-5s %-15s} "$_number" "$_name"]
    }
    focus -force $number 
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }

  typemethod _SelectFromList {selectedItem} {
    set elt [$tlistlist itemcget $selectedItem -data]
    set result [lindex $elt 0]
    eval [list $dialog withdraw]
    return [$dialog enddialog $result]
  }

  typemethod _BrowseFromList {selectedItem} {
    set elt [$tlistlist itemcget $selectedItem -data]
    set value "[lindex $elt 0]"
    $number configure -text "$value"
  }
}

snit::widget TimeTable::displayOneTrain {
  TimeTable::TtStdShell DisplayOneTrain

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

#  option -title -default [_ "Displaying one train"] \
#		-configuremethod _SetTitle
  option -title -default {} \
		-configuremethod _SetTitle

  option -train -default NULL -validatemethod _CheckTrain
  method _CheckTrain {option value} {
    if {[string equal "$value" {}]} {
      $self configure $option NULL
      set value [$self cget $option]
    }
    if {![string equal "$value" NULL] &&
	 [regexp {^_[0-9a-z]*_p_TTSupport__Train$} "$value"] < 1} {
      error [_ "Not a pointer to a train: %s" $value]
    }
  }    

  option -minutes -default -1 -validatemethod _CheckDouble
  method _CheckDouble {option value} {
    if {![string is double -strict "$value"]} {
      error [_ "Not a number for option %s: %s" $option $value]
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
    set numberLabel [ttk::label $header.number -relief sunken]
    pack $numberLabel -side left
    #puts stderr "*** $self constructtopframe: numberLabel = $numberLabel"
    set nameLabel [ttk::label $header.name -relief sunken]
    pack $nameLabel -side left -expand yes -fill x
    #puts stderr "*** $self constructtopframe: nameLabel = $nameLabel"
    pack [ttk::label $header.l1 -text [_m "Label|Class: "]] -side left
    set classLabel [ttk::label $header.class -relief sunken]
    pack $classLabel -side left
    #puts stderr "*** $self constructtopframe: classLabel = $classLabel"
    pack [ttk::label $header.l2 -text [_m "Label|Speed: "]] -side left
    set speedLabel [ttk::label $header.speed -relief sunken]
    pack $speedLabel -side left
    #puts stderr "*** $self constructtopframe: speedLabel = $speedLabel"
    pack [ttk::label $header.l3 -text [_m "Label|Notes: "]] -side left
    set notesLabel [ttk::label $header.notes -relief sunken]
    pack $notesLabel -side right
    #puts stderr "*** $self constructtopframe: notesLabel = $notesLabel"

    set snPane [ttk::panedwindow $frame.schedNotes -orient vertical]
    pack $snPane -expand yes -fill both
    #puts stderr "*** $self constructtopframe: snPane = $snPane"
    set schedPane [ttk::frame $snPane.sched]
    $snPane add $schedPane
    #puts stderr "*** $self constructtopframe: schedPane = $schedPane"
    set notesPane [ttk::frame $snPane.notes]
    $snPane add $notesPane
    #puts stderr "*** $self constructtopframe: notesPane = $notesPane"

    set schedSWindow [ScrolledWindow $frame.schedscroll -scrollbar both -auto both]
    pack $schedSWindow -in $schedPane -expand yes -fill both
    #puts stderr "*** $self constructtopframe: schedSWindow is $schedSWindow"

    set schedFrame [ScrollableFrame $frame.schedscroll.sched -width 300 -height 150  ]
    $schedSWindow setwidget $schedFrame
    #puts stderr "*** $self constructtopframe: schedFrame is $schedFrame"
    ttk::label $schedFrame.mile0 -text [_m "Label|Mile"] -anchor e
    ttk::label $schedFrame.arrival0 -text [_m "Label|Arival"] -anchor w
    ttk::label $schedFrame.station0 -text [_m "Label|Station"] -anchor w
    ttk::label $schedFrame.depart0  -text [_m "Label|Depart"] -anchor e
    ttk::label $schedFrame.notes0 -text [_m "Label|Notes"] -anchor w

    foreach wid  {mile arrival station depart notes} \
	    c    {0    1       2       3      4} \
	    sk   {e    e       nsw     e      w} {
      grid configure $schedFrame.${wid}0 \
    	-column $c -row 0 -sticky $sk
    }

    set notesSWindow [ScrolledWindow $frame.notescroll -scrollbar both -auto both]
    pack $notesSWindow -in $notesPane -expand yes -fill both
    #puts stderr "*** $self constructtopframe: notesSWindow is $notesSWindow"
    
    set notesText [ROText $frame.notescroll.notes -height 8 -width 24]
    $notesSWindow setwidget $notesText
    #puts stderr "*** $self constructtopframe: notesText is $notesText"
  }

  method initializetopframe {frame args} {
    #puts stderr "*** $self initializetopframe $frame $args"
    $self configure -minutes -1
    $self configurelist $args
    
    if {"$options(-title)" eq {}} {
      $self configure -title [_ "Displaying one train"]
    }
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
#	puts stderr "*** ${self}::initializetopframe: station = $station, sindex = $sindex"
        set smile [Station_SMile $station]
#	puts stderr "*** ${self}::initializetopframe: station = $station, smile = $smile, ir = $ir"
        if {$oldDepart >= 0} {
	  set arrival [expr {$oldDepart + (abs($smile - $oldSmile) * (double($speed) / 60.0))}]
#	  puts stderr "*** ${self}::initializetopframe: arrival = $arrival"
	  if {$minutes >= $oldDepart && $minutes < $arrival} {
	    set locationSMile [expr {(($minutes - $oldDepart) / (double($speed) / 60.0)) + $oldSmile}]
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
	  ttk::label $schedFrame.mile$ir -anchor e
	  ttk::label $schedFrame.arrival$ir -anchor w
	  ttk::label $schedFrame.station$ir -anchor w
	  ttk::label $schedFrame.depart$ir -anchor e
	  ttk::label $schedFrame.notes$ir -anchor w
        }
        switch [Stop_Flag $stop] {
	  Origin {
	    set arrivalText {}
	    set departText "[format {%2d:%02d} [expr {int($depart) / 60}] [expr {int($depart) % 60}]]"
	  }
	  Transit {
	    set arrivalText "[format {%2d:%02d} [expr {int($arrival) / 60}] [expr {int($arrival) % 60}]]"
	    set departText "[format {%2d:%02d} [expr {int($depart) / 60}] [expr {int($depart) % 60}]]"
	  }
	  Terminate {
	    set arrivalText "[format {%2d:%02d} [expr {int($arrival) / 60}] [expr {int($arrival) % 60}]]"
	    set departText {}
	  }
        }
        $schedFrame.mile$ir configure -text [expr {abs(int($smile + .5))}]
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
      $notesText insert end [_ "%2d:%02d At or near milepost: %d" [expr {int($minutes) / 60}] [expr {int($minutes) % 60}] [expr {int($locationSMile + .5)}]]
    }
  }
}

proc TimeTable::ViewOneTrain {} {
  set trainNum "[SelectOneTrainDialog draw]"
#  puts stderr "*** ViewOneTrain: trainNum = $trainNum"
  
  if {[string equal "$trainNum" {}]} {return}
  set train [TimeTable FindTrainByNumber "$trainNum"]
  if {[string equal "$train" NULL]} {return}

  set v [displayOneTrain draw -train $train]
}

snit::type TimeTable::viewAllTrainsDialog {
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
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .viewAllTrainsDialog \
			-bitmap info \
			-default 0 -cancel 0 -modal none -transient yes \
			-parent . -side bottom -title [_ "All Available Trains"]]
    $dialog add dismis -text [_m "Button|Dismis"] -command [mytypemethod _Dismis]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Dismis]
    set mainframe [$dialog getframe]
    set headerframe $mainframe.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    set scheduleSWindow $mainframe.scheduleSWindow
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "All Available Trains"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    ScrolledWindow $scheduleSWindow \
		-auto vertical -scrollbar vertical
    pack $scheduleSWindow -expand yes -fill both
    set scheduleSFrame [ScrollableFrame $scheduleSWindow.scheduleSFrame]
    $scheduleSWindow setwidget $scheduleSFrame
    set scheduleFrame [$scheduleSFrame getframe]
    ttk::label $scheduleFrame.number0 -text [_m "Label|Number"] -anchor e
    ttk::label $scheduleFrame.name0 -text [_m "Label|Name"] -anchor w
    ttk::label $scheduleFrame.speed0 -text [_m "Label|Speed"] -anchor e    
    ttk::label $scheduleFrame.orig0 -text [_m "Label|Origin"] -anchor w
    ttk::label $scheduleFrame.dest0 -text [_m "Label|Destination"] -anchor w
    ttk::label $scheduleFrame.length0 -text [_m "Label|Miles"] -anchor e
    ttk::label $scheduleFrame.time0 -text [_m "Label|Running Time"]  -anchor e
    foreach w  {number name speed orig dest length time} \
	    c  {0      1    2     3    4    5      6} \
	    sk {e      w    e     w    w    e      e} {
      grid configure $scheduleFrame.${w}0 -column $c -row 0 -sticky $sk
    }
  }
  typemethod _Dismis {} {
    $dialog withdraw
    return [$dialog enddialog {}]
  }

  typevariable _NumberOfTrainsInDialog 0
  typemethod draw {args} {
    $type createDialog
    set tindex 0
    ForEveryTrain [TimeTable cget -this] train {
      incr tindex
#      puts stderr "*** viewAllTrainsDialog::draw: tindex = $tindex, train = $train, _NumberOfTrainsInDialog = $_NumberOfTrainsInDialog"
      if {$tindex > $_NumberOfTrainsInDialog} {
	ttk::button $scheduleFrame.number$tindex
	ttk::label  $scheduleFrame.name$tindex   -anchor w
	ttk::label  $scheduleFrame.speed$tindex  -anchor e    
	ttk::label  $scheduleFrame.orig$tindex   -anchor w
	ttk::label  $scheduleFrame.dest$tindex   -anchor w
	ttk::label  $scheduleFrame.length$tindex -anchor e
	ttk::label  $scheduleFrame.time$tindex   -anchor e
	foreach w  {number name speed orig dest length time} \
		c  {0      1    2     3    4    5      6} \
		sk {e      w    e     w    w    e      e} {
	  grid configure $scheduleFrame.${w}$tindex -column $c -row $tindex -sticky $sk
	}
        incr _NumberOfTrainsInDialog
      }
      $scheduleFrame.number$tindex configure \
		-text "[Train_Number $train]" \
		-command [list TimeTable::displayOneTrain draw \
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
#	puts stderr "*** viewAllTrainsDialog::draw: ForEveryStop: sindex = $sindex, station = $station"
        set smile [Station_SMile $station]
        if {$oldDepart >= 0} {
	  set arrival [expr {$oldDepart + (abs($smile - $oldSmile) * (double($speed) / 60.0))}]
        } else {
	  set arrival $departure
        }
        set depart [Stop_Departure $stop $arrival]
	set smileN 0
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
      $scheduleFrame.length$tindex configure -text [expr {$smileN - $smile0}]
      set rtime [expr {$arrival - $departure}]
      set rtimeFmt [format {%2d:%02d} [expr {int($rtime) / 60}] [expr {int($rtime) % 60}]]
      $scheduleFrame.time$tindex configure -text "$rtimeFmt"
    }
#    puts stderr "*** viewAllTrainsDialog::draw: tindex = $tindex, _NumberOfTrainsInDialog = $_NumberOfTrainsInDialog"
    for {set iextra $tindex} {$iextra < $_NumberOfTrainsInDialog} {incr iextra} {
      foreach w {number name speed orig dest length time} {
        destroy scheduleFrame.${w}$iextra
      }
    }
    update idle
    set dialogWidth [expr {60 + [winfo reqwidth $scheduleFrame]}]
    set dialogHeight [expr {(4 * $dialogWidth) / 3}]
    if {$dialogHeight > 500} {set dialogHeight 500}
    set geo "${dialogWidth}x${dialogHeight}"
    $dialog configure -geometry "$geo"    
    set _NumberOfTrainsInDialog $tindex
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }
  
}

proc TimeTable::ViewAllTrains {} {
  viewAllTrainsDialog draw
}

catch {
$TimeTable::Main menu sethelpvar view
$TimeTable::Main menu add view command -label [_m "Menu|View|View One Train"] -command TimeTable::ViewOneTrain \
		      -dynamichelp [_ "View a single train"] -state disabled
$TimeTable::Main menu add view command -label [_m "Menu|View|View All Trains"] -command TimeTable::ViewAllTrains \
		      -dynamichelp [_ "View all trains"] -state disabled 
}

snit::type TimeTable::editTrainDialog {
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
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .editTrainDialog \
			-bitmap questhead \
			-default 0 -cancel 1 -modal local -transient yes \
			-parent . -side bottom -title [_ "Edit Train"]]
    $dialog add done -text [_m "Button|Done"] -command [mytypemethod _Done]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Edit Train Dialog}]
    set frame [$dialog getframe] 
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Edit Train"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set editpages [PagesManager $frame.editpages]
    pack $editpages -expand yes -fill both
    set basicpageframe [$editpages add basicpage]
    set lwidth [_mx "Label|Name:"  "Label|Number:" "Label|Class:" \
		    "Label|Speed:" "Label|Origin:" "Label|Termination:" \
		    "Label|Departure:"]
    set name	[LabelEntry $basicpageframe.name \
			-label [_m "Label|Name:"] -labelwidth $lwidth]
    pack $name -fill x
    set number	[LabelEntry $basicpageframe.number \
			-label [_m "Label|Number:"] -labelwidth $lwidth]
    pack $number -fill x
    set class	[LabelComboBox $basicpageframe.class \
			-label [_m "Label|Class:"] -labelwidth $lwidth \
			-values {1 2 3 4 5 6 7 8 9 10} -editable no]
    pack $class -fill x
    set speed	[LabelSpinBox $basicpageframe.speed \
    			-label [_m "Label|Speed:"] -labelwidth $lwidth \
			-range {10 150 5}]
    pack $speed	-fill x
    set  departure [LabelFrame $basicpageframe.departure \
			-text [_m "Label|Departure:"] -width $lwidth]
    pack $departure -fill x
    set departureFrame [$departure getframe]
    set  departureHours [spinbox $departureFrame.departureHours \
                         -width 2 -from 0 -to 23 -increment 1 \
                         -justify r]
    pack $departureHours -side left
    pack [ttk::label $departureFrame.colon -text {:}] -side left
    set departureMinutes [spinbox $departureFrame.departureMinutes \
                          -width 2 -from 0 -to 59 -increment 1 \
                          -justify r \
                          -command [mytypemethod _FormatMinutes %W]]
    pack $departureMinutes -side left
    pack [frame $departureFrame.filler -bd 0 -relief flat] -side right -fill x
    set firststation  [LabelComboBox $basicpageframe.firststation \
			-label [_m "Label|Origin:"] -labelwidth $lwidth -editable no]
    pack $firststation -fill x
    set laststation  [LabelComboBox $basicpageframe.laststation \
			-label [_m "Label|Termination:"] -labelwidth $lwidth -editable no]
    pack $laststation -fill x
    set basicpagebuttons [ButtonBox $basicpageframe.basicpagebuttons \
				-orient horizontal]
    pack $basicpagebuttons -fill x
    $basicpagebuttons add ttk::button next -text [_m "Button|Schedule"] \
			  -command [mytypemethod _GotoSchedulePage]
    $basicpagebuttons add ttk::button reset -text [_m "Button|Reset Information"] \
			  -command [mytypemethod _ResetBasicPage]
    set scheduleframe  [$editpages add schedule]
    set schedscroll    [ScrolledWindow $scheduleframe.schedscroll \
				-auto both -scrollbar both]
    pack $schedscroll -expand yes -fill both
    set schedscrollframe [ScrollableFrame $schedscroll.schedscrollframe]
    $schedscroll setwidget $schedscrollframe
    set schedule [$schedscrollframe getframe]
    ttk::label $schedule.mile0 -text [_m "Label|Smile"]
    ttk::label $schedule.arrive0 -text [_m "Label|Arrival"]
    ttk::label $schedule.station0 -text [_m "Label|Station Name"]
    ttk::label $schedule.layover0 -text [_m "Label|Layover"]
    ttk::label $schedule.depart0 -text [_m "Label|Departure"]
    ttk::label $schedule.cab0 -text [_m "Label|Cab"]
    ttk::label $schedule.update0
    foreach wid    {mile arrive station layover depart cab update} \
	    col    {0    1      2       3       4      5   6} \
	    sticky {e    e      w       e       e      w   w} {
      grid configure $schedule.${wid}0 -column $col -row 0 -sticky $sticky
    }
    set schedulebuttons  [ButtonBox $scheduleframe.buttons \
					-orient horizontal]
    pack $schedulebuttons -fill x
    $schedulebuttons add ttk::button next -text [_m "Button|Storage"] \
			 -command [mytypemethod _GotoStoragePage]
    $schedulebuttons add ttk::button reset -text [_m "Button|Reset Schedule"] \
			 -command [mytypemethod _ResetSchedule]
    set storageframe   [$editpages add storage]
    set storagescroll [ScrolledWindow $storageframe.storagescroll \
				-auto both -scrollbar both]
    pack $storagescroll -expand yes -fill both
    set storagescrollframe [ScrollableFrame $storagescroll.storagescrollframe]
    $storagescroll setwidget $storagescrollframe
    set storage [$storagescrollframe getframe]
    ttk::label $storage.mile0 -text [_m "Label|Smile"]
    ttk::label $storage.arrive0 -text [_m "Label|Arrival"]
    ttk::label $storage.station0 -text [_m "Label|Station Name"]
    ttk::label $storage.track0 -text [_m "Label|Storage Track"]
    ttk::label $storage.depart0 -text [_m "Label|Departure"]
    foreach wid    {mile arrive station track depart} \
	    col    {0    1      2       3     4} \
	    sticky {e    e      w       w     e} {
      grid configure $storage.${wid}0 -column $col -row 0 -sticky $sticky
    }
    set storagebuttons [ButtonBox $storageframe.buttons \
					-orient horizontal]
    pack $storagebuttons -fill x
    $storagebuttons add ttk::button reset -text [_m "Button|Reset Storage"] \
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
    $type createDialog
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
      set _Last  [expr {[TimeTable NumberOfStations] - 1}]
      set _Departure 0
      set _EditFlag no
      $number configure -editable yes
   } else {
      set _Name   "[Train_Name $_Train]"
      set _Number "[Train_Number $_Train]"
      set _Class  [Train_ClassNumber $_Train]
      set _Speed  [Train_Speed $_Train]
      set _First  [Stop_StationIndex [Train_StopI $_Train 0]]
      set _Last   [Stop_StationIndex [Train_StopI $_Train [expr {[Train_NumberOfStops $_Train] - 1}]]]
      set _Departure [Train_Departure $_Train]
      $number configure -editable no
      set _EditFlag yes
    }
    $type _ResetBasicPage
    $editpages raise basicpage
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }
  
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog cancel]
  }
  
  typemethod _Done {} {
    $dialog withdraw
    foreach stop [array names _StopStorageTrack] {
      set storage_row $_StopStorageTrack($stop)
      if {$storage_row < 0} {
	set _StopStorageTrack($stop) {}
      } else {
	set _StopStorageTrack($stop) "[$storage.track$_StopStorageTrack($stop) cget -text]"
      }
    }
    return [$dialog enddialog done]
  }
  
  typemethod _GotoSchedulePage {} {
    set _Name "[$name cget -text]"
    set _Number "[$number cget -text]"
    set _Class [$class cget -text]
    set _Speed [$speed cget -text]
    set _First [TimeTable FindStationByName "[$firststation get]"]
    set _Last  [TimeTable FindStationByName "[$laststation get]"]
    scan [$departureHours cget -text] {%d} dHours
    scan [$departureMinutes cget -text] {%02d} dMinutes
    set _Departure [expr {$dHours * 60}]
    incr _Departure $dMinutes
    $type _ResetSchedule
    $editpages raise schedule
  }
  
  typemethod _AddOrUpdateScheduleRow {row smile stationName arrival depart \
				      layover cabName} {
      if {$row >= $_NumberOfScheduleRows} {
          ttk::label $schedule.mile$_NumberOfScheduleRows
          ttk::entry $schedule.arrive$_NumberOfScheduleRows -state readonly -width 6
          ttk::label $schedule.station$_NumberOfScheduleRows
          spinbox $schedule.layover$_NumberOfScheduleRows \
		-from 0 -to 999 -increment 1 -width 6
          ttk::entry $schedule.depart$_NumberOfScheduleRows -state readonly -width 9
          ttk::combobox $schedule.cab$_NumberOfScheduleRows \
		-values [TimeTable CabNameList] -width 6
          ttk::button $schedule.update$_NumberOfScheduleRows \
		-text Update \
		-command "[mytypemethod _UpdateScheduleRow] [expr {$_NumberOfScheduleRows - 1}]"
          foreach wid    {mile arrive station layover depart cab update} \
                col    {0    1      2       3       4      5   6} \
                sticky {e    e      w       e       e      w   w} {
              grid configure $schedule.${wid}$_NumberOfScheduleRows \
                    -column $col -row $_NumberOfScheduleRows -sticky $sticky
          }
          incr _NumberOfScheduleRows
      }
      $schedule.layover$row configure -state normal
      $schedule.update$row configure -state normal
      $schedule.cab$row configure -state normal
      $schedule.mile$row configure -text $smile
      if {$arrival < 0} {
          $schedule.arrive$row configure -state normal
          $schedule.arrive$row delete 0 end
          $schedule.arrive$row insert end {Origin}
          $schedule.arrive$row configure -state readonly
          $schedule.layover$row configure -state readonly
      } else {
          $schedule.arrive$row configure -state normal
          $schedule.arrive$row delete 0 end
          $schedule.arrive$row insert end \
                [format {%2d:%02d} [expr {int($arrival) / 60}] \
                 [expr {int($arrival) % 60}]]
          $schedule.arrive$row configure -state readonly
      }
      $schedule.station$row configure -text "$stationName"
      $schedule.layover$row configure -text $layover
      if {$depart < 0} {
          $schedule.depart$row configure -state normal
          $schedule.depart$row delete 0 end
          $schedule.depart$row insert end {Terminate}
          $schedule.depart$row configure -state readonly
          $schedule.layover$row configure -state readonly
          $schedule.update$row configure -state disabled
          $schedule.cab$row configure -state disabled
      } else {
          $schedule.depart$row configure -state normal
          $schedule.depart$row delete 0 end
          $schedule.depart$row insert end \
                [format {%2d:%02d} [expr {int($depart) / 60}] \
                 [expr {int($depart) % 60}]]
          $schedule.depart$row configure -state readonly
          
      }
      $schedule.cab$row set [lindex [$schedule.cab$row cget -values] 0]
      if {[string length "$cabName"]} {
          set index [lsearch [$schedule.cab$row cget -values] "$cabName"]
          if {$index >= 0} {$schedule.cab$row set "$cabName"}
      }
  }
  
  typemethod _UpdateScheduleRow {stopNumber} {
      set rowNumber [expr {$stopNumber + 1}]
      set _StopLayover($stopNumber) [$schedule.layover$rowNumber cget -text]
      set _StopCab($stopNumber) "[$schedule.cab$rowNumber cget -text]"
      if {$stopNumber > 0} {
          scan [$schedule.arrive$rowNumber get] {%2d:%02d} h m
          set arrival [expr {($h * 60) + $m}]
          scan [$schedule.depart$rowNumber get] {%2d:%02d} h m
          set olddepart [expr {($h * 60) + $m}]
          set newdepart [expr {$arrival + $_StopLayover($stopNumber)}]
          set diff [expr {$newdepart - $olddepart}]
      } else {
          set diff 0
      }
      for {set row $rowNumber} {$row < $_NumberOfScheduleRows} {incr row} {
          if {$diff > 0} {
              scan [$schedule.arrive$row get] {%2d:%02d} h m
              set arrival [expr {($h * 60) + $m}]
              if {$row > $rowNumber} {
                  set arrival [expr {$arrival + $diff}]
                  $schedule.arrive$row configure -state normal
                  $schedule.arrive$row delete 0 end
                  $schedule.arrive$row insert end \
                        [format {%2d:%02d} [expr {int($arrival) / 60}] \
                         [expr {int($arrival) % 60}]]
                  $schedule.arrive$row configure -state readonly
              }
              if {![string equal [$schedule.depart$row get] {Terminate}]} {
                  scan [$schedule.depart$row get -text] {%2d:%02d} h m
                  set depart [expr {($h * 60) + $m}]
                  set depart [expr {$depart + $diff}]
                  $schedule.depart$row configure -state normal
                  $schedule.depart$row delete 0 end
                  $schedule.depart$row insert end \
                        [format {%2d:%02d} [expr {int($depart) / 60}] \
                         [expr {int($depart) % 60}]]
                  $schedule.depart$row configure -state readonly
              }
          }
          set index [lsearch [$schedule.cab$row cget -values] "$_StopCab($stopNumber)"]
          if {$index >= 0} {$schedule.cab$row set "$_StopCab($stopNumber)"}
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
      $firststation configure -text "[Station_Name [TimeTable IthStation $_First]]"
      $laststation  configure -text "[Station_Name [TimeTable IthStation $_Last]]"
      set dHours [expr {int($_Departure) / 60}]
      set dMinutes [expr {int($_Departure) % 60}]
      $departureHours configure -text $dHours
      $departureMinutes configure -text [format {%02d} $dMinutes]
  }
  typemethod _GotoStoragePage {} {
      foreach stop [array names _StopLayover] {
          set sched_row [expr {$stop + 1}]
          set _StopLayover($stop) [$schedule.layover$sched_row cget -text]
          set _StopCab($stop)     "[$schedule.cab$sched_row cget -text]"
          if {$sched_row > 1} {
              scan [$schedule.arrive$sched_row get] {%2d:%02d} h m
              set _StopArrival($stop) [expr {($h * 60) + $m}]
          }
      }
      if {[$type _ResetStorage]} {
          $editpages raise storage
      } else {
          $type _Done
      }
      
  }
  typemethod _ResetSchedule {} {
      set numberOfStops [expr {abs($_Last - $_First) + 1}]
      set depart $_Departure
      set lastsmile -1
      array unset _StopLayover
      array unset _StopCab
      for {set stop 0} {$stop < $numberOfStops} {incr stop} {
          #      puts stderr  "*** $type _ResetSchedule: stop = $stop, _First = $_First"
          if {$_Last > $_First} {
              set station [TimeTable IthStation [expr {$_First + $stop}]]
          } else {
              set station [TimeTable IthStation [expr {$_First - $stop}]]
          }
          #      puts stderr  "*** $type _ResetSchedule: station = $station"
          set smile [Station_SMile $station]
          #      puts stderr  "*** $type _ResetSchedule: smile =  $smile"
          if {$stop == 0} {
              set layover -
              set arrival -1
          } else {
              if {$_EditFlag} {
                  set layover [Stop_Layover [Train_StopI $_Train $stop]]
              } else {
                  set layover 0
              }
              set arrival [expr {$depart + ((double($_Speed) / 60.0) * \
                                            abs($smile - $lastsmile))}]
          }
          #      puts stderr  "*** $type _ResetSchedule: layover = $layover"
          #      puts stderr  "*** $type _ResetSchedule: arrival = $arrival"
          set cabName {}
          if {$_EditFlag} {
              set cab [Stop_TheCab [Train_StopI $_Train $stop]]
              if {![string equal $cab NULL]} {
                  set cabName [Cab_Name $cab]
              }
          }
          #      puts stderr  "*** $type _ResetSchedule: cabName = $cabName"
          if {[expr {$stop + 1}] == $numberOfStops} {
              set depart -1
              set layover -
          } elseif {$stop != 0} {
              set depart [expr {$arrival + $layover}]
          }
          #      puts stderr  "*** $type _ResetSchedule: depart = $depart"
          set _StopLayover($stop) $layover
          set _StopCab($stop) "$cabName"
          $type _AddOrUpdateScheduleRow [expr {$stop + 1}] $smile [Station_Name $station] \
                $arrival $depart $layover "$cabName"
          set lastsmile $smile
          
      }
      set lastrow [expr {$stop + 1}]
      while {$lastrow < $_NumberOfScheduleRows} {
          $type _DeleteLastScheduleRow
      }
      #    puts stderr "*** ${type} _ResetSchedule: lastrow = $lastrow, _NumberOfScheduleRows = $_NumberOfScheduleRows"
      $editpages compute_size
  }
  typemethod _ResetStorage {} {
      set storage_row 0
      array unset _StopStorageTrack
      set hasStorageTracks no
      foreach stop [lsort -integer [array names _StopLayover]] {
          if {$_First < $_Last} {
              set station [TimeTable IthStation [expr {$_First + $stop}]]
          } else {
              set station [TimeTable IthStation [expr {$_First - $stop}]]
          }
          #      puts stderr "*** $type _ResetStorage: station = $station"
          set sched_row [expr {$stop + 1}]
          set arrival [$schedule.arrive$sched_row get]
          set depart  [$schedule.depart$sched_row get]
          set layover $_StopLayover($stop)
          set numtracks [Station_NumberOfStorageTracks $station]
          #      puts stderr "*** $type _ResetStorage: stop = $stop, station = $station, sched_row = $sched_row, arrival = $arrival, depart = $depart, layover = $layover, numtracks = $numtracks"
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
      #    puts stderr "*** $type _ResetStorage: hasStorageTracks = $hasStorageTracks"
      return $hasStorageTracks
  }

  typemethod _AddOrUpdateStorageRow {row arrival station storageTrack depart} {
      if {$row >= $_NumberOfStorageRows} {
          ttk::label $storage.mile$_NumberOfStorageRows
          ttk::label $storage.arrive$_NumberOfStorageRows
          ttk::label $storage.station$_NumberOfStorageRows
          ttk::combobox $storage.track$_NumberOfStorageRows -state readonly
          ttk::label $storage.depart$_NumberOfStorageRows
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
      $storage.track$row set "$storageTrack"
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

proc TimeTable::AddTrain {} {
#  puts stderr "*** AddTrain"
  set result [editTrainDialog draw -title {Create New Train}]
#  puts stderr "*** AddTrain: result = $result"
  if {[string equal "$result" cancel]} {return}
  set name   "[editTrainDialog getName]"
  set number "[editTrainDialog getNumber]"
  if {![string equal [TimeTable FindTrainByNumber "$number"] NULL]} {
    TtErrorMessage draw -message [_ "Train number already in use: %s, pick another!" $number]
    return
  }
  if {![string equal [TimeTable FindTrainByName "$name"] NULL]} {
    TtInfoMessage draw -message [_ "Duplicate train name: %s." $name]
  }
  set speed [editTrainDialog getSpeed]
  set classnumber [editTrainDialog getClass]
  set departure [editTrainDialog getDeparture]
  set start [editTrainDialog getFirst]
  set end [editTrainDialog getLast]
#  puts stderr "*** AddTrain: start = $start, end = $end"
  set numberOfStops [expr {abs($end - $start) + 1}]
  set layoverList {}
  set cabnameList {}
  set storageTrackList {}
  for {set istop 0} {$istop < $numberOfStops} {incr istop} {
    lappend layoverList [editTrainDialog getStopLayover $istop]
    lappend cabnameList "[editTrainDialog getStopCab $istop]"
    lappend storageTrackList "[editTrainDialog getStopStorageTrack $istop]"
  }
  if {[catch {TimeTable AddTrainLongVersion "$name" "$number" $speed \
					    $classnumber $departure $start \
					    $end $layoverList $cabnameList \
					    $storageTrackList} result]} {
    if {[lindex $result 0] == "NULL"} {set result [lindex $result 1]}
    set error "Error adding train $number: $result"
    TtErrorMessage draw -message "$error"
    return
  } else {
    $TimeTable::ChartDisplay addATrain [TimeTable cget -this] $result
  }
}

proc TimeTable::EditTrain {} {
  TtInfoMessage draw -message [_ "Edit Train Not Implemented Yet!"]
#  puts stderr "*** EditTrain"
#  set trainNum "[SelectOneTrainDialog draw]"
#  if {[string equal "$trainNum" {}]} {return}
#  set train [TimeTable FindTrainByNumber "$trainNum"]
#  if {[string equal "$train" NULL]} {return}
#  set result [editTrainDialog draw -title "Edit Train [Train_Number $train]" -train $train]
#  puts stderr "*** EditTrain: result = $result"
}

proc TimeTable::DeleteTrain {} {
  puts stderr "*** DeleteTrain"
  set trainNum "[SelectOneTrainDialog draw]"
  if {[string equal "$trainNum" {}]} {return}
  set train [TimeTable FindTrainByNumber "$trainNum"]
  if {[string equal "$train" NULL]} {return}
  if {![TtYesNo draw -title [_ "Delete Train?"] \
	-message [_ "Are you SURE you want to delete train %s?" $trainNum]]} {return}
  if {[catch "TimeTable DeleteTrain $trainNum" result]} {
    set error [_ "Error deleting train %s: %s" $trainNum [lindex $result 1]]
    TtErrorMessage draw -message "$error"
    set result [lindex $result 0]
  }
  if {$result} {
    $TimeTable::ChartDisplay deleteTrain "$trainNum"
  }
}

catch {
$TimeTable::Main menu add trains command -label [_m "Menu|Trains|Add Train"] -command TimeTable::AddTrain \
			-dynamichelp [_ "Add a new train"]
#$TimeTable::Main menu add trains command -label [_m "Menu|Trains|Edit Train"] -command TimeTable::EditTrain \
#			-dynamichelp [_ "Edit a train"]
$TimeTable::Main menu add trains command -label [_m "Menu|Trains|Delete Train"] -command TimeTable::DeleteTrain \
			-dynamichelp [_ "Delete a train"]
$TimeTable::Main buttons add ttk::button addTrain \
	-text [_m "Button|Add a new train"] -command TimeTable::AddTrain -state disabled
#	-helptext [_ "Add a new train"] 
#$TimeTable::Main buttons add ttk::button editTrain \
#	-text [_m "Button|Edit an existing train"] -command TimeTable::EditTrain \
#	-helptext [_ "Edit an existin train"] -state disabled
$TimeTable::Main buttons add ttk::button deleteTrain \
      -text [_m "Button|Delete an existing train"] \
      -command TimeTable::DeleteTrain \
      -state disabled
#	-helptext [_ "Delete an existing train"] 
image create photo AddTrainButtonImage -file [file join $TimeTable::ImageDir addtrain.gif]
$TimeTable::Main toolbar addbutton tools addtrain -image AddTrainButtonImage \
			-command TimeTable::AddTrain \
			-helptext [_ "Add a new train"] -state disabled
#image create photo EditTrainButtonImage -file [file join $TimeTable::ImageDir edittrain.gif]
#$TimeTable::Main toolbar addbutton tools edittrain -image EditTrainButtonImage \
#			-command TimeTable::EditTrain \
#			-helptext [_ "Edit an existing train"] -state disabled
image create photo DeleteTrainButtonImage -file [file join $TimeTable::ImageDir deletetrain.gif]
$TimeTable::Main toolbar addbutton tools deletetrain -image DeleteTrainButtonImage \
			-command TimeTable::DeleteTrain \
			-helptext [_ "Delete an existing train"] -state disabled
}

proc TimeTable::EnableTrainCommands {} {
  variable Main
  $Main mainframe setmenustate trains:menu normal
  $Main buttons itemconfigure addTrain -state normal
#  $Main buttons itemconfigure editTrain -state normal
  $Main buttons itemconfigure deleteTrain -state normal
  $Main toolbar buttonconfigure tools addtrain -state normal
#  $Main toolbar buttonconfigure tools editTrain -state normal
  $Main toolbar buttonconfigure tools deletetrain -state normal
  $Main menu entryconfigure view {View One Train} -state normal  
  $Main menu entryconfigure view {View All Trains} -state normal  
}

package provide TTTrains 1.0
