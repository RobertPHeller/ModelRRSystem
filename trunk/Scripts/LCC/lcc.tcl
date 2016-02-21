#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Feb 2 12:06:52 2016
#  Last Modified : <160221.1604>
#
#  Description	
#  *** NOTE: Deepwoods Software assigned Node ID range is 05 01 01 01 22 *
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2016  Robert Heller D/B/A Deepwoods Software
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


## @defgroup LCCModule LCCModule
# @brief LCC (OpenLCB) interface code.
#
# These are Tcl SNIT classes that interface to the LCC / OpenLCB bus.
# 
# @author Robert Heller \<heller\@deepsoft.com\>
#
# @{

#package require gettext
package require snit

namespace eval lcc {
    ## @brief Namespace that holds the LCC interface code.
    #
    # This is a cross-platform implementation ...
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    # @section lcc Package provided
    #
    # LCC 1.0
    #
    
    snit::integer twobits -min 0 -max 0x03
    ## @typedef int twobits
    # A 2 bit integer.
    snit::integer threebits -min 0 -max 0x07
    ## @typedef int threebits
    # A 3 bit integer.
    snit::integer fivebits -min 0 -max 0x1F
    ## @typedef int fivebits
    # A 5 bit integer.
    snit::integer sixbits -min 0 -max 0x3F
    ## @typedef int sixbits
    # A 6 bit integer.
    snit::integer length -min 1 -max 64
    ## @typedef int length
    # An integer from 1 to 64
    snit::integer byte -min 0 -max 0x0FF
    ## @typedef unsigned char byte
    # An 8-bit unsigned byte.
    snit::integer twelvebits -min 0 -max 0x0FFF
    ## @typedef int twelvebits
    # A 12 bit integer.
    snit::integer fifteenbits -min 0 -max 0x07FFF
    ## @typedef int fifteenbits
    # A 15 bit integer.
    snit::integer sixteenbits  -min 0 -max 0x0FFFF
    ## @typedef int sixteenbits
    # A 16 bit integer.
    snit::integer headerword -min 0 -max 0x1FFFFFFF
    ## @typedef int headerword
    # A 29 bit integer.
    snit::listtype eightbytes -minlen 0 -maxlen 8 -type lcc::byte
    ## @typedef list eightbytes
    # A list of bytes, from 0 to 8 elements.
    snit::enum datagramcontent -values {
        ## @enum datagramcontent
        # Datagram and stream types.
        #
        {}
        ## Not a datagram or stream.
        complete 
        ## One frame datagram.
        first 
        ## First frame datagram.
        middle 
        ## Middle frame datagram.
        last 
        ## Last frame datagram.
        stream
        ## Stream frame.
    }
    
    snit::macro ::lcc::AbstractMessage {} {
        ## @brief Define common variables and accessor methods
        #
        
        method getElement {n} {
            ## @brief Get the nth data element.
            # @param n The index of the element to retrieve.
            # @return The data element.
            return [lindex $_dataChars $n]
        }
        method getNumDataElements {} {
            ## @brief Get the number of data elements.
            # @return The number of data elements.
            return $_nDataChars
        }
        method setElement {n v} {
            ## @brief Set the nth data element.
            # @param n The index of the element to set.
            # @param v The value to store.
            
            if {[catch {lcc::byte validate $v}]} {
                if {[catch {snit::integer validate $v}]} {
                    set v [scan $v %c]
                } else {
                    set v [expr {$v & 0x0FF}]
                }
            }
            lset _dataChars $n $v
        }
        variable _dataChars {}
        ##  @brief The data bytes as a list.
        variable _nDataChars 0
        ##  @brief The number of data bytes.
    }
    snit::macro ::lcc::AbstractMRMessage {} {
        ## @Brief Macro to create common methods and variables for an AbstractMRMessage
        #
        
        lcc::AbstractMessage;# Include base AbstractMessage
        method setOpCode {i} {
            ## @Brief Set the opcode (byte 0).
            # @param i The opcode to store.
            lset _dataChars 0 $i
        }
        method getOpCode {} {
            ## @Brief Get the opcode (byte 0).
            # @return The opcode.
            return [lindex $_dataChars 0]
        }
        
        method getOpCodeHex {} {
            ## @Brief Get the opcode (byte 0) in hex.
            # @return The opcode in hex.
            return [format {0x%x} [$self getOpCode]]
        }
        variable mNeededMode 0
        ## @Brief The needed mode
        method setNeededMode {pMode} {
            ## @Brief Set the needed mode.
            # @param pMode The mode to set.
            set mNeededMode $pMode
        }
        method getNeededMode {} {
            ## @Brief Get the needed mode.
            # @return The needed mode.
            return $mNeededMode
        }
        method replyExpected {} {
            ## @Brief Returns reply expected flag.
            # @return The reply expected flag.
            return true
        }
        variable _isBinary false
        ## @Brief Binary flag.
        method isBinary {} {
            ## @Brief Returns binary flag.
            # @return The binary flag.
            return $_isBinary
        }
        method setBinary {b} {
            ## @Brief Set the binary flag.
            # @param b The binary flag.
            set _isBinary $b
        }
        typevariable SHORT_TIMEOUT 2000
        ## @Brief Short timeout.
        typevariable LONG_TIMEOUT 60000
        ## @Brief Long timeout.
        variable mTimeout 0
        ## @Brief Current timeout. 
        method setTimeout {t} {
            ## @Brief Set the timeout.
            # @param t The new timeout value (milisecs).
            set mTimeout $t
        }
        method getTimeout {} {
            ## @Brief Get the timeout.
            # @return The current timeout value (milisecs).
            return $mTimeout
        }
        variable mRetries 0
        ## @Brief The number of retries.
        method setRetries {i} {
            ## @Brief Set the number of retries.
            # @param i The number of retries.
            set mRetries $i
        }
        method getRetries {} {
            ## @Brief Get the number of retries.
            # @return The number of retries.
            return $mRetries
        }
        method addIntAsThree {val offset} {
            ## @Brief Insert an integer as three decimal digits (with leading 0s).
            # @param val The value (0-999).
            # @param offset The index of the first digit.
            
            set svals [scan [format {%03d} $val] %c%c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
            $self setElement [expr {$offset+2}] [lindex $svals 2]
        }
        method addIntAsTwoHex {val offset} {
            ## @Brief Insert an integer as two hexadecimal digits (with leading 0s).
            # @param val The value (0-255)
            # @param offset The index of the first digit.
            
            set svals [scan [format {%02X} $val] %c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
        }
        method addIntAsThreeHex {val offset} {
            ## @Brief Insert an integer as three hexadecimal digits (with leading 0s).
            # @param val The value (0-4095)
            # @param offset The index of the first digit.
            
            set svals [scan [format {%03X} $val] %c%c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
            $self setElement [expr {$offset+2}] [lindex $svals 2]
        }
        method addIntAsFourHex {val offset} {
            ## @Brief Insert an integer as four hexadecimal digits (with leading 0s).
            # @param val The value (0-65535)
            # @param offset The index of the first digit.
            
            set svals [scan [format {%04X} $val] %c%c%c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
            $self setElement [expr {$offset+2}] [lindex $svals 2]
            $self setElement [expr {$offset+3}] [lindex $svals 3]
        }
        method setNumDataElements {n} {
            ## @Brief Set the number of data bytes.
            # @param n The number of data bytes.
            set _nDataChars $n
        }
        method toString {} {
            ## @Brief Return the data object as a string.
            
            set s ""
            for {set i 0} {$i < $_nDataChars} {incr i} {
                if {$_isBinary} {
                    if {$i != 0} {
                        append s " "
                    }
                    append s [format "%02X" [lindex $_dataChars $i]]
                } else {
                    append s [format "%c" [lindex $_dataChars $i]]
                }
            }
            return $s
        }
    }
    
        
    
    snit::type CANHeader {
        ## @brief CAN Header type.
        # Creates a 29-bit CAN header.  The header is generated and decoded
        # ``on the fly'' from/to the supplied options:
        #
        # @arg -openlcbframe A boolean flag to indicate an OpenLCB or
        #        generic CAN frame.
        # @arg -variablefield A 15 bit data field.
        # @arg -srcid A 12 bit source id field.
        
        typevariable RESERVED_SHIFT 28
        ## @privatesection @brief Bit 28 is reserved and always 1
        option -openlcbframe -type snit::boolean -default yes
        typevariable OPENLCBFRAME_SHIFT 27
        ## @brief Bit 27 is the OpenLCB bit: 1 == OpenLCB, 0 == other CAN
        typevariable OPENLCBFRAME_MASK  0x08000000
        ## @brief Bit 27 is the OpenLCB bit: 1 == OpenLCB, 0 == other CAN
        option -variablefield  -type ::lcc::fifteenbits -default 0
        typevariable VARIABLEFIELD_SHIFT 12
        ## @brief Bits 12-26 are the variable field.
        typevariable VARIABLEFIELD_MASK  0x07FFF000
        ## @brief Bits 12-26 are the variable field.
        option -srcid -default 0 -type ::lcc::twelvebits
        typevariable SRCID_SHIFT 0
        ## @brief Bits 0-11 are the source id.
        typevariable SRCID_MASK  0x00000FFF
        ## @brief Bits 0-11 are the source id.
        constructor {args} {
            ## @publicsection @brief Constructor: create a 29-bit CAN header.
            # Creates a CAN header object from the supplied options.
            #
            # @param name The name of the object.
            # @param ... Options:
            # @arg -openlcbframe Flag to indicate a OpenLCB frame or not.
            #      Default yes, type boolean.
            # @arg -variablefield Fifteen bit variable field.
            #      Default 0, type 15-bit integer.
            # @arg -srcid Twelve bit source id field.
            #      Default 0, type 12-bit integer.
            # @par
            
            #puts stderr "*** $type create $self $args"
            $self configurelist $args
        }
        method getHeader {} {
            ## @brief Generate and return the 29-bit header.
            # Creates a 29-bit header from the supplied options.
            # @return The 29-bit CAN header.
            set header [expr {(1 << $RESERVED_SHIFT)}];# reserved bit -- always 1
            if {$options(-openlcbframe)} {
                set header [expr {$header | (1 << $OPENLCBFRAME_SHIFT)}]
            }
            set header [expr {$header | ($options(-variablefield) << $VARIABLEFIELD_SHIFT)}]
            set header [expr {$header | $options(-srcid)}]
            return $header
        }
        method setHeader {header} {
            ## @brief Decode a 29-bit CAN header.
            # The 29-bit CAN header is decoded and the various options set.
            # @param header The 29-bit CAN header.
            
            if {($header & $OPENLCBFRAME_MASK) == 0} {
                set options(-openlcbframe) no
            } else {
                set options(-openlcbframe) yes
            }
            set options(-variablefield) [expr {($header & $VARIABLEFIELD_MASK) >> $VARIABLEFIELD_SHIFT}]
            set options(-srcid) [expr {$header & $SRCID_MASK}]
        }
        
            
    }
    snit::type MTIHeader {
        ## @brief MTI Header type. 
        # Creates a 29-bit CAN header, specific to OpenLCB. The header is 
        # generated and decoded ``on the fly'' from/to the supplied options:
        #
        # @arg -srcid A 12 bit source id field. Delegated to the canheader 
        #       component. @see lcc::CANHeader.
        # @arg -mti The 12 bit CAN_MTI field. Default is 0, type is a 12-bit 
        #       integer.
        # @arg -frametype The three bit frame type field. Default is 0, type 
        #       is a 3-bit integer.
        
        component canheader
        ## @privatesection @brief The CANHeader component.
        # Handles the header at the CAN level.
        delegate option -srcid to canheader
        option -mti -default 0 -type ::lcc::twelvebits
        typevariable MTI_CAN_SHIFT 0
        ## @brief Bits 0-11 of the variable field are the MTI_CAN field.
        typevariable MTI_CAN_MASK 0x0FFF
        ## @brief Bits 0-11 of the variable field are the MTI_CAN field.
        option -frametype -default 1 -type ::lcc::threebits
        typevariable FRAMETYPE_SHIFT 12
        ## @brief Bits 12-14 of the variable field are the frame type field.
        typevariable FRAMETYPE_MASK 0x7000
        ## @brief Bits 12-14 of the variable field are the frame type field.
        constructor {args} {
            ## @publicsection @brief Constructor: create a MTIHeader
            # A 29-bit CAN Header specific to the OpenLCB is created.
            #
            # @param name The name of the instance.
            # @param ... Options:
            # @arg -srcid A 12 bit source id field.
            # @arg -mti The 12 bit CAN_MTI field.
            # @arg -frametype The three bit frame type field.
            # @par
            
            #puts stderr "*** $type create $self $args"
            install canheader using lcc::CANHeader %AUTO% -openlcbframe yes
            $self configurelist $args
        }
        method getHeader {} {
            ## @brief Get the 29-bit header.
            # Most of the heavy lifting is handled in the canheader component.
            # @see lcc::CANHeader.
            # @return The 29-bit header.
            
            $canheader configure -variablefield [expr {($options(-frametype) << $FRAMETYPE_SHIFT)|$options(-mti)}]
            set header [$canheader getHeader]
            return $header
        }
        method setHeader {header} {
            ## @brief Decode the 29-bit header.
            # Most of the heavy lifting is handled in the canheader component.
            # @see lcc::CANHeader.
            # @param header The 29-bit header.
            
            $canheader setHeader $header
            set vfield [$canheader cget -variablefield]
            set options(-frametype) [expr {($vfield & $FRAMETYPE_MASK) >> $FRAMETYPE_SHIFT}]
            set options(-mti) [expr {$vfield & $MTI_CAN_MASK}]
        }
    }
   
    snit::type MTIDetail {
        ## @brief MTI Header type, detailed version.
        # Creates a 29-bit CAN header, specific to OpenLCB. The header is 
        # generated and decoded ``on the fly'' from/to the supplied options:
        #
        # @arg -srcid A 12 bit source id field. Delegated to the mtiheader 
        #       component. @see lcc::CANHeader and lcc::MTIHeader.
        # @arg -special A boolean flag indicating if this is a special frame.
        #       Default is no.
        # @arg -streamordatagram A boolean flag indicating if this is a stream
        #       or datagram frame.  Default is false.
        # @arg -priority A 2-bit integer specifying the frame's priority.
        #       Default is 0.
        # @arg -typewithin A 5-bit integer specifying the type withing the 
        #       priority. Default is 0.
        # @arg -simple A boolean flag indicating if the frame is a simple
        #       protocol frame. Default is no.
        # @arg -addressp A boolean flag indicating if an address is present.
        #       Default is no.
        # @arg -eventp A boolean flag indicating if an event is present.
        #       Default is no.
        # @arg -modifier The 2-bit modifier field. Default is 0.
        # @arg -destid A 12-bit Desitination alias. Only used for stream and 
        #       datagram frames. Default is 0.
        # @arg -datagramcontent An enumerated type defining the datagram 
        #       or stream content type.  Default is {} (not a datagram or 
        #       stream).
        
        component mtiheader
        ## @privatesection @brief the MTIHeader component.
        # Contains a MTIHeader to perform heavy lifting.
        option -special -type snit::boolean -default no
        option -streamordatagram  -type snit::boolean -default no
        option -priority -type lcc::twobits -default 0
        typevariable PRIORITY_SHIFT 10
        ## @brief The priority is bits 10-11 of the MTI_CAN
        typevariable PRIORITY_MASK 0x0C00
        ## @brief The priority is bits 10-11 of the MTI_CAN
        option -typewithin -type lcc::fivebits -default 0
        typevariable TYPEWITHIN_SHIFT 5
        ## @brief The type within priority field is bits 5-9 of the MTI_CAN
        typevariable TYPEWITHIN_MASK  0x03E0
        ## @brief The type within priority field is bits 5-9 of the MTI_CAN.
        option -simple -type snit::boolean -default no
        typevariable SIMPLE_SHIFT 4
        ## @brief The simple bit is bit 4 of the MTI_CAN.
        typevariable SIMPLE_MASK 0x0010
        ## @brief The simple bit is bit 4 of the MTI_CAN.
        option -addressp -type snit::boolean -default no
        typevariable ADDRESSP_SHIFT 3
        ## @brief The address present bit is bit 3 of the MTI_CAN.
        typevariable ADDRESSP_MASK 0x0008
        ## @brief The address present bit is bit 3 of the MTI_CAN.
        option -eventp -type snit::boolean -default no
        typevariable EVENTP_SHIFT 2
        ## @brief The event present bit is bit 2 of the MTI_CAN.
        typevariable EVENTP_MASK 0x0004
        ## @brief The event present bit is bit 2 of the MTI_CAN.
        option -modifier -type lcc::twobits -default 0
        typevariable MODIFIER_SHIFT 0
        ## @brief The modifier is bits 0-1 of the MTI_CAN.
        typevariable MODIFIER_MASK 0x0003
        ## @brief The modifier is bits 0-1 of the MTI_CAN.
        delegate option -srcid to mtiheader
        option -destid -type lcc::twelvebits -default 0
        typevariable DESTID_SHIFT 0
        ## @brief The destid is bits 0-11 of the MTI_CAN.
        typevariable DESTID_MASK 0x0FFF
        ## @brief The destid is bits 0-11 of the MTI_CAN.
        option -datagramcontent -type lcc::datagramcontent -default {}
        constructor {args} {
            ## @publicsection @brief Constructor: create a MTIDetail object.
            # A 29-bit CAN Header specific to the OpenLCB is created, using
            # details for a MTI frame.
            #
            # @param name The name of the instance.
            # @param ... Options:
            # @arg -srcid A 12 bit source id field.
            # @arg -special A boolean flag indicating if this is a special frame.
            # @arg -streamordatagram A boolean flag indicating if this is a stream
            #       or datagram frame.
            # @arg -priority A 2-bit integer specifying the frame's priority.
            # @arg -typewithin A 5-bit integer specifying the type withing the 
            # @arg -simple A boolean flag indicating if the frame is a simple
            #       protocol frame.
            # @arg -addressp A boolean flag indicating if an address is present.
            # @arg -eventp A boolean flag indicating if an event is present.
            # @arg -modifier The 2-bit modifier field.
            # @arg -destid A 12-bit Desitination alias. Only used for stream and 
            #       datagram frames.
            # @arg -datagramcontent An enumerated type defining the datagram 
            #       or stream content type.
            # @par
            
            install mtiheader using MTIHeader %AUTO%
            $self configurelist $args
        }
        method getHeader {} {
            ## @brief Get the 29-bit header.
            # Most of the heavy lifting is handled in the mtiheader component.
            # @see lcc::CANHeader and lcc::MTIHeader.
            # @return The 29-bit header.
            
            if {!$options(-streamordatagram) && !$options(-special)} {
                ## frame type 1: Global & Addressed MTI
                set mti_can [expr {$options(-priority) << $PRIORITY_SHIFT}]
                set mti_can [expr {$mti_can | ($options(-typewithin) << $TYPEWITHIN_SHIFT)}]
                if {$options(-simple)} {
                    set mti_can [expr {$mti_can | (1 << $SIMPLE_SHIFT)}]
                }
                if {$options(-addressp)} {
                    set mti_can [expr {$mti_can | (1 << $ADDRESSP_SHIFT)}]
                }
                if {$options(-eventp)} {
                    set mti_can [expr {$mti_can | (1 << $EVENTP_SHIFT)}]
                }
                set mti_can [expr {$mti_can | $options(-modifier)}]
                $mtiheader configure -mti $mti_can
            } else {
                ## frame types 2, 3, 4, 5, and 7
                ## Datagram and Stream
                $mtiheader configure -mti [expr {$options(-destid) & 0x0FFF}]
                switch $options(-datagramcontent) {
                    complete {
                        $mtiheader configure -frametype 2
                    }
                    first {
                        $mtiheader configure -frametype 3
                    }
                    middle {
                        $mtiheader configure -frametype 4
                    }
                    last {
                        $mtiheader configure -frametype 5
                    }
                    stream {
                        $mtiheader configure -frametype 7
                    }
                    default {
                        error [_ "Illegal datagram content type: %s" $options(-datagramcontent)]
                    }
                }
            }
            return [$mtiheader getHeader]
        }
        method setHeader {header} {
            ## @brief Decode the 29-bit header.
            # Most of the heavy lifting is handled in the mtiheader component.
            # @see lcc::CANHeader and lcc::MTIHeader.
            # @param header The 29-bit header.
            
            $mtiheader setHeader $header
            switch [$mtiheader cget -frametype] {
                0 -
                6 {
                    # reserved
                }
                1 {
                    # Global & Addressed MTI
                    set options(-streamordatagram) no
                    set options(-special) no
                    set mti_can [$mtiheader cget -mti]
                    set options(-priority)   [expr {($mti_can & $PRIORITY_MASK) >> $PRIORITY_SHIFT}]
                    set options(-typewithin) [expr {($mti_can & $TYPEWITHIN_MASK) >> $TYPEWITHIN_SHIFT}]
                    set options(-simple)     [expr {($mti_can & $SIMPLE_MASK) != 0}]
                    set options(-addressp)   [expr {($mti_can & $ADDRESSP_MASK) != 0}]
                    set options(-eventp)     [expr {($mti_can & $EVENTP_MASK) != 0}]
                    set options(-modifier)   [expr {$mti_can & $MODIFIER_MASK}]
                }
                2 -
                3 -
                4 -
                5 {
                    # datagrams
                    set options(-streamordatagram) yes
                    set options(-destid)  [expr {[$mtiheader cget -mti] & $DESTID_MASK}]
                    switch [$mtiheader cget -frametype] {
                        2 {set options(-datagramcontent) complete}
                        3 {set options(-datagramcontent) first}
                        4 {set options(-datagramcontent) middle}
                        5 {set options(-datagramcontent) last}
                    }
                }
                7 {
                    # stream
                    set options(-streamordatagram) yes
                    set options(-destid)  [expr {[$mtiheader cget -mti] & $DESTID_MASK}]
                    set options(-datagramcontent) stream
                }
            }
        }
    }
    
    
    
    snit::type CanMessage {
        ## @brief A CAN Message, containing a 29-bit header and upto 8 bytes of
        # data.
        #
        # Options:
        # @arg -header The 29-bit header.  Readonly, used only during creation.
        #       Default 0.
        # @arg -length The length of the data.  Readonly, used only during 
        #       creation. Default 0.
        # @arg -data The initial data. Readonly, used only during creation. 
        #       Default is the empty list.
        # @arg -extended. Boolean flag to indicate an extended protocol frame.
        #       Default is false.
        # @arg -rtr. Boolean flag to indicate if a reply is expected. Default 
        #       is false.
        # @par
        # Additional methods defined using the macros AbstractMessage and 
        # AbstractMRMessage include:
        #
        # @arg getElement {n} -- Get the nth data element.
        # @arg getNumDataElements {} -- Get the number of data elements.
        # @arg setElement {n v} -- Set the nth data element.
        # @arg setOpCode {i} -- Set the opcode (byte 0).
        # @arg getOpCode {} --  Get the opcode (byte 0).
        # @arg getOpCodeHex {} -- Get the opcode (byte 0) in hex.
        # @arg setNeededMode {pMode} -- Set the needed mode.
        # @arg getNeededMode {} -- Get the needed mode.
        # @arg replyExpected {} -- Returns reply expected flag.
        # @arg isBinary {} -- Returns binary flag.
        # @arg setBinary {b} -- Set the binary flag.
        # @arg setTimeout {t} -- Set the timeout.
        # @arg getTimeout {} -- Get the timeout.
        # @arg setRetries {i} -- Set the number of retries.
        # @arg getRetries {} -- Get the number of retries.
        # @arg addIntAsThree {val offset} -- Insert an integer as three 
        #             decimal digits (with leading 0s).
        # @arg addIntAsTwoHex {val offset} -- Insert an integer as two 
        #             hexadecimal digits (with leading 0s).
        # @arg addIntAsThreeHex {val offset} -- Insert an integer as three 
        #             hexadecimal digits (with leading 0s).
        # @arg addIntAsFourHex {val offset} -- Insert an integer as four 
        #             hexadecimal digits (with leading 0s).
        # @arg setNumDataElements {n} --  Set the number of data bytes.
        # @arg toString {} -- Return the data object as a string.
        # @par
        # And these (private) instance variables:
        # @arg _dataChars {}
        # @arg _nDataChars 0
        # @arg mNeededMode 0
        # @arg _isBinary false
        # @arg mTimeout 0
        # @arg mRetries 0
        # @par
        # And these (private) static variables:
        # @arg SHORT_TIMEOUT 2000
        # @arg LONG_TIMEOUT 60000
        # @par

        lcc::AbstractMRMessage
        
        
        option -header -readonly yes -default 0 -type lcc::headerword
        option -length -readonly yes -default 0 \
              -type {snit::integer -min 0 -max 8}
        option -data   -readonly yes -default {} -type lcc::eightbytes
        option -extended -type snit::boolean -default no
        option -rtr -type snit::boolean -default no
        constructor {args} {
            ## @brief Constructor: create a CANMessage object
            # Creates a fresh CANMessage object, with possible initialization.
            #
            # @param name The name of the new instance.
            # @param ... The options:
            # @arg -header The 29-bit header.  Readonly, used only during 
            #       creation.
            # @arg -length The length of the data.  Readonly, used only during 
            #       creation.
            # @arg -data The initial data. Readonly, used only during creation.
            # @arg -extended. Boolean flag to indicate an extended protocol 
            #       frame.
            # @arg -rtr. Boolean flag to indicate if a reply is expected.
            # @par        
            
            
            #puts stderr "*** $type create $self $args"
            set _header [from args -header 0]
            set _nDataChars 8
            $self setBinary true
            set _dataChars [list 0 0 0 0 0 0 0 0]
            if {[lsearch $args -data] >= 0 && [lsearch $args -length] >= 0} {
                $self setData [from args -data]
                set _nDataChars [from args -length]
            } elseif {[lsearch $args -data] >= 0} {
                $self setData [from args -data]
                set _nDataChars [llength $_dataChars]
            } elseif {[lsearch $args -length] >= 0} {
                set _nDataChars [from args -length]
                set _dataChars [list]
                for {set i 0} {$i < $_nDataChars} {incr i} {
                    lappend _dataChars 0
                }
            }
            $self configurelist $args
            #puts stderr "*** $type create $self: [$self toString]"
        }
        typemethod copy {m} {
            ## @brief Copy constructor.
            # Copies a CANMessage instance.
            #
            # @param m The CANMessage to make a copy of.
            
            $type validate $m
            set result [$type %AUTO% -header [$m getHeader] \
                        -data [$m getData] -length [$m getNumDataElements] \
                        -extended [$m cget -extended] -rtr [$m cget -rtr]]
            return $result
        }
        method hashCode {} {
            ## @brief Return a hash code.
            # @return The header as the object's hash code.
            return $_header
        }
        method equals {a} {
            ## @brief  Equality check.
            # CANMessages are equal if all of the bits are the same.
            # @param a A CANMessage to compare to.
            # @return A boolean value indication equality.
            
            if {[$a info type] ne $type} {return false}
            if {[$a getHeader] != $_header} {return false}
            if {[$a cget -rtr] && ![$self cget -rtr]} {return false}
            if {![$a cget -rtr] && [$self cget -rtr]} {return false}
            if {[$a cget -extended] && ![$self cget -extended]} {return false}
            if {![$a cget -extended] && [$self cget -extended]} {return false}
            if {$_nDataChars != [$a getNumDataElements]} {
                return false
            }
            for {set i 0} {$i < $_nDataChars} {incr i} {
                if {[$self getElement $i] != [$a getElement $i]} {
                    return false
                }
            }
            return true
        }
        method replyExpected {} {
            ## @brief Reply expected.
            # @return A boolean flag indicating if a reply is expected.
            return true
        }
        method setNumDataElements {n} {
            ## @brief Set the number of data elements.
            # Sets the number of data elements.
            # @param n The number of data elements.
            set _nDataChars $n
        }
        method setData {d} {
            ## @brief Set the data values.
            # Copy data into the data vector.
            # @param d Replacement data values.
            
            set len [llength $_dataChars]
            if {[llength $d] < $len} {
                set len [llength $d]
            }
            for {set i 0} {$i < $len} {incr i} {
                lset _dataChars $i [lindex $d $i]
            }
        }
        method getData {} {
            ## Return the data vector.
            # @return The data vector.
            return [lrange $_dataChars 0 [expr {$_nDataChars - 1}]]
        }
        method getHeader {} {
            ## Return the header.
            # @return The header.
            return $_header
        }
        method setHeader {h} {
            ## Set the header.
            # @param h The new header.
            set _header $h
        }
        variable _header
        ## The header.
        typemethod validate {o} {
            ## Validator typemethod.
            # @param o The object to validate.
            
            #puts stderr "*** $type validate $o"
            if {[catch {$o info type} thetype]} {
                #puts stderr "*** $type validate: $thetype"
                error "Not a $type: $o"
            } elseif {$thetype ne $type} {
                #puts stderr "*** $type validate: $thetype, $type"
                error "Not a $type: $o"
            } else {
                return $o
            }
        }
        method toString {} {
            ## Method to create a string version of the message.
            # @return A string representation of the message.
            
            set s [format {%08X } [$self getHeader]]
            if {[$self cget -extended]} {
                append s {X }
            } else {
                append s {S }
            }
            if {[$self cget -rtr]} {
                append s {R }
            } else {
                append s {N }
            }
            for {set i 0} {$i < $_nDataChars} {incr i} {
                if {$i != 0} {
                    append s " "
                }
                append s [format "%02X" [lindex $_dataChars $i]]
            }
            return $s
        }
            
    }
    
    snit::type GridConnectMessage {
        ## @brief A Grid Connect formatted CAN message.
        # This is an ASCII formatted version of a CAN message, used by some
        # USB connected CAN interface devices.
        #
        # This class is used to convert from @b binary CAN Messages to 
        # @b ASCII Grid Connect messages. See GridConnectReply for converting
        # from @b ASCII Grid Connect messages to @b binary CAN Messages.
        #
        # Options:
        # @arg -canmessage A binary CANMessage to be converted to a Grid 
        #       Connect message. A write only option.
        # @arg -extended A boolean flag to indicate if this is an extended 
        #       protocol message.  Default no.
        # @arg -rtr A boolean flag to indicate if this is a reply exptected 
        #       message.  Default no.
        # @par
        # Additional methods defined using the macros AbstractMessage and 
        # AbstractMRMessage include:
        #
        # @arg getElement {n} -- Get the nth data element.
        # @arg getNumDataElements {} -- Get the number of data elements.
        # @arg setElement {n v} -- Set the nth data element.
        # @arg setOpCode {i} -- Set the opcode (byte 0).
        # @arg getOpCode {} --  Get the opcode (byte 0).
        # @arg getOpCodeHex {} -- Get the opcode (byte 0) in hex.
        # @arg setNeededMode {pMode} -- Set the needed mode.
        # @arg getNeededMode {} -- Get the needed mode.
        # @arg replyExpected {} -- Returns reply expected flag.
        # @arg isBinary {} -- Returns binary flag.
        # @arg setBinary {b} -- Set the binary flag.
        # @arg setTimeout {t} -- Set the timeout.
        # @arg getTimeout {} -- Get the timeout.
        # @arg setRetries {i} -- Set the number of retries.
        # @arg getRetries {} -- Get the number of retries.
        # @arg addIntAsThree {val offset} -- Insert an integer as three 
        #             decimal digits (with leading 0s).
        # @arg addIntAsTwoHex {val offset} -- Insert an integer as two 
        #             hexadecimal digits (with leading 0s).
        # @arg addIntAsThreeHex {val offset} -- Insert an integer as three 
        #             hexadecimal digits (with leading 0s).
        # @arg addIntAsFourHex {val offset} -- Insert an integer as four 
        #             hexadecimal digits (with leading 0s).
        # @arg setNumDataElements {n} --  Set the number of data bytes.
        # @arg toString {} -- Return the data object as a string.
        # @par
        # And these (private) instance variables:
        # @arg _dataChars {}
        # @arg _nDataChars 0
        # @arg mNeededMode 0
        # @arg _isBinary false
        # @arg mTimeout 0
        # @arg mRetries 0
        # @par
        # And these (private) static variables:
        # @arg SHORT_TIMEOUT 2000
        # @arg LONG_TIMEOUT 60000
        # @par

        lcc::AbstractMRMessage
        option -canmessage -configuremethod _copyCM
        option -extended -type snit::boolean -configuremethod _set_extended \
              -cgetmethod _get_extended -default no
        method _set_extended {opt extended} {
            ## @private @brief Configure method for the -extended option.
            # Sets the extended flag character.
            # @param opt Always -extended. Ignored.
            # @param extended Boolean flag indicating extendedness.
            
            if {$extended} {
                $self setElement 1 "X"
            } else {
                $self setElement 1 "S"
            }
        }
        method _get_extended {opt} {
            ## @private @brief CGet method for the -extended option.
            # Gets the extended flag character.
            # @param opt Always -extended. Ignored.
            # @return A boolean flag indicating extendedness.
            
            set E [format {%c} [$self getElement 1]]
            return [expr {$E eq "X"}]
        }
        option -rtr -type snit::boolean -default no \
              -configuremethod _set_rtr -cgetmethod _get_rtr              
        method _set_rtr {opt rtr} {
            ## @private @brief Configure method for the -rtr option.
            # Sets the rtr flag character.
            # @param opt Always -rtr. Ignored.
            # @param rtr Boolean flag indicating rtrness.
            
            if {[$self cget -extended]} {
                set offset 10
            } else {
                set offset 5
            }
            if {$rtr} {
                $self setElement $offset "R"
            } else {
                $self setElement $offset "N"
            }
        }
        method _get_rtr {opt} {
            ## @private @brief CGet method for the -rtr option.
            # Gets the rtr flag character.
            # @param opt Always -rtr. Ignored.
            # @returnA boolean flag indicating rtrness.
            
            if {[$self cget -extended]} {
                set offset 10
            } else {
                set offset 5
            }
            if {[$self getElement $offset] eq "R"} {
                return true
            } else {
                return false
            }
        }
        constructor {args} {
            ## @brief Constructor: create a Grid Connect Message object.
            # Create a Grid Connect Message.  Typically, a CANMessage is
            # configured with the -canmessage option and then the toString
            # method is used to get a printable Grid Connect Message 
            # string.
            #
            # @param name The name of the object.
            # @param ... The options:
            # @arg -canmessage A binary CANMessage to be converted to a Grid 
            #       Connect message. A write only option.
            # @arg -extended A boolean flag to indicate if this is an extended 
            #       protocol message.
            # @arg -rtr A boolean flag to indicate if this is a reply expected 
            #       message.
            # @par
            
            set _nDataChars 28
            set _dataChars [list]
            for {set i 0} {$i < 28} {incr i} {
                lappend _dataChars 0
            }
            $self setElement 0 ":"
            $self configurelist $args
        }
        method _copyCM {option m} {
            ## @private @brief Configure method for the -canmessage option.
            # Copies in a CANMessage and in the process formats a Grid Connect
            # Message string.
            #
            # @param option Always -canmessage. Ignored.
            # @param m A CANMessage object.
            
            #puts stderr "*** $self _copyCM $option $m"
            lcc::CanMessage validate $m
            $self configure -extended [$m cget -extended]
            $self configure -rtr [$m cget -rtr]
            $self setHeader   [$m getHeader]
            for {set i 0} {$i < [$m getNumDataElements]} {incr i} {
                $self setByte [$m getElement $i] $i
            }
            if {[$self cget -extended]} {
                set offset 11
            } else {
                set offset 6
            }
            $self setElement [expr {$offset + ([$m getNumDataElements] * 2)}] ";"
            $self setNumDataElements [expr {$offset + 1 + ([$m getNumDataElements] * 2)}]
        }
        method setHeader {header} {
            ## @brief Set the header.
            # Sets the header.  The header is converted to hex digits and 
            # stored in the data buffer.
            #
            # @param header The binary 29-bit header.
            
            if {[$self cget -extended]} {
                $self setHexDigit [expr {($header >> 28) & 0x0F}] 2
                $self setHexDigit [expr {($header >> 24) & 0x0F}] 3
                $self setHexDigit [expr {($header >> 20) & 0x0F}] 4
                $self setHexDigit [expr {($header >> 16) & 0x0F}] 5
                $self setHexDigit [expr {($header >> 12) & 0x0F}] 6
                $self setHexDigit [expr {($header >> 8) & 0x0F}] 7
                $self setHexDigit [expr {($header >> 4) & 0x0F}] 8
                $self setHexDigit [expr {$header & 0x0F}] 9
            } else {
                $self setHexDigit [expr {($header >> 8) & 0x0F}] 2
                $self setHexDigit [expr {($header >> 4) & 0x0F}] 3
                $self setHexDigit [expr {$header & 0x0F}] 4
            }
        }
        method setByte {val n} {
            ## @brief Set a data byte.
            # Stores a data byte as two hex digits.
            #
            # @param val The data byte value, 0-255.
            # @param n   The data index, 0-7.
            
            if {($n >= 0) && ($n <= 7)} {
                set index [expr {$n * 2 + ([$self cget -extended] ? 11 : 6)}]
                $self setHexDigit [expr {($val >> 4) & 0x0F}] $index
                incr index
                $self setHexDigit [expr {$val& 0x0F}] $index
            }
        }
        method setHexDigit {val n} {
            ## @brief Set a hex digit.
            # Stores a single nibble (0-16) at the specified index as an ASCII
            # hex digit.
            # @param val The nibble (0-16) to store.
            # @param n   The data index.
            
            if {($val >= 0) && ($val <= 15)} {
                lset _dataChars $n [scan [format %X $val] %c]
            } else {
                lset _dataChars $n [scan "0" %c]
            }
        }
    }
    
    snit::type GridConnectReply {
        ## @brief A Grid Connect formatted CAN message (reply).
        # This is an ASCII formatted version of a CAN message, used by some 
        # USB connected CAN interface devices.
        #
        # This class is used to convert to @b binary CAN Messages from 
        # @b ASCII Grid Connect messages. See GridConnectMessage for converting
        # to @b ASCII Grid Connect messages from @b binary CAN Messages.
        #
        # Options:
        # @arg -extended A boolean flag to indicate if this is an extended 
        #       protocol message.  Readonly and not settable.
        # @arg -rtr A boolean flag to indicate if this is a reply exptected 
        #       message.  Readonly and not settable.
        # @arg -message A received GridConnectMessage to be converted to a
        #       binary CanMessage.  Settable only.
        # @par
        # Additional methods defined using the macros AbstractMessage and 
        # AbstractMRMessage include:
        #
        # @arg getElement {n} -- Get the nth data element.
        # @arg getNumDataElements {} -- Get the number of data elements.
        # @arg setElement {n v} -- Set the nth data element.
        # @arg setOpCode {i} -- Set the opcode (byte 0).
        # @arg getOpCode {} --  Get the opcode (byte 0).
        # @arg getOpCodeHex {} -- Get the opcode (byte 0) in hex.
        # @arg setNeededMode {pMode} -- Set the needed mode.
        # @arg getNeededMode {} -- Get the needed mode.
        # @arg replyExpected {} -- Returns reply expected flag.
        # @arg isBinary {} -- Returns binary flag.
        # @arg setBinary {b} -- Set the binary flag.
        # @arg setTimeout {t} -- Set the timeout.
        # @arg getTimeout {} -- Get the timeout.
        # @arg setRetries {i} -- Set the number of retries.
        # @arg getRetries {} -- Get the number of retries.
        # @arg addIntAsThree {val offset} -- Insert an integer as three 
        #             decimal digits (with leading 0s).
        # @arg addIntAsTwoHex {val offset} -- Insert an integer as two 
        #             hexadecimal digits (with leading 0s).
        # @arg addIntAsThreeHex {val offset} -- Insert an integer as three 
        #             hexadecimal digits (with leading 0s).
        # @arg addIntAsFourHex {val offset} -- Insert an integer as four 
        #             hexadecimal digits (with leading 0s).
        # @arg setNumDataElements {n} --  Set the number of data bytes.
        # @arg toString {} -- Return the data object as a string.
        # @par
        # And these (private) instance variables:
        # @arg _dataChars {}
        # @arg _nDataChars 0
        # @arg mNeededMode 0
        # @arg _isBinary false
        # @arg mTimeout 0
        # @arg mRetries 0
        # @par
        # And these (private) static variables:
        # @arg SHORT_TIMEOUT 2000
        # @arg LONG_TIMEOUT 60000
        # @par
        
        lcc::AbstractMRMessage
        option -extended -type snit::boolean -readonly true \
              -cgetmethod _get_extended -default no
        method _get_extended {opt} {
            ## @private @brief CGet method for the -extended option.
            # Gets the extended protocol flag for this message.
            #
            # @param opt Allways -extended. Ignored.
            # @return The extended protocol flag for this message.
            
            set E [format {%c} [$self getElement 1]]
            return [expr {$E eq "X"}]
        }
        option -rtr -type snit::boolean -default no \
              -readonly yes -cgetmethod _get_rtr              
        method _get_rtr {opt} {
            ## @private @brief CGet method for the -rtr option.
            # Gets the reply flag for this message.
            #
            # @param opt Allways -rtr. Ignored.
            # @return The reply flag for this message.
            set R [format {%c} [$self getElement $_RTRoffset]]
            return [expr {$R eq "R"}]
        }
        option -message -configuremethod _copyGCM
        method _copyGCM {option s} {
            ## @private @brief Configure method for the -message option.
            # Send in an ASCII Grid Connect Message for conversion.
            #
            # @param option Allways -message. Ignored.
            # @param s The ASCII Grid Connect Message as a string.
            #
            
            if {[string length $s] > $MAXLEN} {
                set s [string range $s 0 [expr {$MAXLEN - 1}]]
            }
            #puts stderr "*** $self _copyGCM: s = '$s'"
            set i 0
            foreach c [split $s {}] {
                #puts stderr "*** $type create $self: c = '$c'"
                set b [scan $c %c]
                #puts stderr "*** $type create $self: b = $b"
                lset _dataChars $i $b
                incr i
            }
            set _nDataChars [string length $s]
        }
        typevariable MAXLEN 27
        ## @private The maximum length for a Grid Connect Message.
        constructor {args} {
            ## @brief Constructor: create a GridConnectReply instance.
            # A GridConnectReply object is created.
            #
            # @param name The name of the new instance.
            # @param ... The options:
            # @arg -message An optional Grid Connect Message string.
            # @par
            set _nDataChars 0
            set _dataChars [list]
            for {set i 0} {$i < $MAXLEN} {incr i} {
                lappend _dataChars 0
            }
            $self configurelist $args
        }
        method createReply {} {
            ## @brief Convert to a @b binary CanMessage object.
            # Decode a Grid Connect Message into a binary CanMessage object.
            #
            # @return A CanMessage object.
            
            set ret [lcc::CanMessage %AUTO%]
            if {![$self basicFormatCheck]} {
                $ret setHeader 0
                $ret setNumDataElements 0
                return $ret
            }
            if {[$self cget -extended]} {
                $ret configure -extended true
            }
            $ret setHeader [$self getHeader]
            if {[$self cget -rtr]} {
                $ret configure -rtr true
            }
            for {set i 0} {$i < [$self getNumBytes]} {incr i} {
                $ret setElement $i [$self getByte $i]
            }
            $ret setNumDataElements [$self getNumBytes]
            return $ret
        }
        method basicFormatCheck {} {
            ## @private @brief Perform a basic format check.
            # Check for a basicly correct formatted string.
            # 
            # @return A boolean flag indicating that the message passed a 
            # basic format check.
            set E [format {%c} [$self getElement 1]]
            if {$E ne "X" && $E ne "S"} {
                return false
            } else {
                return true
            }
        }
        method setElement {n v} {
            ## @brief Set the element.
            # Set the element at the specified index.
            # 
            # @param n The index to set.
            # @param v The value to set.
            if {[catch {lcc::byte validate $v}]} {
                if {[catch {snit::integer validate $v}]} {
                    set v [scan $v %c]
                } else {
                    set v [expr {$v & 0x0FF}]
                }
            }
            lset _dataChars $n $v
            if {$_nDataChars < ($n + 1)} {
                set _nDataChars [expr {$n + 1}]
            }
        }
        method maxSize {} {
            ## Return the maximum size of a Grid Connect Message.
            # @return The maximum size of a Grid Connect Message.
            return $MAXLEN
        }
        method setData {d} {
            ## @brief Set the data
            # Copy the data bytes into the structure.
            #
            # @param d A list of data bytes (characters).
            
            if {[llength $d] <= $MAXLEN} {
                set len [llength $d]
            } else {
                set len $MAXLEN
            }
            for {set i 0} {$i < $len} {incr i} {
                lset _dataChars $i [lindex $d $i]
            }
        }
        variable _RTRoffset -1
        ## @private The offset to the RTR flag.
        method getHeader {} {
            ## @brief Extract the header as a 29-bit integer.
            # Peel the hexadecimal digits between the simple/extended flag 
            # character and the reply/noreply character as a 29-bit
            # CAN header word.
            #
            # @return A 29-bit integer.
            set val 0
            for {set i 2} {$i <= 10} {incr i} {
                set _RTRoffset $i
                set R [format {%c} [lindex $_dataChars $i]]
                if {$R eq "N" || $R eq "R"} {break}
                set val [expr {($val << 4) | [$self getHexDigit $i]}]
            }
            return $val
        }
        method getNumBytes {} {
            ## Return the number of data bytes.
            #
            # @return The number of data bytes.
            return [expr {($_nDataChars - ($_RTRoffset + 1)) / 2}]
        }
        method getByte {b} {
            ## Return a selected data byte.
            # 
            # @param b The index of the byte (0-7) to return.
            # @return The data bytes or 0.
            if {($b >= 0) && ($b <= 7)} {
                set index [expr {$b * 2 + $_RTRoffset + 1}]
                set hi [$self getHexDigit $index]
                incr index
                set lo [$self getHexDigit $index]
                if {($hi < 16) && ($lo < 16)} {
                    return [expr {$hi * 16 + $lo}]
                }
            }
            return 0
        }
        method getHexDigit {index} {
            ## Get one hexadecimal digit.
            #
            # @param index The low-level data index of the nibble to return.
            # @return The nibble.
            set b [lindex $_dataChars $index]
            return [scan [format %c $b] %x]
        }
    }
    
    snit::stringtype nid -regexp {^([[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]]):([[:xdigit:]][[:xdigit:]])$}
    ## @typedef string nid
    # @brief Node ID regexp pattern.
    # A Node Id is six bytes as pairs of hex digits separacted by colons (:).
    

    snit::type LCCBufferUSB {
        ## @brief Connect to a RR-Cirkits LCC Buffer USB device.
        # This class implements I/O to the CAN Bus via a RR-Cirkits LCC Buffer
        # USB device. The LCC Buffer USB uses Grid Connect format messages to
        # communicate with devices on the OpenLCB CAN bus.
        #
        # Options:
        # @arg -port The name of the serial port.  Typically "/dev/ttyACMn"
        # under Linux (using the cdc_acm driver).  This is a readonly option
        # only processed at instance creation.
        # @arg -nid The Node ID that the computer will assume in the format
        # of @c hh:hh:hh:hh:hh:hh which is a 48 bit number expressed as 6
        # pairs of hexadecimal digits separacted by colons (:).
        # @arg -eventhandler This is a script prefix that is run on incoming 
        # messages.  The current message as a binary CanMessage is appended.
        # @par
        
        component gcmessage
        ## @privatesection @brief GridConnectMessage component.
        # This component is used to encode CAN Messages in Grid Connect Message
        # format for transmission.
        component gcreply
        ## @brief GridConnectReply component.
        # This component is used to decode received Grid Connect Messages into
        # binary CAN Messages.
        component mtidetail
        ## @brief MTIDetail component.
        # This component is used to extract and pack fields from and to a CAN
        # header at a MTI detail level
        component mtiheader
        ## @brief MTIHeader component.
        # This component is used to extract and pack fields from and to a CAN
        # header at a MTI header level.
        component canheader
        ## @brief CANHeader component.
        # This component is used to extract and pack fields from and to a CAN
        # header at a CAN Header level.
        variable ttyfd
        ## The tty I/O channel.
        variable nidlist
        ## The Node ID as a list of 6 bytes.
        variable myalias
        ## My node alias.
        variable aliasMap -array {}
        ## Alias to NID map
        variable nidMap -array {}
        ## NID to alias map
        typevariable NIDPATTERN 
        ## The regexp for breaking up the Node ID into bytes.
        typeconstructor {
            set NIDPATTERN [::lcc::nid cget -regexp]
        }
        option -port -readonly yes -default "/dev/ttyACM0"
        option -nid  -readonly yes -default "05:01:01:01:22:00" -type lcc::nid
        method _peelnid {value} {
            ## Peel the Node ID into bytes and initializing the 48 bit
            # random number seed for alias generation.
            
            #puts stderr "*** $self _peelnid $value"
            set nidlist [list]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $value] 1 end] {
                lappend nidlist [scan $oct %02x]
            }
            #puts stderr "*** $self _peelnid: nidlist = $nidlist"
            # load the PRNG from the Node ID
            set lfsr1 [expr {([lindex $nidlist 0] << 16) | ([lindex $nidlist 1] << 8) | [lindex $nidlist 2]}]
            set lfsr2 [expr {([lindex $nidlist 3] << 16) | ([lindex $nidlist 4] << 8) | [lindex $nidlist 5]}]
            #puts stderr "*** $self _peelnid: lfsr1 = $lfsr1, lfsr2 = $lfsr2"
        }
        variable lfsr1 0
        ## Sequence value, upper 24 bits.
        variable lfsr2 0
        ## Sequence value, lower 24 bits.
        method _getAlias {} {
            ## Compute next alias.
            
            #puts stderr "*** $self getAlias: lfsr1 = $lfsr1, lfsr2 = $lfsr2"
            # First, form 2^9*val
            set temp1 [expr {(($lfsr1<<9) | (($lfsr2>>15)&0x1FF)) & 0xFFFFFF}]
            set temp2 [expr {($lfsr2<<9) & 0xFFFFFF}]
            
            # add
            set lfsr2 [expr {$lfsr2 + $temp2 + 0x7A4BA9}]
            set lfsr1 [expr {$lfsr1 + $temp1 + 0x1B0CA3}]
            # carry
            set lfsr1 [expr {($lfsr1 & 0xFFFFFF) | (($lfsr2&0xFF000000) >> 24)}]
            set lfsr2 [expr {$lfsr2 & 0xFFFFFF}]
            return [expr {($lfsr1 ^ $lfsr2 ^ ($lfsr1>>12) ^ ($lfsr2>>12) )&0xFFF}]
        }
        option -eventhandler -default {}
        method getMyAlias {} {
            ## @publicsection Return the current alias value.
            # @return The 12 bit node id alias.
            return $myalias
        }
        constructor {args} {
            ## @brief Constructor: create a connection to a Grid Connect USB serial device.
            # Connect to the CAN bus via a Grid Connect USB serial port
            # interface.
            #
            # @param name The name of the instance.
            # @param ... The options:
            # @arg -port The name of the serial port.  Typically "/dev/ttyACMn"
            # under Linux (using the cdc_acm driver).
            # @arg -nid The Node ID that the computer will assume in the format
            # of @c hh:hh:hh:hh:hh:hh which is a 48 bit number expressed as 6
            # pairs of hexadecimal digits separacted by colons (:).
            # @arg -eventhandler This is a script prefix that is run on incoming 
            # messages.  The current message as a binary CanMessage is appended.
            # @par
            
            install gcmessage using GridConnectMessage %AUTO%
            install gcreply   using GridConnectReply   %AUTO%
            install mtidetail using MTIDetail          %AUTO%
            install mtiheader using MTIHeader          %AUTO%
            install canheader using CANHeader          %AUTO%
            #puts stderr "*** $type create $self $args
            set options(-port) [from args -port]
            set options(-nid)  [from args -nid]
            $self _peelnid $options(-nid)
            if {[catch {open $options(-port) r+} ttyfd]} {
                set theerror $ttyfd
                catch {unset ttyfd}
                error [_ "Failed to open port %s because %s." $options(-port) $theerror]
                return
            }
            #puts stderr "*** $type create: port opened: $ttyfd"
            if {[catch {fconfigure $ttyfd -mode}]} {
                close $ttyfd
                catch {unset ttyfd}
                error [_ "%s is not a terminal port." $options(-port)]
                return
            }
            fconfigure $ttyfd -buffering line -translation {crlf crlf}
            fileevent $ttyfd readable [mymethod _messageReader]
            while {![$self _reserveMyAlias]} {
            }
            $mtiheader configure -mti 0x0100 -srcid $myalias -frametype 1
            set message [CanMessage %AUTO% -data $nidlist \
                         -header [$mtiheader getHeader] \
                         -extended true]
            $self _sendmessage $message
            $self configurelist $args
            # Send an AME
            $canheader configure -openlcbframe no \
                  -variablefield 0x0702 -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes]
        }
        method getAliasOfNID {nid} {
            ## Fetch the alias of a NID
            #
            # @param nid A full NID of the form hh:hh:hh:hh:hh:hh
            # @return The node's alias or the empty string if not known.
            lcc::nid validate $nid
            if {[info exists aliasMap($nid)]} {
                return $aliasMap($nid)
            } else {
                return {}
            }
        }
        method getNIDofAlias {alias} {
            ## Get the NID of the alias.
            #
            # @param alias The alias to look up.
            # @return The NID of the alias or the empty string if not known.
            if {[info exists nidMap($alias)]} {
                 return $nidMap($alias)
            } else {
                return {}
            }
        }
        method getAllNIDs {} {
            ## Get all known NIDs
            #
            # @return All known NIDS.
            
            return [array names aliasMap]
        }
        method getAllAliases {} {
            ## Get all known aliases
            #
            # @return All known aliases.
            
            return [array names nidMap]
        }
        method verifynode {args} {
            ## Send Verify node message.
            #
            # @param ... Options:
            # @arg -address Optional address to use, as a twelve bit number list.
            # @par
            
            set address [from args -address 0]
            if {$address == 0} {
                $mtiheader configure -mti 0x0490 -srcid $myalias -frametype 1
                set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                             -extended true]
            } else {
                lcc::twelvebits validate $address
                $mtiheader configure -mti 0x498 -srcid $myalias -frametype 1
                set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                             -extended true -data [list \
                                                   [expr {($address & 0x0F00) >> 8}] \
                                                   [expr {$address & 0x00FF}]] \
                             -length 2]
            }
            $self _sendmessage $message
        }
        method protosupport {address} {
            ## Send Protocol Support Inquiry message
            #
            # @param address Twelve bit alias address.
            
            lcc::twelvebits validate $address
            puts stderr "*** $self protosupport $address"
            $mtiheader configure -mti 0x0828 -srcid $myalias -frametype 1
            set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                         -extended true -data [list \
                                               [expr {($address & 0x0F00) >> 8}] \
                                               [expr {$address & 0x00FF}]] \
                         -length 2]
            puts stderr "*** $self protosupport: message is [$message toString]"
            $self _sendmessage $message
        }
        method identifyevents {args} {
            ## Send Identify Events message
            #
            # @param ... Options:
            # @arg -address Optional address to use, as a two byte list.
            # @par
            
            puts stderr "*** $self identifyevents $args"
            set address [from args -address 0]
            lcc::twelvebits validate $address
            puts stderr "*** $self identifyevents: address = $address"
            if {$address == 0} {
                $mtiheader configure -mti 0x0970 -srcid $myalias -frametype 1
                set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                             -extended true]
            } else {
                $mtiheader configure -mti 0x968 -srcid $myalias -frametype 1
                set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                             -extended true -data  [list \
                                                    [expr {($address & 0x0F00) >> 8}] \
                                                    [expr {$address & 0x00FF}]] \
                             -length 2]
            }
            $self _sendmessage $message
        }
        method identifyconsumer {event} {
            ## Send Identify Consumer message
            #
            # @param event Eight byte event number.
            
            puts stderr "*** $self identifyconsumer $event"
            $mtiheader configure -mti 0x08F4 -srcid $myalias -frametype 1
            set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                         -extended true -data $event -length 8]
            puts stderr "*** $self identifyconsumer: message is [$message toString]"
            $self _sendmessage $message
        }
        method getConfigOptions {address} {
            ## Send Get configuration options datagram command
            puts stderr "*** $self getConfigOptions $address"
            lcc::twelvebits validate $address
            $mtidetail configure -streamordatagram yes -destid $address \
                  -datagramcontent complete -srcid $myalias
            puts "*** $self  getConfigOptions \[$mtidetail getHeader\] = [$mtidetail getHeader]"
            set message [CanMessage %AUTO% -header [$mtidetail getHeader] \
                         -extended true -data [list 0x20 0x80] -length 2]
            puts stderr "*** $self  getConfigOptions message is [$message toString]"
            $self _sendmessage $message
        }
        method getAddrSpaceInfo {address space} {
            ## Send Address Space Information datagram command
            puts stderr "*** $self getAddrSpaceInfo $address $space"
            lcc::twelvebits validate $address
            $mtidetail configure -streamordatagram yes -destid $address \
                  -datagramcontent complete -srcid $myalias
            set message [CanMessage %AUTO% -header [$mtidetail getHeader] \
                         -extended true -data [list 0x20 0x84 $space] \
                         -length 3]
            puts stderr "*** $self getAddrSpaceInfo message is [$message toString]"
            $self _sendmessage $message
        }
        method DatagramAck {address} {
            ## Send Datagram OK message
            #
            # @param address Destination address.
            
            lcc::twelvebits validate $address
            puts stderr "*** $self DatagramAck $address"
            $mtiheader configure -mti 0x0A28 -srcid $myalias -frametype 1
            set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                         -extended true -data [list \
                                               [expr {($address & 0x0F00) >> 8}] \
                                               [expr {$address & 0x00FF}] \
                                               0x00] \
                         -length 3]
            puts stderr "*** $self DatagramAck message is [$message toString]"
            $self _sendmessage $message
        }
        method getSimpleNodeInfo {address} {
            lcc::twelvebits validate $address
            $mtiheader configure -mti 0x0DE8 -srcid $myalias -frametype 1
            set message [CanMessage %AUTO% -header [$mtiheader getHeader] \
                         -extended true -data [list \
                                               [expr {($address & 0x0F00) >> 8}] \
                                               [expr {$address & 0x00FF}]] \
                         -length 2]
            $self _sendmessage $message
        }
        method DatagramRead {destination space address length} {
            lcc::twelvebits validate $destination
            lcc::byte validate $space
            lcc::sixteenbits validate $address
            lcc::length validate $length
            
            $mtidetail configure -streamordatagram yes -destid $destination \
                  -datagramcontent complete -srcid $myalias
            set data [list 0x20]
            set spacein6 no
            if {$space == 0xFD} {
                lappend data 0x41
            } elseif {$space == 0xFE} {
                lappend data 0x42
            } elseif {$space == 0xFF} {
                lappend data 0x43
            } else {
                lappend data 0x40
                set spacein6 yes
            }
            lappend data [expr {($address & 0xFF000000) >> 24}]
            lappend data [expr {($address & 0x00FF0000) >> 16}]
            lappend data [expr {($address & 0x0000FF00) >>  8}]
            lappend data [expr {($address & 0x000000FF) >>  0}]
            if {$spacein6} {lappend data $space}
            lappend data $length
            set message [CanMessage %AUTO% -header [$mtidetail getHeader] \
                         -extended true -data $data -length [llength $data]]
            puts stderr "*** $self DatagramRead message is [$message toString]"
            $self _sendmessage $message
        }
                         
            
        method _messageReader {} {
            ## @privatesection @brief Message reader method.
            # This method is the readable event handler for the serial port
            # Messages are read and decoded.  If the message is an OpenLCB 
            # message and is global or addressed to this station, it is passed
            # on to the defined event handler.
            #
            if {[gets $ttyfd message]} {
                $gcreply configure -message $message
                puts stderr "*** $self _messageReader: message is $message"
                set r [$gcreply createReply]
                $canheader setHeader [$r getHeader]
                puts stderr "*** $self _messageReader: canheader : [$canheader configure]"
                if {[$canheader cget -openlcbframe]} {
                    $mtiheader setHeader [$canheader getHeader]
                    $mtidetail setHeader [$canheader getHeader]
                    puts stderr "*** $self _messageReader: mtiheader : [$mtiheader configure]"
                    puts stderr "*** $self _messageReader: mtidetail : [$mtidetail configure]"
                    if {[$mtiheader cget -frametype] == 1 &&
                        [$mtidetail cget -addressp]} {
                        set destid [expr {(([lindex [$r getData] 0] & 0x0F) << 8) | [lindex [$r getData] 1]}]
                        if {$destid != $myalias} {
                            # The message is not addressed to me, discard it.
                            return
                        }
                    } elseif {[$mtidetail cget -streamordatagram]} {
                        set destid [$mtidetail cget -destid]
                        if {$destid != $myalias} {
                            # The message is not addressed to me, discard it.
                            return
                        }
                    }
                    set handler [$self cget -eventhandler]
                    if {$handler ne {}} {
                        uplevel #0 "$handler $r"
                    }
                } else {
                    # Not a OpenLCB message.
                    # Check for an Error Information Report
                    set vf [$canheader cget -variablefield]
                    puts stderr "[format {*** %s _messageReader: vf = 0x%04X} $self $vf]"
                    if {$vf == 0x0701} {
                        # AMD frame
                        puts stderr "*** $self _messageReader: received AMD frame"
                        set srcalias [$canheader cget -srcid]
                        set srcnid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] [lrange [$r getData] 0 5]]
                        puts stderr "[format {*** %s _messageReader: srcalias = 0x%03X, srcnid = %s} $self $srcalias $srcnid]"
                        set nidMap($srcalias) $srcnid
                        set aliasMap($srcnid) $srcalias
                    } elseif {$vf == 0x0702} {
                        # AME frame
                        if {[listeq [lrange [$r getData] 0 5] {0 0 0 0 0 0}] || [listeq [lrange [$r getData] 0 5] $nidlist]} {
                            $canheader configure -openlcbframe no \
                                  -variablefield 0x0701 -srcid $myalias
                            $self _sendmessage [CanMessage %AUTO% -header [$canheader getHeader] -extended yes -data $nidlist -length 6]
                        }
                    } elseif {$vf >= 0x0710 || $vf <= 0x0713} {
                        # Was an Error Information Report -- flag it.
                        incr _timeoutFlag -2
                    } else {
                        
                        #### Node ID Alias Collision handling... NYI
                    }
                }
            } else {
                # Error reading -- probably EOF / disconnect.
                $self destroy
            }
        }
        variable _timeoutFlag 0
        ## Timeout or error message received flag.
        method _reserveMyAlias {} {
            ## @brief Reserve an alias.
            # Sends out CID messages and eventually RID and AMD messages, if
            # there are no errors.
            # 
            # @return A boolean value indicating a successfully reserved alias
            # (true) or failure (false).
            
            # Generate a tentative alias.
            set myalias [$self _getAlias]
            
            # Send out Check ID frames.
            # CID1
            $canheader configure -openlcbframe no \
                  -variablefield [expr {(0x7 << 12) | [getBits 47 36 $nidlist]}] \
                  -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes]
            # CID2
            $canheader configure -openlcbframe no \
                  -variablefield [expr {(0x6 << 12) | [getBits 35 24 $nidlist]}] \
                  -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes]
            # CID3
            $canheader configure -openlcbframe no \
                  -variablefield [expr {(0x5 << 12) | [getBits 23 12 $nidlist]}] \
                  -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes]
            # CID4
            $canheader configure -openlcbframe no \
                  -variablefield [expr {(0x4 << 12) | [getBits 11 0 $nidlist]}] \
                  -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes]
            set _timeoutFlag 0
            set timoutID [after 500 [mymethod _timedout]]
            vwait [myvar _timeoutFlag]
            if {$_timeoutFlag < 0} {
                # Received an error report.  Cancel the timeout and return
                # false.
                catch [after cancel $timoutID]
                return false
            }
            # No errors after 500ms timeout.  We can reserve our alias.
            # RID
            $canheader configure -openlcbframe no \
                  -variablefield 0x0700 -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes]
            # AMD
            $canheader configure -openlcbframe no \
                  -variablefield 0x0701 -srcid $myalias
            $self _sendmessage [CanMessage %AUTO% \
                                -header [$canheader getHeader] -extended yes \
                                -data $nidlist -length 6]
            set nidMap($myalias) [$self cget -nid]
            set aliasMap([$self cget -nid]) $myalias
            return true
        }
        method _timedout {} {
            ## Timeout event.
            incr _timeoutFlag
        }
        method _sendmessage {canmessage} {
            ## @brief Send a CAN Message.
            # A CAN message is encoded as a Grid Connect message and 
            # transmitted.
            #
            # @param canmessage The binary CAN message to be sent.
            
            puts stderr "*** $self _sendmessage [$canmessage toString]"
            $gcmessage configure -canmessage $canmessage
            puts $ttyfd [$gcmessage toString]
            flush $ttyfd
        }
        proc getBits {top bottom bytelist} {
            ## @brief Get the selected bitfield.
            # Extract the bits from a list of 6 8-bit (byte) numbers 
            # representing a 48 bit number.
            #
            # @param top Topmost (highest) bit number.
            # @param bottom Bottommost (lowest) bit number.
            # @param bytelist List of 6 bytes.
            # @return An integer value.
            
            set topbyteindex [expr {5 - ($top / 8)}]
            set bottomindex  [expr {5 - ($bottom / 8)}]
            set word 0
            for {set i $topbyteindex} {$i <= $bottomindex} {incr i} {
                set word [expr {($word << 8) | [lindex $bytelist $i]}]
            }
            set shift [expr {$bottom - (($bottom / 8)*8)}]
            set word  [expr {$word >> $shift}]
            set nbits [expr {($top - $bottom)+1}]
            set mask  [expr {(1 << $nbits) - 1}]
            set word  [expr {$word & $mask}]
            return $word
        }
            
            
        proc listeq {a b} {
            ## @brief Compare two lists.
            # Compares two lists for equality.
            #
            # @param a First list to compare.
            # @param b Second list to compare.
            # @return A boolean value: true if the lists are the same, false 
            # if not.
            
            if {[llength $a] != [llength $b]} {
                return false
            }
            foreach aele $a bele $b {
                if {$aele != $bele} {
                    return false
                }
            }
            return true
        }
    }
    proc peelCANheader {header} {
        set CANPrefix [expr {($header & wide(0x18000000)) >> 27}]
        set CANFrameType [expr {($header & wide(0x07000000)) >> 24}]
        set CAN_MTI [expr {($header & wide(0x00FFF000)) >> 12}]
        set SRCID   [expr {($header & wide(0x00000FFF))}]
        set CAN_StaticPriority [expr {($header & wide(0x00C00000)) >> 22}]
        set CAN_TypeWithinPriority [expr {($header & wide(0x003E0000)) >> 17}]
        set CAN_Simple [expr {($header & wide(0x00010000)) >> 16}]
        set CAN_AP [expr {($header & wide(0x00008000)) >> 15}]
        set CAN_EIDP [expr {($header & wide(0x00004000)) >> 14}]
        set CAN_MB [expr {($header & wide(0x00003000)) >> 12}]
        puts [format "%08X --" $header]
        puts [format "  CANPrefix   : %0X" $CANPrefix]
        puts [format "  CANFrameType: %0X" $CANFrameType]
        puts [format "  CAN_MTI     : %03X" $CAN_MTI]
        puts [format "    CAN_StaticPriority    : %0X" $CAN_StaticPriority]
        puts [format "    CAN_TypeWithinPriority: %0X" $CAN_TypeWithinPriority]
        puts [format "    CAN_Simple            : %0X" $CAN_Simple]
        puts [format "    CAN_AP                : %0X" $CAN_AP]
        puts [format "    CAN_EIDP              : %0X" $CAN_EIDP]
        puts [format "    CAN_MB                : %0X" $CAN_MB]
        puts [format "  SRCID  : %03X" $SRCID]
        return [list header $header CANPrefix $CANPrefix \
                CANFrameType $CANFrameType \
                CAN_MTI [list $CAN_MTI \
                         CAN_StaticPriority $CAN_StaticPriority \
                         CAN_TypeWithinPriority $CAN_TypeWithinPriority \
                         CAN_Simple $CAN_Simple CAN_AP $CAN_AP \
                         CAN_EIDP $CAN_EIDP CAN_MB $CAN_MB] \
                SRCID $SRCID]
    }

}
  

## @}


package provide LCC 1.0

