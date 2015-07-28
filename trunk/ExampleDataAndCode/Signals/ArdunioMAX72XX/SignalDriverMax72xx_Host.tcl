#!/usr/local/bin/tclkit
#**************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Mar 1 10:42:54 2015
#  Last Modified : <150727.1844>
#
#  Description	
#
#  Notes
#
#  History
#	
#**************************************************************************
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
#**************************************************************************

package require snit

snit::type SignalDriverMax72xx {
    ## SignalDriverMax72xx is a Snit type (OO class) that implements the host 
    # interface to the SignalDriverMax72xx program running on an Arduino.
    # It provides an abstraction of the serial port interface that controls
    # signals multiplexed by the MAX72xx chip.
    # This version assumes a that there is only one SignalDriverMax72xx driver
    # boards (1 to 8 signals, numbered 0 through 7) connected to the Arduino.
    # This version assumes that only these aspects are valid (case folded):
    #
    #   g_r (Green over Red -- Clear)
    #   y_r (Yellow over Red -- Approach)
    #   r_r (Red over Red -- [Absolute] Stop)
    #   r_g (Red over Green -- Slow Clear)
    #   r_y (Red over Yellow -- Approach Limited)
    #   dark (all lights off)
    #
    
    typecomponent validateaspects
    ## @private Validation type for aspects.
    typecomponent validatesignalnums
    ## @private Validation type for signal numbers.
    typeconstructor {
        ## Initialize the validation typecomponents.
        set validateaspects [snit::enum %%AUTO%% -values {g_r y_r r_r r_g r_y 
                             dark}]
        set validatesignalnums [snit::integer %%AUTO%% -min 0 -max 7]
    }
    typemethod validate {object} {
        ## Type validation typemethod
        # @param object An object to be validated.
        
        if {[catch {$object info type} thetype]} {
            error "Not a valid $type object: $object"
        } elseif {$thetype ne $type} {
            error "Not a valid $type object: $object" 
        } else {
            return $object
        }
    }
    
    variable portfd {}
    ## @private Variable to hold the port fd
    
    #* option for the portname
    option -portname -readonly yes -default /dev/ttyACM0
    constructor {args} {
        ## Constructor: open the port, configure it, set a readable file event, 
        # and prime the port.
        # @param name The name of the object to be created.
        # @param ... Options:
        # @arg -portname The name of the USB Serial port connecting to the Uno.
        
        set options(-portname) [from args -portname]
        set portfd [open $options(-portname) w+]
        fconfigure $portfd -mode 115200,n,8,2 -blocking no -buffering none \
              -handshake none -translation {crlf cr}
        fileevent $portfd readable [mymethod _ReadPort]
        puts $portfd {}
    }
    
    variable _ready no
    ## @private Variable to hold ready (for a command) state
    
    method _ReadPort {} {
        ## @private Method to gobble from the Arduino
        foreach {in out} [fconfigure $portfd -queue] {break}
        if {$in > 0} {
            set buffer [read $portfd $in]
            if {[string range $buffer end-1 end] eq ">>"} {
                set _ready yes
            } else {
                set _ready no
            }
        }
    }
    
    method dark {} {
        ## Method to turn off all LEDs
        
        # Wait for a prompt.
        if {!$_ready} {
            vwait [myvar _ready]
        }
        set _ready no
        # Send the command
        puts $portfd "D"
    }
    
    method set {signo aspect} {
        ## Method to set the aspect for one signal
        # @param signo Signal number
        # @param aspect The desired aspect
        
        # Validate the aspect
        $validateaspects validate [string tolower $aspect]
        # Validate the signal number
        $validatesignalnums validate $signo
        # Wait for a prompt.
        if {!$_ready} {
            vwait [myvar _ready]
        }
        # Form command
        set cmd [format {S %d %s} $signo $aspect]
        set _ready no
        # Send the command
        puts $portfd "$cmd"
    }
    
    destructor {
        ## Destructor: close the port.
        catch {close $portfd}
    }
}

package provide SignalDriverMax72xx_Host 1.0
