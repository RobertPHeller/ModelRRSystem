#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 31 15:00:32 2021
#  Last Modified : <210731.1656>
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
package gettext

snit::type CarTypes {
    variable symbol_;# Symbol
    method Symbol {} {return $symbol_}
    variable group_;# Group
    method Group {} {return $group_}
    variable description_;# Description
    method Description {} {return $description_}
    variable comment_;# Comment
    method Comment  {} {return $comment_}
    typevariable AllCarTypes [list]
    typevariable TypeBySymbol -array {}
    constructor {record args} {
        lassign $record symbol_ group_ description_ pad comment_
        lappend AllCarTypes $self
        set TypeBySymbol($symbol_) $self
    }
    destructor {
        unset TypeBySymbol($symbol_)
        set index [lsearch -exact $AllCarTypes $self]
        if {$index >= 0} {
            set AllCarTypes [lreplace $AllCarTypes $index $index]
        }
    }
    typemethod ReadCarTypes {filename} {
        if {[catch {open $filename r} fp]} {
            error [_ "Could not open %s because %s" $filename $fp]
        }
        while {[gets $fp line] >= 0} {
            set line [string trim [regsub {'.*$} $line {}]]
            if {$line eq {}} {continue}
            set record [::csv::split $line]
            if {[llength $record] == 5} {
                $type create %AUTO% $record
            } elseif {[llength $record] == 3} {
                CarGroups create %AUTO% $record
            }
        }
        close $fp
    }
}

snit::type CarGroups {
    variable symbol_;# Symbol
    method Symbol {} {return $symbol_}
    variable description_;# Description
    method Description {} {return $description_}
    variable comment_;# Comment
    method Comment  {} {return $comment_}
    typevariable AllCarGroups [list]
    typevariable GroupBySymbol -array {}
    constructor {record args} {
        lassign $record symbol_ description_ comment_
        lappend AllCarGroups $self
        set GroupBySymbol($symbol_) $self
    }
    destructor {
        unset GroupBySymbol($symbol_)
        set index [lsearch -exact $AllCarGroups $self]
        if {$index >= 0} {
            set AllCarGroups [lreplace $AllCarGroups $index $index]
        }
    }
    typemethod ReadCarGroups  {filename} {
        if {[catch {open $filename r} fp]} {
            error [_ "Could not open %s because %s" $filename $fp]
        }
        while {[gets $fp line] >= 0} {
            set line [string trim [regsub {'.*$} $line {}]]
            if {$line eq {}} {continue}
            set record [::csv::split $line]
            if {[llength $record] == 3} {
                $type create %AUTO%
            }
        }
        close $fp
    }
}

package provide Cartypes 1.0

# file "/home/heller/Deepwoods/ModelRRSystem//ChesapeakeSystem/cartypes.dat"
#
#CarTypes ReadCarTypes $file
#
#foreach ct $CarTypes::AllCarTypes {
#    puts "[$ct Symbol]: [$ct Description]"
#}
#
#foreach cg $CarGroups::AllCarGroups {
#    puts "[$cg Symbol]: [$cg Description]"
#}
