#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Mon Sep 19 09:18:09 2016
#  Last Modified : <191123.1004>
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


package require gettext
package require Tk
package require tile
package require snit
package require LCC
package require ConfigurationEditor
package require ConfigDialogs

snit::widgetadaptor ReadCDIProgress {
    delegate option -parent to hull
    
    component bytesE
    variable  bytesRead
    component progress
    
    
    delegate option -totalbytes to progress as -maximum
    
    constructor {args} {
        installhull using Dialog -bitmap questhead -default dismis \
              -modal none -transient yes \
              -side bottom -title [_ "Reading CDI"] \
              -parent [from args -parent]
        $hull add dismis -text [_m "Button|Dismiss"] \
              -state disabled -command [mymethod _Dismis]
        wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Dismis]
        set frame [$hull getframe]
        install bytesE using ttk::entry $frame.bytesE \
              -textvariable [myvar bytesRead] \
              -state readonly
        pack $bytesE -expand yes -fill x
        install progress using ttk::progressbar $frame.progress \
              -orient horizontal -mode determinate -length 256
        pack $progress -expand yes -fill x
        $self configurelist $args
    }
    method draw {args} {
        #puts stderr "*** $self draw $args"
        $self configurelist $args
        set options(-parent) [$self cget -parent]
        $hull itemconfigure dismis -state disabled
        update idle
        return [$hull draw]
    }
    method withdraw {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
    method _Dismis {} {
        $hull withdraw
        return [$hull enddialog {}]
    }
    method Update {bytesread} {
        #puts stderr "*** $self Update $bytesread"
        set bytesRead [_ "%5d bytes read of %5d" $bytesread \
                       [$progress cget -maximum]]
        $progress configure -value $bytesread
        update idle
    }
    method Done {} {
        #puts stderr "*** $self Done"
        $hull itemconfigure dismis -state normal
        update idle
    }
}


snit::widgetadaptor LCCNodeTree {
    ## @brief LCC Node Tree Widget
    # This is the LCC Node Tree Widget, which lists the nodes on the 
    # OpenLCB network.
    #
    # Options: 
    # @arg -transport The OpenLCB transport object.
    # @arg -layoutdb  The layout DB
    #
    # @par
    
    typevariable nodetree_cols {nodeid}
    ## @privatesection Columns.
    component  transport
    ## Transport component.
    option -transport -readonly yes -default {} -configuremethod _settransport
    method _settransport {o v} {
        ## Transport set method
        #
        # @param o Always -transport
        # @param v The transport.
        
        set transport $v
    }
    option -layoutdb -default {} \
          -configuremethod _passthroughLayoutDB
    method _passthroughLayoutDB {o v} {
        set options($o) $v
        foreach nid [array names CDIs_FormTLs] {
            $CDIs_FormTLs($nid) configure -layoutdb $v
        }
    }
    variable mynid {}
    ## My NID.
    proc hidpiP {w} {
        ## Checks for High DPI screen
        #
        # @param w Window of the display to check
        # @returns Boolean flag, true if display is high DPI (eg 4K display)
        
        set scwidth [winfo screenwidth $w]
        set scmmwidth [winfo screenmmwidth $w]
        set scinchwidth [expr {$scmmwidth / 25.4}]
        set scdpiw [expr {$scwidth / $scinchwidth}]
        set scheight [winfo screenheight $w]
        set scmmheight [winfo screenmmheight $w]
        set scinchheight [expr {$scmmheight / 25.4}]
        set scdpih [expr {$scheight / $scinchheight}]
        return [expr {($scdpiw > 100) || ($scdpih > 100)}]
    }
    delegate option * to hull except {-columns -displaycolumns -padding -show}
    delegate method * to hull except {bbox cget children column configure 
        delete detach exists heading insert move next parent prev set state 
        tag}
    
    
    typevariable _debug no
    ## Debug flag
    proc putdebug {message} {
        if {$_debug} {
            puts stderr $message
        }
    }
    proc hexdump { header data} {
        if {$_debug} {
            puts -nonewline stderr $header
            foreach byte $data {
                puts -nonewline stderr [format " %02X" $byte]
            }
            puts stderr {}
        }
    }

    component readCDIProgress
    
    constructor {args} {
        ## @publicsection Construct a LCC Node Tree
        
        putdebug "*** $type create $self $args"
        installhull using ttk::treeview -columns $nodetree_cols -selectmode browse -show tree
        putdebug "*** $type create $self: hull = $hull"
        $self configurelist $args
        putdebug "*** $type create $self: transport = $transport"
        $hull column #0 -minwidth 500
        
        if {[hidpiP $win]} {
            set style [$hull cget -style]
            set f [ttk::style lookup $style -font]
            set ls [font metrics $f -displayof $win -linespace]
            ttk::style configure $style -rowheight [expr {$ls * 2}]
        }
        set mynid [$transport cget -nid]
        $hull insert {} end -id $mynid -text $mynid -open no
        $self _insertSimpleNodeInfo $mynid [$transport ReturnMySimpleNodeInfo]
        $self _insertSupportedProtocols $mynid [$transport ReturnMySupportedProtocols]
        $hull tag bind protocol_CDI <ButtonPress-1> [mymethod _ReadCDI %x %y]
        $hull tag bind protocol_CDI <ButtonPress-2> {}
        $hull tag bind protocol_MemoryConfig <ButtonPress-1> [mymethod _MemoryConfig %x %y]
        $hull tag bind protocol_MemoryConfig <ButtonPress-2> {}
        update idle
        $transport SendVerifyNodeID
        install readCDIProgress using ReadCDIProgress $win.readCDIProgress -parent $win
    }
    method Refresh {} {
        $hull delete [$hull children {}]
        set mynid [$transport cget -nid]
        $hull insert {} end -id $mynid -text $mynid -open no
        $self _insertSimpleNodeInfo $mynid [$transport ReturnMySimpleNodeInfo]
        $self _insertSupportedProtocols $mynid [$transport ReturnMySupportedProtocols]
        $transport SendVerifyNodeID
    }
    method messageHandler {message} {
        ## Message handler -- handle incoming messages.
        #
        # Initialization Complete Messages -- Insert a node id entry in the 
        #                                     tree view.
        #                                     A SimpleNodeInfoRequest is also 
        #                                     sent to the new node.
        # Verified Node ID -- Insert a node id entry in the tree view.
        #                     A SimpleNodeInfoRequest is also sent to the
        #                     new node.
        # Protocol Support Reply -- Insert the Supported Protocols for the 
        #                     node.
        # Simple Node Information Reply -- Insert the  Simple Node Information
        #                     Then send a Protocol Support Inquiry to the 
        #                     node.
        # All other messages are not processed.
        
        putdebug [format "*** $self messageHandler: mti is 0x%04X" [$message cget -mti]]
        switch [format {0x%04X} [$message cget -mti]] {
            0x0100 -
            0x0101 -
            0x0170 -
            0x0171 {
                #* Verified Node ID & Initialization Complete messages.
                set nid [eval [list format {%02X:%02X:%02X:%02X:%02X:%02X}] \
                         [$message cget -data]]
                if {![$hull exists $nid]} {
                    # I'm fine, how are you?
                    # (Nice to meet you, my name is...)
                    $transport SendMyNodeVerifcation
                    $hull insert {} end -id $nid -text $nid -open no
                    $transport SendSimpleNodeInfoRequest $nid
                }
            }
            0x0668 {
                #* Protocol Support Reply
                set report [$message cget -data]
                set nid    [$message cget -sourcenid]
                $self _insertSupportedProtocols $nid $report
            }
            0x0A08 {
                #* Simple Node Information Reply
                set payload [$message cget -data]
                set nid     [$message cget -sourcenid]
                $self _insertSimpleNodeInfo $nid $payload
                $transport SendSupportedProtocolsRequest $nid
            }
            default {
            }
        }
    }
    typemethod setdebug {flag} {
        ## Set debug flag
        # @param flag Debug flag value
        
        set _debug $flag
    }
    
    method _insertSimpleNodeInfo {nid infopayload} {
        ## @privatesection Insert the SimpleNodeInfo for nid into the tree view.

        putdebug "*** $self _insertSimpleNodeInfo $nid $infopayload"
        $hull insert $nid end -id ${nid}_simplenodeinfo \
              -text {Simple Node Info} \
              -open no
        set strings1 [lindex $infopayload 0]
        if {$strings1 == 1} {set strings1 4}
        set i 1
        set names1 {manufact model hvers svers}
        set formats1 [list \
                      [_ "Manfacturer: %s"] \
                      [_ "Model: %s"] \
                      [_ "Hardware Version: %s"] \
                      [_ "Software Version: %s"]]
        for {set istring 0} {$istring < $strings1} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                putdebug "*** $self _insertSimpleNodeInfo: strings1: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                $hull insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names1 $istring] \
                      -text [_ [lindex $formats1 $istring] $s] \
                      -open no
            }
            incr i
        }
        if {$i >= [llength $infopayload]} {return}
        set strings2 [lindex $infopayload $i]
        if {$strings2 == 1} {set strings2 2}
        # If version 1, then 2 strings (???), other wise version == number of strings
        incr i
        set names2 {name descr}
        set formats2 [list [_ "Name: %s"] [_ "Description: %s"]]
        for {set istring 0} {$istring < $strings2} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                putdebug "*** $self _insertSimpleNodeInfo: strings2: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                $hull insert ${nid}_simplenodeinfo end \
                      -id ${nid}_simplenodeinfo_[lindex $names2 $istring] \
                      -text [_ [lindex $formats2 $istring] $s] \
                      -open no
                if {[lindex $names2 $istring] eq "name"} {
                    $hull item ${nid} -text [format "%s (%s)" $nid $s]
                }
            }
            incr i
        }
        putdebug "*** $self _insertSimpleNodeInfo: done"
    }
    method _insertSupportedProtocols {nid report} {
        #* Insert Supported Protocols if node into tree view.
        
        if {[llength $report] < 3} {lappend report 0 0 0}
        if {[llength $report] > 3} {set report [lrange $report 0 2]}
        set protocols [lcc::OpenLCBProtocols GetProtocolNames $report]
        putdebug "*** $self _insertSupportedProtocols $nid $report"
        
        putdebug "*** $self _insertSupportedProtocols: protocols are $protocols"
        if {[llength $protocols] > 0} {
            $hull insert $nid end -id ${nid}_protocols \
                 -text {Protocols Supported} \
                 -open no
            foreach p $protocols {
                putdebug [list *** $self _insertSupportedProtocols: p = $p]
                $hull insert ${nid}_protocols end \
                      -id ${nid}_protocols_$p \
                      -text [lcc::OpenLCBProtocols ProtocolLabelString $p] \
                      -open no \
                      -tag protocol_$p
            }
        }
    }
    variable _datagramdata;# Datagram data buffer. 
    variable _currentnid;  # Node ID of the node we currently expect 
    # datagrams from.
    variable _iocomplete;  # I/O completion flag.
    method _datagramHandler {command sourcenid args} {
        #* Datagram handler.

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
    #* CDI text for nodes (indexed by Node IDs).
    variable CDIs_text -array {}
    #* CDI parsed XML trees (indexed by Node IDs).
    variable CDIs_xml  -array {}
    #* CDI Forms (indexed by Node IDs).
    variable CDIs_FormTLs -array {}
    #* Button lock
    variable buttonLock no
    method _ReadCDI {x y} {
        #* Read in a CDI for the node at x,y
        
        if {$buttonLock} {return}
        set buttonLock yes
        putdebug "*** $self _ReadCDI $x $y"
        set id [$hull identify row $x $y]
        putdebug "*** $self _ReadCDI: id = $id"
        set nid [regsub {_protocols_CDI} $id {}]
        putdebug "*** $self _ReadCDI: nid = $nid"
        putdebug "*** $self _ReadCDI: \[info exists CDIs_text($nid)\] => [info exists CDIs_text($nid)]"
        if {![info exists CDIs_text($nid)] ||
            $CDIs_text($nid) eq "" || ![info exists CDIs_xml($nid)] ||
            $CDIs_xml($nid) eq {} || ![info exists CDIs_FormTLs($nid)] ||
            $CDIs_FormTLs($nid) eq {}} {
            if {[info exists CDIs_FormTLs($nid)] && 
                [winfo exists $CDIs_FormTLs($nid)]} {
                catch {destory $CDIs_FormTLs($nid)}
            }
            putdebug "*** $self _ReadCDI: Going to read CDI for $nid"
            $transport configure -datagramhandler [mymethod _datagramHandler]
            set data [list 0x20 0x84 0x0FF]
            set _iocomplete 0
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [myvar _iocomplete]
            $transport configure -datagramhandler {}
            catch {unset _currentnid}
            hexdump [format "*** %s _ReadCDI: datagram received (Get Address Space Information): " $self] $_datagramdata
            set present [expr {[lindex $_datagramdata 1] == 0x87}]
            putdebug "*** $self _ReadCDI: present is $present"
            if {!$present} {
                putdebug "*** $self _ReadCDI: CDI not present?"
                tk_messageBox -icon warning \
                      -message [_ "CDI is not present for %s!" $nid] \
                      -type ok
                return
            }
            putdebug "*** $self _ReadCDI: CDI present..."
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
            putdebug [format {*** %s _ReadCDI: lowest = %08X} $self $lowest]
            putdebug [format {*** %s _ReadCDI: highest = %08X} $self $highest]
            set start $lowest
            #set end   [expr {$highest + 64}]
            set end $highest
            set CDIs_text($nid) {}
            set EOS_Seen no
            $readCDIProgress withdraw
            $readCDIProgress draw -parent $win -totalbytes [expr {$end - $start}]
            for {set address $start} {!$EOS_Seen} {incr address $size} {
                # Always read 64 bytes, even if this means reading past the 
                # "end".
                set size 64
                set data [list 0x20 0x43 \
                          [expr {($address & 0xFF000000) >> 24}] \
                          [expr {($address & 0xFF0000) >> 16}] \
                          [expr {($address & 0xFF00) >> 8}] \
                          [expr {$address & 0xFF}] \
                          $size]
                $transport configure -datagramhandler [mymethod _datagramHandler]
                set _iocomplete 0
                set _currentnid $nid
                $transport SendDatagram $nid $data
                vwait [myvar _iocomplete]
                $transport configure -datagramhandler {}
                catch {unset _currentnid}
                putdebug [format {*** %s _ReadCDI: address = %08X} $self $address]
                hexdump [format "*** %s _ReadCDI: datagram received: " $self] $_datagramdata
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
                            if {$b == 0} {
                                set EOS_Seen yes
                                break
                            }
                            append CDIs_text($nid) [format {%c} $b]
                            incr count
                            if {$count >= $size} {break}
                        }
                    } else {
                        # ??? (bad return address)
                        set EOS_Seen yes
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
                    set EOS_Seen yes
                }
                $readCDIProgress Update [expr {($address + $size)-$start}]
            }
            $readCDIProgress Done
            putdebug [format {*** %s _ReadCDI: Last address block was at: = %08X} $self $address]
            if {[catch {ParseXML %AUTO% $CDIs_text($nid)} parsedCDI]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not parse the CDI (1) because %s" $parsedCDI]
                return
            }
            set CDIs_xml($nid) $parsedCDI
            putdebug "*** $self _ReadCDI: CDI XML parsed for $nid: $CDIs_xml($nid)"
            set CDIs_FormTLs($nid) \
                  [lcc::ConfigurationEditor .cdi[regsub -all {:} $nid {}] \
                   -cdi $CDIs_xml($nid) -nid $nid -transport $transport \
                   -debugprint [myproc putdebug] \
                   -layoutdb [$self cget -layoutdb]]
            putdebug "*** $self _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
        } else {
            putdebug "*** $self _ReadCDI: CDI Form Toplevel: $CDIs_FormTLs($nid)"
            wm deiconify $CDIs_FormTLs($nid)
        }
        set buttonLock no
    }
    method _ViewCDI {} {
        set cdifile [tk_getOpenFile -defaultextension .xml \
                     -filetypes { {{XML Files} {.xml} }
                                  {{Text Files} {.txt} }
                                  {{All Files} * } } \
                     -initialdir [pwd] \
                     -initialfile cdi.xml \
                     -parent . \
                     -title "Select a CDI XML file to display"]
        if {$cdifile eq {}} {return}
        if {[catch {open $cdifile r} infp]} {
            tk_messageBox -type ok -icon error \
                  -message [_ "Could not open %s because %s" $cdifile $infp]
            return
        }
        set CDIs_text($cdifile) [read $infp]
        close $infp
        if {[catch {ParseXML %AUTO% $CDIs_text($cdifile)} parsedCDI]} {
            tk_messageBox -type ok -icon error \
                  -message [_ "Could not parse the CDI (3) because %s" $parsedCDI]
            return
        }
        set CDIs_xml($cdifile) $parsedCDI
        if {[info exists CDIs_FormTLs($cdifile)] && 
            [winfo exists $CDIs_FormTLs($cdifile)]} {
            destroy $CDIs_FormTLs($cdifile)
        }
        set CDIs_FormTLs($cdifile) \
              [lcc::ConfigurationEditor \
               .cdi[regsub -all {.} [file tail $cdifile] {}]%AUTO% \
               -cdi $CDIs_xml($cdifile) \
               -displayonly true \
               -debugprint [myproc putdebug]]
    }
    method _MemoryConfig {x y} {
        #* Configure the memory for the node at x,y
        
        if {$buttonLock} {return}
        set buttonLock yes
        putdebug "*** $self _MemoryConfig $x $y"
        set id [$hull identify row $x $y]
        putdebug "*** $self _MemoryConfig: id = $id"
        set nid [regsub {_protocols_MemoryConfig} $id {}]
        putdebug "*** $self _MemoryConfig: nid = $nid"
        set count 10
        $transport configure -datagramhandler [mymethod _datagramHandler]
        set _iocomplete 0
        while {$count > 0 && $_iocomplete <= 0} {
            set _iocomplete 0
            set data [list 0x20 0x80]
            set _currentnid $nid
            $transport SendDatagram $nid $data
            vwait [myvar _iocomplete]
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
              -name "$name" \
              -debugprint [myproc putdebug]
        lcc::ConfigMemory .configmem[regsub {:} $nid {}]%AUTO% \
              -destnid $nid \
              -transport $transport \
              -debugprint [myproc putdebug]
        set buttonLock no
    }
    
        
    
}

package provide LCCNodeTree 1.0
