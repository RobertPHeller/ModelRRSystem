#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Fri Nov 29 10:48:40 2024
#  Last Modified : <241202.1037>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
## @copyright
#    Copyright (C) 2024  Robert Heller D/B/A Deepwoods Software
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
# @file LCCNodeTable.tcl
# @author Robert Heller
# @date Fri Nov 29 10:48:40 2024
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
package require ReadCDIProgress
package require ScrollWindow

snit::widget NodeDisplayPopup {
    hulltype toplevel
    widgetclass NodeDisplayPopup
    
    component name
    component description
    component nodeID
    component manufact
    component model
    component hvers
    component svers
    component protocols
    component dismisbutton
    
    option -nid -default {00:00:00:00:00:00} -type lcc::nid \
          -configuremethod _SetNID
    option -manufacturer -default {} -configuremethod _SetManufact
    option -model -default {} -configuremethod _SetModel
    option -hardware -default {} -configuremethod _SetHardware
    option -software -default {} -configuremethod _SetSoftware
    option -protocols -default [list] -configuremethod _SetProtocols
    option -name -default {} -configuremethod _SetName
    option -description -default {} -configuremethod _SetDescription
    
    option -style -default NodeDisplayPopup
    option -parent -default .
    method _SetNID {option value} {
        $nodeID configure -text "$value"
        wm title $win "LCC Node: $value"
        set options($option) "$value"
    }
    method _SetManufact {option value} {
        $manufact configure -text "$value"
        set options($option) "$value"
    }
    method _SetModel {option value} {
        $model configure -text "$value"
        set options($option) "$value"
    }
    method _SetHardware {option value} {
        $hvers configure -text "$value"
        set options($option) "$value"
    }
    method _SetSoftware {option value} {
        $svers configure -text "$value"
        set options($option) "$value"
    }
    method _SetProtocols {option value} {
        $protocols delete [$protocols children {}]
        foreach p $value {
            $protocols insert {} end -values [list $p]
        }
        set options($option) "$value"
    }
    method _SetName {option value} {
        $name configure -text "$value"
        set options($option) "$value"
    }
    method _SetDescription {option value} {
        $description configure -text "$value"
        set options($option) "$value"
    }
    
    method _themeChanged {} {
        foreach option {-activebackground -activeforeground -anchor -background 
            -borderwidth -cursor -disabledforeground -foreground 
            -highlightbackground -highlightcolor -highlightthickness 
            -padx -pady -takefocus} {
            set value [ttk::style lookup $options(-style) $option]
            catch [list $win configure $option "$value"]    
            catch [list $dismisbutton configure $option "$value"]
            catch [list $name configure $option "$value"]
            catch [list $description configure $option "$value"]
            catch [list $nodeID configure $option "$value"]
            catch [list $manufact configure $option "$value"]
            catch [list $model configure $option "$value"]
            catch [list $hvers configure $option "$value"]
            catch [list $svers configure $option "$value"]
            catch [list $protocols configure $option "$value"]
        }
    }
    constructor {args} {
        wm withdraw $win
        set lframe [ttk::labelframe $win.nameframe -labelanchor nw \
                    -text [_m "Label|Name:"]]
        pack $lframe -expand yes -fill x
        install name using ttk::label $lframe.name
        pack $name -fill x
        set lframe [ttk::labelframe $win.descriptionframe -labelanchor nw \
                    -text [_m "Label|Description:"]]
        pack $lframe -expand yes -fill x
        install description using ttk::label $lframe.description
        pack $description -fill x
        set lframe [ttk::labelframe $win.nodeIDframe -labelanchor nw \
                    -text [_m "Label|Node ID:"]]
        pack $lframe -expand yes -fill x
        install nodeID using ttk::label $lframe.nodeID
        pack $nodeID -fill x
        set lframe [ttk::labelframe $win.manufactframe -labelanchor nw \
                    -text [_m "Label|Manufacturer:"]]
        pack $lframe -expand yes -fill x
        install manufact using ttk::label $lframe.manufact
        pack $manufact -fill x
        set lframe [ttk::labelframe $win.modelframe -labelanchor nw \
                    -text [_m "Label|Model:"]]
        pack $lframe -expand yes -fill x
        install model using ttk::label $lframe.model
        pack $model -fill x
        set lframe [ttk::labelframe $win.hversframe -labelanchor nw \
                    -text [_m "Label|Hardware:"]]
        pack $lframe -expand yes -fill x
        install hvers using ttk::label $lframe.hvers
        pack $hvers -fill x
        set lframe [ttk::labelframe $win.sversframe -labelanchor nw \
                    -text [_m "Label|Software:"]]
        pack $lframe -expand yes -fill x
        install svers using ttk::label $lframe.svers
        pack $svers -fill x
        set lframe [ttk::labelframe $win.protocolsframe -labelanchor nw \
                    -text [_m "Label|Supported Protocols:"]]
        pack $lframe -expand yes -fill x
        set scrollw [ScrolledWindow $lframe.scrollw -scrollbar vertical \
                     -auto vertical]
        pack $scrollw -expand yes  -fill x
        install protocols using ttk::treeview [$scrollw getframe].protocols \
                           -columns {protocol} -displaycolumns {protocol} \
                           -show {}
        $scrollw setwidget $protocols
        install dismisbutton using ttk::button $win.dismisbutton \
              -default active \
              -text [_m "Button|Dismis"] \
              -command [mymethod _Dismis]
        pack $dismisbutton -fill x
        $self configurelist $args
        wm transient $win [$self cget -parent]
        $type push availlist $self
        bind <Return> $win [list $dismisbutton invoke]
        bind <Esc> $win [list $dismisbutton invoke]
        wm protocol $win WM_DELETE_WINDOW [list $dismisbutton invoke]
        bind <<ThemeChanged>> $win [mymethod _themeChanged]
        $self _themeChanged
    }
    
    method _Dismis {} {
        wm withdraw $win
        $type remove inuselist $self
        $type push   availlist $self
    }
    method draw {args} {
        $self configurelist $args
        update idle
        set x [expr {[winfo screenwidth $win]/2 - ([winfo reqwidth $win])/2 \
               - [winfo vrootx $win]}]
        set y [expr {[winfo screenheight $win]/2 - [winfo reqheight $win]/2 \
               - [winfo vrooty $win]}]
        if {$x < 0} {set x 0}
        if {$y < 0} {set y 0}
        wm geom $win =450x500+$x+$y
        wm transient $win [$self cget -parent]
        wm deiconify $win
        $type push inuselist $self
    }

    typemethod draw {args} {
        if {[$type length availlist] == 0} {
            $type create .[string tolower [lindex [split $type :] end]]%AUTO%
        }
        set object [$type pop availlist]
        #    puts stderr "*** ${type}::typemethod draw: object = $object"
        $object draw {*}$args
        return $object
    }

    destructor {
        $type remove availlist $self
        $type remove inuselist $self
    }

    typevariable availlist {}
    typevariable inuselist {}

    typemethod _CheckList {list} {
        if {[lsearch -exact {availlist inuselist} $list] < 0} {
            error "No such list: $list"
        }
    }

    typemethod push {list object} {
        $type _CheckList $list
        if {![$type member $list $object]} {
            lappend $list $object
        }
    }

    typemethod pop {list} {
        $type _CheckList $list
        if {[$type length $list] > 0} {
            #      puts stderr "*** ${type}::typemethod pop: list = $list ([set [set list]])"
            set object [lindex [set [set list]] 0]
            #      puts stderr "*** ${type}::typemethod pop: object = $object"
            set $list  [lrange [set [set list]] 1 end]
            #      puts stderr "*** ${type}::typemethod pop: list = $list ([set [set list]])"
        } else {
            set object {}
        }
        return $object
    }
    
    typemethod member {list object} {
        $type _CheckList $list 
        if {[lsearch -exact [set [set list]] $object] < 0} {
            return 0
        } else {
            return 1
        }
    }
    
    typemethod length {list} {
        $type _CheckList $list 
        return [llength [set [set list]]]
    }
    
    typemethod remove {list object} {
        $type _CheckList $list 
        set index [lsearch -exact [set [set list]] $object]
        if {$index < 0} {
            # nothing
        } elseif {$index == 0} {
            set $list [lrange [set [set list]] 1 end]
        } else {
            set $list [lreplace [set [set list]] $index $index]
        }
    }
}

snit::widgetadaptor LCCNodeTable {
    ## @brief LCC Node Table Widget
    # This is the LCC Node Table Widget, which lists the nodes on the 
    # OpenLCB network.
    #
    # Options: 
    # @arg -transport The OpenLCB transport object.
    # @arg -layoutdb  The layout DB
    #
    # @par
    
    typevariable nodetable_cols {nodeid manufact model hvers svers protocols configure name description};# Columns
    ## @privatesection Columns.
    typevariable nodetable_dispcols {name nodeid manufact model svers configure};# displayed columns
    ## Displayed columns.
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
    delegate method * to hull except {bbox cget column configure 
        delete detach exists insert move next parent prev set 
        state tag}
    
    
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
        ## @publicsection Construct a LCC Node Table
        
        putdebug "*** $type create $self $args"
        installhull using ttk::treeview -columns $nodetable_cols \
              -displaycolumns $nodetable_dispcols -selectmode browse \
              -show headings
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
        $hull heading name -text [_m "Label|Name"]
        $hull heading nodeid -text [_m "Label|Node Id"]
        $hull heading manufact -text [_m "Label|Manufacturer"]
        $hull heading model -text [_m "Label|Model"]
        $hull heading svers -text [_m "Label|Software"]
        $hull heading configure -text [_m "Label|Configure"]
        set mynid [$transport cget -nid]
        $hull insert {} end -id $mynid -values [list $mynid] \
              -tags [list itemselect]
        $self _insertSimpleNodeInfo $mynid [$transport ReturnMySimpleNodeInfo]
        $self _insertSupportedProtocols $mynid [$transport ReturnMySupportedProtocols]
        $hull tag bind protocol_CDI <ButtonPress-1> [mymethod _ReadCDI %x %y]
        $hull tag bind protocol_CDI <ButtonPress-2> {}
        $hull tag bind itemselect <ButtonPress-3>  [mymethod _itemselect %x %y %X %Y]
        update idle
        $transport SendVerifyNodeID
        install readCDIProgress using ReadCDIProgress $win.readCDIProgress -parent $win
    }
    typemethod DisplayNode {nodeid manufact model hvers svers protocols {configure {}} {name {}} {description {}}} {
        NodeDisplayPopup draw \
              -nid $nodeid \
              -manufacturer $manufact \
              -model $model \
              -hardware $hvers \
              -software $svers \
              -protocols $protocols \
              -name $name \
              -description $description
    }
    method _itemselect {x y rootX rootY} {
        #* Id node at x,y
        
        putdebug [format "*** $self _itemselect %d %d %d %d" $x $y $rootX $rootY]
        set id [$hull identify row $x $y]
        putdebug "*** $self _itemselect: id = $id"
        LCCNodeTable DisplayNode {*}[$hull item $id -values]
    }
    method Refresh {} {
        $hull delete [$hull children {}]
        set mynid [$transport cget -nid]
        $hull insert  {} end -id $mynid -values [$mynid]
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
                    $hull insert {} end -id $nid -values [list $nid] \
                          -tags [list itemselect]
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
        set strings1 [lindex $infopayload 0]
        if {$strings1 == 1} {set strings1 4}
        set i 1
        set names1 {1 2 3 4}
        for {set istring 0} {$istring < $strings1} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                #putdebug "*** $self _insertSimpleNodeInfo: strings1: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                set values [$hull item $nid -values]
                set indx [lindex $names1 $istring]
                while {[llength $values] <= $indx} {lappend values {}}
                set values [lreplace $values $indx $indx $s]
                $hull item $nid -values $values
            }
            incr i
        }
        if {$i >= [llength $infopayload]} {return}
        set strings2 [lindex $infopayload $i]
        if {$strings2 == 1} {set strings2 2}
        # If version 1, then 2 strings (???), other wise version == number of strings
        incr i
        set names2 {7 8}
        for {set istring 0} {$istring < $strings2} {incr istring} {
            set s ""
            while {[lindex $infopayload $i] != 0} {
                set c [lindex $infopayload $i]
                #putdebug "*** $self _insertSimpleNodeInfo: strings2: i = $i, c = '$c'"
                if {$c eq ""} {break}
                append s [format %c $c]
                incr i
            }
            if {$s ne ""} {
                set values [$hull item $nid -values]
                set indx [lindex $names2 $istring]
                while {[llength $values] <= $indx} {lappend values {}}
                set values [lreplace $values $indx $indx $s]
                $hull item $nid -values $values
            }
            incr i
        }
        #putdebug "*** $self _insertSimpleNodeInfo: done"
    }
    method _insertSupportedProtocols {nid report} {
        #* Insert Supported Protocols if node into tree view.
        
        if {[llength $report] < 3} {lappend report 0 0 0}
        if {[llength $report] > 3} {set report [lrange $report 0 2]}
        set protocols [lcc::OpenLCBProtocols GetProtocolNames $report]
        set values [$hull item $nid -values]
        set indx 5
        while {[llength $values] <= $indx} {lappend values {}}
        set values [lreplace $values $indx $indx $protocols]
        $hull item $nid -values $values
        putdebug "*** $self _insertSupportedProtocols $nid $report"
        putdebug "*** $self _insertSupportedProtocols: protocols are $protocols"
        if {[lsearch -exact $protocols [_m "Label|CDI"]] >= 0} {
            set values [$hull item $nid -values]
            set indx 6
            set s [_m "Label|Configure"]
            while {[llength $values] <= $indx} {lappend values {}}
            set values [lreplace $values $indx $indx $s]
            $hull item $nid -values $values
            $hull item $nid -tag [concat protocol_CDI [$hull item $nid -tag]]
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




package provide LCCNodeTable 1.0
