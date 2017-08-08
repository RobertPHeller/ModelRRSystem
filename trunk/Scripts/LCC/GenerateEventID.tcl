#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Jul 29 14:30:39 2017
#  Last Modified : <170729.1518>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
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
package require LCC

snit::type GenerateEventID {
    option -baseeventid -type lcc::EventID_or_null -default {}
    constructor {args} {
        $self configurelist $args
        if {$options(-baseeventid) eq {}} {
            $self configure -baseeventid [lcc::EventID create %AUTO%]
        }
    }
    method nextid {} {
        set idstring [$options(-baseeventid) cget -eventidstring]
        set idlist [$options(-baseeventid) cget -eventidlist]
        set next 256
        set i 8
        while {$next > 255} {
            if {$i <= 7} {
                lset idlist $i 0
            }
            incr i -1
            set next [expr {1 + [lindex $idlist $i]}]
        }
        if {$i >= 0} {
            lset idlist $i $next
        }
        $options(-baseeventid) configure -eventidlist $idlist
        return $idstring
    }
}


package provide GenerateEventID 1.0
