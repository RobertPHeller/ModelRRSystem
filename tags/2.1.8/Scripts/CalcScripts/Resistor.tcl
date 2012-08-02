#!/usr/bin/wish -f
#* 
#* ------------------------------------------------------------------
#* Resistor.tcl - Load resistor calculator
#* Created by Robert Heller on Sat Jan 24 10:37:59 2004
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.3  2007/04/19 17:23:23  heller
#* Modification History: April 19 Lock Down
#* Modification History:
#* Modification History: Revision 1.2  2007/02/01 20:00:53  heller
#* Modification History: Lock down for Release 2.1.7
#* Modification History:
#* Modification History: Revision 1.1  2004/01/24 18:08:59  heller
#* Modification History: Initial Version.
#* Modification History:
#* Modification History: Revision 1.1  2002/07/28 14:03:50  heller
#* Modification History: Add it copyright notice headers
#* Modification History:
#* ------------------------------------------------------------------
#* Contents:
#* ------------------------------------------------------------------
#*  
#*     Model RR System, Version 2
#*     Copyright (C) 1994,1995,2002  Robert Heller D/B/A Deepwoods Software
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

#@Chapter:Resistor.tcl -- Calculate Load Resistors.
#@Label:chapt:Resistor.tcl
#$Id$

set argv0 [file join  [file dirname [info nameofexecutable]] Resistor]

package require Tk
package require BWidget
package require BWHelp
package require BWStdMenuBar

global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
#puts stderr "*** HelpDir = $HelpDir"

namespace eval Resistor {

  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1265 994
  wm minsize . 1 1
  wm protocol . WM_DELETE_WINDOW {CareFulExit}
  wm title . {Calculate Load Resistor Value}

  set menubar [StdMenuBar::MakeMenu \
	-file {"&File" {file} {file} 0 {
	     {command "&New" {file:new} "Reset Values"  {Ctrl n} -command {Resistor::ResetValues}}
	     {command "&Open..." {file:open} "" {} -state disabled}
	     {command "&Save"    {file:save} "Save Value" {Ctrl s} -command {Resistor::WriteOutValue}}
	     {command "Save &As..." {file:save} "Save Value" {Ctrl s} -command {Resistor::WriteOutValue}}
	     {command "&Close" {file:close} "Close the application" {Ctrl q} -command {::CareFulExit}}
	     {command "E&xit" {file:exit} "Close the application" {Ctrl q} -command {::CareFulExit}}
		}
	     }]



  pack [MainFrame::create .main -menu $menubar -textvariable Status] -expand yes -fill both
  .main showstatusbar status

  set frame [.main getframe]
  pack [Label::create $frame.hlabel \
	-font {Helvetica -24 bold} -text {Calculate Load Resistor Value} \
	-anchor c] -expand yes -fill x

  set lw 15
  pack [LabelFrame::create $frame.vSupplyLF -text {Supply Voltage:} -width $lw] \
	-fill x
  variable VSupplyValue [SpinBox::create [$frame.vSupplyLF getframe].volts \
		-range {1.0 48.0 .25}]
  pack $VSupplyValue -side left -expand yes -fill x
  variable VSupplyUnits [ComboBox::create [$frame.vSupplyLF getframe].units \
		-editable no -values {Volts MiliVolts KiloVolts}]
  pack $VSupplyUnits -side right
  $VSupplyUnits setvalue first

  pack [LabelFrame::create $frame.vLoadLF -text {Load Voltage:} -width $lw] \
	-fill x
  variable VLoadValue [SpinBox::create [$frame.vLoadLF getframe].volts \
		-range {1.0 48.0 .25}]
  pack $VLoadValue -side left -expand yes -fill x
  variable VLoadUnits [ComboBox::create [$frame.vLoadLF getframe].units \
		-editable no -values {Volts MiliVolts KiloVolts}]
  pack $VLoadUnits -side right
  $VLoadUnits setvalue first

  pack [LabelFrame::create $frame.iLoadLF -text {Load Current:} -width $lw] \
	-fill x 
  variable ILoadValue [SpinBox::create [$frame.iLoadLF getframe].amps \
		-range {.001 1000.0 .01}]
  pack $ILoadValue -side left -expand yes -fill x
  variable ILoadUnits [ComboBox::create [$frame.iLoadLF getframe].units \
		-editable no -values {Amps MiliAmps KiloAmps}]
  pack $ILoadUnits -side right
  $ILoadUnits setvalue first

  pack [LabelFrame::create $frame.resistorValue \
			-text {Resistor Values:} -width $lw] -fill x
  variable CalcValue [LabelEntry::create [$frame.resistorValue getframe].calcV \
			-label {Calculated:} -editable no -text 0]
  pack $CalcValue -side left -fill x
  variable AvailValue [LabelEntry::create [$frame.resistorValue getframe].availV \
			-label {Available:} -editable no -text 0]
  pack $AvailValue -side left -fill x
	  
  pack [Button::create $frame.calc \
		-text {Calculate} \
		-command {Resistor::CalculateValue}] -fill x


  pack [frame $frame.resistor2 -borderwidth {2}] -fill x
  variable PowerRating [LabelEntry::create $frame.resistor2.pow \
			-label {Minimum Power Rating:} \
			-editable no -text 0]
  pack $PowerRating -side left -fill x
  set lfTemp [LabelFrame::create $frame.resistor2.bands -text {Bands:}]
  pack $lfTemp -side left -fill x
  variable BandDisplay [canvas [$lfTemp getframe].c \
			-borderwidth {2} \
			-relief {sunken} \
			-width 50 -height 15]
  pack $BandDisplay

  $VSupplyValue configure -text 12.0
  $VLoadValue   configure -text  2.0
  $ILoadValue   configure -text   .02


  variable StockValues {
  10 11 12 13 14 15 16 18 20 22 24 27 30 33 36 39 43 47 51
  56 62 68 75 82 91}
  variable StockMinValue 1.0
  variable StockMaxValue 10000000.0
  variable Bands
  array set Bands {
    0 black
    1 brown
    2 red
    3 orange
    4 yellow
    5 green
    6 blue
    7 violet
    8 gray
    9 white
    -1 gold
    -2 silver
  }

  variable Resistor
}

proc CareFulExit {} {
# Procedure to carefully exit.
# [index] CarefulExit!procedure

  if {[string compare \
	[tk_messageBox -default no -icon question -message {Really Quit?} \
		-title {Careful Exit} -type yesno] {yes}] == 0} {
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

proc Resistor::ResetValues {} {

  variable VSupplyValue
  $VSupplyValue configure -text 12.0
  variable VSupplyUnits
  $VSupplyUnits setvalue first
  variable VLoadValue
  $VLoadValue configure -text 2.0
  variable VLoadUnits
  $VLoadUnits setvalue first
  variable ILoadValue
  $ILoadValue configure -text 0.02
  variable ILoadUnits
  $ILoadUnits setvalue first
  CalculateValue

}

proc Resistor::CalculateValue {} {
  variable VSupplyValue
  variable VSupplyUnits
  variable VLoadValue
  variable VLoadUnits
  variable ILoadValue
  variable ILoadUnits
  variable CalcValue
  variable AvailValue
  variable PowerRating
  variable BandDisplay

  set vp "[$VSupplyValue cget -text]"
  if {![string is double "$vp"]} {
    tk_messageBox -type ok -icon error -message "Not a number (Supply Voltage): $vp"
    return
  }
  set lv "[$VLoadValue cget -text]"
  if {![string is double "$lv"]} {
    tk_messageBox -type ok -icon error -message "Not a number (Voltage Across Load): $lv"
    return
  }
  set lc "[$ILoadValue cget -text]"
  if {![string is double "$lc"]} {
    tk_messageBox -type ok -icon error -message "Not a number Load Current Draw): $lc"
    return
  }
  variable Resistor
  switch -exact -- "[$VSupplyUnits cget -text]" {
    Volts {set  Resistor(vPlus) $vp}
    MiliVolts {set Resistor(vPlus) [expr {$vp / 1000.0}]}
    KiloVolts {set Resistor(vPlus) [expr {$vp * 1000.0}]}
  }
  switch -exact -- "[$VLoadUnits cget -text]" {
    Volts {set Resistor(lVolts) $lv}
    MiliVolts {set Resistor(lVolts) [expr {$lv / 1000.0}]}
    KiloVolts {set Resistor(lVolts) [expr {$lv * 1000.0}]}
  }
  switch -exact -- "[$ILoadUnits cget -text]" {
    Amps {set Resistor(lCurrent) $lc}
    MiliAmps {set Resistor(lCurrent) [expr {$lc / 1000.0}]}
    KiloAmps {set Resistor(lCurrent) [expr {$lc * 1000.0}]}
  }
  set Resistor(dropVolts) [expr $Resistor(vPlus) - $Resistor(lVolts)]
  set Resistor(Calculated) [expr $Resistor(dropVolts) / $Resistor(lCurrent)]
  DisplayResistence $CalcValue $Resistor(Calculated)
  set Resistor(Stock) [FindNearestStockValue $Resistor(Calculated)]
  DisplayResistence $AvailValue $Resistor(Stock)
  DisplayBands $BandDisplay $Resistor(Stock)
  set Resistor(Power) [expr $Resistor(dropVolts) * $Resistor(lCurrent)]
  DisplayPower $PowerRating $Resistor(Power)
}

proc Resistor::DisplayResistence {entry value} {
  if {$value < 1000} {
    $entry configure -text "[format {%6.2f  Ohms} $value]"
  } elseif {$value < 1000000} {
    $entry configure -text "[format {%6.2f KOhms} [expr $value / 1000]]"
  } else {
    $entry configure -text "[format {%6.2f MOhms} [expr $value / 1000000]]"
  }
}

proc Resistor::DisplayPower {entry value} {
  if {$value < 1} {
    $entry configure -text "[format {%5.0f mWatts} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    $entry configure -text "[format {%5.2f  Watts} $value]"
  } elseif {$value < 1000000} {
    $entry configure -text "[format {%5.2f KWatts} [expr $value / 1000]]"
  } else {
    $entry configure -text "[format {%5.2f MWatts} [expr $value / 1000000]]"
  }
}

  

proc Resistor::DisplayBands {canvas value} {
  variable Bands
  $canvas delete all

  set mult 0
  while {$value < 10} {
    incr mult -1
    set value [expr $value * 10]
  }
  while {$value > 99} {
    incr mult 1
    set value [expr $value / 10]
  }
  set b1 [expr int($value / 10) % 10]
  set b2 [expr int($value)      % 10]

  set cwidth  [winfo reqwidth  $canvas]
  set cheight [winfo reqheight $canvas]

  set offsetX [expr ($cwidth - 50) / 2]
  set offsetY [expr ($cheight - 10) / 2]
  set boffY [expr $offsetY + 1]
  set dX [expr $offsetX + 45]
  set dY [expr $offsetY + 10]
  set bdY [expr $dY - 1]
  $canvas create rectangle $offsetX $offsetY $dX $dY \
			   -outline black -fill {tan}
  set b1X1 [expr $offsetX +  5]
  set b1X2 [expr $offsetX + 10]
  set b2X1 [expr $offsetX + 15]
  set b2X2 [expr $offsetX + 20]
  set mX1  [expr $offsetX + 25]
  set mX2  [expr $offsetX + 30]
  set tX1  [expr $offsetX + 35]
  set tX2  [expr $offsetX + 40]

  $canvas create rectangle $b1X1 $boffY $b1X2 $bdY -outline {} -fill $Bands($b1)
  $canvas create rectangle $b2X1 $boffY $b2X2 $bdY -outline {} -fill $Bands($b2)
  $canvas create rectangle $mX1  $boffY  $mX2 $bdY -outline {} -fill $Bands($mult)
  $canvas create rectangle $tX1  $boffY  $tX2 $bdY -outline {} -fill gold
}


proc Resistor::FindNearestStockValue {value} {
  variable StockValues 
  variable StockMinValue 
  variable StockMaxValue

  if {$value < $StockMinValue} {
    tk_messageBox -type ok -icon warning -message "Resistor too small: $value"
    return $StockMinValue
  } elseif {$value > $StockMaxValue} {
    tk_messageBox -type ok -icon warning -message "Resistor too large: $value"
    return $StockMaxValue
  }
  set mult 0
  while {$value < 10} {
    incr mult -1
    set value [expr $value * 10]
  }
  while {$value > 99} {
    incr mult 1
    set value [expr $value / 10]
  }
  foreach s $StockValues {
    if {$value <= $s} {break}
  }
  return [expr $s * pow(10,$mult)]    
}

proc Resistor::WriteOutValue {} {
  variable Resistor 
  variable Bands

  set outfile "[tk_getSaveFile \
		 -defaultextension .txt \
		 -filetypes { {{Text Files}       {.txt .text}    TEXT} } \
		 -initialfile Resistor.txt \
		 -parent . \
		 -title {File to save resistor information in}]"
  if {[string length "$outfile"] == 0} {return}
  if {[catch [list open "$outfile" w] fp]} {
    tk_messageBox -type ok -icon error -message "Could not open $outfile: $fp"
    return
  }
  set ProgId {$Id$}
  puts $fp "Resistor Calculated by $ProgId"
  puts $fp "On [clock format [clock scan now]]"
  puts $fp {}
  foreach slot {vPlus lVolts lCurrent dropVolts Calculated Stock Power Stock} \
	  label {{Supply Voltage} {Load Voltage} {Load Current} 
		 {Voltage Dropped by Resistor} {Calculated Resistance} 
		 {Stock Resistor Value} {Minimum Power Rating} {Bands}} \
	  formatCode {{FormatVoltage} {FormatVoltage} {FormatCurrent} 
		      {FormatVoltage} {FormatResistance} {FormatResistance}
		      {FormatPower} {FormatBands}} {
    puts $fp "$label: [$formatCode $Resistor($slot)]"
  }
  close $fp
}

proc Resistor::FormatVoltage {value} {
  if {$value < 1} {
    return "[format {%5.0f mVolts} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Volts} $value]"
  } else {
    return "[format {%5.2f KVolts} [expr $value / 1000]]"
  }
}

proc Resistor::FormatCurrent {value} {
  if {$value < 1} {
    return "[format {%5.0f mAmps} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Amps} $value]"
  } else {
    return "[format {%5.2f KAmps} [expr $value / 1000]]"
  }
}

proc Resistor::FormatResistance {value} {
  if {$value < 1000} {
    return "[format {%6.2f  Ohms} $value]"
  } elseif {$value < 1000000} {
    return "[format {%6.2f KOhms} [expr $value / 1000]]"
  } else {
    return "[format {%6.2f MOhms} [expr $value / 1000000]]"
  }
}

proc Resistor::FormatPower {value} {
  if {$value < 1} {
    return "[format {%5.0f mWatts} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Watts} $value]"
  } elseif {$value < 1000000} {
    return "[format {%5.2f KWatts} [expr $value / 1000]]"
  } else {
    return "[format {%5.2f MWatts} [expr $value / 1000000]]"
  }
}

proc Resistor::FormatBands {value} {
  variable Bands

  set mult 0
  while {$value < 10} {
    incr mult -1
    set value [expr $value * 10]
  }
  while {$value > 99} {
    incr mult 1
    set value [expr $value / 10]
  }
  set b1 [expr int($value / 10) % 10]
  set b2 [expr int($value)      % 10]

  return "$Bands($b1)-$Bands($b2)-$Bands($mult)-gold"  
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
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
            - [winfo vrootx $w]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
            - [winfo vrooty $w]}]
  wm geom $w +$x+$y
  wm deiconify .
}

Resistor::CalculateValue

