#* 
#* ------------------------------------------------------------------
#* userCodeModules.tcl - User Code Modules
#* Created by Robert Heller on Fri May 23 20:18:05 2008
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

# $Id: userCodeModules.tcl 667 2008-07-27 12:51:53Z heller $

#* TrackWork:START *
namespace eval Blocks {
  # Block type (general trackwork).
  # Encapsulates block occupation detectors.
  #
  snit::type Block {
    # Occupation state values
    typevariable OCC 1
    typevariable CLR 0
    # Occupation state bit
    variable occupiedbit
    constructor {} {
      set occupiedbit $CLR;#	Initialize to clear.
    }
    # Occupation state methods
    method occupiedp {} {return [expr {$occupiedbit == $OCC}]}
    method setoccupied {value} {
      set occupiedbit $value
    }
  }
}

namespace eval Switches {
  # Switch type (turnout)
  # Encapsulates a switch (turnout), including its OS (delegated to a Block 
  # object), its switch motor, and its point position sensor (its state).
  snit::type Switch {
    component block;#			OS section
    delegate method * to block;#	Delegate block methods
    variable state unknown;#		Sense state (point position)
    # Motor bit values
    typevariable NOR 1;# 01		
    typevariable REV 2;# 10		
    variable motor;#			Motor bits -- used to drive switch 
#					motor.
    constructor {} {
      #					Install OS section
      install block using Blocks::Block %AUTO%
      # Initialize motor bits
      set motor $NOR
    }
    # State methods
    method getstate {} {return $state}
    method setstate {statebits} {
      if {$statebits == $NOR} {
	set state normal
      } elseif {$statebits == $REV} {
	set state reverse
      } else {
	set state unknown
      }
    }
    # Motor bit methods
    method motorbits {} {return $motor}
    method setmotor {mv} {
      switch -exact $mv {
	normal {set motor $NOR}
	reverse {set motor $REV}
      }
    }
  }
}
#* TrackWork:END *

#* SwitchPlates:START *
namespace eval SwitchPlates {
  # Switch Plate
  # Encapsulates a switch plate, implementing its lever position.
  snit::type SwitchPlate {
    component switch
    delegate method * to switch
    variable leverpos unknown
    constructor {sw} {
      set switch $sw
    }
    method setlever {pos} {set leverpos $pos}
    method getlever {} {return $leverpos}
  }
}
#* SwitchPlates:END

#* Signals2ACL:START *
namespace eval Signals {
  # Signal types.  Encapsulates a signal's aspect.
  # Descrete Led types, two aspect (Red, Green)
  # See: Fig 3-5 of The Computer / Model Railroad Interface User's Manual V3.0
  snit::type OneHead {
    # Single head signals have three states: dark, green or red.
    typevariable aspects -array {
      Dark	0x00
      Green	0x01
      Red	0x02
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  Green {MainWindow ctcpanel setv $options(-signal) green}
	  Red {MainWindow ctcpanel setv $options(-signal) red}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
  snit::type TwoHead {
    # Two head signals have four states: dard, green over red, red over green, 
    # and red over red.
    typevariable aspects -array {
      Dark	0x00
      GreenRed	0x06
      RedGreen	0x09
      RedRed	0x0A
    }
    variable aspectbits
    option -signal -default {}
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  GreenRed {MainWindow ctcpanel setv $options(-signal) {green red}}
	  RedGreen {MainWindow ctcpanel setv $options(-signal) {red green}}
	  RedRed {MainWindow ctcpanel setv $options(-signal) {red red}}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
}
#* Signals2ACL:END *

#* Signals3ACL:START *
namespace eval Signals {
  # Signal types.  Encapsulates a signal's aspect.
  # Descrete Led types, three aspect (Red, Yellow, Green)
  # See: Fig 3-5 of The Computer / Model Railroad Interface User's Manual V3.0
  snit::type OneHead {
    # Single head signals have four states: dark, green, yellow, or red.
    typevariable aspects -array {
      Dark	0x00
      Green	0x01
      Yellow	0x02
      Red	0x04
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  Green {MainWindow ctcpanel setv $options(-signal) green}
	  Yellow {MainWindow ctcpanel setv $options(-signal) yellow}
	  Red {MainWindow ctcpanel setv $options(-signal) red}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
  snit::type TwoHead {
    # Two head signals have five states: dark, green over red, 
    # yellow over red, red over yellow, and red over red.
    typevariable aspects -array {
      Dark	0x00
      GreenRed	0x11
      YellowRed	0x12
      RedYellow	0x0c
      RedRed	0x14
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  GreenRed {MainWindow ctcpanel setv $options(-signal) {green red}}
	  YellowRed {MainWindow ctcpanel setv $options(-signal) {yellow red}}
	  RedYellow {MainWindow ctcpanel setv $options(-signal) {red yellow}}
	  RedRed {MainWindow ctcpanel setv $options(-signal) {red red}}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
  snit::type ThreeHead {
    # Three head signals have six states: dark, green over red over red, 
    # yellow over red over red, red over yellow over red, red over red 
    # over yellow, and red over red over red.
    typevariable aspects -array {
      Dark		0x00
      GreenRedRed	0x51
      YellowRedRed	0x52
      RedYellowRed	0x4c
      RedRedYellow	0x34
      RedRedRed		0x54
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  GreenRedRed {MainWindow ctcpanel setv $options(-signal) {green red red}}
	  YellowRedRed {MainWindow ctcpanel setv $options(-signal) {yellow red red}}
	  RedYellowRed {MainWindow ctcpanel setv $options(-signal) {red yellow red}}
	  RedRedYellow {MainWindow ctcpanel setv $options(-signal) {red red yellow}}
	  RedRedRed {MainWindow ctcpanel setv $options(-signal) {red red red}}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
}
#* Signals3ACL:END *

#* Signals3ASL:START *
namespace eval Signals {
  # Signal types.  Encapsulates a signal's aspect.
  # Three Aspect Search Light Signals, with either 3 lead or 2 lead bi-color 
  # LEDS
  # See: Fig 3-6 and 3-7 of The Computer / Model Railroad Interface User's Manual V3.0
  snit::type OneHead {
    # Single head signals have four states: dark, green, yellow, or red.
    typevariable aspects -array {
      Dark	0x00
      Green	0x01
      Yellow	0x03
      Red	0x02
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  Green {MainWindow ctcpanel setv $options(-signal) green}
	  Yellow {MainWindow ctcpanel setv $options(-signal) yellow}
	  Red {MainWindow ctcpanel setv $options(-signal) red}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
  snit::type TwoHead {
    # Two head signals have five states: dark, green over red, 
    # yellow over red, red over yellow, and red over red.
    typevariable aspects -array {
      Dark	0x00
      GreenRed	0x09
      YellowRed	0x0b
      RedYellow	0x0d
      RedRed	0x0a
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  GreenRed {MainWindow ctcpanel setv $options(-signal) {green red}}
	  YellowRed {MainWindow ctcpanel setv $options(-signal) {yellow red}}
	  RedYellow {MainWindow ctcpanel setv $options(-signal) {red yellow}}
	  RedRed {MainWindow ctcpanel setv $options(-signal) {red red}}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
  snit::type ThreeHead {
    # Three head signals have six states: dark, green over red over red, 
    # yellow over red over red, red over yellow over red, red over red 
    # over yellow, and red over red over red.
    typevariable aspects -array {
      Dark		0x00
      GreenRedRed	0x29
      YellowRedRed	0x2b
      RedYellowRed	0x2d
      RedRedYellow	0x3a
      RedRedRed		0x2a
    }
    option -signal -default {}
    variable aspectbits
    constructor {args} {
      $self configurelist $args
      set aspectbits $aspects(Dark)
      if {[string length $options(-signal)] > 0} {
	MainWindow ctcpanel setv $options(-signal) dark
      }
    }
    method setaspect {a} {
      set aspectbits $aspects($a)
      if {[string length $options(-signal)] > 0} {
	switch $a {
	  Dark {MainWindow ctcpanel setv $options(-signal) dark}
	  GreenRedRed {MainWindow ctcpanel setv $options(-signal) {green red red}}
	  YellowRedRed {MainWindow ctcpanel setv $options(-signal) {yellow red red}}
	  RedYellowRed {MainWindow ctcpanel setv $options(-signal) {red yellow red}}
	  RedRedYellow {MainWindow ctcpanel setv $options(-signal) {red red yellow}}
	  RedRedRed {MainWindow ctcpanel setv $options(-signal) {red red red}}
	}
      }
    }
    method getaspect {}  {return $aspectbits}
  }
}
#* Signals3ASL:END *


#* SignalPlates:START *
namespace eval SignalPlates {
  # Signal Plate, encapsulating a signal plate with its lever and indicators.
  snit::type SignalPlate {
    variable leverpos unknown
    option -signalplate -default {} -readonly yes
    constructor {args} {
      $self configurelist $args
    }
    method setlever {pos} {set leverpos $pos}
    method getlever {} {return $leverpos}
    method setdot {dir} {
      switch $dir {
	left {
	  MainWindow ctcpanel seti $options(-signalplate) L on
	  MainWindow ctcpanel seti $options(-signalplate) C off
	  MainWindow ctcpanel seti $options(-signalplate) R off
	}
	right {
	  MainWindow ctcpanel seti $options(-signalplate) L off
	  MainWindow ctcpanel seti $options(-signalplate) C off
	  MainWindow ctcpanel seti $options(-signalplate) R on
	}
	none -
	default {
	  MainWindow ctcpanel seti $options(-signalplate) L off
	  MainWindow ctcpanel seti $options(-signalplate) C on
	  MainWindow ctcpanel seti $options(-signalplate) R off
	}
      }
    }
  }
}
#* SignalPlates:END *

#* ControlPoints:START *
namespace eval ControlPoints {
  # Control points.  Used to implement code buttons.  
  # Encapsulates a control point
  snit::type ControlPoint {
    option -cpname -readonly yes -default {}
    constructor {args} {
      $self configurelist $args
    }
    method code {} {
      foreach swp [MainWindow ctcpanel objectlist $options(-cpname) SwitchPlates] {
	MainWindow ctcpanel invoke $swp
      }      
      foreach sgp [MainWindow ctcpanel objectlist $options(-cpname) SignalPlates] {
	MainWindow ctcpanel invoke $sgp
      }
    }
  }
}
#* ControlPoints:END *

#* Groups:START *
namespace eval Groups {
  # Radio groups (from push buttons)
  snit::type Group {
    option -buttonmap -readonly yes -default {}
    variable value
    constructor {args} {
      $self configurelist $args
      $self setvalue {}
    }
    method getvalue {} {return $value}
    method setvalue {newvalue} {
      set value $newvalue
      foreach {b v} $options(-buttonmap) {
	if {[string equal "$v" "$value"]} {
	  MainWindow ctcpanel seti $b I on
	} else {
	  MainWindow ctcpanel seti $b I off
	}
      }
    }
  } 
}
#* Groups:END *

#* SimpleMode:START *
namespace eval SimpleMode {
  proc CodeButton {cp} {
    foreach swp [MainWindow ctcpanel objectlist $cp SwitchPlates] {
      MainWindow ctcpanel invoke $swp
    }
    foreach sgp [MainWindow ctcpanel objectlist $cp SignalPlates] {
      MainWindow ctcpanel invoke $sgp
    }
  }
  proc NormalMRD {plate switchname MRDSerialNumber} {
    MainWindow ctcpanel setv $switchname Normal
    set mrd [Azatrax_OpenDevice $MRDSerialNumber $::Azatrax_idMRDProduct]
    $mrd GetStateData
    $mrd SetChan1
    delete_MRD $mrd
    $mrd -delete
    MainWindow ctcpanel seti $plate N on
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R off
  }
  proc ReverseMRD {plate switchname MRDSerialNumber} {
    MainWindow ctcpanel setv $switchname Reverse
    set mrd [Azatrax_OpenDevice $MRDSerialNumber $::Azatrax_idMRDProduct]
    $mrd GetStateData
    $mrd SetChan2
    delete_MRD $mrd
    $mrd -delete    
    MainWindow ctcpanel seti $plate N off
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R on
  }
  proc NormalSL2 {swnum plate switchname SL2SerialNumber} {
    MainWindow ctcpanel setv $switchname Normal
    set sl2 [Azatrax_OpenDevice $SL2SerialNumber $::Azatrax_idSL2Product]
    $sl2 GetStateData
    switch $swnum {
      1 {$sl2 SetQ1posQ2neg}
      2 {$sl2 SetQ3posQ4neg}
    }
    delete_SL2 $sl2
    $sl2 -delete
    MainWindow ctcpanel seti $plate N on
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R off
  }
  proc ReverseSL2 {swnum plate switchname SL2SerialNumber} {
    MainWindow ctcpanel setv $switchname Reverse
    set sl2 [Azatrax_OpenDevice $SL2SerialNumber $::Azatrax_idSL2Product]
    $sl2 GetStateData
    switch $swnum {
      1 {$sl2 SetQ1negQ2pos}
      2 {$sl2 SetQ3negQ4pos}
    }
    delete_SL2 $sl2
    $sl2 -delete
    MainWindow ctcpanel seti $plate N off
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R on
  }
  proc NormalSR4 {swnum plate switchname SR4SerialNumber} {
    MainWindow ctcpanel setv $switchname Normal
    set sr4 [Azatrax_OpenDevice $SR4SerialNumber $::Azatrax_idSR4Product]
    $sr4 GetStateData
    switch $swnum {
      1 {$sr4 PulseRelays true false false false 1}
      2 {$sr4 PulseRelays false false true false 1}
    }
    delete_SR4 $sr4
    $sr4 -delete
    MainWindow ctcpanel seti $plate N on
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R off
  }
  proc ReverseSR4 {swnum plate switchname SR4SerialNumber} {
    MainWindow ctcpanel setv $switchname Reverse
    set sr4 [Azatrax_OpenDevice $SR4SerialNumber $::Azatrax_idSR4Product]
    $sr4 GetStateData
    switch $swnum {
      1 {$sr4 PulseRelays false true false false 1}
      2 {$sr4 PulseRelays false false false true 1}
    }
    delete_SR4 $sr4
    $sr4 -delete
    MainWindow ctcpanel seti $plate N off
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R on
  }
  proc Left {plate} {
    MainWindow ctcpanel seti $plate L on
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R off
  }
  proc Center {plate} {
    MainWindow ctcpanel seti $plate L off
    MainWindow ctcpanel seti $plate C on
    MainWindow ctcpanel seti $plate R off
  }
  proc Right {plate} {
    MainWindow ctcpanel seti $plate L off
    MainWindow ctcpanel seti $plate C off
    MainWindow ctcpanel seti $plate R on
  }

}
#* SimpleMode:END *


