#****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Jul 13 10:23:04 2015
#  Last Modified : <150716.1213>
#
#  Description	
#
#  Notes
#
#  History
#	
#****************************************************************************
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
#****************************************************************************

package require Azatrax;# require the Azatrax package
package require snit;#    require the SNIT OO framework


snit::type C4TSR4_Block {
    ##
    # @brief Block occupation detection using Circuits4Tracks Quad Occupancy Detectors and Azatrax SR4s
    #
    # @verbatim
    # o
    # |
    # ----------------------------------------------------------------
    # ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    # :---------------------------------------------------------------
    # Rail Gap         >=== traffic direction ===>             
    # @endverbatim
    #
    # Above is a simple diagram for using Circuits4Tracks Quad Occupancy 
    # Detectors for block occupation detection. A Circuits4Tracks Quad 
    # Occupancy board has four current sensors. One wires one side of the
    # track power (either DCC or DC) to a common rail and the other side
    # through the Circuits4Tracks Quad Occupancy Detector to rails isolated
    # with gaps (possibly with insulating rail joiners).  This code uses
    # Azatrax SR4s to connect a Circuits4Tracks Quad Occupancy Detectors
    # to the computer via USB.  A small circuit board with two ASSR-4128s 
    # (dual Solid State Relays) and four 1,000 Ohm resistors and some headers 
    # connects the Circuits4Tracks board to the SR4.
    #
    # Typical usage:
    #
    #
    # Four blocks in a loop:
    #
    # @code
    # SR4 quadsense1 -this [Azatrax_OpenDevice 0400001234 $::Azatrax_idSR4Product]
    # C4TSR4_Block block1 -sensorobj quadsense1 -bit 0 -signalobj signal1
    # C4TSR4_Block block2 -sensorobj quadsense1 -bit 1 -signalobj signal2 -previousblock block1
    # C4TSR4_Block block3 -sensorobj quadsense1 -bit 2 -signalobj signal3 -previousblock block2
    # C4TSR4_Block block4 -sensorobj quadsense1 -bit 3 -signalobj signal4 -previousblock block3
    # block1 configure -previousblock block4
    # @endcode
    # A Schematic of the layout would look like this:    
    # @image html 4circleblocks.png
    # @image latex 4circleblocks.png "Four block circle" width=3in
    # For the track work elements use "blockN occupiedp" for the track work 
    # elements' occupied command:
    # eg Block1 would have 'block1 occupiedp' as its occupied command, that is 
    # its edit window would look like:
    # @image html EditingBlock1.png
    # @image latex EditingBlock1.png "Editing Block1" width=5in
    # The other three blocks would be similar.
    #
    # 
    # Then in the Main Loop, you would have:
    # @code
    # while {true} { 
    #     MainWindow ctcpanel invoke Block1
    #     MainWindow ctcpanel invoke Block2
    #     MainWindow ctcpanel invoke Block3
    #     MainWindow ctcpanel invoke Block4
    #     update;# Update display
    # }
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    option -sensorobj -readonly yes -default {}
    option -bit -readonly yes -default 0 -type {snit::integer -min 0 -max 3}
    option -forwardsignalobj -readonly yes -default {}
    option -reversesignalobj -readonly yes -default {}
    option -previousblock -type C4TSR4_Block -default {}
    option -nextblock -type C4TSR4_Block -default {}
    option -direction -type {snit::enum -values {forward reverse}} -default forward
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a C4TSR4_Block
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
    component sensor
    ## @privatesection SR4 object
    component forwardsignal
    ## Signal object (typically a three color, one head block signal 
    component reversesignal
    ## Signal object (typically a three color, one head block signal 
    variable isoccupied no
    ## Saved occupation state.
    typevariable sensemap -array {
        0 Sense_1_Latch
        1 Sense_2_Latch
        2 Sense_3_Latch
        3 Sense_4_Latch
    }
    ## Sensor bit mapping to sensor functions.
    
    
    constructor {args} {
        ## @publicsection @brief Constructor: initialize the block object.
        #
        # Create a lowlevel sensor object and install it as a component.
        # Install the blocks signal (created elsewhere).
        #
        # @param name Name of the block object
        # @param ... Options:
        # @arg -sensorobj This is the SR4 for this (and up to three other 
        # blocks). This option is read-only and must be set at creation time.
        # @arg -bit This defines the input bit on the SR4 for this block as an
        # integer from 0 to 3, inclusive. This option is read-only and can 
        # only be set at creation time. The default is 0.
        # @arg -forwardsignalobj This block's forward signal. This option is 
        # read-only and can only be set at creation time.  The default is the 
        # empty string.
        # @arg -reversesignalobj This block's reverse signal. This option is 
        # read-only and can only be set at creation time.  The default is the 
        # empty string.
        # @arg -previousblock Previous block (next block in reverse) -- used 
        # for 'propagating' signal aspects and must be a C4TSR4_Block type 
        # object.  The default is the empty string.
        # @arg -nextblock Next block (previous block in reverse) -- used for 
        # 'propagating' signal aspects and must be a C4TSR4_Block type object.  
        # The default is the empty string.
        # @arg -direction Current running direction, either the word forward
        # or reverse.  The default is forward.
        # @par
        
        ## Process any options 
        $self configurelist $args
        # Install the sensor
        set sensor [$self cget -sensorobj]
        if {$sensor eq {}} {
            error "The -sensorobj is required!"
        }
        # Install the signal component.
        set signal [$self cget -signalobj]
    }
    method occupiedp {} {
        ## The occupiedp method returns yes or no (true or false) indicating 
        # block occupation.
        
        # First read the current sensor state.
        $sensor GetSenseData
        if {[$sensor $sensemap($options(-bit))]} {
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
    method _entering {} {
        ## @privatesection Method for entering a block.
        
        if {[$self cget -direction] eq "forward"} {
            # Set a red (stop and proceed) aspect.
            if {$forwardsignal ne ""} {$forwardsignal setaspect red}
            # Now propagate the signal to the previous block (if any)
            if {$options(-previousblock) ne {}} {
                # Set a yellow (approach) aspect on the previous block.
                $options(-previousblock) propagate yellow $self -direction forward
            }
        } else {
            if {$reversesignal ne ""} {$reversesignal setaspect red}
            # Now propagate the signal to the previous block (if any)
            if {$options(-nextblock) ne {}} {
                # Set a yellow (approach) aspect on the previous block.
                $options(-nextblock) propagate yellow $self -direction reverse
            }
        }
    }
    method _exiting {} {
        ## Method for exiting a block.
        
        # Nothing here -- could be used for any sort of exit handling.
    }
    method propagate {aspect from args} {
        ## @publicsection Method used to propagate distant signal states back down the line.
        # @param aspect The signal aspect that is being propagated.
        # @param from The propagating block (not used). 
        # @param ... Options:
        # @arg -direction The direction of the propagation.
        
        ## First process any options
        $self configurelist $args
        ## If we are already occupiedp, don't do anything else.
        if {[$self occupiedp]} {return}
        if {[$self cget -direction] eq "forward"} {
            # Set signal aspect
            if {$forwardsignal ne ""} {$forwardsignal setaspect $aspect}
            # If the new aspect was yellow, propagate a green (clear) signal
            if {$aspect eq "yellow"} {
                if {$options(-previousblock) ne {}} {
                    $options(-previousblock) propagate green $self -direction forward
                }
            }
        } else {
            # Set signal aspect
            if {$reversesignal ne ""} {$reversesignal setaspect $aspect}
            # If the new aspect was yellow, propagate a green (clear) signal
            if {$aspect eq "yellow"} {
                if {$options(-nextblock) ne {}} {
                    $options(-nextblock) propagate green $self -direction reverse
                }
            }
        }
    }
}
    
            

package provide C4TSR4_Block 1.0
