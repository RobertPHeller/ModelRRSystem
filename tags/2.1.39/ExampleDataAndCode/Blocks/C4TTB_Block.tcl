#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Aug 1 09:57:53 2015
#  Last Modified : <150801.1029>
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

snit::type C4TTB_Block {
    ##
    # @brief Block occupation detection using Circuits4Tracks Quad Occupancy Detector and a CTI Train Brain
    #
    # @image html C4TTB_Block-thumb.png
    # @image latex C4TTB_Block.png "Block detection with a Circuits4Tracks Quad Occupancy Detector and a Train Brain" width=5in
    #
    # Above is a simple diagram for using Circuits4Tracks Quad Occupancy 
    # Occupancy board has four current sensors. One wires one side of the
    # track power (either DCC or DC) to a common rail and the other side
    # through the Circuits4Tracks Quad Occupancy Detector to rails isolated 
    # with gaps (possibly with insulating rail joiners).  This code uses
    # a CTI Train Brain to connect a Circuits4Tracks Quad Occupancy Detectors
    # to the computer via a CTI Acela computer interface.
    #
    #
    # Typical usage: 
    #
    # Four blocks in a loop:
    #
    # @code
    # # Connect to the CTI Acela via USB the serial interface at /dev/ttyACM0
    # ctiacela::CTIAcela acela /dev/ttyACM0
    # # The first four bits of the first Train Brain are wired to the Circuits4Tracks 
    # # Quad Occupancy Detector
    # C4TTB_Block block1 -acelaobj acela -address 0 -signalobj signal1
    # C4TTB_Block block2 -acelaobj acela -address 1 -signalobj signal2 -previousblock block1
    # C4TTB_Block block3 -acelaobj acela -address 2 -signalobj signal3 -previousblock block2
    # C4TTB_Block block4 -acelaobj acela -address 3 -signalobj signal4 -previousblock block3
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
    

    option -acelaobj -readonly yes -default {} -type ::ctiacela::CTIAcela
    option -address -readonly yes -default 0 -type ::ctiacela::addresstype
    option -forwardsignalobj -readonly yes -default {}
    option -reversesignalobj -readonly yes -default {}
    option -previousblock -type C4TTB_Block -default {}
    option -nextblock -type C4TTB_Block -default {}
    option -direction -type {snit::enum -values {forward reverse}} -default forward
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a C4TTB_Block
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
        # @arg -address The address of the sensor bit for this block.
        # This is an integer from 0 to 65535 inclusive. This option is 
        # read-only and can only be set at creation time.  The default is 0.
                # @arg -forwardsignalobj This block's forward signal. This option is 
        # read-only and can only be set at creation time.  The default is the 
        # empty string.
        # @arg -reversesignalobj This block's reverse signal. This option is 
        # read-only and can only be set at creation time.  The default is the 
        # empty string.
        # @arg -previousblock Previous block (next block in reverse) -- used 
        # for 'propagating' signal aspects and must be a C4TTB_Block type 
        # object.  The default is the empty string.
        # @arg -nextblock Next block (previous block in reverse) -- used for 
        # 'propagating' signal aspects and must be a C4TTB_Block type object.  
        # The default is the empty string.
        # @arg -direction Current running direction, either the word forward
        # or reverse.  The default is forward.
        # @par
        
        ## Process any options 
        $self configurelist $args
        set acela [$self cget -acelaobj]
        if {$acela eq {}} {
            error "The -acelaobj is required!"
        }
        # Install the signal component.
        set forwardsignal [$self cget -forwardsignalobj]
        set reversesignal [$self cget -reversesignalobj]
    }
    method occupiedp {} {
        ## The occupiedp method returns yes or no (true or false) indicating 
        # block occupation.
        
        # First read the current sensor state.
        set bit  [$acela Read [$self cget -address]]
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

package provide C4TTB_Block 1.0
    
