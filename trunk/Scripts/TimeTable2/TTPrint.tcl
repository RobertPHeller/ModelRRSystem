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

## @defgroup TimeTableLaTeXOpts TimeTableLaTeXOpts
# @brief Time Table program (v2), LaTeX options
#
# @section DESCRIPTION
# 
# There are a number of LaTeX formatting configuration options stored in the
# time table datafile.  They are:
#
# - General options:
#   -# Title The title of the time table.  Default: ``My Model Railroad 
#	Timetable''.
#   -# SubTitle The sub-title of the time table.  Default: ``Employee 
#	Timetable Number 1''.
#   -# Date The date of the time table. Default: ``\\today'' (the current 
#	date when PDFLaTeX is run).
#   -# TimeFormat The time format to use, 24 (24 hour) or 12 (12 hour). 
#	Default: 24.
#   -# AMPMFormat AM and PM indication when in 12 hour time format. One of
#	a (little a or p), AP (large AM or PM), or lB (light font for AM,
#	bold font for PM). Default: a.
#   -# NSides Number of sides, either single or double. Default: single.
#   -# DirectionName The name of the default direction of travel. One of 
#	Northbound, Eastbound, Southbound, or Westbound. Default: Northbound.
#   -# StationColWidth The width (in inches) of the station name column. 
#	Default: 1.5.
#   -# TimeColWidth The width (in inches) of the time column. Default: 0.5.
#   -# ExtraPreamble Extra preamble code.  Used to include additional packages
#	or set additional LaTeX parameters.  Default: empty.
#
# - Multiple table options:
#   -# UseMultipleTables Boolean flag to enable the use of multiple tables.
#	Default depends on how wide a single would be. If the number of trains
#	exceeds (7 - StationColWidth - TimeColWidth) / TimeColWidth trains,
#	then this flag is defaults to true, otherwise it defaults to false.
#   -# TOCP Boolean flag to enable a table of contents.  Default true if
#	UseMultipleTables defaults to true.
#   -# BeforeTOC LaTeX code or text to include before the table of contents.
#	Default: empty.
#   -# NotesTOP LaTeX code or text to include before the notes. Default: empty.
#   -# AllTrainsHeader All trains header.  Default: ``All Trains''.
#   -# AllTrainsSectionTOP LaTeX code before the All Trains Section. 
#	Default: empty.
#
# - Group options. There is a set of options for each group, indicated
#	 by the group's index:
#   -# GroupBy Grouping method, either Class or Manually. Default: Class.
#   -# Group,index,ClassHeader Group class header for group number index.
#	Default: empty.
#   -# Group,index,SectionTOP Class section LaTeX code. Default: empty.
#   -# Group,index,Trains List of trains in this group.
# 
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#


namespace eval TimeTable {}

catch {TimeTable::SplashWorkMessage [_ "Loading Print Code"] 88}

package require gettext
package require Tk
package require tile
package require snit
package require Dialog
package require LabelFrames
package require ScrollWindow
package require ScrollableFrame
package require ListBox
package require ROText

namespace eval TimeTable {

  variable LargePrinterImage {}
  catch {
    variable ImageDir
    set LargePrinterImage [image create photo \
				-file [file join $ImageDir largePrinter.gif]]
  }
}

snit::widgetadaptor NoteBook {
    variable leavecmd -array {}
    variable raisecmd -array {}
    delegate option * to hull
    delegate method * to hull except {add insert}
    constructor {args} {
        installhull using ttk::notebook -class NoteBook
        $self configurelist $args
    }
    typeconstructor {
        bind NoteBook <ButtonPress-1> [mytypemethod _Press %W %x %y]
        bind NoteBook <Key-Right> "[mytypemethod _CycleTab %W  1]; break"
        bind NoteBook <Key-Left>  "[mytypemethod _CycleTab %W -1]; break"
        bind NoteBook <Control-Key-Tab> "[mytypemethod _CycleTab %W  1]; break"
        bind NoteBook <Control-Shift-Key-Tab> "[mytypemethod _CycleTab %W -1]; break"
        catch {
            bind NoteBook <Control-ISO_Left_Tab> "[mytypemethod _CycleTab %W -1]; break"
        }
        ttk::style configure NoteBook.Tab \
              -padding [ttk::style lookup TNotebook.Tab -padding] \
              -background [ttk::style lookup TNotebook.Tab -background]
        ttk::style layout NoteBook [ttk::style layout TNotebook]
        ttk::style layout NoteBook.Tab [ttk::style layout TNotebook.Tab]
    }
    typemethod _Press {w x y} {
        $w _Press_ $x $y
    }
    typemethod _CycleTab {w dir} {
        $w _CycleTab_ $dir
    }
    method _Press_ {x y} {
        set index [$hull index @$x,$y]
        if {$index ne ""} {
            $self _ActivateTab $index
        }
    }
    method _CycleTab_ {dir} {
        if {[$hull index end] != 0} {
            set current [$hull index current]
            set select [expr {($current + $dir) % [$hull index end]}]
            while {[$hull tab $select -state] != "normal" && ($select != $current)} {
                set select [expr {($select + $dir) % [$hull index end]}]
            }
            if {$select != $current} {
                $self _ActivateTab $select
            }
        }
    }
    method _ActivateTab {tab} {
        if {[$hull index $tab] eq [$hull index current]} {
            if {[info exists raisecmd([$hull index current])]} {
                uplevel #0 $raisecmd([$hull index current])
            }
            focus $win
        } else {
            set canleave yes
            #puts stderr "*** $self _ActivateTab: leavecmd([$hull index current]) = $leavecmd([$hull index current])"
            if {[info exists leavecmd([$hull index current])] &&
                $leavecmd([$hull index current]) ne ""} {
                set canleave [uplevel #0 $leavecmd([$hull index current])]
            }
            #puts stderr "*** $self _ActivateTab: canleave = $canleave"
            if {!$canleave} {return}
            $hull select $tab
            #puts stderr "*** $self _ActivateTab: raisecmd([$hull index current]) = $raisecmd([$hull index current])"
            if {[info exists raisecmd([$hull index current])]} {
                uplevel #0 $raisecmd([$hull index current])
            }
            update ;# needed so focus logic sees correct mapped/unmapped states
            if {[set f [ttk::focusFirst [$hull select]]] ne ""} {
                tk::TabToWindow $f
            }
        }
    }
    method add {window args} {
        set _raisecmd [from args -raisecmd]
        set _leavecmd [from args -leavecmd]
        eval [list $hull add $window] $args
        set index [$hull index $window]
        set raisecmd($index) $_raisecmd
        set leavecmd($index) $_leavecmd
    }
    method insert {index window args} {
        set _raisecmd [from args -raisecmd]
        set _leavecmd [from args -leavecmd]
        eval [list $hull insert $index $window] $args
        set index [$hull index $window]
        set raisecmd($index) $_raisecmd
        set leavecmd($index) $_leavecmd
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
  
  typevariable general
  typevariable groups
  
  typeconstructor {
    set dialog {}
  }
  typemethod createDialog {} {
    if {![string equal "$dialog" {}] && [winfo exists $dialog]} {return}
    set dialog [Dialog .printConfigurationDialog \
			-image $TimeTable::LargePrinterImage \
			-default 0 -cancel 2 -modal local -transient yes \
			-parent . -side bottom -title [_ "Print Configuration"]]
    $dialog add ok -text [_m "Button|OK"] -command [mytypemethod _OK]
    $dialog add apply -text [_m "Button|Apply"] -command [mytypemethod _Apply]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Print Configuration Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Print Configuration"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set configurationnotebook $frame.configurationnotebook
    NoteBook $frame.configurationnotebook
    pack $configurationnotebook -expand yes -fill both
    set general [ttk::frame $configurationnotebook.general]
    $configurationnotebook insert end $general -text [_m "Tab|General"] \
          -leavecmd [mytypemethod _LeaveGeneral] \
          -raisecmd [mytypemethod _RaiseGeneral]
    $type _BuildGeneral $general
    set multi [ttk::frame $configurationnotebook.multi]
    $configurationnotebook insert end $multi -text [_m "Tab|Multi"] \
          -leavecmd [mytypemethod _LeaveMulti] \
          -raisecmd [mytypemethod _RaiseMulti]
    $type _BuildMulti $multi
    set groups [ttk::frame $configurationnotebook.groups]
    $configurationnotebook insert end $groups -text [_m "Tab|Groups"] \
          -leavecmd [mytypemethod _LeaveGroups] \
          -raisecmd [mytypemethod _RaiseGroups]
    $type _BuildGroups $groups
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
    set lwidth [_mx "Label|Title:" "Label|Sub Title:" "Label|Date:" \
		    "Label|Number of sides:" "Label|Time Format:" \
		    "Label|AM/PM format:" "Label|Forward Direction is generally:" "Label|Station Column Width:" "Label|Time Column Width:"]
    set titleLE $frame.titleLE
    pack [LabelEntry $titleLE \
			     -label [_m "Label|Title:"] \
			     -labelwidth $lwidth] -fill x
    set subtitleLE $frame.subtitleLE
    pack [LabelEntry $subtitleLE \
			     -label [_m "Label|Sub Title:"] \
			     -labelwidth $lwidth] -fill x
    set dateLE $frame.dateLE
    pack [LabelEntry $dateLE \
			     -label [_m "Label|Date:"] \
			     -labelwidth $lwidth] -fill x
    set nSidesLF $frame.nSidesLF
    pack [LabelFrame $nSidesLF -text [_m "Label|Number of sides:"] \
          -width $lwidth] -fill x
    set nSidesLCB [$nSidesLF getframe].nSidesLCB
    pack [spinbox $nSidesLCB -state readonly \
          -values [list [_m "Answer|single"] [_m "Answer|double"]]] \
          -fill x -side left -expand yes
    $nSidesLCB set [_m "Answer|single"]
    set timeformatLF $frame.timeformatLF
    pack [LabelFrame $timeformatLF \
			     -text [_m "Label|Time Format:"] \
			     -width $lwidth] -fill x
    set timeformatLF_frame [$timeformatLF getframe]
    pack [ttk::radiobutton $timeformatLF_frame.rb24 \
			-text [_m "Label|24 Hour"] -value 24 \
			-command [mytypemethod _Disable_AMPMFormat] \
			-variable [mytypevar _TimeFormat] \
			] -side left -expand yes -fill x
    pack [ttk::radiobutton $timeformatLF_frame.rb12 \
			-text [_m "Label|12 Hour"] -value 12 \
			-command [mytypemethod _Enable_AMPMFormat] \
			-variable [mytypevar _TimeFormat] \
			] -side left -expand yes -fill x
    set _TimeFormat 24
    set ampmLF $frame.ampmLF
    pack [LabelFrame $ampmLF \
			     -text [_m "Label|AM/PM format:"] \
			     -width $lwidth] -fill x
    set ampmLF_frame [$ampmLF getframe]
    pack [ttk::radiobutton $ampmLF_frame.rb_ap \
    			-text [_m "Label|Small a or p"] -value a \
			-variable [mytypevar _AMPMFormat] \
			-state disabled] -fill x
    lappend ampmLF_RBS $ampmLF_frame.rb_ap
    pack [ttk::radiobutton $ampmLF_frame.rb_AP \
    			-text [_m "Label|Large AM or PM"] -value AP \
			-variable [mytypevar _AMPMFormat] \
			-state disabled] -fill x
    lappend ampmLF_RBS $ampmLF_frame.rb_AP
    pack [ttk::radiobutton $ampmLF_frame.rb_lB \
    			-text [_m "Label|Light font for AM, bold font for PM"] -value lB \
			-variable [mytypevar _AMPMFormat] \
			-state disabled] -fill x
    lappend ampmLF_RBS $ampmLF_frame.rb_lB
    set _AMPMFormat a
    set directionLF $frame.directionLF
    pack [LabelFrame $directionLF \
          -text [_m "Label|Forward Direction is generally:"] \
          -width $lwidth] -fill x
    set directionLCB [$directionLF getframe].directionLCB
    pack [spinbox $directionLCB \
          -values [list [_m "Answer|Northbound"] [_m "Answer|Eastbound"] \
                        [_m "Answer|Southbound"] [_m "Answer|Westbound"]] \
          -state readonly] -fill x -expand yes -side left
    $directionLCB set [_m "Answer|Northbound"]
    set stationcwLF $frame.stationcwLF
    pack [LabelFrame $stationcwLF \
          -text [_m "Label|Station Column Width:"] \
          -width $lwidth] -fill x
    set stationcwLSB [$stationcwLF getframe].stationcwLSB
    pack [spinbox $stationcwLSB \
          -from .125 -to 2.5 -increment .125] -side left -fill x -expand yes
    $stationcwLSB set 1.5
    set timecwLF $frame.timecwLF
    pack [LabelFrame $timecwLF \
          -text [_m "Label|Time Column Width:"] \
          -width $lwidth] -fill x
    set timecwLSB [$timecwLF getframe].timecwLSB
    pack [spinbox $timecwLSB \
          -from .125 -to 2.5 -increment .125] -side left  -fill x -expand yes
    $timecwLSB set .5
    set extraPreambleLF $frame.extraPreambleLF
    pack [ttk::labelframe $extraPreambleLF \
		-labelanchor n -text [_ "Additional LaTeX preamble code:"]] -fill both
    set extraPreambleLF_frame $extraPreambleLF
    set extraPreambleLF_sw $extraPreambleLF_frame.sw
    pack [ScrolledWindow $extraPreambleLF_sw -auto both \
						     -scrollbar both] \
	-expand yes -fill both
    set extraPreambleText $extraPreambleLF_sw.text
    text $extraPreambleText -wrap word -width 40 -height 5
    $extraPreambleLF_sw setwidget $extraPreambleText
  }
  typemethod _LeaveGeneral {} {
    set _LocalPrintConfiguration(Title) "[$titleLE cget -text]"
    set _LocalPrintConfiguration(SubTitle) "[$subtitleLE cget -text]"
    set _LocalPrintConfiguration(Date) "[$dateLE cget -text]"
    set _LocalPrintConfiguration(TimeFormat) "$_TimeFormat"
    set _LocalPrintConfiguration(AMPMFormat) "$_AMPMFormat"
    set dn "[$directionLCB get]"
    if {$dn eq [_m "Answer|Northbound"]} {
        set _LocalPrintConfiguration(DirectionName) Northbound
    } elseif {$dn eq [_m "Answer|Eastbound"]} {
        set _LocalPrintConfiguration(DirectionName) Eastbound
    } elseif {$dn eq [_m "Answer|Southbound"]} {
        set _LocalPrintConfiguration(DirectionName) Southbound
    } elseif {$dn eq [_m "Answer|Westbound"]} {
        set _LocalPrintConfiguration(DirectionName) Westbound
    }
    set _LocalPrintConfiguration(StationColWidth) [$stationcwLSB cget -text]
    if {![string is double -strict $_LocalPrintConfiguration(StationColWidth)]} {
        set _LocalPrintConfiguration(StationColWidth) 1.5
    }
    set _LocalPrintConfiguration(TimeColWidth) [$timecwLSB cget -text]
    if {![string is double -strict $_LocalPrintConfiguration(TimeColWidth)]} {
        set _LocalPrintConfiguration(TimeColWidth) .5
    }
    if {[$nSidesLCB get] eq [_m "Answer|single"]} {
        set _LocalPrintConfiguration(NSides) single
    }
    set _LocalPrintConfiguration(ExtraPreamble) "[$extraPreambleText get 1.0 end-1c]"
    return 1
  }
  typemethod _RaiseGeneral {} {
    if {[catch {set _LocalPrintConfiguration(Title)}]} {
      set _LocalPrintConfiguration(Title) [_ "My Model Railroad Timetable"]
    }
    $titleLE configure -text "$_LocalPrintConfiguration(Title)"
    if {[catch {set _LocalPrintConfiguration(SubTitle)}]} {
      set _LocalPrintConfiguration(SubTitle) [_ "Employee Timetable Number 1"]
    }
    $subtitleLE configure -text "$_LocalPrintConfiguration(SubTitle)"
    if {[catch {set _LocalPrintConfiguration(Date)}]} {
      set _LocalPrintConfiguration(Date) "\\today"
    }
    $dateLE configure -text "$_LocalPrintConfiguration(Date)"
    if {[catch {set _LocalPrintConfiguration(TimeFormat)}]} {
      set _LocalPrintConfiguration(TimeFormat) "24"
    }
    if {[lsearch -exact {12 24} $_LocalPrintConfiguration(TimeFormat)] < 0} {
      set _LocalPrintConfiguration(TimeFormat) "24"
    }
    set _TimeFormat "$_LocalPrintConfiguration(TimeFormat)"
    if {[catch {set _LocalPrintConfiguration(AMPMFormat)}]} {
      set _LocalPrintConfiguration(AMPMFormat) "a"
    }
    set _AMPMFormat "$_LocalPrintConfiguration(AMPMFormat)"
    if {[catch {set _LocalPrintConfiguration(NSides)}]} {
      set _LocalPrintConfiguration(NSides) "single"
    }
    if {"$_LocalPrintConfiguration(NSides)" eq "single"} {
        $nSidesLCB set [_m "Answer|single"]
    } else {
        $nSidesLCB set [_m "Answer|double"]
    }
    if {[catch {set _LocalPrintConfiguration(DirectionName)}]} {
      set _LocalPrintConfiguration(DirectionName)  "Northbound"
    }
    switch "$_LocalPrintConfiguration(DirectionName)" {
        Northbound {$directionLCB set [_m "Answer|Northbound"]}
        Eastbound {$directionLCB set [_m "Answer|Eastbound"]}
        Southbound {$directionLCB set [_m "Answer|Southbound"]}
        Westbound {$directionLCB set [_m "Answer|Westbound"]}
    }
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
    set lwidth [_mx "Label|Create Table Of Contents?" \
                "Label|Use multiple tables?" "Label|All Trains Header:"]
    set tocLF $frame.tocLF
    pack [LabelFrame $tocLF \
          -text [_m "Label|Create Table Of Contents?"] \
          -width $lwidth] -fill x
    set tocP [$tocLF getframe].tocP    
    pack [spinbox $tocP \
          -state readonly \
          -values [list [_m "Answer|No"] [_m "Answer|Yes"]]] \
          -fill x -expand yes -side left
    $tocP set [_m "Answer|Yes"]
    set useMultipleTablesLF $frame.useMultipleTablesLF
    pack [LabelFrame $useMultipleTablesLF \
          -text [_m "Label|Use multiple tables?"] \
          -width $lwidth] -fill x
    set useMultipleTablesP [$useMultipleTablesLF getframe].useMultipleTablesP
    pack [spinbox $useMultipleTablesP \
          -command [mytypemethod _SetGroupsState] \
          -state readonly \
          -values [list [_m "Answer|No"] [_m "Answer|Yes"]]] \
	-fill x
    $useMultipleTablesP set [_m "Answer|Yes"]
    set beforeTOCLF $frame.beforeTOCLF
    pack [ttk::labelframe $beforeTOCLF \
			-labelanchor n \
			-text [_ "LaTeX code before the Table of Contents:"]] \
	 -fill both
    set beforeTOCLF_frame $beforeTOCLF
    set beforeTOCLF_sw    $beforeTOCLF_frame.sw
    pack [ScrolledWindow $beforeTOCLF_sw -auto both -scrollbar both] \
	-expand yes -fill both
    set beforeTOCText $beforeTOCLF_sw.text
    text $beforeTOCText -wrap word -width 40 -height 5
    $beforeTOCLF_sw setwidget $beforeTOCText
    set notesTOPLF $frame.notesTOPLF
    pack [ttk::labelframe $notesTOPLF \
			-labelanchor n \
			-text [_ "LaTeX code at the beginning of the notes section:"]] \
	 -fill both
    set notesTOPLF_frame $notesTOPLF
    set notesTOPLF_sw    $notesTOPLF_frame.sw
    pack [ScrolledWindow $notesTOPLF_sw -auto both -scrollbar both] \
	-expand yes -fill both
    set notesTOPText $notesTOPLF_sw.text
    text $notesTOPText -wrap word -width 40 -height 5
    $notesTOPLF_sw setwidget $notesTOPText
    set allTrainsHeaderLE $frame.allTrainsHeaderLE
    pack [LabelEntry $allTrainsHeaderLE \
			     -label [_m "Label|All Trains Header:"] \
			     -labelwidth $lwidth] -fill x
    set allTrainsSectionTOPLF $frame.allTrainsSectionTOPLF
    pack [ttk::labelframe $allTrainsSectionTOPLF \
			-labelanchor n \
			-text [_ "LaTeX code before the All Trains Section:"]] \
	-fill both
   set allTrainsSectionTOPLF_frame $allTrainsSectionTOPLF
   set allTrainsSectionTOPLF_sw $allTrainsSectionTOPLF_frame.sw
   pack [ScrolledWindow $allTrainsSectionTOPLF_sw -auto both -scrollbar both] \
	-expand yes -fill both
   set allTrainsSectionTOPText $allTrainsSectionTOPLF_sw.text
   text $allTrainsSectionTOPText -wrap word -width 40 -height 5
   $allTrainsSectionTOPLF_sw setwidget $allTrainsSectionTOPText
  }
  typemethod _SetGroupsState {} {
    set multiTablesP [$useMultipleTablesP get]
    if {$multiTablesP eq [_m "Answer|Yes"]} {
      $configurationnotebook tab $groups -state normal
    } else {
      $configurationnotebook tab $groups -state disabled
    }
  }
  typemethod _RaiseMulti {} {
    set ntrains [TimeTable NumberOfTrains]
    set stationColW $_LocalPrintConfiguration(StationColWidth)
    if {![string is double -strict $stationColW]} {
        set _LocalPrintConfiguration(StationColWidth) 1.5
        set stationColW $_LocalPrintConfiguration(StationColWidth)
    }
    set timeColW    $_LocalPrintConfiguration(TimeColWidth)
    if {![string is double -strict $timeColW]} {
        set _LocalPrintConfiguration(TimeColWidth) .5
        set timeColW    $_LocalPrintConfiguration(TimeColWidth)
    }
    set maxtrains [expr int((7 - $stationColW - $timeColW)/double($timeColW))]
    if {$ntrains > $maxtrains} {
      if {[catch {set _LocalPrintConfiguration(UseMultipleTables)}]} {
        set _LocalPrintConfiguration(UseMultipleTables) true
      }
      if {![string is boolean -strict $_LocalPrintConfiguration(UseMultipleTables)]} {
          set _LocalPrintConfiguration(UseMultipleTables) true
      }
      if {[catch {set _LocalPrintConfiguration(TOCP)}]} {
        set _LocalPrintConfiguration(TOCP) true
      }
      if {![string is boolean -strict $_LocalPrintConfiguration(TOCP)]} {
        set _LocalPrintConfiguration(TOCP) true
      }
    } else {
      if {[catch {set _LocalPrintConfiguration(UseMultipleTables)}]} {
        set _LocalPrintConfiguration(UseMultipleTables) false
      }
      if {![string is boolean -strict $_LocalPrintConfiguration(UseMultipleTables)]} {
          set _LocalPrintConfiguration(UseMultipleTables) false
      }
      if {[catch {set _LocalPrintConfiguration(TOCP)}]} {
        set _LocalPrintConfiguration(TOCP) $_LocalPrintConfiguration(UseMultipleTables)
      }
      if {![string is boolean -strict $_LocalPrintConfiguration(TOCP)]} {
        set _LocalPrintConfiguration(TOCP) $_LocalPrintConfiguration(UseMultipleTables)
      }
    }
#    puts stderr "*** $type _RaiseMulti: _LocalPrintConfiguration(UseMultipleTables) = $_LocalPrintConfiguration(UseMultipleTables)"
    if {$_LocalPrintConfiguration(UseMultipleTables)} {
      $useMultipleTablesP set [_m "Answer|Yes"]
    } else {
      $useMultipleTablesP set [_m "Answer|No"]
    }
#    puts stderr "*** $type _RaiseMulti: _LocalPrintConfiguration(TOCP) = $_LocalPrintConfiguration(TOCP)"
    if {$_LocalPrintConfiguration(TOCP)} {
      $tocP set [_m "Answer|Yes"]
    } else {
      $tocP set [_m "Answer|No"]
    }
#    puts stderr "*** $type _RaiseMulti: $useMultipleTablesP get = [$useMultipleTablesP getvalue], $useMultipleTablesP get = [$useMultipleTablesP get]"
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
      set _LocalPrintConfiguration(AllTrainsHeader) [_ "All Trains"]
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
#    puts stderr "*** $type _LeaveMulti: $useMultipleTablesP get = [$useMultipleTablesP getvalue], $useMultipleTablesP get = [$useMultipleTablesP get]"
    set ntrains [TimeTable NumberOfTrains]
    set stationColW $_LocalPrintConfiguration(StationColWidth)
    set timeColW    $_LocalPrintConfiguration(TimeColWidth)
    set maxtrains [expr int((7 - $stationColW - $timeColW)/double($timeColW))]
    if {[$useMultipleTablesP get] eq [_m "Answer|Yes"]} {
      set _LocalPrintConfiguration(UseMultipleTables) true
    } elseif {$ntrains > $maxtrains} {
      ::TimeTable::TtWarningMessage draw -message [_ "You have too many trains to fit in a single table!"]
      return 0
    } else {
      set _LocalPrintConfiguration(UseMultipleTables) false
    }
#    puts stderr "*** $type _LeaveMulti: _LocalPrintConfiguration(UseMultipleTables) = $_LocalPrintConfiguration(UseMultipleTables)"
#    puts stderr "*** $type _LeaveMulti: $tocP getvalue = [$tocP getvalue], $tocP get = [$tocP get]"
    if {[$tocP get] eq [_m "Answer|Yes"]} {
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
    set addgroupButton $frame.addgroupButton
    set groupItemsSW   $frame.groupItemsSW
    set groupItemsSF   $groupItemsSW.groupItemsSW
    set lwidth [_mx "Label|Group by:"]
    set groupByLF      $frame.groupByLF
    pack [LabelFrame $groupByLF -width $lwidth \
          -text [_m "Label|Group by:"]] -fill x
    set groupByLCB     [$groupByLF getframe].groupByLCB
    pack [spinbox $groupByLCB \
          -values [list [_m "Answer|Class"] \
                   [_m "Answer|Manually"]] \
          -state readonly \
          -command [mytypemethod _GroupByUpdated]] \
          -fill x -expand yes -side left
    $groupByLCB set [_m "Answer|Class"]
    pack [ttk::button $addgroupButton -text [_m "Button|Add group"] \
					 -command [mytypemethod _AddGroup]] \
	-fill x
    pack [ScrolledWindow $groupItemsSW -auto both -scrollbar both] \
	-expand yes -fill both
    ScrollableFrame $groupItemsSF
    $groupItemsSW setwidget $groupItemsSF
  }
  typemethod _RaiseGroups {} {
    if {[catch {set _LocalPrintConfiguration(GroupBy)}]} {
      set _LocalPrintConfiguration(GroupBy) "Class"
    }
    switch $_LocalPrintConfiguration(GroupBy) {
      Class {$groupByLCB set [_m "Answer|Class"]}
      Manually {$groupByLCB set [_m "Answer|Manually"]}
    }
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
      set frame [$groupItemsSF getframe]
      for {set ll $last} {$ll > $lastclass} {incr ll -1} {
        catch "destroy $frame.group$ll"
	catch "unset _GroupClassHeaders($ll)"
	catch "unset _GroupSectionTOPTexts($ll)"
	catch "unset _GroupTrainsLBs($ll)"
      }
    }
  }
  typemethod _LeaveGroups {} {
    if {"[$groupByLCB get]" eq [_m "Answer|Class"]} {
      set _LocalPrintConfiguration(GroupBy) Class
    } else {
      set _LocalPrintConfiguration(GroupBy) Manually
    }
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
    set frame [$groupItemsSF getframe]
    set grframe $frame.group$last
    pack [LabelFrame $grframe -text [format [_m "Label|Class %d:"] $last] \
			      -borderwidth 4 -relief ridge] \
	-expand yes -fill both
    update idle
#    puts stderr "*** $type _AddGroup: built the base frame for class $last"
    set f1 [$grframe getframe]
    set _GroupClassHeaders($last) $f1.classHeader
    set lwidth [_mx "Label|Class Header:"]
    pack [LabelEntry $_GroupClassHeaders($last) \
			-label [_m "Label|Class Header:"] \
			-labelwidth $lwidth] -fill x
#    puts stderr "*** $type _AddGroup: built the header LE for class $last"
    set _GroupSectionTOPLFs($last)  $f1.sectionTOPLF
    pack [ttk::labelframe $_GroupSectionTOPLFs($last) \
			-text [_ "Class section LaTeX code:"] \
			-labelanchor n] -expand yes -fill both
    set _GroupSectionTOPLFs_frame $_GroupSectionTOPLFs($last)
    set _GroupSectionTOPLFs_sw    $_GroupSectionTOPLFs_frame.sw
    pack [ScrolledWindow $_GroupSectionTOPLFs_sw -auto both -scrollbar both] \
	-expand yes -fill both
    set _GroupSectionTOPTexts($last) $_GroupSectionTOPLFs_sw.text
    text $_GroupSectionTOPTexts($last) -wrap word -height 5
    $_GroupSectionTOPLFs_sw setwidget $_GroupSectionTOPTexts($last)
#    puts stderr "*** $type _AddGroup: built the SectionTOP for class $last"
    set _GroupTrainsLFs($last)       $f1.trains
    pack [ttk::labelframe $_GroupTrainsLFs($last) \
			-text [_ "Label|Class trains:"] \
			-labelanchor n] -expand yes -fill both
#    puts stderr "*** $type _AddGroup: built (_GroupTrainsLFs($last)) $_GroupTrainsLFs($last)"
    set _GroupTrainsLFs_frame $_GroupTrainsLFs($last)
    set _GroupTrainsLFs_sw    $_GroupTrainsLFs_frame.sw
    pack [ScrolledWindow $_GroupTrainsLFs_sw -auto both -scrollbar both] \
	-expand yes -fill both
#    puts stderr "*** $type _AddGroup: built (_GroupTrainsLFs_sw) $_GroupTrainsLFs_sw"
    set _GroupTrainsLBs($last) [$_GroupTrainsLFs_sw getframe].lb
    ListBox $_GroupTrainsLBs($last) -height 5
#    puts stderr "*** $type _AddGroup: built (_GroupTrainsLBs($last) $_GroupTrainsLBs($last)"
    $_GroupTrainsLFs_sw setwidget $_GroupTrainsLBs($last)
#    puts stderr "*** $type _AddGroup: built the TrainsLF for class $last"
    set _GroupAddTrainButtons($last) $f1.addTrain
    pack [ttk::button $_GroupAddTrainButtons($last) \
		-text [_m "Button|Add Train To Group"] \
		-command "[mytypemethod _AddTrainToGroup] $last"] -fill x
#    puts stderr "*** $type _AddGroup: built the add train button for class $last"
    if {[string equal [$groupByLCB get] [_m "Answer|Class"]]} {
      #$_GroupTrainsLFs($last) configure -state disabled
      $_GroupAddTrainButtons($last) configure -state disabled
    }
#    puts stderr "*** $type _AddGroup: $f1 completely built."
  }
  typemethod _AddTrainToGroup {class} {
    set number [SelectOneTrainDialog draw -title [_ "Train to add to class %s" $class]]
    if {[string equal "$number" ""]} {return}
    $_GroupTrainsLBs($class) insert end "$number" -text "$number"
 }
  typemethod _GroupByUpdated {} {
    if {[$groupByLCB get] eq [_m "Answer|Class"]} {
      foreach tr [array names _GroupTrainsLFs] {
	$_GroupTrainsLFs($tr) configure -state disabled
	$_GroupAddTrainButtons($tr) configure -state disabled
      }
    } else {
      foreach tr [array names _GroupTrainsLFs] {
	$_GroupTrainsLFs($tr) configure -state normal
	$_GroupAddTrainButtons($tr) configure -state normal
      }
    }
  }
  typemethod draw {args} {
    $type createDialog
    catch {array unset _LocalPrintConfiguration}
    ForEveryPrintOption [TimeTable cget -this] option {
        #puts stderr "*** $type draw: ForEveryPrintOption: option = $option"
        set _LocalPrintConfiguration($option) "[TimeTable GetPrintOption $option]"
        #puts stderr "*** $type draw: _LocalPrintConfiguration($option) = '$_LocalPrintConfiguration($option)'"
    }
    $type _RaiseGeneral
    $configurationnotebook select $general
    wm transient [winfo toplevel $dialog] [$dialog cget -parent]
    return [$dialog draw]
  }
  typemethod _OK {} {
    if {![$type _Apply]} {return}
    $dialog withdraw
    return [$dialog enddialog ok]
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog cancel]
  }
  typemethod _Apply {} {
    switch -regexp "[$configurationnotebook select]" {
      \.general$ {if {![$type _LeaveGeneral]} {return 0}}
      \.multi$   {if {![$type _LeaveMulti]} {return 0}}
      \.groups$  {if {![$type _LeaveGroups]} {return 0}}
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
    set dialog [Dialog .printDialog -image $TimeTable::LargePrinterImage \
			-default 0 -cancel 2 -modal local -transient yes \
			-parent . -side bottom -title [_ "Print Timetable"]]
    $dialog add print -text [_m "Button|Print"] -command [mytypemethod _Print]
    $dialog add config -text [_m "Button|Configure"] -command [mytypemethod _Configure]
    $dialog add cancel -text [_m "Button|Cancel"] -command [mytypemethod _Cancel]
    wm protocol [winfo toplevel $dialog] WM_DELETE_WINDOW [mytypemethod _Cancel]
    $dialog add help -text [_m "Button|Help"] -command [list HTMLHelp::HTMLHelp help {Print Dialog}]
    set frame [$dialog getframe]
    set headerframe $frame.headerframe
    set iconimage $headerframe.iconimage
    set headerlabel $headerframe.headerlabel
    ttk::frame $headerframe -relief ridge -borderwidth 5
    pack  $headerframe -fill x
    ttk::label $iconimage -image banner
    pack  $iconimage -side left
    ttk::label $headerlabel -anchor w -font {Helvetica -24 bold} \
		-text [_ "Print Timetable"]
    pack  $headerlabel -side right -anchor w -expand yes -fill x
    set lwidth [_mx "Label|LaTeX file name:" "Label|LaTeX processing program:" \
		    "Label|Run three times? (for TOC)" \
		    "Label|Post Process Command:" \
		    "Label|Run post processing commands?"]
    set printfile $frame.printfile
    pack [FileEntry $printfile \
			-label [_m "Label|LaTeX file name:"] \
			-labelwidth $lwidth \
			-defaultextension .tex \
			-filetypes { { {LaTeX files} {.tex .ltx} TEXT } } \
			-filedialog save \
			-title [_ "LaTeX file name"]] -fill x
    set printprogram $frame.printprogram
    global tcl_platform
    if {[string equal "$tcl_platform(platform)" "windows"]} {
      set exeext ".exe"
    } else {
      set exeext ""
    }
    pack [FileEntry $printprogram \
			-label [_m "Label|LaTeX processing program:"] \
			-labelwidth $lwidth \
			-defaultextension "$exeext" \
			-filedialog open \
			-title {LaTeX processing program}] -fill x
    set run3timesPLF $frame.run3timesPLF
    pack [LabelFrame $run3timesPLF \
			-text [_m "Label|Run three times? (for TOC)"] \
			-width $lwidth] -fill x
    set run3timesPLF_frame [$run3timesPLF getframe]
    set run3timesPLF_RByes $run3timesPLF_frame.yes
    set run3timesPLF_RBno  $run3timesPLF_frame.no
    pack [ttk::radiobutton $run3timesPLF_RByes -text [_m "Answer|Yes"] \
					  -variable [mytypevar _Run3TimesFlag] \
					  -value yes] -side left -fill x
    pack [ttk::radiobutton $run3timesPLF_RBno -text [_m "Answer|No"] \
					  -variable [mytypevar _Run3TimesFlag] \
					  -value no] -side left -fill x
    set _Run3TimesFlag yes
    set postprocesscommandLE $frame.postprocesscommandLE
    pack [LabelEntry $postprocesscommandLE \
			-label [_m "Label|Post Process Command:"] -labelwidth $lwidth \
			] -fill x

    set postprocesscommandPLF $frame.postprocesscommandPLF
    pack [LabelFrame $postprocesscommandPLF \
			-text [_m "Label|Run post processing commands?"] \
			-width $lwidth] -fill x
    set postprocesscommandPLF_frame [$postprocesscommandPLF getframe]
    set postprocesscommandPLF_RByes $postprocesscommandPLF_frame.yes
    set postprocesscommandPLF_RBno  $postprocesscommandPLF_frame.no
    pack [ttk::radiobutton $postprocesscommandPLF_RByes \
			-text [_m "Answer|Yes"] \
			-variable [mytypevar _PostProcessCommandFlag] \
			-value yes] -side left -fill x
    pack [ttk::radiobutton $postprocesscommandPLF_RBno \
			-text [_m "Answer|No"] \
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
    return [$dialog draw]    
  }
  typemethod _Cancel {} {
    $dialog withdraw
    return [$dialog enddialog cancel]
  }
  typemethod _Configure {} {
    TimeTable::PrintConfiguration
  }
  typemethod _Print {} {
    $dialog withdraw
    set latexfile "[$printfile cget -text]"
    TimeTable CreateLaTeXTimetable "$latexfile"
    TimeTable::TtInfoMessage draw -message [_ "%s Generated." $latexfile]
    set latexcmd "[$printprogram cget -text] [file rootname $latexfile]"
    if {"[$printprogram cget -text]" ne ""} {
        if {$_Run3TimesFlag} {
            TimeTable::RunSubprocess "$latexcmd"
            TimeTable::RunSubprocess "$latexcmd"
            TimeTable::RunSubprocess "$latexcmd"
        } else {
            TimeTable::RunSubprocess "$latexcmd"
        }
        TimeTable::TtInfoMessage draw -message [_ "Ran: %s" $latexcmd]
        if {$_PostProcessCommandFlag} {
            TimeTable::RunSubprocess "[$postprocesscommandLE cget -text]"
            TimeTable::TtInfoMessage draw -message [_ "Ran: %s" [$postprocesscommandLE cget -text]]
        }
    } else {
        if {$_Run3TimesFlag} {
            TimeTable::TtInfoMessage draw -message [_ "LaTeX source is in %s, you will need to run latex (or pdflatex) manually 3 times over this file." $latexfile]
        } else {
            TimeTable::TtInfoMessage draw -message [_ "LaTeX source is in %s, you will need to run latex (or pdflatex) manually over this file." $latexfile]
        }
    }
    return [$dialog enddialog print]
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
    pack [ScrolledWindow $logwindowSW -auto both -scrollbar both]\
		-expand yes -fill both
    set logwindowText $logwindowSW.text
    ROText $logwindowText -wrap word
    $logwindowSW setwidget $logwindowText
  }

  variable _Pipe
  variable _Running

  method isRunning {} {return $_Running}

  method initializetopframe {frame args} {
    set _Running 0
    $logwindowText delete 1.0 end
    $self configurelist $args
    if {[string length "$options(-command)"] == 0} {
      $self writeText [_ "No command was supplied!\n"]
      return
    }
    if {[string length "$options(-title)"] == 0} {
      $self configure -title [_ "Running %s" $options(-command)]
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
$TimeTable::Main menu entryconfigure file [_m "Menu|File|Print..."] -command TimeTable::PrintTimeTable -state disabled
image create photo PrintButtonImage -file [file join $TimeTable::CommonImageDir print.gif]
$TimeTable::Main toolbar addbutton tools print -image PrintButtonImage \
				      -command TimeTable::PrintTimeTable \
				      -helptext [_ "Print Timetable"] -state disabled
}

proc TimeTable::EnablePrintCommands {} {
  variable Main
  $Main menu entryconfigure file Print... -state normal
  $Main toolbar buttonconfigure tools print -state normal
}

package provide TTPrint 1.0


