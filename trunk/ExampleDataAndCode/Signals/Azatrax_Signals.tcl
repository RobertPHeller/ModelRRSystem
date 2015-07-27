#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Jul 26 09:16:15 2015
#  Last Modified : <150726.1545>
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

namespace eval azatrax_signals {
## @defgroup Azatrax_Signals Using SR4s to Operate Signals
# @brief Classes to operate signals using SR4s.
#
# This file contains code to operate various sorts of signals using Azatrax 
# SR4s.
#
# Typical wiring for LED common anode signals:
# @image html Azatrax_Signals-thumb.png
# @image latex Azatrax_Signals.png "Connecting a three LED common anode signal to a SR4." width=5in
# See the specific classes for how they expect the signals to be wired.
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

snit::type OneHead3Color {
    ## @brief Single head signals, 3 color.
    #
    # Typically used for simple block signals.  One SR4, with Q1 connected to
    # the top lamp (green), Q2 connected to the middle lamp (yellow), and 
    # Q3 connected to the bottom lamp (red).
    #
    # Typical usage:
    #
    # @code
    # azatrax_signals::OneHead3Color blocksignal1 -signalsn 0400001234 -signalname Signal1
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    # Azatrax related options
    option -signalsn -readonly yes -default {}
    # Signal name
    option -signalname -readonly yes -default {}
    
    component signal
    ## @private Signal driver (SR4)
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a 
        # OneHead3Color type object.
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
        # @arg -signalsn Serial number of the SR4 that controls this signal.
        # @arg -signalname Name of the signal on the track work schematic.
        # @par
        
        # Prefetch the -signalsn option.
        set options(-signalsn) [from args -signalsn]
        if {$options(-signalsn) eq {}} {
            error "The -signalsn option is required!"
        }
        install signal using Azatrax_OpenDevice $options(-signalsn) \
              $::Azatrax_idSR4Product
        # Disconnect relays from inputs.
        $signal OutputRelayInputControl 0 0 0 0
        # Turn off all relays (set signal to dark aspect).
        $signal RelaysOff 1 1 1 0
    }
    
    method setaspect {aspect} {
        ## Set signal aspect.
        #
        # @param aspect New aspect color.
        
        signalcolors validate $aspect
        $signal RelaysOff 1 1 1 0
        set sig [$self cget -signal]
        if {$sig ne {}} {MainWindow ctcpanel setv $sig $aspect}
        switch $aspect {
            red {
                $signal RelaysOn 0 0 1 0
            }
            yellow {
                $signal RelaysOn 0 1 0 0
            }
            green {
                $signal RelaysOn 1 0 0 0
            }
        }
    }
}

snit::listtype twoaspectlist -minlen 2 -maxlen 2 -type signalcolors
## @typedef twoaspectlist
# @brief Aspects for two headed signals.
# This is a list of two aspect colors, the first element for the upper head 
# and the second element for the lower head.

snit::type TwoHead3over2 {
    ## @brief Two head signals, 3 over 2.
    #
    # Typically used for simple interlocking signals.  Two SR4s, with one
    # driving the top head: with Q1 connected to the top lamp (green), Q2 
    # connected to the middle lamp (yellow), and Q3 connected to the bottom 
    # lamp (red). The second SR4 wired to the lower head, its Q1 connected to 
    # the top lamp (green or yellow), and Q2 to the bottom lamp (red).
    #
    # Typical usage:
    #
    # @code
    # azatrax_signals::TwoHead3over2 interlocksignal1 \
    #                                -signalsnupper 0400001234 \
    #                                -signalsnlower 0400001235 \
    #                                -signalname Signal1
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    # Azatrax related options
    option -signalsnupper -readonly yes -default {}
    option -signalsnlower -readonly yes -default {}
    # Signal name
    option -signalname -readonly yes -default {}
    
    component signalupper
    ## @private Signal driver (SR4)
    component signallower
    ## @private Signal driver (SR4)
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a 
        # TwoHead3over2 type object.
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
        # @arg -signalsnupper Serial number of the SR4 that controls the upper
        # head of this signal.
        # @arg -signalsnlower Serial number of the SR4 that controls the lower
        # head of this signal.
        # @arg -signalname Name of the signal on the track work schematic.
        # @par
        
        # Prefetch the -signalsnupper and -signalsnlower options.
        set options(-signalsnupper) [from args -signalsnupper]
        if {$options(-signalsnupper) eq {}} {
            error "The -signalsnupper option is required!"
        }
        set options(-signalsnlower) [from args -signalsnlower]
        if {$options(-signalsnlower) eq {}} {
            error "The -signalsnlower option is required!"
        }
        install signalupper using Azatrax_OpenDevice $options(-signalsnupper) \
              $::Azatrax_idSR4Product
        install signallower using Azatrax_OpenDevice $options(-signalsnlower) \
              $::Azatrax_idSR4Product
        # Disconnect relays from inputs.
        $signalupper OutputRelayInputControl 0 0 0 0
        $signallower OutputRelayInputControl 0 0 0 0
        # Turn off all relays (set signal to dark aspect).
        $signalupper RelaysOff 1 1 1 0
        $signallower RelaysOff 1 1 0 0
    }
    
    method setaspect {aspect} {
        ## Set signal aspect.
        #
        # @param aspect New aspect color.
        
        twoaspectlist validate $aspect
        $signalupper RelaysOff 1 1 1 0
        $signallower RelaysOff 1 1 0 0
        set sig [$self cget -signal]
        if {$sig ne {}} {MainWindow ctcpanel setv $sig $aspect}
        switch [lindex $aspect 0] {
            red {
                $signalupper RelaysOn 0 0 1 0
            }
            yellow {
                $signalupper RelaysOn 0 1 0 0
            }
            green {
                $signalupper RelaysOn 1 0 0 0
            }
        }
        switch [lindex $aspect 1] {
            red {
                $signallower RelaysOn 0 1 0 0
            }
            green -
            yellow {
                # upper color (of lower head) is either green or yellow.
                $signallower RelaysOn 1 0 0 0
            }
        }
    }
    
}

snit::type TwoHead2over2 {
    ## @brief Two head signals, 2 over 2.
    #
    # Typically used for simple interlocking signals.  One SR4, driving both
    # heads: with Q1 connected to the top lamp (green) or the top head, Q2 
    # connected to the bottom lamp (red) of the top head. Then Q3 connected to 
    # the top lamp (green or yellow) of othe lower head, and Q4 to the bottom 
    # lamp (red) of the lower head.
    #
    # Typical usage:
    #
    # @code
    # azatrax_signals::TwoHead2over2 interlocksignal1 -signalsn 0400001234 \
    #                                -signalname Signal1
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    # Azatrax related options
    option -signalsn -readonly yes -default {}
    # Signal name
    option -signalname -readonly yes -default {}
    
    component signal
    ## @private Signal driver (SR4)
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a 
        # TwoHead2over2 type object.
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
        # @arg -signals Serial number of the SR4
        # @arg -signalname Name of the signal on the track work schematic.
        # @par
        
        # Prefetch the -signalsn option.
        set options(-signalsn) [from args -signalsn]
        if {$options(-signalsn) eq {}} {
            error "The -signalsn option is required!"
        }
        install signal using Azatrax_OpenDevice $options(-signalsn) \
              $::Azatrax_idSR4Product
        # Disconnect relays from inputs.
        $signal OutputRelayInputControl 0 0 0 0
        # Turn off all relays (set signal to dark aspect).
        $signal RelaysOff 1 1 1 1
    }
    
    method setaspect {aspect} {
        ## Set signal aspect.
        #
        # @param aspect New aspect color.
        
        twoaspectlist validate $aspect
        $signal RelaysOff 1 1 1 1
        set sig [$self cget -signal]
        if {$sig ne {}} {MainWindow ctcpanel setv $sig $aspect}
        switch [lindex $aspect 0] {
            red {
                $signal RelaysOn 0 1 0 0
            }
            yellow {}
            green {
                # upper color (of the upper head) is green.
                $signal RelaysOn 1 0 0 0
            }
        }
        switch [lindex $aspect 1] {
            red {
                $signal RelaysOn 0 0 0 1
            }
            green -
            yellow {
                # upper color (of the lower head) is either green or yellow.
                $signal RelaysOn 0 0 1 0
            }
        }
    }
    
}

snit::listtype threeaspectlist -minlen 3 -maxlen 3 -type signalcolors
## @typedef threeaspectlist
# @brief Aspects for three headed signals.
# This is a list of three aspect colors, the first element for the upper head 
# and the second element for the middle head, and finally the third element
# for the bottom head.

snit::type ThreeHead3over2over2 {
    ## @brief Three head signals, 3 over 2 over 2.
    #
    # Typically used for simple interlocking signals.  Two SR4s, with one
    # driving the top head: with Q1 connected to the top lamp (green), Q2 
    # connected to the middle lamp (yellow), and Q3 connected to the bottom 
    # lamp (red). The second SR4 wired to the middle and lower heads, its Q1 
    # connected to the top lamp (green or yellow) of the middle head, and Q2 
    # to the bottom lamp (red) of the middle head. Then Q3 is connected to the 
    # top lamp (green or yellow) of the bottom head, and Q4 connected to the 
    # bottom lamp (red) of the bottom head.
    #
    # Typical usage:
    #
    # @code
    # azatrax_signals::TwoHead3over2over2 interlocksignal1 \
    #                                -signalsnupper 0400001234 \
    #                                -signalsnlower 0400001235 \
    #                                -signalname Signal1
    # @endcode
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    
    # Azatrax related options
    option -signalsnupper -readonly yes -default {}
    option -signalsnlower -readonly yes -default {}
    # Signal name
    option -signalname -readonly yes -default {}
    
    component signalupper
    ## @private Signal driver (SR4)
    component signallower
    ## @private Signal driver (SR4)
    
    typemethod validate {object} {
        ## Type validating code
        # Raises an error if object is not either the empty string or a 
        # TwoHead3over2over2 type object.
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
        # @arg -signalsnupper Serial number of the SR4 that controls the upper
        # head of this signal.
        # @arg -signalsnlower Serial number of the SR4 that controls the lower
        # two heads of this signal.
        # @arg -signalname Name of the signal on the track work schematic.
        # @par
        
        # Prefetch the -signalsnupper and -signalsnlower options.
        set options(-signalsnupper) [from args -signalsnupper]
        if {$options(-signalsnupper) eq {}} {
            error "The -signalsnupper option is required!"
        }
        set options(-signalsnlower) [from args -signalsnlower]
        if {$options(-signalsnlower) eq {}} {
            error "The -signalsnlower option is required!"
        }
        install signalupper using Azatrax_OpenDevice $options(-signalsnupper) \
              $::Azatrax_idSR4Product
        install signallower using Azatrax_OpenDevice $options(-signalsnlower) \
              $::Azatrax_idSR4Product
        # Disconnect relays from inputs.
        $signalupper OutputRelayInputControl 0 0 0 0
        $signallower OutputRelayInputControl 0 0 0 0
        # Turn off all relays (set signal to dark aspect).
        $signalupper RelaysOff 1 1 1 0
        $signallower RelaysOff 1 1 1 1
    }
    
    method setaspect {aspect} {
        ## Set signal aspect.
        #
        # @param aspect New aspect color.
        
        threeaspectlist validate $aspect
        $signalupper RelaysOff 1 1 1 0
        $signallower RelaysOff 1 1 1 1
        set sig [$self cget -signal]
        if {$sig ne {}} {MainWindow ctcpanel setv $sig $aspect}
        # Top head
        switch [lindex $aspect 0] {
            red {
                $signalupper RelaysOn 0 0 1 0
            }
            yellow {
                $signalupper RelaysOn 0 1 0 0
            }
            green {
                $signalupper RelaysOn 1 0 0 0
            }
        }
        # Middle head
        switch [lindex $aspect 1] {
            red {
                $signallower RelaysOn 0 1 0 0
            }
            green -
            yellow {
                # upper color (of lower head) is either green or yellow.
                $signallower RelaysOn 1 0 0 0
            }
        }
        # Bottom head
        switch [lindex $aspect 2] {
            red {
                $signallower RelaysOn 0 0 0 1
            }
            green -
            yellow {
                # upper color (of lower head) is either green or yellow.
                $signallower RelaysOn 0 0 1 0
            }
        }
    }
}



## @}

}

package provide Azatrax_Signals 1.0
