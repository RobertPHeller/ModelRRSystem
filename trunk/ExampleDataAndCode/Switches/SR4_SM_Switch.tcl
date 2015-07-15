#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Jul 14 19:03:09 2015
#  Last Modified : <150715.1641>
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

snit::type SR4_SM_Switch {
    ##
    # @brief Switch (turnout) operation using 1/2 of a SR4
    #
    # @image html switch-SR4-MRD2-thumb.png
    # @image latex switch-SR4-MRD2.png "Switch controlled by a SR4 with MRD2 OS Detection" width=5in
    #
    # Above is a typical switch (turnout) using an Azatrax SR4 to control a
    # Circuitron Tortoise Switch Machine and to sense the point position and
    # an Azatrax MRD2 to sense occupation of the switch.
    # (A high resolution PDF and a Xtrkcad layout file are included.)
    #
    # Typical usage:
    #
    # @code
    # SR4 turnoutControl1 \
    #     -this [Azatrax_OpenDevice 0400001234 $::Azatrax_idSR4Product]
    # # Disable inputs controlling outputs.
    # turnoutControl1 OutputRelayInputControl 0 0 0 0
    # # Switch 1 is controlled and sensed by the lower 1/2 of turnoutControl1
    # SR4_SM_Switch switch1 -motorobj turnoutControl1 -motorhalf lower \
    #                       -pointsenseobj turnoutControl1 \
    #                       -pointsensehalf lower \
    #                       -ossensorsn 0200001234
    # # Switch2 is controlled and sensed by the upper 1/2 of turnoutControl1
    # SR4_SM_Switch switch2 -motorobj turnoutControl1 -motorhalf upper \
    #                       -pointsenseobj turnoutControl1 \
    #                       -pointsensehalf upper \
    #                       -ossensorsn 0200001235
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
    
    # Azatrax related options
    # Motor control (SR4 relays) 
    option -motorobj -readonly yes -default {}
    option -motorhalf -readonly yes -default lower \
          -type {snit::enum -values {lower upper}}
    # Point sense (SR4 inputs)
    option -pointsenseobj -readonly yes -default {}
    option -pointsensehalf -readonly yes -default lower \
          -type {snit::enum -values {lower upper}}
    # Occupency sensor (MRD2)
    option -ossensorsn -readonly yes -default {}
    option -diverttimeout -default 10.0 -type {snit:: -min 1.0 -max 60.0}
    
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
    
    component motor
    ## @private Motor device (SR4 outputs)
    component pointsense
    ## @private Point sense device (SR4 inputs)
    component ossensor
    ## @private Occupency sensor (MRD2)
    component forwardsignal
    ## @private Signal at the points
    component reversemainsignal
    ## @private Signal at the straight frog end
    component reversedivergentsignal
    ## @private Signal at the divergent frog end
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a SR4_SM_Switch
        # type.
        # @param object Some object.
        
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
    
    constructor {args} {
        ## @brief Constructor: initialize the switch object.
        #
        # Create a low level sensor object and install it as a component.
        # Install the switch's signals, motor, and point sense objects.
        #
        # @param name Name of the switch object
        # @param ... Options:
        # @arg -motorobj Object (SR4) that controls the motor.
        # @arg -motorhalf Which half: lower means Q1 and Q2, upper means Q3 
        # and Q4.
        # @arg -pointsenseobj Object (SR4) that senses the point state.
        # @arg -pointsensehalf Which half: lower means I1 and I2, upper means 
        # I3 and I4.
        # @arg -ossensorsn Serial number of the MRD2 that is sensing OS.
        # @arg -diverttimeout Timeout, in seconds to allow for a train to
        # clear the turnout when going on a divergent route.
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
        
        # Prefetch the -forwarddirection option.
        set options(-forwarddirection) [from args -forwarddirection]
        # Prefetch the MRD2U's serial number
        set options(-ossensorsn) [from args -ossensorsn]
        if {$options(-ossensorsn) eq {}} {
            error "The -ossensorsn option is required!"
        }
        install ossensor using MRD %%AUTO%% \
              -this [Azatrax_OpenDevice $options(-ossensorsn) \
                     $::Azatrax_idMRDProduct]
        ## Process any other options
        $self configurelist $args
        set motor [$self cget -motorobj]
        if {$motor eq {}} {
            error "The -motor option is required!"
        }
        set pointsense [$self cget -pointsenseobj]
        if {$pointsense eq {}} {
            error "The -pointsense option is required!"
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
        
        $ossensor GetStateData;# Fetch state
        if {$options(-direction) eq "forward"} {
            if {[$ossensor Sense_1]} {
                # Just entering the switch from the point end.
                $self _entering
                return yes
            } elseif {[$ossensor Latch_1]} {
                # Gone past sense 1, but not yet at sense 2.
                $ossensor Stopwatch fract seconds minutes hours
                set fseconds [expr {($fract/100.0)+$seconds+($minutes*60)+($hours*60*60)}]
                if {[$self pointstate] eq "reverse" && 
                    $fseconds > [$self cget -diverttimeout]} {
                    # Divergent timeout: 'fake' a trip of sensor 2.
                    $ossensor SetChan2
                    $ossensor ResetStopwatch
                    $self _exiting
                    return no
                } else {
                    return yes
                }
            } elseif {$ossensor Sense_2} {
                # At sense 2 -- just leaving
                $self _exiting
                return yes
            } else {
                $ossensor ResetStopwatch
                return no
            }
        } else {
            # Reverse direction.
            if {[$self pointstate] eq "normal"} {
                # Points are normal -- entry is Sense_2, exit is Sense_1.
                if {[$ossensor Sense_2]} {
                    # Just entering the switch from the main frog end.
                    $self _entering
                    return yes
                } elseif {[$ossensor Latch_2]} {
                    # Gone past sense 2, but not yet at sense 1.
                    return yes
                } elseif {[$ossensor Sense_1]} {
                    # Just leaving the switch at the point end.
                    $self _exiting
                    return yes
                } else {
                    return no
                }
            } else {
                # Points are reversed -- entry is not detectable, only exit!
                if {[$ossensor Sense_1]} {
                    # Just leaving the switch at the point end.
                    # Fake an entrance and then exit.
                    $self _entering
                    $self _exiting
                    return yes
                } else {
                    return no;# Just a guess!
                }
            }
        }
    }
    method pointstate {} {
        ## The pointstate method returns normal if the points are aligned to
        # the main route and reverse if the points are aligned to the divergent
        # route. If the state cannot be determined, a value of unknown is 
        # returned.
        # @returns Normal or reverse, indicating the point state.
        
        # Fetch state
        $pointsense GetStateData
        if {[$self cget -pointsensehalf] eq "lower"} {
            if {[$pointsense Sense_1_Live]} {
                return normal
            } elseif {[$pointsense Sense_2_Live]} {
                return reverse
            } else {
                return unknown
            }
        } else {
            if {[$pointsense Sense_3_Live]} {
                return normal
            } elseif {[$pointsense Sense_4_Live]} {
                return reverse
            } else {
                return unknown
            }
        }
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
        switch $route {
            normal {
                if {[$self cget -motorhalf] eq "lower"} {
                    $motor RelaysOff 1 1 0 0
                    $motor RelaysOn  1 0 0 0
                } else {
                    $motor RelaysOff 0 0 1 1
                    $motor RelaysOn  0 0 1 0
                }
                if {$reversedivergentsignal ne {}} {
                    $reversedivergentsignal setaspect red
                }
            }
            reverse {
                if {[$self cget -motorhalf] eq "lower"} {
                    $motor RelaysOff 1 1 0 0
                    $motor RelaysOn  0 1 0 0
                } else {
                    $motor RelaysOff 0 0 1 1
                    $motor RelaysOn  0 0 0 1
                }
                if {$reversemainsignal ne {}} {
                    $reversemainsignal setaspect red
                }
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
                    [$self cget -previousblock] propagate yellow -direction [$self cget -direction]
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
                            [$self cget -nextmainblock] propagate yellow -direction [$self cget -direction]
                        }
                    }
                    reverse {
                        # Set the divergent frog end signal and propagate down 
                        # the divergent route.
                        if {$reversedivergentsignal ne {}} {
                            $reversedivergentsignal setaspect red
                        }
                        if {[$self cget -nextdivergentblock] ne {}} {
                            [$self cget -nextdivergentblock] propagate yellow -direction [$self cget -direction]
                        }
                    }
                }
            }
        }
    }
    method _exiting {} {
        ## @protected Code to run when about to exit the OS
    }
    method propagate {aspect args} {
        ## Propagate signals.
        
        $self configurelist $args
        if {[$self occupiedp]} {return}
        switch $options(-direction) {
            forward {
                # Propagate back from the points.
                switch [$self pointstate] {
                    normal {
                        # Points are normal, upper head is a logical block 
                        # signal
                        if {$forwardsignal ne {}} {
                            $forwardsignal setaspect [list $aspect red]
                        }
                    }
                    reverse {
                        # Points are reversed, lower head is the controling 
                        # head, but  has no yellow.
                        if {$forwardsignal ne {}} {
                            $forwardsignal setaspect [list red green]
                        }
                    }
                }
                # Propagate back from the points.
                if {$aspect eq "yellow"} {
                    if {[$self cget -previousblock] ne {}} {
                        [$self cget -previousblock] propagate green -direction [$self cget -direction]
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
                                [$self cget -nextmainblock] propagate green -direction [$self cget -direction]
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
                                [$self cget -nextdivergentblock] propagate green -direction [$self cget -direction]
                            }
                        }
                    }
                }
            }
        }
    }
}


package provide SR4_SM_Switch 1.0
