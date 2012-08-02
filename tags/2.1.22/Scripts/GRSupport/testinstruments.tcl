package require Tk
package require BWidget
package require BWStdMenuBar
package require Instruments 2.0
package require OvalWidgets 2.0

namespace eval TestInstruments {
  variable Menu [StdMenuBar::MakeMenu \
		-file {"&File" {file} {file} 0 {
		{command "&New" {file:new} "" {} -state disabled}
		{command "&Open..." {file:open} "" {} -state disabled}
		{command "&Save" {file:save} "" {} -state disabled}
		{command "Save &As..." {file:saveas} "" {} -state disabled}
		{command "&Print..." {file:print} "" {} -state disabled}
		{command "&Close" {file:close} "Close the application" \
						{Ctrl q} -command exit}
		{command "E&xit"  {file:exit} "Close the application" \
						{Ctrl q} -command exit}
		}}]
  variable Status {}
  variable Main [MainFrame::create .main \
				-menu $Menu \
				-textvariable TestInstruments::Status]
  pack $Main -expand yes -fill both
  $Main showstatusbar status
  set frame [.main getframe]
  set sw [ScrolledWindow::create $frame.canvasSW -scrollbar both -auto both]
  pack $sw -expand yes -fill both
  variable Canvas [canvas $sw.canvas]
  pack $Canvas -expand yes -fill both
  $sw setwidget $Canvas

  variable SpeedOdometer [Instruments::DialInstrument create spedo $Canvas -x 20 -y 50 -size 80 -label {Speed}]
  variable AirPressure   [Instruments::DialInstrument create airpres $Canvas -x 150 -y 50 -size 80 \
				-maxvalue 200 -secondpointerp 1 -digitalp 0 \
				-label {Air Pressure}]
  $AirPressure setvalue 180 0
  variable Clock [Instruments::AnalogClock create clock $Canvas -x 280 -y 50 -size 80 -label {Clock}]
  variable DClock [Instruments::DigitalClock create dclock $Canvas -x 280 -y 150 -size 20 -label {Clock}]
  variable Oil   [Instruments::DialInstrument create oil $Canvas -x 410 -y 50 -size 80 -label {Oil Pressure} \
			-maxvalue 80 -digitalp 0]
  variable Temp  [Instruments::DialInstrument create temp $Canvas -x 540 -y 50 -size 80 -label {Temp} \
			-maxvalue 220 -minvalue 80 -digitalp 0]
  variable DTemp  [Instruments::DigitalInstrument create dtemp $Canvas -x 540 -y 150 -size 20 -label {Temp} \
			-digits 3]

  variable CabSig1 [Instruments::CabSignalLamp create cabsig1 $Canvas -x 50 -y 200 -size 20 -color green]
  variable CabSig2 [Instruments::CabSignalLamp create cabsig2 $Canvas -x 50 -y 230 -size 20 -color yellow]
  variable CabSig3 [Instruments::CabSignalLamp create cabsig3 $Canvas -x 50 -y 260 -size 20 -color red]

  proc __ovsb {args} {
    puts "*** TestInstruments::__ovsb $args"
  }

  variable OVB [OvalWidgets::OvalButton create ovb $Canvas -x 150 -y 200 -background yellow -foreground magenta -text Hello -command {puts "Hello"}]
  variable OVS [OvalWidgets::OvalSrollBar create ovsb $Canvas -x 350 -y 200 -length 400 -command "TestInstruments::__ovsb"]
  variable OVSC [OvalWidgets::OvalScale create ovsc $Canvas -x 400 -y 200 -length 400 -to 80 ]
  variable OVSL [OvalWidgets::OvalSlider create ovsl $Canvas -x 150 -y 250 -length 300 -from 100 -to 0 -background blue -foreground orange -text Thrusters]
  $OVSL set 0.0
  variable OVRECT [OvalWidgets::OvalRoundCornerRectangle create ovrect $Canvas -x 400 -y 300 -width 400 -height 300 -color green]
  variable OVLABEL [OvalWidgets::OvalLabel create ovlab $Canvas -x 450 -y 350 \
		-text "Hello, Captian Picard" -font {federationbold -20} \
		-color yellow -undercolor blue -under 7

  set bbAll [$Canvas bbox all]

  $Canvas configure -scrollregion $bbAll

#  set bbwidth  [expr {[lindex $bbAll 2] - [lindex $bbAll 0]}]
#  set bbheight [expr {[lindex $bbAll 3] - [lindex $bbAll 1]}]
#  if {$bbwidth > 780}  {set bbwidth 780}
#  if {$bbheight > 580} {set bbheight 580}
#  $Canvas configure -width $bbwidth -height $bbheight
  
  wm geometry . 800x600

  variable SpeedCount 0
  variable AirCount 180
  variable AirIncr -10

  
}

proc TestInstruments::UpdateClock {} {
  variable Clock
  variable DClock
  scan [::clock format [::clock scan now] -format %R] {%2d:%2d} hour minute
  $Clock settime $hour  $minute
  $DClock settime $hour  $minute
#  puts stderr "*** TestInstruments::UpdateClock: hour = $hour, minute = $minute"
  after 60000 TestInstruments::UpdateClock
}

TestInstruments::UpdateClock

proc TestInstruments::UpdateInstruments {} {
  variable SpeedCount
  variable AirCount
  variable AirIncr
  variable SpeedOdometer
  variable AirPressure
  variable Oil
  variable Temp
  variable DTemp
  variable OVSC

  incr SpeedCount 5
  incr AirCount $AirIncr
  if {$SpeedCount > 100} {set SpeedCount 0}
  if {$AirCount == 0} {set AirIncr 10}
  if {$AirCount == 180} {set AirIncr -10}
  $SpeedOdometer setvalue $SpeedCount
  $AirPressure setvalue $AirCount [expr 180 - $AirCount]
  $Oil setvalue [$OVSC get]
  set flutter [expr {(rand() * 5) - 2.5}]
  set temp [expr {([$OVSC get] * 1.65) + 82.5 + $flutter}]
  $Temp setvalue $temp
  $DTemp setvalue $temp
  after 125 TestInstruments::UpdateInstruments
}

after 125 TestInstruments::UpdateInstruments
  
  
  
