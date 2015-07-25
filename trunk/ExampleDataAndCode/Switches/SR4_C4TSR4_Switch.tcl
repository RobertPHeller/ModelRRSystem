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
#  Last Modified : <150724.2123>
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

snit::type SR4_C4TSR4_Switch {
    ##
    # @brief Switch (turnout) operation using 1/2 of a SR4
    #
    # @image html switch-SR4-C4TSR4.png
    # @image latex switch-SR4-C4TSR4.png "Switch controlled by a SR4 with a Circuits4Tracks OS detection using a second SR4" width=5in
    #
    # Above is a typical switch (turnout) using an Azatrax SR4 to control a
    # Circuitron Tortoise Switch Machine and to sense the point position and
    # a Circuits4Track quad occupancy detector and a second SR4 to sense 
    # occupation of the switch.
    #
    # Typical usage:
    #
    # @code
    # SR4 turnoutControl1 \
    #     -this [Azatrax_OpenDevice 0400001234 $::Azatrax_idSR4Product]
    # SR4 quadsense1 \
    #     -this [Azatrax_OpenDevice 0400001235 $::Azatrax_idSR4Product]
    #
    # # Disable inputs controlling outputs.
    # turnoutControl1 OutputRelayInputControl 0 0 0 0
    # quadsense1 OutputRelayInputControl 0 0 0 0
    # # Switch 1 is controlled and sensed by the lower 1/2 of turnoutControl1
    # SR4_C4TSR4_Switch switch1 -motorobj turnoutControl1 -motorhalf lower \
    #                       -pointsenseobj turnoutControl1 \
    #                       -pointsensehalf lower \
    #                       -ossensorobj quadsense1 -bit 0
    # # Switch2 is controlled and sensed by the upper 1/2 of turnoutControl1
    # SR4_C4TSR4_Switch switch2 -motorobj turnoutControl1 -motorhalf upper \
    #                       -pointsenseobj turnoutControl1 \
    #                       -pointsensehalf upper \
    #                       -ossensorobj quadsense1 -bit 1
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
    # Occupancy (OS) sensor
    option -ossensorobj -readonly yes -default {}
    option -bit -readonly yes -default 0 -type {snit::integer -min 0 -max 3}
    
    
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
    
    component motor
    ## @private Motor device (SR4 outputs)
    component pointsense
    ## @private Point sense device (SR4 inputs)
    component ossensor
    ## @private SR4 object
    variable isoccupied no
    ## @private Saved occupation state.
    typevariable sensemap -array {
        0 Sense_1_Latch
        1 Sense_2_Latch
        2 Sense_3_Latch
        3 Sense_4_Latch
    }
    ## @private Sensor bit mapping to sensor functions.

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
        # @arg -motorobj Object (SR4) that controls the motor.
        # @arg -motorhalf Which half: lower means Q1 and Q2, upper means Q3 
        # and Q4.
        # @arg -pointsenseobj Object (SR4) that senses the point state.
        # @arg -pointsensehalf Which half: lower means I1 and I2, upper means 
        # I3 and I4.
        # @arg -ossensorobj Object (SR4) that senses occupation (via the C4T)
        # @arg -bit This defines the input bit on the SR4 for this block as an
        # integer from 0 to 3, inclusive. This option is read-only and can 
        # only be set at creation time. The default is 0.
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
        # @arg -plate The name of the switch plate for this switch.
        # end.
        
        # Prefetch the -forwarddirection option.
        set options(-forwarddirection) [from args -forwarddirection]
        ## Process any other options
        $self configurelist $args
        set ossensor [from args -ossensorobj]
        if {$ossensor eq {}} {
            error "The -ossensorobj option is required!"
        }
        set motor [$self cget -motorobj]
        if {$motor eq {}} {
            error "The -motor option is required!"
        }
        set pointsense [$self cget -pointsenseobj]
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
}

