#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sat Aug 21 14:25:53 2021
#  Last Modified : <210821.1605>
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
package require gettext
package require LinuxGpio
package require Tk
package require tile
package require Dialog
package require LabelFrames
package require ButtonBox
package require ScrollableFrame
package require MainWindow 

set argv0 [file join [file dirname [info nameofexecutable]] [file rootname [file tail [info script]]]]
package require Version
namespace export _*
global ImageDir 
set ImageDir [file join [file dirname [file dirname [info script]]] \
              Common]
global HelpDir
set HelpDir [file join [file dirname [file dirname [file dirname \
                                                    [info script]]]] Help]
set msgfiles [::msgcat::mcload [file join [file dirname [file dirname\
                                                         [file dirname \
                                                          [info script]]]] \
                                                         Messages]]

snit::widgetadaptor OutputList {
    variable _gpios [list]
    variable _gpioWidgetMap -array {}
    variable _frame
    variable _widgetIndex 0
    method destroyall {} {
        foreach g $_gpios {
            set w $_gpioWidgetMap($g)
            destroy $w
            $g destroy
        }
    }
    method addgpio {pinno} {
        if {[catch {linuxgpio::GpioOutputSafeLow %AUTO% -pinnumber $pinno} gpio]} {
            error [_ "Not a valid pin: %d" $pinno]
        }
        incr _widgetIndex
        set w [ttk::labelframe ${_frame}.lf${_widgetIndex} \
               -labelanchor nw -text [_ "GPIO %d" $pinno]]
        pack $w -expand yes -fill x
        upvar #0 $w rgroup
        set rgroup 0
        set on [ttk::radiobutton $w.on -text "High" -value 1 \
                -command [mymethod _on $gpio] -variable $w]
        set off [ttk::radiobutton $w.off -text "Low" -value 0 \
                 -command [mymethod _off $gpio] -variable $w]
        pack $on -side left -expand yes -fill x
        pack $off -side left -expand yes -fill x
        $hull see $w
        lappend _gpios $gpio
        set _gpioWidgetMap($gpio) $w
    }
    method _on {gpio} {
        $gpio Set
    }
    method _off {gpio} {
        $gpio Clr
    }
    delegate option -xscrollcommand to hull
    delegate option -yscrollcommand to hull
    delegate option -xscrollincrement to hull
    delegate option -yscrollincrement to hull
    delegate option -height to hull
    delegate option -width to hull
    delegate method xview to hull
    delegate method yview to hull
    delegate method _themeChanged_ to hull
    delegate method _resize_ to hull
    constructor {args} {
        installhull using ScrollableFrame  \
                        -constrainedwidth yes
        $self configurelist $args
        set _frame [$hull getframe]
    }
}

snit::type TestGPIOOutput {
    pragma -hastypeinfo    no
    pragma -hastypedestroy no
    pragma -hasinstances   no
    typecomponent main
    typecomponent   outputlist
    typeconstructor {
        set main [mainwindow .main]
        pack $main -expand yes -fill both
        set outputlist [OutputList \
                        [$main scrollwindow getframe].olist]
        $main scrollwindow setwidget $outputlist
        $main menu entryconfigure file "Exit" -command [mytypemethod _exit]
        $main menu delete file "New"
        $main menu delete file "Open..."
        $main menu delete file "Save"
        $main menu delete file "Save As..."
        $main menu delete file "Close"
        set GPIOCount  [from ::argv -gpiocount 16]
        set Start [from ::argv -start [expr {512 - $GPIOCount}]]
        for {set off 0} {$off < $GPIOCount} {incr off} {
            $outputlist addgpio [expr {$Start + $off}]
        }
        $main showit
    }
    typemethod _exit {} {
        $outputlist destroyall
        ::exit
    }
}
