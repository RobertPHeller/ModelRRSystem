#* 
#* ------------------------------------------------------------------
#* TTPrint.tcl - Print code
#* Created by Robert Heller on Sat Apr  1 23:08:47 2006
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.5  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
#* Modification History: Revision 1.4  2007/10/17 14:06:33  heller
#* Modification History: Dialog fixes
#* Modification History:
#* Modification History: Revision 1.3  2007/09/03 14:39:28  heller
#* Modification History: Rev 2.1.9 Lockdown
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

catch {TimeTable::SplashWorkMessage {Loading Print Code} 88}

package require snit

package require BWLabelSpinBox
package require BWLabelComboBox
package require BWFileEntry

namespace eval TimeTable {

  variable LargePrinterImage {}
  catch {
    variable ImageDir
    set LargePrinterImage [image create photo \
				-file [file join $ImageDir largePrinter.gif]]
  }
}

snit::type TimeTable::printConfigurationDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerlabel
  typecomponent configurationnotebook
  typevariable _LocalPrintConfiguration -array {}

  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .printConfigurationDialog \
			-image $TimeTable::LargePrinterImage \
			-default 0 -cancel 2 -modal local -transient yes \
			-parent . -side bottom -title {Print Configuration}]
    $dialog add -name ok -text OK -command [mytypemethod _OK]
    $dialog add -name apply -text Apply -command [mytypemethod _Apply]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Print Configuration Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Print Configuration}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set configurationnotebook $frame.configurationnotebook
    NoteBook::create $frame.configurationnotebook -homogeneous yes -side top
    pack $configurationnotebook -expand yes -fill both
    $type _BuildGeneral [NoteBook::insert $configurationnotebook end general \
			-text General \
			-leavecmd [mytypemethod _LeaveGeneral] \
			-raisecmd [mytypemethod _RaiseGeneral]]
    $type _BuildMulti [NoteBook::insert $configurationnotebook end multi \
			-text Multi \
			-leavecmd [mytypemethod _LeaveMulti] \
			-raisecmd [mytypemethod _RaiseMulti]]
    $type _BuildGroups [NoteBook::insert $configurationnotebook end groups \
			-text Groups \
			-leavecmd [mytypemethod _LeaveGroups] \
			-raisecmd [mytypemethod _RaiseGroups]]
    NoteBook::compute_size $configurationnotebook
    update idle
    set fw 750
    set fh [expr int($fw*.75)]
    $dialog configure -geometry [expr $fw]x[expr $fh]
  }
  typecomponent generalFrame
  typecomponent titleLE
  typecomponent subtitleLE
  typecomponent dateLE
  typecomponent nSidesLCB
  typecomponent timeformatLF
  typevariable  _TimeFormat
  typecomponent ampmLF
  typecomponent ampmLF_RBS
  typevariable _AMPMFormat
  typecomponent directionLCB
  typecomponent stationcwLSB
  typecomponent timecwLSB
  typecomponent extraPreambleLF
  typecomponent extraPreambleText
  typemethod _BuildGeneral {frame} {
    set generalFrame $frame
    set titleLE $frame.titleLE
    pack [LabelEntry::create $titleLE \
			     -side left -label "Title:" \
			     -labelwidth 30] -fill x
    set subtitleLE $frame.subtitleLE
    pack [LabelEntry::create $subtitleLE \
			     -side left -label "Sub Title:" \
			     -labelwidth 30] -fill x
    set dateLE $frame.dateLE
    pack [LabelEntry::create $dateLE \
			     -side left -label "Date:" \
			     -labelwidth 30] -fill x
    set nSidesLCB $frame.nSidesLCB
    pack [LabelComboBox $nSidesLCB -editable no \
			     -side left -label "Number of sides:" \
			     -labelwidth 30 -values {single double}] -fill x
    set timeformatLF $frame.timeformatLF
    pack [LabelFrame::create $timeformatLF \
			     -side left -text "Time Format:" \
			     -width 30] -fill x
    set timeformatLF_frame [LabelFrame::getframe $timeformatLF]
    pack [radiobutton $timeformatLF_frame.rb24 \
			-text "24 Hour" -value 24 \
			-command [mytypemethod _Disable_AMPMFormat] \
			-variable [mytypevar _TimeFormat] \
			-indicatoron yes] -side left -expand yes -fill x
    pack [radiobutton $timeformatLF_frame.rb12 \
			-text "12 Hour" -value 12 \
			-command [mytypemethod _Enable_AMPMFormat] \
			-variable [mytypevar _TimeFormat] \
			-indicatoron yes] -side left -expand yes -fill x
    set _TimeFormat 24
    set ampmLF $frame.ampmLF
    pack [LabelFrame::create $ampmLF \
			     -side left -text "AM/PM format:" \
			     -width 30 -state disabled] -fill x
    set ampmLF_frame [LabelFrame::getframe $ampmLF]
    pack [radiobutton $ampmLF_frame.rb_ap \
    			-text "Small a or p" -value a -anchor w \
			-variable [mytypevar _AMPMFormat] \
			-indicatoron yes -state disabled] -fill x
    lappend ampmLF_RBS $ampmLF_frame.rb_ap
    pack [radiobutton $ampmLF_frame.rb_AP \
    			-text "Large AM or PM" -value AP  -anchor w \
			-variable [mytypevar _AMPMFormat] \
			-indicatoron yes -state disabled] -fill x
    lappend ampmLF_RBS $ampmLF_frame.rb_AP
    pack [radiobutton $ampmLF_frame.rb_lB \
    			-text "Light font for AM, bold font for PM" -value lB \
			-variable [mytypevar _AMPMFormat]  -anchor w \
			-indicatoron yes -state disabled] -fill x
    lappend ampmLF_RBS $ampmLF_frame.rb_lB
    set _AMPMFormat a
    set directionLCB $frame.directionLCB
    pack [LabelComboBox::create $directionLCB \
				-side left \
				-label "Forward Direction is generally:" \
				-labelwidth 30 \
				-values {Northbound Eastbound
					 Southbound Westbound} \
				-editable no] -fill x
    $directionLCB setvalue first
    set stationcwLSB $frame.stationcwLSB
    pack [LabelSpinBox::create $stationcwLSB \
			       -side left \
			       -label "Station Column Width:" \
			       -labelwidth 30 \
			       -range {.125 2.5 .125} \
			       -text 1.5] -fill x
    set timecwLSB $frame.timecwLSB
    pack [LabelSpinBox::create $timecwLSB \
			       -side left \
			       -label "Time Column Width:" \
			       -labelwidth 30 \
			       -range {.125 2.5 .125} \
			       -text .5] -fill x
    set extraPreambleLF $frame.extraPreambleLF
    pack [LabelFrame::create $extraPreambleLF \
		-side top -text "Additional LaTeX preamble code:"] -fill both
    set extraPreambleLF_frame [LabelFrame::getframe $extraPreambleLF]
    set extraPreambleLF_sw $extraPreambleLF_frame.sw
    pack [ScrolledWindow::create $extraPreambleLF_sw -auto both \
						     -scrollbar both] \
	-expand yes -fill both
    set extraPreambleText $extraPreambleLF_sw.text
    pack [text $extraPreambleText -wrap word -width 40 -height 5] \
	-expand yes -fill both
    ScrolledWindow::setwidget $extraPreambleLF_sw $extraPreambleText
  }
  typemethod _LeaveGeneral {} {
    set _LocalPrintConfiguration(Title) "[$titleLE cget -text]"
    set _LocalPrintConfiguration(SubTitle) "[$subtitleLE cget -text]"
    set _LocalPrintConfiguration(Date) "[$dateLE cget -text]"
    set _LocalPrintConfiguration(TimeFormat) "$_TimeFormat"
    set _LocalPrintConfiguration(AMPMFormat) "$_AMPMFormat"
    set _LocalPrintConfiguration(DirectionName) "[$directionLCB get]"
    set _LocalPrintConfiguration(StationColWidth) [$stationcwLSB cget -text]
    set _LocalPrintConfiguration(TimeColWidth) [$timecwLSB cget -text]
    set _LocalPrintConfiguration(NSides) [$nSidesLCB get]
    set _LocalPrintConfiguration(ExtraPreamble) "[$extraPreambleText get 1.0 end-1c]"
    return 1
  }
  typemethod _RaiseGeneral {} {
    if {[catch {set _LocalPrintConfiguration(Title)}]} {
      set _LocalPrintConfiguration(Title) "My Model Railroad Timetable"
    }
    $titleLE configure -text "$_LocalPrintConfiguration(Title)"
    if {[catch {set _LocalPrintConfiguration(SubTitle)}]} {
      set _LocalPrintConfiguration(SubTitle) "Employee Timetable Number 1"
    }
    $subtitleLE configure -text "$_LocalPrintConfiguration(SubTitle)"
    if {[catch {set _LocalPrintConfiguration(Date)}]} {
      set _LocalPrintConfiguration(Date) "\\today"
    }
    $dateLE configure -text "$_LocalPrintConfiguration(Date)"
    if {[catch {set _LocalPrintConfiguration(TimeFormat)}]} {
      set _LocalPrintConfiguration(TimeFormat) "24"
    }
    if {[catch {set _LocalPrintConfiguration(NSides)}]} {
      set _LocalPrintConfiguration(NSides) "single"
    }
    $nSidesLCB setvalue @[lsearch -exact [$nSidesLCB cget -values] "$_LocalPrintConfiguration(NSides)"]
    set _TimeFormat "$_LocalPrintConfiguration(TimeFormat)"
    if {[catch {set _LocalPrintConfiguration(AMPMFormat)}]} {
      set _LocalPrintConfiguration(AMPMFormat) "a"
    }
    set _AMPMFormat "$_LocalPrintConfiguration(AMPMFormat)"
    if {[catch {set _LocalPrintConfiguration(DirectionName)}]} {
      set _LocalPrintConfiguration(DirectionName) "Northbound"
    }
    $directionLCB setvalue @[lsearch -exact [$directionLCB cget -values] \
				"$_LocalPrintConfiguration(DirectionName)"]
    if {[catch {set _LocalPrintConfiguration(StationColWidth)}]} {
      set _LocalPrintConfiguration(StationColWidth) 1.5
    }
    $stationcwLSB configure -text $_LocalPrintConfiguration(StationColWidth)
    if {[catch {set _LocalPrintConfiguration(TimeColWidth)}]} {
      set _LocalPrintConfiguration(TimeColWidth) 0.5
    }
    $timecwLSB configure -text $_LocalPrintConfiguration(TimeColWidth)
    if {[catch {set _LocalPrintConfiguration(ExtraPreamble)}]} {
      set _LocalPrintConfiguration(ExtraPreamble) {}
    }
    $extraPreambleText delete 1.0 end
    $extraPreambleText insert end "$_LocalPrintConfiguration(ExtraPreamble)"
  }
  typemethod _Disable_AMPMFormat {} {
    $ampmLF configure -state disabled
    foreach rb $ampmLF_RBS {$rb configure -state disabled}
  }
  typemethod _Enable_AMPMFormat {} {
    $ampmLF configure -state normal
    foreach rb $ampmLF_RBS {$rb configure -state normal}
  }
  typecomponent multiFrame
  typecomponent tocP
  typecomponent useMultipleTablesP
  typecomponent beforeTOCLF
  typecomponent beforeTOCText
  typecomponent notesTOPLF
  typecomponent notesTOPText
  typecomponent allTrainsHeaderLE
  typecomponent allTrainsSectionTOPLF
  typecomponent allTrainsSectionTOPText
  typemethod _BuildMulti {frame} {
    set multiFrame $frame
    set tocP $frame.tocP
    pack [LabelComboBox::create $tocP \
			-side left \
			-label "Create Table Of Contents?" \
			-labelwidth 30 \
			-editable no \
			-values {no yes}] -fill x
    $tocP setvalue last
    set useMultipleTablesP $frame.useMultipleTablesP
    pack [LabelComboBox::create $useMultipleTablesP \
			-side left \
			-label "Use multiple tables?" \
			-labelwidth 30 \
			-modifycmd [mytypemethod _SetGroupsState] \
			-editable no \
			-values {no yes}] -fill x
    $useMultipleTablesP setvalue last
    set beforeTOCLF $frame.beforeTOCLF
    pack [LabelFrame::create $beforeTOCLF \
			-side top \
			-text "LaTeX code before the Table of Contents:"] \
	 -fill both
    set beforeTOCLF_frame [LabelFrame::getframe $beforeTOCLF]
    set beforeTOCLF_sw    $beforeTOCLF_frame.sw
    pack [ScrolledWindow::create $beforeTOCLF_sw -auto both -scrollbar both] \
	-expand yes -fill both
    set beforeTOCText $beforeTOCLF_sw.text
    pack [text $beforeTOCText -wrap word -width 40 -height 5] \
	-expand yes -fill both
    ScrolledWindow::setwidget $beforeTOCLF_sw $beforeTOCText
    set notesTOPLF $frame.notesTOPLF
    pack [LabelFrame::create $notesTOPLF \
			-side top \
			-text "LaTeX code at the beginning of the notes section:"] \
	 -fill both
    set notesTOPLF_frame [LabelFrame::getframe $notesTOPLF]
    set notesTOPLF_sw    $notesTOPLF_frame.sw
    pack [ScrolledWindow::create $notesTOPLF_sw -auto both -scrollbar both] \
	-expand yes -fill both
    set notesTOPText $notesTOPLF_sw.text
    pack [text $notesTOPText -wrap word -width 40 -height 5] \
	-expand yes -fill both
    ScrolledWindow::setwidget $notesTOPLF_sw $notesTOPText
    set allTrainsHeaderLE $frame.allTrainsHeaderLE
    pack [LabelEntry::create $allTrainsHeaderLE \
			     -side left -label "All Trains Header:" \
			     -labelwidth 30] -fill x
    set allTrainsSectionTOPLF $frame.allTrainsSectionTOPLF
    pack [LabelFrame::create $allTrainsSectionTOPLF \
			-side top \
			-text "LaTeX code before the All Trains Section:"] \
	-fill both
   set allTrainsSectionTOPLF_frame [LabelFrame::getframe $allTrainsSectionTOPLF]
   set allTrainsSectionTOPLF_sw $allTrainsSectionTOPLF_frame.sw
   pack [ScrolledWindow::create $allTrainsSectionTOPLF_sw -auto both -scrollbar both] \
	-expand yes -fill both
   set allTrainsSectionTOPText $allTrainsSectionTOPLF_sw.text
   pack [text $allTrainsSectionTOPText -wrap word -width 40 -height 5] \
	-expand yes -fill both
   ScrolledWindow::setwidget $allTrainsSectionTOPLF_sw $allTrainsSectionTOPText
  }
  typemethod _SetGroupsState {} {
    set multiTablesP [$useMultipleTablesP get]
    if {$multiTablesP} {
      NoteBook::itemconfigure $configurationnotebook groups -state normal
    } else {
      NoteBook::itemconfigure $configurationnotebook groups -state disabled
    }
  }
  typemethod _RaiseMulti {} {
    set ntrains [TimeTable NumberOfTrains]
    set stationColW $_LocalPrintConfiguration(StationColWidth)
    set timeColW    $_LocalPrintConfiguration(TimeColWidth)
    set maxtrains [expr int((7 - $stationColW - $timeColW)/double($timeColW))]
    if {$ntrains > $maxtrains} {
      if {[catch {set _LocalPrintConfiguration(UseMultipleTables)}]} {
        set _LocalPrintConfiguration(UseMultipleTables) true
      }
      if {[catch {set _LocalPrintConfiguration(TOCP)}]} {
        set _LocalPrintConfiguration(TOCP) true
      }
    } else {
      if {[catch {set _LocalPrintConfiguration(UseMultipleTables)}]} {
        set _LocalPrintConfiguration(UseMultipleTables) false
      }
      if {[catch {set _LocalPrintConfiguration(TOCP)}]} {
        set _LocalPrintConfiguration(TOCP) $_LocalPrintConfiguration(UseMultipleTables)
      }
    }
#    puts stderr "*** $type _RaiseMulti: _LocalPrintConfiguration(UseMultipleTables) = $_LocalPrintConfiguration(UseMultipleTables)"
    if {$_LocalPrintConfiguration(UseMultipleTables)} {
      $useMultipleTablesP setvalue @[lsearch -exact [$useMultipleTablesP cget -values] yes]
    } else {
      $useMultipleTablesP setvalue @[lsearch -exact [$useMultipleTablesP cget -values] no]
    }
#    puts stderr "*** $type _RaiseMulti: _LocalPrintConfiguration(TOCP) = $_LocalPrintConfiguration(TOCP)"
    if {$_LocalPrintConfiguration(TOCP)} {
      $tocP setvalue @[lsearch -exact [$tocP cget -values] yes]
    } else {
      $tocP setvalue @[lsearch -exact [$tocP cget -values] no]
    }
#    puts stderr "*** $type _RaiseMulti: $useMultipleTablesP getvalue = [$useMultipleTablesP getvalue], $useMultipleTablesP get = [$useMultipleTablesP get]"
    if {[catch {set _LocalPrintConfiguration(BeforeTOC)}]} {
      set _LocalPrintConfiguration(BeforeTOC) {%
% Insert Pre TOC material here.  Cover graphic, logo, etc.
%}
    }
    $beforeTOCText delete 1.0 end
    $beforeTOCText insert end "$_LocalPrintConfiguration(BeforeTOC)"
    if {[catch {set _LocalPrintConfiguration(NotesTOP)}]} {
      set _LocalPrintConfiguration(NotesTOP) {%
% Insert notes prefix info here.
%}
    }
    $notesTOPText delete 1.0 end
    $notesTOPText insert end "$_LocalPrintConfiguration(NotesTOP)"
    if {[catch {set _LocalPrintConfiguration(AllTrainsHeader)}]} {
      set _LocalPrintConfiguration(AllTrainsHeader) "All Trains"
    }
    $allTrainsHeaderLE configure \
			-text "$_LocalPrintConfiguration(AllTrainsHeader)"
    if {[catch {set _LocalPrintConfiguration(AllTrainsSectionTOP)}]} {
      set _LocalPrintConfiguration(AllTrainsSectionTOP) ""
    }
    $allTrainsSectionTOPText delete 1.0 end
    $allTrainsSectionTOPText insert end "$_LocalPrintConfiguration(AllTrainsSectionTOP)"
  }
  typemethod _LeaveMulti {} {
#    puts stderr "*** $type _LeaveMulti: $useMultipleTablesP getvalue = [$useMultipleTablesP getvalue], $useMultipleTablesP get = [$useMultipleTablesP get]"
    set ntrains [TimeTable NumberOfTrains]
    set stationColW $_LocalPrintConfiguration(StationColWidth)
    set timeColW    $_LocalPrintConfiguration(TimeColWidth)
    set maxtrains [expr int((7 - $stationColW - $timeColW)/double($timeColW))]
    if {[$useMultipleTablesP getvalue]} {
      set _LocalPrintConfiguration(UseMultipleTables) true
    } elseif {$ntrains > $maxtrains} {
      TtWarningMessage draw -message "You have too many trains to fit in a single table!"
      return 0
    } else {
      set _LocalPrintConfiguration(UseMultipleTables) false
    }
#    puts stderr "*** $type _LeaveMulti: _LocalPrintConfiguration(UseMultipleTables) = $_LocalPrintConfiguration(UseMultipleTables)"
#    puts stderr "*** $type _LeaveMulti: $tocP getvalue = [$tocP getvalue], $tocP get = [$tocP get]"
    if {[$tocP getvalue]} {
      set _LocalPrintConfiguration(TOCP) true
    } else {
      set _LocalPrintConfiguration(TOCP) false
    }
#    puts stderr "*** $type _LeaveMulti: _LocalPrintConfiguration(TOCP) = $_LocalPrintConfiguration(TOCP)"
    set _LocalPrintConfiguration(BeforeTOC) "[$beforeTOCText get 1.0 end-1c]"
    set _LocalPrintConfiguration(NotesTOP)  "[$notesTOPText  get 1.0 end-1c]"
    set _LocalPrintConfiguration(AllTrainsHeader) \
	"[$allTrainsHeaderLE cget -text]"
    set _LocalPrintConfiguration(AllTrainsSectionTOP) \
	"[$allTrainsSectionTOPText get 1.0 end-1c]"
    return 1
  }
  typecomponent groupsFrame
  typecomponent groupByLCB
  typecomponent addgroupButton
  typecomponent groupItemsSW
  typecomponent groupItemsSF
  typevariable  _GroupClassHeaders    -array {}
  typevariable  _GroupSectionTOPLFs   -array {}
  typevariable  _GroupSectionTOPTexts -array {}
  typevariable  _GroupTrainsLFs       -array {}
  typevariable  _GroupTrainsLBs       -array {}
  typevariable  _GroupAddTrainButtons -array {}
  typemethod _BuildGroups {frame} {
    set groupsFrame    $frame
    set groupByLCB     $frame.groupByLCB
    set addgroupButton $frame.addgroupButton
    set groupItemsSW   $frame.groupItemsSW
    set groupItemsSF   $groupItemsSW.groupItemsSW
    pack [LabelComboBox::create $groupByLCB -side left -labelwidth 30 \
				-label "Group by:" -values {Class Manually} \
				-editable no \
				-modifycmd [mytypemethod _GroupByUpdated]] \
	-fill x
    $groupByLCB setvalue first
    pack [Button::create $addgroupButton -text "Add group" \
					 -command [mytypemethod _AddGroup]] \
	-fill x
    pack [ScrolledWindow::create $groupItemsSW -auto both -scrollbar both] \
	-expand yes -fill both
    pack [ScrollableFrame::create $groupItemsSF] -expand yes -fill both
    ScrolledWindow::setwidget $groupItemsSW $groupItemsSF
  }
  typemethod _RaiseGroups {} {
    if {[catch {set _LocalPrintConfiguration(GroupBy)}]} {
      set _LocalPrintConfiguration(GroupBy) "Class"
    }
    $groupByLCB setvalue @[lsearch -exact [$groupByLCB cget -values] \
				"$_LocalPrintConfiguration(GroupBy)"]
    set lastclass 0
    foreach groupsClassHeadersOpt \
		[array names _LocalPrintConfiguration Group,*,ClassHeader] {
      if {[regexp {Group,([0-9]*),ClassHeader} "$groupsClassHeadersOpt" -> class] < 1} {continue}
      while {[catch {set _GroupClassHeaders($class)}]} {
        $type _AddGroup
      }
      $_GroupClassHeaders($class) \
	   configure -text "$_LocalPrintConfiguration(Group,$class,ClassHeader)"
      $_GroupSectionTOPTexts($class) delete 1.0 end
      if {[catch "set _LocalPrintConfiguration(Group,$class,SectionTOP)"]} {
        set _LocalPrintConfiguration(Group,$class,SectionTOP) ""
      }
      $_GroupSectionTOPTexts($class) insert end \
	   "$_LocalPrintConfiguration(Group,$class,SectionTOP)"
      if {[catch "set _LocalPrintConfiguration(Group,$class,Trains)"]} {
        set _LocalPrintConfiguration(Group,$class,Trains) ""
      }
      set trainList [TT_StringListToList \
			"$_LocalPrintConfiguration(Group,$class,Trains)"]
      $_GroupTrainsLBs($class) delete [$_GroupTrainsLBs($class) items]
      foreach train $trainList {
	$_GroupTrainsLBs($class) insert end "$train" -text "$train"
      }
      if {$class > $lastclass} {set lastclass $class}
    }
    set last [lindex [lsort -integer [array names _GroupClassHeaders]] end]
    if {$last > $lastclass} {
      set frame [ScrollableFrame::getframe $groupItemsSF]
      for {set ll $last} {$ll > $lastclass} {incr ll -1} {
        catch "destroy $frame.group$ll"
	catch "unset _GroupClassHeaders($ll)"
	catch "unset _GroupSectionTOPTexts($ll)"
	catch "unset _GroupTrainsLBs($ll)"
      }
    }
  }
  typemethod _LeaveGroups {} {
    set _LocalPrintConfiguration(GroupBy) "[$groupByLCB cget -text]"
    foreach class [array names _GroupClassHeaders] {
      set _LocalPrintConfiguration(Group,$class,ClassHeader) \
	"[$_GroupClassHeaders($class) cget -text]"
      set _LocalPrintConfiguration(Group,$class,SectionTOP) \
	"[$_GroupSectionTOPTexts($class) get 1.0 end-1c]"
      set _LocalPrintConfiguration(Group,$class,Trains) \
	"[TT_ListToStringListString [$_GroupTrainsLBs($class) items]]"
    }
    return 1
  }
  typemethod _AddGroup {} {
    set last [lindex [lsort -integer [array names _GroupClassHeaders]] end]
    if {[string equal "$last" {}]} {set last 0}
    incr last
    set frame [ScrollableFrame::getframe $groupItemsSF]
    set grframe $frame.group$last
    pack [LabelFrame $grframe -text [format "Class %d:" $last] \
			      -side left -borderwidth 4 -relief ridge] \
	-expand yes -fill both
    update idle
#    puts stderr "*** $type _AddGroup: built the base frame for class $last"
    set f1 [LabelFrame::getframe $grframe]
    set _GroupClassHeaders($last) $f1.classHeader
    pack [LabelEntry $_GroupClassHeaders($last) \
			-label "Class Header:" -side left \
			-labelwidth 30] -fill x
#    puts stderr "*** $type _AddGroup: built the header LE for class $last"
    set _GroupSectionTOPLFs($last)  $f1.sectionTOPLF
    pack [LabelFrame $_GroupSectionTOPLFs($last) \
			-text "Class section LaTeX code:" \
			-side top] -expand yes -fill both
    set _GroupSectionTOPLFs_frame [LabelFrame::getframe $_GroupSectionTOPLFs($last)]
    set _GroupSectionTOPLFs_sw    $_GroupSectionTOPLFs_frame.sw
    pack [ScrolledWindow::create $_GroupSectionTOPLFs_sw -auto both -scrollbar both] \
	-expand yes -fill both
    set _GroupSectionTOPTexts($last) $_GroupSectionTOPLFs_sw.text
    pack [text $_GroupSectionTOPTexts($last) -wrap word -height 5] \
	-expand yes -fill both
    ScrolledWindow::setwidget $_GroupSectionTOPLFs_sw \
			      $_GroupSectionTOPTexts($last)
#    puts stderr "*** $type _AddGroup: built the SectionTOP for class $last"
    set _GroupTrainsLFs($last)       $f1.trains
    pack [LabelFrame::create $_GroupTrainsLFs($last) \
			-text "Class trains:" \
			-side top] -expand yes -fill both
#    puts stderr "*** $type _AddGroup: built (_GroupTrainsLFs($last)) $_GroupTrainsLFs($last)"
    set _GroupTrainsLFs_frame [LabelFrame::getframe $_GroupTrainsLFs($last)]
    set _GroupTrainsLFs_sw    $_GroupTrainsLFs_frame.sw
    pack [ScrolledWindow::create $_GroupTrainsLFs_sw -auto both -scrollbar both] \
	-expand yes -fill both
#    puts stderr "*** $type _AddGroup: built (_GroupTrainsLFs_sw) $_GroupTrainsLFs_sw"
    set _GroupTrainsLBs($last) [ScrolledWindow::getframe $_GroupTrainsLFs_sw].lb
    pack [ListBox::create $_GroupTrainsLBs($last) -height 5] \
	-expand yes -fill both
#    puts stderr "*** $type _AddGroup: built (_GroupTrainsLBs($last) $_GroupTrainsLBs($last)"
    ScrolledWindow::setwidget $_GroupTrainsLFs_sw $_GroupTrainsLBs($last)
#    puts stderr "*** $type _AddGroup: built the TrainsLF for class $last"
    set _GroupAddTrainButtons($last) $f1.addTrain
    pack [Button::create $_GroupAddTrainButtons($last) \
		-text "Add Train To Group" \
		-command "[mytypemethod _AddTrainToGroup] $last"] -fill x
#    puts stderr "*** $type _AddGroup: built the add train button for class $last"
    if {[string equal [$groupByLCB get] "Class"]} {
      $_GroupTrainsLFs($last) configure -state disabled
      $_GroupAddTrainButtons($last) configure -state disabled
    }
#    puts stderr "*** $type _AddGroup: $f1 completely built."
  }
  typemethod _AddTrainToGroup {class} {
    set number [SelectOneTrainDialog draw -title "Train to add to class $class"]
    if {[string equal "$number" ""]} {return}
    $_GroupTrainsLBs($class) insert end "$number" -text "$number"
 }
  typemethod _GroupByUpdated {} {
    switch -exact [$groupByLCB get] {
      Class {
	foreach tr [array names _GroupTrainsLFs] {
	  $_GroupTrainsLFs($tr) configure -state disabled
	  $_GroupAddTrainButtons($tr) configure -state disabled
	}
      }
      Manually {
	foreach tr [array names _GroupTrainsLFs] {
	  $_GroupTrainsLFs($tr) configure -state normal
	  $_GroupAddTrainButtons($tr) configure -state normal
	}
      }
    }
  }
  typemethod draw {args} {
    $type createDialog
    catch {array unset _LocalPrintConfiguration}
    ForEveryPrintOption [TimeTable cget -this] option {
#      puts stderr "*** $type draw: ForEveryPrintOption: option = $option"
      set _LocalPrintConfiguration($option) "[TimeTable GetPrintOption $option]"
#      puts stderr "*** $type draw: _LocalPrintConfiguration($option) = '$_LocalPrintConfiguration($option)'"
    }
    NoteBook::raise $configurationnotebook general
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [Dialog::draw $dialog]
  }
  typemethod _OK {} {
    if {![$type _Apply]} {return}
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog ok]
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog
    return [Dialog::enddialog $dialog cancel]
  }
  typemethod _Apply {} {
    switch -exact "[NoteBook::raise $configurationnotebook]" {
      general {if {![$type _LeaveGeneral]} {return 0}}
      multi   {if {![$type _LeaveMulti]} {return 0}}
      groups  {if {![$type _LeaveGroups]} {return 0}}
    }
    foreach option [array names _LocalPrintConfiguration] {
#      puts stderr "*** $type _Apply: option = $option"
      TimeTable SetPrintOption "$option" "$_LocalPrintConfiguration($option)"
    }
    return 1
  }
}

proc TimeTable::PrintConfiguration {} {
  printConfigurationDialog draw
}

snit::type TimeTable::printDialog {
  pragma -hastypedestroy no
  pragma -hasinstances no
  pragma -hastypeinfo no

  typecomponent dialog
  typecomponent headerlabel
  typecomponent printfile
  typecomponent printprogram
  typecomponent run3timesPLF
  typecomponent run3timesPLF_RByes
  typecomponent run3timesPLF_RBno
  typevariable  _Run3TimesFlag
  typecomponent postprocesscommandLE
  typecomponent postprocesscommandPLF
  typecomponent postprocesscommandPLF_RByes
  typecomponent postprocesscommandPLF_RBno
  typevariable  _PostProcessCommandFlag
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog::create .printDialog -image $TimeTable::LargePrinterImage \
			-default 0 -cancel 2 -modal local -transient yes \
			-parent . -side bottom -title {Print Timetable}]
    $dialog add -name print -text Print -command [mytypemethod _Print]
    $dialog add -name config -text Configure -command [mytypemethod _Configure]
    $dialog add -name cancel -text Cancel -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add -name help -text Help -command [list HTMLHelp::HTMLHelp help {Print Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    frame $headerframe -relief ridge -bd 5
    pack  $headerframe -fill x
    Label::create $iconimage -image banner
    pack  $iconimage -side left
    Label::create $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text {Print Timetable}
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set printfile $frame.printfile
    pack [FileEntry::create $printfile \
			-label "LaTeX file name:" \
			-labelwidth 40 -side left \
			-defaultextension .tex \
			-filetypes { { {LaTeX files} {.tex .ltx} TEXT } } \
			-filedialog save \
			-title {LaTeX file name}] -fill x
    set printprogram $frame.printprogram
    global tcl_platform
    if {[string equal "$tcl_platform(platform)" "windows"]} {
      set exeext ".exe"
    } else {
      set exeext ""
    }
    pack [FileEntry::create $printprogram \
			-label "LaTeX processing program:" \
			-labelwidth 40 -side left \
			-defaultextension "$exeext" \
			-filedialog open \
			-title {LaTeX processing program}] -fill x
    set run3timesPLF $frame.run3timesPLF
    pack [LabelFrame::create $run3timesPLF \
			-text "Run three times? (for TOC)" \
			-width 40 -side left] -fill x
    set run3timesPLF_frame [LabelFrame::getframe $run3timesPLF]
    set run3timesPLF_RByes $run3timesPLF_frame.yes
    set run3timesPLF_RBno  $run3timesPLF_frame.no
    pack [radiobutton $run3timesPLF_RByes -text "Yes" \
					  -variable [mytypevar _Run3TimesFlag] \
					  -value yes] -side left -fill x
    pack [radiobutton $run3timesPLF_RBno -text "No" \
					  -variable [mytypevar _Run3TimesFlag] \
					  -value no] -side left -fill x
    set _Run3TimesFlag yes
    set postprocesscommandLE $frame.postprocesscommandLE
    pack [LabelEntry::create $postprocesscommandLE \
			-label "Post Process Command:" -labelwidth 40 \
			-side left] -fill x

    set postprocesscommandPLF $frame.postprocesscommandPLF
    pack [LabelFrame::create $postprocesscommandPLF \
			-text "Run post processing commands?" \
			-width 40 -side left] -fill x
    set postprocesscommandPLF_frame [LabelFrame::getframe $postprocesscommandPLF]
    set postprocesscommandPLF_RByes $postprocesscommandPLF_frame.yes
    set postprocesscommandPLF_RBno  $postprocesscommandPLF_frame.no
    pack [radiobutton $postprocesscommandPLF_RByes \
			-text "Yes" \
			-variable [mytypevar _PostProcessCommandFlag] \
			-value yes] -side left -fill x
    pack [radiobutton $postprocesscommandPLF_RBno \
			-text "No" \
			-variable [mytypevar _PostProcessCommandFlag] \
			-value no] -side left -fill x
    set _PostProcessCommandFlag no

  }
  typemethod draw {args} {
    $type createDialog
    set currentfile "[TimeTable Filename]"
    $printfile configure -text "[file rootname [file tail $currentfile]].tex"
    $printprogram configure -text "[TimeTable::TimeTableConfiguration getoption pdflatex]"
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [Dialog::draw $dialog]    
  }
  typemethod _Cancel {} {
    Dialog::withdraw $dialog]
    return [Dialog::enddialog $dialog cancel]
  }
  typemethod _Configure {} {
    TimeTable::PrintConfiguration
  }
  typemethod _Print {} {
    Dialog::withdraw $dialog]
    set latexfile "[$printfile cget -text]"
    TimeTable CreateLaTeXTimetable "$latexfile"
    TimeTable::TtInfoMessage draw -message "$latexfile Generated."
    set latexcmd "[$printprogram cget -text] [file rootname $latexfile]"
    if {$_Run3TimesFlag} {
      TimeTable::RunSubprocess "$latexcmd"
      TimeTable::RunSubprocess "$latexcmd"
      TimeTable::RunSubprocess "$latexcmd"
    } else {
      TimeTable::RunSubprocess "$latexcmd"
    }
    TimeTable::TtInfoMessage draw -message "Ran: $latexcmd"
    if {$_PostProcessCommandFlag} {
      TimeTable::RunSubprocess "[$postprocesscommandLE cget -text]"
      TimeTable::TtInfoMessage draw -message "Ran: [$postprocesscommandLE cget -text]"
    }
    return [Dialog::enddialog $dialog print]
  }
}

snit::widget TimeTable::subprocess {
  TimeTable::TtStdShell Subprocess

  component logwindowSW
  component logwindowText

  option -title -default {} -configuremethod _SetTitle
  option -command

  method settopframeoption {frame option value} {
    catch [list $logwindowSW configure $option "$value"]
    catch [list $logwindowText configure $option "$value"]
  }
  method constructtopframe {frame args} {
    set logwindowSW $frame.logwindowSW
    pack [ScrolledWindow::create $logwindowSW -auto both -scrollbar both]\
		-expand yes -fill both
    set logwindowText $logwindowSW.text
    pack [text $logwindowText -wrap word] -expand yes -fill both
    ScrolledWindow::setwidget $logwindowSW $logwindowText
  }

  variable _Pipe
  variable _Running

  method isRunning {} {return $_Running}

  method initializetopframe {frame args} {
    set _Running 0
    $logwindowText delete 1.0 end
    $self configurelist $args
    if {[string length "$options(-command)"] == 0} {
      $self writeText "No command was supplied!\n"
      return
    }
    if {[string length "$options(-title)"] == 0} {
      $self configure -title "Running $options(-command)"
    }
    $dismisbutton configure -state disabled
    if {[catch [list open "|$options(-command)" r] _Pipe]} {
      $self writeText "Error starting process ($options(-command): $_Pipe"
      unset _Pipe
      $dismisbutton configure -state normal
    } else {
      incr _Running
      fileevent $_Pipe readable [mymethod _ReadPipe]
    }
  }

  method _ReadPipe {} {
    if {[gets $_Pipe line] < 0} {
      catch [list close $_Pipe] errorText
      $self processDone "$errorText"
    } else {
      $self writeText "$line"
    }
  }

  method writeText {text} {
    $logwindowText insert end "$text\n"
    $logwindowText see end
  }

  method processDone {errorText} {
    if {![string equal "$errorText" {}]} {$self writeText "$errorText"}
    $dismisbutton configure -state normal
    incr _Running -1
  }
  method wait {} {
    if {$_Running} {tkwait variable [myvar _Running]}
  }
}  

proc TimeTable::RunSubprocess {command} {
  set window [subprocess draw -command "$command"]
  $window wait
}

proc TimeTable::PrintTimeTable {} {
  printDialog draw
}

catch {
$TimeTable::Main menu entryconfigure file Print... -command TimeTable::PrintTimeTable -state disabled
image create photo PrintButtonImage -file [file join $TimeTable::CommonImageDir print.gif]
$TimeTable::Main toolbar addbutton tools print -image PrintButtonImage \
				      -command TimeTable::PrintTimeTable \
				      -helptext "Print Timetable" -state disabled
}

proc TimeTable::EnablePrintCommands {} {
  variable Main
  $Main menu entryconfigure file Print... -state normal
  $Main toolbar buttonconfigure tools print -state normal
}

package provide TTPrint 1.0


