#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Jul 24 20:07:30 2015
#  Last Modified : <150725.1306>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2015  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#*****************************************************************************


package require Azatrax;# require the Azatrax package
package require snit;#    require the SNIT OO framework

snit::type C4TSMINI_Switch {
    ##
    # @brief Switch (turnout) operation using a Chubb SMINI board and a Circuits4Tracks Quad OD for OS detection
    #
    # @image html switch-C4TSMINI-thumb.png
    # @image latex switch-C4TSMINI.png "Switch controlled by a Chubb SMINI board with a Circuits4Tracks OS detection" width=5in
    #
    # Above is a typical switch (turnout) using an Chubb SMINI board to 
    # control a Circuitron Tortoise Switch Machine and to sense the point 
    # position and a Circuits4Track quad occupancy detector to sense 
    # occupation of the switch.
    #
    # Typical usage:
    #
    # @code
    # # Connect to the cmribus through a USB RS485 adapter at /dev/ttyUSB0
    # CmriSupport::CmriNode openport /dev/ttyUSB0
    # # SMINI board at address 0
    # CmriSupport::CmriNode SMINI0 -type SMINI -address 0
    # # Switch 1 is controled by bits 0 and 1 of output port 0
    # # Switch 1 points are sensed by bits 0 and 1 of input port 0
    # # Switch 1 OS is detected on bit 0 of input port 1
    # C4TSMINI_Switch switch1 -nodeobj SMINI0 -motorport 0 -motorbit 0 \
    #                       -pointsenseport 0 -pointsensebit 0 \
    #                       -plate SwitchPlate1 \
    #                       -ossensorport 1 -osbit 0
    # # Switch 2 is controled by bits 0 and 1 of output port 1
    # # Switch 2 points are sensed by bits 2 and 3 of input port 0
    # # Switch 2 OS is detected on bit 1 of input port 1
    # C4TSMINI_Switch switch2 -nodeobj SMINI0 -motorport 1 -motorbit 0 \
    #                       -pointsenseport 0 -pointsensebit 2 \
    #                       -plate SwitchPlate2 \
    #                       -ossensorport 1 -osbit 1
    # @endcode
    #
    # For the track work elements use "switchN occupiedp" for the track work
    # elements' occupied script and use "switchN pointstate" for the track 
    # work elements' state script. For the switch plate use 
    # "switchN motor normal" for the normal script and "switchN motor reverse"
    # for the reverse script.
    #
    # Then in the Main Loop, you would have:
    # @code
    # while {true} {
    #     MainWindow ctcpanel invoke Switch1
    #     MainWindow ctcpanel invoke Switch2
    #     MainWindow ctcpanel invoke SwitchPlate1
    #     MainWindow ctcpanel invoke SwitchPlate2
    #     update;# Update display
    # }
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    # SMINI related options
    # Node object
    option -nodeobj -readonly yes -default {}
    # Output port and bits for motor control
    option -motorport -readonly yes -default 0 -type {snit::integer -min 0}
    option -motorbit  -readonly yes -default 0 -type {snit::integer -min 0 -max 6}
    # Input port and bits for point sense
    option -pointsenseport -readonly yes -default 0 -type {snit::integer -min 0}
    option -pointsensebit -readonly yes -default 0 -type {snit::integer -min 0 -max 6}
    # Input port and bit for OS sense
    option -ossensorport -readonly yes -default 0 -type {snit::integer -min 0}
    option -osbit  -readonly yes -default 0 -type {snit::integer -min 0 -max 7}
    
    # Signal related options
    # The forward direction means entering at the point end.
    option -direction  -type {snit::enum -values {forward reverse}} \
          -default forward -configuremethod _settruedirection \
          -cgetmethod _gettruedirection
    # If the switch is installed opposite the overall traffic flow (eg it is 
    # a frog facing switch), then -forwarddirection needs to be set for
    # reverse operation.
    option -forwarddirection \
          -type {snit::enum -values {forward reverse}} -default forward \
          -readonly yes
    # The forward signal is the signal protecting the points
    option -forwardsignalobj -readonly yes -default {}
    # The previous block is the block connected to the points
    option -previousblock -default {}
    # The reverse main signal is the signal protecting the straight frog end
    option -reversemainsignalobj -readonly yes -default {}
    # The next main block is the block connected to the main frog end
    option -nextmainblock -default {}
    # The reverse divergent signal is the signal protecting the divergent frog end
    option -reversedivergentsignalobj -readonly yes -default {}
    # The next divergent block is the block connected to the divergent frog end
    option -nextdivergentblock -default {}
    # Switch Plate name (if any).
    option -plate -default {}
    
    component node
    ## @private SMINI node object
    variable isoccupied no
    ## @private Saved occupation state.
    typevariable _motorbits -array {
        normal 0x01
        reverse 0x02
    }
    ## @private Motor bit values
    typevariable _pointsense -array {
        0x00 unknown                                        
        0x01 normal
        0x02 reverse
        0x03 unknown
    }
    ## @private Point sense bit values
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a SR4_C4TSR4_Switch
        # type.
        # @param object Some object.
        
        if {$object eq ""} {
            return $object;# Empty or null objects are OK
        } elseif {[catch {$object info type} itstype]} {
            error "$object is not a $type";# object is not a SNIT type
        } elseif {$itstype eq $type} {
            return $object;# Object is of our type (SR4_C4TSR4_Switch)
        } else {
            error "$object is not a $type";# object is something else
        }
    }
    
    constructor {args} {
        ## @brief Constructor: initialize the switch object.
        #
        # Create a low level sensor object and install it as a component.
        # Install the switch's signals, motor, and point sense objects.
        #
        # @param name Name of the switch object
        # @param ... Options:
        # @arg -nodeobj Cmri node object
        # @arg -motorport Output port number for motor control.
        # @arg -motorbit First (of two) motor control bits.
        # @arg -pointsenseport Input port for point sense.
        # @arg -pointsensebit First (of two) point sense bits.
        # @arg -ossensorport Input port for OS sense.
        # @arg -osbit This defines the input bit on the input port for OS 
        # sense.
        # @arg -direction The current direction of travel. Forward always
        # means entering at the point end.
        # @arg -forwarddirection The @e logial forward direction.  Set this
        # to reverse for a frog facing switch.  Default is forward and it
        # is readonly and can only be set during creation.
        # @arg -forwardsignalobj The signal object protecting the points. 
        # Presumed to be a two headed signal, with the upper head relating to 
        # the main (straight) route and the lower head relating to the 
        # divergent route.  The upper head has three colors: red, yellow, and 
        # green. The lower head only two: red and green.
        # @arg -reversemainsignalobj The signal object protecting the straight 
        # frog end. Presumed to be single headed (with number plate).
        # @arg -reversedivergentsignalobj The signal object protecting the
        # divergent frog end. Presumed to be single headed (with number plate).
        # @arg -previousblock The block connected to the point end.
        # @arg -nextmainblock The block connected to the straight frog end.
        # @arg -nextdivergentblock The block connected to the divergent frog 
        # end.
        # @arg -plate The name of the switch plate for this switch.
        
        # Prefetch the -forwarddirection option.
        set options(-forwarddirection) [from args -forwarddirection]
        ## Process any other options
        $self configurelist $args
        set node [$self cget -nodeobj]
        if {$motor eq {}} {
            error "The -nodeobj option is required!"
        }
        set forwardsignal [$self cget -forwardsignalobj]
        set reversemainsignal [$self cget -reversemainsignalobj]
        set reversedivergentsignal [$self cget -reversedivergentsignalobj]
    }
    
    method _settruedirection {option value} {
        ## @private A method to fake direction for frog facing switches.
        # @param option This is always -direction.
        # @param value  Either forward or reverse.
        switch $options(-forwarddirection) {
            forward {
                set options($option) $value
            }
            reverse {
                switch $value {
                    forward {set options($option) reverse}
                    reverse {set options($option) forward}
                }
            }
        }
    }
    method _gettruedirection {option} {
        ## @private A method to fake direction for frog facing switches.
        # @param option This is always -direction.
        # @returns Either forward or reverse.
        
        switch $options(-forwarddirection) {
            forward {return $options($option)}
            reverse {
                switch $options($option) {
                    forward {return reverse}
                    reverse {return forward}
                }
            }
        }
    }
    
    method occupiedp {} {
        ## The occupiedp method returns yes or no (true or false) indicating
        # block (OS) occupation.
        # @returns Yes or no, indicating whether the OS is occupied.
        
        # First read the current sensor state.
        set inputs [$node inputs]
        set port [lindex $inputs [$self cget -ossensorport]]
        set bit  [expr {($port >> [$self cget -osbit]) & 0x01}]
        # The outputs of the OD are active negative, so we need to invert the
        # logic.
        set bit  [expr {(~$bit) & 0x01}]
        if {$bit == 1} {
            if {$isoccupied} {
                # Already entered the OS.
                return $isoccupied
            } else {
                # Just entered the OS
                set isoccupied yes
                $self _entering
                return $isoccupied
            }
        } else {
            if {$isoccupied} {
                # Just left the OS
                set isoccupied no
                $self _exiting
                return $isoccupied
            } else {
                # OS still unoccupied
                return $isoccupied
            }
        }
    }
    method pointstate {} {
        ## The pointstate method returns normal if the points are aligned to
        # the main route and reverse if the points are aligned to the divergent
        # route. If the state cannot be determined, a value of unknown is 
        # returned.
        # @returns Normal or reverse, indicating the point state.
        
        # Assume point state is unknown.
        set result unknown
        set inputs [$node inputs]
        set port [lindex $inputs [$self cget -pointsenseport]]
        set bits [expr {($port >> [$self cget -pointsensebit]) & 0x03}]
        set result $_pointsense($bits)
        if {[$self cget -plate] ne {}} {
            set plate [$self cget -plate]
            switch $result {
                normal {
                    MainWindow ctcpanel seti $plate N on
                    MainWindow ctcpanel seti $plate C off
                    MainWindow ctcpanel seti $plate R off
                }
                reverse {
                    MainWindow ctcpanel seti $plate N off
                    MainWindow ctcpanel seti $plate C off
                    MainWindow ctcpanel seti $plate R on
                }
                unknown {
                    MainWindow ctcpanel seti $plate N off
                    MainWindow ctcpanel seti $plate C on
                    MainWindow ctcpanel seti $plate R off
                }
            }
        }
        return $result
    }
    typevariable _routes 
    ## @private Route check validation object.
    typeconstructor {
        set _routes [snit::enum _routes -values {normal reverse}]
    }
    
    method motor {route} {
        ## The motor method sets the switch motor to align the points for the
        # specificed route.
        # @param route The desired route.  A value of normal means align the
        # points to the main (straight) route and a value of reverse means 
        # align the points to the divergent route.
        
        $_routes validate $route
        set mask [expr {0x03 << [$self cget -motorbit]}]
        set bits [expr {$_motorbits($route) << [$self cget -motorbit]}]
        $node setbitfield [$self cget -motorport] $mask $bits
    }
    method _entering {} {
        ## @protected Code to run when just entering the OS
        # Sets the signal aspects and propagates signal state.
        
        switch $options(-direction) {
            forward {
                # Forward direction, set point end signal and propagate back
                # from the points.
                if {$forwardsignal ne {}} {$forwardsignal setaspect {red red}}
                if {[$self cget -previousblock] ne {}} {
                    [$self cget -previousblock] propagate yellow $self -direction [$self cget -direction]
                }
            }
            reverse {
                # Reverse direction.
                switch [$self pointstate] {
                    normal {
                        # Set the main frog end signal and propagate down the
                        # main.
                        if {$reversemainsignal ne {}} {
                            $reversemainsignal setaspect red
                        }
                        if {[$self cget -nextmainblock] ne {}} {
                            [$self cget -nextmainblock] propagate yellow $self -direction [$self cget -direction]
                        }
                    }
                    reverse {
                        # Set the divergent frog end signal and propagate down 
                        # the divergent route.
                        if {$reversedivergentsignal ne {}} {
                            $reversedivergentsignal setaspect red
                        }
                        if {[$self cget -nextdivergentblock] ne {}} {
                            [$self cget -nextdivergentblock] propagate yellow $self -direction [$self cget -direction]
                        }
                    }
                }
            }
        }
    }
    method _exiting {} {
        ## @protected Code to run when about to exit the OS
    }
    method propagate {aspect from args} {
        ## @publicsection Method used to propagate distant signal states back down the line.
        # @param aspect The signal aspect that is being propagated.
        # @param from The propagating block. 
        # @param ... Options:
        # @arg -direction The direction of the propagation.
        
        set from [regsub {^::} $from {}]
        $self configurelist $args
        if {[$self occupiedp]} {return}
        
        switch $options(-direction) {
            forward {
                # Propagate back from the points.
                switch [$self pointstate] {
                    normal {
                        # Points are normal, upper head is a logical block 
                        # signal, but don't propagate against the points.                        
                        if {$from ne [regsub {^::} [$self cget -nextmainblock] {}]} {return}
                        if {$forwardsignal ne {}} {
                            $forwardsignal setaspect [list $aspect red]
                        }
                    }
                    reverse {
                        # Points are reversed, lower head is the controling 
                        # head, but  has no yellow.
                        # But don't propagate against the points.
                        if {$from ne [regsub {^::} [$self cget -nextdivergentblock] {}]} {return}
                        if {$forwardsignal ne {}} {
                            $forwardsignal setaspect [list red green]
                        }
                    }
                }
                # Propagate back from the points.
                if {$aspect eq "yellow"} {
                    if {[$self cget -previousblock] ne {}} {
                        [$self cget -previousblock] propagate green $self -direction [$self cget -direction]
                    }
                }
            }
            reverse {
                # Reverse direction, propagate towards the frog end.
                switch [$self pointstate] {
                    normal {
                        # Points normal, propagate down the main.
                        if {$reversemainsignal ne {}} {
                            $reversemainsignal setaspect $aspect
                        }
                        if {$aspect eq "yellow"} {
                            if {[$self cget -nextmainblock] ne {}} {
                                [$self cget -nextmainblock] propagate green $self -direction [$self cget -direction]
                            }
                        }
                    }
                    reverse {
                        # Points reversed, propagate down the divergent route.
                        if {$reversedivergentsignal ne {}} {
                            $reversedivergentsignal setaspect $aspect
                        }
                        if {$aspect eq "yellow"} {
                            if {[$self cget -nextdivergentblock] ne {}} {
                                [$self cget -nextdivergentblock] propagate green $self -direction [$self cget -direction]
                            }
                        }
                    }
                }
            }
        }
    }
}

package provide C4TSMINI_Switch 1.0
