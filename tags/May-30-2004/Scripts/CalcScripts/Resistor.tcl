#!/usr/bin/wish -f
#* 
#* ------------------------------------------------------------------
#* Resistor.tcl - Load resistor calculator
#* Created by Robert Heller on Sat Jan 24 10:37:59 2004
#* ------------------------------------------------------------------
#* Modification History: $Log$
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

global SrcDir
# Global containing the source directory.
# [index] SrcDir!global

set SrcDir [file dirname [info script]]
if {[string compare "$SrcDir" {.}] == 0} {set SrcDir [pwd]}

global CommonSrcDir
# Global containing the Common source directory.
# [index] CommonSrcDir!global

set CommonSrcDir [file join [file dirname $SrcDir] Common]

lappend auto_path $CommonSrcDir $SrcDir

package require StdMenuBar 1.0

proc MainWindow {} {
  global Resistor


  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1265 994
  wm minsize . 1 1
  wm protocol . WM_DELETE_WINDOW {CareFulExit}
  wm title . {Calculate Load Resistor Value}


  MakeStandardMenuBar
  set fm [GetMenuByName File]
  $fm entryconfigure Exit -command {CareFulExit}
  $fm entryconfigure Close -command {CareFulExit}
  $fm entryconfigure Save -command {WriteOutValue}
  $fm entryconfigure {Save As...} -command {WriteOutValue}
  $fm entryconfigure New -command {ResetValues}
  $fm entryconfigure {Open...} -state disabled
  $fm entryconfigure {Print...} -state disabled

  set em [GetMenuByName Edit]
  for {set i 0} {$i <= [$em index end]} {incr i} {
    $em entryconfigure $i -state disabled
  }


  # build widget .main
  frame .main \
    -borderwidth {2}

  # build widget .main.head
  frame .main.head \
    -borderwidth {2}

  # build widget .main.head.label7
  label .main.head.label7 \
    -font {Helvetica -24 bold} \
    -text {Calculate Load Resistor Value}

  # build widget .main.head.frame8
  frame .main.head.frame8 \
    -borderwidth {2}

  # build widget .main.vPlus
  frame .main.vPlus \
    -borderwidth {2}

  # build widget .main.vPlus.label9
  label .main.vPlus.label9 \
    -text {Supply Voltage:}

  # build widget .main.vPlus.vSupply
  entry .main.vPlus.vSupply

  # build widget .main.vPlus.units
  tk_optionMenu .main.vPlus.units Resistor(VPlusUnits) Volts MiliVolts KiloVolts

  # build widget .main.loadVoltage
  frame .main.loadVoltage \
    -borderwidth {2}

  # build widget .main.loadVoltage.label11
  label .main.loadVoltage.label11 \
    -text {Voltage Across Load (Bulb, LED, etc.):}

  # build widget .main.loadVoltage.units
  tk_optionMenu .main.loadVoltage.units Resistor(LoadVUnits) Volts MiliVolts KiloVolts

  # build widget .main.loadVoltage.loadVoltage
  entry .main.loadVoltage.loadVoltage

  # build widget .main.loadCurrent
  frame .main.loadCurrent \
    -borderwidth {2}

  # build widget .main.loadCurrent.label15
  label .main.loadCurrent.label15 \
    -text {Load Current Draw:}

  # build widget .main.loadCurrent.loadCurrent
  entry .main.loadCurrent.loadCurrent

  # build widget .main.loadCurrent.units
  tk_optionMenu .main.loadCurrent.units Resistor(LoadCurrentUnits) Amps MiliAmps KiloAmps

  # build widget .main.resistorValue
  frame .main.resistorValue \
    -borderwidth {2}

  # build widget .main.resistorValue.label19
  label .main.resistorValue.label19 \
    -text {Calculated Value:}

  # build widget .main.resistorValue.calcval
  label .main.resistorValue.calcval \
    -anchor {w} \
    -relief {sunken} \
    -text {0} \
    -width {12}

  # build widget .main.resistorValue.label21
  label .main.resistorValue.label21 \
    -text {Available value:}

  # build widget .main.resistorValue.available
  label .main.resistorValue.available \
    -anchor {w} \
    -relief {sunken} \
    -text {0} \
    -width {12}

  # build widget .main.button6
  button .main.button6 \
    -text {Calculate} \
    -command {CalculateValue}

  # build widget .main.resistor2
  frame .main.resistor2 \
    -borderwidth {2}

  # build widget .main.resistor2.label23
  label .main.resistor2.label23 \
    -text {Minimum Power Rating:}

  # build widget .main.resistor2.pow
  label .main.resistor2.pow \
    -anchor {w} \
    -relief {sunken} \
    -text {0} \
    -width {12}

  # build widget .main.resistor2.label25
  label .main.resistor2.label25 \
    -text {Bands:}

  # build widget .main.resistor2.bands
  canvas .main.resistor2.bands \
    -borderwidth {2} \
    -height {0} \
    -relief {sunken} \
    -width {50} \
    -height {15}

  # pack master .main.head
  pack configure .main.head.label7 \
    -side left
  pack configure .main.head.frame8 \
    -fill both \
    -side right

  # pack master .main.vPlus
  pack configure .main.vPlus.label9 \
    -side left
  pack configure .main.vPlus.vSupply \
    -expand 1 \
    -fill x \
    -side left
  pack configure .main.vPlus.units \
    -side right

  # pack master .main.loadVoltage
  pack configure .main.loadVoltage.label11 \
    -side left
  pack configure .main.loadVoltage.units \
    -side right
  pack configure .main.loadVoltage.loadVoltage \
    -expand 1 \
    -fill x \
    -side left

  # pack master .main.loadCurrent
  pack configure .main.loadCurrent.label15 \
    -side left
  pack configure .main.loadCurrent.loadCurrent \
    -expand 1 \
    -fill x \
    -side left
  pack configure .main.loadCurrent.units \
    -side right

  # pack master .main.resistorValue
  pack configure .main.resistorValue.label19 \
    -side left
  pack configure .main.resistorValue.calcval \
    -expand 1 \
    -fill x \
    -side left
  pack configure .main.resistorValue.label21 \
    -side left
  pack configure .main.resistorValue.available \
    -expand 1 \
    -fill x \
    -side right

  # pack master .main.resistor2
  pack configure .main.resistor2.label23 \
    -side left
  pack configure .main.resistor2.pow \
    -side left
  pack configure .main.resistor2.label25 \
    -side left
  pack configure .main.resistor2.bands \
    -expand 1 \
    -fill both \
    -side right

  # pack master .main
  pack configure .main.head \
    -fill x
  pack configure .main.vPlus \
    -fill x
  pack configure .main.loadVoltage \
    -fill x
  pack configure .main.loadCurrent \
    -fill x
  pack configure .main.resistorValue \
    -fill x
  pack configure .main.resistor2 \
    -fill x
  pack configure .main.button6 \
    -expand 1 \
    -fill x

  # pack slave .main
  pack configure .main \
    -expand 1 \
    -fill both

  .main.vPlus.vSupply insert end {12}
  .main.loadVoltage.loadVoltage insert end {2}
  .main.loadCurrent.loadCurrent insert end {.02}
  # build canvas items .main.resistor2.bands

# end of widget tree


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
  update idletasks
  CalculateValue
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

proc ResetValues {} {
  global Resistor
  array set Resistor {
    VPlusUnits Volts
    LoadVUnits Volts
    LoadCurrentUnits Amps
  }
  .main.vPlus.vSupply delete 0 end
  .main.vPlus.vSupply insert end {12}
  .main.loadVoltage.loadVoltage delete 0 end
  .main.loadVoltage.loadVoltage insert end {2}
  .main.loadCurrent.loadCurrent delete 0 end
  .main.loadCurrent.loadCurrent insert end {.02}
  CalculateValue

}

proc CalculateValue {} {
  global Resistor

  set vp "[.main.vPlus.vSupply get]"
  if {[catch [list expr double($vp)] Resistor(vPlus)]} {
    tk_messageBox -type ok -icon error -message "Not a number (Supply Voltage): $vp"
    return
  }
  set lv "[.main.loadVoltage.loadVoltage get]"
  if {[catch [list expr double($lv)] Resistor(lVolts)]} {
    tk_messageBox -type ok -icon error -message "Not a number (Voltage Across Load): $lv"
    return
  }
  set lc "[.main.loadCurrent.loadCurrent get]"
  if {[catch [list expr double($lc)] Resistor(lCurrent)]} {
    tk_messageBox -type ok -icon error -message "Not a number Load Current Draw): $lc"
    return
  }
  switch -exact -- "$Resistor(VPlusUnits)" {
    Volts {}
    MiliVolts {set Resistor(vPlus) [expr $Resistor(vPlus) / 1000.0]}
    KiloVolts {set Resistor(vPlus) [expr $Resistor(vPlus) * 1000.0]}
  }
  switch -exact -- "$Resistor(LoadVUnits)" {
    Volts {}
    MiliVolts {set Resistor(lVolts) [expr $Resistor(lVolts) / 1000.0]}
    KiloVolts {set Resistor(lVolts) [expr $Resistor(lVolts) * 1000.0]}
  }
  switch -exact -- "$Resistor(LoadCurrentUnits)" {
    Amps {}
    MiliAmps {set Resistor(lCurrent) [expr $Resistor(lCurrent) / 1000.0]}
    KiloAmps {set Resistor(lCurrent) [expr $Resistor(lCurrent) * 1000.0]}
  }
  set Resistor(dropVolts) [expr $Resistor(vPlus) - $Resistor(lVolts)]
  set Resistor(Calculated) [expr $Resistor(dropVolts) / $Resistor(lCurrent)]
  DisplayResistence .main.resistorValue.calcval $Resistor(Calculated)
  set Resistor(Stock) [FindNearestStockValue $Resistor(Calculated)]
  DisplayResistence .main.resistorValue.available $Resistor(Stock)
  DisplayBands .main.resistor2.bands $Resistor(Stock)
  set Resistor(Power) [expr $Resistor(dropVolts) * $Resistor(lCurrent)]
  DisplayPower .main.resistor2.pow $Resistor(Power)
}

proc DisplayResistence {label value} {
  if {$value < 1000} {
    $label configure -text "[format {%6.2f  Ohms} $value]"
  } elseif {$value < 1000000} {
    $label configure -text "[format {%6.2f KOhms} [expr $value / 1000]]"
  } else {
    $label configure -text "[format {%6.2f MOhms} [expr $value / 1000000]]"
  }
}

proc DisplayPower {label value} {
  if {$value < 1} {
    $label configure -text "[format {%5.0f mWatts} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    $label configure -text "[format {%5.2f  Watts} $value]"
  } elseif {$value < 1000000} {
    $label configure -text "[format {%5.2f KWatts} [expr $value / 1000]]"
  } else {
    $label configure -text "[format {%5.2f MWatts} [expr $value / 1000000]]"
  }
}

global Bands
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
  

proc DisplayBands {canvas value} {
  global Bands
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

  set cwidth  [winfo width  $canvas]
  set cheight [winfo height $canvas]

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

global StockValues StockMinValue StockMaxValue
set StockValues {
  10 11 12 13 14 15 16 18 20 22 24 27 30 33 36 39 43 47 51
  56 62 68 75 82 91}
set StockMinValue 1.0
set StockMaxValue 10000000.0

proc FindNearestStockValue {value} {
  global StockValues StockMinValue StockMaxValue

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

proc WriteOutValue {} {
  global Resistor Bands

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

proc FormatVoltage {value} {
  if {$value < 1} {
    return "[format {%5.0f mVolts} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Volts} $value]"
  } else {
    return "[format {%5.2f KVolts} [expr $value / 1000]]"
  }
}

proc FormatCurrent {value} {
  if {$value < 1} {
    return "[format {%5.0f mAmps} [expr $value * 1000]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Amps} $value]"
  } else {
    return "[format {%5.2f KAmps} [expr $value / 1000]]"
  }
}

proc FormatResistance {value} {
  if {$value < 1000} {
    return "[format {%6.2f  Ohms} $value]"
  } elseif {$value < 1000000} {
    return "[format {%6.2f KOhms} [expr $value / 1000]]"
  } else {
    return "[format {%6.2f MOhms} [expr $value / 1000000]]"
  }
}

proc FormatPower {value} {
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

proc FormatBands {value} {
  global Bands

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

MainWindow
