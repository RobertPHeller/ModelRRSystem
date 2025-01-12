#!/usr/bin/tclsh
#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue May 8 21:35:11 2018
#  Last Modified : <180508.2156>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2018  Robert Heller D/B/A Deepwoods Software
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


package require csv

package require snit

snit::listtype TrackList -type snit::integer

snit::type Block {
    option -name -default {}
    option -tracks -type TrackList -default {}
    option -occlow  -default {}
    option -occhigh -default {}
    typevariable allblocks {}
    typevariable availablepins {4 5 6 7 21 22 23 26 27 28 29}
    variable pin
    constructor {args} {
        $self configurelist $args
        set pin [lindex $availablepins 0]
        set availablepins [lrange $availablepins 1 end]
        lappend allblocks $self
    }
    typevariable EVPattern {^([[:xdigit:].]+):([[:xdigit:].]+)$}
    typemethod readBlocksCSV {filename} {
        if {[catch {open $filename r} fp]} {
            error "Unable to open $filename: $fp"
        }
        set hline [gets $fp]
        set headings [::csv::split $hline]
        set nameindex [lsearch -nocase $headings name]
        set trksindex [lsearch -nocase $headings tracklist]
        set senseindex [lsearch -nocase $headings sensescript]
        while {[gets $fp line] >= 0} {
            set record [::csv::split $line]
            set name [lindex $record $nameindex]
            set trks [lindex $record $trksindex]
            if {[regexp $EVPattern [lindex $record $senseindex] => low high] < 1} {continue}
            $type create %AUTO% -name $name -tracks $trks -occlow $low -occhigh $high
        }
        close $fp
    }
    method GeneratePiGPIOXML {fp} {
        puts $fp "<pin>"
        puts $fp "  <description>[$self cget -name]</description>"
        puts $fp "  <number>$pin</number>"
        puts $fp "  <mode>in</mode>"
        puts $fp "  <pullmode>up</pullmode>"
        puts $fp "  <pinin0>[$self cget -occlow]</pinin0>"
        puts $fp "  <pinin1>[$self cget -occhigh]</pinin1>"
        puts $fp "</pin>"
    }
    typemethod allBlocks {} {return $allblocks}
}

Block readBlocksCSV CrossingInterchangeBlocks.csv
foreach b [Block allBlocks] {
    $b GeneratePiGPIOXML stdout
}
