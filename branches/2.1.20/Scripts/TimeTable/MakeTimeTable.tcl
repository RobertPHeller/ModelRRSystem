#* 
#* ------------------------------------------------------------------
#* Model Railroad System by Deepwoods Software
#* ------------------------------------------------------------------
#* MakeTimeTable.tcl - Code to generate a time table
#* Created by Robert Heller on Thu Feb 14 18:54:39 2002
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.2  2004/04/14 23:25:17  heller
#* Modification History: Various updates: slave option, additional LaTeX code inclusion.
#* Modification History:
#* Modification History: Revision 1.1  2002/11/10 14:27:46  heller
#* Modification History: Updated for Time Table scripts
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994-2002  Robert Heller D/B/A Deepwoods Software
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

#@Chapter:MakeTimeTable.tcl -- Create the timetable.
#@Label:chapt:MakeTimeTable.tcl
#$Id$

package provide MakeTimeTable 1.0

global MakeTimeTableStatus
# Time Table status array.
# [index] MakeTimeTableStatus!global

set MakeTimeTableStatus(TimeFormat) 24
set MakeTimeTableStatus(AMPMFormat) a
set MakeTimeTableStatus(Title) {My Model Railroad Timetable}
set MakeTimeTableStatus(SubTitle) {Employee Timetable Number 1}
set MakeTimeTableStatus(Date) {\today}
set MakeTimeTableStatus(Filename) "tt[pid].tex"
set MakeTimeTableStatus(TOCP) 0
set MakeTimeTableStatus(NSides) single
set MakeTimeTableStatus(GroupBy) Class
set MakeTimeTableStatus(StationColWidth) 1.5
set MakeTimeTableStatus(TimeColWidth) .5
set MakeTimeTableStatus(Graphicx) 0
set MakeTimeTableStatus(BeforeTOC) {%
% Insert Pre TOC material here.  Cover graphic, logo, etc.
%}
set MakeTimeTableStatus(NotesTOP) {%
% Insert notes prefix info here.
%}

global MakeTimeTableStatusFileTypes
# Holds the MakeTimeTableStatus file types.
# [index] MakeTimeTableStatusFileTypes!global

set MakeTimeTableStatusFileTypes { 
  {{MakeTimeTableStatus Files} {.ttstatus} TEXT}
  {{All Text Files} * TEXT}
}

global LATEX
# Global holding the path to the LaTeX program.
# [index] LATEX!global

set LATEX [auto_execok latex]

global DVIDVI
# Global holding the path to the dvidvi program.
# [index] DVIDVI!global

set DVIDVI [auto_execok dvidvi]

global DVIPS
# Global holding the path to the dvips program.
# [index] DVIPS!global

set DVIPS [auto_execok dvips]

global DVIPSOPTS
# Global holding options for the dvips program.
# [index] DVIPSOPTS!global

# Set for letter-sized paper, reverse stacking (typical for inkjet printers).
set DVIPSOPTS [list -t letter -r]





proc MakeTimeTable {} {
# Procedure to create a hardcopy timetable. Generates a LaTeX file to do this.
# [index] MakeTimeTable!procedure

  global Trains Stations Notes CabColors TrackList
  global HasCabP HasTrackP
  global TotalLength DuplicateTrackMap


  set totalTrains [llength [array names Trains]]
  if {$totalTrains < 1} {
    tk_messageBox -icon info -type ok -message "No Trains!"
    return
  }

  if {[string compare "[tk_messageBox -default yes -type yesno -icon question -message {Load generation parameters?}]" {yes}] == 0} {
    LoadTimeTableStatus
  }

  set allTrains [lsort -command TrainComp [array names Trains]]
  set forwardTrains {}
  set backwardTrains {}
  foreach tr $allTrains {
    if {$Stations([lindex [lindex $Trains($tr) 1] 1]) < $Stations([lindex [lindex $Trains($tr) end] 1])} {
      lappend forwardTrains $tr
    } else {
      lappend backwardTrains $tr
    }
  }

  global MakeTimeTableStatus
  
# .baseMakeTimeTableInfo
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .baseMakeTimeTableInfo
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .baseMakeTimeTableInfo"
  } {
    catch "destroy .baseMakeTimeTableInfo"
  }
  toplevel .baseMakeTimeTableInfo 

  # Window manager configurations
  wm positionfrom .baseMakeTimeTableInfo ""
  wm sizefrom .baseMakeTimeTableInfo ""
  wm maxsize .baseMakeTimeTableInfo 1009 738
  wm minsize .baseMakeTimeTableInfo 1 1
  wm protocol .baseMakeTimeTableInfo WM_DELETE_WINDOW {.baseMakeTimeTableInfo.buttons.button5 invoke}
  wm title .baseMakeTimeTableInfo {Basic Make Time Table Info}
  wm transient .baseMakeTimeTableInfo .


  # build widget .baseMakeTimeTableInfo.banner
  frame .baseMakeTimeTableInfo.banner \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.banner.label27
  label .baseMakeTimeTableInfo.banner.label27 \
    -image {banner}

  # build widget .baseMakeTimeTableInfo.banner.label28
  label .baseMakeTimeTableInfo.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Step 1: Get Basic Time Table Info}

  # build widget .baseMakeTimeTableInfo.info
  frame .baseMakeTimeTableInfo.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .baseMakeTimeTableInfo.info.title
  frame .baseMakeTimeTableInfo.info.title \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.title.label12
  label .baseMakeTimeTableInfo.info.title.label12 \
    -text {Title:}

  # build widget .baseMakeTimeTableInfo.info.title.title
  entry .baseMakeTimeTableInfo.info.title.title -textvariable MakeTimeTableStatus(Title)

  # build widget .baseMakeTimeTableInfo.info.subtitle
  frame .baseMakeTimeTableInfo.info.subtitle \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.subtitle.label14
  label .baseMakeTimeTableInfo.info.subtitle.label14 \
    -text {Sub Title:}

  # build widget .baseMakeTimeTableInfo.info.subtitle.subtitle
  entry .baseMakeTimeTableInfo.info.subtitle.subtitle -textvariable MakeTimeTableStatus(SubTitle)

  # build widget .baseMakeTimeTableInfo.info.date
  frame .baseMakeTimeTableInfo.info.date \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.date.label16
  label .baseMakeTimeTableInfo.info.date.label16 \
    -text {Date:}

  # build widget .baseMakeTimeTableInfo.info.date.date
  entry .baseMakeTimeTableInfo.info.date.date -textvariable MakeTimeTableStatus(Date)

  # build widget .baseMakeTimeTableInfo.info.filename
  frame .baseMakeTimeTableInfo.info.filename \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.filename.label18
  label .baseMakeTimeTableInfo.info.filename.label18 \
    -text {Filename:}

  # build widget .baseMakeTimeTableInfo.info.filename.filename
  entry .baseMakeTimeTableInfo.info.filename.filename \
	-textvariable MakeTimeTableStatus(Filename)

  # build widget .baseMakeTimeTableInfo.info.filename.button20
  button .baseMakeTimeTableInfo.info.filename.button20 \
    -padx {9} \
    -pady {3} \
    -text {Browse} \
    -command {
	global MakeTimeTableStatus
	set newName "[tk_getSaveFile -defaultextension .tex \
				     -filetypes {{{LaTeX Files} {.tex} TEXT} {{All Text Files} * TEXT}} \
				     -initialfile "$MakeTimeTableStatus(Filename)" \
				     -title {LaTeX file to create} \
				     -parent .baseMakeTimeTableInfo]"
	if {[string length "$newName"] > 0} {set MakeTimeTableStatus(Filename) "$newName"}
    }

  # build widget .baseMakeTimeTableInfo.info.timeformat
  frame .baseMakeTimeTableInfo.info.timeformat \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twentyfour
  frame .baseMakeTimeTableInfo.info.timeformat.twentyfour \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twentyfour.radiobutton23
  radiobutton .baseMakeTimeTableInfo.info.timeformat.twentyfour.radiobutton23 \
    -text {24 Hour Format} \
    -value {24} \
    -variable {MakeTimeTableStatus(TimeFormat)}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve
  frame .baseMakeTimeTableInfo.info.timeformat.twelve \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve.radiobutton24
  radiobutton .baseMakeTimeTableInfo.info.timeformat.twelve.radiobutton24 \
    -text {12 Hour Format} \
    -value {12} \
    -variable {MakeTimeTableStatus(TimeFormat)}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve.ampm
  frame .baseMakeTimeTableInfo.info.timeformat.twelve.ampm \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton26
  radiobutton .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton26 \
    -text {Small a or p} \
    -value {a} \
    -variable {MakeTimeTableStatus(AMPMFormat)}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton27
  radiobutton .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton27 \
    -text {Large AM and PM} \
    -value {AP} \
    -variable {MakeTimeTableStatus(AMPMFormat)}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.label28
  label .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.label28 \
    -text {AM/PM format}

  # build widget .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton29
  radiobutton .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton29 \
    -text {Light font for AM, bold font for PM} \
    -value {lB} \
    -variable {MakeTimeTableStatus(AMPMFormat)}

  # build widget .baseMakeTimeTableInfo.info.dirname
  frame .baseMakeTimeTableInfo.info.dirname \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.dirname.label6
  label .baseMakeTimeTableInfo.info.dirname.label6 \
    -text {Forward Direction is generally: }

  # build widget .baseMakeTimeTableInfo.info.dirname.dire
  tk_optionMenu .baseMakeTimeTableInfo.info.dirname.dire MakeTimeTableStatus(DirectionName) Northbound Eastbound Southbound Westbound

  # build widget .baseMakeTimeTableInfo.info.latexWidths
  frame .baseMakeTimeTableInfo.info.latexWidths \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.latexWidths.label13
  label .baseMakeTimeTableInfo.info.latexWidths.label13 \
    -text {Station Column Width:}

  # build widget .baseMakeTimeTableInfo.info.latexWidths.stationColWidth
  entry .baseMakeTimeTableInfo.info.latexWidths.stationColWidth \
    -textvariable {MakeTimeTableStatus(StationColWidth)} \
    -width {10}

  # build widget .baseMakeTimeTableInfo.info.latexWidths.label15
  label .baseMakeTimeTableInfo.info.latexWidths.label15 \
    -text {Time Column Width:}

  # build widget .baseMakeTimeTableInfo.info.latexWidths.timeColWidth
  entry .baseMakeTimeTableInfo.info.latexWidths.timeColWidth \
    -textvariable {MakeTimeTableStatus(TimeColWidth)} \
    -width {10}

  # build widget .baseMakeTimeTableInfo.info.checkbutton1
  checkbutton .baseMakeTimeTableInfo.info.checkbutton1 \
    -anchor {w} \
    -text {Include graphix package?} \
    -variable {MakeTimeTableStatus(Graphicx)}

  # build widget .baseMakeTimeTableInfo.info.label2
  label .baseMakeTimeTableInfo.info.label2 \
    -anchor {w} \
    -text {LaTeX code before TOC:}

  # build widget .baseMakeTimeTableInfo.info.beforeTOC
  frame .baseMakeTimeTableInfo.info.beforeTOC \
    -relief {flat}

  # build widget .baseMakeTimeTableInfo.info.beforeTOC.scrollbar1
  scrollbar .baseMakeTimeTableInfo.info.beforeTOC.scrollbar1 \
    -command {.baseMakeTimeTableInfo.info.beforeTOC.text yview} \
    -relief {sunken}

  # build widget .baseMakeTimeTableInfo.info.beforeTOC.text
  text .baseMakeTimeTableInfo.info.beforeTOC.text \
    -height {8} \
    -wrap {word} \
    -yscrollcommand {.baseMakeTimeTableInfo.info.beforeTOC.scrollbar1 set}

  # build widget .baseMakeTimeTableInfo.info.label3
  label .baseMakeTimeTableInfo.info.label3 \
    -anchor {w} \
    -text {LaTeX at beginning of Notes section:}

  # build widget .baseMakeTimeTableInfo.info.notesTOP
  frame .baseMakeTimeTableInfo.info.notesTOP \
    -relief {flat}

  # build widget .baseMakeTimeTableInfo.info.notesTOP.scrollbar1
  scrollbar .baseMakeTimeTableInfo.info.notesTOP.scrollbar1 \
    -command {.baseMakeTimeTableInfo.info.notesTOP.text yview} \
    -relief {sunken}

  # build widget .baseMakeTimeTableInfo.info.notesTOP.text
  text .baseMakeTimeTableInfo.info.notesTOP.text \
    -height {8} \
    -wrap {word} \
    -yscrollcommand {.baseMakeTimeTableInfo.info.notesTOP.scrollbar1 set}

  # build widget .baseMakeTimeTableInfo.buttons
  frame .baseMakeTimeTableInfo.buttons \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.buttons.button5
  button .baseMakeTimeTableInfo.buttons.button5 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 0}

  # build widget .baseMakeTimeTableInfo.buttons.button6
  button .baseMakeTimeTableInfo.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 1}

  # pack master .baseMakeTimeTableInfo.banner
  pack configure .baseMakeTimeTableInfo.banner.label27 \
    -side left
  pack configure .baseMakeTimeTableInfo.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.dirname
  pack configure .baseMakeTimeTableInfo.info.dirname.label6 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.dirname.dire \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.latexWidths
  pack configure .baseMakeTimeTableInfo.info.latexWidths.label13 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.latexWidths.stationColWidth \
    -expand 1 \
    -fill x \
    -side left
  pack configure .baseMakeTimeTableInfo.info.latexWidths.label15 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.latexWidths.timeColWidth \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info
  pack configure .baseMakeTimeTableInfo.info.title \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.subtitle \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.date \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.filename \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.timeformat \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.dirname \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.latexWidths \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.checkbutton1 \
    -expand 1 \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.label2 \
    -expand 1 \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.beforeTOC \
    -fill both
  pack configure .baseMakeTimeTableInfo.info.label3 \
    -expand 1 \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.notesTOP \
    -fill both

  # pack master .baseMakeTimeTableInfo.info.beforeTOC
  pack configure .baseMakeTimeTableInfo.info.beforeTOC.scrollbar1 \
    -fill y \
    -side right
  pack configure .baseMakeTimeTableInfo.info.beforeTOC.text \
    -expand 1 \
    -fill both

  # pack master .baseMakeTimeTableInfo.info.notesTOP
  pack configure .baseMakeTimeTableInfo.info.notesTOP.scrollbar1 \
    -fill y \
    -side right
  pack configure .baseMakeTimeTableInfo.info.notesTOP.text \
    -expand 1 \
    -fill both

  # pack master .baseMakeTimeTableInfo.info.title
  pack configure .baseMakeTimeTableInfo.info.title.label12 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.title.title \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.subtitle
  pack configure .baseMakeTimeTableInfo.info.subtitle.label14 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.subtitle.subtitle \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.date
  pack configure .baseMakeTimeTableInfo.info.date.label16 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.date.date \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.filename
  pack configure .baseMakeTimeTableInfo.info.filename.label18 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.filename.filename \
    -expand 1 \
    -fill x \
    -side left
  pack configure .baseMakeTimeTableInfo.info.filename.button20 \
    -side right

  # pack master .baseMakeTimeTableInfo.info.timeformat
  pack configure .baseMakeTimeTableInfo.info.timeformat.twentyfour \
    -fill x \
    -side left
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.timeformat.twentyfour
  pack configure .baseMakeTimeTableInfo.info.timeformat.twentyfour.radiobutton23 \
    -anchor w \
    -expand 1 \
    -fill x

  # pack master .baseMakeTimeTableInfo.info.timeformat.twelve
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve.radiobutton24 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve.ampm \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.timeformat.twelve.ampm
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.label28 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton26 \
    -anchor w
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton27 \
    -anchor w
  pack configure .baseMakeTimeTableInfo.info.timeformat.twelve.ampm.radiobutton29 \
    -anchor w \
    -side right

  # pack master .baseMakeTimeTableInfo.buttons
  pack configure .baseMakeTimeTableInfo.buttons.button5 \
    -side left
  pack configure .baseMakeTimeTableInfo.buttons.button6 \
    -side right

  # pack master .baseMakeTimeTableInfo
  pack configure .baseMakeTimeTableInfo.banner \
    -fill x
  pack configure .baseMakeTimeTableInfo.info \
    -expand 1 \
    -fill both
  pack configure .baseMakeTimeTableInfo.buttons \
    -fill x

  .baseMakeTimeTableInfo.info.beforeTOC.text insert end "$MakeTimeTableStatus(BeforeTOC)"
  .baseMakeTimeTableInfo.info.notesTOP.text insert end "$MakeTimeTableStatus(NotesTOP)"

# end of widget tree

  set w .baseMakeTimeTableInfo
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  focus $w.info.title.title

  set MakeTimeTableStatus(Button) -1
  tkwait variable MakeTimeTableStatus(Button)

  set MakeTimeTableStatus(BeforeTOC) "[.baseMakeTimeTableInfo.info.beforeTOC.text get 1.0 end]"
  set MakeTimeTableStatus(NotesTOP) "[.baseMakeTimeTableInfo.info.notesTOP.text get 1.0 end]"

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .baseMakeTimeTableInfo}

  if {$MakeTimeTableStatus(Button) == 0} {
    return
  }

  set maxTrains [expr int((7 - $MakeTimeTableStatus(StationColWidth) \
		             - $MakeTimeTableStatus(TimeColWidth)) \
		          / $MakeTimeTableStatus(TimeColWidth))]

  if {$totalTrains >= $maxTrains} {
    set MakeTimeTableStatus(UseMultipleTables) 1
    if {[GetMultipleTablesParameters] == 0} {return}
  } else {
    set MakeTimeTableStatus(UseMultipleTables) 0
    set MakeTimeTableStatus(TOCP) 0
    set MakeTimeTableStatus(NSides) single
  }

  if {[catch [list open "$MakeTimeTableStatus(Filename)" w] tfp]} {
    tk_messageBox -type ok -icon error -message "MakeTimeTable: open $MakeTimeTableStatus(Filename) w: $tfp"
    return
  }

  puts $tfp {\nonstopmode}
  if {[string compare "$MakeTimeTableStatus(NSides)" {double}] == 0} {
    puts $tfp {\documentclass[notitlepage,twoside]{article}}
  } else {
    puts $tfp {\documentclass[notitlepage]{article}}
  }
  puts $tfp {\usepackage{TimeTable}}
  puts $tfp {\usepackage{supertabular}}
  if {$MakeTimeTableStatus(Graphicx)} {puts $tfp {\usepackage{graphicx}}}
  if {!$MakeTimeTableStatus(TOCP)} {
    puts $tfp {\nofiles}
  }
  if {$MakeTimeTableStatus(TimeFormat) == 24} {
    puts $tfp {\newcommand{\shtime}{\rrtimetwentyfour}}
  } else {
    puts $tfp "\\newcommand\{\\shtime\}\{\\rrtimetwelve$MakeTimeTableStatus(AMPMFormat)\}"
  }
  if {$MakeTimeTableStatus(StationColWidth) != 1.5} {
    puts $tfp "\\setlength\{\\stationwidth\}\{$MakeTimeTableStatus(StationColWidth)in\}"
    puts $tfp {\setlength{\stationwidthonear}{\stationwidth}}
    puts $tfp {\advance\stationwidthonear by -.25in}
    puts $tfp {\setlength{\stationwidthtwoar}{\stationwidthonear}}
    puts $tfp {\advance\stationwidthtwoar by -.25in}
  }
  if {$MakeTimeTableStatus(TimeColWidth) != .5} {
    puts $tfp "\\setlength\{\\timecolumnwidth\}\{$MakeTimeTableStatus(TimeColWidth)in\}"
  }    
  puts $tfp "\\title\{$MakeTimeTableStatus(Title)\}"
  puts $tfp "\\author\{$MakeTimeTableStatus(SubTitle)\}"
  puts $tfp "\\date\{$MakeTimeTableStatus(Date)\}"
  
  puts $tfp {\begin{document}}

  puts $tfp {\maketitle}

  puts $tfp "$MakeTimeTableStatus(BeforeTOC)"

  if {$MakeTimeTableStatus(TOCP)} {
    puts $tfp {\tableofcontents}
  }
  if {$MakeTimeTableStatus(UseMultipleTables) && \
      [string compare "$MakeTimeTableStatus(GroupBy)" {Class}] == 0} {
    if {[MakeTimeTableGroupByClass $tfp $allTrains $forwardTrains $backwardTrains] == 0} {
      close $tfp
      file delete -force $MakeTimeTableStatus(Filename)
      return
    }
  } elseif {$totalTrains > 8} {
    if {[MakeTimeTableGroupManually $tfp $maxTrains $allTrains] == 0} {
      close $tfp
      file delete -force $MakeTimeTableStatus(Filename)
      return
    }
  } else {
    MakeTimeTableOneTable $tfp $allTrains $forwardTrains $backwardTrains
  }

  set nts [lsort -integer [array names Notes]]
  if {[llength $nts] > 0} {
    puts $tfp {\section*{Notes}}
    if {$MakeTimeTableStatus(TOCP)} {
      puts $tfp {\addcontentsline{toc}{section}{Notes}}
    }

    puts $tfp "$MakeTimeTableStatus(NotesTOP)"

    puts $tfp {\begin{description}}
    foreach nt $nts {
      set end [expr [string length "$Notes($nt)"] - 1]
      if {[string first [string index "$Notes($nt)" $end] {.?!}] < 0} {
	set period {.}
      } else {
	set period {}
      }
      puts $tfp "\\item\[$nt\] $Notes($nt)$period"
    }
    puts $tfp {\end{description}}
  }
  puts $tfp {\end{document}}
  close $tfp

  if {[string compare "[tk_messageBox -default yes -type yesno -icon question -message {LaTeX file generated.  Save generation parameters?}]" {yes}] == 0} {
    SaveTimeTableStatus
  }

  if {[string compare "[tk_messageBox -default yes -type yesno -icon question -message {Run LaTeX now?}]" {no}] == 0} {return}

  global LATEX DVIDVI DVIPS DVIPSOPTS
  if {[RunSubprocess [concat $LATEX [file rootname $MakeTimeTableStatus(Filename)]] {Running LaTeX (pass 1)}] == 0} {
    return
  }
  if {$MakeTimeTableStatus(TOCP)} {
    if {[RunSubprocess [concat $LATEX [file rootname $MakeTimeTableStatus(Filename)]] {Running LaTeX (pass 2)}] == 0} {
      return
    }
    if {[RunSubprocess [concat $LATEX [file rootname $MakeTimeTableStatus(Filename)]] {Running LaTeX (pass 3)}] == 0} {
      return
    }
  }
  if {[string compare "$MakeTimeTableStatus(NSides)" {double}] == 0} {
    switch -exact -- [tk_messageBox -type yesnocancel -icon question \
			-message "Run dvidvi to extract odd and even pages?"] {
      yes {
	if {[RunSubprocess [concat $DVIDVI \
				   {2:0} \
				   [file rootname $MakeTimeTableStatus(Filename)].dvi \
				   [file rootname $MakeTimeTableStatus(Filename)]_O.dvi] \
			   {dvidvi -- Odd Pages}] == 0} {return}
	if {[RunSubprocess [concat $DVIDVI \
				   {2:-1} \
				   [file rootname $MakeTimeTableStatus(Filename)].dvi \
				   [file rootname $MakeTimeTableStatus(Filename)]_E.dvi] \
			   {dvidvi -- Even Pages}] == 0} {return}
        set DVIFiles [list [file rootname $MakeTimeTableStatus(Filename)]_E \
			   [file rootname $MakeTimeTableStatus(Filename)]_O]
      }
      cancel {return}
      no {
        set DVIFiles [list [file rootname $MakeTimeTableStatus(Filename)]]
      }
    }
  } else {
    set DVIFiles [list [file rootname $MakeTimeTableStatus(Filename)]]
  }

  if {[llength $DVIFiles] == 1} {
    RunSubprocess [concat $DVIPS $DVIPSOPTS [lindex $DVIFiles 0]] {dvips}
  } else {
    if {[RunSubprocess [concat $DVIPS $DVIPSOPTS [lindex $DVIFiles 0]] {dvips -- Even Pages}] == 0} {return}
    tk_messageBox -type ok -icon info -message {Even pages spooled.  When printout complets, flip output over and re-feed for backside printing}
    RunSubprocess [concat $DVIPS $DVIPSOPTS [lindex $DVIFiles 1]] {dvips -- Odd Pages}
  }
}

proc RunSubprocess {commandlist message} {
# Procedure to run a subprocess.
# <in> commandlist -- list containing the command line to run.
# <in> message -- message to display.
# [index] RunSubprocess!procedure

  global MakeTimeTableStatus tcl_platform
  if {[string compare "$tcl_platform(os)" "MacOS"] == 0 && 
      [string match "$tcl_platform(osVersion)" {10.*}] == 0} {
    tk_messageBox -type ok -icon warning -message "No subprocess support under MacOS Version <= 9.x"
    return 0
  }

  if {[catch [list open "|$commandlist" r] cmdpipe]} {
    tk_messageBox -type ok -icon error -message "$commandlist: $cmdpipe"
    return 0
  }
# .subprocessWindow
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .subprocessWindow
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .subprocessWindow"
  } {
    catch "destroy .subprocessWindow"
  }
  toplevel .subprocessWindow 

  # Window manager configurations
  wm positionfrom .subprocessWindow ""
  wm sizefrom .subprocessWindow ""
  wm maxsize .subprocessWindow 1000 768
  wm minsize .subprocessWindow 10 10
  wm protocol .subprocessWindow WM_DELETE_WINDOW {.subprocessWindow.buttons.button10 invoke}
  wm title .subprocessWindow {Subprocess Window}
  wm transient .subprocessWindow .

  # build widget .subprocessWindow.banner
  frame .subprocessWindow.banner \
    -borderwidth {2}

  # build widget .subprocessWindow.banner.label27
  label .subprocessWindow.banner.label27 \
    -image {banner}

  # build widget .subprocessWindow.banner.label28
  label .subprocessWindow.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Running Subprocesses}

  # build widget .subprocessWindow.workFrame
  frame .subprocessWindow.workFrame \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .subprocessWindow.workFrame.command
  frame .subprocessWindow.workFrame.command \
    -borderwidth {2}

  # build widget .subprocessWindow.workFrame.command.label13
  label .subprocessWindow.workFrame.command.label13 \
    -anchor {w} \
    -relief {sunken} \
    -text "Running: $message"

  # build widget .subprocessWindow.workFrame.frame
  frame .subprocessWindow.workFrame.frame

  # build widget .subprocessWindow.workFrame.frame.scrollbar1
  scrollbar .subprocessWindow.workFrame.frame.scrollbar1 \
    -command {.subprocessWindow.workFrame.frame.text2 yview}

  # build widget .subprocessWindow.workFrame.frame.text2
  text .subprocessWindow.workFrame.frame.text2 \
    -yscrollcommand {.subprocessWindow.workFrame.frame.scrollbar1 set}
  # bindings
  bind .subprocessWindow.workFrame.frame.text2 <Key> {break}

  # build widget .subprocessWindow.buttons
  frame .subprocessWindow.buttons \
    -borderwidth {2}

  # build widget .subprocessWindow.buttons.button10
  button .subprocessWindow.buttons.button10 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 0}

  # build widget .subprocessWindow.buttons.button11
  button .subprocessWindow.buttons.button11 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -state disabled \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 1}

  # pack master .subprocessWindow.banner
  pack configure .subprocessWindow.banner.label27 \
    -side left
  pack configure .subprocessWindow.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .subprocessWindow.workFrame
  pack configure .subprocessWindow.workFrame.command \
    -fill x
  pack configure .subprocessWindow.workFrame.frame \
    -expand 1 \
    -fill both

  # pack master .subprocessWindow.workFrame.command
  pack configure .subprocessWindow.workFrame.command.label13 \
    -anchor w \
    -expand 1 \
    -fill x

  # pack master .subprocessWindow.workFrame.frame
  pack configure .subprocessWindow.workFrame.frame.scrollbar1 \
    -fill y \
    -side right
  pack configure .subprocessWindow.workFrame.frame.text2 \
    -expand 1 \
    -fill both

  # pack master .subprocessWindow.buttons
  pack configure .subprocessWindow.buttons.button10 \
    -side left
  pack configure .subprocessWindow.buttons.button11 \
    -side right

  # pack master .subprocessWindow
  pack configure .subprocessWindow.banner \
    -fill x
  pack configure .subprocessWindow.workFrame \
    -expand 1 \
    -fill x
  pack configure .subprocessWindow.buttons \
    -fill x

  .subprocessWindow.workFrame.frame.text2 insert end "> $commandlist\n"


# end of widget tree

  set w .subprocessWindow
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w

  set MakeTimeTableStatus(Button) -1
  fileevent $cmdpipe readable "RunSubprocessPipe $cmdpipe .subprocessWindow.workFrame.frame.text2 .subprocessWindow.buttons.button11"
  tkwait variable MakeTimeTableStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .subprocessWindow}
  catch "close $cmdpipe"

  return $MakeTimeTableStatus(Button)
}

proc RunSubprocessPipe {pipe textW buttonW} {
# Procedure to handle a subprocess pipe.
# <in> pipe -- stdout from the process.
# <in> textW -- text widget to display the process's stdout to.
# <in> buttonW -- button to enable when the process finishes.
# [index] RunSubprocessPipe!procedure

  if {[gets $pipe Line] < 0} {
    catch "close $pipe" standardError
    $textW insert end "\n$standardError\n"
    $buttonW configure -state normal
  }
  $textW insert end "$Line\n"
}


proc GetMultipleTablesParameters {} {
# Procedure to get multiple table parameters.
# [index] GetMultipleTablesParameters!procedure

  global MakeTimeTableStatus

# .baseMakeTimeTableInfo
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .baseMakeTimeTableInfo
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .baseMakeTimeTableInfo"
  } {
    catch "destroy .baseMakeTimeTableInfo"
  }
  toplevel .baseMakeTimeTableInfo 

  # Window manager configurations
  wm positionfrom .baseMakeTimeTableInfo ""
  wm sizefrom .baseMakeTimeTableInfo ""
  wm maxsize .baseMakeTimeTableInfo 1009 738
  wm minsize .baseMakeTimeTableInfo 1 1
  wm protocol .baseMakeTimeTableInfo WM_DELETE_WINDOW {.baseMakeTimeTableInfo.buttons.button5 invoke}
  wm title .baseMakeTimeTableInfo {Basic Make Time Table Info}
  wm transient .baseMakeTimeTableInfo .


  # build widget .baseMakeTimeTableInfo.banner
  frame .baseMakeTimeTableInfo.banner \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.banner.label27
  label .baseMakeTimeTableInfo.banner.label27 \
    -image {banner}

  # build widget .baseMakeTimeTableInfo.banner.label28
  label .baseMakeTimeTableInfo.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Step 2: Get Multiple Table Time Table Info}

  # build widget .baseMakeTimeTableInfo.info
  frame .baseMakeTimeTableInfo.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .baseMakeTimeTableInfo.info.nsides
  frame .baseMakeTimeTableInfo.info.nsides \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.nsides.radiobutton1
  radiobutton .baseMakeTimeTableInfo.info.nsides.radiobutton1 \
    -text {Single Sided} \
    -value {single} \
    -variable {MakeTimeTableStatus(NSides)}

  # build widget .baseMakeTimeTableInfo.info.nsides.radiobutton2
  radiobutton .baseMakeTimeTableInfo.info.nsides.radiobutton2 \
    -text {Double Sided} \
    -value {double} \
    -variable {MakeTimeTableStatus(NSides)}

  # build widget .baseMakeTimeTableInfo.info.tocP
  frame .baseMakeTimeTableInfo.info.tocP \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.tocP.checkbutton4
  checkbutton .baseMakeTimeTableInfo.info.tocP.checkbutton4 \
    -text {Generate Table Of Contents?} \
    -variable {MakeTimeTableStatus(TOCP)}

  # build widget .baseMakeTimeTableInfo.info.groupBy
  frame .baseMakeTimeTableInfo.info.groupBy \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.info.groupBy.label9
  label .baseMakeTimeTableInfo.info.groupBy.label9 \
    -text {Group trains by:}

  # build widget .baseMakeTimeTableInfo.info.groupBy.radiobutton10
  radiobutton .baseMakeTimeTableInfo.info.groupBy.radiobutton10 \
    -text {Class} \
    -value {Class} \
    -variable {MakeTimeTableStatus(GroupBy)}

  # build widget .baseMakeTimeTableInfo.info.groupBy.radiobutton11
  radiobutton .baseMakeTimeTableInfo.info.groupBy.radiobutton11 \
    -text {Manual Selection} \
    -value {Manually} \
    -variable {MakeTimeTableStatus(GroupBy)}

  # build widget .baseMakeTimeTableInfo.buttons
  frame .baseMakeTimeTableInfo.buttons \
    -borderwidth {2}

  # build widget .baseMakeTimeTableInfo.buttons.button5
  button .baseMakeTimeTableInfo.buttons.button5 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 0}

  # build widget .baseMakeTimeTableInfo.buttons.button6
  button .baseMakeTimeTableInfo.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 1}

  # pack master .baseMakeTimeTableInfo.banner
  pack configure .baseMakeTimeTableInfo.banner.label27 \
    -side left
  pack configure .baseMakeTimeTableInfo.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .baseMakeTimeTableInfo.info.nsides
  pack configure .baseMakeTimeTableInfo.info.nsides.radiobutton1 \
    -expand 1 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.nsides.radiobutton2 \
    -expand 1 \
    -side right

  # pack master .baseMakeTimeTableInfo.info.tocP
  pack configure .baseMakeTimeTableInfo.info.tocP.checkbutton4

  # pack master .baseMakeTimeTableInfo.info.groupBy
  pack configure .baseMakeTimeTableInfo.info.groupBy.label9 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.groupBy.radiobutton10 \
    -side left
  pack configure .baseMakeTimeTableInfo.info.groupBy.radiobutton11 \
    -side right

  pack configure .baseMakeTimeTableInfo.info.nsides \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.tocP \
    -fill x
  pack configure .baseMakeTimeTableInfo.info.groupBy \
    -fill x

  # pack master .baseMakeTimeTableInfo.buttons
  pack configure .baseMakeTimeTableInfo.buttons.button5 \
    -side left
  pack configure .baseMakeTimeTableInfo.buttons.button6 \
    -side right

  # pack master .baseMakeTimeTableInfo
  pack configure .baseMakeTimeTableInfo.banner \
    -fill x
  pack configure .baseMakeTimeTableInfo.info \
    -expand 1 \
    -fill both
  pack configure .baseMakeTimeTableInfo.buttons \
    -fill x



# end of widget tree

  set w .baseMakeTimeTableInfo
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  set MakeTimeTableStatus(Button) -1
  tkwait variable MakeTimeTableStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .baseMakeTimeTableInfo}

  return $MakeTimeTableStatus(Button)

}

proc MakeTimeTableGroupByClass {tfp allTrains forwardTrains backwardTrains} {
# Procedure to make tables, grouped by class.
# <in> tfp -- channel to LaTeX file.
# <in> allTrains -- sorted list of all trains.
# <in> forwardTrains -- forward trains (read down columns).
# <in> backwardTrains -- backward trains (read up columns).
# [index] MakeTimeTableGroupByClass!procedure

  global MakeTimeTableStatus Trains

  set classes {}

  foreach tr $allTrains {
    set class [lindex [lindex $Trains($tr) 0] 2]
    if {[lsearch -exact $classes $class] < 0} {lappend classes $class}
  }
  foreach class [lsort -integer $classes] {
    set fcl {}
    set bcl {}
    set acl {}
    foreach ft $forwardTrains {
      if {[lindex [lindex $Trains($ft) 0] 2] == $class} {lappend fcl $ft}
    }
    foreach bt $backwardTrains {
      if {[lindex [lindex $Trains($ft) 0] 2] == $class} {lappend bcl $bt}
    }
    foreach t $allTrains {
      if {[lindex [lindex $Trains($ft) 0] 2] == $class} {lappend acl $t}
    }

# .className
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .className
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .className"
  } {
    catch "destroy .className"
  }
  toplevel .className 

  # Window manager configurations
  wm positionfrom .className ""
  wm sizefrom .className ""
  wm maxsize .className 1009 738
  wm minsize .className 1 1
  wm protocol .className WM_DELETE_WINDOW {.className.buttons.button3 invoke}
  wm title .className "Get Header for class $class trains"
  wm transient .className .


  # build widget .className.banner
  frame .className.banner \
    -borderwidth {2}

  # build widget .className.banner.label27
  label .className.banner.label27 \
    -image {banner}

  # build widget .className.banner.label28
  label .className.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text "Class header text for class $class trains"

  # build widget .className.info
  frame .className.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .className.info.section
  frame .className.info.section \
    -borderwidth {0}

  # build widget .className.info.section.label5
  label .className.info.section.label5 \
    -text {Header text:}

  # build widget .className.info.section.header
  entry .className.info.section.header \
    -textvariable MakeTimeTableStatus(ClassHeader)
  bind .className.info.section.header <Return> {.className.buttons.button4 invoke}

  # build widget .className.info.labels
  label .className.info.labels \
    -text {LaTeX code to insert before table:} \
    -anchor w

  # build widget .className.info.sectionTOP
  frame .className.info.sectionTOP \
    -relief {flat}

  # build widget .className.info.sectionTOP.scrollbar1
  scrollbar .className.info.sectionTOP.scrollbar1 \
    -command {.className.info.sectionTOP.text yview} \
    -relief {sunken}

  # build widget .className.info.sectionTOP.text
  text .className.info.sectionTOP.text \
    -height {8} \
    -wrap {word} \
    -yscrollcommand {.className.info.sectionTOP.scrollbar1 set}

  # build widget .className.buttons
  frame .className.buttons \
    -borderwidth {2}

  # build widget .className.buttons.button3
  button .className.buttons.button3 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 0}

  # build widget .className.buttons.button4
  button .className.buttons.button4 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {global MakeTimeTableStatus;set MakeTimeTableStatus(Button) 1}

  # pack master .className.banner
  pack configure .className.banner.label27 \
    -side left
  pack configure .className.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .className.info.section
  pack configure .className.info.section.label5 \
    -side left
  pack configure .className.info.section.header \
    -expand 1 \
    -fill x \
    -side right

  # pack master .className.info.sectionTOP
  pack configure .className.info.sectionTOP.scrollbar1 \
    -fill y \
    -side right
  pack configure .className.info.sectionTOP.text \
    -expand 1 \
    -fill both

  # pack master .className.info
  pack configure .className.info.section \
    -fill x
  pack configure .className.info.labels \
    -expand 1 \
    -fill x
  pack configure .className.info.sectionTOP \
    -fill both

  # pack master .className.buttons
  pack configure .className.buttons.button3 \
    -side left
  pack configure .className.buttons.button4 \
    -side right

  # pack master .className
  pack configure .className.banner \
    -fill x
  pack configure .className.info \
    -expand 1 \
    -fill both
  pack configure .className.buttons \
    -fill x

# end of widget tree

    if {[catch "set MakeTimeTableStatus(Group,$class,ClassHeader)" MakeTimeTableStatus(ClassHeader)]} {
      set MakeTimeTableStatus(ClassHeader) "Class $class trains"
    }

    if {[catch "set MakeTimeTableStatus(Group,$class,SectionTOP)" sectionTOP]} {
      set sectionTOP {%
% Insert section TOP code here
%}
    }
    .className.info.sectionTOP.text insert end "$sectionTOP"


    set w .className
    wm withdraw $w
    update idletasks
    set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
    set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
    wm geom $w +$x+$y
    wm deiconify $w
    
    set oldFocus [focus]
    set oldGrab [grab current $w]
    if {$oldGrab != ""} {
      set grabStatus [grab status $oldGrab]
    }
    grab $w
    focus $w.info.section.header

    set MakeTimeTableStatus(Button) -1
    tkwait variable MakeTimeTableStatus(Button)

    set sectionTOP [.className.info.sectionTOP.text get 1.0 end]

    catch {focus $oldFocus}
    if {$oldGrab != ""} {
      if {$grabStatus == "global"} {
        grab -global $oldGrab
      } else {
        grab $oldGrab
      }
    }
    catch {destroy .className}

    if {$MakeTimeTableStatus(Button) == 0} {
      return 0
    }
    MakeTimeTableOneTable $tfp $acl $fcl $bcl "$MakeTimeTableStatus(ClassHeader)" "$sectionTOP"
    set MakeTimeTableStatus(Group,$class,All) $acl
    set MakeTimeTableStatus(Group,$class,Forward) $fcl
    set MakeTimeTableStatus(Group,$class,Backward) $bcl
    set MakeTimeTableStatus(Group,$class,ClassHeader) "$MakeTimeTableStatus(ClassHeader)"
    set MakeTimeTableStatus(Group,$class,SectionTOP) "$sectionTOP"
    catch {unset MakeTimeTableStatus(ClassHeader)}
  }
  return 1
}

proc MakeTimeTableOneTable {tfp allTrains forwardTrains backwardTrains {chapter {All Trains}} {sectionTOP {}}} {
# Procedure to make a single timetable.
# <in> tfp -- channel to LaTeX file.
# <in> allTrains -- sorted list of all trains.
# <in> forwardTrains -- forward trains (read down columns).
# <in> backwardTrains -- backward trains (read up columns).
# <in> chapter -- section heading text.
# <in> sectionTOP -- LaTeX code for top of section (optional).
# [index] MakeTimeTableOneTable!procedure

  global MakeTimeTableStatus Trains


  if {[llength $backwardTrains] == 0} {
    MakeTimeTableOneTableStationsLeft $tfp $forwardTrains "$chapter" "$sectionTOP"
  } else {
    MakeTimeTableOneTableStationsCenter $tfp \
	$forwardTrains $backwardTrains "$chapter" "$sectionTOP"
  }
}

proc MakeTimeTableOneTableStationsLeft {tfp trains chapter {sectionTOP {}}} {
# Procedure to make a single timetable, with all monodirectional trains.
# <in> tfp -- channel to LaTeX file.
# <in> trains -- sorted list of all trains.
# <in> chapter -- section heading text.
# <in> sectionTOP -- LaTeX code for top of section (optional).
# [index] MakeTimeTableOneTableStationsLeft!procedure

  global MakeTimeTableStatus Trains Stations HasCabP

  puts $tfp {\clearpage}
  puts $tfp "\\section*\{$chapter\}"
  if {$MakeTimeTableStatus(TOCP)} {
    puts $tfp "\\addcontentsline\{toc\}\{section\}\{$chapter\}"
    foreach tr $trains {
      puts $tfp "\\addcontentsline\{toc\}\{subsection\}\{\\protect\\numberline\{$tr\}[lindex [lindex $Trains($tr) 0] 0]\}"
    }
  }      

  if {[string length "$sectionTOP"] > 0} {
    puts $tfp "$sectionTOP"
  } else {
    puts $tfp {%}
    puts $tfp "% Insert prefix info for $chapter here"
    puts $tfp {%}
  }

  set nTrains [llength $trains]
  puts -nonewline $tfp "\n\\begin\{supertabular\}\{|r|p\{\\stationwidth\}|"
  for {set t 0} {$t < $nTrains} {incr t} {
    puts -nonewline $tfp {r|}
  }
  
  puts $tfp "\}"

  puts $tfp "\\hline"
  puts -nonewline $tfp "&\\parbox\{\\timecolumnwidth\}\{Train number:\\\\name:\\\\class:\}"
  foreach tr $trains {
    set name "[lindex [lindex $Trains($tr) 0] 0]"
    set class "[lindex [lindex $Trains($tr) 0] 2]"
    puts -nonewline $tfp "&\\parbox\{\\timecolumnwidth\}\{$tr\\\\$name\\\\$class\}"
  }
  puts $tfp {\\}
  puts -nonewline $tfp "&Notes:"
  foreach tr $trains {
    set notes "[lindex [lindex $Trains($tr) 0] 3]"
    puts -nonewline $tfp "&\\parbox\{\\timecolumnwidth\}\{$notes\}"
  }
  puts $tfp {\\}
  puts $tfp "\\hline"
  puts $tfp "Mile&Station &\\multicolumn\{$nTrains\}\{|c|\}\{$MakeTimeTableStatus(DirectionName) (Read Down)\}\\\\"
  puts $tfp "\\hline"
  foreach station [lsort -command StationDistanceComp [array names Stations]] {
    set mile $Stations($station)
    puts -nonewline $tfp "&\\parbox\[t\]\{\\stationwidthonear\}\{$station\}\\hfill AR"
    foreach tr $trains {
      puts -nonewline $tfp "&"
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set ar [lindex $trst 0]
	  if {[llength $ar] == 1} {
	    puts -nonewline $tfp "\\shtime\{[expr int($ar+.5)]\}"
	  } elseif {[string compar "[lindex $ar 1]" {N/A}] != 0} {
	    puts -nonewline $tfp "Tr\\# [lindex $ar 1]"
	  }
	}
      }
    }
    puts $tfp {\\}
    puts -nonewline $tfp "[expr int($mile+.5)]&"
    foreach tr $trains {
      puts -nonewline $tfp "&"
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set no [lindex $trst 4]
	  if {$HasCabP} {
	    set no "[lindex $trst 3]\\\\$no"
	  }
	  puts -nonewline $tfp "\\parbox\{\\timecolumnwidth\}\{$no\}"
	}
      }
    }
    puts $tfp {\\}
    puts -nonewline $tfp "&\\hfill LV"
    foreach tr $trains {
      puts -nonewline $tfp "&"
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set dp [lindex $trst 2]
	  if {[llength $dp] == 1} {
	    puts -nonewline $tfp "\\shtime\{[expr int($dp+.5)]\}"
	  } elseif {[string compare "[lindex $dp 1]" {N/A}] != 0} {
	    puts -nonewline $tfp "Tr\\# [lindex $dp 1]"
	  }
	}
      }
    }
    puts $tfp {\\}
    puts $tfp {\hline}
  }
  puts $tfp {\end{supertabular}}
  puts $tfp {}
  puts $tfp {\vfill}
  puts $tfp {}
}

proc MakeTimeTableOneTableStationsCenter {tfp fortrains backtrains chapter {sectionTOP {}}} {
# Procedure to make a single timetable, with trains in both directions.
# <in> tfp -- channel to LaTeX file.
# <in> fortrains -- forward trains (read down columns).
# <in> backtrains -- backward trains (read up columns).
# <in> chapter -- section heading text.
# <in> sectionTOP -- LaTeX code for top of section (optional).
# [index] MakeTimeTableOneTableStationsCenter!procedure

  global MakeTimeTableStatus Trains Stations HasCabP

  puts $tfp "\\section*\{$chapter\}"
  if {$MakeTimeTableStatus(TOCP)} {
    puts $tfp "\\addcontentsline\{toc\}\{section\}\{$chapter\}"
    foreach tr [concat $fortrains $backtrains] {
      puts $tfp "\\addcontentsline\{toc\}\{subsection\}\{\\protect\\numberline\{$tr\}[lindex [lindex $Trains($tr) 0] 0]\}"
    }
  }      

  if {[string length "$sectionTOP"] > 0} {
    puts $tfp "$sectionTOP"
  } else {
    puts $tfp {%}
    puts $tfp "% Insert prefix info for $chapter here"
    puts $tfp {%}
  }

  set nFTrains [llength $fortrains]
  set nBTrains [llength $backtrains]
  puts -nonewline $tfp "\n\\begin\{supertabular\}\{|"
  for {set t 0} {$t < $nFTrains} {incr t} {
    puts -nonewline $tfp {r|}
  }
  puts -nonewline $tfp "r|p\{\\stationwidth\}|"
  for {set t 0} {$t < $nBTrains} {incr t} {
    puts -nonewline $tfp {r|}
  }

  puts $tfp "\}"

  puts $tfp "\\hline"
  foreach tr $fortrains {
    set name "[lindex [lindex $Trains($tr) 0] 0]"
    set class "[lindex [lindex $Trains($tr) 0] 2]"
    puts -nonewline $tfp "\\parbox\{\\timecolumnwidth\}\{$tr\\\\$name\\\\$class\}&"
  }

  puts -nonewline $tfp "&\\parbox\{\\timecolumnwidth\}\{Train number:\\\\name\\\\class:\}"
  foreach tr $backtrains {
    set name "[lindex [lindex $Trains($tr) 0] 0]"
    set class "[lindex [lindex $Trains($tr) 0] 2]"
    puts -nonewline $tfp "&\\parbox\{\\timecolumnwidth\}\{$tr\\\\$name\\\\$class\}"
  }

  puts $tfp {\\}
  foreach tr $fortrains {
    set notes "[lindex [lindex $Trains($tr) 0] 3]"
    puts -nonewline $tfp "\\parbox\{\\timecolumnwidth\}\{$notes\}&"
  }
  puts -nonewline $tfp "&Notes:"
  foreach tr $backtrains {
    set notes "[lindex [lindex $Trains($tr) 0] 3]"
    puts -nonewline $tfp "&\\parbox\{\\timecolumnwidth\}\{$notes\}"
  }
  puts $tfp {\\}
  switch -exact -- $MakeTimeTableStatus(DirectionName) {
    Northbound {set rev Southbound}
    Eastbound {set rev Westbound}
    Southbound {set rev Northbound}
    Westbound {set rev Eastbound}
  }
  puts $tfp "\\hline"
  puts $tfp "\\multicolumn\{$nFTrains\}\{|c|\}\{$MakeTimeTableStatus(DirectionName) (Read Down\}&Mile&Station &\\multicolumn\{$nBTrains\}\{|c|\}\{$rev (Read Up)\}\\\\"
  puts $tfp "\\hline"
  foreach station [lsort -command StationDistanceComp [array names Stations]] {
    set mile $Stations($station)
    foreach tr $fortrains {
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set ar [lindex $trst 0]
	  if {[llength $ar] == 1} {
	    puts -nonewline $tfp "\\shtime\{[expr int($ar+.5)]\}"
	  } elseif {[string compar "[lindex $ar 1]" {N/A}] != 0} {
	    puts -nonewline $tfp "Tr\\# [lindex $ar 1]"
	  }
	}
      }
      puts -nonewline $tfp "&"
    }
    puts -nonewline $tfp "&AR\\hfill \\parbox\[t\]\{\\stationwidthtwoar\}\{$station\}\\hfill AR"
    foreach tr $backtrains {
      puts -nonewline $tfp "&"
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set ar [lindex $trst 0]
	  if {[llength $ar] == 1} {
	    puts -nonewline $tfp "\\shtime\{[expr int($ar+.5)]\}"
	  } elseif {[string compar "[lindex $ar 1]" {N/A}] != 0} {
	    puts -nonewline $tfp "Tr\\# [lindex $ar 1]"
	  }
	}
      }
    }
    puts $tfp {\\}
    foreach tr $fortrains {
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set no [lindex $trst 4]
	  if {$HasCabP} {
	    set no "[lindex $trst 3]\\\\$no"
	  }
	  puts -nonewline $tfp "\\parbox\{\\timecolumnwidth\}\{$no\}"
	}
      }
      puts -nonewline $tfp "&"
    }
    puts -nonewline $tfp "[expr int($mile+.5)]&"
    foreach tr $backtrains {
      puts -nonewline $tfp "&"
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set no [lindex $trst 4]
	  if {$HasCabP} {
	    set no "[lindex $trst 3]\\\\$no"
	  }
	  puts -nonewline $tfp "\\parbox\{\\timecolumnwidth\}\{$no\}"
	}
      }
    }
    puts $tfp {\\}
    foreach tr $fortrains {
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set dp [lindex $trst 2]
	  if {[llength $dp] == 1} {
	    puts -nonewline $tfp "\\shtime\{[expr int($dp+.5)]\}"
	  } elseif {[string compare "[lindex $dp 1]" {N/A}] != 0} {
	    puts -nonewline $tfp "Tr\\# [lindex $dp 1]"
	  }
	}
      }
      puts -nonewline $tfp "&"
    }
    puts -nonewline $tfp "&LV\\hfill LV"
    foreach tr $backtrains {
      puts -nonewline $tfp "&"
      foreach trst [lrange $Trains($tr) 1 end] {
	if {[string compare "$station" "[lindex $trst 1]"] == 0} {
	  set dp [lindex $trst 2]
	  if {[llength $dp] == 1} {
	    puts -nonewline $tfp "\\shtime\{[expr int($dp+.5)]\}"
	  } elseif {[string compare "[lindex $dp 1]" {N/A}] != 0} {
	    puts -nonewline $tfp "Tr\\# [lindex $dp 1]"
	  }
	}
      }
    }
    puts $tfp {\\}
    puts $tfp {\hline}

  }
  puts $tfp {\end{supertabular}}
  puts $tfp {}
  puts $tfp {\vfill}
  puts $tfp {}
}

proc MakeTimeTableGroupManually {tfp maxTrains allTrains} {
# Procedure to make tables, grouped manually.
# <in> tfp -- channel to LaTeX file.
# <in> maxTrains -- maximum number of trains per schedule.
# <in> allTrains -- sorted list of all trains.
# [index] MakeTimeTableGroupManually!procedure

  global Trains MakeTimeTableStatus 
  set MakeTimeTableStatus(count) 0
  
# .manuallyGroup
# The above line makes pasting MUCH easier for me.
# It contains the pathname of the cutted widget.
# Tcl version: 8.0 (Tcl/Tk/XF)
# Tk version: 8.0
# XF version: 4.0
#

  # build widget .manuallyGroup
  if {"[info procs XFEdit]" != ""} {
    catch "XFDestroy .manuallyGroup"
  } {
    catch "destroy .manuallyGroup"
  }
  toplevel .manuallyGroup 

  # Window manager configurations
  wm positionfrom .manuallyGroup ""
  wm sizefrom .manuallyGroup ""
  wm maxsize .manuallyGroup 1009 738
  wm minsize .manuallyGroup 1 1
  wm protocol .manuallyGroup WM_DELETE_WINDOW {.baseMakeTimeTableInfo.buttons.button5 invoke}
  wm title .manuallyGroup {Manually Group Trains}
  wm transient .manuallyGroup .


  # build widget .manuallyGroup.banner
  frame .manuallyGroup.banner \
    -borderwidth {2}

  # build widget .manuallyGroup.banner.label27
  label .manuallyGroup.banner.label27 \
    -image {banner}

  # build widget .manuallyGroup.banner.label28
  label .manuallyGroup.banner.label28 \
    -anchor {w} \
    -font {Helvetica -24 bold} \
    -text {Step 3: Manually select groups of trains}

  # build widget .manuallyGroup.info
  frame .manuallyGroup.info \
    -borderwidth {4} \
    -relief {ridge}

  # build widget .manuallyGroup.info.lists
  frame .manuallyGroup.info.lists \
    -borderwidth {2}

  # build widget .manuallyGroup.info.lists.source
  frame .manuallyGroup.info.lists.source

  # build widget .manuallyGroup.info.lists.source.scrollbar3
  scrollbar .manuallyGroup.info.lists.source.scrollbar3 \
    -command {.manuallyGroup.info.lists.source.list xview} \
    -orient {horizontal} \
    -relief {raised}

  # build widget .manuallyGroup.info.lists.source.scrollbar2
  scrollbar .manuallyGroup.info.lists.source.scrollbar2 \
    -command {.manuallyGroup.info.lists.source.list yview} \
    -relief {raised}

  # build widget .manuallyGroup.info.lists.source.list
  listbox .manuallyGroup.info.lists.source.list \
    -relief {raised} \
    -selectmode extended \
    -xscrollcommand {.manuallyGroup.info.lists.source.scrollbar3 set} \
    -yscrollcommand {.manuallyGroup.info.lists.source.scrollbar2 set}
  foreach tr $allTrains {.manuallyGroup.info.lists.source.list insert end $tr}

  # build widget .manuallyGroup.info.lists.dest
  frame .manuallyGroup.info.lists.dest

  # build widget .manuallyGroup.info.lists.dest.scrollbar3
  scrollbar .manuallyGroup.info.lists.dest.scrollbar3 \
    -command {.manuallyGroup.info.lists.dest.list xview} \
    -orient {horizontal} \
    -relief {raised}

  # build widget .manuallyGroup.info.lists.dest.scrollbar2
  scrollbar .manuallyGroup.info.lists.dest.scrollbar2 \
    -command {.manuallyGroup.info.lists.dest.list yview} \
    -relief {raised}

  # build widget .manuallyGroup.info.lists.dest.list
  listbox .manuallyGroup.info.lists.dest.list \
    -relief {raised} \
    -selectmode extended \
    -xscrollcommand {.manuallyGroup.info.lists.dest.scrollbar3 set} \
    -yscrollcommand {.manuallyGroup.info.lists.dest.scrollbar2 set}

  # build widget .manuallyGroup.info.lists.button21
  button .manuallyGroup.info.lists.button21 \
    -font {Helvetica -24 bold} \
    -padx {9} \
    -pady {3} \
    -text {=>} \
    -command {MoveLBElements .manuallyGroup.info.lists.source.list .manuallyGroup.info.lists.dest.list}

  # build widget .manuallyGroup.info.lists.button22
  button .manuallyGroup.info.lists.button22 \
    -font {Helvetica -24 bold} \
    -padx {9} \
    -pady {3} \
    -text {<=} \
    -command {MoveLBElements .manuallyGroup.info.lists.dest.list .manuallyGroup.info.lists.source.list}

  # build widget .manuallyGroup.info.group
  frame .manuallyGroup.info.group \
    -borderwidth {2}

  # build widget .manuallyGroup.info.group.label23
  label .manuallyGroup.info.group.label23 \
    -text {Group Name:}

  # build widget .manuallyGroup.info.group.entry24
  entry .manuallyGroup.info.group.entry24 \
    -textvariable {MakeTimeTableStatus(GroupName)}
  bind .manuallyGroup.info.group.entry24 <Return> {.manuallyGroup.info.group.button25 invoke}

  # build widget .manuallyGroup.info.group.button25
  button .manuallyGroup.info.group.button25 \
    -padx {9} \
    -pady {3} \
    -text {Make Table} \
    -command "MakeTableFromList $tfp $maxTrains .manuallyGroup.info.lists.dest.list"

  # build widget .manuallyGroup.info.labels
  label .manuallyGroup.info.labels \
    -text {LaTeX code to insert before table:} \
    -anchor w

  # build widget .manuallyGroup.info.sectionTOP
  frame .manuallyGroup.info.sectionTOP \
    -relief {flat} 

  # build widget .manuallyGroup.info.sectionTOP.scrollbar1
  scrollbar .manuallyGroup.info.sectionTOP.scrollbar1 \
    -command {.manuallyGroup.info.sectionTOP.text yview} \
    -relief {sunken}

  # build widget .manuallyGroup.info.sectionTOP.text
  text .manuallyGroup.info.sectionTOP.text \
    -height {8} \
    -wrap {word} \
    -yscrollcommand {.manuallyGroup.info.sectionTOP.scrollbar1 set}

  # build widget .manuallyGroup.buttons
  frame .manuallyGroup.buttons \
    -borderwidth {2}

  # build widget .manuallyGroup.buttons.button5
  button .manuallyGroup.buttons.button5 \
    -padx {9} \
    -pady {3} \
    -text {Cancel} \
    -command {
      global MakeTimeTableStatus
      set MakeTimeTableStatus(Button) 0
    }

  # build widget .manuallyGroup.buttons.button6
  button .manuallyGroup.buttons.button6 \
    -padx {9} \
    -pady {3} \
    -text {Next} \
    -command {
      global MakeTimeTableStatus
      set MakeTimeTableStatus(Button) 1
    }

  # pack master .manuallyGroup.banner
  pack configure .manuallyGroup.banner.label27 \
    -side left
  pack configure .manuallyGroup.banner.label28 \
    -anchor w \
    -expand 1 \
    -fill x \
    -side right

  # pack master .manuallyGroup.info
  pack configure .manuallyGroup.info.lists \
    -expand 1 \
    -fill both
  pack configure .manuallyGroup.info.group \
    -fill x
  pack configure .manuallyGroup.info.labels \
    -expand 1 \
    -fill x
  pack configure .manuallyGroup.info.sectionTOP \
    -fill x

  # pack master .manuallyGroup.info.lists
  pack configure .manuallyGroup.info.lists.source \
    -expand 1 \
    -fill both \
    -side left
  pack configure .manuallyGroup.info.lists.dest \
    -expand 1 \
    -fill both \
    -side right
  pack configure .manuallyGroup.info.lists.button22 \
    -fill y \
    -side left
  pack configure .manuallyGroup.info.lists.button21 \
    -fill y \
    -side left

  # pack master .manuallyGroup.info.lists.source
  pack configure .manuallyGroup.info.lists.source.scrollbar2 \
    -fill y \
    -side right
  pack configure .manuallyGroup.info.lists.source.list \
    -expand 1 \
    -fill both
  pack configure .manuallyGroup.info.lists.source.scrollbar3 \
    -fill x \
    -side bottom

  # pack master .manuallyGroup.info.lists.dest
  pack configure .manuallyGroup.info.lists.dest.scrollbar2 \
    -fill y \
    -side right
  pack configure .manuallyGroup.info.lists.dest.list \
    -expand 1 \
    -fill both
  pack configure .manuallyGroup.info.lists.dest.scrollbar3 \
    -fill x \
    -side bottom

  # pack master .manuallyGroup.info.sectionTOP
  pack configure .manuallyGroup.info.sectionTOP.scrollbar1 \
    -fill y \
    -side right
  pack configure .manuallyGroup.info.sectionTOP.text \
    -expand 1 \
    -fill both

  # pack master .manuallyGroup.info.group
  pack configure .manuallyGroup.info.group.label23 \
    -side left
  pack configure .manuallyGroup.info.group.entry24 \
    -expand 1 \
    -fill x \
    -side left
  pack configure .manuallyGroup.info.group.button25 \
    -side right

  # pack master .manuallyGroup.buttons
  pack configure .manuallyGroup.buttons.button5 \
    -side left
  pack configure .manuallyGroup.buttons.button6 \
    -side right

  # pack master .manuallyGroup
  pack configure .manuallyGroup.banner \
    -fill x
  pack configure .manuallyGroup.info \
    -expand 1 \
    -fill both
  pack configure .manuallyGroup.buttons \
    -fill x
# end of widget tree

  set w .manuallyGroup
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
	    - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
	    - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify $w
    
  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {$oldGrab != ""} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  global MakeTimeTableStatus
  set MakeTimeTableStatus(Button) -1
  tkwait variable MakeTimeTableStatus(Button)

  catch {focus $oldFocus}
  if {$oldGrab != ""} {
    if {$grabStatus == "global"} {
      grab -global $oldGrab
    } else {
      grab $oldGrab
    }
  }
  catch {destroy .manuallyGroup}
  catch {unset MakeTimeTableStatus(count)}
  catch {unset MakeTimeTableStatus(GroupName)}
  return $MakeTimeTableStatus(Button)

}

proc MakeTableFromList {tfp maxTrains listbox} {
# Procedure to make a single timetable from trains collected from a listbox.
# <in> tfp -- channel to LaTeX file.
# <in> maxTrains -- maximum number of trains per schedule.
# <in> listbox -- listbox widget containing the trains to include in this table.
# [index] MakeTableFromList!procedure

  global Trains MakeTimeTableStatus Stations

  if {[$listbox size] >= $maxTrains} {
    tk_messageBox -icon warning -type ok -parent .baseMakeTimeTableInfo \
		  -message "Too many trains in group (>= $maxTrains)! Remove some and try again."
    return
  }

  set trainsInGroup [lsort -command TrainComp [$listbox get 0 end]]
  set forwardTrains {}
  set backwardTrains {}
  foreach tr $trainsInGroup {
    if {$Stations([lindex [lindex $Trains($tr) 1] 1]) < $Stations([lindex [lindex $Trains($tr) end] 1])} {
      lappend forwardTrains $tr
    } else {
      lappend backwardTrains $tr
    }
  }

  set sectionTOP "[.manuallyGroup.info.sectionTOP.text get 1.0 end]"

  MakeTimeTableOneTable $tfp $trainsInGroup $forwardTrains $backwardTrains "$MakeTimeTableStatus(GroupName)" "$sectionTOP"
  incr MakeTimeTableStatus(count)
  set class $MakeTimeTableStatus(count)
  set MakeTimeTableStatus(Group,$class,All) $trainsInGroup
  set MakeTimeTableStatus(Group,$class,Forward) $forwardTrains
  set MakeTimeTableStatus(Group,$class,Backward) $backwardTrains
  set MakeTimeTableStatus(Group,$class,ClassHeader) "$MakeTimeTableStatus(GroupName)"
  set MakeTimeTableStatus(Group,$class,SectionTOP) "$sectionTOP"
  $listbox delete 0 end
  if {[.manuallyGroup.info.lists.source.list size] == 0} {
    set MakeTimeTableStatus(Button) 1
  }
  catch "set MakeTimeTableStatus(Group,[expr $class + 1],ClassHeader)" MakeTimeTableStatus(GroupName)
}

proc MoveLBElements {fromLB toLB} {
# Procedure to move selected elements from one listbox to another.
# <in> fromLB -- source listbox wiget.
# <in> toLB -- destination listbox wiget.
# [index] MoveLBElements!procedure

  set selection "[$fromLB curselection]"
  foreach s [lsort -integer -decreasing $selection] {
    $toLB insert end "[$fromLB get $s]"
    $fromLB delete $s
  }
}


proc QuoteNL {s} {
  regsub -all "\n" "$s" "\\n" s
  return "$s"
}

proc UnQuoteNL {s} {
  regsub -all {\\n} "$s" "\n" s
  return "$s"
}

proc LoadTimeTableStatus {{filename {}}} {
# Procedure to load a saved copy of MakeTimeTableStatus.
# <in> filename (optional) -- file name to load from.
# [index] LoadTimeTableStatus!procedure

  global MakeTimeTableStatus MakeTimeTableStatusFileTypes

  if {[string length "$filename"] == 0} {
    set filename "[tk_getOpenFile -defaultextension .ttstatus \
    				  -filetypes $MakeTimeTableStatusFileTypes \
				  -title {Time Table generation parameter file}]"
  }
  if {[string length "$filename"] == 0} {return}

  if {[catch [list open "$filename" r] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening Time Table generation parameter file $filename for input: $sfp" \
		  -type ok
    return
  }

  while {[gets $sfp Line] >= 0} {
    if {[llength $Line] == 2} {
      set MakeTimeTableStatus([lindex $Line 0]) "[UnQuoteNL [lindex $Line 1]]"
    }
  }
  close $sfp
}

proc SaveTimeTableStatus {{filename {}}} {
# Procedure to save a copy of MakeTimeTableStatus.
# <in> filename (optional) -- file name to save to.
# [index] SaveTimeTableStatus!procedure

  global MakeTimeTableStatus MakeTimeTableStatusFileTypes

  if {[string length "$filename"] == 0} {
    set filename "[tk_getSaveFile -defaultextension .ttstatus \
    				  -filetypes $MakeTimeTableStatusFileTypes \
				  -title {Time Table generation parameter file}]"
  }
  if {[string length "$filename"] == 0} {return}

  if {[catch [list open "$filename" w] sfp]} {
    tk_messageBox -icon error \
		  -message "Error opening Time Table generation parameter file $filename for outfile: $sfp" \
		  -type ok
    return
  }

  foreach k [array names MakeTimeTableStatus] {
    puts $sfp [list "$k" [QuoteNL "$MakeTimeTableStatus($k)"]]
  }
  close $sfp
}


