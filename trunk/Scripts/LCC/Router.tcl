#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun Mar 17 16:32:29 2019
#  Last Modified : <220810.1253>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2019  Robert Heller D/B/A Deepwoods Software
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

## @page Router OpenLCB Router Daemon (Server)
# @brief Routes between OpenLCB GridConnect/CAN and binary OpenLCB over Tcp/Ip 
#
# @section RouterSYNOPSIS SYNOPSIS
#
# Router [-bhost localhost] [-bport 12000]
#        [-cmode Tcpip|Socket|USB] [-chost localhost] [-cport 12021]
#        [-csocket can0] [-cdevice /dev/ttyACM0] [-nid 05:01:01:01:22:00]
#        [-log Router.log] [-debug]
#        [-nodename ""] [-nodedescription ""]
#
# @section RouterDESCRIPTION DESCRIPTION
#
# This program is a server daemon that implements a router between an 
# OpenLCB/CAN segment and a native OpenLCB over Tcp/Ip network.
#
# @section RouterPARAMETERS PARAMETERS
#
# none
#
# @section RouterOPTIONS OPTIONS
#
# @arg -bhost The binary OpenLCB over Tcp/Ip host to connect to.
# @arg -bport The tcp port to connect with.
# @arg -cmode The CAN If mode: Tcpip means GridConnect over Tcp/Ip, Socket 
# means use a CAN famile Socket (Linux only) (using the TclSocketCAN API),
# and USB means using a USB Serial port connection using GridConnect (such
# as a RR-CirKits USB Buffer-LCC).
# @arg -chost The GridConnect over Tcp/Ip host to connect to (only when -cmode 
# is Tcpip).
# @arg -cport The tcp port to connect with (only when -cmode is Tcpip).
# @arg -csocket The CAN socket name (only when -cmode is Socket).
# @arg -cdevice The tty device to connect to (only when -cmode is USB).
# @arg -nid The OpenLCB Node ID for the router.
# @arg -log The file to use for logging.
# @arg -debug Enable debugging messages.
# @arg -nodename The name of this router node.
# @arg -nodedescription The description of this router node.
# @par
#
# @section RouterAUTHOR AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] Router]

package require snit
package require gettext
package require Version
package require log
package require LCC

set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname [info script]]]] Messages]]

snit::type OpenLCBTcp {
    #** Static class to handle the native OpenLCB channel.
    #
    # Handles incoming native OpenLCB messages, converts them to generic 
    # OpenLCB message objects and then calls the parent class's methods:
    # 1) UpdateRoute to record the source channel for source NIDs
    # 2) Broadcast to send any global (unaddressed) messages along
    # 3) SendTo to send any addressed messages along.
    #
    
    # Set up for an ensemble command.
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no
    
    typecomponent mtidetail
    #** Object to hold the MTI and allow for accessing its bits.
    typecomponent parent
    #** Parent (Router) class object
    typevariable defaultPort 12000
    #** Default Tcp/Ip port number.
    typevariable defaultHost localhost
    #**  Default host.
    typevariable channel {}
    #** Open channel
    
    typemethod Open {argvname p} {
        #** Open the channel.
        #
        # The command line options are fetched and used to open a client 
        # connection to the specificed hub daemon.
        #
        # @param argvname The name of the variable containing the command line
        # words.
        # @param p The name of the parent class object.
        # @returns The name of this class object.
        
        # Derefence the name of the variable containing the command line words.
        upvar $argvname argv
        
        # Fetch command line options.
        set bhost [from argv -bhost $defaultHost]
        set bport [from argv -bport $defaultPort]
        # Open the socket
        if {[catch {socket $bhost $bport} channel]} {
            # Failure: report error and die.
            set theerror $channel
            catch {unset  channel}
            ::log::logError [_ "Failed to open %s:%d because %s." $bhost $bport $theerror]
            exit 99
        }
        # Stash the parent object
        set parent $p
        # Log it.
        ::log::logMsg [_ "%s Binary listening on %s:%s" $type $bhost $bport]
        # Configure the channel
        fconfigure $channel -buffering none -translation {binary binary}
        # Instansiate a mtidetail object to later use
        set mtidetail [lcc::MTIDetail %AUTO%]
        # Start listening...
        fileevent $channel readable [mytypemethod _messageReader]
        # Return our type (class) object.
        return $type
    }    
    typemethod SendMessage {message} {
        #** Send a message.
        # @param message The  message to send.
        
        lcc::OpenLCBMessage validate $message
        ::log::log debug "$type SendMessage [$message toString]"
        set preamble 0x8000;# Common OpenLCB bit.
        set messageData [$type _makeBinaryMessage $message]
        set totallength [expr {[llength $messageData] + (48/8) + (48/8)}]
        set tlbytes [list \
                     [expr {($totallength & 0xFF0000) >> 16}] \
                     [expr {($totallength & 0xFF00) >> 8}] \
                     [expr {$totallength & 0xFF}]]
        set sourcenid [list]
        #::log::log debug "$type SendMessage: \[\$message cget -sourcenid\] is [$message cget -sourcenid]"
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
        #::log::log debug "$type SendMessage: preamble = $preamble, tlbytes = $tlbytes, sourcenid = $sourcenid, sqbytes = $sqbytes, messageData = \{$messageData\}"
        set messageBlock [binary format {Sc3c6c6c*} $preamble $tlbytes $sourcenid $sqbytes $messageData]
        if {[catch {puts -nonewline $channel $messageBlock
             flush $channel} error]} {
                ::log::logError [_ "%s: write error to hub: %s" $type $error]
                exit 99
        }
    }
    typemethod _messageReader {} {
        #** Message reader handler.
        
        ::log::log debug "$type _messageReader entered"
        
        set buffer [read $channel 2];# Preamble
        if {[eof $channel] || [string length $buffer] < 2} {
            exit 1
            return
        }
        if {[binary scan $buffer S preamble] < 1} {
            exit 1
            return
        }
        set preamble [expr {$preamble & 0x0FFFF}]
        if {($preamble & 0x8000) == 0} {
            # Link control message -- these are currently ignored.
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
            # Convert to a generic message object.
            set openlcbMessage [$type _unpackBinaryMessage $openlcbmessage]
            set dest [$openlcbMessage cget -destnid]
            set source [$openlcbMessage cget -sourcenid]
            $parent UpdateRoute $source B
            if {$dest eq ""} {
                ::log::log debug "$type _messageReader: Broadcasting [$openlcbMessage toString]"
                $parent Broadcast $openlcbMessage B
            } else {
                ::log::log debug "$type _messageReader: Routing to $dest [$openlcbMessage toString]"
                $parent SendTo $dest $openlcbMessage B
            }
            set eventid [$openlcbMessage cget -eventid]
            catch {$eventid destroy}
            $openlcbMessage destroy
        }
        ::log::log debug "*** $type _messageReader: MTIDetails: [lcc::MTIDetail ObjectCount]"
        ::log::log debug "*** $type _messageReader: CanMessages: [lcc::CanMessage ObjectCount]"
        ::log::log debug "*** $type _messageReader: GridConnectMessages: [lcc::GridConnectMessage ObjectCount]"
        ::log::log debug "*** $type _messageReader: GridConnectReplys: [lcc::GridConnectReply ObjectCount]"
        ::log::log debug "*** $type _messageReader: CanAliass: [lcc::CanAlias ObjectCount]"
        ::log::log debug "*** $type _messageReader: CanTransports: [lcc::CanTransport ObjectCount]"
        ::log::log debug "*** $type _messageReader: OpenLCBMessages: [lcc::OpenLCBMessage ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnects: [lcc::CANGridConnect ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnectOverUSBSerials: [lcc::CANGridConnectOverUSBSerial ObjectCount]"
        ::log::log debug "*** $type _messageReader: OpenLCBOverTcps: [lcc::OpenLCBOverTcp ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnectOverTcps: [lcc::CANGridConnectOverTcp ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnectOverCANSockets: [lcc::CANGridConnectOverCANSocket ObjectCount]"
        ::log::log debug "*** $type _messageReader: OpenLCBNodes: [lcc::OpenLCBNode ObjectCount]"
        ::log::log debug "*** $type _messageReader: EventIDs: [lcc::EventID ObjectCount]"
        ::log::log debug "*** $type _messageReader: MTIHeaders: [lcc::MTIHeader ObjectCount]"
    }
    typemethod _unpackBinaryMessage {messagebuffer} {
        #** Unpack a binary message.
        #
        # @param messagebuffer A byte array containing the message bytes.
        # @return An OpenLCBMessage instance.
        
        set MTI [expr {([lindex $messagebuffer 0] << 8) | [lindex $messagebuffer 1]}]
        $mtidetail setMTI16Header $MTI
        set sourcenid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] [lrange $messagebuffer 2 7]]
        set result [lcc::OpenLCBMessage %AUTO%  -sourcenid $sourcenid \
                    -mti $MTI]
        # Extract special data elements: destination and eventId, since they 
        # are stored in the OpenLCBMessage separately.
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
        # Other random data.
        $result configure -data [lrange $messagebuffer $dataoff end]
        return $result
    }
    typemethod _makeBinaryMessage {openlcbMessage} {
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

snit::type OpenLCBGCCAN {
    #** Static class to handle the GridConnect (CAN) OpenLCB channel.
    #
    # Handles incoming GridConnect (CAN) messages, converts them to generic
    # OpenLCB message objects and then calls the parent class's methods:
    # 1) UpdateRoute to record the source channel for source NIDs 
    # 2) Broadcast to send any global (unaddressed) messages along
    # 3) SendTo to send any addressed messages along. 
    #
    
    # Set up for an ensemble command.
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no
    
    typecomponent gcmessage
    #** Parsed GridConnect message
    typecomponent gcreply
    #** Parsed GridConnect Reply message
    typecomponent mtidetail
    #** MTI detail object
    typecomponent mtiheader
    #** MTI Header object
    typecomponent canheader
    #** CAN Header object
    typecomponent mycanalias
    ## My CanAlias component.
    typecomponent parent
    #** Parent (Router) class object
    typevariable nidMap -array {}
    #** The NID => Alias map for the CAN segment.  The array is indexed by
    # NIDs and the values are the current aliases.
    typevariable aliasMap -array {}
    #** The Alias => NID map for the CAN segment.  The array is indexed by
    # aliases and the values are the NIDs the aliases represent.
    typevariable pendingAliasFlags -array {}
    #** Pending Alias flags
    typevariable pendingMessageQueues -array {}
    #** Pending Message Queues
    typevariable defaultTcpPort 12021
    #** @brief Default GridConnect over Tcp/Ip port number. 
    typevariable defaultTcpHost localhost
    #** @brief Default GridConnect over Tcp/Ip host.
    typevariable defaultSocketName can0
    #** @brief Default CAN Socket.
    typevariable defaultSerialPort /dev/ttyACM0
    #** @brief Default Serial port.
    typevariable defaultCANMode USB
    #** Default CAN/GC mode
    typevariable channel {}
    #** Channel
    typevariable _timeoutFlag 0
    #** Timeout flag.
    typevariable _timeoutID {}
    typevariable messageBuffer ""
    #** Message buffer
    typevariable readState "waitforstart"
    #** Read State
    typevariable datagrambuffers -array {}
    ## Datagram buffers.
    typevariable messagebuffers -array {}
    ## General message buffers (for multi frame messages) 
    variable simplenodeflags -array {}
    ## Simple node info flags
    
    delegate typemethod getMyAlias to mycanalias
    
    typemethod _reserveMyAlias {} {
        ## Reserve my alias.
        #
        # @return A boolean value indicating a successfully reserved alias
        # (true) or failure (false).
        
        return [$type reserveAlias $mycanalias]
    }
    
    
    typemethod Open {argvname p} {
        #** Open the channel.
        #
        # The command line options are fetched and used to open a client 
        # connection to the specificed hub daemon.
        #
        # @param argvname The name of the variable containing the command line
        # words.
        # @param p The name of the parent class object.
        # @returns The name of this class object.
        
        # Derefence the name of the variable containing the command line words.
        upvar $argvname argv
        
        set cmode [from argv -cmode $defaultCANMode]
        ::log::log debug "*** $type Open: cmode = $cmode"
        switch [string toupper [string index $cmode 0]] {
            U {
                set cdevice [from argv -cdevice $defaultSerialPort]
                if {$::tcl_platform(platform) eq "windows"} {
                    ## Force Use of the "global NT object space" for serial port
                    ## devices under MS-Windows.
                    set cdevice [format "\\\\.\\%s" $cdevice]
                }
                if {[catch {open $cdevice r+} channel]} {
                    set theerror $channel
                    catch {unset channel}
                    ::log::logError [_ "Failed to open port %s because %s." $cdevice $theerror]
                    exit 99
                }
                if {[catch {fconfigure $channel -mode}]} {
                    close $channel
                    catch {unset channel}
                    ::log::logError [_ "%s is not a terminal port." $cdevice]
                    exit 99
                }
                ::log::logMsg [_ "%s CAN listening on %s" $type $cdevice]
            }
            S {
                set csocket [from argv -csocket $defaultSocketName]
                if {[catch {SocketCAN $csocket} channel]} {
                    set theerror $channel
                    catch {unset channel}
                    ::log::logError [_ "Failed to open port %s because %s." $csocket $theerror]
                    exit 99
                }
                ::log::logMsg [_ "%s CAN listening on %s" $type $csocket]
            }
            T {
                set cport [from argv -cport $defaultTcpPort]
                set chost [from argv -chost $defaultTcpHost]
                if {[catch {socket $chost $cport} channel]} {
                    set theerror $channel
                    catch {unset channel}
                    ::log::logError [_ "Failed to open port %s:%s because %s." $chost $cport $theerror]
                    exit 99
                }
                ::log::logMsg [_ "%s CAN listening on %s:%s" $type $chost $cport]
            }
            default {
                ::log::logError [_ "Unknown CAN Mode: %s." $cmode]
                exit 99
            }
        }
        set parent $p
        fconfigure $channel -buffering none -translation {binary binary}
        set gcmessage [lcc::GridConnectMessage %AUTO%]
        set gcreply   [lcc::GridConnectReply   %AUTO%]
        set mtidetail [lcc::MTIDetail          %AUTO%]
        set mtiheader [lcc::MTIHeader          %AUTO%]
        set canheader [lcc::CANHeader          %AUTO%]
        set mycanalias [lcc::CanAlias %AUTO% -nid [$parent MyNID]]
        fileevent $channel    readable [mytypemethod _readByte]
        while {![$type _reserveMyAlias]} {
        }
        $type populateAliasMap
        return $type
    }
    typemethod getAliasOfNID {nid} {
        #** Fetch the alias of a NID
        #
        # @param nid A full NID of the form hh:hh:hh:hh:hh:hh
        # @return The node's alias or the empty string if not known.
        lcc::nid validate $nid
        if {[info exists aliasMap([string toupper $nid])]} {
            return $aliasMap([string toupper $nid])
        } else {
            return {}
        }
    }
    typemethod getNIDofAlias {alias} {
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
    typemethod getAllNIDs {} {
        #** Get all known NIDs
        #
        # @return All known NIDS.
        
        return [array names aliasMap]
    }
    typemethod getAllAliases {} {
        #** Get all known aliases
        #
        # @return All known aliases.
        
        return [array names nidMap]
    }
    typemethod updateAliasMap {nid alias} {
        #** Update the alias map with the specificed Node ID and Alias.
        #
        # @param nid An OpenLCB Node ID.
        # @param alias A 12-bit CAN Alias.
        #
        
        set nid [string toupper $nid]
        #::log::log debug "$type updateAliasMap $nid $alias"
        foreach a [array names nidMap] {
            if {$nidMap($a) eq $nid} {
                #::log::log debug "$type updateAliasMap: unsetting nidMap($a) (= $nidMap($a))"
                unset nidMap($a)
            }
        }
        foreach n [array names aliasMap] {
            if {$aliasMap($n) == $alias} {
                #::log::log debug "$type updateAliasMap: unsetting aliasMap($n) (= $aliasMap($n))"
                unset aliasMap($n)
            }
        }
        set nidMap($alias) $nid
        set aliasMap([string toupper $nid]) $alias
    }
    typemethod populateAliasMap {} {
        #** Send an AME
        $canheader configure -openlcbframe no \
              -variablefield 0x0702 -srcid [$type getMyAlias]
        set _timeoutFlag 0
        after 5000 [mytypemethod _timedout]
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes]
        $type _sendmessage $message
        $message destroy
        vwait [mytypevar _timeoutFlag]
    }
    typemethod _queueMessagePendingAlias {sourcenid message} {
        set sourcenid [string toupper $sourcenid]
        lappend pendingMessageQueues($sourcenid) $message
    }
    typemethod _flushMessagePendingAlias {sourcenid} {
        set sourcenid [string toupper $sourcenid]
        set messages $pendingMessageQueues($sourcenid)
        set pendingMessageQueues($sourcenid) {}
        foreach message $messages {
            $type SendMessage $message
            $message destroy
        }
    }
    typemethod CheckSourceAlias {sourcenid} {
        set sourcenid [string toupper $sourcenid]
        ::log::log debug "$type CheckSourceAlias $sourcenid"
        ::log::log debug "$type CheckSourceAlias: \[info exists pendingAliasFlags($sourcenid)\] is [info exists pendingAliasFlags($sourcenid)]"
        if {[info exists pendingAliasFlags($sourcenid)]} {
            if {$pendingAliasFlags($sourcenid) > 0} {
                return Pending
            }
        }
        set sourcealias [$type getAliasOfNID $sourcenid]
        ::log::log debug "$type CheckSourceAlias: sourcealias is $sourcealias"
        if {$sourcealias eq {}} {
            set pendingMessageQueues($sourcenid) [list]
            incr  pendingAliasFlags($sourcenid)
            ::log::log debug "$type CheckSourceAlias: (start) pendingAliasFlags($sourcenid) is $pendingAliasFlags($sourcenid)"
            set tempcanalias [lcc::CanAlias %AUTO% -nid $sourcenid]
            while {![$type reserveAlias $tempcanalias]} {
                ::log::log debug "$type CheckSourceAlias: (in while loop) tempcanalias is [format 0x%03x [$tempcanalias getMyAlias]]"

            }
            ::log::log debug "$type CheckSourceAlias: (out of while loop) tempcanalias is [format 0x%03x [$tempcanalias getMyAlias]]"
            #set sourcealias [$tempcanalias getMyAlias]
            #$type updateAliasMap $sourcenid $sourcealias
            incr pendingAliasFlags($sourcenid) -1
            ::log::log debug "$type CheckSourceAlias: (end) pendingAliasFlags($sourcenid) is $pendingAliasFlags($sourcenid)"
            $type _flushMessagePendingAlias $sourcenid
            $tempcanalias destroy
        }
    }            
    typemethod reserveAlias {canalias} {
        ## @publicsection @brief Reserve an alias.
        # Sends out CID messages and eventually RID and AMD messages, if
        # there are no errors.
        # 
        # @param canalias A CanAlias object.
        # @return A boolean value indicating a successfully reserved alias
        # (true) or failure (false).
        
        ::log::log debug "$type reserveAlias: nid is [$canalias cget -nid]"
        lcc::CanAlias validate $canalias
        set nidlist [$canalias getMyNIDList]
        # Generate a tentative alias.
        set alias [$canalias getNextAlias]
        ::log::log debug [format "*** $type reserveAlias: alias = 0x%03X" $alias]
        
        # Send out Check ID frames.
        # CID1
        $canheader configure -openlcbframe no \
              -variablefield [expr {(0x7 << 12) | [getBits 47 36 $nidlist]}] \
              -srcid $alias
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes]
        $type _sendmessage $message
        $message destroy
        # CID2
        $canheader configure -openlcbframe no \
              -variablefield [expr {(0x6 << 12) | [getBits 35 24 $nidlist]}] \
              -srcid $alias
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes]
        $type _sendmessage $message
        $message destroy
        # CID3
        $canheader configure -openlcbframe no \
              -variablefield [expr {(0x5 << 12) | [getBits 23 12 $nidlist]}] \
              -srcid $alias
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes]
        $type _sendmessage $message
        $message destroy
        # CID4
        $canheader configure -openlcbframe no \
              -variablefield [expr {(0x4 << 12) | [getBits 11 0 $nidlist]}] \
              -srcid $alias
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes]
        $type _sendmessage $message
        $message destroy
        set _timeoutFlag 0
        set _timeoutID [after 500 [mytypemethod _timedout]]
        vwait [mytypevar _timeoutFlag]
        ::log::log debug [format "*** $type reserveAlias: _timeoutFlag is $_timeoutFlag"]
        if {$_timeoutFlag < 0} {
            # Received an error report.  Cancel the timeout and return
            # false.
            catch [after cancel $_timeoutID]
            set _timeoutID {}
            return false
        }
        set _timeoutID {}
        # No errors after 500ms timeout.  We can reserve our alias.
        # RID
        $canheader configure -openlcbframe no \
              -variablefield 0x0700 -srcid $alias
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes]
        $type _sendmessage $message
        $message destroy
        # AMD
        $canheader configure -openlcbframe no \
              -variablefield 0x0701 -srcid $alias
        set message [lcc::CanMessage %AUTO% \
                            -header [$canheader getHeader] -extended yes \
                            -data $nidlist -length 6]
        $type _sendmessage $message
        $message destroy
        
        $type updateAliasMap [$canalias cget -nid] $alias
        return true
    }
    typemethod _timedout {} {
        #** @privatesection Timeout method.  Called on timeout.
        
        ::log::log debug "*** $type _timedout"
        ::log::log debug "*** $type _timedout: (before) _timeoutFlag = $_timeoutFlag"
        incr _timeoutFlag
        ::log::log debug "*** $type _timedout: (after)  _timeoutFlag = $_timeoutFlag"
    }
    
    typemethod SendMessage {message} {
        ## Send a message on the OpenLCB bus.
        # @param message An OpenLCBMessage.
        
        lcc::OpenLCBMessage validate $message
        ::log::log debug "*** $type SendMessage: message is [$message toString]"
        set sourcenid [$message cget -sourcenid]
        if {[$type CheckSourceAlias $sourcenid] eq "Pending"} {
            $type _queueMessagePendingAlias $sourcenid \
                  [lcc::OpenLCBMessage copy $message]
            return
        }
        set sourcealias [$type getAliasOfNID $sourcenid]
        if {$sourcealias eq {}} {
            ::log::logError [_ "Error: source alias of %s not set!  This should not be happening!" $sourcenid]
            exit 1
        }
        if {[$message cget -destnid] eq [$mycanalias cget -nid]} {
            #??? Message for me?
            ::log::log info "Message address to the router, dropped."
            return
        }
        ::log::log debug "*** $type SendMessage: past test for router addressed messages, about to check for missing dest alias."
        if {([$message cget -mti] & 0x0008) != 0} {
            set destnid [$message cget -destnid]
            set destalias [$type getAliasOfNID $destnid]
            ::log::log debug "*** $type SendMessage: destnid is $destnid, destalias is $destalias"
            if {$destalias eq {}} {
                ::log::logError [_ "Message cannot be routed to %s -- alias not available!" $destnid]
                return
            }
        }
        ::log::log debug "*** $type SendMessage: past test for missing destalias.  About to get datalen."
        set datalen [llength [$message cget -data]]
        ::log::log debug "*** $type SendMessage: datalen is $datalen."
        if {([$message cget -mti] & 0x0008) != 0} {
            ## Address present
            incr datalen 2
        }
        
        if {([$message cget -mti] & 0x0004) != 0} {
            ## Event present
            incr datalen 8
        }
        set mtiheader [lcc::MTIHeader %AUTO% -srcid $sourcealias -mti [expr {[$message cget -mti] & 0x0FFF}] -frametype 1]
        if {([$message cget -mti] & 0x1000) != 0} {
            ## Datagram
            $type _sendDatagram $message
        } else {
            if {$datalen <= 8} {
                ## Frame will be complete in one frame
                set canmessage [lcc::CanMessage %AUTO% \
                                -header [$mtiheader getHeader] \
                                -extended yes \
                                -length $datalen]
                set dindex 0
                if {([$message cget -mti] & 0x0008) != 0} {
                    ::log::log debug "$type SendMessage: destalias is $destalias ($destnid)"
                    #set destalias [$type getAliasOfNID [$message cget -destnid]]
                    $canmessage setElement $dindex [expr {($destalias & 0x0F00) >> 8}]
                    incr dindex
                    $canmessage setElement $dindex [expr {$destalias & 0x0FF}]
                    incr dindex
                }
                if {([$message cget -mti] & 0x0004) != 0} {
                    set evlist [[$message cget -eventid] cget -eventidlist]
                    foreach ebyte $evlist {
                        $canmessage setElement $dindex $ebyte
                        incr dindex
                    }
                }
                foreach dbyte [$message cget -data] {
                    $canmessage setElement $dindex $dbyte
                    incr dindex
                }
                ::log::log debug "*** $type sendMessage: canmessage = [$canmessage toString]"
                $type _sendmessage $canmessage
                $canmessage destroy
            } else {
                ## send as multiple frames.
                set databuffer [$message cget -data]
                if {([$message cget -mti] & 0x0008) != 0} {
                    set destalias [$type getAliasOfNID [$message cget -destnid]]
                } else {
                    set destalias 0;# unaddress multi-frame message?
                }
                set flags 0x01;# first frame
                set bindex 0
                set remain [llength $databuffer]
                while {$remain > 6} {
                    set canmessage [lcc::CanMessage %AUTO% \
                                    -header [$mtiheader getHeader] \
                                    -extended yes -length 8]
                    $canmessage setElement 0 [expr {($flags << 4) | (($destalias & 0x0F00) >> 8)}]
                    $canmessage setElement 1 [expr {$destalias & 0x0FF}]
                    set dindex 2
                    while {$dindex <= 7} {
                        $canmessage setElement $dindex [lindex $databuffer $bindex]
                        incr dindex
                        incr bindex
                        incr remain -1
                    }
                    $type _sendmessage $canmessage
                    $canmessage destroy
                    set flags 0x03;# middle frames
                }
                set canmessage [lcc::CanMessage %AUTO% \
                                -header [$mtiheader getHeader] \
                                -extended yes -length [expr {$remain + 2}]]
                set flags 0x02;# last frame
                $canmessage setElement 0 [expr {($flags << 4) | (($destalias & 0x0F00) >> 8)}]
                $canmessage setElement 1 [expr {$destalias & 0x0FF}]
                set dindex 2
                while {$remain > 0} {
                    $canmessage setElement $dindex [lindex $databuffer $bindex]
                    incr dindex
                    incr bindex
                    incr remain -1
                }
                $type _sendmessage $canmessage
                $canmessage destroy
            }
        }
        $mtiheader destroy
    }
    typemethod _sendDatagram {message} {
        ## @privatesection Send a datagram message.
        # A possibly multi-part datagram message is sent.
        #
        # @param message The OpenLCB message to send.
        
        set destalias [$type getAliasOfNID [$message cget -destnid]]
        set databuffer [$message cget -data]
        set sourcenid [$message cget -sourcenid]
        set sourcealias [$type getAliasOfNID $sourcenid]
        $mtidetail configure -streamordatagram yes -destid $destalias \
              -srcid $sourcealias
        set remain [llength $databuffer]
        set dindex 0
        if {$remain <= 8} {
            $mtidetail configure -datagramcontent complete
            set message [lcc::CanMessage %AUTO% -header [$mtidetail getHeader] \
                         -extended true \
                         -data [lrange $databuffer $dindex end] \
                         -length $remain]
            $type _sendmessage $message
            $message destroy
        } else {
            $mtidetail configure -datagramcontent first
            while {$remain > 8} {
                set eblock [expr {$dindex + 7}]
                incr remain -8
                set message [lcc::CanMessage %AUTO% -header [$mtidetail getHeader] \
                             -extended true \
                             -data [lrange $databuffer $dindex $eblock] \
                             -length 8]
                $type _sendmessage $message
                $message destroy
                incr dindex 8
                $mtidetail configure -datagramcontent middle
            }
            $mtidetail configure -datagramcontent last
            set message [lcc::CanMessage %AUTO% -header [$mtidetail getHeader] \
                         -extended true \
                         -data [lrange $databuffer $dindex end] \
                         -length $remain]
            $type _sendmessage $message
            $message destroy
        }
    }
    typemethod _sendmessage {canmessage} {
        #** Send a low-level CAN bus message using the Grid Connect format.
        # 
        # @param canmessage The (binary) CANMessage to send.
        
        $gcmessage configure -canmessage $canmessage
        ::log::log debug "$type _sendmessage: gcmessage is [$gcmessage toString]"
        if {[catch {puts -nonewline $channel [$gcmessage toString];flush $channel} err]} {
            ::log::logError [_ "Caught error on %s: %s" $channel $err]
            exit 1
        }
        ::log::log debug "$type _sendmessage: message sent."
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
    
    typemethod _readByte {} {
        #::log::log debug "*** $type _readByte entered."
        set ch [read $channel 1]
        if {$ch eq ""} {
            # Error reading -- probably EOF / disconnect.
            exit 1
        }
        if {![info exists readState]} {return}
        switch $readState {
            waitforstart {
                if {$ch ne ":"} {return}
                set messageBuffer $ch
                set readState readmessage
            }
            readmessage {
                append messageBuffer $ch
                if {$ch eq ";"} {
                    $type _messageReader $messageBuffer
                    set readState waitforstart
                    set buffer ""
                }
            }
        }
    }
    typemethod _flags0 {srcid r doff} {
        ## Method to deal with possible multipart messages, with partitular
        # handling of multi-part Simple Node Info messages.
        #
        # @param srcid The source alias of the message.
        
        #::log::log debug "*** $type _flags0 $srcid [$r toString] $doff"
        set mti [$mtiheader cget -mti]
        #::log::log debug [format {*** %s _flags0: mti = 0x%04X} $type $mti]
        if {[$mtiheader cget -mti] == 0x0A08} {
            if {[info exists simplenodeflags($srcid,v1)]} {
                eval [list lappend messagebuffers($srcid,$mti)] [lrange [$r getData] $doff end]
                if {[countNUL $messagebuffers($srcid,$mti)] < $simplenodeflags($srcid,v1)} {
                    return no
                }
            } else {
                set messagebuffers($srcid,$mti) [lrange [$r getData] $doff end]
                set simplenodeflags($srcid,v1) [lindex $messagebuffers($srcid,$mti) 0]
                if {$simplenodeflags($srcid,v1) == 1} {
                    set simplenodeflags($srcid,v1) 4
                }  
            }
            #::log::log debug "*** $type _flags0: messagebuffers($srcid,$mti) contains $messagebuffers($srcid,$mti)"
            set i 1
            for {set j 0} \
                  {$j < $simplenodeflags($srcid,v1)} \
                  {incr j} {
                set k [lsearch -start $i -exact $messagebuffers($srcid,$mti) 0]
                #::log::log debug "*** $type _flags0: i = $i, j = $j, k = $k"
                if {$k < 0} {return no}
                set i [expr {$k + 1}]
            }
            #::log::log debug "*** $type _flags0: length of messagebuffers($srcid,$mti) is [llength $messagebuffers($srcid,$mti)]"
            #::log::log debug "*** $type _flags0: i = $i"
            if {$i >= [llength $messagebuffers($srcid,$mti)]} {
                return no
            }
            set simplenodeflags($srcid,v2) [lindex $messagebuffers($srcid,$mti) $i]
            if {$simplenodeflags($srcid,v2) == 1} {
                set simplenodeflags($srcid,v2) 2
            }
            if {[countNUL $messagebuffers($srcid,$mti)] < ($simplenodeflags($srcid,v1) + $simplenodeflags($srcid,v2))} {
                return no
            }
            unset simplenodeflags($srcid,v1)
            unset simplenodeflags($srcid,v2)
            return yes
        } else {
            set messagebuffers($srcid,$mti) [lrange [$r getData] $doff end]
            return yes
        }
    }
    typemethod _messageReader {message} {
        ## Handling incoming messages.  Handle control (CAN) messages
        # here.  OpenLCB messages are assembled possibly from multiple CAN
        # messages and then dispatched to the upper level message handler.
        
        ::log::log debug "*** $type _messageReader: message = $message"
        $gcreply configure -message $message
        set r [$gcreply createReply]
        $canheader setHeader [$r getHeader]
        #::log::log debug "*** $type _messageReader: canheader : [$canheader configure]"
        #::log::log debug "*** $type _messageReader: r = [$r toString]"
        if {[$canheader cget -openlcbframe]} {
            $mtiheader setHeader [$canheader getHeader]
            $mtidetail setHeader [$canheader getHeader]
            ::log::log debug "*** $type _messageReader: mtiheader : [$mtiheader configure]"
            ::log::log debug "*** $type _messageReader: mtidetail : [$mtidetail configure]"
            set srcid [$canheader cget -srcid]
            if {[$type getNIDofAlias $srcid] ne ""} {
                $parent UpdateRoute [$type getNIDofAlias $srcid] C
            }
            set flagbits 0
            set destid 0
            set doff 0
            if {[$mtiheader cget -frametype] == 1} {
                set mti [$mtiheader cget -mti]
                if {[$mtidetail cget -addressp]} {
                    set doff 2
                    set destid [expr {(([lindex [$r getData] 0] & 0x0F) << 8) | [lindex [$r getData] 1]}]
                    set flagbits [expr {([lindex [$r getData] 0] & 0xF0) >> 4}]
                }
                set datacomplete no
                if {$flagbits == 0x00} {
                    ::log::log debug "*** $type _messageReader: doff = $doff"
                    set datacomplete [$type _flags0 $srcid $r $doff]
                    ::log::log debug "*** $type _messageReader: $r getData is [$r getData]"
                    ::log::log debug "*** $type _messageReader: messagebuffers($srcid,$mti) contains $messagebuffers($srcid,$mti)"
                } elseif {$flagbits == 0x01} {
                    set messagebuffers($srcid,$mti) [lrange [$r getData] 2 end]
                } elseif {$flagbits == 0x03} {
                    eval [list lappend messagebuffers($srcid,$mti)] [lrange [$r getData] 2 end]
                } elseif {$flagbits == 0x02} {
                    eval [list lappend messagebuffers($srcid,$mti)] [lrange [$r getData] 2 end]
                    set datacomplete yes
                }
                if {$datacomplete} {
                    ::log::log debug "*** $type _messageReader: datacomplete: srcid is $srcid, $type getNIDofAlias $srcid is [$type getNIDofAlias $srcid]"
                    if {[$type getNIDofAlias $srcid] eq "" && 
                        ([$mtiheader cget -mti] == 0x0100 ||
                         [$mtiheader cget -mti] == 0x0101 || 
                         [$mtiheader cget -mti] == 0x0170 ||
                         [$mtiheader cget -mti] == 0x0171)} {
                        # InitComplete and VerifyNodeID messages.  Capture the NID.
                        set srcnid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] [lrange [$r getData] 0 5]]
                        ::log::log debug "*** $type _messageReader: InitComplete and VerifyNodeID messages."
                        ::log::log debug "*** $type _messageReader: srcnid is $srcnid"
                        $type updateAliasMap $srcnid $srcid
                        $parent UpdateRoute $srcnid C
                    }
                    set m [lcc::OpenLCBMessage %AUTO% \
                           -mti [$mtiheader cget -mti] \
                           -sourcenid [$type getNIDofAlias $srcid] \
                           -data      $messagebuffers($srcid,$mti)]
                    
                    if {$destid != 0} {
                        $m configure \
                              -destnid [$type getNIDofAlias $destid]
                    }
                    set doff 0
                    if {[$mtidetail cget -eventp]} {
                        set evstart $doff
                        set evend   [expr {$doff + 7}]
                        incr doff 8
                        set edata [lrange $messagebuffers($srcid,$mti) $evstart $evend]
                        set eid [lcc::EventID %AUTO% -eventidlist $edata]
                        $m configure -eventid $eid
                        $m configure -data [lrange $messagebuffers($srcid,$mti) $doff end]
                    }
                    catch {unset messagebuffers($srcid,$mti)}
                    if {[$m cget -sourcenid] ne {}} {
                        if {[$m cget -destnid] ne {}} {
                            $parent SendTo [$m cget -destnid] $m C
                        } else {
                            $parent Broadcast $m C
                        }
                    } else {
                        ::log::log warning "Orphan message: [$m toString]"
                    }
                    if {[$mtidetail cget -eventp]} {
                        $eid destroy
                    }
                    $m destroy
                }
            } elseif {[$mtidetail cget -streamordatagram]} {
                set destid [$mtidetail cget -destid]
                set datacomplete no
                switch [$mtidetail cget -datagramcontent] {
                    complete {
                        set datagrambuffers($srcid) [$r getData]
                        set datacomplete yes
                    }
                    first {
                        set datagrambuffers($srcid) [$r getData]
                    }
                    middle {
                        eval [list lappend datagrambuffers($srcid)] [$r getData]
                    }
                    last {
                        eval [list lappend datagrambuffers($srcid)] [$r getData]
                        set datacomplete yes
                    }
                }
                if {$datacomplete} {
                    set m [lcc::OpenLCBMessage %AUTO% -mti 0x1C48 \
                           -sourcenid [$type getNIDofAlias $srcid] \
                           -destnid   [$type getNIDofAlias $destid] \
                           -data      $datagrambuffers($srcid)]
                    unset datagrambuffers($srcid)
                    if {[$m cget -sourcenid] ne {}} {
                        $parent SendTo [$m cget -destnid] $m C
                    } else {
                        ::log::log warning "Orphan message: [$m toString]"
                    }
                    $m destroy
                }
            }
        } else {
            # Not a OpenLCB message.
            # Check for an Error Information Report
            set vf [$canheader cget -variablefield]
            #::log::log debug "[format {*** %s _messageReader: vf = 0x%04X} $type $vf]"
            if {$vf == 0x0701} {
                # AMD frame
                #::log::log debug "*** $type _messageReader: received AMD frame"
                set srcalias [$canheader cget -srcid]
                set srcnid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] [lrange [$r getData] 0 5]]
                #::log::log debug "[format {*** %s _messageReader: srcalias = 0x%03X, srcnid = %s} $type $srcalias $srcnid]"
                $type updateAliasMap $srcnid $srcalias
            } elseif {$vf == 0x0702} {
                set nidlist [$mycanalias getMyNIDList]
                # AME frame
                if {[listeq [lrange [$r getData] 0 5] {0 0 0 0 0 0}] || [listeq [lrange [$r getData] 0 5] $nidlist]} {
                    $canheader configure -openlcbframe no \
                          -variablefield 0x0701 -srcid [$type getMyAlias]
                    set message [lcc::CanMessage %AUTO% \
                                        -header [$canheader getHeader] \
                                        -extended yes \
                                        -data $nidlist -length 6]
                    $type _sendmessage $message
                    $message destroy
                }
            } elseif {$vf >= 0x0710 || $vf <= 0x0713} {
                # Was an Error Information Report -- flag it.
                incr _timeoutFlag -2
            } else {
                
                #### Node ID Alias Collision handling... NYI
            }
        }
        $r destroy
        ::log::log debug "*** $type _messageReader: MTIDetails: [lcc::MTIDetail ObjectCount]"
        ::log::log debug "*** $type _messageReader: CanMessages: [lcc::CanMessage ObjectCount]"
        ::log::log debug "*** $type _messageReader: GridConnectMessages: [lcc::GridConnectMessage ObjectCount]"
        ::log::log debug "*** $type _messageReader: GridConnectReplys: [lcc::GridConnectReply ObjectCount]"
        ::log::log debug "*** $type _messageReader: CanAliass: [lcc::CanAlias ObjectCount]"
        ::log::log debug "*** $type _messageReader: CanTransports: [lcc::CanTransport ObjectCount]"
        ::log::log debug "*** $type _messageReader: OpenLCBMessages: [lcc::OpenLCBMessage ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnects: [lcc::CANGridConnect ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnectOverUSBSerials: [lcc::CANGridConnectOverUSBSerial ObjectCount]"
        ::log::log debug "*** $type _messageReader: OpenLCBOverTcps: [lcc::OpenLCBOverTcp ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnectOverTcps: [lcc::CANGridConnectOverTcp ObjectCount]"
        ::log::log debug "*** $type _messageReader: CANGridConnectOverCANSockets: [lcc::CANGridConnectOverCANSocket ObjectCount]"
        ::log::log debug "*** $type _messageReader: OpenLCBNodes: [lcc::OpenLCBNode ObjectCount]"
        ::log::log debug "*** $type _messageReader: EventIDs: [lcc::EventID ObjectCount]"
        ::log::log debug "*** $type _messageReader: MTIHeaders: [lcc::MTIHeader ObjectCount]"
    }
    proc listeq {l1 l2} {
        foreach a $l1 b $l2 {
            if {$a != $b} {return false}
        }
        return true
    }
}


snit::type Router {
    #** @brief This class implements the OpenLCB Router.
    #
    # The static members implement global initialization and the listeners.
    #
    # @author Robert Heller \<heller\@deepsoft.com\>
    #
    
    # Set up for an ensemble command.
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no
    
    
    typevariable defaultNID "05:01:01:01:22:00"
    #** Default NID
    typevariable _nid
    #** My NID
    typemethod MyNID {} {
        #** Return my NID
        # @returns My NID
        
        return $_nid
    }
    typevariable protocolsupport [list 0x80 0x10 0x00]
    #** Protocol support: Simple Protocol subset and SimpleNodeInfo.
    typevariable simplenodeinfo {}
    #** Simple node info payload.
    typevariable softwaremodel {Router}
    typevariable softwareversion {0.0}
    typevariable manufactorname {Deepwoods Software}
    typevariable manufactorversion {}
    typevariable nodename {}
    typevariable nodedescription {}
    typemethod _generatesimplenodeinfo {} {
        set simplenodeinfo [list 4]
        foreach s [list $manufactorname \
                   $softwaremodel \
                   $manufactorversion \
                   $softwareversion] {
            foreach ch [split $s {}] {
                lappend simplenodeinfo [scan $ch {%c}]
            }
            lappend simplenodeinfo 0
        }
        lappend simplenodeinfo 2
        foreach s [list $nodename $nodedescription] {
            foreach ch [split $s {}] {
                lappend simplenodeinfo [scan $ch {%c}]
            }
            lappend simplenodeinfo 0
        }
    }
    typevariable _routeTable -array {}
    #** The routing table.  This is an array, indexed by NIDs, containing
    # the source segment/network type.  This is used to determine where to
    # send messages addressed to a given NID.
    typevariable logchan
    #** @brief Logfile channel.
    
    typecomponent _openLCBTcpip
    #** The Native OpenLCB handler
    typecomponent _openLCBGCCan
    #** The GridConnect (CAN) handler
    
    
    typeconstructor {
        #** @brief Global static initialization.
        #
        # Set up the logging and open channels and start listening.
        #
        
        # The command line...
        global argv
        global argc
        global argv0
        
        # debug logging...
        set debugnotvis 1
        set debugIdx [lsearch -exact $argv -debug]
        if {$debugIdx >= 0} {
            set debugnotvis 0
            set argv [lreplace $argv $debugIdx $debugIdx]
        }
        # Set up the log file
        set deflogfilename [format {%s.log} [file tail $argv0]]
        set logfilename [from argv -log $deflogfilename]
        if {[file extension $logfilename] ne ".log"} {append logfilename ".log"}
        # Daemonize ourselves: detach from controlling tty and/or the parent 
        # process's I/O channels
        close stdin
        close stdout
        close stderr
        # Bind stdin and stdout to the null device
        set null /dev/null
        if {$::tcl_platform(platform) eq "windows"} {
            set null nul
        }
        open $null r
        open $null w
        # And stderr to the log file
        set logchan [open $logfilename w]
        fconfigure $logchan  -buffering none
        
        # Set up logging
        ::log::lvChannelForall $logchan
        ::log::lvSuppress info 0
        ::log::lvSuppress notice 0
        ::log::lvSuppress warning 0
        ::log::lvSuppress debug $debugnotvis
        ::log::lvCmdForall [mytypemethod LogPuts]
        
        set _nid [from argv -nid $defaultNID]
        set nodename [from argv -nodename]
        set nodedescription [from argv -nodedescription]
        set manufactorversion $MRRSystem::VERSION
        $type _generatesimplenodeinfo
        
        # Startup message
        ::log::logMsg [_ "%s starting (%s: %s)..." $type $_nid $nodename]
        
        # Set typecomponents (prevent race condition)
        set _openLCBTcpip OpenLCBTcp
        set _openLCBGCCan OpenLCBGCCAN

        # Open helper objects.
        $_openLCBGCCan   Open argv $type
        $_openLCBTcpip   Open argv $type
        $type SendInitComplete
    }
    typemethod LogPuts {level message} {
        #** Log output function.
        #
        # @param level Level of log message.
        # @param message The message text.
        
        puts [::log::lv2channel $level] "[clock format [clock seconds] -format {%b %d %T}] \[[pid]\] $level $message"
    }
    typemethod Broadcast {message fromflag} {
        #** Handle a broadcast message.
        #
        # @param message The message.
        # @param fromflag Either B (message is from the binary channel) or C
        # (message is from the CAN channel)
        
        ::log::log debug "*** $type Broadcast [$message toString] $fromflag"
        if {[string tolower [$message cget -sourcenid]] eq [string tolower $_nid]} {
            $_openLCBGCCan SendMessage $message
            $_openLCBTcpip SendMessage $message
        } else {
            switch $fromflag {
                B {
                    $_openLCBGCCan SendMessage $message
                }
                C {
                    $_openLCBTcpip SendMessage $message
                }
            }
            $type MessageHandler $message
        }
    }
    typemethod SendTo {destination message fromflag} {
        #** Handle a message to a specific address.
        #
        # @param destination The destination address to send to
        # @param message The message.
        # @param fromflag Either B (message is from the binary channel) or C
        # (message is from the CAN channel)
        
        ::log::log debug "*** $type SendTo '$destination' [$message toString] $fromflag"
        if {[string tolower $destination] eq [string tolower $_nid]} {
            $type MessageHandler $message
            return
        }
        ::log::log debug "*** $type SendTo: info exists _routeTable([string toupper $destination]) is [info exists _routeTable([string toupper $destination])]"
        if {[info exists _routeTable([string toupper $destination])]} {
            ::log::log debug "*** $type SendTo: _routeTable([string toupper $destination]) is $_routeTable([string toupper $destination])"
            set route $_routeTable([string toupper $destination])
            if {$route ne $fromflag} {
                switch $route {
                    B {
                        $_openLCBTcpip SendMessage $message
                    }
                    C {
                        $_openLCBGCCan SendMessage $message
                    }
                }
            }
        } else {
            ::log::log warning [_ "Non routable NID: %s!" $destination]
            # Hmmm.  Destination is not in the routing table.  Treat it like a
            # broadcast and hope for the best... (Really should not be happening).
            #$type Broadcast $message $fromflag
        }
    }
    typemethod UpdateRoute {destination fromflag} {
        #** Update the routing table.
        #
        # @param destination The destination address to update the route to.
        # @param fromflag Either B (from the binary channel) or C (from the 
        # CAN channel)
        
        ::log::log debug "*** $type UpdateRoute $destination $fromflag"
        set _routeTable([string toupper $destination]) $fromflag
    }
    proc matchNIDinBody {message nid} {
        set data [$message cget -data]
        if {$data eq {}} {
            return true
        }
        set nidlist [list]
        foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] $nid] 1 end] {
            lappend nidlist [scan $oct %02x]
        }
        foreach d $data n $nidlist {
            if {$d != $n} {return false}
        }
        return true
    }
    typemethod MessageHandler {message} {
        ::log::log debug "$type MessageHandler [$message toString]"
        switch [format {0x%04X} [$message cget -mti]] {
            0x0490 {
                #* Verify Node ID (global)
                if {[matchNIDinBody $message $_nid]} {
                    $type SendMyNodeVerifcation
                }
            }
            0x0488 {
                #* Verify Node ID
                $type SendMyNodeVerifcation
            }
            0x0828 {
                #* Protocol Support Inquiry
                $type SendMySupportedProtocols [$message cget -sourcenid]
            }
            0x0DE8 {
                #* Simple Node Information Request
                $type SendMySimpleNodeInfo [$message cget -sourcenid]
            }
            default {
            }
        }
    }
    typemethod SendInitComplete {} {
        #** Send an initialization complete message.
        
        set message [lcc::OpenLCBMessage %AUTO%  -sourcenid $_nid \
                     -mti 0x0100 -data [nidlist $_nid]]
        $type Broadcast $message {}
        $message destroy
    }
    typemethod SendMySupportedProtocols {nid} {
        #** Send my supported protocols message.
        # @param nid The Node ID to send the message to.
        
        lcc::nid validate $nid
        set message [lcc::OpenLCBMessage %AUTO%  -sourcenid $_nid \
                     -mti 0x0668 -destnid $nid \
                     -data $protocolsupport]
        $type SendTo $nid $message {}
        $message destroy
    }
    typemethod SendMySimpleNodeInfo {nid} {
        #** Send my simple node info message.
        # @param nid The Node ID to send the message to.
        
        lcc::nid validate $nid
        set message [lcc::OpenLCBMessage %AUTO%  -sourcenid $_nid \
                     -mti 0x0A08 -destnid $nid \
                     -data $simplenodeinfo]
        $type SendTo $nid $message {}
        $message destroy
    }
    typemethod SendMyNodeVerifcation {} {
        #** Send my node verification message
        
        set message [lcc::OpenLCBMessage %AUTO%  -sourcenid $_nid \
                     -mti 0x0170 \
                     -data [nidlist $_nid]]
        $type Broadcast $message {}
        $message destroy
    }
    proc nidlist {nid} {
        #** Break a Node ID string into a list of bytes.
        # @param nid The Node ID to split up.
        
        set nidlist [list]
        foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] \
                             $nid] 1 end] {
            lappend nidlist [scan $oct %02x]
        }
        return $nidlist
    }
        
}

vwait forever


