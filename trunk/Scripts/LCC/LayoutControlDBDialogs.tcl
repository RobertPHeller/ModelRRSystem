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
#  Last Modified : <210630.0911>
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
package require ButtonBox

namespace eval lcc {
    snit::macro _layoutControlCopyPaste {} {
        method _copyevent {e varname} {
            $e selection range 0 end
        }
        method _pasteevent {e varname} {
            if {[catch {selection get} select]} {return}
            if {$select eq ""} {return}
            if {[catch {lcc::eventidstring validate $select}]} {return}
            upvar #0 "$varname" var
            set var $select
        }
    }
    snit::widgetadaptor NewTurnoutDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        delegate option -modal  to hull
        option -db
        option -nameonly -readonly yes -default no -type snit::boolean
        
        component nameLE;#                  Name of object
        component normalEventLF;#           -normalmotorevent
        variable  normal_ {00.00.00.00.00.00.00.00}
        component reverseEventLF;#          -reversemotorevent
        variable  reverse_ {00.00.00.00.00.00.00.00}
        component normalPointsEventLF;#     -normalpointsevent
        variable  normalPoints_ {00.00.00.00.00.00.00.00}
        component reversePointsEventLF;#    -reversepointsevent
        variable  reversePoints_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes \
                  -side bottom -title [_ "New Turnout"] \
                  -parent [from args -parent]
            $hull add add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            if {[$self cget -nameonly]} {return}
            install normalEventLF using LabelFrame \
                  $frame.normalEventLF -text [_m "Label|Normal Motor Event:"]
            pack $frame.normalEventLF -fill x
            pack [ttk::entry [set e [$frame.normalEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar normal_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar normal_]]] \
                  -side left
            pack [ttk::button [$frame.normalEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar normal_]]] \
                  -side left
            install reverseEventLF using LabelFrame \
                  $frame.reverseEventLF -text [_m "Label|Reverse Motor Event:"]
            pack $frame.reverseEventLF -fill x
            pack [ttk::entry [set e [$frame.reverseEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar reverse_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reverseEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar reverse_]]] \
                  -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reverseEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar reverse_]]] \
                  -side left \
                  -expand yes -fill x
            install normalPointsEventLF using LabelFrame \
                  $frame.normalPointsEventLF -text [_m "Label|Normal Points Event:"]
            pack $frame.normalPointsEventLF -fill x
            pack [ttk::entry [set e [$frame.normalPointsEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar normalPoints_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalPointsEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar normalPoints_]]] \
                  -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalPointsEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar normalPoints_]]] \
                  -side left \
                  -expand yes -fill x
            install reversePointsEventLF using LabelFrame \
                  $frame.reversePointsEventLF -text [_m "Label|Reverse Points Event:"]
            pack $frame.reversePointsEventLF -fill x
            pack [ttk::entry [set e [$frame.reversePointsEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar reversePoints_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reversePointsEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar reversePoints_]]] \
                  -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reversePointsEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar reversePoints_]]] \
                  -side left \
                  -expand yes -fill x
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] newTurnout $name]
            if {[$self cget -nameonly]} {return}
            if {$normal_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName motor -depth 1]
                #puts stderr "$self _Add: tag (motor) is '$tag'"
                [$tag getElementsByTagName normal -depth 1] setdata $normal_
            }
            if {$reverse_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName motor -depth 1]
                #puts stderr "$self _Add: tag (motor) is '$tag'"
                [$tag getElementsByTagName reverse -depth 1] setdata $reverse_
            }
            if {$normalPoints_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName points -depth 1]
                [$tag getElementsByTagName normal -depth 1] setdata $normalPoints_
            }
            if {$reversePoints_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName points -depth 1]
                [$tag getElementsByTagName reverse -depth 1] setdata $reversePoints_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor EditTurnoutDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        option -db
        
        component nameLE;#                  Name of object
        component normalEventLF;#           -normalmotorevent
        variable  normal_ {00.00.00.00.00.00.00.00}
        component reverseEventLF;#          -reversemotorevent
        variable  reverse_ {00.00.00.00.00.00.00.00}
        component normalPointsEventLF;#     -normalpointsevent
        variable  normalPoints_ {00.00.00.00.00.00.00.00}
        component reversePointsEventLF;#    -reversepointsevent
        variable  reversePoints_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes -modal local\
                  -side bottom -title [_ "New Turnout"] \
                  -parent [from args -parent]
            $hull add update    -text [_m "Label|Update"]    -command [mymethod _Update]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {} -editable no
            pack $nameLE -fill x
            $self configurelist $args
            install normalEventLF using LabelFrame \
                  $frame.normalEventLF -text [_m "Label|Normal Motor Event:"]
            pack $frame.normalEventLF -fill x
            pack [ttk::entry [set e [$frame.normalEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar normal_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar normal_]]] \
                  -side left
            pack [ttk::button [$frame.normalEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar normal_]]] \
                  -side left
            install reverseEventLF using LabelFrame \
                  $frame.reverseEventLF -text [_m "Label|Reverse Motor Event:"]
            pack $frame.reverseEventLF -fill x
            pack [ttk::entry [set e [$frame.reverseEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar reverse_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reverseEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar reverse_]]] \
                  -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reverseEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar reverse_]]] \
                  -side left \
                  -expand yes -fill x
            install normalPointsEventLF using LabelFrame \
                  $frame.normalPointsEventLF -text [_m "Label|Normal Points Event:"]
            pack $frame.normalPointsEventLF -fill x
            pack [ttk::entry [set e [$frame.normalPointsEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar normalPoints_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalPointsEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar normalPoints_]]] \
                  -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalPointsEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar normalPoints_]]] \
                  -side left \
                  -expand yes -fill x
            install reversePointsEventLF using LabelFrame \
                  $frame.reversePointsEventLF -text [_m "Label|Reverse Points Event:"]
            pack $frame.reversePointsEventLF -fill x
            pack [ttk::entry [set e [$frame.reversePointsEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar reversePoints_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reversePointsEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar reversePoints_]]] \
                  -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reversePointsEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar reversePoints_]]] \
                  -side left \
                  -expand yes -fill x
        }
        method draw {name args} {
            $self configurelist $args
            set result [[$self cget -db] getTurnout $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set tag [$result getElementsByTagName motor -depth 1]
            set normal_ [[$tag getElementsByTagName normal -depth 1] data]
            if {$normal_ eq ""} {
                set normal_ {00.00.00.00.00.00.00.00}
            }
            set reverse_ [[$tag getElementsByTagName reverse -depth 1] data]
            if {$reverse_ eq ""} {
                set reverse_ {00.00.00.00.00.00.00.00}
            }
            set tag [$result getElementsByTagName points -depth 1]
            set normalPoints_ [[$tag getElementsByTagName normal -depth 1] data]
            if {$normalPoints_ eq ""} {
                set normalPoints_ {00.00.00.00.00.00.00.00}
            }
            set reversePoints_ [[$tag getElementsByTagName reverse -depth 1] data]
            if {$reversePoints_ eq ""} {
                set reversePoints_ {00.00.00.00.00.00.00.00}
            }
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Update {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] getTurnout $name]
            if {$result eq {}} {return}
            if {$normal_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName motor -depth 1]
                #puts stderr "$self _Add: tag (motor) is '$tag'"
                [$tag getElementsByTagName normal -depth 1] setdata $normal_
            }
            if {$reverse_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName motor -depth 1]
                #puts stderr "$self _Add: tag (motor) is '$tag'"
                [$tag getElementsByTagName reverse -depth 1] setdata $reverse_
            }
            if {$normalPoints_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName points -depth 1]
                [$tag getElementsByTagName normal -depth 1] setdata $normalPoints_
            }
            if {$reversePoints_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName points -depth 1]
                [$tag getElementsByTagName reverse -depth 1] setdata $reversePoints_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widget NewTurnoutWidget {
        _layoutControlCopyPaste
        option -db
        option -edit -type snit::boolean -readonly yes -default false
        
        component nameLE;#                  Name of object
        component normalEventLF;#           -normalmotorevent
        variable  normal_ {00.00.00.00.00.00.00.00}
        component reverseEventLF;#          -reversemotorevent
        variable  reverse_ {00.00.00.00.00.00.00.00}
        component normalPointsEventLF;#     -normalpointsevent
        variable  normalPoints_ {00.00.00.00.00.00.00.00}
        component reversePointsEventLF;#    -reversepointsevent
        variable  reversePoints_ {00.00.00.00.00.00.00.00}
        component buttons
        constructor {args} {
            set frame $win
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            install normalEventLF using LabelFrame \
                  $frame.normalEventLF -text [_m "Label|Normal Motor Event:"]
            pack $frame.normalEventLF -fill x
            pack [ttk::entry [set e [$frame.normalEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar normal_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar normal_]]] \
                  -side left
            pack [ttk::button [$frame.normalEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar normal_]]] \
                  -side left
            install reverseEventLF using LabelFrame \
                  $frame.reverseEventLF -text [_m "Label|Reverse Motor Event:"]
            pack $frame.reverseEventLF -fill x
            pack [ttk::entry [set e [$frame.reverseEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar reverse_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reverseEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar reverse_]]] \
                  -side left
            pack [ttk::button [$frame.reverseEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar reverse_]]] \
                  -side left
            install normalPointsEventLF using LabelFrame \
                  $frame.normalPointsEventLF -text [_m "Label|Normal Points Event:"]
            pack $frame.normalPointsEventLF -fill x
            pack [ttk::entry [set e [$frame.normalPointsEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar normalPoints_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.normalPointsEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar normalPoints_]]] \
                  -side left
            pack [ttk::button [$frame.normalPointsEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar normalPoints_]]] \
                  -side left
            install reversePointsEventLF using LabelFrame \
                  $frame.reversePointsEventLF -text [_m "Label|Reverse Points Event:"]
            pack $frame.reversePointsEventLF -fill x
            pack [ttk::entry [set e [$frame.reversePointsEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar reversePoints_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.reversePointsEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar reversePoints_]]] \
                  -side left
            pack [ttk::button [$frame.reversePointsEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar reversePoints_]]] \
                  -side left
            install buttons using ButtonBox $frame.buttons -orient horizontal
            pack $buttons -fill x
            $buttons add ttk::button add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $buttons add ttk::button clear -text [_m "Label|Clear"] -command [mymethod _Clear]
            $self configurelist $args
            if {[$self cget -edit]} {
                $nameLE configure -editable false
                $buttons itemconfigure add -text [_m "Label|Update"] \
                      -state disabled
            }
        }
        method Load {name args} {
            $self configurelist $args
            if {![$self cget -edit]} {return}
            set result [[$self cget -db] getTurnout $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set tag [$result getElementsByTagName motor -depth 1]
            set normal_ [[$tag getElementsByTagName normal -depth 1] data]
            if {$normal_ eq ""} {
                set normal_ {00.00.00.00.00.00.00.00}
            }
            set reverse_ [[$tag getElementsByTagName reverse -depth 1] data]
            if {$reverse_ eq ""} {
                set reverse_ {00.00.00.00.00.00.00.00}
            }
            set tag [$result getElementsByTagName points -depth 1]
            set normalPoints_ [[$tag getElementsByTagName normal -depth 1] data]
            if {$normalPoints_ eq ""} {
                set normalPoints_ {00.00.00.00.00.00.00.00}
            }
            set reversePoints_ [[$tag getElementsByTagName reverse -depth 1] data]
            if {$reversePoints_ eq ""} {
                set reversePoints_ {00.00.00.00.00.00.00.00}
            }
            $buttons itemconfigure add -state normal
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            #puts stderr "$self _Add: name is '$name'"
            set result [[$self cget -db] newTurnout $name]
            #puts stderr "$self _Add: result is '$result'"
            if {$normal_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName motor -depth 1]
                #puts stderr "$self _Add: tag (motor) is '$tag'"
                [$tag getElementsByTagName normal -depth 1] setdata $normal_
            }
            if {$reverse_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName motor -depth 1]
                #puts stderr "$self _Add: tag (motor) is '$tag'"
                [$tag getElementsByTagName reverse -depth 1] setdata $reverse_
            }
            if {$normalPoints_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName points -depth 1]
                [$tag getElementsByTagName normal -depth 1] setdata $normalPoints_
            }
            if {$reversePoints_ ne {00.00.00.00.00.00.00.00}} {
                set tag [$result getElementsByTagName points -depth 1]
                [$tag getElementsByTagName reverse -depth 1] setdata $reversePoints_
            }
        }
        method _Clear {} {
            $nameLE delete 0 end
            set normal_ {00.00.00.00.00.00.00.00}
            set reverse_ {00.00.00.00.00.00.00.00}
            set normalPoints_ {00.00.00.00.00.00.00.00}
            set reversePoints_ {00.00.00.00.00.00.00.00}
        }
    }
    snit::widgetadaptor NewBlockDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        delegate option -modal  to hull
        option -db
        option -nameonly -readonly yes -default no -type snit::boolean
        component nameLE;#                  Name of object
        component occupiedEventLF;#         -occupiedevent
        variable  occupied_ {00.00.00.00.00.00.00.00}
        component clearEventLF;#            -clearevent
        variable  clear_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes \
                  -side bottom -title [_ "New Block"] \
                  -parent [from args -parent]
            $hull add add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            if {[$self cget -nameonly]} {return}
            install occupiedEventLF using LabelFrame \
                  $frame.occupiedEventLF -text [_m "Label|Occupied Event:"]
            pack $occupiedEventLF -fill x
            pack [ttk::entry [set e [$frame.occupiedEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar occupied_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.occupiedEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar occupied_]]] \
                  -side left
            pack [ttk::button [$frame.occupiedEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar occupied_]]] \
                  -side left
                    install clearEventLF using LabelFrame \
                  $frame.clearEventLF -text [_m "Label|Clear Event:"]
            pack $clearEventLF -fill x
            pack [ttk::entry [set e [$frame.clearEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar clear_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.clearEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar clear_]]] \
                  -side left
            pack [ttk::button [$frame.clearEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar clear_]]] \
                  -side left
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] newBlock $name]
            if {[$self cget -nameonly]} {return}
            if {$occupied_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName occupied -depth 1] setdata $occupied_
            }
            if {$clear_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName clear -depth 1] setdata $clear_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor EditBlockDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        component occupiedEventLF;#         -occupiedevent
        variable  occupied_ {00.00.00.00.00.00.00.00}
        component clearEventLF;#            -clearevent
        variable  clear_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -modal local -transient yes \
                  -side bottom -title [_ "New Block"] \
                  -parent [from args -parent]
            $hull add update -text [_m "Label|Update"] -command [mymethod _Update]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {} -editable no
            pack $nameLE -fill x
            $self configurelist $args
            install occupiedEventLF using LabelFrame \
                  $frame.occupiedEventLF -text [_m "Label|Occupied Event:"]
            pack $occupiedEventLF -fill x
            pack [ttk::entry [set e [$frame.occupiedEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar occupied_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.occupiedEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar occupied_]]] \
                  -side left
            pack [ttk::button [$frame.occupiedEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar occupied_]]] \
                  -side left
                    install clearEventLF using LabelFrame \
                  $frame.clearEventLF -text [_m "Label|Clear Event:"]
            pack $clearEventLF -fill x
            pack [ttk::entry [set e [$frame.clearEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar clear_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.clearEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar clear_]]] \
                  -side left
            pack [ttk::button [$frame.clearEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar clear_]]] \
                  -side left
        }
        method draw {name args} {
            $self configurelist $args
            set result [[$self cget -db] getBlock $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set occupied_ [[$result getElementsByTagName occupied -depth 1] data]
            if {$occupied_ eq ""} {
                set occupied_ {00.00.00.00.00.00.00.00}
            }
            set clear_ [[$result getElementsByTagName clear -depth 1] data]
            if {$clear_ eq ""} {
                set clear_ {00.00.00.00.00.00.00.00}
            }
            return [$hull draw]
        }
        method _Update {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] getBlock $name]
            if {$occupied_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName occupied -depth 1] setdata $occupied_
            }
            if {$clear_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName clear -depth 1] setdata $clear_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widget NewBlockWidget {
        _layoutControlCopyPaste
        option -db
        option -edit -type snit::boolean -readonly yes -default false
        
        component nameLE;#                  Name of object
        component occupiedEventLF;#         -occupiedevent
        variable  occupied_ {00.00.00.00.00.00.00.00}
        component clearEventLF;#            -clearevent
        variable  clear_ {00.00.00.00.00.00.00.00}
        component buttons
        constructor {args} {
            set frame $win
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            install occupiedEventLF using LabelFrame \
                  $frame.occupiedEventLF -text [_m "Label|Occupied Event:"]
            pack $occupiedEventLF -fill x
            pack [ttk::entry [set e [$frame.occupiedEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar occupied_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.occupiedEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar occupied_]]] \
                  -side left
            pack [ttk::button [$frame.occupiedEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar occupied_]]] \
                  -side left
                    install clearEventLF using LabelFrame \
                  $frame.clearEventLF -text [_m "Label|Clear Event:"]
            pack $clearEventLF -fill x
            pack [ttk::entry [set e [$frame.clearEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar clear_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.clearEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar clear_]]] \
                  -side left
            pack [ttk::button [$frame.clearEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar clear_]]] \
                  -side left
            install buttons using ButtonBox $frame.buttons -orient horizontal
            pack $buttons -fill x
            $buttons add ttk::button add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $buttons add ttk::button clear -text [_m "Label|Clear"] -command [mymethod _Clear]
            $self configurelist $args
            if {[$self cget -edit]} {
                $nameLE configure -editable false
                $buttons itemconfigure add -text [_m "Label|Update"] \
                      -state disabled
            }
        }
        method Load {name args} {
            $self configurelist $args
            if {![$self cget -edit]} {return}
            set result [[$self cget -db] getBlock $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set occupied_ [[$result getElementsByTagName occupied -depth 1] data]
            if {$occupied_ eq ""} {
                set occupied_ {00.00.00.00.00.00.00.00}
            }
            set clear_ [[$result getElementsByTagName clear -depth 1] data]
            if {$clear_ eq ""} {
                set clear_ {00.00.00.00.00.00.00.00}
            }
            $buttons itemconfigure add -state normal
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            #puts stderr "$self _Add: name is '$name'"
            set result [[$self cget -db] newBlock $name]
            #puts stderr "$self _Add: result is '$result'"
            if {$occupied_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName occupied -depth 1] setdata $occupied_
            }
            if {$clear_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName clear -depth 1] setdata $clear_
            }
        }
        method _Clear {} {
            $nameLE delete 0 end
            set occupied_ {00.00.00.00.00.00.00.00}
            set clear_ {00.00.00.00.00.00.00.00}
        }
    }
            
    snit::widgetadaptor NewSensorDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        delegate option -modal  to hull
        option -db
        option -nameonly -readonly yes -default no -type snit::boolean
        component nameLE;#                  Name of object
        component onEventLF;#               -onevent
        variable  on_ {00.00.00.00.00.00.00.00}
        component offEventLF;#              -offevent
        variable  off_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes \
                  -side bottom -title [_ "New Sensor"] \
                  -parent [from args -parent]
            $hull add add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            if {[$self cget -nameonly]} {return}
            install onEventLF using LabelFrame \
                  $frame.onEventLF -text [_m "Label|On Event:"]
            pack $onEventLF -fill x
            pack [ttk::entry [set e [$frame.onEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar on_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.onEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar on_]]] \
                  -side left
            pack [ttk::button [$frame.onEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar on_]]] \
                  -side left
            install offEventLF using LabelFrame \
                  $frame.offEventLF -text [_m "Label|Off Event:"]
            pack $offEventLF -fill x
            pack [ttk::entry [set e [$frame.offEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar off_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.offEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar off_]]] \
                  -side left
            pack [ttk::button [$frame.offEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar off_]]] \
                  -side left
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] newSensor $name]
            if {[$self cget -nameonly]} {return}
            if {$on_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName on -depth 1] setdata $on_
            }
            if {$off_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName off -depth 1] setdata $off_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor EditSensorDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        component onEventLF;#               -onevent
        variable  on_ {00.00.00.00.00.00.00.00}
        component offEventLF;#              -offevent
        variable  off_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes -modal local \
                  -side bottom -title [_ "New Sensor"] \
                  -parent [from args -parent]
            $hull add add    -text [_m "Label|Update"] -command [mymethod _Update]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            install onEventLF using LabelFrame \
                  $frame.onEventLF -text [_m "Label|On Event:"]
            pack $onEventLF -fill x
            pack [ttk::entry [set e [$frame.onEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar on_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.onEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar on_]]] \
                  -side left
            pack [ttk::button [$frame.onEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar on_]]] \
                  -side left
            install offEventLF using LabelFrame \
                  $frame.offEventLF -text [_m "Label|Off Event:"]
            pack $offEventLF -fill x
            pack [ttk::entry [set e [$frame.offEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar off_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.offEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar off_]]] \
                  -side left
            pack [ttk::button [$frame.offEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar off_]]] \
                  -side left
        }
        method draw {name args} {
            $self configurelist $args
            set result [[$self cget -db] getSensor $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set on_ [[$result getElementsByTagName on -depth 1] data]
            if {$on_ eq ""} {
                set on_ {00.00.00.00.00.00.00.00}
            }
            set off_ [[$result getElementsByTagName off -depth 1] data]
            if {$off_ eq ""} {
                set off_ {00.00.00.00.00.00.00.00}
            }
            return [$hull draw]
        }
        method _Update {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] getSensor $name]
            if {$on_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName on -depth 1] setdata $on_
            }
            if {$off_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName off -depth 1] setdata $off_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widget NewSensorWidget {
        _layoutControlCopyPaste
        option -db
        option -edit -type snit::boolean -readonly yes -default false

        component nameLE;#                  Name of object
        component onEventLF;#               -onevent
        variable  on_ {00.00.00.00.00.00.00.00}
        component offEventLF;#              -offevent
        variable  off_ {00.00.00.00.00.00.00.00}
        component buttons
        constructor {args} {
            set frame $win
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            install onEventLF using LabelFrame \
                  $frame.onEventLF -text [_m "Label|On Event:"]
            pack $onEventLF -fill x
            pack [ttk::entry [set e [$frame.onEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar on_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.onEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar on_]]] \
                  -side left
            pack [ttk::button [$frame.onEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar on_]]] \
                  -side left
            install offEventLF using LabelFrame \
                  $frame.offEventLF -text [_m "Label|Off Event:"]
            pack $offEventLF -fill x
            pack [ttk::entry [set e [$frame.offEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar off_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.offEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar off_]]] \
                  -side left
            pack [ttk::button [$frame.offEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar off_]]] \
                  -side left
            install buttons using ButtonBox $frame.buttons -orient horizontal
            pack $buttons -fill x
            $buttons add ttk::button add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $buttons add ttk::button clear -text [_m "Label|Clear"] -command [mymethod _Clear]
            $self configurelist $args
            if {[$self cget -edit]} {
                $nameLE configure -editable false
                $buttons itemconfigure add -text [_m "Label|Update"] \
                      -state disabled
            }
        }
        method Load {name args} {
            $self configurelist $args
            if {![$self cget -edit]} {return}
            set result [[$self cget -db] getSensor $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set on_ [[$result getElementsByTagName on -depth 1] data]
            if {$on_ eq ""} {
                set on_ {00.00.00.00.00.00.00.00}
            }
            set off_ [[$result getElementsByTagName off -depth 1] data]
            if {$off_ eq ""} {
                set off_ {00.00.00.00.00.00.00.00}
            }
            $buttons itemconfigure add -state normal
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            #puts stderr "$self _Add: name is '$name'"
            set result [[$self cget -db] newSensor $name]
            #puts stderr "$self _Add: result is '$result'"
            if {$on_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName on -depth 1] setdata $on_
            }
            if {$off_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName off -depth 1] setdata $off_
            }
        }
        method _Clear {} {
            $nameLE delete 0 end
            set on_ {00.00.00.00.00.00.00.00}
            set off_ {00.00.00.00.00.00.00.00}
        }
    }
    snit::widgetadaptor NewControlDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        delegate option -modal  to hull
        option -db
        option -nameonly -readonly yes -default no -type snit::boolean
        component nameLE;#                  Name of object
        component onEventLF;#               -onevent
        variable  on_ {00.00.00.00.00.00.00.00}
        component offEventLF;#              -offevent
        variable  off_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes \
                  -side bottom -title [_ "New Control"] \
                  -parent [from args -parent]
            $hull add add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            if {[$self cget -nameonly]} {return}
            install onEventLF using LabelFrame \
                  $frame.onEventLF -text [_m "Label|On Event:"]
            pack $onEventLF -fill x
            pack [ttk::entry [set e [$frame.onEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar on_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.onEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar on_]]] \
                  -side left
            pack [ttk::button [$frame.onEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar on_]]] \
                  -side left
            install offEventLF using LabelFrame \
                  $frame.offEventLF -text [_m "Label|Off Event:"]
            pack $offEventLF -fill x
            pack [ttk::entry [set e [$frame.offEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar off_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.offEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar off_]]] \
                  -side left
            pack [ttk::button [$frame.offEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar off_]]] \
                  -side left
        }
        method draw {args} {
            $self configurelist $args
            set options(-parent) [$self cget -parent]
            return [$hull draw]
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] newControl $name]
            if {[$self cget -nameonly]} {return}
            if {$on_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName on -depth 1] setdata $on_
            }
            if {$off_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName off -depth 1] setdata $off_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widgetadaptor EditControlDialog {
        _layoutControlCopyPaste
        delegate option -parent to hull
        option -db
        component nameLE;#                  Name of object
        component onEventLF;#               -onevent
        variable  on_ {00.00.00.00.00.00.00.00}
        component offEventLF;#              -offevent
        variable  off_ {00.00.00.00.00.00.00.00}
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes -modal local \
                  -side bottom -title [_ "New Control"] \
                  -parent [from args -parent]
            $hull add add    -text [_m "Label|Update"] -command [mymethod _Update]
            $hull add cancel -text [_m "Label|Cancel"] -command [mymethod _Cancel]
            wm protocol [winfo toplevel $win] WM_DELETE_WINDOW [mymethod _Cancel]
            set frame [$hull getframe]
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            install onEventLF using LabelFrame \
                  $frame.onEventLF -text [_m "Label|On Event:"]
            pack $onEventLF -fill x
            pack [ttk::entry [set e [$frame.onEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar on_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.onEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar on_]]] \
                  -side left
            pack [ttk::button [$frame.onEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar on_]]] \
                  -side left
            install offEventLF using LabelFrame \
                  $frame.offEventLF -text [_m "Label|Off Event:"]
            pack $offEventLF -fill x
            pack [ttk::entry [set e [$frame.offEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar off_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.offEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar off_]]] \
                  -side left
            pack [ttk::button [$frame.offEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar off_]]] \
                  -side left
        }
        method draw {name args} {
            $self configurelist $args
            set result [[$self cget -db] getSensor $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set on_ [[$result getElementsByTagName on -depth 1] data]
            if {$on_ eq ""} {
                set on_ {00.00.00.00.00.00.00.00}
            }
            set off_ [[$result getElementsByTagName off -depth 1] data]
            if {$off_ eq ""} {
                set off_ {00.00.00.00.00.00.00.00}
            }
            return [$hull draw]
        }
        method _Update {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            set result [[$self cget -db] getControl $name]
            if {$on_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName on -depth 1] setdata $on_
            }
            if {$off_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName off -depth 1] setdata $off_
            }
            $hull withdraw
            return [$hull enddialog $result]
        }
        method _Cancel {} {
            $hull withdraw
            return [$hull enddialog {}]
        }
    }
    snit::widget NewControlWidget {
        _layoutControlCopyPaste
        option -db
        option -edit -type snit::boolean -readonly yes -default false
        
        component nameLE;#                  Name of object
        component onEventLF;#               -onevent
        variable  on_ {00.00.00.00.00.00.00.00}
        component offEventLF;#              -offevent
        variable  off_ {00.00.00.00.00.00.00.00}
        component buttons
        constructor {args} {
            set frame $win
            install nameLE using LabelEntry $frame.nameLE \
                  -label [_m "Label|Name:"] -text {}
            pack $nameLE -fill x
            $self configurelist $args
            install onEventLF using LabelFrame \
                  $frame.onEventLF -text [_m "Label|On Event:"]
            pack $onEventLF -fill x
            pack [ttk::entry [set e [$frame.onEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar on_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.onEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar on_]]] \
                  -side left
            pack [ttk::button [$frame.onEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar on_]]] \
                  -side left
            install offEventLF using LabelFrame \
                  $frame.offEventLF -text [_m "Label|Off Event:"]
            pack $offEventLF -fill x
            pack [ttk::entry [set e [$frame.offEventLF getframe].e] \
                  -text {00.00.00.00.00.00.00.00} \
                  -textvariable [myvar off_]] -side left \
                  -expand yes -fill x
            pack [ttk::button [$frame.offEventLF getframe].copy \
                  -text [_m "Label|Copy"] \
                  -command [mymethod _copyevent $e [myvar off_]]] \
                  -side left
            pack [ttk::button [$frame.offEventLF getframe].paste \
                  -text [_m "Label|Paste"] \
                  -command [mymethod _pasteevent $e [myvar off_]]] \
                  -side left
            install buttons using ButtonBox $frame.buttons -orient horizontal
            pack $buttons -fill x
            $buttons add ttk::button add    -text [_m "Label|Add"]    -command [mymethod _Add]
            $buttons add ttk::button clear -text [_m "Label|Clear"] -command [mymethod _Clear]
            $self configurelist $args
            if {[$self cget -edit]} {
                $nameLE configure -editable false
                $buttons itemconfigure add -text [_m "Label|Update"] \
                      -state disabled
            }
        }
        method Load {name args} {
            $self configurelist $args
            if {![$self cget -edit]} {return}
            set result [[$self cget -db] getControl $name]
            if {$result eq {}} {return}
            $nameLE configure -text $name
            set on_ [[$result getElementsByTagName on -depth 1] data]
            if {$on_ eq ""} {
                set on_ {00.00.00.00.00.00.00.00}
            }
            set off_ [[$result getElementsByTagName off -depth 1] data]
            if {$off_ eq ""} {
                set off_ {00.00.00.00.00.00.00.00}
            }
            $buttons itemconfigure add -state normal
        }
        method _Add {} {
            set name "[$nameLE cget -text]"
            if {$name eq ""} {return}
            #puts stderr "$self _Add: name is '$name'"
            set result [[$self cget -db] newControl $name]
            #puts stderr "$self _Add: result is '$result'"
            if {$on_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName on -depth 1] setdata $on_
            }
            if {$off_ ne {00.00.00.00.00.00.00.00}} {
                [$result getElementsByTagName off -depth 1] setdata $off_
            }
        }
        method _Clear {} {
            $nameLE delete 0 end
            set on_ {00.00.00.00.00.00.00.00}
            set off_ {00.00.00.00.00.00.00.00}
        }
    }
    snit::widgetadaptor NewSignalDialog {
        delegate option -parent to hull
        delegate option -modal  to hull
        option -db
        option -nameonly -readonly yes -default no -type snit::boolean
        component nameLE;#                  Name of object
        component aspectlistLF
        component   aspectlistSTabNB
        variable    aspectlist -array {}
        component   addaspectB
        
        constructor {args} {
            installhull using Dialog -bitmap questhead -default add \
                  -cancel cancel -transient yes \
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
            pack $addaspectB -expand yes -fill x
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
            set aspectlist($aspectcount,aspl) $aspl_
            set asplook_ [LabelEntry $aspectlistSTabNB.$fr.asplook \
                          -label [_m "Label|Aspect Look"] \
                          -text {}]
            pack $asplook_ -fill x
            set aspectlist($aspectcount,asplook) $asplook_
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
            if {$name eq ""} {return}
            set result [[$self cget -db] newSignal $name]
            foreach a [lsort [array names aspectlist -glob *,frame]] {
                #puts stderr "*** $self _Add: a is '$a'"
                regexp {^([[:digit:]]+),frame} $a => index
                #puts stderr "*** $self _Add: index is $index"
                [$self cget -db] addAspect $name \
                      -aspect [$aspectlist($index,aspl) get] \
                      -look   [$aspectlist($index,asplook) get]
            }
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
