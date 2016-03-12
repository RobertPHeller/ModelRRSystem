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
#  Last Modified : <160312.1230>
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
# OpenLCB [X11 Resource Options] -- [Other options]
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
# @subsection x11resource X11 Resource Options
#
# @arg -colormap: Colormap for main window
# @arg -display:  Display to use
# @arg -geometry: Initial geometry for window
# @arg -name:     Name to use for application
# @arg -sync:     Use synchronous mode for display server
# @arg -visual:   Visual for main window
# @arg -use:      Id of window in which to embed application
# @par
#
# @subsection other Other options
#
# @arg -transportname The name of the transport constructor.  A shell wildcard
#                     is allowed (but needs to be quoted or escaped).
# @arg -listconstructors Print a list of available constructors and exit.
# @arg -help Print a short help message and exit.
# @par
#
# Additional options, specific to the transport constructor can also be 
# specified.
#
# @section AUTHOR
# Robert Heller \<heller\@deepsoft.com\>
#

set argv0 [file join  [file dirname [info nameofexecutable]] OpenLCB]

package require gettext
package require Tk
package require tile
package require snit
package require MainWindow
package require ScrollWindow
package require ROText
package require snitStdMenuBar
package require HTMLHelp 2.0
package require LabelFrames
package require LCC
package require ParseXML
package require ConfigurationEditor
package require EventDialogs
package require ConfigDialogs


global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
							[info script]]]] Help]
#puts stderr "*** HelpDir = $HelpDir"
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname [file dirname \
							[info script]]]] Messages]]
#puts stderr "*** msgfiles = $msgfiles"

snit::type OpenLCB {
    pragma -hastypeinfo false
    pragma -hastypedestroy false
    pragma -hasinstances false
    
    typecomponent mainWindow
    typecomponent   nodetree
    typecomponent transport
    typecomponent sendevent
    
    typevariable nodetree_cols {nodeid}
    typevariable mynid {}
    typevariable transport
    typemethod usage {} {
        puts stdout [_ "Usage: %s \[X11 Resource Options\] -- \[Other options\]" $::argv0]
        puts stdout {}
        puts stdout [_ "X11 Resource Options:"]
        puts stdout [_ " -colormap: Colormap for main window"]
        puts stdout [_ "-display:  Display to use"]
        puts stdout [_ "-geometry: Initial geometry for window"]
        puts stdout [_ "-name:     Name to use for application"]
        puts stdout [_ "-sync:     Use synchronous mode for display server"]
        puts stdout [_ "-visual:   Visual for main window"]
        puts stdout [_ "-use:      Id of window in which to embed application"]
        puts stdout {}
        puts stdout [_ "Other options:"]
        puts stdout [_ "-transportname: The name of the transport constructor."]
        puts stdout [_ "-listconstructors: Print a list of available constructors and exit."]
        puts stdout [_ "-help: Print this help message and exit."]
        puts stdout [_ "Additional options for the transport constructor can also be specified."]
    }
    typeconstructor {
        set listconstructorsP [lsearch $::argv -listconstructors]
        set helpP [lsearch $::argv -help]
        if {$listconstructorsP >= 0} {
            wm withdraw .
            set transportConstructorList [lcc::OpenLCBNode \
                                          transportConstructors]
            puts stdout [_ "Constructors available:"]
            foreach {descr name} $transportConstructorList {
                puts stdout [format "%s: %s" [namespace tail $name] $descr]
            }
            $type usage
            exit
        }
        if {$helpP >= 0} {
            wm withdraw .
            $type usage
            exit
        }
        set mainWindow [mainwindow .main -scrolling yes -height 600 -width 800]
        pack $mainWindow -expand yes -fill both
        $mainWindow menu entryconfigure file "Exit" -command [mytypemethod _carefulExit]
        $mainWindow menu insert file "Print..." command \
              -label [_m "Label|File|Send Event"] \
              -command [mytypemethod _SendEvent]
        $mainWindow menu entryconfigure help "On Help..." -command {HTMLHelp help Help}
        $mainWindow menu delete help "On Keys..."
        $mainWindow menu delete help "Index..."
        $mainWindow menu delete help "Tutorial..."
        $mainWindow menu entryconfigure help "On Version" -command {HTMLHelp help Version}
        $mainWindow menu entryconfigure help "Warranty" -command {HTMLHelp help Warranty}
        $mainWindow menu entryconfigure help "Copying" -command {HTMLHelp help Copying}
        $mainWindow menu add help command \
              -label [_m "Menu|Help|Reference Manual"] \
              -command {HTMLHelp help "OpenLCB Reference"}
        
        
        HTMLHelp setDefaults "$::HelpDir" "index.html#toc"
        
        set sendevent {}
        set nodetree [ttk::treeview \
                      [$mainWindow scrollwindow getframe].nodetree \
                      -columns $nodetree_cols \
                      -selectmode browse \
                      -show tree]
        $mainWindow scrollwindow setwidget $nodetree
        update idle
        puts stderr "*** $type typeconstructor: ::argv is $::argv"
        set transportConstructorName [from ::argv -transportname ""]
        puts stderr "*** $type typeconstructor: transportConstructorName is $transportConstructorName"
        set transportConstructor {}
        if {$transportConstructorName ne ""} {
            set transportConstructors [info commands ::lcc::$transportConstructorName]
            puts stderr "*** $type typeconstructor: transportConstructors is $transportConstructors"
            if {[llength $transportConstructors] > 0} {
                set transportConstructor [lindex $transportConstructors 0]
            }
        }
        if {$transportConstructor eq {}} {
            set transportConstructor [lcc::OpenLCBNode \
                                      selectTransportConstructor \
                                      -parent [winfo toplevel $mainWindow]]
        }
        if {$transportConstructor eq {}} {
            exit
        }
        set reqOpts [$transportConstructor requiredOpts]
        set transportOpts [list]    
        foreach {o d} $reqOpts {
            if {[lsearch $::argv $o] >= 0} {
                lappend transportOpts $o [from ::argv $o $d]
            }
        }
        if {[llength $reqOpts] > [llength $transportOpts]} {
            set transportOpts [eval [list $transportConstructor \
                                     drawOptionsDialog \
                                     -parent [winfo toplevel $mainWindow]] \
                                     $transportOpts]
        }
        set transport [eval [list lcc::OpenLCBNode %AUTO% \
                             -transport $transportConstructor\
                             -eventhandler [mytypemethod _eventHandler] \
                             -generalmessagehandler [mytypemethod _messageHandler]] \
                             $transportOpts]
        #puts stderr "*** $type typeconstructor: transport = $transport"
        set mynid [$transport cget -nid]
        #puts stderr "*** $type typeconstructor: mynid = $mynid"
        $nodetree insert {} end -id $mynid \
              -text $mynid \
              -open no
        #puts stderr "*** $type typeconstructor: $mynid inserted."
        $type _insertSimpleNodeInfo $mynid [$transport ReturnMySimpleNodeInfo]
        $type _insertSupportedProtocols $mynid [$transport ReturnMySupportedProtocols]
        #
        $nodetree tag bind protocol_CDI <ButtonPress-1> [mytypemethod _ReadCDI %x %y]
        $nodetree tag bind protocol_MemoryConfig <ButtonPress-1> [mytypemethod _MemoryConfig %x %y]
        $mainWindow showit
        update idle
        $transport SendVerifyNodeID
        #puts stderr "*** $type typeconstructor: done."
    }
    typemethod _eventHandler {command eventid {{validity {}}}} {
        if {$command eq "report"} {
            lcc::EventReceived .eventreceived${srcid}%AUTO% \
                  -eventid $eventid
        }
    }
    typemethod _messageHandler {message} {
        switch [format {0x%04X} [$message cget -mti]] {
            0x0170 -
            0x0171 {
                ## Verified Node ID
                set nid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] \
                         [$message cget -data]]
                $nodetree insert {} end -id $nid -text $nid -open no
                $transport SendSimpleNodeInfoRequest $nid
            }
            0x0490 -
            0x0498 {
                ## Verify Node ID
                $transport SendMyNodeVerifcation
            }
            0x0828 {
                ## Protocol Support Inquiry
                $transport SendMySupportedProtocols [$message cget -sourcenid]
            }
            0x0668 {
                ## Protocol Support Reply
                set report [$message cget -data]
                set nid    [$message cget -sourcenid]
                $type _insertSupportedProtocols $nid $report
            }
            0x0DE8 {
                ## Simple Node Information Request
                $transport SendMySimpleNodeInfo [$message cget -sourcenid]
            }
            0x0A08 {
                ## Simple Node Information Reply
                set payload [$message cget -data]
                set nid     [$message cget -sourcenid]
                $type _insertSimpleNodeInfo $nid $payload
            }
            default {
            }
        }
    }
    typemethod _insertSimpleNodeInfo {nid infopayload} {
        #puts stderr "*** $type _insertSimpleNodeInfo $nid $infopayload"
        $nodetree insert $nid end -id ${nid}_simplenodeinfo \
              -text {Simple Node Info} \
              -open no
        set strings1 [lindex $infopayload 0]
        if {$strings1 == 1} {set strings1 4}
        set i 1
        set names1 {manufact model hvers svers}
        set formats1 [list \
                      "Manfacturer: %s" \
                      "Model: %s" \
                      "Hardware Version: %s" \
                      "Software Version: %s"]
        for {set istring 0} {$istring < $strings1} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                append s [format %c [lindex $infopayload $i]]
                incr i
            }
            if {$s ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names1 $istring] \
                      -text [_ [lindex $formats1 $istring] $s] \
                      -open no
            }
            incr i
        }
        set strings2 [lindex $infopayload $i]
        if {$strings2 == 1} {set strings2 2}
        # If version 1, then 2 strings (???), other wise version == number of strings
        incr i
        set names2 {name descr}
        set formats2 [list "Name: %s" "Description: %s"]
        for {set istring 0} {$istring < $strings2} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                append s [format %c [lindex $infopayload $i]]
                incr i
            }
            if {$s ne ""} {
                $nodetree insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names2 $istring] \
                      -text [_ [lindex $formats2 $istring] $s] \
                      -open no
            }
            incr i
        }
        #puts stderr "*** $type _insertSimpleNodeInfo: done"
        $transport SendSupportedProtocolsRequest $nid
    }
    typevariable protocolstrings -array {
        Simple "Label|Simple"
        Datagram "Label|Datagram"
        Stream "Label|Stream"
        MemoryConfig "Label|Memory Configuration"
        Reservation "Label|Reservation"
        EventExchange "Label|Event Exchange"
        Itentification "Label|Identification"
        TeachLearn "Label|Teach / Learn"
        RemoteButton "Label|Remote Button"
        AbbreviatedDefaultCDI "Label|Abbreviated Default CDI"
        Display "Label|Display"
        SimpleNodeInfo "Label|Simple Node Information"
        CDI "Label|CDI"
        Traction "Label|Traction"
        FDI "Label|FDI"
        DCC "Label|DCC"
        SimpleTrainNode "Label|Simple Train Node"
        FunctionConfiguration "Label|Function Configuration"
    }
    typemethod _insertSupportedProtocols {nid report} {
        #puts stderr "*** $type _insertSupportedProtocols $nid $report"
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
        
        #puts stderr "*** $type _insertSupportedProtocols: protocols are $protocols"
        if {[llength $protocols] > 0} {
            $nodetree insert $nid end -id ${nid}_protocols \
                 -text {Protocols Supported} \
                 -open no
            foreach p $protocols {
                #puts stderr [list *** $type _insertSupportedProtocols: p = $p]
                $nodetree insert ${nid}_protocols end \
                      -id ${nid}_protocols_$p \
                      -text [_m $protocolstrings($p)] \
                      -open no \
                      -tag protocol_$p
            }
        }
    }
    typemethod _SendEvent {} {
        if {[info exists sendevent] && [winfo exists $sendevent]} {
            $sendevent draw
        } else {
            set sendevent [lcc::SendEvent .sendevent%AUTO% -transport $transport]
        }
    }
    
    typevariable _datagramdata 
    typevariable _currentnid    
    typevariable _iocomplete
    typemethod _datagramHandler {command sourcenid args} {
        set data $args
        switch $command {
            datagramreceivedok {
                return
            }
            datagramrejected {
                if {$sourcenid ne $_currentnid} {return}
                set _datagramdata $data
                incr _iocomplete -1
            }
            datagramcontent {
                if {$sourcenid ne $_currentnid} {
                    $transport DatagramRejected $sourcenid 0x1000
                } else {
                    
                    set _datagramdata $data
                    $transport DatagramReceivedOK $sourcenid
                    incr _iocomplete
                }
            }
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
        if {![info exists CDIs_text($nid)] ||
            $CDIs_text($nid) eq ""} {
            $transport configure -datagramhandler [mytypemethod _datagramHandler]
            set data [list 0x20 0x84 0x0FF]
            set _iocomplete 0
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [mytypevar _iocomplete]
            $transport configure -datagramhandler {}
            unset _currentnid
            set present [expr {[lindex $_datagramdata 1] == 0x87}]
            if {!$present} {return}
            set lowest 0x00000000
            set highest [expr {[lindex $_datagramdata 3] << 24}]
            set highest [expr {$highest | ([lindex $_datagramdata 4] << 16)}]
            set highest [expr {$highest | ([lindex $_datagramdata 5] << 8)}]
            set highest [expr {$highest | [lindex $_datagramdata 6]}]
            set flags [lindex $_datagramdata 7]
            if {($flags & 0x02) != 0} {
                set lowest [expr {[lindex $_datagramdata 8] << 24}]
                set lowest [expr {$lowest | ([lindex $_datagramdata 9] << 16)}]
                set lowest [expr {$lowest | ([lindex $_datagramdata 10] << 8)}]
                set lowest [expr {$lowest | [lindex $_datagramdata 11]}]
            }
            set start $lowest
            set end   [expr {$highest + 64}]
            set CDIs_text($nid) {}
            for {set address $start} {$address < $end} {incr address $size} {
                set size [expr {$end - $address}]
                if {$size > 64} {set size 64}
                set data [list 0x20 0x43 \
                          [expr {($address & 0xFF000000) >> 24}] \
                          [expr {($address & 0xFF0000) >> 16}] \
                          [expr {($address & 0xFF00) >> 8}] \
                          [expr {$address & 0xFF}] \
                          $size]
                $transport configure -datagramhandler [mytypemethod _datagramHandler]
                set _iocomplete 0
                set _currentnid $nid
                $transport SendDatagram $nid $data
                vwait [mytypevar _iocomplete]
                $transport configure -datagramhandler {}
                unset _currentnid
                set status [lindex $_datagramdata 1]
                if {$status == 0x53} {
                    set respaddress [expr {[lindex $_datagramdata 2] << 24}]
                    set respaddress [expr {$respaddress | ([lindex $_datagramdata 3] << 16)}]
                    set respaddress [expr {$respaddress | ([lindex $_datagramdata 4] << 8)}]
                    set respaddress [expr {$respaddress | [lindex $_datagramdata 5]}]
                    if {$respaddress == $address} {
                        set bytes [lrange $_datagramdata 6 end]
                        set count 0
                        foreach b $bytes {
                            if {$b == 0} {break}
                            append CDIs_text($nid) [format {%c} $b]
                            incr count
                            if {$count >= $size} {break}
                        }
                    } else {
                        # ??? (bad return address)
                    }
                } else {
                    # error...
                    set error [expr {[lindex $_datagramdata 2] << 8}]
                    set error [expr {$error | [lindex $_datagramdata 3]}]
                    #$logmessages insert end "[format {Read Reply error %04X} $error]"
                    #set message { }
                    #foreach b [lrange $_datagramdata 4 end] {
                    #    append message [format %c $b]
                    #}
                    #$logmessages insert end "$message\n"
                }
                
            }
            set CDIs_xml($nid) [ParseXML %AUTO% $CDIs_text($nid)]
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) -nid $nid -transport $transport]
        } elseif {![info exists CDIs_xml($nid)] ||
            $CDIs_xml($nid) eq {}} {
            set CDIs_xml($nid) [ParseXML %AUTO% \
                                          $CDIs_text($nid)]
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) \
                   -nid $nid \
                   -transport $transport ]
        } elseif {![info exists CDIs_FormTLs($nid)] ||
                  $CDIs_FormTLs($nid) eq {} ||
                  ![winfo exists $CDIs_FormTLs($nid)]} {
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) \
                   -nid $nid \
                   -transport $transport ]
        } else {
            wm deiconify $CDIs_FormTLs($nid)
        }
    }
    typemethod _MemoryConfig {x y} {
        #puts stderr "*** $type _MemoryConfig $x $y"
        set id [$nodetree identify row $x $y]
        #puts stderr "*** $type _MemoryConfig: id = $id"
        set nid [regsub {_protocols_MemoryConfig} $id {}]
        #puts stderr "*** $type _MemoryConfig: nid = $nid"
        set count 10
        $transport configure -datagramhandler [mytypemethod _datagramHandler]
        set _iocomplete 0
        while {$count > 0 && $_iocomplete <= 0} {
            set _iocomplete 0
            set data [list 0x20 0x80]
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [mytypevar _iocomplete]
            if {$_iocomplete < 0} {
                incr count -1
            }
        }
        unset _currentnid
        $transport configure -datagramhandler {}
        if {$_iocomplete < 0} {
            tk_messageBox -icon warning \
                  -message [_ "Could not get configuration options for %s!" $nid] \
                  -type ok
            return
        }
        set available [expr {([lindex $_datagramdata 2] << 8) | [lindex $_datagramdata 3]}]
        set writelens [lindex $_datagramdata 4]
        set highest [lindex $_datagramdata 5]
        set lowest 0xFD
        set name ""
        if {[llength  $_datagramdata] >= 7} {
            set lowest [lindex $_datagramdata 6]
            foreach b [lrange $_datagramdata 7 end] {
                if {$b == 0} {break}
                append name [format %c $b]
            }
        }
        lcc::ConfigOptions .configopts[regsub {:} $nid {}]%AUTO% \
              -nid $nid \
                  -available $available \
                  -writelengths $writelens \
                  -highest $highest \
                  -lowest $lowest \
                  -name "$name"
        lcc::ConfigMemory .configmem[regsub {:} $nid {}]%AUTO% \
              -destnid $nid \
              -transport $transport
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
