#!/usr/bin/wish -f
#* 
#* ------------------------------------------------------------------
#* Resistor.tcl - Load resistor calculator
#* Created by Robert Heller on Sat Jan 24 10:37:59 2004
#* ------------------------------------------------------------------
#* Modification History: $Log$
#* Modification History: Revision 1.4  2007/10/22 17:17:28  heller
#* Modification History: 10222007
#* Modification History:
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

## @defgroup Resistor Resistor
# @brief Calculate Load Resistors.
#
# @section SYNOPSIS
# Resistor [X11 Resource Options]
#
# @section DESCRIPTION
# The Resistor Calculator program aids in calculating dropping resistors
# for LEDs and low-voltage lamps commonly used on model railroads.  It
# implements Ohm's Law, shown in the equations below to perform the
# calculation and then finds the nearest stock value and also displays
# the color bands for typical carbon resistors.
#
#
# <b>Rdrop = Vdrop/I</b>
#
# <b>Vdrop = Vsupply - Vload</b>
#
#
# The calculator takes three input values, the supply voltage
# (Vsupply), the voltage across the load (Vload) (LED or lamp)
# and the load current (I) the LED or lamp operates at.  These values
# are entered along with the units they are in. Then the calculate button
# is pushed and the results are displayed.  The results can also be saved
# to a text file, which can be printed or otherwise refered to later.
#
# @section PARAMETERS
# None.
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#


set argv0 [file join  [file dirname [info nameofexecutable]] Resistor]

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

namespace eval Resistor {

  # Window manager configurations
  wm positionfrom . user
  wm sizefrom . ""
  wm maxsize . 1265 994
  wm minsize . 1 1
  wm protocol . WM_DELETE_WINDOW {CareFulExit}
  wm title . [_ "Calculate Load Resistor Value"]

  # Create menubar
  set menubar [StdMenuBar MakeMenu \
	-file [list [_m "Menu|&File"] {file} {file} 0 [list \
	     [list command [_m "Menu|&File|&New"] {file:new} [_ "Reset Values"]  {Ctrl n} -command {Resistor::ResetValues}] \
	     [list command [_m "Menu|&File|&Open..."] {file:open} "" {} -state disabled] \
	     [list command [_m "Menu|&File|&Save"]    {file:save} [_ "Save Value"] {Ctrl s} -command {Resistor::WriteOutValue}] \
	     [list command [_m "Menu|&File|Save &As..."] {file:save} [_ "Save Value"] {Ctrl s} -command {Resistor::WriteOutValue}] \
	     [list command [_m "Menu|&File|&Close"] {file:close} [_ "Close the application"] {Ctrl q} -command {::CareFulExit}] \
	     [list command [_m "Menu|&File|E&xit"] {file:exit} [_ "Close the application"] {Ctrl q} -command {::CareFulExit}] \
	]\
    ] -help [list [_m "Menu|&Help"] {help} {help} 0 [list \
		[list command [_m "Menu|Help|On &Help..."] {help:help} [_ "Help on help"] {} -command "HTMLHelp help Help"] \
		[list command [_m "Menu|Help|On &Version"] {help:version} [_ "Version"] {} -command "HTMLHelp help Version"] \
		[list command [_m "Menu|Help|Warranty"] {help:warranty} [_ "Warranty"] {} -command "HTMLHelp help Warranty"] \
		[list command [_m "Menu|Help|Copying"] {help:copying} [_ "Copying"] {} -command "HTMLHelp help Copying"] \
		[list command [_m "Menu|Help|Reference Manual"] {help:reference} [_ "Reference Manual"] {} -command {HTMLHelp help "Resistor Program Reference"}] \
	]\
    ]]


  # Create main frame
  pack [MainFrame .main -menu $menubar -textvariable Status] -expand yes -fill both
  .main showstatusbar status

  HTMLHelp setDefaults "$::HelpDir" "index.html#toc"

  # Get frame
  set frame [.main getframe]
  # Heading
  pack [ttk::label $frame.hlabel \
	-font {Helvetica -24 bold} -text [_ "Calculate Load Resistor Value"] \
	-anchor c] -expand yes -fill x

  # Supply voltage frame
  set lw 15
  pack [LabelFrame $frame.vSupplyLF -text [_m "Label|Supply Voltage:"] -width $lw] \
	-fill x
  variable VSupplyValue [spinbox [$frame.vSupplyLF getframe].volts \
		-from 1.0 -to 48.0 -increment .25]
  pack $VSupplyValue -side left -expand yes -fill x
  variable VSupplyUnits [ttk::combobox [$frame.vSupplyLF getframe].units \
		-state readonly -values {Volts MiliVolts KiloVolts}]
  pack $VSupplyUnits -side right
  $VSupplyUnits set Volts

  # Load voltage frame
  pack [LabelFrame $frame.vLoadLF -text [_m "Label|Load Voltage:"] -width $lw] \
	-fill x
  variable VLoadValue [spinbox [$frame.vLoadLF getframe].volts \
		-from 1.0 -to 48.0 -increment .25]
  pack $VLoadValue -side left -expand yes -fill x
  variable VLoadUnits [ttk::combobox [$frame.vLoadLF getframe].units \
		-state readonly -values {Volts MiliVolts KiloVolts}]
  pack $VLoadUnits -side right
  $VLoadUnits set Volts

  # Load current frame
  pack [LabelFrame $frame.iLoadLF -text [_m "Label|Load Current:"] -width $lw] \
	-fill x 
  variable ILoadValue [spinbox [$frame.iLoadLF getframe].amps \
		-from .001 -to 1000.0 -increment .01]
  pack $ILoadValue -side left -expand yes -fill x
  variable ILoadUnits [ttk::combobox [$frame.iLoadLF getframe].units \
		-state readonly -values {Amps MiliAmps KiloAmps}]
  pack $ILoadUnits -side right
  $ILoadUnits set Amps

  # Resistor value frame
  pack [LabelFrame $frame.resistorValue \
			-text [_m "Label|Resistor Values:"] -width $lw] -fill x
  variable CalcValue [LabelEntry [$frame.resistorValue getframe].calcV \
			-label [_m "Label|Calculated:"] -editable no -text 0]
  pack $CalcValue -side left -fill x
  variable AvailValue [LabelEntry [$frame.resistorValue getframe].availV \
			-label [_m "Label|Available:"] -editable no -text 0]
  pack $AvailValue -side left -fill x

  # Calculate button	  
  pack [ttk::button $frame.calc \
		-text [_m "Button|Calculate"] \
		-command {Resistor::CalculateValue}] -fill x

  # Power rating and band display frame
  pack [frame $frame.resistor2 -borderwidth {2}] -fill x
  variable PowerRating [LabelEntry $frame.resistor2.pow \
			-label [_m "Label|Minimum Power Rating:"] \
			-editable no -text 0]
  pack $PowerRating -side left -fill x
  set lfTemp [LabelFrame $frame.resistor2.bands -text {Bands:}]
  pack $lfTemp -side left -fill x
  variable BandDisplay [canvas [$lfTemp getframe].c \
			-borderwidth {2} \
			-relief {sunken} \
			-width 50 -height 15]
  pack $BandDisplay

  # Initial values
  $VSupplyValue configure -text 12.0
  $VLoadValue   configure -text  2.0
  $ILoadValue   configure -text   .02


  # Stock values
  variable StockValues {
  10 11 12 13 14 15 16 18 20 22 24 27 30 33 36 39 43 47 51
  56 62 68 75 82 91}
  variable StockMinValue 1.0
  variable StockMaxValue 10000000.0
  # Color code values
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

proc CareFulExit {{answer no}} {
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

proc Resistor::ResetValues {} {
# Procedure to reset to default values.
# [index] Resistor::ResetValues!procedure

  variable VSupplyValue
  $VSupplyValue delete 0 end
  $VSupplyValue insert end 12.0
  variable VSupplyUnits
  $VSupplyUnits set Volts
  variable VLoadValue
  $VLoadValue delete 0 end
  $VLoadValue insert end 2.0
  variable VLoadUnits
  $VLoadUnits set Volts
  variable ILoadValue
  $ILoadValue delete 0 end
  $ILoadValue insert end 0.02
  variable ILoadUnits
  $ILoadUnits set Amps
  CalculateValue

}

proc Resistor::CalculateValue {} {
# Procedure to calculate the resistor value.
# [index] Resistor::CalculateValue!procedure

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

  # Fetch and validate values from GUI
  set vp "[$VSupplyValue get]"
  if {![string is double "$vp"]} {
    tk_messageBox -type ok -icon error -message [format [_ "Not a number (Supply Voltage): %s"] $vp]
    return
  }
  set lv "[$VLoadValue get]"
  if {![string is double "$lv"]} {
    tk_messageBox -type ok -icon error -message [format [_ "Not a number (Voltage Across Load): %s"] $lv]
    return
  }
  set lc "[$ILoadValue get]"
  if {![string is double "$lc"]} {
    tk_messageBox -type ok -icon error -message [format [_ "Not a number Load Current Draw): %s"] $lc]
    return
  }
  # Adjust for units
  variable Resistor
  switch -exact -- "[$VSupplyUnits get]" {
    Volts {set  Resistor(vPlus) $vp}
    MiliVolts {set Resistor(vPlus) [expr {$vp / 1000.0}]}
    KiloVolts {set Resistor(vPlus) [expr {$vp * 1000.0}]}
  }
  switch -exact -- "[$VLoadUnits get]" {
    Volts {set Resistor(lVolts) $lv}
    MiliVolts {set Resistor(lVolts) [expr {$lv / 1000.0}]}
    KiloVolts {set Resistor(lVolts) [expr {$lv * 1000.0}]}
  }
  switch -exact -- "[$ILoadUnits get]" {
    Amps {set Resistor(lCurrent) $lc}
    MiliAmps {set Resistor(lCurrent) [expr {$lc / 1000.0}]}
    KiloAmps {set Resistor(lCurrent) [expr {$lc * 1000.0}]}
  }
  # Compute Vdrop
  set Resistor(dropVolts) [expr {$Resistor(vPlus) - $Resistor(lVolts)}]
  # Compute R
  set Resistor(Calculated) [expr {$Resistor(dropVolts) / $Resistor(lCurrent)}]
  # Display the calculated resistance
  DisplayResistance $CalcValue $Resistor(Calculated)
  # Find the nearest stock value.
  set Resistor(Stock) [FindNearestStockValue $Resistor(Calculated)]
  # Display the available value.
  DisplayResistance $AvailValue $Resistor(Stock)
  # Display the bands.
  DisplayBands $BandDisplay $Resistor(Stock)
  # Computer power rating needed.
  set Resistor(Power) [expr {$Resistor(dropVolts) * $Resistor(lCurrent)}]
  # Display power rating needed.
  DisplayPower $PowerRating $Resistor(Power)
}

proc Resistor::DisplayResistance {entry value} {
# Procedure to display resistance values.
# <in> entry Entry widget to update.
# <in> value Resistance value to display.
# [index] Resistor::DisplayResistance!procedure

  if {$value < 1000} {
    $entry configure -text "[format {%6.2f  Ohms} $value]"
  } elseif {$value < 1000000} {
    $entry configure -text "[format {%6.2f KOhms} [expr {$value / 1000.0}]]"
  } else {
    $entry configure -text "[format {%6.2f MOhms} [expr {$value / 1000000.0}]]"
  }
}

proc Resistor::DisplayPower {entry value} {
# Procedure to display power values.
# <in> entry Entry widget to update. 
# <in> value Power value to display.
# [index] Resistor::DisplayPower!procedure

  if {$value < 1} {
    $entry configure -text "[format {%5.0f mWatts} [expr {$value * 1000}]]"
  } elseif {$value < 1000} {
    $entry configure -text "[format {%5.2f  Watts} $value]"
  } elseif {$value < 1000000} {
    $entry configure -text "[format {%5.2f KWatts} [expr {$value / 1000.0}]]"
  } else {
    $entry configure -text "[format {%5.2f MWatts} [expr {$value / 1000000.0}]]"
  }
}

  

proc Resistor::DisplayBands {canvas value} {
# Procedure to display resistor color bands
# <in> canvas Canvas to display the bands in.
# <in> value Resistance value to display.
# [index] Resistor::DisplayBands!procedure

  variable Bands
  $canvas delete all

# Normalize value to between 10 and 99 (first two bands),
# saving multiplier value (third band).
  set mult 0
  while {$value < 10} {
    incr mult -1
    set value [expr {$value * 10}]
  }
  while {$value > 99} {
    incr mult 1
    set value [expr {$value / 10}]
  }
# Extract band digits.
  set b1 [expr {int($value / 10.0) % 10}]
  set b2 [expr {int($value)        % 10}]

  set cwidth  [winfo reqwidth  $canvas]
  set cheight [winfo reqheight $canvas]

  set offsetX [expr {($cwidth - 50) / 2}]
  set offsetY [expr {($cheight - 10) / 2}]
  set boffY [expr {$offsetY + 1}]
  set dX [expr {$offsetX + 45}]
  set dY [expr {$offsetY + 10}]
  set bdY [expr {$dY - 1}]
  # Draw background color.
  $canvas create rectangle $offsetX $offsetY $dX $dY \
			   -outline black -fill {tan}
  set b1X1 [expr {$offsetX +  5}]
  set b1X2 [expr {$offsetX + 10}]
  set b2X1 [expr {$offsetX + 15}]
  set b2X2 [expr {$offsetX + 20}]
  set mX1  [expr {$offsetX + 25}]
  set mX2  [expr {$offsetX + 30}]
  set tX1  [expr {$offsetX + 35}]
  set tX2  [expr {$offsetX + 40}]

  # Draw bands.
  $canvas create rectangle $b1X1 $boffY $b1X2 $bdY -outline {} -fill $Bands($b1)
  $canvas create rectangle $b2X1 $boffY $b2X2 $bdY -outline {} -fill $Bands($b2)
  $canvas create rectangle $mX1  $boffY  $mX2 $bdY -outline {} -fill $Bands($mult)
  $canvas create rectangle $tX1  $boffY  $tX2 $bdY -outline {} -fill gold
}


proc Resistor::FindNearestStockValue {value} {
# Procedure to find nearest stock value.
# <in> value Resistance value.
# [index] Resistor::FindNearestStockValue!procedure

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
    set value [expr {$value * 10}]
  }
  while {$value > 99} {
    incr mult 1
    set value [expr {$value / 10}]
  }
  foreach s $StockValues {
    if {$value <= $s} {break}
  }
  return [expr {$s * pow(10,$mult)}]    
}

proc Resistor::WriteOutValue {} {
# Procedure to write resistor value out.
# [index] Resistor::WriteOutValue!procedure

  variable Resistor 
  variable Bands

  set outfile [tk_getSaveFile \
		 -defaultextension .txt \
		 -filetypes { {{Text Files}       {.txt .text}    TEXT} } \
		 -initialfile Resistor.txt \
		 -parent . \
		 -title [_ "File to save resistor information in"]]
  if {[string length "$outfile"] == 0} {return}
  if {[catch [list open "$outfile" w] fp]} {
    tk_messageBox -type ok -icon error -message [format [_ "Could not open %s: %s"] $outfile $fp]
    return
  }
  set ProgId {$Id$}
  puts $fp [format [_ "Resistor Calculated by %s"] $ProgId]
  puts $fp [format [_ "On %s"] [clock format [clock scan now]]]
  puts $fp {}
  foreach slot {vPlus lVolts lCurrent dropVolts Calculated Stock Power Stock} \
	  label [list [_m "Label|Supply Voltage"] [_m "Label|Load Voltage"] \
		 [_m "Label|Load Current"] \
		 [_m "Label|Voltage Dropped by Resistor"] \
		 [_m "Label|Calculated Resistance"] \ 
		 [_m "Label|Stock Resistor Value"] \
		 [_m "Label|Minimum Power Rating"] [_m "Label|Bands"]] \
	  formatCode {{FormatVoltage} {FormatVoltage} {FormatCurrent} 
		      {FormatVoltage} {FormatResistance} {FormatResistance}
		      {FormatPower} {FormatBands}} {
    puts $fp "$label: [$formatCode $Resistor($slot)]"
  }
  close $fp
}

proc Resistor::FormatVoltage {value} {
# Procedure to format a voltage value.
# <in> value Voltage value to format.
# [index] Resistor::FormatVoltage!procedure

  if {$value < 1} {
    return "[format {%5.0f mVolts} [expr {$value * 1000}]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Volts} $value]"
  } else {
    return "[format {%5.2f KVolts} [expr {$value / 1000.0}]]"
  }
}

proc Resistor::FormatCurrent {value} {
# Procedure to format a current value.
# <in> value Current value to format.
# [index] Resistor::FormatCurrent!procedure

  if {$value < 1} {
    return "[format {%5.0f mAmps} [expr {$value * 1000}]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Amps} $value]"
  } else {
    return "[format {%5.2f KAmps} [expr {$value / 1000.0}]]"
  }
}

proc Resistor::FormatResistance {value} {
# Procedure to format a resistance value.
# <in> value Resistance value to format.
# [index] Resistor::FormatResistance!procedure

  if {$value < 1000} {
    return "[format {%6.2f  Ohms} $value]"
  } elseif {$value < 1000000} {
    return "[format {%6.2f KOhms} [expr {$value / 1000}]]"
  } else {
    return "[format {%6.2f MOhms} [expr {$value / 1000000.0}]]"
  }
}

proc Resistor::FormatPower {value} {
# Procedure to format a power value.
# <in> value Power value to format.
# [index] Resistor::FormatPower!procedure

  if {$value < 1} {
    return "[format {%5.0f mWatts} [expr {$value * 1000}]]"
  } elseif {$value < 1000} {
    return "[format {%5.2f  Watts} $value]"
  } elseif {$value < 1000000} {
    return "[format {%5.2f KWatts} [expr {$value / 1000.0}]]"
  } else {
    return "[format {%5.2f MWatts} [expr {$value / 1000000.0}]]"
  }
}

proc Resistor::FormatBands {value} {
# Procedure to format a resistor's color bands.
# <in> value Resistance value to format.
# [index] Resistor::FormatBands!procedure


  variable Bands

  set mult 0
  while {$value < 10} {
    incr mult -1
    set value [expr {$value * 10}]
  }
  while {$value > 99} {
    incr mult 1
    set value [expr {$value / 10.0}]
  }
  set b1 [expr {int($value / 10.0) % 10}]
  set b2 [expr {int($value)      % 10}]

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

Resistor::ResetValues

if {$IsSlave} {
  fileevent stdin readable {
    if {[gets stdin line] < 0} {CareFulExit yes}
    switch -- "$line" { 
      {201 Exit} {CareFulExit yes}
      default {}
    }
  }
}
