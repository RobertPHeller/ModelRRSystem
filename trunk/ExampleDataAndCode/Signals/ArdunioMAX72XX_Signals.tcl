#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Jul 28 19:15:41 2015
#  Last Modified : <150817.1413>
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


package require SignalDriverMax72xx_Host;# Load low-level code
package require snit;#    require the SNIT OO framework 

namespace eval arduniomax72xx_signals {
    ## @defgroup arduniomax72xx_signals Using an Ardunio Uno and a MAX72XX to Operate Signals
    # @brief Classes to operate signals using an Ardunio Uno and a MAX72XX.
    #
    # The module contains code to operate various sorts of signals using
    # the hardware and code in the ArdunioMAX72XX folder.  See the 
    # documentation there for information on how things are wired, etc.
    # 
    # @{
    
snit::enum signalcolors -values {
    ## @enum signalcolors
    # @brief Basic signal colors.
    # The four values are dark, red, yellow, and green.
    
    dark
    ## Dark, all lamps off, implies red.
    
    red
    ## Red, generally stop or stop and proceed.
    
    yellow
    ## Yellow, generally approach.
    
    green
    ## Green, generally clear.
}

snit::listtype onetwoaspectlist -minlen 1 -maxlen 2 -type signalcolors
## @typedef twoaspectlist
# @brief Aspects for one or two headed signals.
# This is a list of one or two aspect colors, the first element for the upper 
# head (or only) and the second element for the lower head.

snit::type OneTwoHead3Color {
    ## @brief One or two heads signals, 3 colors per head.
    #
    # Typical usage:
    #
    # @code
    # # Load the low-level code
    # package require SignalDriverMax72xx_Host
    # # Connect to the Ardunio
    # SignalDriverMax72xx controlpoint1 -portname /dev/ttyACM0
    # # Allocate a signal
    # arduniomax72xx_signals::OneTwoHead3Color CP1w2 -driver controlpoint1 -signal 0
    # # Set aspect to Green over Red (clear)
    # CP1w2 setaspect {green red}
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    # Ardunio options
    option -signal -readonly yes -default 0 -type {snit::integer -min 0 -max 7}
    option -driver -readonly yes -default {} -type ::SignalDriverMax72xx
    # Signal name
    option -signalname -readonly yes -default {}
    
    component driver
    ## @private The SignalDriverMax72xx object.
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a 
        # OneTwoHead3Color type object.
        # @param object Some object.
        
        if {$object eq ""} {
            return $object;# Empty or null objects are OK
        } elseif {[catch {$object info type} itstype]} {
            error "$object is not a $type";# object is not a SNIT type
        } elseif {$itstype eq $type} {
            return $object;# Object is of our type.
        } else {
            error "$object is not a $type";# object is something else
        }
    }
    
    constructor {args} {
        ## @brief Constructor: initialize the signal object.
        #
        # Create a low level actuator object and install it as a component.
        #
        # @param name Name of the signal object.
        # @param ... Options:
        # @arg -driver SignalDriverMax72xx object.
        # @arg -signal Signal number on the MAX7200 board.
        # @arg -signalname Name of the signal on the track work schematic.
        # @par
        
        # Prefetch the -driver option.
        set options(-driver) [from args -driver]
        if {$options(-driver) eq {}} {
            error "The -driver option is required!"
        }
        set driver $options(-driver)
    }
    
    typevariable aspectmap -array {
        green g_r
        yellow y_r
        red r_r
        green-red g_r
        yellow-red y_r
        red-red r_r
        red-green r_g
        red-yellow r_y
        dark dark
    }
    ## @private Aspect map.
    
    method setaspect {aspect} {
        ## Set signal aspect.
        #
        # @param aspect New aspect color.
        
        onetwoaspectlist validate $aspect
        set ap [join $aspect -]
        if {![info exists aspectmap($ap)]} {
            error "Undefined aspect: $aspect"
        }
        $driver set [$self cget -signal] $aspectmap(ap)
        set sig [$self cget -signalname]
        if {$sig ne {}} {MainWindow ctcpanel setv $sig $aspect}
    }
}

## @}

}

package provide ArdunioMAX72XX_Signals 1.0
    


