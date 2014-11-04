#* 
#* ------------------------------------------------------------------
#* LocoPull.tcl - LocoPull -- Loco pull calculator
#* Created by Robert Heller on Sat Feb 27 09:42:54 2010
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

## @defgroup LocoPull LocoPull
# @brief Calculate locomotive pulling capacity
#
# @section SYNOPSIS
# LocoPull [X11 Resource Options]
#
# @section DESCRIPTION
# The LocoPull Calculator program aids in calculating how many cars a model
# locomotive consist (one or more powered model locomotives) can pull under
# various track conditions, including level straight track, up grades and/or
# curves.  Based on <mumble>
#
# @section PARAMETERS
# None.
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]]  LocoPull]


# Load required packages
package require gettext
package require Tk
package require HTMLHelp 2.0
package require snitStdMenuBar
package require LabelFrames
package require MainFrame
package require Version

# Set Help directory
global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
#puts stderr "*** HelpDir = $HelpDir"
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
#puts stderr "*** msgfiles = $msgfiles"

namespace eval LocoPull {

  snit::widget LocoPullCalculator {

    component scale
    variable  thescale N
    typevariable ScaleTranslationTable -array {
      N 160.0
      H0 87.0
    }
    component locoInfo
    component   muCount
    variable    themuCount 1
    component   locoWeight
    variable	thelocoWeight 3.0
    component   adhesionFactor
    variable	theadhesionFactor 25
    component   tractiveEffortPerUnit
    variable    thetractiveEffortPerUnit 0
    component   netTractiveEffort
    variable    thenetTractiveEffort 0
    component consitInfo
    component   averageCarWeight
    variable    theaverageCarWeight 4
    component   averageRFactor
    variable	theaverageRFactor 4
    component   averageRollingResistanceOz
    variable    theaverageRollingResistanceOz 0
    component zeroGradeCapacity
    variable thezeroGradeCapacity 0
    component gradeInfo
    component   grade
    variable	thegrade 0
    component   addedResistancePerCarAtGrade
    variable	theaddedResistancePerCarAtGrade 0
    component   netResistancePerCar
    variable	thenetResistancePerCar 0
    component   addedResistancePerUnit
    variable    theaddedResistancePerUnit 0
    component curveInfo
    component   radius
    variable	theradius 0
    component   resistanceFactorPerDegree
    variable	theresistanceFactorPerDegree .04
    component   degreeCuravature
    variable	thedegreeCuravature 0
    component capacityAtGradeAndCurve
    variable thecapacityAtGradeAndCurve 0
    component calculateButton
    typevariable LabelWidth 30

    constructor {args} {
      install scale using ::LabelComboBox $win.scale \
        -label [_m "Label|Scale:"] -labelwidth $LabelWidth \
	-values [lsort -dictionary [array names ScaleTranslationTable]] \
	-editable no -textvariable [myvar thescale]
      pack $scale -fill x
      $scale set [lindex [$scale cget -values] 0]
      install locoInfo using ttk::labelframe $win.locoInfo \
				-text [_ "Locomotive Information"] -labelanchor nw
      pack $locoInfo -fill x
      set frame $locoInfo
      install muCount using ::LabelSpinBox $frame.muCount \
		-label [_m "Label|MU Count:"] -labelwidth $LabelWidth \
		-range {1 5 1} -textvariable [myvar themuCount]
      pack $muCount -fill x
      install locoWeight using ::LabelSpinBox $frame.locoWeight \
		-label [_m "Label|Locomotive weight (Oz.):"] -labelwidth $LabelWidth \
		-range {1 20 .1} \
		-textvariable [myvar thelocoWeight]
      pack $locoWeight -fill x
      install adhesionFactor using ::LabelSpinBox \
		$frame.adhesionFactor \
		-label [_m "Label|Adhesion factor (%):"] -labelwidth $LabelWidth \
		-range {1 100 1}  \
		-textvariable [myvar theadhesionFactor]
      pack $adhesionFactor -fill x
      install tractiveEffortPerUnit using ::LabelEntry \
		$frame.tractiveEffortPerUnit \
		-label [_m "Label|Tractive Effort Per Unit (Oz.):"] \
		-labelwidth $LabelWidth \
		-editable no \
		-textvariable [myvar thetractiveEffortPerUnit]
      pack $tractiveEffortPerUnit -fill x
      install netTractiveEffort using ::LabelEntry \
		$frame.netTractiveEffort \
		-label [_m "Label|Net Tractive Effort (Oz.):"] -labelwidth $LabelWidth \
		-editable no \
		-textvariable [myvar thenetTractiveEffort]
      pack $netTractiveEffort -fill x
      install consitInfo using ttk::labelframe $win.consitInfo \
				-text [_ "Consist Information"] -labelanchor nw
      pack $consitInfo -fill x
      set frame $consitInfo
      install averageCarWeight using LabelSpinBox $frame.averageCarWeight \
				-label [_m "Label|Average Car Weight (Oz.)"] \
				-labelwidth $LabelWidth \
				-range {.5 10 .5} \
				-textvariable [myvar theaverageCarWeight]
      pack $averageCarWeight -fill x
      install averageRFactor using LabelSpinBox \
				$frame.averageRFactor \
				-label [_m "Label|Average Resistance Factor (%):"] \
				-labelwidth $LabelWidth \
				-range {1 100 1} \
				-textvariable [myvar theaverageRFactor]
      pack $averageRFactor -fill x
      install averageRollingResistanceOz using LabelEntry \
				$frame.averageRollingResistanceOz \
				-label [_m "Label|Average Car Rolling Resistance (Oz.):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar theaverageRollingResistanceOz]
      pack $averageRollingResistanceOz -fill x
      install zeroGradeCapacity using LabelEntry $win.zeroGradeCapacity \
				-label [_m "Label|Zero-grade Capacity (cars):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar thezeroGradeCapacity]
      pack $zeroGradeCapacity -fill x
      install gradeInfo using ttk::labelframe $win.gradeInfo \
				-text [_ "Grade Information"] -labelanchor nw
      pack $gradeInfo -fill x
      set frame $gradeInfo
      install grade using LabelSpinBox $frame.grade \
			-label [_m "Label|Grade (%):"]  -labelwidth $LabelWidth \
			-range {1 100 1} \
			-textvariable [myvar thegrade]
      pack $grade -fill x
      install addedResistancePerCarAtGrade using LabelEntry \
				$frame.addedResistancePerCarAtGrade \
				-label [_m "Label|Added R/car at grade (Oz./car):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar theaddedResistancePerCarAtGrade]
      pack $addedResistancePerCarAtGrade -fill x
      install netResistancePerCar using LabelEntry \
				$frame.netResistancePerCar \
				-label [_m "Label|Net R/car at grade (Oz./car):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar thenetResistancePerCar]
      pack $netResistancePerCar -fill x
      install addedResistancePerUnit using LabelEntry \
				$frame.addedResistancePerUnit \
				-label [_m "Label|Added R/Unit at grade (Oz./unit):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar theaddedResistancePerUnit]
      pack $addedResistancePerUnit -fill x
      install curveInfo using ttk::labelframe $win.curveInfo \
				-text [_ "Curve Information"] -labelanchor nw
      pack $curveInfo -fill x
      set frame $curveInfo
      install radius using LabelSpinBox $frame.radius \
				-label [_m "Label|Radius (in):"] -labelwidth $LabelWidth \
				-range {6 48 2} -textvariable [myvar theradius]
      pack $radius -fill x
      install resistanceFactorPerDegree using LabelSpinBox \
			$frame.resistanceFactorPerDegree \
			-label [_m "Label|RR per degree (%):"]  -labelwidth $LabelWidth \
			-range {1 100 1} \
			-textvariable [myvar theresistanceFactorPerDegree]
      pack $resistanceFactorPerDegree -fill x
      install degreeCuravature using  LabelEntry \
				$frame.degreeCuravature \
				-label [_m "Label|Degree of Curvature (deg):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar thedegreeCuravature]
      pack $degreeCuravature -fill x
      install capacityAtGradeAndCurve using LabelEntry \
				$win.capacityAtGradeAndCurve \
				-label [_m "Label|Capacity @ Grade+Curve (cars):"] \
				-labelwidth $LabelWidth \
				-editable no \
				-textvariable [myvar thecapacityAtGradeAndCurve]
      pack $capacityAtGradeAndCurve -fill x
      install calculateButton using ttk::button $win.calculateButton \
				-text [_m "Button|Calculate"] \
				-command [mymethod calculate]
      pack $calculateButton -fill x
      #$self configurelist $args
      $self reset
      $self calculate
    }

    method reset {} {
      set thescale N
      set themuCount 1
      set thelocoWeight 3.0
      set theadhesionFactor 25
      set theaverageCarWeight 4
      set theaverageRFactor 4
      set thegrade 0
      set theradius 0
      set theresistanceFactorPerDegree 0.04
    }
    method saveas {{filename {}}} {
    }
    method calculate {} {
      set thetractiveEffortPerUnit [expr {$thelocoWeight * \
					  ($theadhesionFactor / 100.0)}]
      set thenetTractiveEffort [expr {$themuCount * $thetractiveEffortPerUnit}]
      set theaverageRollingResistanceOz [expr {$theaverageCarWeight * \
					($theaverageRFactor/100.0)}]
      set thezeroGradeCapacity [expr {int(floor($thenetTractiveEffort / \
					    double($theaverageRollingResistanceOz)))}]
      set theaddedResistancePerCarAtGrade [expr {$theaverageCarWeight * ($thegrade/100.0)}]
      set thenetResistancePerCar [expr {$theaddedResistancePerCarAtGrade + $theaverageRollingResistanceOz}]
      set theaddedResistancePerUnit [expr {($thegrade/100.0) * $thelocoWeight}]
      if {$theradius == 0} {
	set thedegreeCuravature 0
      } else {
	set thedegreeCuravature [expr {5730.0 / \
					($theradius * \
					 $ScaleTranslationTable($thescale) / \
					 12.0)}]
      }
      set gradePercent [expr {$thegrade / 100.0}]
      set rollingResistanceFactorPerDegree \
				[expr {$theresistanceFactorPerDegree / 100.0}]
      set thecapacityAtGradeAndCurve \
	[expr {int(floor(($thenetTractiveEffort-$themuCount*$thelocoWeight*\
				($gradePercent+\
				 $rollingResistanceFactorPerDegree*\
				 $thedegreeCuravature))/
		         ($theaverageRollingResistanceOz+\
			  $theaverageCarWeight*\
			  ($gradePercent+\
			   $rollingResistanceFactorPerDegree*\
			   $thedegreeCuravature))\
	))}]
      
    }

  }

  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1265 994
  wm minsize . 1 1
  wm protocol . WM_DELETE_WINDOW {LocoPull::CareFulExit}
  wm title . [_ "Calculate Locomotive Pull Capacity"]

  variable Main
  variable Calculator

  # Create menubar
  set menubar [StdMenuBar MakeMenu \
	-file [list [_m "Menu|&File"] {file} {file} 0 [list \
	     [list command [_m "Menu|File|&New"] {file:new} [_ "Reset Values"]  {Ctrl n} -command {$LocoPull::Calculator reset}] \
	     [list command [_m "Menu|File|&Open..."] {file:open} "" {} -state disabled] \
	     [list command [_m "Menu|File|Save &As..."] {file:save} [_ "Save Value"] {Ctrl s} -command {$LocoPull::Calculator saveas}] \
	     [list command [_m "Menu|File|&Close"] {file:close} [_ "Close the application"] {Ctrl q} -command {LocoPull::CareFulExit}] \
	     [list command [_m "Menu|File|E&xit"] {file:exit} [_ "Close the application"] {Ctrl q} -command {LocoPull::CareFulExit}] \
	] \
    ] -help [list [_m "Menu|&Help"] {help} {help} 0 [list \
		[list command [_m "Menu|Help|On &Help..."] {help:help} [_ "Help on help"] {} -command "HTMLHelp help Help"] \
		[list command [_m "Menu|Help|On &Version"] {help:version} [_ "Version"] {} -command "HTMLHelp help Version"] \
		[list command [_m "Menu|Help|Warranty"] {help:warranty} [_ "Warranty"] {} -command "HTMLHelp help Warranty"] \
		[list command [_m "Menu|Help|Copying"] {help:copying} [_ "Copying"] {} -command "HTMLHelp help Copying"] \
		[list command [_m "Menu|Help|Reference Manual"] {help:reference} [_ "Reference Manual"] {} -command {HTMLHelp help "LocoPull Program Reference"}] \
	] \
    ]]
  # Create main frame
  wm withdraw .
  set Main [MainFrame .main -menu $menubar]
  pack $Main -expand yes -fill both
  set Calculator [LocoPullCalculator [$Main getframe].calculator]
  pack $Calculator -expand yes -fill both

  HTMLHelp setDefaults "$::HelpDir" "index.html#toc"
}

proc LocoPull::CareFulExit {{answer no}} {
# Procedure to carefully exit.
# <in> answer Default answer.
# [index] CarefulExit!procedure

  if {!$answer} {
    set answer [tk_messageBox -default no -icon question \
				-message [_ "Really Quit?"] \
		-title [_ "Careful Exit"] -type yesno]
  }
  if {$answer} {
    global IsSlave
    #puts stderr "*** CarefulExit: IsSlave = $IsSlave"
    flush stderr
    if {$IsSlave} {
      puts stdout "101 Exit"
      flush stdout
      set ans [gets stdin]
      #puts stderr "*** CarefulExit: ans = '$ans'"
    }
    exit
  }
}

# Process command line options.
global IsSlave
set IsSlave 0
global argcTest
set argcTest 0
global argc argv argv0

for {set ia 0} {$ia < $argc} {incr ia} {
  switch -glob -- "[lindex $argv $ia]" {
    -isslave* {
      set IsSlave 1
      incr argcTest
      fconfigure stdin -buffering line
      fconfigure stdout -buffering line
    }
    default {
      puts stderr "usage: $argv0 \[wish options\]"
      exit 96
    }
  }
}


global IsSlave
if {!$IsSlave} {
  set w .
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
            - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
            - [winfo vrooty $w]}]
  wm geom $w +$x+$y
}

update idle
set minwidth [winfo reqwidth .]
set minheight [winfo reqheight .]
wm minsize . $minwidth [expr {$minheight + 30}]
wm geometry . =[expr {$minheight + 30}]x$minwidth
wm deiconify .
