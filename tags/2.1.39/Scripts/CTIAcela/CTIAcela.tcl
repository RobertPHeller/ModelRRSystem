#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Jul 21 10:56:52 2015
#  Last Modified : <160911.1742>
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


## @defgroup CTIAcela CTIAcela
#  @brief CTI Acela Serial Port Interface.
#
# This is a cross-platform implementation of the host (computer) side of the
# CTI Acela Serial Port Interface.
#
# Basically, the way this code works is to use a SNIT class (described in the
# CTIAcela type) to interface to the serial port, which may have one or more
# CTI modules (Train Brain, Dash-8, Watchman, Signalman, Smart Cab, etc.).
# A given class instance interfaces to all of the modules attached to a given 
# serial port.
#
#  @author Robert Heller @<heller\@deepsoft.com@>
#
#  @{

package require gettext
package require snit 

namespace eval ctiacela {
    ##
    #  @brief CTI Acela Tcl Serial Port Interface.
    #
    #  @author Robert Heller @<heller\@deepsoft.com@>
    #
    #  @section CTIAcela_package Package provided
    #
    #  CTIAcela 1.0.0
    #
    
    snit::enum directiontype -values {forward reverse}
        ## @enum directiontype
        # @brief Direction type
        #
        # Either forward or reverse.
        #
    
    snit::enum lampcontroltype -values {off on blink reverseblink}
        ## @enum lampcontroltype
        # @brief Lamp control type
        #
        # One of off, on, blink, or reverseblink.
        #
    
    snit::enum selecttype -values {noise bounce gap dirty}
        ## @enum selecttype
        # @brief Filter select type.
        #
        # One of noise, bounce, gap, or dirty.
    
    snit::enum polaritytype -values {normal invert}
        ## @enum polaritytype
        # @brief Polarity type
        #
        # One of normal or invert.
    
    snit::integer addresstype -min 0 -max 65535
    ## @typedef unsigned short int addresstype
    # @brief Module address type.
    #
    # An integer in the range from 0 to 65535, inclusive.
    #
    
    snit::integer ubyte -min 0 -max 255
    ## @typedef unsigned char ubyte
    # @brief Unsigned byte type.
    #
    # An integer in the range from 0 to 255, inclusive.
    #
    
    snit::integer speedtype -min 0 -max 100
    ## @typedef int speedtype
    # @brief Speed type
    #
    # Integer in the range of 0 to 100, inclusive.
    
    snit::integer momtype -min 0 -max 7
    ## @typedef int momtype
    # @brief Momentium control type.
    #
    # Integer in the range of 0 to 7, inclusive.
    
    snit::integer filterthreshtype -min 0 -max 31
    ## @typedef int filterthreshtype
    # @brief  Filter threshold type.
    #
    # An integer from 0 to 31, inclusive.
    
    snit::type CTIAcela {
        ## @brief Main CTIAcela interface class. 
        #
        # @param name Name of the CTIAcela interface instance.
        # @param port Name of the serial port connected to the CTI Acela.
        # Either something like /dev/ttySN for real serial ports or 
        # /dev/ttyACM0 for a USB connected Acela.
        # @author Robert Heller @<heller\@deepsoft.com@>
        #
        
        #typevariable dummy {}
        # @private
        
        typevariable Responses -array {
            Success           0x00
            ProcessedOffline  0x01
            AddressOutOfRange 0x02
            UnknownCommand    0x03
            SRQSenseStateChg  0x81
            SRQCommLost       0x82
        }
        ## @private Responses
        
        typevariable Opcodes -array {
            Activate         0x01
            Deactive         0x02
            PulseOn          0x03
            PulseOff         0x04
            Blink            0x05
            ReverseBlink     0x06
            Control4         0x07
            Control8         0x08
            Control16        0x09
            Throttle         0x0A
            EmergencyStop    0x0B
            Signal2          0x0C
            Signal3          0x0D
            Signal4          0x0E
            SignalX          0x0F
            ConfigureSensor  0x10
            Read             0x11
            Read4            0x12
            Read8            0x13
            ReadAll          0x14
            ResetNetwork     0x15
            NetworkOnline    0x16
            NetworkOffline   0x17
            Poll             0x18
            ReadRevision     0x19
            Read16           0x1A
            SignalBrightness 0x1B
            SRQControl       0x1C
            Query            0x1D
        }
        ## @private Opcodes.
        
        typevariable LampBits -array {
            off           0x00
            on            0x01
            blink         0x02
            reverseblink  0x03
        }
        ## @private Lamp Bits
        
        typevariable FilterSelectBits -array {
            noise   0x00
            bounce  0x01
            gap     0x02
            dirty   0x03
        }
        ## @private Filter Select Bits
        
        typevariable CTI_DeviceMap -array {
            1 {Train Brain}
            2 Dash-8
            3 Watchman
            4 Signalman
            5 {Smart Cab}
            6 Switchman
            7 {Yard Master}
            8 Sentry
            255 {Unrecognized module}
        }
        ## @private CTI Module Map
        
        typemethod validate {object} {
            ## @public @brief Type validation method.
            # Validate object as a CTIAcela instance.
            #
            # @param object The object to validate.
            
            if {[catch {$object info type} thetype]} {
                error [_ "Not a CTIAcela: %s" $object]
            } elseif {$thetype ne $type} {
                error [_ "Not a CTIAcela: %s" $object]
            } else {
                return $object
            }
        }
        
        variable ttyfd
        ## @private Terminal file descriptor.
        
        option -srqhandler -default {}
        
        constructor {port args} {
            ## Constructor: open a connection to the CTI Acela.
            # @param name The name of this instance.
            # @param port Name of the serial port connected to theCTI Acela.
            # @param ... Options:
            # @arg -srqhandler Script to run when there is a sense state 
            # change.
            # @par
            
            $self configurelist $args
            if {$::tcl_platform(platform) eq "windows"} {
                ## Force Use of the "global NT object space" for serial port
                ## devices under MS-Windows.
                set port [format "\\\\.\\%s" $port]
            }
            if {[catch {open $port r+} ttyfd]} {
                set theerror $ttyfd
                catch {unset ttyfd}
                error [_ "Failed to open port %s because %s." $port $theerror]
                return
            }
            if {[catch {fconfigure $ttyfd -mode}]} {
                close $ttyfd
                catch {unset ttyfd}
                error [_ "%s is not a terminal port." $port]
                return
            }
            if {[catch {fconfigure $ttyfd -mode 9600,n,8,1 \
                 -blocking no -buffering none -encoding binary \
                 -translation binary -handshake none} err]} {
                close $ttyfd
                catch {unset ttyfd}
                error [_ "Cannot configure port %s because %s." $port $err]
                return
            }
            fileevent $ttyfd readable [mymethod _handleSRQ]
        }
        destructor {
            ## The destructor restores the serial port's state and closes it.
            if {![catch {set ttyfd}]} {close $ttyfd}
            catch {unset ttyfd}
        }
        variable dataavailable no
        ## @private Flag set to true (yes) when sensor data is available
        method HaveData {} {
            ## @returns Yes, if there is data available.
            return $dataavailable
        }
        variable networkonline yes
        ## @private Flag set to false (no) when the network goes offline.
        method OnlineP {} {
            ## @returns Yes, if the network is online.
            return $networkonline
        }
        method _handleSRQ {} {
            ## @private Handle a service request
            if {![$self _readbyte srq]} {return}
            if {$srq == $Responses(SRQSenseStateChg)} {
                set dataavailable yes
            } elseif {$srq == $Responses(SRQCommLost)} {
                set networkonline no
            }
            set srqhandler [$self cget -srqhandler]
            if {$srqhandler ne {}} {
                uplevel #0 "$srqhandler"
            }
        }
        proc highbyte {addr} {
            ## @private Return the high byte of address.
            # @param addr Address word (16-bits)
            # @returns upper 8 bits
            return [expr {($addr >> 8) & 0x0FF}]
        }
        proc lowbyte {addr} {
            ## @private Return the low byte of address.
            # @param addr Address word (16-bits)
            # @returns lower 8 bits
            return [expr {$addr  & 0x0FF}]
        }
        method Activate {address} {
            ## Activate a control.
            # @param address Address of the control.
            
            ::ctiacela::addresstype validate $address
            set response [$self _transmit [list $Opcodes(Activate) [highbyte $address] [lowbyte $address]]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Deactive {address} {
            ## Deactive a control.
            # @param address Address of the control.
            
            ::ctiacela::addresstype validate $address
            set response [$self _transmit [list $Opcodes(Deactive) [highbyte $address] [lowbyte $address]]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method PulseOn {address pulsewidth} {
            ## Pulse On a control.
            # @param address Address of the control.
            # @param pulsewidth Pulsewidth in 10ths of a second
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::ubyte validate $pulsewidth
            set response [$self _transmit [list $Opcodes(PulseOn) [highbyte $address] [lowbyte $address] $pulsewidth]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method PulseOff {address pulsewidth} {
            ## Pulse Off a control.
            # @param address Address of the control.
            # @param pulsewidth Pulsewidth in 10ths of a second
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::ubyte validate $pulsewidth
            set response [$self _transmit [list $Opcodes(PulseOff) [highbyte $address] [lowbyte $address] $pulsewidth]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Blink {address pulsewidth} {
            ##  Blink a control.
            # @param address Address of the control.
            # @param pulsewidth Pulsewidth in 10ths of a second
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::ubyte validate $pulsewidth
            set response [$self _transmit [list $Opcodes(Blink) [highbyte $address] [lowbyte $address] $pulsewidth]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method ReverseBlink {address pulsewidth} {
            ## Reverse Blink a control.
            # @param address Address of the control.
            # @param pulsewidth Pulsewidth in 10ths of a second
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::ubyte validate $pulsewidth
            set response [$self _transmit [list $Opcodes(ReverseBlink) [highbyte $address] [lowbyte $address] $pulsewidth]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Control4 {address c1 c2 c3 c4} {
            ## Configure 4 controls simultaneously.
            # @param address Address of the first control.
            # @param c1 First control status, boolean true activates, boolean 
            # false deactivates.
            # @param c2 Second control status, boolean true activates, boolean
            # false deactivates.
            # @param c3 Third control status, boolean true activates, boolean 
            # false deactivates.
            # @param c4 Fourth control status, boolean true activates, boolean 
            # false deactivates.
            
            ::ctiacela::addresstype validate $address
            ::snit::boolean validate $c1
            ::snit::boolean validate $c2
            ::snit::boolean validate $c3
            ::snit::boolean validate $c4
            set byte [pack4 $c1 $c2 $c3 $c4]
            set response [$self _transmit [list $Opcodes(Control4) [highbyte $address] [lowbyte $address] $byte]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Control8 {address c1 c2 c3 c4 c5 c6 c7 c8} {
            ## Configure 8 controls simultaneously.
            # @param address Address of the first control.
            # @param c1 First control status, boolean true activates, boolean 
            # false deactivates.
            # @param c2 Second control status, boolean true activates, boolean
            # false deactivates.
            # @param c3 Third control status, boolean true activates, boolean 
            # false deactivates.
            # @param c4 Fourth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c5 Fifth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c6 Sixth control status, boolean true activates, boolean
            # false deactivates.
            # @param c7 Seventh control status, boolean true activates, boolean 
            # false deactivates.
            # @param c8 Eighth control status, boolean true activates, boolean 
            # false deactivates.
            
            ::ctiacela::addresstype validate $address
            ::snit::boolean validate $c1
            ::snit::boolean validate $c2
            ::snit::boolean validate $c3
            ::snit::boolean validate $c4
            ::snit::boolean validate $c5
            ::snit::boolean validate $c6
            ::snit::boolean validate $c7
            ::snit::boolean validate $c8
            set byte [pack8 $c1 $c2 $c3 $c4 $c5 $c6 $c7 $c8]
            set response [$self _transmit [list $Opcodes(Control8) [highbyte $address] [lowbyte $address] $byte]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Control16 {address c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16} {
            ## Configure 16 controls simultaneously.
            # @param address Address of the first control.
            # @param c1 First control status, boolean true activates, boolean 
            # false deactivates.
            # @param c2 Second control status, boolean true activates, boolean
            # false deactivates.
            # @param c3 Third control status, boolean true activates, boolean 
            # false deactivates.
            # @param c4 Fourth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c5 Fifth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c6 Sixth control status, boolean true activates, boolean
            # false deactivates.
            # @param c7 Seventh control status, boolean true activates, boolean 
            # false deactivates.
            # @param c8 Eighth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c9 Ninth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c10 Tenth control status, boolean true activates, boolean
            # false deactivates.
            # @param c11 Eleventh control status, boolean true activates, boolean 
            # false deactivates.
            # @param c12 Twelth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c13 Thirteenth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c14 Fourteenth control status, boolean true activates, boolean
            # false deactivates.
            # @param c15 Fifteenth control status, boolean true activates, boolean 
            # false deactivates.
            # @param c16 Sixteenth control status, boolean true activates, boolean 
            # false deactivates.
            
            ::ctiacela::addresstype validate $address
            ::snit::boolean validate $c1
            ::snit::boolean validate $c2
            ::snit::boolean validate $c3
            ::snit::boolean validate $c4
            ::snit::boolean validate $c5
            ::snit::boolean validate $c6
            ::snit::boolean validate $c7
            ::snit::boolean validate $c8
            ::snit::boolean validate $c9
            ::snit::boolean validate $c10
            ::snit::boolean validate $c11
            ::snit::boolean validate $c12
            ::snit::boolean validate $c13
            ::snit::boolean validate $c14
            ::snit::boolean validate $c15
            ::snit::boolean validate $c16
            set byte2 [pack8 $c1 $c2 $c3 $c4 $c5 $c6 $c7 $c8]
            set byte1 [pack8 $c9 $c10 $c11 $c12 $c13 $c14 $c15 $c16]
            set response [$self _transmit [list $Opcodes(Control16) [highbyte $address] [lowbyte $address] $byte1 $byte2]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        proc pack4 {b1 b2 b3 b4} {
            ## @private pack 4 bits
            # @param b1 First bit
            # @param b2 Second bit
            # @param b3 Third bit
            # @param b4 Fourth bit
            # @returns a byte with the bits packed.
            set result 0
            if {$b1} {set result [expr {$result | 0x01}]}
            if {$b2} {set result [expr {$result | 0x02}]}
            if {$b3} {set result [expr {$result | 0x04}]}
            if {$b4} {set result [expr {$result | 0x08}]}
            return $result
        }
        proc pack8 {b1 b2 b3 b4 b5 b6 b7 b8} {
            ## @private pack 4 bits
            # @param b1 First bit
            # @param b2 Second bit
            # @param b3 Third bit
            # @param b4 Fourth bit
            # @param b5 Fifth bit
            # @param b6 Sixth bit
            # @param b7 Seventh bit
            # @param b8 Eighth bit
            # @returns a byte with the bits packed.
            set result 0
            if {$b1} {set result [expr {$result | 0x001}]}
            if {$b2} {set result [expr {$result | 0x002}]}
            if {$b3} {set result [expr {$result | 0x004}]}
            if {$b4} {set result [expr {$result | 0x008}]}
            if {$b5} {set result [expr {$result | 0x010}]}
            if {$b6} {set result [expr {$result | 0x020}]}
            if {$b7} {set result [expr {$result | 0x040}]}
            if {$b8} {set result [expr {$result | 0x080}]}
            return $result
        }
        method Throttle {address speed momentum brake direction idle} {
            ## Throttle command.
            # @param address Address of the throttle.
            # @param speed Speed (0-100).
            # @param momentum Momentum Control (0 minimum, 7 maximum).
            # @param brake Brake control (boolean: true is on).
            # @param direction Direction control (forward or reverse).
            # @param idle Idle Voltage Control (boolean: true is on).
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::speedtype validate $speed
            ::ctiacela::momtype validate $momentum
            ::snit::boolean validate $brake
            ::ctiacela::directiontype  validate $direction
            ::snit::boolean validate $idle
            set attributes $momentum
            if {$brake} {set attributes [expr {$attributes | 0x08}]}
            if {$direction eq "reverse"} {set attributes [expr {$attributes | 0x010}]}
            if {$idle} {set attributes [expr {$attributes | 0x020}]}
            set response [$self _transmit [list $Opcodes(Throttle) [highbyte $address] [lowbyte $address] $speed $attributes]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method EmergencyStop {} {
            ## Emergency Stop.  Stop all trains.
            
            set response [$self _transmit [list $Opcodes(EmergencyStop)]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Signal2 {address lamp1 lamp2 {yellow off}} {
            ## Control 2-lamp signals.  
            # @param address Address of first lamp.
            # @param lamp1 Lamp 1 control, one of off, on, blink, or 
            # reverseblink.
            # @param lamp2 Lamp 2 control, one of off, on, blink, or 
            # reverseblink.
            # @param yellow Yellow control, one of off, on, blink, or 
            # reverseblink.
            #
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::lampcontroltype validate $lamp1
            ::ctiacela::lampcontroltype validate $lamp2
            ::ctiacela::lampcontroltype validate $yellow
            set aspectbyte $LampBits($lamp1)
            set aspectbyte [expr {$aspectbyte | ($LampBits($lamp2) << 2)}]
            set aspectbyte [expr {$aspectbyte | ($LampBits($yellow) << 4)}]
            set response [$self _transmit [list $Opcodes(Signal2) [highbyte $address] [lowbyte $address] $aspectbyte]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Signal3 {address lamp1 lamp2 lamp3} {
            ## Control 3-lamp signals.  
            # @param address Address of first lamp.
            # @param lamp1 Lamp 1 control, one of off, on, blink, or 
            # reverseblink.
            # @param lamp2 Lamp 2 control, one of off, on, blink, or 
            # reverseblink.
            # @param lamp3 Lamp 3control, one of off, on, blink, or 
            # reverseblink.
            #
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::lampcontroltype validate $lamp1
            ::ctiacela::lampcontroltype validate $lamp2
            ::ctiacela::lampcontroltype validate $lamp3
            set aspectbyte $LampBits($lamp1)
            set aspectbyte [expr {$aspectbyte | ($LampBits($lamp2) << 2)}]
            set aspectbyte [expr {$aspectbyte | ($LampBits($lamp3) << 4)}]
            set response [$self _transmit [list $Opcodes(Signal3) [highbyte $address] [lowbyte $address] $aspectbyte]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Signal4 {address lamp1 lamp2 lamp3 lamp4} {
            ## Control 4-lamp signals.  
            # @param address Address of first lamp.
            # @param lamp1 Lamp 1 control, one of off, on, blink, or 
            # reverseblink.
            # @param lamp2 Lamp 2 control, one of off, on, blink, or 
            # reverseblink.
            # @param lamp3 Lamp 3 control, one of off, on, blink, or 
            # reverseblink.
            # @param lamp4 Lamp 4 control, one of off, on, blink, or 
            # reverseblink.
            #
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::lampcontroltype validate $lamp1
            ::ctiacela::lampcontroltype validate $lamp2
            ::ctiacela::lampcontroltype validate $lamp3
            ::ctiacela::lampcontroltype validate $lamp4
            set aspectbyte $LampBits($lamp1)
            set aspectbyte [expr {$aspectbyte | ($LampBits($lamp2) << 2)}]
            set aspectbyte [expr {$aspectbyte | ($LampBits($lamp3) << 4)}]
            set aspectbyte [expr {$aspectbyte | ($LampBits($lamp4) << 6)}]
            set response [$self _transmit [list $Opcodes(Signal4) [highbyte $address] [lowbyte $address] $aspectbyte]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method SignalSettings {blinkrate yellowhue} {
            ## Set Signal Settings
            # @param blinkrate Blink rate in 10ths of a second
            # @param yellowhue Mix of red and green to get yellow as a 
            # percentage of green vs red: 128 is 50/50.
            
            ::ctiacela::ubyte validate $blinkrate
            ::ctiacela::ubyte validate $yellowhue
            set response [$self _transmit [list $Opcodes(SignalX) $blinkrate $yellowhue]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method SignalBrightness {brightness} {
            ## Set signal brightness.
            # @param brightness Signal brightness.
            
            ::ctiacela::ubyte validate $brightness
            set response [$self _transmit [list $Opcodes(SignalBrightness) $brightness]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method ConfigureSensor {address threshold select polarity} {
            ## Configure a sensor.
            # @param address Address of the sensor.
            # @param threshold Filter threshold, 0-31.
            # @param select Filter select, one of noise, bounce, gap, pr dirty.
            # @param polarity Polarity, one of normal or invert.
            
            ::ctiacela::addresstype validate $address
            ::ctiacela::filterthreshtype validate $threshold
            ::ctiacela::selecttype validate $select
            ::ctiacela::polaritytype validate $polarity
            set attributes [expr {($threshold << 3) | ($FilterSelectBits($select) << 1)}]
            if {$polarity eq "invert"} {set attributes [expr {$attributes | 0x01}]}
            set response [$self _transmit [list $Opcodes(ConfigureSensor) [highbyte $address] [lowbyte $address] $attributes]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Read {address} {
            ## Read the state of a sensor.
            # @param address Address of the sensor.
            # @returns the sensor state as a boolean value.
            
            ::ctiacela::addresstype validate $address
            set response [$self _transmit [list $Opcodes(Read) [highbyte $address] [lowbyte $address]] 1]
            #puts stderr "*** $self Read: response = $response"
            if {[lindex $response 0] == $Responses(Success)} {
                return [expr {([lindex $response 1] & 0x01) == 0x01}]
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Read4 {address} {
            ## Read the state of four sensors.
            # @param address Address of the first sensor.
            # @returns the state of four sensors as a four element list of 
            # boolean values.
            
            ::ctiacela::addresstype validate $address
            set response [$self _transmit [list $Opcodes(Read4) [highbyte $address] [lowbyte $address]] 1]
            if {[lindex $response 0] == $Responses(Success)} {
                set s1 [expr {([lindex $response 1] & 0x01) == 0x01}]
                set s2 [expr {([lindex $response 1] & 0x02) == 0x02}]
                set s3 [expr {([lindex $response 1] & 0x04) == 0x04}]
                set s4 [expr {([lindex $response 1] & 0x08) == 0x08}]
                return [list $s1 $s2 $s3 $s4]
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }       
        method Read8 {address} {
            ## Read the state of eight sensors.
            # @param address Address of the first sensor.
            # @returns the state of eight sensors as an eight element list of 
            # boolean values.
            
            ::ctiacela::addresstype validate $address
            set response [$self _transmit [list $Opcodes(Read8) [highbyte $address] [lowbyte $address]] 1]
            if {[lindex $response 0] == $Responses(Success)} {
                set s1 [expr {([lindex $response 1] & 0x01) == 0x01}]
                set s2 [expr {([lindex $response 1] & 0x02) == 0x02}]
                set s3 [expr {([lindex $response 1] & 0x04) == 0x04}]
                set s4 [expr {([lindex $response 1] & 0x08) == 0x08}]
                set s5 [expr {([lindex $response 1] & 0x10) == 0x10}]
                set s6 [expr {([lindex $response 1] & 0x20) == 0x20}]
                set s7 [expr {([lindex $response 1] & 0x40) == 0x40}]
                set s8 [expr {([lindex $response 1] & 0x80) == 0x80}]
                return [list $s1 $s2 $s3 $s4 $s5 $s6 $s7 $s8]
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }       
        method Read16 {address} {
            ## Read the state of sixteen sensors.
            # @param address Address of the first sensor.
            # @returns the state of sisteen sensors as a sixteen element list 
            # of boolean values.
            
            ::ctiacela::addresstype validate $address
            set response [$self _transmit [list $Opcodes(Read16) [highbyte $address] [lowbyte $address]] 2]
            if {[lindex $response 0] == $Responses(Success)} {
                set s1 [expr {([lindex $response 1] & 0x01) == 0x01}]
                set s2 [expr {([lindex $response 1] & 0x02) == 0x02}]
                set s3 [expr {([lindex $response 1] & 0x04) == 0x04}]
                set s4 [expr {([lindex $response 1] & 0x08) == 0x08}]
                set s5 [expr {([lindex $response 1] & 0x10) == 0x10}]
                set s6 [expr {([lindex $response 1] & 0x20) == 0x20}]
                set s7 [expr {([lindex $response 1] & 0x40) == 0x40}]
                set s8 [expr {([lindex $response 1] & 0x80) == 0x80}]
                set s9 [expr {([lindex $response 2] & 0x01) == 0x01}]
                set s10 [expr {([lindex $response 2] & 0x02) == 0x02}]
                set s11 [expr {([lindex $response 2] & 0x04) == 0x04}]
                set s12 [expr {([lindex $response 2] & 0x08) == 0x08}]
                set s13 [expr {([lindex $response 2] & 0x10) == 0x10}]
                set s14 [expr {([lindex $response 2] & 0x20) == 0x20}]
                set s15 [expr {([lindex $response 2] & 0x40) == 0x40}]
                set s16 [expr {([lindex $response 2] & 0x80) == 0x80}]
                return [list $s1 $s2 $s3 $s4 $s5 $s6 $s7 $s8 $s9 $s10 $s11 $s12 $s13 $s14 $s15 $s16]
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        proc lappend8bits {varname byte} {
            upvar $varname var
            for {set ishift 0} {$ishift < 8} {incr ishift} {
                lappend var [expr {(($byte >> $ishift) & 0x01) == 0x01}]
            }
        }
        method ReadAll {} {
            ## Read all sensors
            # @returns the state of all sensors as a list of boolean values.
            
            set response [$self _transmit [list $Opcodes(ReadAll)] N]
            if {[lindex $response 0] == $Responses(Success)} {
                set n [lindex $response 1]
                set result [list]
                for {set i 0} {$i < $n} {incr i} {
                    lappend8bits result [lindex $response [expr {$i + 2}]]
                }
                return $result
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method SRQControl {{enable yes}} {
            ## Enable or disable SRQ messages.
            # @param enable Boolean, if true enable SRQ messages.
            
            if {$enable} {
                set response [$self _transmit [list $Opcodes(SRQControl) 0]]
            } else {
                set response [$self _transmit [list $Opcodes(SRQControl) 1]]
            }
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Query {} {
            ## Query sensor change state
            # @returns true if sensors changed state since the last Query call.
            
            set response [$self _transmit [list $Opcodes(Query)] 1]
            if {[lindex $response 0] == $Responses(Success)} {
                if {[lindex $response 1] == 0} {
                    return false
                } else {
                    return true
                }
            }  elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method ResetNetwork {} {
            ## Reset the network
            
            set response [$self _transmit [list $Opcodes(ResetNetwork)]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method NetworkOnline {} {
            ## Bring the network online.
            
            set response [$self _transmit [list $Opcodes(NetworkOnline)]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method NetworkOffline {} {
            ## Bring the network offline.
            
            set response [$self _transmit [list $Opcodes(NetworkOffline)]]
            if {$response == $Responses(Success)} {
                return yes
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method Poll {} {
            ## Poll the network configuration
            # @returns a list of modules on the network.
            
            set response [$self _transmit [list $Opcodes(Poll)] N]
            #puts stderr "*** $self Poll: response is $response"
            if {[lindex $response 0] == $Responses(Success)} {
                set n [lindex $response 1]
                set result [list]
                for {set i 0} {$i < $n} {incr i} {
                    set val [lindex $response [expr {$i + 2}]]
                    if {[info exists CTI_DeviceMap($val)]} {
                        lappend result $CTI_DeviceMap($val)
                    } else {
                        lappend result $val
                    }
                }
                return $result
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method ReadRevision {} {
            ## Read CTI Acela firmware revision.
            # @returns a two element list containing the major and minor
            # revision numbers of the Acela
            
            set response [$self _transmit [list $Opcodes(ReadRevision)] 2]
            if {[lindex $response 0] == $Responses(Success)} {
                set result [list [lindex $response 1] [lindex $response 2]]
                return $result
            } elseif {$response == $Responses(ProcessedOffline)} {
                return no
            } elseif {$response == $Responses(AddressOutOfRange)} {
                error [_ {Address (0x%04x) out of range.} $address]
            }
        }
        method _transmit {buffer {responsebytes 0}} {
            ## @private Transmit buffer and wait for response.
            # @param buffer List of bytes to transmit.
            # @param responsebytes Number of expected databytes (not counting 
            # the command ack byte) or N for a variable number of result bytes.
            # @returns the response, either a single byte or a list of bytes.
            
            #puts stderr "*** $self _transmit: sending $buffer"
            puts -nonewline $ttyfd [binary format c* $buffer]
            if {[$self _readbyte result]} {
                #puts stderr "*** $self _transmit: result is $result"
                if {$result != $Responses(Success)} {return $result}
                #puts stderr "*** $self _transmit: need to get $responsebytes"
                if {$responsebytes eq "N" || $responsebytes eq "n"} {
                    if {[$self _readbyte N]} {
                        #puts stderr "*** $self _transmit: getting $N bytes"
                        lappend result $N
                        for {set idata 0} {$idata < $N} {incr idata} {
                            if {[$self _readbyte data]} {
                                lappend result $data
                            }
                        }
                    }
                } else {
                    #puts stderr "*** $self _transmit: getting $responsebytes bytes"
                    for {set idata 0} {$idata < $responsebytes} {incr idata} {
                        if {[$self _readbyte data]} {
                            lappend result $data
                        }
                    }
                }
                #puts stderr "*** $self _transmit: result is $result"
                return $result
            }
        }
        variable _timeout 0
        ## @private Timeout flag.
        method _readevent {} {
            ## @private Read event method.
            incr _timeout -1
        }
        typevariable maxtries 10000
        ## @private Loop control for read attempts.
        method _readbyte {thebytevar} {
            ## @private Read a single byte from the serial interface.  Used by
            # methods that read responses.  
            # @param thebytevar A name of a variable to put the byte read.
            #   Undefined if there was an error.
            # @returns false on error and and true on success.
            upvar $thebytevar thebyte
            foreach {in out} [fconfigure $ttyfd -queue] {break}
            for {set i 0} {$i < $maxtries} {incr i} {
                if {$in > 0} {
                    set therawbyte [read $ttyfd 1]
                    binary scan $therawbyte c thebyte
                    set thebyte [expr {$thebyte & 0x0ff}]
                    return true
                }
                set savedevent [fileevent $ttyfd readable]
                set _timeout 0
                set aid [after 100 incr [myvar _timeout]]
                fileevent $ttyfd readable [mymethod _readevent]
                vwait [myvar _timeout]
                fileevent $ttyfd readable $savedevent
                after cancel $aid
                foreach {in out} [fconfigure $ttyfd -queue] {break}
            }
            return false
        }
    }
}


            
package provide CTIAcela 1.0.0

