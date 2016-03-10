#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Mar 3 14:38:10 2016
#  Last Modified : <160310.1530>
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


package require Tk
package require tile
package require snit
package require Dialog
package require LCC

namespace eval lcc {
    ## 
    # @section ConfigDialogs Package provided
    #
    # ConfigDialogs 1.0
    
    snit::widgetadaptor ConfigOptions {
        ## Display memory config options.
        #
        # Options
        # @arg -nid Node ID.
        # @arg -available Available bitmask.
        # @arg -writelengths Write length bitmask.
        # @arg -highest Highest memory space.
        # @arg -lowest Lowest memory space.
        # @arg -name Name string.
        # @par
        
        component nodeid
        ## @privatesection Node ID.
        component available
        ## Available bits.
        component writelengths
        ## Write lengths.
        component highest
        ## Highest memory space.
        component lowest
        ## Lowest memory space.
        component name
        ## Name string.
        
        option -nid -readonly yes -type lcc::nid -default 00:00:00:00:00:00
        option -available -readonly yes -type lcc::sixteenbits -default 0x0000
        option -writelengths -readonly yes -type lcc::byte -default 0x00
        option -highest -readonly yes -type lcc::byte -default 0xFF
        option -lowest -readonly yes -type lcc::byte -default 0xFD
        option -name -readonly yes -default ""
        
        constructor {args} {
            ## @publicsection Construct a Config Options dialog.
            #
            # @param name The widget pathname.
            # @param ... Options:
            # @arg -nid Node ID.
            # @arg -available Available bitmask.
            # @arg -writelengths Write length bitmask.
            # @arg -highest Highest memory space.
            # @arg -lowest Lowest memory space.
            # @arg -name Name string.
            # @par
            
            installhull using Dialog -separator 0 \
                  -modal none -parent . -place center \
                  -side bottom -title {Memory Configuration Options} \
                  -transient 1 -anchor e \
                  -class ConfigOptions
            $hull add close -text Close -underline 0 -command [mymethod _Close]
            $self configurelist $args
            set dframe [$hull getframe]
            install nodeid using LabelEntry $dframe.nodeid \
                  -label "Node ID:" -text [$self cget -nid] -editable no
            pack $nodeid -fill x
            install available using LabelFrame $dframe.available \
                  -text "Available Commands:"
            pack $available -fill x
            set avail [$self cget -available]
            pack [ttk::label [$available getframe].bits \
                  -text [format {0x%04X} $avail] \
                  -relief sunken] -side left -fill x -anchor w
            if {($avail & 0x8000) != 0} {
                pack [ttk::label [$available getframe].wmask -text "Write under mask."] -fill x
            }
            if {($avail & 0x4000) != 0} {
                pack [ttk::label [$available getframe].unalignedread -text "Unaligned Reads supported."] -fill x
            }
            if {($avail & 0x2000) != 0} {
                pack [ttk::label [$available getframe].unalignedwrite -text "Unaligned Writes supported."] -fill x
            }
            if {($avail & 0x800) != 0} {
                pack [ttk::label [$available getframe].readFC -text "Read from address space 0xFC available."] -fill x
            }
            if {($avail & 0x400) != 0} {
                pack [ttk::label [$available getframe].readFB -text "Read from address space 0xFB available."] -fill x
            }
            if {($avail & 0x200) != 0} {
                pack [ttk::label [$available getframe].writeFB -text "Write to address space 0xFB available."] -fill x
            }
            install writelengths using LabelFrame $dframe.writelengths \
                  -text "Write Lengths:"
            pack $writelengths -fill x
            set wlen [$self cget -writelengths]
            pack [ttk::label [$writelengths getframe].bits \
                  -text [format {0x%02X} $wlen] \
                  -relief sunken] -side left -fill x -anchor w
            if {($wlen & 0x80) != 0} {
                pack [ttk::label [$writelengths getframe].b1 -text "1 byte writes."] -fill x
            }
            if {($wlen & 0x40) != 0} {
                pack [ttk::label [$writelengths getframe].b2 -text "2 byte writes."] -fill x
            }
            if {($wlen & 0x20) != 0} {
                pack [ttk::label [$writelengths getframe].b4 -text "4 byte writes."] -fill x
            }
            if {($wlen & 0x10) != 0} {
                pack [ttk::label [$writelengths getframe].b64 -text "64 byte writes."] -fill x
            }
            if {($wlen & 0x02) != 0} {
                pack [ttk::label [$writelengths getframe].arb -text "arbitary write of any length."] -fill x
            }
            if {($wlen & 0x01) != 0} {
                pack [ttk::label [$writelengths getframe].stream -text "stream writes supported."] -fill x
            }
            install highest using LabelEntry $dframe.highest \
                  -label "Highest address space: " \
                  -text [format {%02X} [$self cget -highest]] \
                  -editable no
            pack $highest -fill x
            install lowest using LabelEntry $dframe.lowest \
                  -label "Lowest address space: " \
                  -text [format {%02X} [$self cget -lowest]] \
                  -editable no
            pack $lowest -fill x
            if {"[$self cget -name]" ne {}} {
                install name using LabelEntry $dframe.name \
                      -label "Name string: " \
                      -text "[$self cget -name]" \
                      -editable no
                pack $name -fill x
            }
            $hull draw
        }
        method _Close {} {
            destroy $win
        }
    }
    snit::widgetadaptor ConfigMemory {
        ## Configure memory.
        #
        # Options:
        # @arg -destnid Node ID to send to.
        # @arg -transport LCC Transport object.
        # @par
        
        component readlist
        ## @privatesection Read list.
        component writelist
        ## Write list
        component count
        ## Byte count
        component address
        ## Start address
        component space
        ## Space select
        
        option -destnid -readonly yes -type lcc::nid -default 00:00:00:00:00:00
        option -transport -readonly yes -default {}
        variable _ioComplete
        ## I/O Completion Flag.
        variable olddatagramhandler {}
        variable datagrambuffer {}
        variable _datagramrejecterror 0
        variable writeReplyCheck no
        method _datagramhandler {command sourcenid args} {
            set data $args
            switch $command {
                datagramcontent {
                    if {$sourcenid ne [$self cget -destnid]} {
                        if {$olddatagramhandler eq {}} {
                            [$self cget -transport] DatagramRejected $sourcenid 0x1000
                        } else {
                            uplevel #0 $olddatagramhandler $command $sourcenid $data
                        }
                    }
                    [$self cget -transport] DatagramReceivedOK $sourcenid
                    set datagrambuffer $data
                    incr _ioComplete
                }
                datagramreceivedok {
                    if {$sourcenid ne [$self cget -destnid]} {
                        if {$olddatagramhandler ne {}} {
                            uplevel #0 $olddatagramhandler $command $sourcenid $data
                        }
                    } else {
                        if {!$writeReplyCheck} {return}
                        if {[llength $data] == 1} {
                            set flags [lindex $data 0]
                        } else {
                            set flags 0
                        }
                        if {($flags & 0x80) == 0} {
                            incr _ioComplete;# no WriteReply pending -- write is presumed to be OK
                        }
                    }
                }
                datagramrejected {
                    if {$sourcenid ne [$self cget -destnid]} {
                        if {$olddatagramhandler ne {}} {
                            uplevel #0 $olddatagramhandler $command $sourcenid $data
                        }
                    } else {
                        # datagram rejected
                        set _datagramrejecterror [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                        incr _ioComplete -1 ;# no further messages expected
                    }
                }
            }
        }
        method _readmemory {_space _address length status_var} {
            lcc::byte validate $_space
            lcc::sixteenbits validate $_address
            lcc::length validate $length
            upvar $status_var status
            
            set data [list 0x20]
            set spacein6 no
            if {$_space == 0xFD} {
                lappend data 0x41
            } elseif {$_space == 0xFE} {
                lappend data 0x42
            } elseif {$_space == 0xFF} {
                lappend data 0x43
            } else {
                lappend data 0x40
                set spacein6 yes
            }
            lappend data [expr {($_address & 0xFF000000) >> 24}]
            lappend data [expr {($_address & 0x00FF0000) >> 16}]
            lappend data [expr {($_address & 0x0000FF00) >>  8}]
            lappend data [expr {($_address & 0x000000FF) >>  0}]
            if {$spacein6} {lappend data $_space}
            lappend data $length
            set _ioComplete 0
            set writeReplyCheck no
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            if {$_ioComplete < 0} {
                ## datagram rejected message received
                # code in_datagramrejecterror
                return {}
            }
            set status [lindex $datagrambuffer 1]
            set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
            set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
            if {$respaddr != $_address} {
                ## wrong address...
            }
            if {$status == 0x50 || $status == 0x58} {
                set respspace [lindex $datagrambuffer 6]
                set dataoffset 7
            } else {
                set dataoffset 6
                if {$status == 0x51 || $status == 0x59} {
                    set respspace 0xFD
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x52  || $status == 0x5A} {
                    set respspace 0xFE
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x53  || $status == 0x5B} {
                    set respspace 0xFF
                    set status [expr {$status & 0xF8}]
                }
            }
            if {$respspace != $_space} {
                ## wrong space ...
            }
            set data [lrange $datagrambuffer $dataoffset end]
            if {$status == 0x50} {
                if {[llength $data] > $length} {
                    set data [lrange $data 0 [expr {$length - 1}]]
                }
                return $data
            } else {
                return 
            }
        }
        method _writememory {_space _address databuffer} {
            lcc::byte validate $_space
            lcc::sixteenbits validate $_address
            lcc::databuf validate $databuffer

            set data [list 0x20]
            set spacein6 no
            if {$_space == 0xFD} {
                lappend data 0x01
            } elseif {$_space == 0xFE} {
                lappend data 0x02
            } elseif {$_space == 0xFF} {
                lappend data 0x03
            } else {
                lappend data 0x00
                set spacein6 yes
            }
            lappend data [expr {($_address & 0xFF000000) >> 24}]
            lappend data [expr {($_address & 0x00FF0000) >> 16}]
            lappend data [expr {($_address & 0x0000FF00) >>  8}]
            lappend data [expr {($_address & 0x000000FF) >>  0}]
            if {$spacein6} {lappend data $_space}
            foreach b $databuffer {lappend data $b}
            set datagrambuffer {}
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            if {$_ioComplete < 0} {
                ## datagram rejected message received
                # code in _datagramrejecterror
                return $_datagramrejecterror
            } elseif {$datagrambuffer eq {}} {
                ## No write reply -- assume the write succeeded
                return 0
            }
            set status [lindex $datagrambuffer 1]
            set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
            set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
            if {$respaddr != $_address} {
                ## wrong address...
            }
            if {$status == 0x10 || $status == 0x18} {
                set respspace [lindex $datagrambuffer 6]
                set dataoffset 7
            } else {
                set dataoffset 6
                if {$status == 0x11 || $status == 0x19} {
                    set respspace 0xFD
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x12  || $status == 0x1A} {
                    set respspace 0xFE
                    set status [expr {$status & 0xF8}]
                } elseif {$status == 0x13  || $status == 0x1B} {
                    set respspace 0xFF
                    set status [expr {$status & 0xF8}]
                }
            }
            if {$respspace != $_space} {
                ## wrong space ...
            }
            return [lrange $datagrambuffer $dataoffset end]
        }
        
        constructor {args} {
            ## @publicsection Construct a memory config dialog.
            #
            # @param name Pathname of the widget.
            # @param ... Options:
            # @arg -destnid Node ID to send to.
            # @arg -transport LCC Transport object.
            # @par
            
            installhull using Dialog -separator 0 \
                  -modal none -parent . -place center \
                  -side bottom \
                  -title {Configuration R/W Tool 00:00:00:00:00:00} \
                  -transient 1 -anchor e \
                  -class ConfigMemory
            $hull add close -text Close -underline 0 -command [mymethod _Close]
            $hull add read  -text Read  -underline 0 -command [mymethod _Read]
            $hull add write -text Write -underline 0 -command [mymethod _Write]
            if {[lsearch $args -transport] < 0} {
                error [_ "The -transport option is required!"]
            }
            if {[lsearch $args -destnid] < 0} {
                error [_ "The -destnid option is required!"]
            }
            $self configurelist $args
            $hull configure -title \
                  [_ "Configuration R/W Tool %s" [$self cget -destnid]]
            wm title [winfo toplevel $win] [_ "Configuration R/W Tool %s" [$self cget -destnid]]
            set dframe [$hull getframe]
            install readlist using LabelEntry $dframe.readlist \
                  -label "Read:" -editable no
            pack $readlist -fill x
            install writelist using LabelEntry $dframe.writelist \
                  -label "Write:"
            pack $writelist -fill x
            install count  using LabelEntry $dframe.count \
                  -label "Count:" -text 40
            pack $count  -fill x
            install address using LabelEntry $dframe.address \
                  -label "Address:" -text [format {%06X} 0]
            pack $address -fill x 
            install space using LabelComboBox $dframe.space \
                  -label "Space:" -values {CDI Config All none} -editable no
            pack $space -fill x
            $space set CDI
            $hull draw
        }
        method _Close {} {
            destroy $win
        }
        method _Read {} {
            set _address [scan [$address cget -text] %x]
            set _size    [scan [$count   cget -text] %d]
            if {$_size > 64} {set _size 64}
            if {$_size < 1} {set _size 1}
            switch [$space cget -text] {
                CDI {set _space 0xFF}
                All {set _space 0xFE}
                Config {set _space 0xFD}
                none {set _space 0x00}
            }
            set data [$self _readmemory $_space $_address $_size status]
            if {$status == 0x50} {
                # OK
                if {[llength $data] > $_size} {
                    set data [lrange $data 0 [expr {$_size - 1}]]
                }
                set result {}
                foreach d $data {
                    append result [format {%02X } $d]
                }
                $readlist configure -text $result
            } elseif {$status == 0x58} {
                # Failure
                set errorcode [expr {([lindex $data 0] << 8) | [lindex $data 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
                
            }
        }
        method _Write {} {
            set _address [scan [$address cget -text] %x]
            switch [$space cget -text] {
                CDI {set _space 0xFF}
                All {set _space 0xFE}
                Config {set _space 0xFD}
                none {set _space 0x00}
            }
            set sdata [$writelist cget -text]
            set hbytes [split $sdata { }]
            set data [list]
            foreach hb $hbytes {
                if {$hb eq {}} {continue}
                lappend data [scan $hb "%0x"]
            }
            if {[llength $data] > 64} {
                set data [lrange $data 1 63]
            } elseif {[llength $data] < 1} {
                return
            }
            set retdata [$self _writememory $_space $_address $data]
            if {[llength $retdata] == 1} {
                if {$retdata == 0} {
                    ## OK
                    return
                } else {
                    set errorcode $retdata
                    set errormessage {}
                }
            } else {
                set errorcode [expr {([lindex $retdata 0] << 8) | [lindex $retdata 1]}]
                set errormessage {}
                foreach c [lrange $data 2 end] {
                    if {$c == 0} {break}
                    append errormessage [format %c $c]
                }
            }
            tk_messageBox -type ok -icon error \
                  -message [_ "There was an error: %d (%s)" \
                            $errorcode $errormessage]
        }
    }
}

package provide ConfigDialogs 1.0

