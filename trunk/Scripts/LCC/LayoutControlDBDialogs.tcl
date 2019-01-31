#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Thu Jan 31 15:01:56 2019
#  Last Modified : <190131.1601>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2019  Robert Heller D/B/A Deepwoods Software
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
package require LayoutControlDB
package require Dialog
package require ScrollTabNotebook
package require LabelFrames

namespace eval lcc {
    snit::widgetadaptor NewTurnoutDialog {
        delegate option -parent to hull
        option -db
        
        component nameLE;#                  Name of object
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -modal local -transient yes \
                  -side bottom -title [_ "New Turnout"] \
                  -parent [from args -parent]
            $hull add add    -text Add    -command [mymethod _Add]
            $hull add cancel -text Cancel -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            set result [[$self cget -db] newTurnout $name]
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor NewBlockDialog {
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -modal local -transient yes \
                  -side bottom -title [_ "New Block"] \
                  -parent [from args -parent]
            $hull add add    -text Add    -command [mymethod _Add]
            $hull add cancel -text Cancel -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            set result [[$self cget -db] newBlock $name]
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor NewSignalDialog {
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        component aspectlistLF
        component   aspectlistSTabNB
        variable    aspectlist -array {}
        component   addaspectB
        
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -modal local -transient yes \
                  -side bottom -title [_ "New Signal"] \
                  -parent [from args -parent]
            $hull add add    -text Add    -command [mymethod _Add]
            $hull add cancel -text Cancel -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            install aspectlistLF using ttk::labelframe $frame.aspectlistLF \
                  -labelanchor nw -text [_m "Label|Signal Aspect Events"]
            pack $aspectlistLF -fill x
            install aspectlistSTabNB using ScrollTabNotebook \
                  $aspectlistLF.aspectlistSTabNB
            pack $aspectlistSTabNB -expand yes -fill both
            install addaspectB using ttk::button $aspectlistLF.addaspectB \
                  -text [_m "Label|Add another aspect"] \
                  -command [mymethod _addaspect]
            $self configurelist $args
        }
        method _addaspect {} {
            set aspectcount 0
            incr aspectcount
            set fr aspect$aspectcount
            while {[winfo exists $aspectlistSTabNB.$fr]} {
                incr aspectcount
                set fr aspect$aspectcount
            }
            set aspectlist($aspectcount,frame) $fr
            ttk::frame $aspectlistSTabNB.$fr
            $aspectlistSTabNB add $aspectlistSTabNB.$fr -text [_ "Aspect %d" $aspectcount] -sticky news
            set aspl_ [LabelEntry $aspectlistSTabNB.$fr.aspl \
                       -label [_m "Label|Aspect Name"] \
                       -text {}]
            pack $aspl_ -fill x
            set aspectlist($aspectcount,aspl) {}
            set asplook_ [LabelEntry $aspectlistSTabNB.$fr.asplook \
                          -label [_m "Label|Aspect Look"] \
                          -text {}]
            pack $asplook_ -fill x
            set aspectlist($aspectcount,asplook) {}
            set del [ttk::button $aspectlistSTabNB.$fr.delete \
                     -text [_m "Label|Delete Aspect"] \
                     -command [mymethod _deleteAspect $aspectcount]]
            pack $del -fill x
        }
        method _deleteAspect {index} {
            set fr $aspectlist($index,frame)
            $aspectlistSTabNB forget $aspectlistSTabNB.$fr
            unset $aspectlist($index,frame)
            unset $aspectlist($index,asplook)
            unset $aspectlist($index,aspl)
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            set result [[$self cget -db] newSignal $name]
            foreach a [lsort [array names aspectlist -glob *,frame]] {
                regsub {^([[:digit:]]+),frame} => index
                [$self cget -db] addAspect $name \
                      -aspect [[$aspectlist($index,aspl)] get] \
                      -look   [[$aspectlist($index,asplook)] get]
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor NewSensorDialog {
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -modal local -transient yes \
                  -side bottom -title [_ "New Sensor"] \
                  -parent [from args -parent]
            $hull add add    -text Add    -command [mymethod _Add]
            $hull add cancel -text Cancel -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            set result [[$self cget -db] newSensor $name]
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor NewControlDialog {
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -modal local -transient yes \
                  -side bottom -title [_ "New Control"] \
                  -parent [from args -parent]
            $hull add add    -text Add    -command [mymethod _Add]
            $hull add cancel -text Cancel -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            set result [[$self cget -db] newControl $name]
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
}

package provide LayoutControlDBDialogs 1.0
