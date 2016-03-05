#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Mar 1 10:44:58 2016
#  Last Modified : <160305.0850>
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


## @defgroup OpenLCB OpenLCB
# @brief OpenLCB main program (for configuration and manual operations).
#
# @section SYNOPSIS
#
# OpenLCB [X11 Resource Options] [-port portdev] [-nid NodeID]
#
# @section DESCRIPTION
#
# This program is a GUI program for configuring OpenLCB nodes and for manual
# (testing) operations.
#
# @section PARAMETERS
#
# none
#
# @section OPTIONS
#
# @arg -port Specifies the serial port device. Default is /dev/ttyACM0.
# @arg -nid  Specifies the Node ID to use. Default is 05:01:01:01:22:00.
# @par
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB]

package require Tk
package require tile
package require snit
package require MainWindow
package require ScrollWindow
package require ROText
package require snitStdMenuBar
package require LabelFrames
package require LCC
package require ParseXML
package require ConfigurationEditor
package require EventDialogs
package require ConfigDialogs


snit::type OpenLCB {
    pragma -hastypeinfo false
    pragma -hastypedestroy false
    pragma -hasinstances false
    
    typecomponent mainWindow
    typecomponent   nodetree
    typecomponent lcc
    typecomponent sendevent
    
    typevariable nodetree_cols {nodeid}
    typevariable mynid {}
    typevariable protocolssupported -array {}
    typevariable simplenodeinfo -array {}
    typevariable simplenodeinfo_meta -array {}
    typevariable datagrambuffers -array {}
    typevariable memoryspaceinfos -array {}
    typevariable configoptions -array {}
    typevariable _readcompleteFlag 0
    typevariable simplenodeinfo -array {}
    typevariable simplenodeinfo_meta -array {}
    typevariable _verifytimeout 0
    typeconstructor {
        set mainWindow [mainwindow .main -scrolling yes -height 600 -width 800]
        pack $mainWindow -expand yes -fill both
        $mainWindow menu entryconfigure file "Exit" -command [mytypemethod _carefulExit]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Label|File|Send Event"] \
              -command [mytypemethod _SendEvent]
        set sendevent {}
        set nodetree [ttk::treeview \
                      [$mainWindow scrollwindow getframe].nodetree \
                      -columns $nodetree_cols \
                      -selectmode browse \
                      -show tree]
        $mainWindow scrollwindow setwidget $nodetree
        set lcc [eval [list lcc::LCCBufferUSB %AUTO% -eventhandler [mytypemethod eventhandler]] $::argv]
        set mynid [$lcc cget -nid]
        set myalias [$lcc getMyAlias]
        set simplenodeinfo_meta($myalias,manufact) "Deepwoods Software"
        set simplenodeinfo_meta($myalias,model) "MRR Sys OpenLCB"
        set simplenodeinfo_meta($myalias,hvers) ""
        set simplenodeinfo_meta($myalias,svers) "1.0"
        set simplenodeinfo_meta($myalias,name) ""
        set simplenodeinfo_meta($myalias,descr) ""
        set protocolssupported($myalias) [list Simple Datagram EventExchange]
        $nodetree insert {} end -id $mynid \
              -text $mynid \
              -open no
        $lcc verifynode
        set _verifytimeout 0
        after 5000 [list incr [mytypevar _verifytimeout]]
        vwait [mytypevar _verifytimeout]
        foreach nid [$lcc getAllNIDs] {
            #puts stderr "*** OpenLCB typeconstructor: nid = $nid"
            set n_alias [$lcc getAliasOfNID $nid]
            if {$nid ne $mynid} {
                $nodetree insert {} end -id $nid \
                      -text $nid \
                      -open no
                $lcc protosupport $n_alias
                $type getSimpleNodeInfo $n_alias
            }
            $nodetree insert $nid end -id ${nid}_simplenodeinfo \
                  -text {Simple Node Info} \
                  -open no
            $nodetree insert ${nid}_simplenodeinfo end \
                  -id ${nid}_simplenodeinfo_manufact \
                  -text [format {Manfacturer: %s} \
                         $simplenodeinfo_meta($n_alias,manufact)] \
                  -open no
            $nodetree insert ${nid}_simplenodeinfo end \
                  -id ${nid}_simplenodeinfo_model \
                  -text [format {Model: %s} \
                         $simplenodeinfo_meta($n_alias,model)] \
                  -open no
            if {$simplenodeinfo_meta($n_alias,hvers) ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_hvers \
                      -text [format {Hardware Version: %s} \
                             $simplenodeinfo_meta($n_alias,hvers)] \
                      -open no
            }
            if {$simplenodeinfo_meta($n_alias,svers) ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_svers \
                      -text [format {Software Version: %s} \
                             $simplenodeinfo_meta($n_alias,svers)] \
                      -open no
            }
            if {$simplenodeinfo_meta($n_alias,name) ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_name \
                      -text [format {Name: %s} \
                             $simplenodeinfo_meta($n_alias,name)] \
                      -open no
            }
            if {$simplenodeinfo_meta($n_alias,descr) ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_descr \
                      -text [format {Description: %s} \
                             $simplenodeinfo_meta($n_alias,descr)] \
                      -open no
            }
            if {[llength $protocolssupported($n_alias)] > 0} {
                $nodetree insert $nid end -id ${nid}_protocols \
                      -text {Protocols Supported} \
                      -open no
                foreach p $protocolssupported($n_alias) {
                    $nodetree insert ${nid}_protocols end \
                          -id ${nid}_protocols_$p \
                          -text $p \
                          -open no \
                          -tag protocol_$p
                }
            }
        }
        $nodetree tag bind protocol_CDI <ButtonPress-1> [mytypemethod _ReadCDI %x %y]
        $nodetree tag bind protocol_MemoryConfig <ButtonPress-1> [mytypemethod _MemoryConfig %x %y]
        $mainWindow showit
    }
    typemethod _SendEvent {} {
        if {[info exists sendevent] && [winfo exists $sendevent]} {
            $sendevent draw
        } else {
            set sendevent [lcc::SendEvent .sendevent%AUTO% -transport $lcc]
        }
    }
    typevariable CDIs_text -array {}
    typevariable CDIs_xml  -array {}
    typevariable CDIs_FormTLs -array {}
    typemethod _ReadCDI {x y} {
        #puts stderr "*** $type _ReadCDI $x $y"
        set id [$nodetree identify row $x $y]
        #puts stderr "*** $type _ReadCDI: id = $id"
        set nid [regsub {_protocols_CDI} $id {}]
        #puts stderr "*** $type _ReadCDI: nid = $nid"
        set sourceaddress [$lcc getAliasOfNID $nid]
        #puts stderr [format {*** %s _ReadCDI: alias = 0x%03X} $type $sourceaddress]
        if {![info exists CDIs_text($sourceaddress)] ||
            $CDIs_text($sourceaddress) eq ""} {
            set _readcompleteFlag 0
            $lcc getAddrSpaceInfo $sourceaddress 0x0FF
            vwait [mytypevar _readcompleteFlag]
            if {$memoryspaceinfos($sourceaddress,FF,present)} {
                set start $memoryspaceinfos($sourceaddress,FF,lowest)
                set end   [expr {$memoryspaceinfos($sourceaddress,FF,highest) + 64}]
                set CDIs_text($sourceaddress) {}
                for {set address $start} {$address < $end} {incr address $size} {
                    set size [expr {$end - $address}]
                    if {$size > 64} {set size 64}
                    $lcc DatagramRead $sourceaddress 0x0FF $address $size
                    vwait [mytypevar _readcompleteFlag]
                    set status [lindex $datagrambuffers($sourceaddress) 1]
                    if {$status == 0x53} {
                        set respaddress [expr {[lindex $datagrambuffers($sourceaddress) 2] << 24}]
                        set respaddress [expr {$respaddress | ([lindex $datagrambuffers($sourceaddress) 3] << 16)}]
                        set respaddress [expr {$respaddress | ([lindex $datagrambuffers($sourceaddress) 4] << 8)}]
                        set respaddress [expr {$respaddress | [lindex $datagrambuffers($sourceaddress) 5]}]
                        if {$respaddress == $address} {
                            set bytes [lrange $datagrambuffers($sourceaddress) 6 end]
                            set count 0
                            foreach b $bytes {
                                if {$b == 0} {break}
                                append CDIs_text($sourceaddress) [format {%c} $b]
                                incr count
                                if {$count >= $size} {break}
                            }
                        } else {
                            # ??? (bad return address)
                        }
                    } else {
                        # error...
                        set error [expr {[lindex $datagrambuffers($sourceaddress) 2] << 8}]
                        set error [expr {$error | [lindex $datagrambuffers($sourceaddress) 3]}]
                        #$logmessages insert end "[format {Read Reply error %04X} $error]"
                        #set message { }
                        #foreach b [lrange $datagrambuffers($sourceaddress) 4 end] {
                        #    append message [format %c $b]
                        #}
                        #$logmessages insert end "$message\n"
                    }
                    
                }
                set CDIs_xml($sourceaddress) [ParseXML %AUTO% \
                                              $CDIs_text($sourceaddress)]
                
                set CDIs_FormTLs($sourceaddress) \
                      [lcc::ConfigurationEditor .cdi$sourceaddress \
                       -cdi $CDIs_xml($sourceaddress) \
                       -alias $sourceaddress \
                       -transport $lcc ]
            } else {
                # No CDI...
            }
        } elseif {![info exists CDIs_xml($sourceaddress)] ||
            $CDIs_xml($sourceaddress) eq {}} {
            set CDIs_xml($sourceaddress) [ParseXML %AUTO% \
                                          $CDIs_text($sourceaddress)]
            set CDIs_FormTLs($sourceaddress) \
                  [lcc::ConfigurationEditor .cdi$sourceaddress \
                   -cdi $CDIs_xml($sourceaddress) \
                   -alias $sourceaddress \
                   -transport $lcc ]
        } elseif {![info exists CDIs_FormTLs($sourceaddress)] ||
                  $CDIs_FormTLs($sourceaddress) eq {} ||
                  ![winfo exists $CDIs_FormTLs($sourceaddress)]} {
            set CDIs_FormTLs($sourceaddress) \
                  [lcc::ConfigurationEditor .cdi$sourceaddress \
                   -cdi $CDIs_xml($sourceaddress) \
                   -alias $sourceaddress \
                   -transport $lcc ]
        } else {
            wm deiconify $CDIs_FormTLs($sourceaddress)
        }
    }
    typemethod _MemoryConfig {x y} {
        #puts stderr "*** $type _MemoryConfig $x $y"
        set id [$nodetree identify row $x $y]
        #puts stderr "*** $type _MemoryConfig: id = $id"
        set nid [regsub {_protocols_MemoryConfig} $id {}]
        #puts stderr "*** $type _MemoryConfig: nid = $nid"
        set sourceaddress [$lcc getAliasOfNID $nid]
        #puts stderr [format {*** %s _MemoryConfig: alias = 0x%03X} $type $sourceaddress]
        set count 10
        while {![info exists configoptions($sourceaddress,available)] && $count > 0} {
            set _readcompleteFlag 0
            $lcc getConfigOptions $sourceaddress
            vwait [mytypevar _readcompleteFlag]
            incr count -1
        }
        if {![info exists configoptions($sourceaddress,available)]} {
            tk_messageBox -icon warning \
                  -message [_ "Could not get configuration options for %s!" $nid] \
                  -type ok
        } else {
            lcc::ConfigOptions .configopts${sourceaddress}%AUTO% \
                  -nid $nid \
                  -available $configoptions($sourceaddress,available) \
                  -writelengths $configoptions($sourceaddress,writelens) \
                  -highest $configoptions($sourceaddress,highest) \
                  -lowest $configoptions($sourceaddress,lowest) \
                  -name "$configoptions($sourceaddress,name)"
        }
        lcc::ConfigMemory .configmem${sourceaddress}%AUTO% \
              -destaddress $nid \
              -transport $lcc
    }
    
    typemethod eventhandler {canmessage} {
        #puts stderr "*** $type eventhandler [$canmessage toString]"
        set mtiheader [lcc::MTIHeader %AUTO%]
        $mtiheader setHeader [$canmessage getHeader]
        set mtidetail [lcc::MTIDetail %AUTO%]
        $mtidetail setHeader [$canmessage getHeader]
        set datacomplete no
        #puts stderr "*** $type eventhandler: streamordatagram: [$mtidetail cget -streamordatagram]"
        if {[$mtidetail cget -streamordatagram]} {
            set srcid [$mtiheader cget -srcid]
            switch [$mtidetail cget -datagramcontent] {
                complete {
                    set datagrambuffers($srcid) [$canmessage getData]
                    set datacomplete yes
                }
                first {
                    set datagrambuffers($srcid) [$canmessage getData]
                }
                middle {
                    eval [list lappend datagrambuffers($srcid)] [$canmessage getData]
                }
                last {
                    eval [list lappend datagrambuffers($srcid)] [$canmessage getData]
                    set datacomplete yes
                }
            }
            #puts stderr "*** $type eventhandler: datacomplete = $datacomplete, srcid = $srcid"
            if {$datacomplete} {
                $lcc DatagramAck $srcid
                #puts stderr "*** $type eventhandler: op is [format {0x%02X} [lindex $datagrambuffers($srcid) 1]]"
                switch [format {0x%02X} [lindex $datagrambuffers($srcid) 1]] {
                    0x82 {
                        # Get Config Options Reply
                        set configoptions($srcid,available) [expr {([lindex $datagrambuffers($srcid) 2] << 8) | [lindex $datagrambuffers($srcid) 3]}]
                        set configoptions($srcid,writelens) [lindex $datagrambuffers($srcid) 4]
                        set configoptions($srcid,highest)   [lindex $datagrambuffers($srcid) 5]
                        set configoptions($srcid,lowest)    [lindex $datagrambuffers($srcid) 6]
                        set configoptions($srcid,name) ""
                        set stringdata [lrange $datagrambuffers($srcid) 7 end]
                        foreach c $stringdata {
                            append configoptions($srcid,name) [format %c $c]
                        }
                    }
                    0x86 -
                    0x87 {
                        # Get Address Space Information Reply
                        set present [expr {[lindex $datagrambuffers($srcid) 1] == 0x87}]
                        set space   [lindex $datagrambuffers($srcid) 2]
                        set highest [expr {[lindex $datagrambuffers($srcid) 3] << 24}]
                        set highest [expr {$highest | ([lindex $datagrambuffers($srcid) 4] << 16)}]
                        set highest [expr {$highest | ([lindex $datagrambuffers($srcid) 5] << 8)}]
                        set highest [expr {$highest | [lindex $datagrambuffers($srcid) 6]}]
                        set flags   [lindex $datagrambuffers($srcid) 7]
                        if {($flags & 0x02) != 0} {
                            set lowest [expr {[lindex $datagrambuffers($srcid) 8] << 24}]
                            set lowest [expr {$lowest | ([lindex $datagrambuffers($srcid) 9] << 16)}]
                            set lowest [expr {$lowest | ([lindex $datagrambuffers($srcid) 10] << 8)}]
                            set lowest [expr {$lowest | [lindex $datagrambuffers($srcid) 11]}]
                            set descroff 12
                        } else {
                            set lowest 0
                            set descroff 8
                        }
                        set writable [expr {($flags & 0x01) == 0}]
                        set descr {}
                        foreach d [lrange $datagrambuffers($srcid) $descroff end] {
                            append descr [format %c $d]
                        }
                        set memoryspaceinfos($srcid,[format {%02X} $space],present) $present
                        if {$present} {
                            set memoryspaceinfos($srcid,[format {%02X} $space],lowest) $lowest
                            set memoryspaceinfos($srcid,[format {%02X} $space],highest) $highest
                            set memoryspaceinfos($srcid,[format {%02X} $space],writable) $writable
                        }
                    }
                }
                incr _readcompleteFlag
            }
        }
        if {[$mtiheader cget -mti] == 0x0668} {
            # Protocol Support Report
            set report [lrange [$canmessage getData] 2 4]
            set protocols [list]
            if {([lindex $report 0] & 0x80) != 0} {
                lappend protocols Simple
            }
            if {([lindex $report 0] & 0x40) != 0} {
                lappend protocols Datagram
            }
            if {([lindex $report 0] & 0x20) != 0} {
                lappend protocols Stream
            }
            if {([lindex $report 0] & 0x10) != 0} {
                lappend protocols MemoryConfig
            }
            if {([lindex $report 0] & 0x08) != 0} {
                lappend protocols Reservation
            }
            if {([lindex $report 0] & 0x04) != 0} {
                lappend protocols EventExchange
            }
            if {([lindex $report 0] & 0x02) != 0} {
                lappend protocols Itentification
            }
            if {([lindex $report 0] & 0x01) != 0} {
                lappend protocols TeachLearn
            }
            
            if {([lindex $report 1] & 0x80) != 0} {
                lappend protocols RemoteButton
            }
            if {([lindex $report 1] & 0x40) != 0} {
                lappend protocols AbbreviatedDefaultCDI
            }
            if {([lindex $report 1] & 0x20) != 0} {
                lappend protocols Display
            }
            if {([lindex $report 1] & 0x10) != 0} {
                lappend protocols SimpleNodeInfo
            }
            if {([lindex $report 1] & 0x08) != 0} {
                lappend protocols CDI
            }
            if {([lindex $report 1] & 0x04) != 0} {
                lappend protocols Traction
            }
            if {([lindex $report 1] & 0x02) != 0} {
                lappend protocols FDI
            }
            if {([lindex $report 1] & 0x01) != 0} {
                lappend protocols DCC
            }
            
            if {([lindex $report 2] & 0x80) != 0} {
                lappend protocols SimpleTrainNode
            }
            if {([lindex $report 2] & 0x40) != 0} {
                lappend protocols FunctionConfiguration
            }
            set protocolssupported([$mtiheader cget -srcid]) $protocols
        } elseif {[$mtiheader cget -mti] == 0x0A28} {
            # Datagram Received OK
            set flags [lindex [$canmessage getData] 2]
            if {$flags eq ""} {set flags 0}
        } elseif {[$mtiheader cget -mti] == 0x0A48} {
            # Datagram Rejected
            set error [expr {[lindex [$canmessage getData] 2] << 8}]
            set error [expr {$error | [lindex [$canmessage getData] 3]}]
        } elseif {[$mtiheader cget -mti] == 0x0A08} {
            # Simple node information reply
            set from [$mtiheader cget -srcid]
            set flags [expr {([lindex [$canmessage getData] 0] & 0x030) >> 4}]
            #puts stderr "[format {*** %s eventhandler: fddd is %02x%02x} $type [lindex [$canmessage getData] 0] [lindex [$canmessage getData] 1]]"
            #puts stderr "*** $type eventhandler: flags = $flags"
            switch $flags {
                0 {
                   # Single frame
                   eval [list lappend simplenodeinfo($from)] [lrange [$canmessage getData] 2 end]
                   set simplenodeinfo_meta($from,v1) [lindex $simplenodeinfo($from) 0]
                   if {$simplenodeinfo_meta($from,v1) == 1} {
                       set simplenodeinfo_meta($from,v1) 4
                   }
                   set simplenodeinfo_meta($from,expectedNULs) [expr {$simplenodeinfo_meta($from,v1) + 2}]
                   if {[countNUL $simplenodeinfo($from)] >= $simplenodeinfo_meta($from,expectedNULs)} {
                       incr _readcompleteFlag
                   }
                }
                1 {
                   # First of multiple frames
                   set simplenodeinfo($from) [lrange [$canmessage getData] 2 end]
                }
                2 {
                   # Middle of multiple frames
                   eval [list lappend simplenodeinfo($from)] [lrange [$canmessage getData] 2 end]
                }
                3 {
                   # Last of multiple frames
                   eval [list lappend simplenodeinfo($from)] [lrange [$canmessage getData] 2 end]
                   incr _readcompleteFlag
                }
            }
        } elseif {[$mtiheader cget -mti] == 0x05B4} {
            # event received (PCER message)
            set eventID [lrange [$canmessage getData] 0 7]
            set srcid [$mtiheader cget -srcid]
            lcc::EventReceived .eventreceived${srcid}%AUTO% \
                  -srcid [$lcc getNIDofAlias $srcid] \
                  -eventid [lcc::EventID %AUTO% \
                            -eventidlist $eventID]
        }
            
    }
    typemethod getSimpleNodeInfo {address} {
        set _readcompleteFlag 0
        set simplenodeinfo($address) [list]
        $lcc getSimpleNodeInfo $address
        vwait [mytypevar _readcompleteFlag]
        set strings1 [lindex $simplenodeinfo($address) 0]
        # If version 1, then 4 strings (???), other wise version == number of strings
        if {$strings1 == 1} {set strings1 4}
        set i 1
        set names1 {manufact model hvers svers}
        for {set istring 0} {$istring < $strings1} {incr istring} {
            set s ""
            while {[lindex $simplenodeinfo($address) $i] != 0} {
                append s [format %c [lindex $simplenodeinfo($address) $i]]
                incr i
            }
            set simplenodeinfo_meta($address,[lindex $names1 $istring]) $s
            incr i
        }
        set strings2 [lindex $simplenodeinfo($address) $i]
        if {$strings2 == 1} {set strings2 2}
        # If version 1, then 2 strings (???), other wise version == number of strings
        incr i
        set names2 {name descr}
        for {set istring 0} {$istring < $strings2} {incr istring} {
            set s ""
            while {[lindex $simplenodeinfo($address) $i] != 0} {
                append s [format %c [lindex $simplenodeinfo($address) $i]]
                incr i
            }
            set simplenodeinfo_meta($address,[lindex $names2 $istring]) $s
            incr i
        }
    }
    typemethod _carefulExit {} {
        exit
    }
    proc countNUL {list} {
       set count 0
       set start 0
       while {[set i [lsearch -start $start $list 0]] >= 0} {
           incr count
           set start [expr {$i + 1}]
       }
       return $count
   }
}
