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
#  Created       : Tue May 8 13:34:27 2018
#  Last Modified : <180508.1441>
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

snit::integer HeadCount -min 1 -max 3

snit::type Signal {
    option -name -default {}
    option -numberofheads -type HeadCount -default 1
    option -origx -type snit::double -default 0.0
    option -origy -type snit::double -default 0.0
    option -angle -type snit::double -default 0.0
    variable aspectEvents -array {}
    typevariable allsignals {}
    method addAspectEvent {eventid name} {
        set aspectEvents($eventid) $name
    }
    method allAspectEvents {} {return array names aspectEvents}
    method aspect {eventid} {
        if {[info exists aspectEvents($eventid)]} {
            return $aspectEvents($eventid)
        } else {
            return {}
        }
    }
    constructor {args} {
        $self configurelist $args
        lappend allsignals $self
    }
    typemethod readSignalsCSV {filename} {
        if {[catch {open $filename r} fp]} {
            error "Unable to open $filename: $fp"
        }
        set hline [gets $fp]
        set headings [::csv::split $hline]
        set nameindex [lsearch -nocase $headings name]
        set nheadsindex [lsearch -nocase $headings numberofheads]
        set oxindex [lsearch -nocase $headings origx]
        set oyindex [lsearch -nocase $headings origy]
        set aindex [lsearch -nocase $headings angle]
        set anameindex [lsearch -nocase $headings signalaspectname]
        set aevidindex [lsearch -nocase $headings signalaspectscript]
        set currentsignal {}
        while {[gets $fp line] >= 0} {
            set record [::csv::split $line]
            #puts stderr "*** $type readSignalsCSV: record is $record"
            set newname [lindex $record $nameindex]
            if {$newname ne {}} {
                set nheads [lindex $record $nheadsindex]
                set ox     [lindex $record $oxindex]
                set oy     [lindex $record $oyindex]
                set a      [lindex $record $aindex]
                set currentsignal [$type create %AUTO% -name $newname \
                                   -numberofheads $nheads \
                                   -origx $ox -origy $oy -angle $a]
            }
            $currentsignal addAspectEvent [lindex $record $aevidindex] \
                  [lindex $record $anameindex]
        }
        close $fp
    }
    typemethod allSignals {} {return $allsignals}
    method dumpme {fp} {
        puts $fp "Name: [$self cget -name]"
        puts $fp "Heads: [$self cget -numberofheads]"
        puts $fp "Orig X: [$self cget -origx]"
        puts $fp "Orig Y: [$self cget -origy]"
        puts $fp "Angle: [$self cget -angle]"
        puts $fp "Aspects:"
        foreach e [lsort [array names aspectEvents]] {
            puts $fp "\t$e: [$self aspect $e]"
        }
    }
    proc colors2aspectname {colors} {
        if {[regexp {^green} $colors] > 0} {return Clear}
        if {[regexp {^yellow} $colors] > 0} {return Approach}
        if {[regexp {^red} $colors] > 0} {
            set c2 [regsub {^red } $colors {}]
            if {[regexp {^green} $c2] > 0} {return {Medium Clear}}
            if {[regexp {^yellow} $colors] > 0} {return {Approach Limited}}
            if {[regexp {^red} $colors] > 0} {
                set c3 [regsub {^red } $c2 {}]
                if {[regexp {^green} $c2] > 0} {return {Slow Clear}}
                if {[regexp {^yellow} $colors] > 0} {return {Approach Slow}}
                return Stop
            }
            return Stop
        }
        return Stop
    }
        
    typevariable HNumber 1
    typemethod ResetHN {} {set HNumber 1}
    method GenerateQSXml {fp} {
        puts $fp "<mast>"
        puts $fp "  <description>[$self cget -name]</description>"
        set heads [list $HNumber]
        incr HNumber
        set hcount [$self cget -numberofheads]
        incr hcount -1
        while {$hcount > 0} {
            lappend heads $HNumber
            incr HNumber
            incr hcount -1
        }
        foreach e [lsort [array names aspectEvents]] {
            set colors $aspectEvents($e)
            puts $fp "  <aspect>"
            puts $fp "    <eventid>$e</eventid>"
            puts $fp "    <name>[colors2aspectname $colors]</name>"
            foreach c $colors h $heads {
                puts $fp "    <head>"
                puts $fp "      <lamp>"
                puts $fp "        <id>[format {H%d-G} $h]</id>"
                if {$c eq "green"} {
                    puts $fp "        <effect>on</effect>"
                } else {
                    puts $fp "        <effect>off</effect>"
                }
                puts $fp "      </lamp>"
                puts $fp "      <lamp>"
                puts $fp "        <id>[format {H%d-Y} $h]</id>"
                if {$c eq "yellow"} {
                    puts $fp "        <effect>on</effect>"
                } else {
                    puts $fp "        <effect>off</effect>"
                }
                puts $fp "      </lamp>"
                puts $fp "      <lamp>"
                puts $fp "        <id>[format {H%d-R} $h]</id>"
                if {$c eq "red"} {
                    puts $fp "        <effect>on</effect>"
                } else {
                    puts $fp "        <effect>off</effect>"
                }
                puts $fp "      </lamp>"
                puts $fp "    </head>"
            }
            puts $fp "  </aspect>"
        }
        puts $fp "</mast>"
        if {$HNumber > 4} {
            set HNumber 1
            puts $fp ""
        }
    }
}

        
Signal readSignalsCSV CrossingInterchangeSignals.csv
foreach s [Signal allSignals] {
    $s GenerateQSXml stdout
}


