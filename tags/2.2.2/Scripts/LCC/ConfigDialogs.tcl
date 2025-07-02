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
#  Last Modified : <210728.1131>
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
        # @arg -debugprint A function to handle debug output.
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
        option -debugprint -readonly yes -default {}
        
        method putdebug {message} {
            ## Print message using debug output, if any.
            #
            # @param message The message to print.
            
            set debugout [$self cget -debugprint]
            if {$debugout ne ""} {
                uplevel #0 [list $debugout "$message"]
            }
        }
        
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
            # @arg -debugprint A function to handle debug output.
            # @par
            
            installhull using Dialog -separator 0 \
                  -modal none -parent . -place center \
                  -side bottom -title [_ "Memory Configuration Options"] \
                  -transient 1 -anchor e \
                  -class ConfigOptions
            $hull add close -text [_m "Label|Close"] -underline 0 -command [mymethod _Close]
            $self configurelist $args
            set dframe [$hull getframe]
            install nodeid using LabelEntry $dframe.nodeid \
                  -label [_m "Label|Node ID:"] -text [$self cget -nid] -editable no
            pack $nodeid -fill x
            install available using LabelFrame $dframe.available \
                  -text [_m "Label|Available Commands:"]
            pack $available -fill x
            set avail [$self cget -available]
            pack [ttk::label [$available getframe].bits \
                  -text [format {0x%04X} $avail] \
                  -relief sunken] -side left -fill x -anchor w
            if {($avail & 0x8000) != 0} {
            pack [ttk::label [$available getframe].wmask \
                  -text [_ "Write under mask."]] -fill x
            }
            if {($avail & 0x4000) != 0} {
                pack [ttk::label [$available getframe].unalignedread \
                      -text [_ "Unaligned Reads supported."]] -fill x
            }
            if {($avail & 0x2000) != 0} {
                pack [ttk::label [$available getframe].unalignedwrite \
                      -text [_ "Unaligned Writes supported."]] -fill x
            }
            if {($avail & 0x800) != 0} {
                pack [ttk::label [$available getframe].readFC \
                      -text [_ "Read from address space 0xFC available."]] \
                      -fill x
            }
            if {($avail & 0x400) != 0} {
                pack [ttk::label [$available getframe].readFB \
                      -text [_ "Read from address space 0xFB available."]] \
                      -fill x
            }
            if {($avail & 0x200) != 0} {
                pack [ttk::label [$available getframe].writeFB \
                      -text [_ "Write to address space 0xFB available."]] \
                      -fill x
            }
            install writelengths using LabelFrame $dframe.writelengths \
                  -text [_m "Label|Write Lengths:"]
            pack $writelengths -fill x
            set wlen [$self cget -writelengths]
            pack [ttk::label [$writelengths getframe].bits \
                  -text [format {0x%02X} $wlen] \
                  -relief sunken] -side left -fill x -anchor w
            if {($wlen & 0x80) != 0} {
            pack [ttk::label [$writelengths getframe].b1 \
                  -text [_ "1 byte writes."]] -fill x
            }
            if {($wlen & 0x40) != 0} {
                pack [ttk::label [$writelengths getframe].b2 \
                      -text [_ "2 byte writes."]] -fill x
            }
            if {($wlen & 0x20) != 0} {
                pack [ttk::label [$writelengths getframe].b4 \
                      -text [_ "4 byte writes."]] -fill x
            }
            if {($wlen & 0x10) != 0} {
                pack [ttk::label [$writelengths getframe].b64 \
                      -text [_ "64 byte writes."]] -fill x
            }
            if {($wlen & 0x02) != 0} {
                pack [ttk::label [$writelengths getframe].arb \
                      -text [_ "Arbitary write of any length."]] -fill x
            }
            if {($wlen & 0x01) != 0} {
                pack [ttk::label [$writelengths getframe].stream \
                      -text [_ "Stream writes supported."]] -fill x
            }
            install highest using LabelEntry $dframe.highest \
                  -label [_m "Label|Highest address space:"] \
                  -text [format {%02X} [$self cget -highest]] \
                  -editable no
            pack $highest -fill x
            install lowest using LabelEntry $dframe.lowest \
                  -label [_m "Label|Lowest address space:"] \
                  -text [format {%02X} [$self cget -lowest]] \
                  -editable no
            pack $lowest -fill x
            if {"[$self cget -name]" ne {}} {
                install name using LabelEntry $dframe.name \
                      -label [_m "Label|Name string:"] \
                      -text "[$self cget -name]" \
                      -editable no
                pack $name -fill x
            }
            $hull draw
        }
        method _Close {} {
            ## Close and destroy the dialog box.
            
            destroy $win
        }
    }
    snit::widgetadaptor ConfigMemory {
        ## @brief Configure memory.
        # Create a dialog box that reads and writes the configuration memory 
        # of an OpenLCB node.
        #
        # Options:
        # @arg -destnid Node ID to send to.
        # @arg -transport LCC Transport object.
        # @arg -debugprint A function to handle debug output.
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
        
        typevariable _spaces [list 0xFF 0xFD 0xFE 0]
        ## Space values.
        
        option -destnid -readonly yes -type lcc::nid -default 00:00:00:00:00:00
        option -transport -readonly yes -default {}
        option -debugprint -readonly yes -default {}
        
        variable _ioComplete
        ## I/O Completion Flag.
        variable olddatagramhandler {}
        ## Old datagram handler.
        variable oldgeneralmessagehandler {}
        ## Old general message handler
        variable datagrambuffer {}
        ## Datagram message buffer
        variable _datagramrejecterror 0
        ## Last datagram rejection error.
        variable writeReplyCheck no
        ## Flag to check for a write reply.
        method _datagramhandler {command sourcenid args} {
            ## @brief Datagram message handler.
            # This method is called when a datagram type message arrives.
            # 
            # @param command One of datagramreceivedok, datagramrejected, or 
            #                datagramcontent.
            # @param sourcenid The Node ID of the node sending the datagram.
            # @param ... The data buffer, if any.
            # @arg -debugprint A function to handle debug output.
            #
            
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
        method _messagehandler {message} {
            ## Message handler -- handle incoming messages.
            # Certain messages are processed:
            #
            # Initialization Complete Messages -- This is a possible response 
            # to freeze, unfreeze, reset, or reinitialize commands.
            #
            switch [format {0x%04X} [$message cget -mti]] {
                0x0100 -
                0x0101 {
                    if {[$message cget -sourcenid] ne [$self cget -destnid]} {
                        if {$oldgeneralmessagehandler ne {}} {
                            uplevel #0 $oldgeneralmessagehandler $message
                        }
                    } else {
                        incr _ioComplete ;# Response from freeze, unfreeze, reset, or reinitialize command.
                    }
                }
                default {
                    if {$oldgeneralmessagehandler ne {}} {
                        uplevel #0 $oldgeneralmessagehandler $message
                    }
                }
            }
        }
        method _readmemory {_space _address length status_var} {
            ## @brief Method to read a block of configuration memory.
            # Read a block of memory, return the data bytes.  The variable
            # named by the @c status_var is side effected with the status code.
            #
            # @param _space The memory space to read from.
            # @param _address The address to start reading from.
            # @param length The number of bytes to read.
            # @param status_var The name of a status variable.
            # @return The data block read.
            
            lcc::byte validate $_space
            lcc::uint32 validate $_address
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
            $self putdebug "*** $self _readmemory: _ioComplete is $_ioComplete"
            if {$_ioComplete < 0} {
                ## datagram rejected message received
                # code in_datagramrejecterror
                set status 0
                return {}
            }
            set status [lindex $datagrambuffer 1]
            set respaddr [expr {[lindex $datagrambuffer 2] << 24}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 3] << 16)}]
            set respaddr [expr {$respaddr | ([lindex $datagrambuffer 4] << 8)}]
            set respaddr [expr {$respaddr | [lindex $datagrambuffer 5]}]
            $self putdebug [format "*** $self _readmemory: respaddr is 0x%08x and _address is 0x%08x" $respaddr $_address]
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
            $self putdebug [format "*** $self _readmemory: respspace is 0x%02x, _space is 0x%02x, and status is 0x%02x" $respspace $_space $status]
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
                return {} 
            }
        }
        method _writememory {_space _address databuffer} {
            ## @brief Write a block of data to configuration memory.
            # This method writes a block of memory to configuration memory of
            # an OpenLCB node.
            #
            # @param _space The memory space to write to.
            # @param _address The address to start writing to.
            # @param databuffer The list of bytes to write.
            # @return The result status: 0 if successful, otherwise an error 
            # code.
            
            lcc::byte validate $_space
            lcc::uint32 validate $_address
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
        
        method _lock {} {
            $self putdebug "*** $self _lock"
            set data [list 0x20 0x88]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] [[$self cget -transport] cget -nid]] 1 end] {
                lappend data [scan $oct %02x]
            }
            set datagrambuffer {}
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            if {$_ioComplete < 0} {
                $self putdebug "*** $self _lock returns -1"
                return -1
            }
            #set status [lindex $datagrambuffer 1]
            set reservedNIDIndx 2
            foreach n [[$self cget -transport] getMyNIDList] {
                if {$n != [lindex $datagrambuffer $reservedNIDIndx]} {
                    $self putdebug "*** $self _lock returns 0"
                    return 0
                }
                incr reservedNIDIndx
            }
            $self putdebug "*** $self _lock returns 1"
            return 1
        }
        method _unlock {} {
            $self putdebug "*** $self _unlock"
            set data [list 0x20 0x88 0 0 0 0 0 0]
            set datagrambuffer {}
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            if {$_ioComplete < 0} {
                $self putdebug "*** $self _unlock returns -1"
                return -1
            }
            $self putdebug "*** $self _unlock returns 1"
            return 1
        }
        method _freeze {thespace} {
            $self putdebug "*** $self _freeze $thespace"
            lcc::byte validate $thespace
            set data [list 0x20 0xA1 $thespace]
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            set oldgeneralmessagehandler [[$self cget -transport] cget -generalmessagehandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] configure -generalmessagehandler [mymethod _messagehandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            [$self cget -transport] configure -generalmessagehandler $oldgeneralmessagehandler
            if {$_ioComplete < 0} {
                $self putdebug "*** $self _freeze returns -1"
                return -1
            }
            $self putdebug "*** $self _freeze returns 1"
            return 1
        }
        method _unfreeze {thespace} {
            $self putdebug "*** $self _unfreeze $thespace"
            lcc::byte validate $thespace
            set data [list 0x20 0xA0 $thespace]
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            set oldgeneralmessagehandler [[$self cget -transport] cget -generalmessagehandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] configure -generalmessagehandler [mymethod _messagehandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            [$self cget -transport] configure -generalmessagehandler $oldgeneralmessagehandler
            if {$_ioComplete < 0} {
                $self putdebug "*** $self _unfreeze returns -1"
                return -1
            }
            $self putdebug "*** $self _unfreeze returns 1"
            return 1
        }
        method _reset {} {
            set data [list 0x20 0xA9]
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            set oldgeneralmessagehandler [[$self cget -transport] cget -generalmessagehandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] configure -generalmessagehandler [mymethod _messagehandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            [$self cget -transport] configure -generalmessagehandler $oldgeneralmessagehandler
            if {$_ioComplete < 0} {
                return -1
            }
            return 1            
        }
        method _reinitialize {} {
            set data [list 0x20 0xAA]
            foreach oct [lrange [regexp -inline [::lcc::nid cget -regexp] [$self cget -destnid]] 1 end] {
                lappend data [scan $oct %02x]
            }
            set _ioComplete 0
            set writeReplyCheck yes
            set olddatagramhandler [[$self cget -transport] cget -datagramhandler]
            set oldgeneralmessagehandler [[$self cget -transport] cget -generalmessagehandler]
            [$self cget -transport] configure -datagramhandler [mymethod _datagramhandler]
            [$self cget -transport] configure -generalmessagehandler [mymethod _messagehandler]
            [$self cget -transport] SendDatagram [$self cget -destnid] $data
            vwait [myvar _ioComplete]
            [$self cget -transport] configure -datagramhandler $olddatagramhandler
            [$self cget -transport] configure -generalmessagehandler $oldgeneralmessagehandler
            if {$_ioComplete < 0} {
                return -1
            }
            return 1            
            
        }
        
        method putdebug {message} {
            ## Print message using debug output, if any.
            #
            # @param message The message to print.
            
            set debugout [$self cget -debugprint]
            if {$debugout ne ""} {
                uplevel #0 [list $debugout "$message"]
            }
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
            $hull add close -text [_m "Label|Close"] -underline 0 -command [mymethod _Close]
            $hull add read  -text [_m "Label|Read"]  -underline 0 -command [mymethod _Read]
            $hull add write -text [_m "Label|Write"] -underline 0 -command [mymethod _Write]
            $hull add dump  -text [_m "Label|Dump to File"] -underline 0 -command [mymethod _Dump]
            $hull add restore -text [_m "Label|Restore from File"] -underline 0 -command [mymethod _Restore]
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
                  -label [_m "Label|Read:"] -editable no
            pack $readlist -fill x
            install writelist using LabelEntry $dframe.writelist \
                  -label [_m "Label|Write:"]
            pack $writelist -fill x
            install count  using LabelEntry $dframe.count \
                  -label [_m "Label|Count:"] -text 40
            pack $count  -fill x
            install address using LabelEntry $dframe.address \
                  -label [_m "Label|Address:"] -text [format {%06X} 0]
            pack $address -fill x 
            install space using LabelComboBox $dframe.space \
                  -label [_m "Label|Space:"] \
                  -values [list [_m "Label|CDI"] [_m "Label|Config"] \
                           [_m "Label|All"] [_m "Label|none"]] -editable no
            pack $space -fill x
            $space set CDI
            $hull draw
        }
        method _Close {} {
            ## Close and destroy the dialog box.
            
            destroy $win
        }
        method _Read {} {
            ## @brief Bound to the @c Read button.
            # Read a block of memory and display the results.
            
            set _address [scan [$address cget -text] %x]
            set _size    [scan [$count   cget -text] %d]
            if {$_size > 64} {set _size 64}
            if {$_size < 1} {set _size 1}
            set _space [lindex $_spaces [lsearch -exact \
                                         [$space cget -values] \
                                         [$space cget -text]]]
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
            ## @brief Bound to the @c Write button.
            # Write a block of memory.
            
            set _address [scan [$address cget -text] %x]
            set _space [lindex $_spaces [lsearch -exact \
                                         [$space cget -values] \
                                         [$space cget -text]]]
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
        method _getAddressRange {thespace} {
            ## @brief Get the address range of the specified space.
            # This performs a Get Address Space Information Command and
            # then returns the address range info.
            #
            # @param thespace The space.
            
            set data [list 0x20 0x84 $thespace]
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
                set status 0
                return {}
            }
            $self putdebug "*** $self _getAddressRange: datagrambuffer is $datagrambuffer"
            set command [lindex $datagrambuffer 1]
            if {$command == 0x86} {return {}}
            set asp     [lindex $datagrambuffer 2]
            set lowest 0x00000000
            set highest [expr {[lindex $datagrambuffer 3] << 24}]
            set highest [expr {$highest | ([lindex $datagrambuffer 4] << 16)}]
            set highest [expr {$highest | ([lindex $datagrambuffer 5] << 8)}]
            set highest [expr {$highest | [lindex $datagrambuffer 6]}]
            set flags [lindex $datagrambuffer 7]
            if {($flags & 0x02) != 0} {
                set lowest [expr {[lindex $datagrambuffer 8] << 24}]
                set lowest [expr {$lowest | ([lindex $datagrambuffer 9] << 16)}]
                set lowest [expr {$lowest | ([lindex $datagrambuffer 10] << 8)}]
                set lowest [expr {$lowest | [lindex $datagrambuffer 11]}]
            }
            return [$self _checkRange $lowest $highest]
        }
        variable _lowestAddress 0
        variable _highestAddress 0
        variable _rangeDialog {}
        method _checkRange {lowest highest} {
            if {![winfo exists $_rangeDialog]} {
                set _rangeDialog [Dialog $win.checkRange -separator 0 \
                                  -modal local -parent $win -place center \
                                  -side bottom \
                                  -title {Address Range to dump} \
                                  -transient 1 -anchor e -class AddressCheck]
                $_rangeDialog add ok -text [_m "Label|OK"] -command [mymethod _rangeOK]
                set dframe [$_rangeDialog getframe]
                pack [LabelEntry $dframe.l -label [_m "Label|Lowest"] -textvariable [myvar _lowestAddress]] -fill x -expand yes
                pack [LabelEntry $dframe.h -label [_m "Label|Highest"] -textvariable [myvar _highestAddress]] -fill x -expand yes
            }
            set _lowestAddress [format "%08x" $lowest]
            set _highestAddress [format "%08x" $highest]
            return [$_rangeDialog draw]
        }
        method _rangeOK {} {
            scan $_lowestAddress %x lowest
            scan $_highestAddress %x highest
            $_rangeDialog withdraw
            $_rangeDialog enddialog [list $lowest $highest]
        }            
        method _Dump {} {
            ## @brief Bound to the @c Dump button.
            # Dump the configuration memory to a file.  Either as text (if 
            # space is CDI) or Hex (if space is NOT CDI).
            set _space [lindex $_spaces [lsearch -exact \
                                         [$space cget -values] \
                                         [$space cget -text]]]
            set addrrange [$self _getAddressRange $_space]
            if {$addrrange eq {}} {return}
            $self putdebug "*** $self _Dump: addrrange is $addrrange"
            if {$_space == 0xFF} {
                $self _dumpAsText $_space [lindex $addrrange 0] [lindex $addrrange 1]
            } else {
                $self _dumpAsHex $_space [lindex $addrrange 0] [lindex $addrrange 1]
            }
        }
        method _dumpAsText {thespace startaddress endaddress} {
            ## @brief Dump a space as text (typically the CDI).
            # Dump a device's memory as a text file.  This is typically
            # the device's CDI.
            #
            # @param thespace The space.
            # @param startaddress The start address
            # @param endaddress The end address
            #
            
            set filename [tk_getSaveFile -defaultextension .xml \
                          -filetypes { {{XML Files} {.xml} }
                                       {{Text Files} {.txt} }
                                       {{All Files} * } } \
                          -initialdir [pwd] \
                          -initialfile cdi.xml \
                          -parent $win \
                          -title "Select a file to save the dump in"]
            if {$filename eq ""} {return}
            if {[catch {open $filename w} outfp]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not open %s because %s" $filename $outfp]
                return
            }
            set seenNUL false
            set totalBytes 0
            for {set a $startaddress} {$a <= $endaddress && !$seenNUL} {incr a 64} {
                set data [$self _readmemory $thespace $a 64 status]
                $self putdebug "*** $self _dumpAsText: read 64 bytes at $a, status is $status"
                if {$status == 0x50} {
                    foreach d $data {
                        if {$d == 0} {
                            set seenNUL true
                            break
                        }
                        puts -nonewline $outfp "[format %c $d]"
                        incr totalBytes
                    }
                } else {
                    puts stderr [_ "Read error @ 0x%08x, retrying" $a]
                    incr a -64
                }
            }
            close $outfp
            puts stderr [_ "Total bytes: %d" $totalBytes]
        }
        method _dumpAsHex {thespace startaddress endaddress} {
            ## @brief Dump a space as hex (typically the configuration memory).
            # Dump a device's memory as a hex file.  This is typically
            # the device's configuration memory.
            #
            # @param thespace The space.
            # @param startaddress The start address
            # @param endaddress The end address
            #
            
            set filename [tk_getSaveFile -defaultextension .hex \
                          -filetypes { {{Hex Files} {.hex} }
                                       {{Text Files} {.txt} }
                                       {{All Files} * } } \
                          -initialdir [pwd] \
                          -initialfile config.hex \
                          -parent $win \
                          -title "Select a file to save the dump in"]
            if {$filename eq ""} {return}
            if {[catch {open $filename w} outfp]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not open %s because %s" $filename $outfp]
                return
            }
            for {set a $startaddress} {$a <= $endaddress} {incr a 64} {
                set data [$self _readmemory $thespace $a 64 status]
                if {$status == 0x50} {
                    puts -nonewline $outfp "[format %08X $a]"
                    foreach d $data {
                        puts -nonewline $outfp "[format { %02X} $d]"
                    }
                    puts $outfp {}
                }
            }
            close $outfp
        }
        method _Restore {} {
            ## @brief Bound to the @c Restore button.
            # Reload configuration memory from a hex dump file.
            set _space [lindex $_spaces [lsearch -exact \
                                         [$space cget -values] \
                                         [$space cget -text]]]
            if {$_space != 0xFD} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Can only restore configuration memory!"]
                return
            }
            set filename [tk_getOpenFile -defaultextension .hex \
                          -filetypes { {{Hex Files} {.hex} }
                                       {{Text Files} {.txt} }
                                       {{All Files} * } } \
                          -initialdir [pwd] \
                          -initialfile config.hex \
                          -parent $win \
                          -title "Select a file to restore a dump from"]
            if {$filename eq ""} {return}
            if {[catch {open $filename r} infp]} {
                tk_messageBox -type ok -icon error \
                      -message [_ "Could not open %s because %s" $filename $outfp]
                return
            }
            set locked no
            while {!$locked} {
                switch [$self _lock] {
                    -1 {
                        if {[tk_messageBox -type okcancel -icon question \
                             -message [_ "Failed to lock node, continue?"]] eq "ok"} {
                            break
                        } else {
                            close $infp
                            return
                        }
                    }
                    0 {
                        set retrycheck [tk_messageBox -type okcancel \
                                        -icon info \
                                        -message [_ "Device Busy, retrying in 30 seconds."]]
                        if {$retrycheck eq "cancel"} {
                            close $infp
                            return
                        } else {
                            after 30000
                        }
                    }
                    1 {
                        set locked yes
                    }
                }
            }
            $self putdebug "*** $self _Restore: locked = $locked"
            set temperature [$self _freeze $_space]
            $self putdebug "*** $self _Restore: temperature = $temperature"
            while {[gets $infp line] >= 0} {
                if {[regexp {^([[:xdigit:]]+)[[:space:]]+([[:xdigit:][:space:]]+)$} $line -> hexaddr hexdata] < 1} {
                    tk_messageBox -type ok -icon warning \
                          -message [_ "Syntax error in line %s, skipped." $line]
                    continue
                }
                scan $hexaddr %x addr
                set data [list]
                foreach hb [split $hexdata] {
                    $self putdebug "*** $self _Restore: hb = $hb"
                    if {[scan $hb %x b] > 0} {
                        lappend data $b
                    }
                }
                $self putdebug "*** $self _Restore: $self _writememory $_space $addr $data"
                $self _writememory $_space $addr $data
            }
            if {$temperature > 0} {$self _unfreeze $_space}
            if {$locked} {$self _unlock}
            close $infp
        }
    }
}

package provide ConfigDialogs 1.0

