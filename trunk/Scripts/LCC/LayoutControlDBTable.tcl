#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Tue Jun 29 07:39:30 2021
#  Last Modified : <230226.1707>
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


package require Tk
package require tile
package require snit
package require gettext
package require IconImage
package require LayoutControlDB


namespace eval lcc {
    snit::widgetadaptor LayoutControlDBTable {
        option -db -default {}
        option -itemeditor -default {}
        delegate option * to hull except {-class -style -columns 
            -displaycolumns -show}
        delegate method * to hull except {bbox cget configure delete 
            detach exists index insert instate move next parent 
            prev set state tag}
        constructor {args} {
            installhull using ttk::treeview -columns {} \
                  -selectmode browse
            $hull tag bind block <ButtonRelease-3> [mymethod _editItem block %x %y]
            $hull tag bind turnout <ButtonRelease-3> [mymethod _editItem turnout %x %y]
            $hull tag bind signal <ButtonRelease-3> [mymethod _editItem signal %x %y]
            $hull tag bind sensor <ButtonRelease-3> [mymethod _editItem sensor %x %y]
            $hull tag bind control <ButtonRelease-3> [mymethod _editItem control %x %y]
            $self configurelist $args
            $self Refresh
        }
        method _editItem {what x y} {
            set item [$hull identify item $x $y]
            if {$item ne {}} {
                set name [$hull item $item -text]
                if {[$self cget -itemeditor] ne {}} {
                    set cmd [$self cget -itemeditor]
                    append cmd { }
                    append cmd [list $what $name -db [$self cget -db]]
                    uplevel #0 $cmd
                }
            }
        }
        method Refresh {} {
            $hull delete [$hull children {}]
            if {$options(-db) ne {}} {
                set l [$options(-db) getElementsByTagName layout]
                foreach i [$l children] {
                    $self InsertControlElement $i
                }
            }
        }
        method UpdateItem {name} {
            set l [$options(-db) getElementsByTagName layout]
            foreach i [$l children] {
                set n [$i getElementsByTagName name -depth 1]
                if {$name eq [$n data]} {
                    $hull delete [$hull children $i]
                    set tag [$i cget -tag]
                    switch $tag {
                        block {
                            set occ [$i getElementsByTagName occupied -depth 1]
                            set clr [$i getElementsByTagName clear -depth 1]
                            $hull insert $i end \
                                  -id "$i:occupied" \
                                  -text [_ "Occupied: %s" [$occ data]]
                            $hull insert $i end \
                                  -id "$i:clear" \
                                  -text [_ "Clear: %s" [$clr data]]
                        }
                        turnout {
                            set motor  [$i getElementsByTagName motor -depth 1]
                            set motor_norm [$motor getElementsByTagName normal -depth 1]
                            set motor_rev  [$motor getElementsByTagName reverse -depth 1]
                            set points [$i getElementsByTagName points -depth 1]
                            set points_norm [$points getElementsByTagName normal -depth 1]
                            set points_rev  [$points getElementsByTagName reverse -depth 1]
                            $hull insert $i end \
                                  -id "$i:motor:normal" \
                                  -text [_ "Motor Normal: %s" [$motor_norm data]]
                            $hull insert $i end \
                                  -id "$i:motor:reverse" \
                                  -text [_ "Motor Reverse: %s" [$motor_rev data]]
                            $hull insert $i end \
                                  -id "$i:points:normal" \
                                  -text [_ "Points Normal: %s" [$points_norm data]]
                            $hull insert $i end \
                                  -id "$i:points:reverse" \
                                  -text [_ "Points Reverse: %s" [$points_rev data]]
                        }
                        signal {
                            foreach a [$i getElementsByTagName aspect] {
                                $hull insert $i end \
                                      -id "$i:$a" \
                                      -text [_ "Aspect %s (%s) %s" \
                                             [[$a getElementsByTagName name -depth 1] data] \
                                             [[$a getElementsByTagName look -depth 1] data] \
                                             [[$a getElementsByTagName event -depth 1] data]]
                            }                        
                        }
                        sensor {
                            set on [$i getElementsByTagName on -depth 1]
                            set off [$i getElementsByTagName off -depth 1]
                            $hull insert $i end \
                                  -id "$i:on" \
                                  -text [_ "On: %s" [$on data]]
                            $hull insert $i end \
                                  -id "$i:off" \
                                  -text [_ "Off: %s" [$off data]]
                        }
                        control {
                            set on [$i getElementsByTagName on -depth 1]
                            set off [$i getElementsByTagName off -depth 1]
                            $hull insert $i end \
                                  -id "$i:on" \
                                  -text [_ "On: %s" [$on data]]
                            $hull insert $i end \
                                  -id "$i:off" \
                                  -text [_ "Off: %s" [$off data]]
                        }
                    }
                    break
                }
            }
        }
        method InsertControlElement {i} {
            set n [$i getElementsByTagName name -depth 1]
            set name [$n data]
            set tag [$i cget -tag]
            switch $tag {
                block {
                    $hull insert {} end -id $i \
                          -image [IconImage image Block] \
                          -text $name  -open false -tags block
                    set occ [$i getElementsByTagName occupied -depth 1]
                    set clr [$i getElementsByTagName clear -depth 1]
                    $hull insert $i end \
                          -id "$i:occupied" \
                          -text [_ "Occupied: %s" [$occ data]]
                    $hull insert $i end \
                          -id "$i:clear" \
                          -text [_ "Clear: %s" [$clr data]]
                }
                turnout {
                    $hull insert {} end -id $i \
                          -image [IconImage image SwitchMotor] \
                          -text $name -open false -tags turnout
                    set motor  [$i getElementsByTagName motor -depth 1]
                    set motor_norm [$motor getElementsByTagName normal -depth 1]
                    set motor_rev  [$motor getElementsByTagName reverse -depth 1]
                    set points [$i getElementsByTagName points -depth 1]
                    set points_norm [$points getElementsByTagName normal -depth 1]
                    set points_rev  [$points getElementsByTagName reverse -depth 1]
                    $hull insert $i end \
                          -id "$i:motor:normal" \
                          -text [_ "Motor Normal: %s" [$motor_norm data]]
                    $hull insert $i end \
                          -id "$i:motor:reverse" \
                          -text [_ "Motor Reverse: %s" [$motor_rev data]]
                    $hull insert $i end \
                          -id "$i:points:normal" \
                          -text [_ "Points Normal: %s" [$points_norm data]]
                    $hull insert $i end \
                          -id "$i:points:reverse" \
                          -text [_ "Points Reverse: %s" [$points_rev data]]
                }
                signal {
                    $hull insert {} end -id $i \
                          -image [IconImage image Signal] \
                          -text $name -open false -tags signal
                    foreach a [$i getElementsByTagName aspect] {
                        $hull insert $i end \
                              -id "$i:$a" \
                              -text [_ "Aspect %s (%s) %s" \
                                     [[$a getElementsByTagName name -depth 1] data] \
                                     [[$a getElementsByTagName look -depth 1] data] \
                                     [[$a getElementsByTagName event -depth 1] data]]
                    }                        
                }
                sensor {
                    $hull insert {} end -id $i \
                          -image [IconImage image Sensor] \
                          -text $name -open false -tags sensor
                    set on [$i getElementsByTagName on -depth 1]
                    set off [$i getElementsByTagName off -depth 1]
                    $hull insert $i end \
                          -id "$i:on" \
                          -text [_ "On: %s" [$on data]]
                    $hull insert $i end \
                          -id "$i:off" \
                          -text [_ "Off: %s" [$off data]]
                }
                control {
                    $hull insert {} end -id $i \
                          -image [IconImage image Control] \
                          -text $name -open false -tags control
                    set on [$i getElementsByTagName on -depth 1]
                    set off [$i getElementsByTagName off -depth 1]
                    $hull insert $i end \
                          -id "$i:on" \
                          -text [_ "On: %s" [$on data]]
                    $hull insert $i end \
                          -id "$i:off" \
                          -text [_ "Off: %s" [$off data]]
                }
            }
        }
    }
}
            
package provide LayoutControlDBTable 1.0
