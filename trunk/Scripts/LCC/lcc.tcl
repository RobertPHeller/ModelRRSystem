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
#  Last Modified : <160211.1722>
#
#  Description	
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
    
    snit::integer byte -min 0 -max 255
    
    snit::macro ::lcc::AbstractMessage {} {
        ## @brief Define common variables and accessor methods
        #
        
        method getElement {n} {
            return [lindex $_dataChars $n]
        }
        method getNumDataElements {} {
            return $_nDataChars
        }
        method setElement {n v} {
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
        variable _nDataChars 0
    }
    snit::macro ::lcc::AbstractMRMessage {} {
        ## @Brief Macro to create common methods and variables for an AbstractMRMessage
        #
        
        lcc::AbstractMessage;# Include base AbstractMessage
        method setOpCode {i} {
            lset _dataChars 0 $i
        }
        method getOpCode {} {
            return [lindex $_dataChars 0]
        }
        
        method getOpCodeHex {} {
            return [format {0x%x} [$self getOpCode]]
        }
        variable mNeededMode 0
        method setNeededMode {pMode} {
            set mNeededMode $pMode
        }
        method getNeededMode {} {
            return $mNeededMode
        }
        method replyExpected {} {return true}
        variable _isBinary false
        method isBinary {} {return $_isBinary}
        method setBinary {b} {set _isBinary $b}
        typevariable SHORT_TIMEOUT 2000
        typevariable LONG_TIMEOUT 60000
        variable mTimeout 0
        method setTimeout {t} {set mTimeout $t}
        method getTimeout {} {return $mTimeout}
        variable mRetries 0
        method setRetries {i} {set mRetries $i}
        method getRetries {} {return $mRetries}
        method addIntAsThree {val offset} {
            set svals [scan [format {%03d} $val] %c%c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
            $self setElement [expr {$offset+2}] [lindex $svals 2]
        }
        method addIntAsTwoHex {val offset} {
            set svals [scan [format {%02X} $val] %c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
        }
        method addIntAsThreeHex {val offset} {
            set svals [scan [format {%03X} $val] %c%c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
            $self setElement [expr {$offset+2}] [lindex $svals 2]
        }
        method addIntAsFourHex {val offset} {
            set svals [scan [format {%04X} $val] %c%c%c%c]
            $self setElement $offset [lindex $svals 0]
            $self setElement [expr {$offset+1}] [lindex $svals 1]
            $self setElement [expr {$offset+2}] [lindex $svals 2]
            $self setElement [expr {$offset+3}] [lindex $svals 3]
        }
        method setNumDataElements {n} {set _nDataChars $n}
        method toString {} {
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

    snit::type CanMessage {
        lcc::AbstractMRMessage
        variable _translated false
        method setTranslated {translated} {set _translated $translated}
        method isTranslated {} {return $_translated}
        option -header -readonly yes -default 0 -type snit::integer
        option -length -readonly yes -default 0 -type {snit::integer -min 0 -max 8}
        option -data   -readonly yes -default {} -type {snit::listtype -minlen 0 -maxlen 8}
        constructor {args} {
            set _header [from args -header 0]
            set _isExtended false
            set _isRtr false
            set _nDataChars 8
            $self setBinary true
            set _dataChars [list 0 0 0 0 0 0 0 0]
            if {[lsearch $args -length] >= 0} {
                set _nDataChars [from args -length]
                set _dataChars [list]
                for {set i 0} {$i < $_nDataChars} {incr i} {
                    lappend _dataChars 0
                }
            } elseif {[lsearch $args -data] >= 0} {
                set _dataChars [from args -data]
                set _nDataChars [llength $_dataChars]
            }
        }
        typemethod {Create header} {header} {
            return [$type %AUTO% -header $header]
        }
        typemethod {Create length} {i header} {
            return [$type %AUTO% -header $header -length $i]
        }
        typemethod {Create data} {d header} {
            return [$type %AUTO% -header $header -data $d]
        }
        typemethod copy {m} {
            set result [$type %AUTO%]
            $result setHeader [$m getHeader]
            $result setExtended [$m isExtended]
            $result setRtr [$m isRtr]
            $result setBinary true
            $result setNumDataElements [$m getNumDataElements]
            $result setData [$m getData
            return $result
        }
        method hashCode {} {return $_header}
        method equals {a} {
            if {[$a info type] ne $type} {return false}
            if {[$a getHeader] != $_header || 
                [$a isRtr] != $_isRtr || 
                [$a isExtended] != $_isExtended} {
                return false
            }
                                                                    
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
        method replyExpected {} {return true}
        method setNumDataElements {n} {set _nDataChars $n}
        method setData {d} {
            set len [llength $_dataChars]
            if {[llength $d] < $len} {
                set len [llength $d]
            }
            for {set i 0} {$i < $len} {incr i} {
                lset _dataChars $i [lindex $d $i]
            }
        }
        method getData {} {return $_dataChars}
        method getHeader {} {return $_header}
        method setHeader {h} {set _header $h}
        method isExtended {} {return $_isExtended}
        method setExtended {b} {set _isExtended $b}
        method isRtr {} {return $_isRtr}
        method setRtr {b} {set _isRtr $b}
        variable _header
        variable _isExtended
        variable _isRtr
        typemethod validate {o} {
            if {[catch {$o info type} thetype]} {
                error "Not a $type: $o"
            } elseif {$thetype ne $type} {
                error "Not a $type: $o"
            } else {
                return $o
            }
        }
    }
    
    snit::type GridConnectMessage {
        lcc::AbstractMRMessage
        option -canmessage 
        constructor {args} {
            set _nDataChars 28
            set _dataChars [list]
            for {set i 0} {$i < 28} {incr i} {
                lappend _dataChars 0
            }
            $self setElement 0 ":"
        }
        typemethod create_fromCanMessage {m} {
            lcc::CanMessage validate $m
            set result [$type create %AUTO%]
            $result setExtended [$m isExtended]
            $result setHeader   [$m getHeader]
            $result setRtr      [$m isRtr]
            for {set i 0} {$i < [$m getNumDataElements]} {incr i} {
                $result setByte [$m getElement $i] $i
            }
            if {[$result isExtended]} {
                set offset 11
            } else {
                set offset 6
            }
            $result setElement [expr {$offset + ([$m getNumDataElements] * 2)}] ";"
            $result setNumDataElements [expr {$offset + 1 + ([$m getNumDataElements] * 2)}]
            return $result
        }
        method setExtended {extended} {
            if {$extended} {
                $self setElement 1 "X"
            } else {
                $self setElement 1 "S"
            }
        }
        method isExtended {} {
            set E [format {%c} [$self getElement 1]]
            return [expr {$E eq "X"}]
        }
        method setHeader {header} {
            if {[$self isExtended]} {
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
        method setRtr {rtr} {
            if {[$self isExtended]} {
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
        method setByte {val n} {
            if {($n >= 0) && ($n <= 7)} {
                set index [expr {$n * 2 + ([$self isExtended] ? 11 : 6)}]
                $self setHexDigit [expr {($val >> 4) & 0x0F}] $index
                incr index
                $self setHexDigit [expr {$val& 0x0F}] $index
            }
        }
        method setHexDigit {val n} {
            if {($val >= 0) && ($val <= 15)} {
                lset _dataChars $n [scan [format %X $val] %c]
            } else {
                lset _dataChars $n [scan "0" %c]
            }
        }
    }
    
    snit::type GridConnectReply {
        lcc::AbstractMRMessage
        typevariable MAXLEN 27
        option -message -readonly yes
        constructor {args} {
            set _nDataChars 0
            set _dataChars [list]
            for {set i 0} {$i < $MAXLEN} {incr i} {
                lappend _dataChars 0
            }
            set s [from args -message ""]
            if {[string length $s] > $MAXLEN} {
                set s [string range $s 0 [expr {$MAXLEN - 1}]]
            }
            #puts stderr "*** $type create $self: s = '$s'"
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
        method createReply {} {
            set ret [lcc::CanMessage %AUTO%]
            if {![$self basicFormatCheck]} {
                $ret setHeader 0
                $ret setNumDataElements 0
                return $ret
            }
            if {[$self isExtended]} {
                $ret setExtended true
            }
            $ret setHeader [$self getHeader]
            if {[$self isRtr]} {
                $ret setRtr true
            }
            for {set i 0} {$i < [$self getNumBytes]} {incr i} {
                $ret setElement $i [$self getByte $i]
            }
            $ret setNumDataElements [$self getNumBytes]
            return $ret
        }
        method basicFormatCheck {} {
            set E [format {%c} [$self getElement 1]]
            if {$E ne "X" && $E ne "S"} {
                return false
            } else {
                return true
            }
        }
        method skipPrefix {index} {
            set colon [scan ":" %c]
            while {[lindex $_dataChars $index] != $colon} {
                incr index
            }
            return $index
        }
        method setElement {n v} {
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
        method isExtended {} {
            set E [format {%c} [$self getElement 1]]
            return [expr {$E eq "X"}]
        }
        method isRtr {} {
            set R [format {%c} [$self getElement $_RTRoffset]]
            return [expr {$R eq "R"}]
        }
        method maxSize {} {
            return $MAXLEN
        }
        method setData {d} {
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
        method getHeader {} {
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
            return [expr {($_nDataChars - ($_RTRoffset + 1)) / 2}]
        }
        method getByte {b} {
            {($b >= 0) && ($b <= 7)} {
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
            set b [lindex $_dataChars $index]
            return [scan [format %c $b] %x]
        }
    }
            
            
}
  

## @}

package provide LCC 1.0

