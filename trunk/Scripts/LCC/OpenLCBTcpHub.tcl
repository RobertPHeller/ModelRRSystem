#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jun 25 10:37:16 2016
#  Last Modified : <160625.1259>
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


## @addgroup LCCModule
# @{

package require snit
package require gettext
package require LCC

namespace eval lcc {
    snit::type OpenLCBTcpHub {
        typevariable _routeTable -array {}
        typevariable _allNodes {}
        typevariable _listenerChannel {}
        
        variable channel {}
        variable remoteHost {}
        variable remotePort {}
        component mtidetail
        typeconstructor {
            global argv
            global argc
            global argv0
            
            set host [from argv -host localhost]
            set port [from argv -port 12000]
            set _listenerChannel [socket -server [mytypemethod _accept] \
                                  -myaddr $host $port]
        }
        typemethod _accept {chan remhost remport} {
            puts stderr "*** $type _accept $chan $remhost $remport"    
            $type create %AUTO% $chan $remhost $remport
        }
        constructor {ch rhost rport args} {
            set channel $ch
            set remoteHost $rhost
            set remotePort $rport
            install mtidetail using MTIDetail          %AUTO%
            lappend _allNodes $self
            fconfigure $channel -buffering none -encoding binary \
                  -translation {binary binary}
            fileevent $channel readable [mymethod _messageReader]
            #$self configurelist $args
            puts stderr "*** $type create $self: _allNodes = $_allNodes"
        }
        destructor {
            puts stderr "*** $self destroy"
            catch {close $channel}
            set nindix [lsearch -exact $_allNodes $self]
            if {$nindix >= 0} {
                set _allNodes [lreplace $_allNodes $nindix $nindix]
            }
            puts stderr "*** $self destroy: _allNodes = $_allNodes"
            foreach dest [array names _routeTable] {
                set nindix [lsearch -exact $_routeTable($dest) $self]
                set _routeTable($dest) [lreplace $_routeTable($dest) $nindix $nindix]
                if {[llength $_routeTable($dest)] == 0} {
                    unset _routeTable($dest)
                }
            }
            puts stderr "*** $self destroy: _routeTable contains:"
            foreach dest [array names _routeTable] {
                puts stderr "*** $self destroy:   $dest => $_routeTable($dest)"
            }
        }
        method sendMessage {message} {
            lcc::OpenLCBMessage validate $message
            set preamble 0x8000;# Common OpenLCB bit.
            set messageData [$self _makeBinaryMessage $message]
            set totallength [expr {[llength $messageData] + (48/8) + (48/8)}]
            set tlbytes [list \
                         [expr {($totallength & 0xFF0000) >> 16}] \
                         [expr {($totallength & 0xFF00) >> 8}] \
                         [expr {$totallength & 0xFF}]]
            set sourcenid [list]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] [$message cget -sourcenid]] 1 end] {
                lappend sourcenid [scan $oct %02x]
            }
            set seqnum [expr {[clock milliseconds] & wide(0x0FFFFFFFFFFFF)}]
            set sqbytes [list \
                         [expr {($seqnum & wide(0x0FF0000000000)) >> 40}] \
                         [expr {($seqnum &   wide(0x0FF00000000)) >> 32}] \
                         [expr {($seqnum &     wide(0x0FF000000)) >> 24}] \
                         [expr {($seqnum &       wide(0x0FF0000)) >> 16}] \
                         [expr {($seqnum &         wide(0x0FF00)) >>  8}] \
                         [expr {($seqnum &           wide(0x0FF))      }]]
            set messageBlock [binary format {Sc3c6c6c*} $preamble $tlbytes $sourcenid $sqbytes $messageData]
            puts -nonewline $channel $messageBlock
            flush $channel
        }
        method _messageReader {} {
            set buffer [read $channel 2];# Preamble
            if {[eof $channel] || [string length $buffer] < 2} {
                $self destroy
                return
            }
            if {[binary scan $buffer S preamble] < 1} {
                $self destroy
                return
            }
            set preamble [expr {$preamble & 0x0FFFF}]
            if {($preamble & 0x8000) == 0} {
                # Link control message ...
            } else {
                set buffer [read $channel 3];# total length (24 bits)
                binary scan $buffer c3 tlist
                set totallength [expr {([lindex $tlist 0] & 0x0FF) << 16}]
                set totallength [expr {$totallength | (([lindex $tlist 1] & 0x0FF) << 8)}]
                set totallength [expr {$totallength | ([lindex $tlist 2] & 0x0FF)}]
                set buffer [read $channel $totallength]
                binary scan $buffer c6c6c* orignidlist_s seqlist openlcbmessage_s
                set orignidlist [list]
                foreach b $orignidlist_s {
                    lappend orignidlist [expr {$b & 0x0FF}]
                }
                set orignid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] $orignidlist]
                set seqnum [expr {           wide([lindex $seqlist 0] &  0x0FF) << 40}]
                set seqnum [expr {$seqnum | wide(([lindex $seqlist 1] &  0x0FF) << 32)}]
                set seqnum [expr {$seqnum | wide(([lindex $seqlist 2] &  0x0FF) << 24)}]
                set seqnum [expr {$seqnum | wide(([lindex $seqlist 3] &  0x0FF) << 16)}]
                set seqnum [expr {$seqnum | wide(([lindex $seqlist 4] &  0x0FF) <<  8)}]
                set seqnum [expr {$seqnum |  wide([lindex $seqlist 5] &  0x0FF)}]
                set openlcbmessage [list]
                foreach b $openlcbmessage_s {
                    lappend openlcbmessage [expr {$b & 0x0FF}]
                }
                set openlcbMessage [$self _unpackBinaryMessage $openlcbmessage]
                set dest [$openlcbMessage cget -destnid]
                set source [$openlcbMessage cget -sourcenid]
                $type UpdateRoute $source $self
                if {$dest eq ""} {
                    puts stderr "$self _messageReader: Broadcasting [$openlcbMessage toString]"
                    $type Broadcast $openlcbMessage -except $self
                } else {
                    puts stderr "$self _messageReader: Routing to $dest [$openlcbMessage toString]"
                    $type SendTo $dest $openlcbMessage -except $self
                }
            }
        }
        method _unpackBinaryMessage {messagebuffer} {
            set MTI [expr {([lindex $messagebuffer 0] << 8) | [lindex $messagebuffer 1]}]
            $mtidetail setMTI16Header $MTI
            set sourcenid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] [lrange $messagebuffer 2 7]]
            set result [lcc::OpenLCBMessage %AUTO%  -sourcenid $sourcenid \
                        -mti $MTI]
            set dataoff 8
            if {[$mtidetail cget -addressp]} {
                set destend [expr {$dataoff + 5}]
                set destid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] [lrange $messagebuffer $dataoff $destend]]
                set dataoff [expr {$destend + 1}]
                $result configure -destnid $destid
            }
            if {[$mtidetail cget -eventp]} {
                set eventend [expr {$dataoff + 7}]
                set eventid [lcc::EventID %AUTO% -eventidlist [lrange $messagebuffer $dataoff $eventend]]
                $result configure -eventid $eventid
                set dataoff [expr {$eventend + 1}]
            }
            $result configure -data [lrange $messagebuffer $dataoff end]
            return $result
        }
        method _makeBinaryMessage {openlcbMessage} {
            set buffer    [list]
            set mti       [$openlcbMessage cget -mti]
            $mtidetail setMTI16Header $mti
            lappend buffer [expr {($mti & 0xFF00) >> 8}]
            lappend buffer [expr {$mti & 0xFF}]
            set sourcenid [$openlcbMessage cget -sourcenid]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $sourcenid] 1 end] {
                lappend buffer [scan $oct %02x]
            }
            if {[$mtidetail cget -addressp]} {
                set destnid [$openlcbMessage cget -destnid]
                foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $destnid] 1 end] {
                    lappend buffer [scan $oct %02x]
                }
            }
            if {[$mtidetail cget -eventp]} {
                set evlist [[$openlcbMessage cget -eventid] cget -eventidlist]
                foreach oct $evlist {
                    lappend buffer $oct
                }
            }
            foreach oct [$openlcbMessage cget -data] {
                lappend buffer $oct
            }
            return $buffer
        }
        typemethod Broadcast {message args} {
            puts stderr "*** $type Broadcast $message $args"
            set except [from args -except {}]
            foreach n $_allNodes {
                if {[lsearch -exact $except $n] < 0} {
                    puts stderr "*** $type Broadcast: sending to $n"
                    $n sendMessage $message
                }
            }
        }
        typemethod SendTo {destination message args} {
            puts stderr "*** $type SendTo $destination $message $args"
            set except [from args -except {}]
            foreach n $_routeTable($destination) {
                if {[lsearch -exact $except $n] < 0} {
                    puts stderr "*** $type SendTo: sending to $n"
                    $n sendMessage $message
                }
            }
        }
        typemethod UpdateRoute {destination routeobj} {
            if {[catch {set _routeTable($destination)} routes]} {
                lappend _routeTable($destination) $routeobj
            } elseif {[lsearch -exact $routes $routeobj] < 0} {
                lappend _routeTable($destination) $routeobj
            }
            puts stderr "*** $type UpdateRoute: _routeTable contains:"
            foreach dest [array names _routeTable] {
                puts stderr "*** $type UpdateRoute:   $dest => $_routeTable($dest)"
            }
            
        }
    }
}

vwait forever
