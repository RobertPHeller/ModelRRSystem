#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Aug 1 14:05:17 2015
#  Last Modified : <150816.1401>
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


package require CTIAcela;# require the CTIAcela package
package require snit;#    require the SNIT OO framework

snit::type TB_Switch {
    ##
    # @brief Switch (turnout) operation using a CTI Train Brain and Yardmaster
    #
    # @image html switch-CTITB-thumb.png
    # @image latex switch-CTITB.png "Switch controlled by CTI's Yardmaster and Train Brain" width=5in
    #
    # Above is a typical switch (turnout) using a CTI Yardmaster to control a 
    # Circuitron Tortoise Switch Machine and a CTI Train Brain to sense the 
    # point position and a Circuits4Track quad occupancy detector to sense 
    # occupation of the switch.
    #
    # Typical usage:
    #
    # @code
    # # Connect to the CTI network via a CTI Acela at /dev/ttyACM0
    # ctiacela::CTIAcela acela /dev/ttyACM0
    # # Switch 1 is controled by bits 0 and 1 of the Yardmaster, and sensed
    # # with bits 0 (occupation), 1 and 2 (point position).
    # TB_Switch switch1 -acelaobj acela -motoraddress 0 -osaddress 0 \
    #                   -pointsense 1 -plate SwitchPlate1
    # # Switch 2 is controled by bits 2 and 3 of the Yardmaster, and sensed
    # # with bits 3 (occupation), 4 and 5 (point position).
    # TB_Switch switch2 -acelaobj acela -motoraddress 2 -osaddress 3 \
    #                   -pointsense 4 -plate SwitchPlate2
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
    
    # CTI Options:
    option -acelaobj -readonly yes -default {} -type ::ctiacela::CTIAcela
    option -motoraddress -readonly yes -default 0 -type ::ctiacela::addresstype
    option -osaddress -readonly yes -default 0 -type ::ctiacela::addresstype
    option -pointsense -readonly yes -default 0 -type ::ctiacela::addresstype
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
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a TB_Switch
        # type.
        
        if {$object eq ""} {
            return $object;# Empty or null objects are OK
        } elseif {[catch {$object info type} itstype]} {
            error "$object is not a $type";# object is not a SNIT type
        } elseif {$itstype eq $type} {
            return $object;# Object is of our type (Block)
        } else {
            error "$object is not a $type";# object is something else
        }
    }
    component acela
    ## @private Acela object
    component forwardsignal
    ## @private Signal object (typically a three color, one head block signal 
    component reversesignal
    ## @private Signal object (typically a three color, one head block signal 
    variable isoccupied no
    ## @private Saved occupation state.
    
    constructor {args} {
        ## @brief Constructor: initialize the block object.
        #
        # Install an CTIAcela object as a component created elsewhere). 
        # Install the blocks signal (created elsewhere).
        #
        # @param name Name of the block object
        # @param ... Options:
        # @arg -acelaobj This is the CTIAcela object.
        # This option is read-only and must be set at creation time.
        # @arg -motoraddress The address of the motor control bits (two 
        # successive bits).
        # This is an integer from 0 to 65535 inclusive. This option is 
        # read-only and can only be set at creation time.  The default is 0.
        # @arg -osaddress The address of the sensor bit for this block.
        # This is an integer from 0 to 65535 inclusive. This option is 
        # read-only and can only be set at creation time.  The default is 0.
        # @arg -pointsense The address of the sensor bits for the point state
        # sense (two successive bits).
        # This is an integer from 0 to 65535 inclusive. This option is 
        # read-only and can only be set at creation time.  The default is 0.
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
        # @par
        
        # Prefetch the -forwarddirection option.
        set options(-forwarddirection) [from args -forwarddirection]
        # Process any options 
        $self configurelist $args
        set acela [$self cget -acelaobj]
        if {$acela eq {}} {
            error "The -acelaobj is required!"
        }
        # Install the signal component.
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
        # block occupation.
        
        # First read the current sensor state.
        set bit  [$acela Read [$self cget -osaddress]]
        if {$bit == 1} {
            if {$isoccupied} {
                # Already entered the block.
                return $isoccupied
            } else {
                # Just entered the block
                set isoccupied yes
                $self _entering
                return $isoccupied
            }
        } else {
            if {$isoccupied} {
                # Just left the block
                set isoccupied no
                $self _exiting
                return $isoccupied
            } else {
                # Block still unoccupied
                return $isoccupied
            }
        }
    }
    
    typevariable _pointsense -array {
        0x00 unknown                                        
        0x01 normal
        0x02 reverse
        0x03 unknown
    }
    ## @private Point sense bit values
    
    method pointstate {} {
        ## The pointstate method returns normal if the points are aligned to
        # the main route and reverse if the points are aligned to the divergent
        # route. If the state cannot be determined, a value of unknown is 
        # returned.
        # @returns Normal or reverse, indicating the point state.
        
        # Assume point state is unknown.
        set result unknown
        set bit0  [$acela Read [$self cget -pointsense]]
        set bit1  [$acela Read [expr {[$self cget -pointsense] + 1}]]
        set bits  [expr {$bit0 | ($bit1 << 1)}]
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
        $acela Deactivate [$self cget -motoraddress]
        $acela Deactivate [expr {[$self cget -motoraddress] + 1}]
        switch $route {
            normal {
                $acela Activate [$self cget -motoraddress]
            }
            reverse {
                $acela Activate [expr {[$self cget -motoraddress] + 1}]
            }
        }
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

package provide TB_Switch 1.0
