#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Oct 13 21:45:14 2018
#  Last Modified : <181013.2326>
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

package require snit

namespace eval linuxgpio {
    snit::integer pinnotype -min 0
    snit::enum pindirection -values {in out high low}
    snit::type LinuxGpio {
        typevariable EXPORT "/sys/class/gpio/export"
        typevariable UNEXPORT "/sys/class/gpio/unexport"
        typevariable DIRECTIONFMT "/sys/class/gpio/gpio%d/direction"
        typevariable VALUEFMT "/sys/class/gpio/gpio%d/value"
        option -pinnumber -default 0 -type linuxgpio::pinnotype -readonly yes
        option -direction -default in -type linuxgpio::pindirection -readonly yes
        constructor {args} {
            $self configurelist $args
            #puts stderr "*** $type create $self: [$self configure]"
            #puts stderr "*** $type create $self: EXPORT is $EXPORT"
            if {[catch {open $EXPORT w} exportFp]} {
                error "Could not export pin: $exportFp"
            }
            puts $exportFp [format %d [$self cget -pinnumber]]
            close $exportFp
            set dirfile [format $DIRECTIONFMT [$self cget -pinnumber]]
            set start [clock milliseconds]
            while {true} {
                set g [file attributes $dirfile -group]
                #puts stderr "*** $type create $self: g is $g"
                if {$g eq "gpio"} {break}
            }
            while {true} {
                set perms [file attributes $dirfile -permissions]
                #puts stderr "*** $type create $self: perms are $perms"
                if {$perms eq "00770"} {break}
            }
            set delta [expr {[clock milliseconds] - $start}]
            #puts stderr "*** $type create $self: delta = $delta"
            #puts stderr "*** $type create $self: [glob {/sys/class/gpio/*}]"
            #puts stderr "*** $type create $self: after export"
            #puts stderr "*** $type create $self: dirfile is '$dirfile'"
            #puts stderr "*** $type create $self: dirfile's attrs: [file attributes $dirfile]"
            if {[catch {open $dirfile w} dirFp]} {
                error "Could not set pin direction: $dirFp"
            }
            puts $dirFp [$self cget -direction]
            close $dirFp
            #puts stderr "*** $type create $self: after set direction"
        }
        method read {} {
            if {[catch {open [format $VALUEFMT [$self cget -pinnumber]] r} valFp]} {
                error "Could not read pin: $valFp"
            }
            set v [::read $valFp 1]
            close $valFp
            return $v
        }
        method write {value} {
            if {[catch {open [format $VALUEFMT [$self cget -pinnumber]] w} valFp]} {
                error "Could not write pin: $valFp"
            }
            puts $valFp $value
            close $valFp
        }
        method is_output {} {
            if {[catch {open [format $DIRECTIONFMT [$self cget -pinnumber]] r} dirFp]} {
                error "Could not get pin direction: $dirFp"
            }
            set dir [gets $dirFp]
            close $dirFp
            return [expr {$dir ne "in"}]
        }
        destructor {
            if {[catch {open $UNEXPORT w} unexportFp]} {
                error "Could not unexport pin: $unexportFp"
            }
            puts $unexportFp [format %d [$self cget -pinnumber]]
            close $unexportFp
        }
    }
}


package provide LinuxGpio 1.0.0
