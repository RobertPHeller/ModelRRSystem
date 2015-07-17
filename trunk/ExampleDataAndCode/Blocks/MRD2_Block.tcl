#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Jul 12 11:27:53 2015
#  Last Modified : <150717.1338>
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




snit::type MRD2_Block {
    ##
    # @brief Block occupation detection using Azatrax MRD2Us
    #
    # @image html MRD2_Block-thumb.png
    # @image latex MRD2_Block.png "Block detection using a MRD2" width=5in
    #
    # Above is a simple diagram for using Azatrax MRD2Us for block occupation 
    # detection. The Azatrax MRD2U has two IR sensors and one can be use to test 
    # for entering a block and one for leaving a block.
    #
    # Typical usage:
    #
    #
    # Four blocks in a loop:
    #
    # @code
    # MRD2_Block block1 -sensorsn 0200001234 -forwardsignalobj signal1
    # MRD2_Block block2 -sensorsn 0200001235 -forwardsignalobj signal2 -previousblock block1
    # MRD2_Block block3 -sensorsn 0200001236 -forwardsignalobj signal3 -previousblock block2
    # MRD2_Block block4 -sensorsn 0200001237 -forwardsignalobj signal4 -previousblock block3
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
    
    
    option -sensorsn -readonly yes -default {}
    option -forwardsignalobj -readonly yes -default {}
    option -reversesignalobj -readonly yes -default {}
    option -previousblock -type MRD2_Block -default {}
    option -nextblock -type MRD2_Block -default {}
    option -direction -type {snit::enum -values {forward reverse}} -default forward
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a MRD2_Block
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
    ## @privatesection MRD2 object
    component forwardsignal
    ## Signal object (typically a three color, one head block signal 
    component reversesignal
    ## Signal object (typically a three color, one head block signal 
    
    constructor {args} {
        ## @publicsection @brief Constructor: initialize the block object.
        #
        # Create a low level sensor object and install it as a component.
        # Install the blocks signal (created elsewhere).
        #
        # @param name Name of the block object
        # @param ... Options:
        # @arg -sensorsn Serial number of the MRD2U for this block.
        # This option is read-only and must be set at creation time.
        # @arg -forwardsignalobj This block's forward signal. This option is 
        # read-only and can only be set at creation time.  The default is the 
        # empty string.
        # @arg -reversesignalobj This block's reverse signal. This option is 
        # read-only and can only be set at creation time.  The default is the 
        # empty string.
        # @arg -previousblock Previous block (next block in reverse) -- used 
        # for 'propagating' signal aspects and must be a MRD2_Block type 
        # object.  The default is the empty string.
        # @arg -nextblock Next block (previous block in reverse) -- used for 
        # 'propagating' signal aspects and must be a MRD2_Block type object.  
        # The default is the empty string.
        # @arg -direction Current running direction, either the word forward
        # or reverse.  The default is forward.
        # @par
        
        set options(-sensorsn) [from args -sensorsn];# prefetch the MRD2U's 
        #                                              serial number
        if {$options(-sensorsn) eq {}} {
            error "The -sensorsn is required!"
        }
        # Create a MRD object and install it as a component
        install sensor using MRD %%AUTO%% \
              -this [Azatrax_OpenDevice $options(-sensorsn) \
                     $::Azatrax_idMRDProduct]
        ## Process any other options 
        $self configurelist $args
        # Install the signal components.
        set forwardsignal [$self cget -forwardsignalobj]
        set reversesignal [$self cget -reversesignalobj]
    }
    method occupiedp {} {
        ## The occupiedp method returns yes or no (true or false) indicating 
        # block occupation.
        
        # First read the current sensor state.
        $sensor GetSenseData
        if {[$self cget -direction] eq "forward"} {
            if {[$sensor Sense_1]} {
                # Sensor one is covered -- a train is entering the block
                # Run the entering code and return yes
                $self _entering
                return yes
            } elseif {[$sensor Sense_2]} {
                # Sensor two is covered -- a train is leaving the block.
                # Run the exit code and return yes
                $self _exiting
                return yes
            } elseif {[$sensor Latch_1]} {
                # Neither sensor is covered, but the first sensor's latch is set.
                # This means that there is a train between the sensors -- the 
                # train is fully in the block.
                return yes
            } else {
                # All other cases: block is unoccupied.
                return no
            }
        } else {
            if {[$sensor Sense_2]} {
                # Sensor one is covered -- a train is entering the block
                # Run the entering code and return yes
                $self _entering
                return yes
            } elseif {[$sensor Sense_1]} {
                # Sensor two is covered -- a train is leaving the block.
                # Run the exit code and return yes
                $self _exiting
                return yes
            } elseif {[$sensor Latch_2]} {
                # Neither sensor is covered, but the first sensor's latch is set.
                # This means that there is a train between the sensors -- the 
                # train is fully in the block.
                return yes
            } else {
                # All other cases: block is unoccupied.
                return no
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


package provide MRD2_Block 1.0
