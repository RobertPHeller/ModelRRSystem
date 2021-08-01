#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 31 19:40:31 2021
#  Last Modified : <210731.2120>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2021  Robert Heller D/B/A Deepwoods Software
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


package require snit
package require csv
package require gettext

snit::type Cars {
    typevariable SessionNumber 0
    typevariable ShiftNumber   0
    typevariable TotalCars     0
    variable type_
    method Type {} {return $type_}
    variable rrmarks_
    method Rrmarks {} {return $rrmarks_}
    variable number_
    method Number {} {return $number_}
    variable homediv_
    method Homediv {} {return $homediv_}
    variable length_
    method Length {} {return $length_}
    variable clearance_
    method Clearance {} {return $clearance_}
    variable weightclass_
    method Weightclass {} {return $weightclass_}
    variable lwt_
    method Lwt {} {return $lwt_}
    variable lwlt_
    method Lwlt {} {return $lwlt_}
    variable loaded_
    method Loaded {} {return $loaded_}
    variable mirror_
    method Mirror {} {return $mirror_}
    variable fixed_
    method Fixed {} {return $fixed_}
    variable owner_
    method Owner {} {return $owner_}
    variable done_
    method Done {} {return $done_}
    variable train_
    method Train {} {return $train_}
    variable moves_
    method Moves {} {return $moves_}
    variable location_
    method Location {} {return $location_}
    variable destination_
    method Destination {} {return $destination_}
    variable trips_
    method Trips {} {return $trips_}
    variable assignments_
    method Assignments {} {return $assignments_}
    typevariable AllCars [list]
    constructor {record args} {
        lassign $record type_ rrmarks_ number_ homediv_ length_ clearance_ \
              weightclass_ lwt_ lwlt_ loaded_ mirror_ fixed_ owner_ done_ \
              train_ moves_ location_ destination_ trips_ assignments_ 
        lappend AllCars $self
    }
    destructor {
        set index [lsearch -exact $AllCars $self]
        if {$index >= 0} {
            set AllCars [lreplace $AllCars $index $index]
        }
    }
    typemethod ReadFCFCars {filename} {
        if {[catch {open $filename r} fp]} {
            error [_ "Could not open %s because %s" $filename $fp]
        }
        while {[gets $fp line] >= 0} {
            set line [string trim [regsub {'.*$} $line {}]]
            if {$line eq {}} {continue}
            scan $line {%d} SessionNumber
            break
        }
        while {[gets $fp line] >= 0} {
            set line [string trim [regsub {'.*$} $line {}]]
            if {$line eq {}} {continue}
            scan $line {%d} ShiftNumber
            break
        }
        while {[gets $fp line] >= 0} {
            set line [string trim [regsub {'.*$} $line {}]]
            if {$line eq {}} {continue}
            scan $line {%d} TotalCars
            break
        }
        while {[gets $fp line] >= 0} {
            set line [string trim [regsub {'.*$} $line {}]]
            if {$line eq {}} {continue}
            if {$line == -1} {break}
            set record [::csv::split $line]
            if {[llength $record] == 20} {
                $type create %AUTO% $record
            }
        }
        close $fp
    }
}

package provide Cars 1.0

## /scratch/ChesapeakeSystem/cars.dat

#Cars ReadFCFCars /scratch/ChesapeakeSystem/cars.dat
#
#puts [format {Session %d, Shift %d, Total Cars %d} $Cars::SessionNumber \
#      $Cars::ShiftNumber $Cars::TotalCars]
#
#set i 0
#foreach c $Cars::AllCars {
#    incr i
#    puts [format {%d: %s %s (%s)} $i [$c Rrmarks] [$c Number] [$c Type]]
#}

