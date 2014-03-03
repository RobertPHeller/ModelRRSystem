#* 
#* ------------------------------------------------------------------
#* FCFCreIndustries.tcl - Create Industries file
#* Created by Robert Heller on Fri Nov 16 15:08:01 2007
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.1  2007/11/30 13:56:51  heller
#* Modification History: Novemeber 30, 2007 lockdown.
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

package require gettext
package require Tk
package require tile
package require LabelFrames
package require ScrollWindow
package require ScrollableFrame


namespace eval FCFCreIndustries {
  variable IndustriesPage
  variable IndustriesPageFR
  variable IndustriesListFR
  variable IndustriesListIndex 1
  variable IsValidated no
  variable Industries 0
  variable IndustryIndexList {}
}

proc FCFCreIndustries::FCFCreIndustries {notebook} {
  variable IndustriesPage [ttk::frame $notebook.industries]
  $notebook insert end $IndustriesPage -text [_m "Tab|Industries File"]
  set IndustriesPageSW [ScrolledWindow $IndustriesPage.sw \
					-auto vertical -scrollbar vertical]
  pack $IndustriesPageSW -expand yes -fill both
  variable IndustriesPageFR [ScrollableFrame $IndustriesPageSW.fr \
							-constrainedwidth yes]
  pack $IndustriesPageFR -expand yes -fill both
  $IndustriesPageSW setwidget $IndustriesPageFR
  set frame [$IndustriesPageFR getframe]

  variable IndustriesListFR [frame $frame.industriesListFR]
  pack $IndustriesListFR -expand yes -fill both
  variable IndustriesListIndex
  grid [ttk::label $IndustriesListFR.numberHead -text [_m "Label|ID  "] -width 4] \
	-row 0 -column 0 -sticky nw
  grid [ttk::label $IndustriesListFR.commaAHead -text {,}] \
	-row 0 -column 1 -sticky nw
  grid [ttk::label $IndustriesListFR.typeHead -text {T}] \
	-row 0 -column 2 -sticky nw
  grid [ttk::label $IndustriesListFR.commaBHead -text {,}] \
	-row 0 -column 3 -sticky nw
  grid [ttk::label $IndustriesListFR.stationHead -text [_m "Label|STA "] -width 4] \
	-row 0 -column 4 -sticky nw
  grid [ttk::label $IndustriesListFR.commaCHead -text {,}] \
	-row 0 -column 5 -sticky nw
  grid [ttk::label $IndustriesListFR.nameHead -text [_m "Label|NAME"]] \
	-row 0 -column 6 -sticky nw
  grid columnconfigure $IndustriesListFR 6 -weight 1
  grid [ttk::label $IndustriesListFR.commaDHead -text {,}] \
	-row 0 -column 7 -sticky nw
  grid [ttk::label $IndustriesListFR.tlenHead -text [_m "Label|TLEN"]] \
	-row 0 -column 8 -sticky nw
  grid [ttk::label $IndustriesListFR.commaEHead -text {,}] \
	-row 0 -column 9 -sticky nw
  grid [ttk::label $IndustriesListFR.alenHead -text [_m "Label|ALEN"]] \
	-row 0 -column 10 -sticky nw
  grid [ttk::label $IndustriesListFR.commaFHead -text {,}] \
	-row 0 -column 11 -sticky nw
  grid [ttk::label $IndustriesListFR.priorityHead -text [_m "Label|P"] -width 1] \
	-row 0 -column 12 -sticky nw
  grid [ttk::label $IndustriesListFR.commaGHead -text {,}] \
	-row 0 -column 13 -sticky nw
  grid [ttk::label $IndustriesListFR.reloadsHead -text [_m "Label|R"] -width 1] \
	-row 0 -column 14 -sticky nw
  grid [ttk::label $IndustriesListFR.commaHHead -text {,}] \
	-row 0 -column 15 -sticky nw
  grid [ttk::label $IndustriesListFR.hazardHead -text [_m "Label|H"] -width 1] \
	-row 0 -column 16 -sticky nw
  grid [ttk::label $IndustriesListFR.commaIHead -text {,}] \
	-row 0 -column 17 -sticky nw
  grid [ttk::label $IndustriesListFR.mirrorHead -text [_m "Label|MIR "] -width 4] \
	-row 0 -column 18 -sticky nw
  grid [ttk::label $IndustriesListFR.commaJHead -text {,}] \
	-row 0 -column 19 -sticky nw
  grid [ttk::label $IndustriesListFR.plateHead -text [_m "Label|C"] -width 1] \
	-row 0 -column 20 -sticky nw
  grid [ttk::label $IndustriesListFR.commaKHead -text {,}] \
	-row 0 -column 21 -sticky nw
  grid [ttk::label $IndustriesListFR.weightHead -text [_m "Label|W"] -width 1] \
	-row 0 -column 22 -sticky nw
  grid [ttk::label $IndustriesListFR.commaLHead -text {,}] \
	-row 0 -column 23 -sticky nw
  grid [ttk::label $IndustriesListFR.dclHead -text [_m "Label|DCL"]] \
	-row 0 -column 24 -sticky nw
  grid [ttk::label $IndustriesListFR.commaMHead -text {,}] \
	-row 0 -column 25 -sticky nw
  grid [ttk::label $IndustriesListFR.maxHead -text [_m "Label|MAX"] -width 4] \
	-row 0 -column 26 -sticky nw
  grid [ttk::label $IndustriesListFR.commaNHead -text {,}] \
	-row 0 -column 27 -sticky nw
  grid [ttk::label $IndustriesListFR.ldHead -text [_m "Label|LD"] -width 4] \
	-row 0 -column 28 -sticky nw
  grid [ttk::label $IndustriesListFR.commaOHead -text {,}] \
	-row 0 -column 29 -sticky nw
  grid [ttk::label $IndustriesListFR.emHead -text [_m "Label|EM"] -width 4] \
	-row 0 -column 30 -sticky nw
  grid [ttk::label $IndustriesListFR.deleteHead -text [_m "Label|Delete?"]] \
	-row 0 -column 31 -sticky nw
  # Workbench
  grid [ttk::label $IndustriesListFR.number0 -text {0} -width 4] \
	-row 1 -column 0 -sticky nw
  grid [ttk::label $IndustriesListFR.commaA0 -text {,}] \
	-row 1 -column 1 -sticky nw
  grid [ttk::label $IndustriesListFR.type0 -text {I}] \
	-row 1 -column 2 -sticky nw
  grid [ttk::label $IndustriesListFR.commaB0 -text {,}] \
	-row 1 -column 3 -sticky nw
  grid [ttk::label $IndustriesListFR.station0 -text {1} -width 4] \
	-row 1 -column 4 -sticky nw
  grid [ttk::label $IndustriesListFR.commaC0 -text {,}] \
	-row 1 -column 5 -sticky nw
  grid [ttk::label $IndustriesListFR.name0 -text [_ "REPAIR YARD"]] \
	-row 1 -column 6 -sticky nw
  grid [ttk::label $IndustriesListFR.commaD0 -text {,}] \
	-row 1 -column 7 -sticky nw
  grid [ttk::label $IndustriesListFR.tlen0 -text {0}] \
	-row 1 -column 8 -sticky nw
  grid [ttk::label $IndustriesListFR.commaE0 -text {,}] \
	-row 1 -column 9 -sticky nw
  grid [ttk::label $IndustriesListFR.alen0 -text {0}] \
	-row 1 -column 10 -sticky nw
  grid [ttk::label $IndustriesListFR.commaF0 -text {,}] \
	-row 1 -column 11 -sticky nw
  grid [ttk::label $IndustriesListFR.priority0 -text {9} -width 1] \
	-row 1 -column 12 -sticky nw
  grid [ttk::label $IndustriesListFR.commaG0 -text {,}] \
	-row 1 -column 13 -sticky nw
  grid [ttk::label $IndustriesListFR.reloads0 -text {N} -width 1] \
	-row 1 -column 14 -sticky nw
  grid [ttk::label $IndustriesListFR.commaH0 -text {,}] \
	-row 1 -column 15 -sticky nw
  grid [ttk::label $IndustriesListFR.hazard0 -text {} -width 1] \
	-row 1 -column 16 -sticky nw
  grid [ttk::label $IndustriesListFR.commaI0 -text {,}] \
	-row 1 -column 17 -sticky nw
  grid [ttk::label $IndustriesListFR.mirror0 -text {0} -width 4] \
	-row 1 -column 18 -sticky nw
  grid [ttk::label $IndustriesListFR.commaJ0 -text {,}] \
	-row 1 -column 19 -sticky nw
  grid [ttk::label $IndustriesListFR.plate0 -text {0} -width 1] \
	-row 1 -column 20 -sticky nw
  grid [ttk::label $IndustriesListFR.commaK0 -text {,}] \
	-row 1 -column 21 -sticky nw
  grid [ttk::label $IndustriesListFR.weight0 -text {0} -width 1] \
	-row 1 -column 22 -sticky nw
  grid [ttk::label $IndustriesListFR.commaL0 -text {,}] \
	-row 1 -column 23 -sticky nw
  grid [ttk::label $IndustriesListFR.dcl0 -text {}] \
	-row 1 -column 24 -sticky nw
  grid [ttk::label $IndustriesListFR.commaM0 -text {,}] \
	-row 1 -column 25 -sticky nw
  grid [ttk::label $IndustriesListFR.max0 -text {999} -width 4] \
	-row 1 -column 26 -sticky nw
  grid [ttk::label $IndustriesListFR.commaN0 -text {,}] \
	-row 1 -column 27 -sticky nw
  grid [ttk::label $IndustriesListFR.ld0 -text {} -width 4] \
	-row 1 -column 28 -sticky nw
  grid [ttk::label $IndustriesListFR.commaO0 -text {,}] \
	-row 1 -column 29 -sticky nw
  grid [ttk::label $IndustriesListFR.em0 -text {} -width 4] \
	-row 1 -column 30 -sticky nw
  grid [ttk::label $IndustriesListFR.delete0 -text {}] \
	-row 1 -column 31 -sticky nw
  
  pack [ttk::button $frame.addIndustry \
			-text [_m  "Button|Add Industry"] \
			-command FCFCreIndustries::AddIndustry] \
	-anchor w
}

proc FCFCreIndustries::AddIndustry {} {
  variable IndustriesListFR
  variable IndustriesListIndex
  variable IsValidated no

  set lastrow [lindex [grid size $IndustriesListFR] 1]
  grid [spinbox $IndustriesListFR.number$IndustriesListIndex \
				-from 1 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 0 -sticky nw
  grid [ttk::label $IndustriesListFR.commaA$IndustriesListIndex -text {,}] \
	-row $lastrow -column 1 -sticky nw
  grid [ttk::combobox $IndustriesListFR.type$IndustriesListIndex \
	-values {I O Y} -state readonly -width 1] \
	-row $lastrow -column 2 -sticky nw
  $IndustriesListFR.type$IndustriesListIndex set [lindex [$IndustriesListFR.type$IndustriesListIndex cget -values]  0]
  grid [ttk::label $IndustriesListFR.commaB$IndustriesListIndex -text {,}] \
	-row $lastrow -column 3 -sticky nw
  grid [spinbox $IndustriesListFR.station$IndustriesListIndex \
				-from 0 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 4 -sticky nw
  grid [ttk::label $IndustriesListFR.commaC$IndustriesListIndex -text {,}] \
	-row $lastrow -column 5 -sticky nw
  grid [ttk::entry $IndustriesListFR.name$IndustriesListIndex] \
	-row $lastrow -column 6 -sticky new
  grid [ttk::label $IndustriesListFR.commaD$IndustriesListIndex -text {,}] \
	-row $lastrow -column 7 -sticky nw
  grid [spinbox $IndustriesListFR.tlen$IndustriesListIndex \
				-from 0 -to 999 -increment 1 -width 4] \
	-row $lastrow -column 8 -sticky nw
  grid [ttk::label $IndustriesListFR.commaE$IndustriesListIndex -text {,}] \
	-row $lastrow -column 9 -sticky nw
  grid [spinbox $IndustriesListFR.alen$IndustriesListIndex \
        -from 0 -to 999 -increment 1 -width 4] \
	-row $lastrow -column 10 -sticky nw
  grid [ttk::label $IndustriesListFR.commaF$IndustriesListIndex -text {,}] \
	-row $lastrow -column 11 -sticky nw
  grid [spinbox $IndustriesListFR.priority$IndustriesListIndex \
				-from 1 -to 9 -increment 1 -width 1] \
	-row $lastrow -column 12 -sticky nw
  grid [ttk::label $IndustriesListFR.commaG$IndustriesListIndex -text {,}] \
	-row $lastrow -column 13 -sticky nw
  grid [ttk::combobox $IndustriesListFR.reloads$IndustriesListIndex \
			-values {N Y} -width 1] \
	-row $lastrow -column 14 -sticky nw
  $IndustriesListFR.reloads$IndustriesListIndex set [lindex [$IndustriesListFR.reloads$IndustriesListIndex cget -values] 0]
  grid [ttk::label $IndustriesListFR.commaH$IndustriesListIndex -text {,}] \
	-row $lastrow -column 15 -sticky nw
  grid [ttk::combobox $IndustriesListFR.hazard$IndustriesListIndex \
			-values {{} 1 2 3 4 5 6 7 8 9} -width 1] \
	-row $lastrow -column 16 -sticky nw
  $IndustriesListFR.hazard$IndustriesListIndex set [lindex [$IndustriesListFR.hazard$IndustriesListIndex cget -values] 0]
  grid [ttk::label $IndustriesListFR.commaI$IndustriesListIndex -text {,}] \
	-row $lastrow -column 17 -sticky nw
  grid [spinbox $IndustriesListFR.mirror$IndustriesListIndex \
			-from 0 -to 1000 -increment 1 -width 4] \
	-row $lastrow -column 18 -sticky nw
  grid [ttk::label $IndustriesListFR.commaJ$IndustriesListIndex -text {,}] \
	-row $lastrow -column 19 -sticky nw
  grid [spinbox $IndustriesListFR.plate$IndustriesListIndex \
			-from 1 -to 9 -increment 1 -width 1] \
	-row $lastrow -column 20 -sticky nw
  grid [ttk::label $IndustriesListFR.commaK$IndustriesListIndex -text {,}] \
	-row $lastrow -column 21 -sticky nw
  grid [spinbox $IndustriesListFR.weight$IndustriesListIndex \
			-from 1 -to 9 -increment 1 -width 1] \
	-row $lastrow -column 22 -sticky nw
  grid [ttk::label $IndustriesListFR.commaL$IndustriesListIndex -text {,}] \
	-row $lastrow -column 23 -sticky nw
  grid [ttk::entry $IndustriesListFR.dcl$IndustriesListIndex -width 4] \
	-row $lastrow -column 24 -sticky nw
  grid [ttk::label $IndustriesListFR.commaM$IndustriesListIndex -text {,}] \
	-row $lastrow -column 25 -sticky nw
  grid [spinbox $IndustriesListFR.max$IndustriesListIndex \
			-from 0 -to 999 -increment 10 -width 3] \
	-row $lastrow -column 26 -sticky nw
  grid [ttk::label $IndustriesListFR.commaN$IndustriesListIndex -text {,}] \
	-row $lastrow -column 27 -sticky nw
  grid [ttk::entry $IndustriesListFR.ld$IndustriesListIndex -width 4] \
	-row $lastrow -column 28 -sticky nw
  grid [ttk::label $IndustriesListFR.commaO$IndustriesListIndex -text {,}] \
	-row $lastrow -column 29 -sticky nw
  grid [ttk::entry $IndustriesListFR.em$IndustriesListIndex -width 4] \
	-row $lastrow -column 30 -sticky nw
  grid [ttk::button $IndustriesListFR.delete$IndustriesListIndex \
	-text [_m "Button|Delete"] \
	-command "FCFCreIndustries::DeleteIndustry $IndustriesListIndex"] \
	-row $lastrow -column 31 -sticky nw
  incr IndustriesListIndex
}

proc FCFCreIndustries::DeleteIndustry {index} {
  variable IndustriesListFR
  variable IsValidated no

  if {![winfo exists ${IndustriesListFR}.number$index]} {return}
  foreach f {number commaA type commaB station commaC name commaD tlen commaE 
	     alen commaF priority commaG reloads commaH hazard commaI mirror 
	     commaJ plate commaK weight commaL dcl commaM max commaN ld commaO 
	     em delete} {
    grid forget ${IndustriesListFR}.${f}$index
    destroy ${IndustriesListFR}.${f}$index
  }
}

proc FCFCreIndustries::ResetForm {} {
  variable IndustriesListFR
  variable IndustriesListIndex
  variable IsValidated no

  for {set ind 1} {$ind < $IndustriesListIndex} {incr ind} {
    DeleteIndustry $ind
  }
  set IndustriesListIndex 1
}

proc FCFCreIndustries::ValidateIndustriesFile {} {
  variable IndustriesListFR
  variable IndustriesListIndex
  variable Industries 
  variable IsValidated
  variable IndustryIndexList

  if {$IsValidated} {return yes}
  set invalid 0

  for {set I 1} {$I < $IndustriesListIndex} {incr I} {
    if {![winfo exists ${IndustriesListFR}.number$I]} {continue}
    set ind [${IndustriesListFR}.number$I cget -text]
    set nam "[${IndustriesListFR}.name$I cget -text]"
    set sta [${IndustriesListFR}.station$I cget -text]
    set typ [${IndustriesListFR}.type$I cget -text]
    set dcl [${IndustriesListFR}.dcl$I cget -text]
    set ld  [${IndustriesListFR}.ld$I cget -text]
    set em  [${IndustriesListFR}.em$I cget -text]
    if {$ind < 1} {
      tk_messageBox -type ok -icon error -message [_ "Invalid index (%d < 1) for industry %s!" $ind $nam]
      incr invalid
    }
    if {[lsearch $IndustryIndexList $ind] >= 0} {
      tk_messageBox -type ok -icon error -message [_ "Duplicate index (%d) for industry %s!" $ind $nam]
      incr invalid
    }
    lappend IndustryIndexList $ind
    if {![FCFCreSystem::ValidStation $sta] && $sta != 0} {
      tk_messageBox -type ok -icon error -message [_ "Invalid station (%s) for industry $nam (%d)!" $sta $ind]
      incr invalid
    }
    if {![string equal "$typ" "Y"]} {
      foreach ds [split "$dcl" {}] {
	if {![FCFCreSystem::ValidDivisionSymbol $ds]} {
	  tk_messageBox -type ok -icon error -message [_ "Invalid Division Symbol (%s) for industry %s (%d)!" $ds $nam $ind]
	  incr invalid
	}
      }
    } else {
      foreach ps [split "$dcl" {}] {
	if {[lsearch {A P D} $ps] < 0} {
	  tk_messageBox -type ok -icon error -message [_ "Invalid print symbol (%s) for yard %s (%d)!" $ps $nam $ind]
	  incr invalid
	}
      }
    }
    foreach ct [split "$ld" {}] {
      if {![FCFCreCars::ValidCarType "$ct"]} {
	tk_messageBox -type ok -icon error -message [_ "Invalid car type (%s) for loads at industry %s (%d)!" $ct $nam $ind]
	incr invalid
      }
    }
    foreach ct [split "$em" {}] {
      if {![FCFCreCars::ValidCarType "$ct"]} {
	tk_messageBox -type ok -icon error -message [_ "Invalid car type (%s) for empties at industry %s (%d)!" $ct $nam $ind]
	incr invalid
      }
    }
  }
  set IndustryIndexList [lsort -integer $IndustryIndexList]
  if {[llength $IndustryIndexList] == 0} {
    tk_messageBox -type ok -icon error -message [_ "No real industries or yards!"]
    set IsValidated no
    return false
  }
  set lastInd [lindex $IndustryIndexList end]
  variable Industries [::RoundUp $lastInd 10]
  if {$Industries == $lastInd} {incr Industries 10}
  for {set I 1} {$I < $IndustriesListIndex} {incr I} {
    if {![winfo exists ${IndustriesListFR}.number$I]} {continue}
    set ind [${IndustriesListFR}.number$I cget -text]
    set nam "[${IndustriesListFR}.name$I cget -text]"
    set mir [${IndustriesListFR}.mirror$I cget -text]
    if {$mir > 0} {
      if {[lsearch $IndustryIndexList $mir] < 0} {
	tk_messageBox -type ok -icon error -message [_ "Invalid mirror industry (%d) for industry %s (%d)!" $mir $nam $ind]
	incr invalid
      }
    }
  }
  set IsValidated [expr {$invalid == 0}]  
  return $IsValidated
}

proc FCFCreIndustries::ValidIndustry {ind} {
  variable IndustryIndexList
  variable IsValidated

  if {$ind == 0} {return yes}
  if {!$IsValidated} {
    if {![ValidateIndustriesFile]} {return no}
  }
  if {[lsearch $IndustryIndexList $ind] < 0} {
    return no
  } else {
    return yes
  }
} 


proc FCFCreIndustries::WriteIndustriesFile {directory filename} {
  variable IndustriesListFR
  variable IndustriesListIndex
  variable Industries
  variable IsValidated

  if {!$IsValidated} {
    if {![ValidateIndustriesFile]} {return false}
  }

  if {![file exists "$directory"] || ![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message [_ "$directory does not exist or is not a not a folder!"]
    return false
  }
  set oFileName [file join "$directory" "$filename"]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
    return false
  }
  puts $ofp "Industries = $Industries"

  for {set I 0} {$I < $IndustriesListIndex} {incr I} {
    if {![winfo exists ${IndustriesListFR}.number$I]} {continue}
    puts -nonewline $ofp "[${IndustriesListFR}.number$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.type$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.station$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.name$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.tlen$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.alen$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.priority$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.reloads$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.hazard$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.mirror$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.plate$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.weight$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.dcl$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.max$I cget -text],"
    puts -nonewline $ofp "[${IndustriesListFR}.ld$I cget -text],"
    puts 	    $ofp "[${IndustriesListFR}.em$I cget -text]"
  }
  puts $ofp "-1"
  close $ofp
  return true
}

proc FCFCreIndustries::WriteStats {directory filename} {
  variable IndustriesListFR
  variable IndustriesListIndex
  variable Industries
  variable IsValidated

  if {!$IsValidated} {
    if {![ValidateIndustriesFile]} {return}
  }

  if {![file exists "$directory"] || ![file isdirectory "$directory"]} {
    tk_messageBox -type ok -icon error -message [_ "$directory does not exist or is not a not a folder!"]
    return false
  }
  set oFileName [file join "$directory" "$filename"]
  if {[catch {open "$oFileName" w} ofp]} {
    tk_messageBox -type ok -icon error -message [_ "Could not open %s: %s" $oFileName $ofp]
    return false
  }
  puts $ofp "1,"
  for {set I 1} {$I < $IndustriesListIndex} {incr I} {
    if {![winfo exists ${IndustriesListFR}.number$I]} {continue}
    set sta [${IndustriesListFR}.station$I cget -text]
    if {$sta == 0} {continue}
    puts -nonewline $ofp "[${IndustriesListFR}.number$I cget -text],"
    puts -nonewline $ofp "0,0,"
    puts            $ofp "[${IndustriesListFR}.tlen$I cget -text]"
  }
  close $ofp
  return true  
}


package provide FCFCreIndustries 1.0
