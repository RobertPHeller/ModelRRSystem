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
#  Last Modified : <160816.1119>
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


## @page OpenLCBGCTcpHub OpenLCB GridConnect Tcp/Ip Hub Server
# @brief OpenLCB GridConnect Tcp Hub daemon.
#
# @section OpenLCBGCTcpHubSYNOPSIS SYNOPSIS
#
# OpenLCBGCTcpHub [-host localhost] [-port 12021] [-debug] [connection options]
#
# @section OpenLCBGCTcpHubDESCRIPTION DESCRIPTION
#
# This program is a server daemon that implements a hub for OpenLCB over 
# Tcp/Ip that accepts connections from OpenLCB over GridConnect over Tcp/Ip 
# nodes and forwards OpenLCB messages between clients.  It can also connect
# to physical CAN busses using GridConnect messaging over (USB) Serial port
# connection.
#
# @section OpenLCBGCTcpHubPARAMETERS PARAMETERS
#
# none
#
# @section OpenLCBGCTcpHubOPTIONS OPTIONS
#
# @arg -host hostname The name or IP address of the host to bind to.  Defaults 
# to localhost (binds only to the local loopback device).  Using an address of
# 0.0.0.0 will bind to all interfaces.
# @arg -port portnumber The Tcp/Ip port to listen on.  Defaults to 12021.
# @arg -debug Turns on debug logging.
# @arg -dev ttydev, -dev0 ttydev, -dev1 ttydev, ... -dev9 ttydev Optional 
#      serial ports connected to CAN busses using GridConnect.
# @arg -remote host[:port], -remote0 host[:port], -remote1 host[:port], ... 
#      -remote9 host[:port] Optional remote Tcp/Ip hubs using GridConnect.
# @par
#
# @section OpenLCBGCTcpHubAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCBGCTcpHub]

#package require Sigterm
package require snit
package require gettext
package require log                                                             
package require LCC

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
snit::type OpenLCBGCTcpHub {
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
    typevariable defaultport 12021
    #** @brief Default Tcp/Ip port number.
    
    option -eoltranslation -readonly yes -default auto
    
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
        set logfilename [format {%s.log} [file tail $argv0]]
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
        foreach op {-dev -dev0 -dev1 -dev2 -dev3 -dev4 -dev5 -dev6 -dev7 -dev8 -dev9} {
            set dev [from argv $op]
            if {$dev eq ""} {continue}
            if {[catch {open $dev r+} ttyfd]} {
                ::log::logError [_ "Channel to %s not opened: %s" $dev $ttyfd]
                continue
            } else {
                if {[catch {fconfigure $ttyfd -mode}]} {
                    ::log::logError [_ "%s is not a terminal port." $dev]
                    continue
                }
                $type create %AUTO% $ttyfd localhost $dev -eoltranslation crlf
            }
        }
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

        ::log::log debug "*** $type SendTo [format {0x%03x} $destination] $message $args"
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
        
        ::log::log debug [format "*** %s UpdateRoute 0x%03x %s" $type $destination $routeobj]
        if {[catch {set _routeTable($destination)} routes]} {
            lappend _routeTable($destination) $routeobj
        } elseif {[lsearch -exact $routes $routeobj] < 0} {
            lappend _routeTable($destination) $routeobj
        }
        ::log::log debug "*** $type UpdateRoute: _routeTable contains:"
        foreach dest [array names _routeTable] {
            ::log::log debug [format "*** %s UpdateRoute:   0x%03x => %s" $type $dest  $_routeTable($dest)]
        }
        
    }
    variable channel {}
    #** Connection socket.
    variable remoteHost {}
    #** Remote host.
    variable remotePort {}
    #** Remote port.
    component gcmessage
    #** @privatesection @brief GridConnectMessage component.
    # This component is used to encode CAN Messages in Grid Connect Message
    # format for transmission.
    component gcreply
    #** @brief GridConnectReply component.
    # This component is used to decode received Grid Connect Messages into
    # binary CAN Messages.
    component mtidetail
    #**  MTI Detail component
    component mtiheader
    #** @brief MTIHeader component.
    # This component is used to extract and pack fields from and to a CAN
    # header at a MTI header level.
    component canheader
    #** @brief CANHeader component.
    # This component is used to extract and pack fields from and to a CAN
    # header at a CAN Header level.
    variable aliasMap -array {}
    #** @privatesection Alias to NID map
    variable nidMap -array {}
    #** NID to alias map
    variable _timeout 0
    #** Timeout flag.
    
    constructor {ch rhost rport args} {
        #** Connection constructor.  Construct a connection.
        #
        # @param ch The socket channel for this connection.
        # @param rhost The remote host.
        # @param rport The remote port.
        # @param ... Options:
        
        ::log::logMsg [_ "Acception connection from %s on port %s" $rhost $rport]
        set channel $ch
        set remoteHost $rhost
        set remotePort $rport
        install gcmessage using lcc::GridConnectMessage %AUTO%
        install gcreply   using lcc::GridConnectReply   %AUTO%
        install mtidetail using lcc::MTIDetail          %AUTO%
        install mtiheader using lcc::MTIHeader          %AUTO%
        install canheader using lcc::CANHeader          %AUTO%
        lappend _allNodes $self
        $self configurelist $args
        fconfigure $channel -buffering line -translation [$self cget -eoltranslation]
        fileevent $channel readable [mymethod _messageReader]
        #$self populateAliasMap
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
    method getAliasOfNID {nid} {
        #** Fetch the alias of a NID
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
        #** Get the NID of the alias.
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
        #** Get all known NIDs
        #
        # @return All known NIDS.
        
        return [array names aliasMap]
    }
    method getAllAliases {} {
        #** Get all known aliases
        #
        # @return All known aliases.
        
        return [array names nidMap]
    }
    method updateAliasMap {nid alias} {
        #** Update the alias map with the specificed Node ID and Alias.
        #
        # @param nid An OpenLCB Node ID.
        # @param alias A 12-bit CAN Alias.
        #
        
        foreach a [array names nidMap] {
            if {$nidMap($a) eq $nid} {
                unset nidMap($a)
            }
        }
        foreach n [array names aliasMap] {
            if {$aliasMap($n) == $alias} {
                unset aliasMap($n)
            }
        }
        set nidMap($alias) $nid
        set aliasMap($nid) $alias
    }
    #method populateAliasMap {} {
    #    #** Send an AME
    #    $canheader configure -openlcbframe no \
    #          -variablefield 0x0702 -srcid [$self getMyAlias]
    #    set _timeoutFlag 0
    #    after 5000 [mymethod _timedout]
    #    $self _sendmessage [CanMessage %AUTO% \
    #                        -header [$canheader getHeader] -extended yes]
    #    vwait [myvar _timeoutFlag]
    #}
    method _timedout {} {
        #** @privatesection Timeout method.  Called on timeout.
        
        #puts stderr "*** $self _timedout"
        incr _timeoutFlag
    }
    method sendMessage {message} {
        #** Send a message.
        # @param message The  message to send.
        
        puts $channel $message
        flush $channel
    }
    method _sendmessage {canmessage} {
        #** Send a low-level CAN bus message using the Grid Connect format.
        # 
        # @param canmessage The (binary) CANMessage to send.
        
        $gcmessage configure -canmessage $canmessage
        puts $channel [$gcmessage toString]
        flush $channel
    }
    proc getBits {top bottom bytelist} {
        #** @brief Get the selected bitfield.
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
    proc countNUL {list} {
        #** Count NUL bytes in a byte buffer.
        #
        # @param list The list of bytes to search.
        # @return The number of NUL (0) bytes in the list.
        
        set count 0
        set start 0
        while {[set i [lsearch -start $start $list 0]] >= 0} {
            incr count
            set start [expr {$i + 1}]
        }
        return $count
    }
    
    method _timedout {} {
        #** @privatesection Timeout method.  Called on timeout.
        
        #puts stderr "*** $self _timedout"
        incr _timeoutFlag
    }
        
    method _messageReader {} {
        #** Message reader handler.
        ::log::log debug "*** $self _messageReader entered."
        if {[gets $channel message] >= 0} {
            ::log::log debug "*** $self _messageReader: message = $message"
            $gcreply configure -message $message
            set r [$gcreply createReply]
            $canheader setHeader [$r getHeader]
            $type UpdateRoute [$canheader cget -srcid] $self
            ::log::log debug "*** $self _messageReader: canheader : [$canheader configure]"
            ::log::log debug "*** $self _messageReader: r = [$r toString]"
            if {[$canheader cget -openlcbframe]} {
                $mtiheader setHeader [$canheader getHeader]
                $mtidetail setHeader [$canheader getHeader]
                ::log::log debug  "*** $self _messageReader: mtiheader : [$mtiheader configure]"
                ::log::log debug "*** $self _messageReader: mtidetail : [$mtidetail configure]"
                set srcid [$canheader cget -srcid]
                set destid 0
                if {[$mtiheader cget -frametype] == 1} {
                    set mti [$mtiheader cget -mti]
                    if {[$mtidetail cget -addressp]} {
                        set destid [expr {(([lindex [$r getData] 0] & 0x0F) << 8) | [lindex [$r getData] 1]}]
                    }
                } elseif {[$mtidetail cget -streamordatagram]} {
                    set destid [$mtidetail cget -destid]
                }
                if {$destid eq 0} {
                    ::log::log debug "$self _messageReader: Broadcasting $message"
                    $type Broadcast $message -except $self
                } else {
                    ::log::log debug "$self _messageReader: Routing to $destid $message"
                    $type SendTo $destid $message -except $self
                }
            } else {
                # Not a OpenLCB message -- pass it throgh
                $type Broadcast $message -except $self
            }
        } else {
            # Error reading -- probably EOF / disconnect.
            $self destroy
        }
    }
    
}



vwait forever
