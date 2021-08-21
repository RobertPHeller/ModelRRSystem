#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Oct 13 21:45:14 2018
#  Last Modified : <210821.1554>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
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

## @defgroup LinuxGpio LinuxGpio
#  @brief Linux GPIO interface, using sysfs.
#
# This is the portable implementation of GPIO under Linux, using the
# sysfs file system (/sys/class/gpio/...).  This code should work on
# all SBC / development boards that run Linux (Raspberry Pis, Beagle 
# Bones, Banana Pis, etc.).
#
#  @author Robert Heller @<heller\@deepsoft.com@>
#
#  @{



package require snit

namespace eval linuxgpio {
    ## @brief Linux GPIO Interface.
    #
    # This is the portable implementation of GPIO under Linux, using the
    # sysfs file system (/sys/class/gpio/...).  This code should work on
    # all SBC / development boards that run Linux (Raspberry Pis, Beagle 
    # Bones, Banana Pis, etc.).
    #
    #  @author Robert Heller @<heller\@deepsoft.com@>
    #
    #  @section linuxgpio_package Package provided
    #
    # LinuxGpio 1.0.0
    #
    
    snit::integer pinnotype -min 0
    ## Pin number type, a positive integer.
    snit::enum pindirection -values {
        ## @enum pindirection
        # Pin direction and initial type code.
        in
        ## Input Pin.
        out
        ## Output Pin.
        high
        ## Output Pin, initialized to high.
        low
        ## Output Pin, initialized to low.
    }
    snit::type LinuxGpio {
        ## @brief Base generic GPIO interface class.
        #
        # (Use one of the specialized classes.)
        #
        # This class implements the basic interface for a GPIO pin.
        # The pin is set up, its direction configured and its value
        # is optionally initialized.
        #

        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @arg -direction The pin direction, readonly, defaults to in
        #                 can be one of in, out, high, or low.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        typevariable EXPORT "/sys/class/gpio/export"
        ## @privatesection The name of the export control file.
        typevariable UNEXPORT "/sys/class/gpio/unexport"
        ## The name of the unexport control file.
        typevariable DIRECTIONFMT "/sys/class/gpio/gpio%d/direction"
        ## The format string to generate the name of the direction 
        # control file.
        typevariable VALUEFMT "/sys/class/gpio/gpio%d/value"
        ## The format string to generate the name of the value file.
        option -pinnumber -default 0 -type linuxgpio::pinnotype -readonly yes
        option -direction -default in -type linuxgpio::pindirection -readonly yes
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            #
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @arg -direction The pin direction, readonly, defaults to in
            #                 can be one of in, out, high, or low.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            
            $self configurelist $args
            #puts stderr "*** $type create $self: [$self configure]"
            #puts stderr "*** $type create $self: EXPORT is $EXPORT"
            if {[catch {open $EXPORT w} exportFp]} {
                error "Could not export pin: $exportFp"
            }
            puts $exportFp [format %d [$self cget -pinnumber]]
            close $exportFp
            set dirfile [format $DIRECTIONFMT [$self cget -pinnumber]]
            set start [clock milliseconds]
            while {true} {
                set g [file attributes $dirfile -group]
                #puts stderr "*** $type create $self: g is $g"
                if {$g eq "gpio"} {break}
            }
            while {true} {
                set perms [file attributes $dirfile -permissions]
                #puts stderr "*** $type create $self: perms are $perms"
                if {$perms eq "00770"} {break}
            }
            set delta [expr {[clock milliseconds] - $start}]
            #puts stderr "*** $type create $self: delta = $delta"
            #puts stderr "*** $type create $self: [glob {/sys/class/gpio/*}]"
            #puts stderr "*** $type create $self: after export"
            #puts stderr "*** $type create $self: dirfile is '$dirfile'"
            #puts stderr "*** $type create $self: dirfile's attrs: [file attributes $dirfile]"
            if {[catch {open $dirfile w} dirFp]} {
                error "Could not set pin direction: $dirFp"
            }
            puts $dirFp [$self cget -direction]
            close $dirFp
            #puts stderr "*** $type create $self: after set direction"
        }
        method read {} {
            ## Read the value of the pin.
            #
            # @return The value of the pin, 1 or 0.
            #
            
            if {[catch {open [format $VALUEFMT [$self cget -pinnumber]] r} valFp]} {
                error "Could not read pin: $valFp"
            }
            set v [::read $valFp 1]
            close $valFp
            return $v
        }
        method write {value} {
            ## Write value to the pin.
            #
            # @param value The value to write, either 1 or any 
            # non-zero value for high or 0 for low.
            #
            
            if {[catch {open [format $VALUEFMT [$self cget -pinnumber]] w} valFp]} {
                error "Could not write pin: $valFp"
            }
            puts $valFp $value
            close $valFp
        }
        method is_output {} {
            ## Returns a boolean value indicating whether the pin is
            # an output pin or not.
            #
            # @return A boolean flag, true if this is an output, false
            # if it is an input.
            #
            
            if {[catch {open [format $DIRECTIONFMT [$self cget -pinnumber]] r} dirFp]} {
                error "Could not get pin direction: $dirFp"
            }
            set dir [gets $dirFp]
            close $dirFp
            return [expr {$dir ne "in"}]
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            if {[catch {open $UNEXPORT w} unexportFp]} {
                error "Could not unexport pin: $unexportFp"
            }
            puts $unexportFp [format %d [$self cget -pinnumber]]
            close $unexportFp
        }
        method Set {} {
            ## Set the pin to logic true.
            
            $self write 1
        }
        method Clr {} {
            ## Set the pin to logic false.
            
            $self write 0
        }
        method Get {} {
            ## Get the pin's logic state.
            
            return [expr {[$self read] != 0}]
        }
    }
    
    snit::type GpioOutputSafeLow {
        ## @brief Output pin, initialized to low.
        #
        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        component basepin
        ## @privatesection The base pin.
        delegate option -pinnumber to basepin
        delegate method * to basepin
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            #puts stderr "$type create $self $args"
            install basepin using linuxgpio::LinuxGpio %AUTO% \
                  -pinnumber [from args -pinnumber] \
                  -direction low
            $self configurelist $args
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            $basepin destroy
        }
    }
    snit::type GpioOutputSafeHigh {
        ## @brief Output pin, initialized to high.
        #
        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        component basepin
        ## @privatesection The base pin.
        delegate option -pinnumber to basepin
        delegate method * to basepin
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            
            install basepin using linuxgpio::LinuxGpio %AUTO% \
                  -pinnumber [from args -pinnumber] \
                  -direction high
            $self configurelist $args
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            $basepin destroy
        }
    }
    snit::type GpioOutputSafeLowInverted {
        ## @brief Output pin, initialized to low, with inverted logic.
        #
        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        component basepin
        ## @privatesection The base pin.
        delegate option -pinnumber to basepin
        delegate method * to basepin
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            
            install basepin using linuxgpio::LinuxGpio %AUTO% \
                  -pinnumber [from args -pinnumber] \
                  -direction low
            $self configurelist $args
        }
        method Set {} {
            ## Set the pin to true (logic low).
            
            $basepin Clr
        }
        method Clr {} {
            ## Set the pin to false (logic high).
            
            $basepin Set
        }
        method Get {} {
            ## Get the pin's logic state.
            # @return The pin state (low is true, high is false).
            
            return [expr {![$basepin Get]}]
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            $basepin destroy
        }
    }
    snit::type GpioOutputSafeHighInvert {
        ## @brief Output pin, initialized to high, inverted.
        #
        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        component basepin
        ## @privatesection The base pin.
        delegate option -pinnumber to basepin
        delegate method * to basepin
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            
            install basepin using linuxgpio::LinuxGpio %AUTO% \
                  -pinnumber [from args -pinnumber] \
                  -direction high
            $self configurelist $args
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            $basepin destroy
        }
        method Set {} {
            ## Set the pin to true (logic low).
            
            $basepin Clr
        }
        method Clr {} {
            ## Set the pin to false (logic high).
            
            $basepin Set
        }
        method Get {} {
            ## Get the pin's logic state.
            # @return The pin state (low is true, high is false).
            
            return [expr {![$basepin Get]}]
        }
    }
    snit::type GpioInputActiveHigh {
        ## @brief Input pin, active high (high is true).
        #
        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        component basepin
        ## @privatesection The base pin.
        delegate option -pinnumber to basepin
        delegate method * to basepin
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            
            install basepin using linuxgpio::LinuxGpio %AUTO% \
                  -pinnumber [from args -pinnumber] \
                  -direction in
            $self configurelist $args
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            $basepin destroy
        }
    }
    snit::type GpioInputActiveLow {
        ## @brief Input pin, active low (low is true).
        #
        # @param name Name of the pin.
        # @param ... Options:
        # @arg -pinnumber The pin number, readonly, defaults to 0 and
        #                 can be any positive integer.
        # @par
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        component basepin
        ## @privatesection The base pin.
        delegate option -pinnumber to basepin
        delegate method * to basepin
        constructor {args} {
            ## @publicsection Constructor, used to set up the GPIO pin.
            # The pin number is written to the export control file and
            # then the pin's diection control file is computed and the
            # pin's direction is written.
            #
            # @param name The name of the pin.
            # @param ... Options:
            # @arg -pinnumber The pin number, readonly, defaults to 0 and
            #                 can be any positive integer.
            # @par
            # @author Robert Heller @<heller\@deepsoft.com@>
            #
            
            install basepin using linuxgpio::LinuxGpio %AUTO% \
                  -pinnumber [from args -pinnumber] \
                  -direction in
            $self configurelist $args
        }
        destructor {
            ## Destructor. Unexport the pin.
            #
            
            $basepin destroy
        }
        method Get {} {
            ## Get the pin's logic state.
            # @return The pin state (low is true, high is false).
            
            return [expr {![$basepin Get]}]
        }
    }
}

## @}

package provide LinuxGpio 1.0.0
