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
#  Last Modified : <170511.1257>
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


## @page OpenLCBTcpHub OpenLCB Tcp/Ip Hub Server
# @brief OpenLCB Tcp Hub daemon.
#
# @section OpenLCBTcpHubSYNOPSIS SYNOPSIS
#
# OpenLCBTcpHub [-host localhost] [-port 12000] [-debug]
#
# @section OpenLCBTcpHubDESCRIPTION DESCRIPTION
#
# This program is a server daemon that implements a hub for OpenLCB over 
# Tcp/Ip that accepts connections from OpenLCB over Tcp/Ip nodes and forwards
# OpenLCB messages between clients.
#
# @section OpenLCBTcpHubPARAMETERS PARAMETERS
#
# none
#
# @section OpenLCBTcpHubOPTIONS OPTIONS
#
# @arg -log  logfilename The name of the logfile.  Defaults to 
# OpenLCBTcpHub.log
# @arg -host hostname The name or IP address of the host to bind to.  Defaults 
# to localhost (binds only to the local loopback device).  Using an address of
# 0.0.0.0 will bind to all interfaces.
# @arg -port portnumber The Tcp/Ip port to listen on.  Defaults to 12000.
# @arg -debug Turns on debug logging.
# @arg -remote host[:port], -remote0 host[:port], -remote1 host[:port], ... 
#      -remote9 host[:port] Optional remote Tcp/Ip hubs.
# @par
#
# @section OpenLCBTcpHubAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCBTcpHub]

#package require Sigterm
package require snit
package require gettext
package require log                                                             
package require LCC

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
snit::type OpenLCBTcpHub {
    #** @brief This class implements the OpenLCB Tcp Hub Server.
    #
    # The static members implement global initialization and the listener.
    # The class instances are client connections.
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    #

    typevariable _routeTable -array {}
    #** The routing table.  This is an array, indexed by NIDs, containing
    # client connection instances.  Used for messages destined to a specific
    # NID.
    typevariable _allNodes {}
    #** The list of all client connection instances.  Used for broadcast 
    # messages.
    typevariable _listenerChannel {}
    #** The Listener socket.  This is the socket we are listening on for
    # client connections. Incoming connections are processed by the 
    # _accept typemethod.
    typevariable logchan
    #** @brief Logfile channel.
    typevariable defaultport 12000
    #** @brief Default Tcp/Ip port number. 
        
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Creates the listener and set up the logging.
        #
        
        global argv
        global argc
        global argv0
        
        set debugnotvis 1
        set debugIdx [lsearch -exact $argv -debug]
        if {$debugIdx >= 0} {
            set debugnotvis 0
            set argv [lreplace $argv $debugIdx $debugIdx]
        }
        set host [from argv -host localhost]
        set port [from argv -port $defaultport]
        set deflogfilename [format {%s.log} [file tail $argv0]]
        set logfilename [from argv -log $deflogfilename]
        if {[file extension $logfilename] ne ".log"} {append logfilename ".log"}
        close stdin
        close stdout
        close stderr
        set null /dev/null
        if {$::tcl_platform(platform) eq "windows"} {
            set null nul
        }
        open $null r
        open $null w
        set logchan [open $logfilename w]
        fconfigure $logchan  -buffering none
        
        ::log::lvChannelForall $logchan
        ::log::lvSuppress info 0
        ::log::lvSuppress notice 0
        ::log::lvSuppress debug $debugnotvis
        ::log::lvCmdForall [mytypemethod LogPuts]
        
        ::log::logMsg [_ "%s starting, listening on %s:%d" $type $host $port]
        set _listenerChannel [socket -server [mytypemethod _accept] \
                              -myaddr $host $port]
        foreach op {-remote -remote0 -remote1 -remote2 -remote3 -remote4 -remote5 -remote6 -remote7 -remote8 -remote9} {
            set remote [from argv $op]
            if {$remote eq ""} {continue}
            if {[regexp {^([^:]+):([[:digit:]]+)$} $remote -> remhost portno] < 1} {
                set remhost $remote
                set portno $defaultport
            }
            if {[catch {socket $remhost $portno} sockfd]} {
                ::log::logError [_ "Socket to %s:%d not opened: %s" $remhost $portno $sockfd]
                continue
            } else {
                $type create %AUTO% $sockfd $remhost $portno
            }
        }
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod _accept {chan remhost remport} {
        #** Connection acceptance method.
        #
        # @param chan The connection channel.
        # @param remhost The remote host.
        # @param remport The remote port.
        
        ::log::log debug "*** $type _accept $chan $remhost $remport"    
        $type create %AUTO% $chan $remhost $remport
    }
    typemethod Broadcast {message args} {
        #** Handle a broadcast message.
        #
        # @param message The message.
        # @param ... Options:
        # @arg -except Connection instance(s) not to send to.
        # @par
        
        ::log::log debug "*** $type Broadcast $message $args"
        set except [from args -except {}]
        foreach n $_allNodes {
            if {[lsearch -exact $except $n] < 0} {
                ::log::log debug "*** $type Broadcast: sending to $n"
                $n sendMessage $message
            }
        }
    }
    typemethod SendTo {destination message args} {
        #** Handle a message to a specific address.
        #
        # @param destination The destination address to send to.
        # @param message The message.
        # @param ... Options:
        # @arg -except Connection instance(s) not to send to.
        # @par

        ::log::log debug "*** $type SendTo $destination $message $args"
        set except [from args -except {}]
        foreach n $_routeTable($destination) {
            if {[lsearch -exact $except $n] < 0} {
                ::log::log debug "*** $type SendTo: sending to $n"
                $n sendMessage $message
            }
        }
    }
    typemethod UpdateRoute {destination routeobj} {
        #** Update the routing table.
        #
        # @param destination The destination address to update the route to.
        # @param routeobj The connection instance to route messages to for the
        # specificed destination.
        
        if {[catch {set _routeTable($destination)} routes]} {
            lappend _routeTable($destination) $routeobj
        } elseif {[lsearch -exact $routes $routeobj] < 0} {
            lappend _routeTable($destination) $routeobj
        }
        ::log::log debug "*** $type UpdateRoute: _routeTable contains:"
        foreach dest [array names _routeTable] {
            ::log::log debug "*** $type UpdateRoute:   $dest => $_routeTable($dest)"
        }
        
    }
    variable channel {}
    #** Connection socket.
    variable remoteHost {}
    #** Remote host.
    variable remotePort {}
    #** Remote port.
    component mtidetail
    #**  MTI Detail component
    
    constructor {ch rhost rport args} {
        #** Connection constructor.  Construct a connection.
        #
        # @param ch The socket channel for this connection.
        # @param rhost The remote host.
        # @param rport The remote port.
        # @param ... Options:
        
        ::log::logMsg [_ "Acception connection from %s on port %d" $rhost $rport]
        set channel $ch
        set remoteHost $rhost
        set remotePort $rport
        install mtidetail using lcc::MTIDetail          %AUTO%
        lappend _allNodes $self
        fconfigure $channel -buffering none -encoding binary \
              -translation {binary binary}
        fileevent $channel readable [mymethod _messageReader]
        #$self configurelist $args
        ::log::log debug "*** $type create $self: _allNodes = $_allNodes"
    }
    destructor {
        #** Destructor -- clean things up.
        
        ::log::log debug "*** $self destroy"
        ::log::logMsg [_ "Closing connection from %s on port %d" $remoteHost $remotePort]
        catch {close $channel}
        set nindix [lsearch -exact $_allNodes $self]
        if {$nindix >= 0} {
            set _allNodes [lreplace $_allNodes $nindix $nindix]
        }
        ::log::log debug "*** $self destroy: _allNodes = $_allNodes"
        foreach dest [array names _routeTable] {
            set nindix [lsearch -exact $_routeTable($dest) $self]
            set _routeTable($dest) [lreplace $_routeTable($dest) $nindix $nindix]
            if {[llength $_routeTable($dest)] == 0} {
                unset _routeTable($dest)
            }
        }
        ::log::log debug "*** $self destroy: _routeTable contains:"
        foreach dest [array names _routeTable] {
            ::log::log debug "*** $self destroy:   $dest => $_routeTable($dest)"
        }
    }
    method sendMessage {message} {
        #** Send a message.
        # @param message The  message to send.
        
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
        #** Message reader handler.
        
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
                ::log::log debug "$self _messageReader: Broadcasting [$openlcbMessage toString]"
                $type Broadcast $openlcbMessage -except $self
            } else {
                ::log::log debug "$self _messageReader: Routing to $dest [$openlcbMessage toString]"
                $type SendTo $dest $openlcbMessage -except $self
            }
        }
    }
    method _unpackBinaryMessage {messagebuffer} {
        #** Unpack a binary message.
        #
        # @param messagebuffer A byte array containing the message bytes.
        # @return An OpenLCBMessage instance.
        
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
        #** Create a binary message buffer.
        #
        # @param openlcbMessage An OpenLCBMessage instance.
        # @return A binary message buffer.
        
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
}


vwait forever
